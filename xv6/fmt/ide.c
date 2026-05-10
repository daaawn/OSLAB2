4300 // Simple PIO-based (non-DMA) IDE driver code.
4301 
4302 #include "types.h"
4303 #include "defs.h"
4304 #include "param.h"
4305 #include "memlayout.h"
4306 #include "mmu.h"
4307 #include "proc.h"
4308 #include "x86.h"
4309 #include "traps.h"
4310 #include "spinlock.h"
4311 #include "sleeplock.h"
4312 #include "fs.h"
4313 #include "buf.h"
4314 
4315 #define SECTOR_SIZE   512
4316 #define IDE_BSY       0x80
4317 #define IDE_DRDY      0x40
4318 #define IDE_DF        0x20
4319 #define IDE_ERR       0x01
4320 
4321 #define IDE_CMD_READ  0x20
4322 #define IDE_CMD_WRITE 0x30
4323 #define IDE_CMD_RDMUL 0xc4
4324 #define IDE_CMD_WRMUL 0xc5
4325 
4326 #define IDE_DEBUG     1
4327 
4328 // idequeue points to the buf now being read/written to the disk.
4329 // idequeue->qnext points to the next buf to be processed.
4330 // You must hold idelock while manipulating queue.
4331 
4332 static struct spinlock idelock;
4333 static struct buf *idequeue;
4334 
4335 static int havedisk1;
4336 static void idestart(struct buf*);
4337 
4338 // Wait for IDE disk to become ready.
4339 static int
4340 idewait(int checkerr)
4341 {
4342   int r;
4343 
4344   while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
4345     ;
4346   if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
4347     return -1;
4348   return 0;
4349 }
4350 void
4351 ideinit(void)
4352 {
4353   int i;
4354 
4355   initlock(&idelock, "ide");
4356   ioapicenable(IRQ_IDE, ncpu - 1);
4357   idewait(0);
4358 
4359   // Check if disk 1 is present
4360   outb(0x1f6, 0xe0 | (1<<4));
4361   for(i=0; i<1000; i++){
4362     if(inb(0x1f7) != 0){
4363       havedisk1 = 1;
4364       break;
4365     }
4366   }
4367 
4368   // Switch back to disk 0.
4369   outb(0x1f6, 0xe0 | (0<<4));
4370 }
4371 
4372 // Start the request for b.  Caller must hold idelock.
4373 static void
4374 idestart(struct buf *b)
4375 {
4376   if(b == 0)
4377     panic("idestart");
4378   if(b->blockno >= FSSIZE)
4379     panic("incorrect blockno");
4380   int sector_per_block =  BSIZE/SECTOR_SIZE;
4381   int sector = b->blockno * sector_per_block;
4382   int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
4383   int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;
4384 
4385   if (sector_per_block > 7) panic("idestart");
4386 
4387   idewait(0);
4388   outb(0x3f6, 0);  // generate interrupt
4389   outb(0x1f2, sector_per_block);  // number of sectors
4390   outb(0x1f3, sector & 0xff);
4391   outb(0x1f4, (sector >> 8) & 0xff);
4392   outb(0x1f5, (sector >> 16) & 0xff);
4393   outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
4394   if(b->flags & B_DIRTY){
4395     outb(0x1f7, write_cmd);
4396     outsl(0x1f0, b->data, BSIZE/4);
4397   } else {
4398     outb(0x1f7, read_cmd);
4399   }
4400 }
4401 
4402 // Interrupt handler.
4403 void
4404 ideintr(void)
4405 {
4406   struct buf *b;
4407 
4408   // First queued buffer is the active request.
4409   acquire(&idelock);
4410 
4411   if((b = idequeue) == 0){
4412     release(&idelock);
4413     return;
4414   }
4415   idequeue = b->qnext;
4416 
4417   // Read data if needed.
4418   if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
4419     insl(0x1f0, b->data, BSIZE/4);
4420 
4421   // Wake process waiting for this buf.
4422   b->flags |= B_VALID;
4423   b->flags &= ~B_DIRTY;
4424   wakeup(b);
4425 
4426   // Start disk on next buf in queue.
4427   if(idequeue != 0)
4428     idestart(idequeue);
4429 
4430   release(&idelock);
4431 }
4432 
4433 
4434 
4435 
4436 
4437 
4438 
4439 
4440 
4441 
4442 
4443 
4444 
4445 
4446 
4447 
4448 
4449 
4450 // Sync buf with disk.
4451 // If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
4452 // Else if B_VALID is not set, read buf from disk, set B_VALID.
4453 void
4454 iderw(struct buf *b)
4455 {
4456   struct buf **pp;
4457 #if IDE_DEBUG
4458   cprintf("b->dev: %x havedisk1: %x\n",b->dev,havedisk1);
4459 #endif
4460   if(!holdingsleep(&b->lock))
4461     panic("iderw: buf not locked");
4462   if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
4463     panic("iderw: nothing to do");
4464   if(b->dev != 0 && !havedisk1)
4465     panic("iderw: ide disk 1 not present");
4466 
4467   acquire(&idelock);  //DOC:acquire-lock
4468 
4469   // Append b to idequeue.
4470   b->qnext = 0;
4471   for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
4472     ;
4473   *pp = b;
4474 
4475   // Start disk if necessary.
4476   if(idequeue == b)
4477     idestart(b);
4478 
4479   // Wait for request to finish.
4480   while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
4481     sleep(b, &idelock);
4482   }
4483 
4484 
4485   release(&idelock);
4486 }
4487 
4488 
4489 
4490 
4491 
4492 
4493 
4494 
4495 
4496 
4497 
4498 
4499 
