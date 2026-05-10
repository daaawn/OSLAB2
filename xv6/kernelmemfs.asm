
kernelmemfs:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <wait_main>:
8010000c:	00 00                	add    %al,(%eax)
	...

80100010 <entry>:
  .long 0
# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  #Set Data Segment
  mov $0x10,%ax
80100010:	66 b8 10 00          	mov    $0x10,%ax
  mov %ax,%ds
80100014:	8e d8                	mov    %eax,%ds
  mov %ax,%es
80100016:	8e c0                	mov    %eax,%es
  mov %ax,%ss
80100018:	8e d0                	mov    %eax,%ss
  mov $0,%ax
8010001a:	66 b8 00 00          	mov    $0x0,%ax
  mov %ax,%fs
8010001e:	8e e0                	mov    %eax,%fs
  mov %ax,%gs
80100020:	8e e8                	mov    %eax,%gs

  #Turn off paing
  movl %cr0,%eax
80100022:	0f 20 c0             	mov    %cr0,%eax
  andl $0x7fffffff,%eax
80100025:	25 ff ff ff 7f       	and    $0x7fffffff,%eax
  movl %eax,%cr0 
8010002a:	0f 22 c0             	mov    %eax,%cr0

  #Set Page Table Base Address
  movl    $(V2P_WO(entrypgdir)), %eax
8010002d:	b8 00 e0 10 00       	mov    $0x10e000,%eax
  movl    %eax, %cr3
80100032:	0f 22 d8             	mov    %eax,%cr3
  
  #Disable IA32e mode
  movl $0x0c0000080,%ecx
80100035:	b9 80 00 00 c0       	mov    $0xc0000080,%ecx
  rdmsr
8010003a:	0f 32                	rdmsr
  andl $0xFFFFFEFF,%eax
8010003c:	25 ff fe ff ff       	and    $0xfffffeff,%eax
  wrmsr
80100041:	0f 30                	wrmsr

  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
80100043:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
80100046:	83 c8 10             	or     $0x10,%eax
  andl    $0xFFFFFFDF, %eax
80100049:	83 e0 df             	and    $0xffffffdf,%eax
  movl    %eax, %cr4
8010004c:	0f 22 e0             	mov    %eax,%cr4

  #Turn on Paging
  movl    %cr0, %eax
8010004f:	0f 20 c0             	mov    %cr0,%eax
  orl     $0x80010001, %eax
80100052:	0d 01 00 01 80       	or     $0x80010001,%eax
  movl    %eax, %cr0
80100057:	0f 22 c0             	mov    %eax,%cr0




  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
8010005a:	bc 80 80 19 80       	mov    $0x80198080,%esp
  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
#  jz .waiting_main
  movl $main, %edx
8010005f:	ba 67 33 10 80       	mov    $0x80103367,%edx
  jmp %edx
80100064:	ff e2                	jmp    *%edx

80100066 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100066:	55                   	push   %ebp
80100067:	89 e5                	mov    %esp,%ebp
80100069:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010006c:	83 ec 08             	sub    $0x8,%esp
8010006f:	68 20 a0 10 80       	push   $0x8010a020
80100074:	68 00 d0 18 80       	push   $0x8018d000
80100079:	e8 76 46 00 00       	call   801046f4 <initlock>
8010007e:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
80100081:	c7 05 4c 17 19 80 fc 	movl   $0x801916fc,0x8019174c
80100088:	16 19 80 
  bcache.head.next = &bcache.head;
8010008b:	c7 05 50 17 19 80 fc 	movl   $0x801916fc,0x80191750
80100092:	16 19 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100095:	c7 45 f4 34 d0 18 80 	movl   $0x8018d034,-0xc(%ebp)
8010009c:	eb 47                	jmp    801000e5 <binit+0x7f>
    b->next = bcache.head.next;
8010009e:	8b 15 50 17 19 80    	mov    0x80191750,%edx
801000a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000a7:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
801000aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ad:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    initsleeplock(&b->lock, "buffer");
801000b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000b7:	83 c0 0c             	add    $0xc,%eax
801000ba:	83 ec 08             	sub    $0x8,%esp
801000bd:	68 27 a0 10 80       	push   $0x8010a027
801000c2:	50                   	push   %eax
801000c3:	e8 cf 44 00 00       	call   80104597 <initsleeplock>
801000c8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000cb:	a1 50 17 19 80       	mov    0x80191750,%eax
801000d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801000d3:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
801000d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d9:	a3 50 17 19 80       	mov    %eax,0x80191750
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000de:	81 45 f4 5c 02 00 00 	addl   $0x25c,-0xc(%ebp)
801000e5:	b8 fc 16 19 80       	mov    $0x801916fc,%eax
801000ea:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ed:	72 af                	jb     8010009e <binit+0x38>
  }
}
801000ef:	90                   	nop
801000f0:	90                   	nop
801000f1:	c9                   	leave
801000f2:	c3                   	ret

801000f3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000f3:	55                   	push   %ebp
801000f4:	89 e5                	mov    %esp,%ebp
801000f6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000f9:	83 ec 0c             	sub    $0xc,%esp
801000fc:	68 00 d0 18 80       	push   $0x8018d000
80100101:	e8 10 46 00 00       	call   80104716 <acquire>
80100106:	83 c4 10             	add    $0x10,%esp

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100109:	a1 50 17 19 80       	mov    0x80191750,%eax
8010010e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100111:	eb 58                	jmp    8010016b <bget+0x78>
    if(b->dev == dev && b->blockno == blockno){
80100113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100116:	8b 40 04             	mov    0x4(%eax),%eax
80100119:	39 45 08             	cmp    %eax,0x8(%ebp)
8010011c:	75 44                	jne    80100162 <bget+0x6f>
8010011e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100121:	8b 40 08             	mov    0x8(%eax),%eax
80100124:	39 45 0c             	cmp    %eax,0xc(%ebp)
80100127:	75 39                	jne    80100162 <bget+0x6f>
      b->refcnt++;
80100129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010012c:	8b 40 4c             	mov    0x4c(%eax),%eax
8010012f:	8d 50 01             	lea    0x1(%eax),%edx
80100132:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100135:	89 50 4c             	mov    %edx,0x4c(%eax)
      release(&bcache.lock);
80100138:	83 ec 0c             	sub    $0xc,%esp
8010013b:	68 00 d0 18 80       	push   $0x8018d000
80100140:	e8 3f 46 00 00       	call   80104784 <release>
80100145:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
80100148:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010014b:	83 c0 0c             	add    $0xc,%eax
8010014e:	83 ec 0c             	sub    $0xc,%esp
80100151:	50                   	push   %eax
80100152:	e8 7c 44 00 00       	call   801045d3 <acquiresleep>
80100157:	83 c4 10             	add    $0x10,%esp
      return b;
8010015a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015d:	e9 9d 00 00 00       	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100162:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100165:	8b 40 54             	mov    0x54(%eax),%eax
80100168:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010016b:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
80100172:	75 9f                	jne    80100113 <bget+0x20>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100174:	a1 4c 17 19 80       	mov    0x8019174c,%eax
80100179:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010017c:	eb 6b                	jmp    801001e9 <bget+0xf6>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010017e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100181:	8b 40 4c             	mov    0x4c(%eax),%eax
80100184:	85 c0                	test   %eax,%eax
80100186:	75 58                	jne    801001e0 <bget+0xed>
80100188:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010018b:	8b 00                	mov    (%eax),%eax
8010018d:	83 e0 04             	and    $0x4,%eax
80100190:	85 c0                	test   %eax,%eax
80100192:	75 4c                	jne    801001e0 <bget+0xed>
      b->dev = dev;
80100194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100197:	8b 55 08             	mov    0x8(%ebp),%edx
8010019a:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010019d:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a0:	8b 55 0c             	mov    0xc(%ebp),%edx
801001a3:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = 0;
801001a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
      b->refcnt = 1;
801001af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001b2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
      release(&bcache.lock);
801001b9:	83 ec 0c             	sub    $0xc,%esp
801001bc:	68 00 d0 18 80       	push   $0x8018d000
801001c1:	e8 be 45 00 00       	call   80104784 <release>
801001c6:	83 c4 10             	add    $0x10,%esp
      acquiresleep(&b->lock);
801001c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001cc:	83 c0 0c             	add    $0xc,%eax
801001cf:	83 ec 0c             	sub    $0xc,%esp
801001d2:	50                   	push   %eax
801001d3:	e8 fb 43 00 00       	call   801045d3 <acquiresleep>
801001d8:	83 c4 10             	add    $0x10,%esp
      return b;
801001db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001de:	eb 1f                	jmp    801001ff <bget+0x10c>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
801001e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001e3:	8b 40 50             	mov    0x50(%eax),%eax
801001e6:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001e9:	81 7d f4 fc 16 19 80 	cmpl   $0x801916fc,-0xc(%ebp)
801001f0:	75 8c                	jne    8010017e <bget+0x8b>
    }
  }
  panic("bget: no buffers");
801001f2:	83 ec 0c             	sub    $0xc,%esp
801001f5:	68 2e a0 10 80       	push   $0x8010a02e
801001fa:	e8 aa 03 00 00       	call   801005a9 <panic>
}
801001ff:	c9                   	leave
80100200:	c3                   	ret

80100201 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100201:	55                   	push   %ebp
80100202:	89 e5                	mov    %esp,%ebp
80100204:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100207:	83 ec 08             	sub    $0x8,%esp
8010020a:	ff 75 0c             	push   0xc(%ebp)
8010020d:	ff 75 08             	push   0x8(%ebp)
80100210:	e8 de fe ff ff       	call   801000f3 <bget>
80100215:	83 c4 10             	add    $0x10,%esp
80100218:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((b->flags & B_VALID) == 0) {
8010021b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010021e:	8b 00                	mov    (%eax),%eax
80100220:	83 e0 02             	and    $0x2,%eax
80100223:	85 c0                	test   %eax,%eax
80100225:	75 0e                	jne    80100235 <bread+0x34>
    iderw(b);
80100227:	83 ec 0c             	sub    $0xc,%esp
8010022a:	ff 75 f4             	push   -0xc(%ebp)
8010022d:	e8 e0 9c 00 00       	call   80109f12 <iderw>
80100232:	83 c4 10             	add    $0x10,%esp
  }
  return b;
80100235:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80100238:	c9                   	leave
80100239:	c3                   	ret

8010023a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010023a:	55                   	push   %ebp
8010023b:	89 e5                	mov    %esp,%ebp
8010023d:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100240:	8b 45 08             	mov    0x8(%ebp),%eax
80100243:	83 c0 0c             	add    $0xc,%eax
80100246:	83 ec 0c             	sub    $0xc,%esp
80100249:	50                   	push   %eax
8010024a:	e8 36 44 00 00       	call   80104685 <holdingsleep>
8010024f:	83 c4 10             	add    $0x10,%esp
80100252:	85 c0                	test   %eax,%eax
80100254:	75 0d                	jne    80100263 <bwrite+0x29>
    panic("bwrite");
80100256:	83 ec 0c             	sub    $0xc,%esp
80100259:	68 3f a0 10 80       	push   $0x8010a03f
8010025e:	e8 46 03 00 00       	call   801005a9 <panic>
  b->flags |= B_DIRTY;
80100263:	8b 45 08             	mov    0x8(%ebp),%eax
80100266:	8b 00                	mov    (%eax),%eax
80100268:	83 c8 04             	or     $0x4,%eax
8010026b:	89 c2                	mov    %eax,%edx
8010026d:	8b 45 08             	mov    0x8(%ebp),%eax
80100270:	89 10                	mov    %edx,(%eax)
  iderw(b);
80100272:	83 ec 0c             	sub    $0xc,%esp
80100275:	ff 75 08             	push   0x8(%ebp)
80100278:	e8 95 9c 00 00       	call   80109f12 <iderw>
8010027d:	83 c4 10             	add    $0x10,%esp
}
80100280:	90                   	nop
80100281:	c9                   	leave
80100282:	c3                   	ret

80100283 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100283:	55                   	push   %ebp
80100284:	89 e5                	mov    %esp,%ebp
80100286:	83 ec 08             	sub    $0x8,%esp
  if(!holdingsleep(&b->lock))
80100289:	8b 45 08             	mov    0x8(%ebp),%eax
8010028c:	83 c0 0c             	add    $0xc,%eax
8010028f:	83 ec 0c             	sub    $0xc,%esp
80100292:	50                   	push   %eax
80100293:	e8 ed 43 00 00       	call   80104685 <holdingsleep>
80100298:	83 c4 10             	add    $0x10,%esp
8010029b:	85 c0                	test   %eax,%eax
8010029d:	75 0d                	jne    801002ac <brelse+0x29>
    panic("brelse");
8010029f:	83 ec 0c             	sub    $0xc,%esp
801002a2:	68 46 a0 10 80       	push   $0x8010a046
801002a7:	e8 fd 02 00 00       	call   801005a9 <panic>

  releasesleep(&b->lock);
801002ac:	8b 45 08             	mov    0x8(%ebp),%eax
801002af:	83 c0 0c             	add    $0xc,%eax
801002b2:	83 ec 0c             	sub    $0xc,%esp
801002b5:	50                   	push   %eax
801002b6:	e8 7c 43 00 00       	call   80104637 <releasesleep>
801002bb:	83 c4 10             	add    $0x10,%esp

  acquire(&bcache.lock);
801002be:	83 ec 0c             	sub    $0xc,%esp
801002c1:	68 00 d0 18 80       	push   $0x8018d000
801002c6:	e8 4b 44 00 00       	call   80104716 <acquire>
801002cb:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
801002ce:	8b 45 08             	mov    0x8(%ebp),%eax
801002d1:	8b 40 4c             	mov    0x4c(%eax),%eax
801002d4:	8d 50 ff             	lea    -0x1(%eax),%edx
801002d7:	8b 45 08             	mov    0x8(%ebp),%eax
801002da:	89 50 4c             	mov    %edx,0x4c(%eax)
  if (b->refcnt == 0) {
801002dd:	8b 45 08             	mov    0x8(%ebp),%eax
801002e0:	8b 40 4c             	mov    0x4c(%eax),%eax
801002e3:	85 c0                	test   %eax,%eax
801002e5:	75 47                	jne    8010032e <brelse+0xab>
    // no one is waiting for it.
    b->next->prev = b->prev;
801002e7:	8b 45 08             	mov    0x8(%ebp),%eax
801002ea:	8b 40 54             	mov    0x54(%eax),%eax
801002ed:	8b 55 08             	mov    0x8(%ebp),%edx
801002f0:	8b 52 50             	mov    0x50(%edx),%edx
801002f3:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
801002f6:	8b 45 08             	mov    0x8(%ebp),%eax
801002f9:	8b 40 50             	mov    0x50(%eax),%eax
801002fc:	8b 55 08             	mov    0x8(%ebp),%edx
801002ff:	8b 52 54             	mov    0x54(%edx),%edx
80100302:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100305:	8b 15 50 17 19 80    	mov    0x80191750,%edx
8010030b:	8b 45 08             	mov    0x8(%ebp),%eax
8010030e:	89 50 54             	mov    %edx,0x54(%eax)
    b->prev = &bcache.head;
80100311:	8b 45 08             	mov    0x8(%ebp),%eax
80100314:	c7 40 50 fc 16 19 80 	movl   $0x801916fc,0x50(%eax)
    bcache.head.next->prev = b;
8010031b:	a1 50 17 19 80       	mov    0x80191750,%eax
80100320:	8b 55 08             	mov    0x8(%ebp),%edx
80100323:	89 50 50             	mov    %edx,0x50(%eax)
    bcache.head.next = b;
80100326:	8b 45 08             	mov    0x8(%ebp),%eax
80100329:	a3 50 17 19 80       	mov    %eax,0x80191750
  }
  
  release(&bcache.lock);
8010032e:	83 ec 0c             	sub    $0xc,%esp
80100331:	68 00 d0 18 80       	push   $0x8018d000
80100336:	e8 49 44 00 00       	call   80104784 <release>
8010033b:	83 c4 10             	add    $0x10,%esp
}
8010033e:	90                   	nop
8010033f:	c9                   	leave
80100340:	c3                   	ret

80100341 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100341:	55                   	push   %ebp
80100342:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100344:	fa                   	cli
}
80100345:	90                   	nop
80100346:	5d                   	pop    %ebp
80100347:	c3                   	ret

80100348 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010034e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100352:	74 1c                	je     80100370 <printint+0x28>
80100354:	8b 45 08             	mov    0x8(%ebp),%eax
80100357:	c1 e8 1f             	shr    $0x1f,%eax
8010035a:	0f b6 c0             	movzbl %al,%eax
8010035d:	89 45 10             	mov    %eax,0x10(%ebp)
80100360:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100364:	74 0a                	je     80100370 <printint+0x28>
    x = -xx;
80100366:	8b 45 08             	mov    0x8(%ebp),%eax
80100369:	f7 d8                	neg    %eax
8010036b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010036e:	eb 06                	jmp    80100376 <printint+0x2e>
  else
    x = xx;
80100370:	8b 45 08             	mov    0x8(%ebp),%eax
80100373:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100376:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010037d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80100380:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100383:	ba 00 00 00 00       	mov    $0x0,%edx
80100388:	f7 f1                	div    %ecx
8010038a:	89 d1                	mov    %edx,%ecx
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	0f b6 91 04 d0 10 80 	movzbl -0x7fef2ffc(%ecx),%edx
8010039c:	88 54 05 e0          	mov    %dl,-0x20(%ebp,%eax,1)
  }while((x /= base) != 0);
801003a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801003a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801003a6:	ba 00 00 00 00       	mov    $0x0,%edx
801003ab:	f7 f1                	div    %ecx
801003ad:	89 45 f0             	mov    %eax,-0x10(%ebp)
801003b0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801003b4:	75 c7                	jne    8010037d <printint+0x35>

  if(sign)
801003b6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801003ba:	74 2a                	je     801003e6 <printint+0x9e>
    buf[i++] = '-';
801003bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003bf:	8d 50 01             	lea    0x1(%eax),%edx
801003c2:	89 55 f4             	mov    %edx,-0xc(%ebp)
801003c5:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
801003ca:	eb 1a                	jmp    801003e6 <printint+0x9e>
    consputc(buf[i]);
801003cc:	8d 55 e0             	lea    -0x20(%ebp),%edx
801003cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003d2:	01 d0                	add    %edx,%eax
801003d4:	0f b6 00             	movzbl (%eax),%eax
801003d7:	0f be c0             	movsbl %al,%eax
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	50                   	push   %eax
801003de:	e8 8b 03 00 00       	call   8010076e <consputc>
801003e3:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
801003e6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ea:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003ee:	79 dc                	jns    801003cc <printint+0x84>
}
801003f0:	90                   	nop
801003f1:	90                   	nop
801003f2:	c9                   	leave
801003f3:	c3                   	ret

801003f4 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003f4:	55                   	push   %ebp
801003f5:	89 e5                	mov    %esp,%ebp
801003f7:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003fa:	a1 34 1a 19 80       	mov    0x80191a34,%eax
801003ff:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
80100402:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100406:	74 10                	je     80100418 <cprintf+0x24>
    acquire(&cons.lock);
80100408:	83 ec 0c             	sub    $0xc,%esp
8010040b:	68 00 1a 19 80       	push   $0x80191a00
80100410:	e8 01 43 00 00       	call   80104716 <acquire>
80100415:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
80100418:	8b 45 08             	mov    0x8(%ebp),%eax
8010041b:	85 c0                	test   %eax,%eax
8010041d:	75 0d                	jne    8010042c <cprintf+0x38>
    panic("null fmt");
8010041f:	83 ec 0c             	sub    $0xc,%esp
80100422:	68 4d a0 10 80       	push   $0x8010a04d
80100427:	e8 7d 01 00 00       	call   801005a9 <panic>


  argp = (uint*)(void*)(&fmt + 1);
8010042c:	8d 45 0c             	lea    0xc(%ebp),%eax
8010042f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100432:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100439:	e9 2f 01 00 00       	jmp    8010056d <cprintf+0x179>
    if(c != '%'){
8010043e:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100442:	74 13                	je     80100457 <cprintf+0x63>
      consputc(c);
80100444:	83 ec 0c             	sub    $0xc,%esp
80100447:	ff 75 e4             	push   -0x1c(%ebp)
8010044a:	e8 1f 03 00 00       	call   8010076e <consputc>
8010044f:	83 c4 10             	add    $0x10,%esp
      continue;
80100452:	e9 12 01 00 00       	jmp    80100569 <cprintf+0x175>
    }
    c = fmt[++i] & 0xff;
80100457:	8b 55 08             	mov    0x8(%ebp),%edx
8010045a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010045e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100461:	01 d0                	add    %edx,%eax
80100463:	0f b6 00             	movzbl (%eax),%eax
80100466:	0f be c0             	movsbl %al,%eax
80100469:	25 ff 00 00 00       	and    $0xff,%eax
8010046e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100471:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100475:	0f 84 14 01 00 00    	je     8010058f <cprintf+0x19b>
      break;
    switch(c){
8010047b:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
8010047f:	74 5e                	je     801004df <cprintf+0xeb>
80100481:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
80100485:	0f 8f c2 00 00 00    	jg     8010054d <cprintf+0x159>
8010048b:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
8010048f:	74 6b                	je     801004fc <cprintf+0x108>
80100491:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
80100495:	0f 8f b2 00 00 00    	jg     8010054d <cprintf+0x159>
8010049b:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
8010049f:	74 3e                	je     801004df <cprintf+0xeb>
801004a1:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
801004a5:	0f 8f a2 00 00 00    	jg     8010054d <cprintf+0x159>
801004ab:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
801004af:	0f 84 89 00 00 00    	je     8010053e <cprintf+0x14a>
801004b5:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
801004b9:	0f 85 8e 00 00 00    	jne    8010054d <cprintf+0x159>
    case 'd':
      printint(*argp++, 10, 1);
801004bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004c2:	8d 50 04             	lea    0x4(%eax),%edx
801004c5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c8:	8b 00                	mov    (%eax),%eax
801004ca:	83 ec 04             	sub    $0x4,%esp
801004cd:	6a 01                	push   $0x1
801004cf:	6a 0a                	push   $0xa
801004d1:	50                   	push   %eax
801004d2:	e8 71 fe ff ff       	call   80100348 <printint>
801004d7:	83 c4 10             	add    $0x10,%esp
      break;
801004da:	e9 8a 00 00 00       	jmp    80100569 <cprintf+0x175>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
801004df:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004e2:	8d 50 04             	lea    0x4(%eax),%edx
801004e5:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004e8:	8b 00                	mov    (%eax),%eax
801004ea:	83 ec 04             	sub    $0x4,%esp
801004ed:	6a 00                	push   $0x0
801004ef:	6a 10                	push   $0x10
801004f1:	50                   	push   %eax
801004f2:	e8 51 fe ff ff       	call   80100348 <printint>
801004f7:	83 c4 10             	add    $0x10,%esp
      break;
801004fa:	eb 6d                	jmp    80100569 <cprintf+0x175>
    case 's':
      if((s = (char*)*argp++) == 0)
801004fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004ff:	8d 50 04             	lea    0x4(%eax),%edx
80100502:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100505:	8b 00                	mov    (%eax),%eax
80100507:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010050a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010050e:	75 22                	jne    80100532 <cprintf+0x13e>
        s = "(null)";
80100510:	c7 45 ec 56 a0 10 80 	movl   $0x8010a056,-0x14(%ebp)
      for(; *s; s++)
80100517:	eb 19                	jmp    80100532 <cprintf+0x13e>
        consputc(*s);
80100519:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010051c:	0f b6 00             	movzbl (%eax),%eax
8010051f:	0f be c0             	movsbl %al,%eax
80100522:	83 ec 0c             	sub    $0xc,%esp
80100525:	50                   	push   %eax
80100526:	e8 43 02 00 00       	call   8010076e <consputc>
8010052b:	83 c4 10             	add    $0x10,%esp
      for(; *s; s++)
8010052e:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100532:	8b 45 ec             	mov    -0x14(%ebp),%eax
80100535:	0f b6 00             	movzbl (%eax),%eax
80100538:	84 c0                	test   %al,%al
8010053a:	75 dd                	jne    80100519 <cprintf+0x125>
      break;
8010053c:	eb 2b                	jmp    80100569 <cprintf+0x175>
    case '%':
      consputc('%');
8010053e:	83 ec 0c             	sub    $0xc,%esp
80100541:	6a 25                	push   $0x25
80100543:	e8 26 02 00 00       	call   8010076e <consputc>
80100548:	83 c4 10             	add    $0x10,%esp
      break;
8010054b:	eb 1c                	jmp    80100569 <cprintf+0x175>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010054d:	83 ec 0c             	sub    $0xc,%esp
80100550:	6a 25                	push   $0x25
80100552:	e8 17 02 00 00       	call   8010076e <consputc>
80100557:	83 c4 10             	add    $0x10,%esp
      consputc(c);
8010055a:	83 ec 0c             	sub    $0xc,%esp
8010055d:	ff 75 e4             	push   -0x1c(%ebp)
80100560:	e8 09 02 00 00       	call   8010076e <consputc>
80100565:	83 c4 10             	add    $0x10,%esp
      break;
80100568:	90                   	nop
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100569:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010056d:	8b 55 08             	mov    0x8(%ebp),%edx
80100570:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100573:	01 d0                	add    %edx,%eax
80100575:	0f b6 00             	movzbl (%eax),%eax
80100578:	0f be c0             	movsbl %al,%eax
8010057b:	25 ff 00 00 00       	and    $0xff,%eax
80100580:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100583:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100587:	0f 85 b1 fe ff ff    	jne    8010043e <cprintf+0x4a>
8010058d:	eb 01                	jmp    80100590 <cprintf+0x19c>
      break;
8010058f:	90                   	nop
    }
  }

  if(locking)
80100590:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100594:	74 10                	je     801005a6 <cprintf+0x1b2>
    release(&cons.lock);
80100596:	83 ec 0c             	sub    $0xc,%esp
80100599:	68 00 1a 19 80       	push   $0x80191a00
8010059e:	e8 e1 41 00 00       	call   80104784 <release>
801005a3:	83 c4 10             	add    $0x10,%esp
}
801005a6:	90                   	nop
801005a7:	c9                   	leave
801005a8:	c3                   	ret

801005a9 <panic>:

void
panic(char *s)
{
801005a9:	55                   	push   %ebp
801005aa:	89 e5                	mov    %esp,%ebp
801005ac:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];

  cli();
801005af:	e8 8d fd ff ff       	call   80100341 <cli>
  cons.locking = 0;
801005b4:	c7 05 34 1a 19 80 00 	movl   $0x0,0x80191a34
801005bb:	00 00 00 
  // use lapiccpunum so that we can call panic from mycpu()
  cprintf("lapicid %d: panic: ", lapicid());
801005be:	e8 39 25 00 00       	call   80102afc <lapicid>
801005c3:	83 ec 08             	sub    $0x8,%esp
801005c6:	50                   	push   %eax
801005c7:	68 5d a0 10 80       	push   $0x8010a05d
801005cc:	e8 23 fe ff ff       	call   801003f4 <cprintf>
801005d1:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
801005d4:	8b 45 08             	mov    0x8(%ebp),%eax
801005d7:	83 ec 0c             	sub    $0xc,%esp
801005da:	50                   	push   %eax
801005db:	e8 14 fe ff ff       	call   801003f4 <cprintf>
801005e0:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005e3:	83 ec 0c             	sub    $0xc,%esp
801005e6:	68 71 a0 10 80       	push   $0x8010a071
801005eb:	e8 04 fe ff ff       	call   801003f4 <cprintf>
801005f0:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005f3:	83 ec 08             	sub    $0x8,%esp
801005f6:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005f9:	50                   	push   %eax
801005fa:	8d 45 08             	lea    0x8(%ebp),%eax
801005fd:	50                   	push   %eax
801005fe:	e8 d3 41 00 00       	call   801047d6 <getcallerpcs>
80100603:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100606:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010060d:	eb 1c                	jmp    8010062b <panic+0x82>
    cprintf(" %p", pcs[i]);
8010060f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100612:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
80100616:	83 ec 08             	sub    $0x8,%esp
80100619:	50                   	push   %eax
8010061a:	68 73 a0 10 80       	push   $0x8010a073
8010061f:	e8 d0 fd ff ff       	call   801003f4 <cprintf>
80100624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
80100627:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010062b:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010062f:	7e de                	jle    8010060f <panic+0x66>
  panicked = 1; // freeze other CPU
80100631:	c7 05 ec 19 19 80 01 	movl   $0x1,0x801919ec
80100638:	00 00 00 
  for(;;)
8010063b:	90                   	nop
8010063c:	eb fd                	jmp    8010063b <panic+0x92>

8010063e <graphic_putc>:

#define CONSOLE_HORIZONTAL_MAX 53
#define CONSOLE_VERTICAL_MAX 20
int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
//int console_pos = 0;
void graphic_putc(int c){
8010063e:	55                   	push   %ebp
8010063f:	89 e5                	mov    %esp,%ebp
80100641:	83 ec 18             	sub    $0x18,%esp
  if(c == '\n'){
80100644:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100648:	75 64                	jne    801006ae <graphic_putc+0x70>
    console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8010064a:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100650:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100655:	89 c8                	mov    %ecx,%eax
80100657:	f7 ea                	imul   %edx
80100659:	89 d0                	mov    %edx,%eax
8010065b:	c1 f8 04             	sar    $0x4,%eax
8010065e:	89 ca                	mov    %ecx,%edx
80100660:	c1 fa 1f             	sar    $0x1f,%edx
80100663:	29 d0                	sub    %edx,%eax
80100665:	6b d0 35             	imul   $0x35,%eax,%edx
80100668:	89 c8                	mov    %ecx,%eax
8010066a:	29 d0                	sub    %edx,%eax
8010066c:	ba 35 00 00 00       	mov    $0x35,%edx
80100671:	29 c2                	sub    %eax,%edx
80100673:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100678:	01 d0                	add    %edx,%eax
8010067a:	a3 00 d0 10 80       	mov    %eax,0x8010d000
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8010067f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100684:	3d 23 04 00 00       	cmp    $0x423,%eax
80100689:	0f 8e dc 00 00 00    	jle    8010076b <graphic_putc+0x12d>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
8010068f:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100694:	83 e8 35             	sub    $0x35,%eax
80100697:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
8010069c:	83 ec 0c             	sub    $0xc,%esp
8010069f:	6a 1e                	push   $0x1e
801006a1:	e8 d9 77 00 00       	call   80107e7f <graphic_scroll_up>
801006a6:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
    font_render(x,y,c);
    console_pos++;
  }
}
801006a9:	e9 bd 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
  }else if(c == BACKSPACE){
801006ae:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
801006b5:	75 1f                	jne    801006d6 <graphic_putc+0x98>
    if(console_pos>0) --console_pos;
801006b7:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006bc:	85 c0                	test   %eax,%eax
801006be:	0f 8e a7 00 00 00    	jle    8010076b <graphic_putc+0x12d>
801006c4:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006c9:	83 e8 01             	sub    $0x1,%eax
801006cc:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
801006d1:	e9 95 00 00 00       	jmp    8010076b <graphic_putc+0x12d>
    if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
801006d6:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006db:	3d 23 04 00 00       	cmp    $0x423,%eax
801006e0:	7e 1a                	jle    801006fc <graphic_putc+0xbe>
      console_pos -= CONSOLE_HORIZONTAL_MAX;
801006e2:	a1 00 d0 10 80       	mov    0x8010d000,%eax
801006e7:	83 e8 35             	sub    $0x35,%eax
801006ea:	a3 00 d0 10 80       	mov    %eax,0x8010d000
      graphic_scroll_up(30);
801006ef:	83 ec 0c             	sub    $0xc,%esp
801006f2:	6a 1e                	push   $0x1e
801006f4:	e8 86 77 00 00       	call   80107e7f <graphic_scroll_up>
801006f9:	83 c4 10             	add    $0x10,%esp
    int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
801006fc:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100702:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100707:	89 c8                	mov    %ecx,%eax
80100709:	f7 ea                	imul   %edx
8010070b:	89 d0                	mov    %edx,%eax
8010070d:	c1 f8 04             	sar    $0x4,%eax
80100710:	89 ca                	mov    %ecx,%edx
80100712:	c1 fa 1f             	sar    $0x1f,%edx
80100715:	29 d0                	sub    %edx,%eax
80100717:	6b d0 35             	imul   $0x35,%eax,%edx
8010071a:	89 c8                	mov    %ecx,%eax
8010071c:	29 d0                	sub    %edx,%eax
8010071e:	89 c2                	mov    %eax,%edx
80100720:	c1 e2 04             	shl    $0x4,%edx
80100723:	29 c2                	sub    %eax,%edx
80100725:	8d 42 02             	lea    0x2(%edx),%eax
80100728:	89 45 f4             	mov    %eax,-0xc(%ebp)
    int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8010072b:	8b 0d 00 d0 10 80    	mov    0x8010d000,%ecx
80100731:	ba ed 73 48 4d       	mov    $0x4d4873ed,%edx
80100736:	89 c8                	mov    %ecx,%eax
80100738:	f7 ea                	imul   %edx
8010073a:	c1 fa 04             	sar    $0x4,%edx
8010073d:	89 c8                	mov    %ecx,%eax
8010073f:	c1 f8 1f             	sar    $0x1f,%eax
80100742:	29 c2                	sub    %eax,%edx
80100744:	6b c2 1e             	imul   $0x1e,%edx,%eax
80100747:	89 45 f0             	mov    %eax,-0x10(%ebp)
    font_render(x,y,c);
8010074a:	83 ec 04             	sub    $0x4,%esp
8010074d:	ff 75 08             	push   0x8(%ebp)
80100750:	ff 75 f0             	push   -0x10(%ebp)
80100753:	ff 75 f4             	push   -0xc(%ebp)
80100756:	e8 91 77 00 00       	call   80107eec <font_render>
8010075b:	83 c4 10             	add    $0x10,%esp
    console_pos++;
8010075e:	a1 00 d0 10 80       	mov    0x8010d000,%eax
80100763:	83 c0 01             	add    $0x1,%eax
80100766:	a3 00 d0 10 80       	mov    %eax,0x8010d000
}
8010076b:	90                   	nop
8010076c:	c9                   	leave
8010076d:	c3                   	ret

8010076e <consputc>:


void
consputc(int c)
{
8010076e:	55                   	push   %ebp
8010076f:	89 e5                	mov    %esp,%ebp
80100771:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
80100774:	a1 ec 19 19 80       	mov    0x801919ec,%eax
80100779:	85 c0                	test   %eax,%eax
8010077b:	74 08                	je     80100785 <consputc+0x17>
    cli();
8010077d:	e8 bf fb ff ff       	call   80100341 <cli>
    for(;;)
80100782:	90                   	nop
80100783:	eb fd                	jmp    80100782 <consputc+0x14>
      ;
  }

  if(c == BACKSPACE){
80100785:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010078c:	75 29                	jne    801007b7 <consputc+0x49>
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010078e:	83 ec 0c             	sub    $0xc,%esp
80100791:	6a 08                	push   $0x8
80100793:	e8 60 5b 00 00       	call   801062f8 <uartputc>
80100798:	83 c4 10             	add    $0x10,%esp
8010079b:	83 ec 0c             	sub    $0xc,%esp
8010079e:	6a 20                	push   $0x20
801007a0:	e8 53 5b 00 00       	call   801062f8 <uartputc>
801007a5:	83 c4 10             	add    $0x10,%esp
801007a8:	83 ec 0c             	sub    $0xc,%esp
801007ab:	6a 08                	push   $0x8
801007ad:	e8 46 5b 00 00       	call   801062f8 <uartputc>
801007b2:	83 c4 10             	add    $0x10,%esp
801007b5:	eb 0e                	jmp    801007c5 <consputc+0x57>
  } else {
    uartputc(c);
801007b7:	83 ec 0c             	sub    $0xc,%esp
801007ba:	ff 75 08             	push   0x8(%ebp)
801007bd:	e8 36 5b 00 00       	call   801062f8 <uartputc>
801007c2:	83 c4 10             	add    $0x10,%esp
  }
  graphic_putc(c);
801007c5:	83 ec 0c             	sub    $0xc,%esp
801007c8:	ff 75 08             	push   0x8(%ebp)
801007cb:	e8 6e fe ff ff       	call   8010063e <graphic_putc>
801007d0:	83 c4 10             	add    $0x10,%esp
}
801007d3:	90                   	nop
801007d4:	c9                   	leave
801007d5:	c3                   	ret

801007d6 <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007d6:	55                   	push   %ebp
801007d7:	89 e5                	mov    %esp,%ebp
801007d9:	83 ec 18             	sub    $0x18,%esp
  int c, doprocdump = 0;
801007dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&cons.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 00 1a 19 80       	push   $0x80191a00
801007eb:	e8 26 3f 00 00       	call   80104716 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 58 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    switch(c){
801007f8:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
801007fc:	0f 84 81 00 00 00    	je     80100883 <consoleintr+0xad>
80100802:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
80100806:	0f 8f ac 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010080c:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100810:	74 43                	je     80100855 <consoleintr+0x7f>
80100812:	83 7d f0 15          	cmpl   $0x15,-0x10(%ebp)
80100816:	0f 8f 9c 00 00 00    	jg     801008b8 <consoleintr+0xe2>
8010081c:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
80100820:	74 61                	je     80100883 <consoleintr+0xad>
80100822:	83 7d f0 10          	cmpl   $0x10,-0x10(%ebp)
80100826:	0f 85 8c 00 00 00    	jne    801008b8 <consoleintr+0xe2>
    case C('P'):  // Process listing.
      // procdump() locks cons.lock indirectly; invoke later
      doprocdump = 1;
8010082c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
      break;
80100833:	e9 18 01 00 00       	jmp    80100950 <consoleintr+0x17a>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100838:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010083d:	83 e8 01             	sub    $0x1,%eax
80100840:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
80100845:	83 ec 0c             	sub    $0xc,%esp
80100848:	68 00 01 00 00       	push   $0x100
8010084d:	e8 1c ff ff ff       	call   8010076e <consputc>
80100852:	83 c4 10             	add    $0x10,%esp
      while(input.e != input.w &&
80100855:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
8010085b:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100860:	39 c2                	cmp    %eax,%edx
80100862:	0f 84 e1 00 00 00    	je     80100949 <consoleintr+0x173>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100868:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010086d:	83 e8 01             	sub    $0x1,%eax
80100870:	83 e0 7f             	and    $0x7f,%eax
80100873:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
      while(input.e != input.w &&
8010087a:	3c 0a                	cmp    $0xa,%al
8010087c:	75 ba                	jne    80100838 <consoleintr+0x62>
      }
      break;
8010087e:	e9 c6 00 00 00       	jmp    80100949 <consoleintr+0x173>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100883:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100889:	a1 e4 19 19 80       	mov    0x801919e4,%eax
8010088e:	39 c2                	cmp    %eax,%edx
80100890:	0f 84 b6 00 00 00    	je     8010094c <consoleintr+0x176>
        input.e--;
80100896:	a1 e8 19 19 80       	mov    0x801919e8,%eax
8010089b:	83 e8 01             	sub    $0x1,%eax
8010089e:	a3 e8 19 19 80       	mov    %eax,0x801919e8
        consputc(BACKSPACE);
801008a3:	83 ec 0c             	sub    $0xc,%esp
801008a6:	68 00 01 00 00       	push   $0x100
801008ab:	e8 be fe ff ff       	call   8010076e <consputc>
801008b0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008b3:	e9 94 00 00 00       	jmp    8010094c <consoleintr+0x176>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801008bc:	0f 84 8d 00 00 00    	je     8010094f <consoleintr+0x179>
801008c2:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
801008c8:	a1 e0 19 19 80       	mov    0x801919e0,%eax
801008cd:	29 c2                	sub    %eax,%edx
801008cf:	83 fa 7f             	cmp    $0x7f,%edx
801008d2:	77 7b                	ja     8010094f <consoleintr+0x179>
        c = (c == '\r') ? '\n' : c;
801008d4:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801008d8:	74 05                	je     801008df <consoleintr+0x109>
801008da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801008dd:	eb 05                	jmp    801008e4 <consoleintr+0x10e>
801008df:	b8 0a 00 00 00       	mov    $0xa,%eax
801008e4:	89 45 f0             	mov    %eax,-0x10(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008e7:	a1 e8 19 19 80       	mov    0x801919e8,%eax
801008ec:	8d 50 01             	lea    0x1(%eax),%edx
801008ef:	89 15 e8 19 19 80    	mov    %edx,0x801919e8
801008f5:	83 e0 7f             	and    $0x7f,%eax
801008f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
801008fb:	88 90 60 19 19 80    	mov    %dl,-0x7fe6e6a0(%eax)
        consputc(c);
80100901:	83 ec 0c             	sub    $0xc,%esp
80100904:	ff 75 f0             	push   -0x10(%ebp)
80100907:	e8 62 fe ff ff       	call   8010076e <consputc>
8010090c:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8010090f:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100913:	74 18                	je     8010092d <consoleintr+0x157>
80100915:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100919:	74 12                	je     8010092d <consoleintr+0x157>
8010091b:	8b 15 e8 19 19 80    	mov    0x801919e8,%edx
80100921:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100926:	83 e8 80             	sub    $0xffffff80,%eax
80100929:	39 c2                	cmp    %eax,%edx
8010092b:	75 22                	jne    8010094f <consoleintr+0x179>
          input.w = input.e;
8010092d:	a1 e8 19 19 80       	mov    0x801919e8,%eax
80100932:	a3 e4 19 19 80       	mov    %eax,0x801919e4
          wakeup(&input.r);
80100937:	83 ec 0c             	sub    $0xc,%esp
8010093a:	68 e0 19 19 80       	push   $0x801919e0
8010093f:	e8 86 3a 00 00       	call   801043ca <wakeup>
80100944:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100947:	eb 06                	jmp    8010094f <consoleintr+0x179>
      break;
80100949:	90                   	nop
8010094a:	eb 04                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094c:	90                   	nop
8010094d:	eb 01                	jmp    80100950 <consoleintr+0x17a>
      break;
8010094f:	90                   	nop
  while((c = getc()) >= 0){
80100950:	8b 45 08             	mov    0x8(%ebp),%eax
80100953:	ff d0                	call   *%eax
80100955:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100958:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010095c:	0f 89 96 fe ff ff    	jns    801007f8 <consoleintr+0x22>
    }
  }
  release(&cons.lock);
80100962:	83 ec 0c             	sub    $0xc,%esp
80100965:	68 00 1a 19 80       	push   $0x80191a00
8010096a:	e8 15 3e 00 00       	call   80104784 <release>
8010096f:	83 c4 10             	add    $0x10,%esp
  if(doprocdump) {
80100972:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100976:	74 05                	je     8010097d <consoleintr+0x1a7>
    procdump();  // now call procdump() wo. cons.lock held
80100978:	e8 08 3b 00 00       	call   80104485 <procdump>
  }
}
8010097d:	90                   	nop
8010097e:	c9                   	leave
8010097f:	c3                   	ret

80100980 <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
80100980:	55                   	push   %ebp
80100981:	89 e5                	mov    %esp,%ebp
80100983:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100986:	83 ec 0c             	sub    $0xc,%esp
80100989:	ff 75 08             	push   0x8(%ebp)
8010098c:	e8 74 11 00 00       	call   80101b05 <iunlock>
80100991:	83 c4 10             	add    $0x10,%esp
  target = n;
80100994:	8b 45 10             	mov    0x10(%ebp),%eax
80100997:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&cons.lock);
8010099a:	83 ec 0c             	sub    $0xc,%esp
8010099d:	68 00 1a 19 80       	push   $0x80191a00
801009a2:	e8 6f 3d 00 00       	call   80104716 <acquire>
801009a7:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
801009aa:	e9 ab 00 00 00       	jmp    80100a5a <consoleread+0xda>
    while(input.r == input.w){
      if(myproc()->killed){
801009af:	e8 7c 30 00 00       	call   80103a30 <myproc>
801009b4:	8b 40 24             	mov    0x24(%eax),%eax
801009b7:	85 c0                	test   %eax,%eax
801009b9:	74 28                	je     801009e3 <consoleread+0x63>
        release(&cons.lock);
801009bb:	83 ec 0c             	sub    $0xc,%esp
801009be:	68 00 1a 19 80       	push   $0x80191a00
801009c3:	e8 bc 3d 00 00       	call   80104784 <release>
801009c8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009cb:	83 ec 0c             	sub    $0xc,%esp
801009ce:	ff 75 08             	push   0x8(%ebp)
801009d1:	e8 1c 10 00 00       	call   801019f2 <ilock>
801009d6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009de:	e9 ab 00 00 00       	jmp    80100a8e <consoleread+0x10e>
      }
      sleep(&input.r, &cons.lock);
801009e3:	83 ec 08             	sub    $0x8,%esp
801009e6:	68 00 1a 19 80       	push   $0x80191a00
801009eb:	68 e0 19 19 80       	push   $0x801919e0
801009f0:	e8 ee 38 00 00       	call   801042e3 <sleep>
801009f5:	83 c4 10             	add    $0x10,%esp
    while(input.r == input.w){
801009f8:	8b 15 e0 19 19 80    	mov    0x801919e0,%edx
801009fe:	a1 e4 19 19 80       	mov    0x801919e4,%eax
80100a03:	39 c2                	cmp    %eax,%edx
80100a05:	74 a8                	je     801009af <consoleread+0x2f>
    }
    c = input.buf[input.r++ % INPUT_BUF];
80100a07:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a0c:	8d 50 01             	lea    0x1(%eax),%edx
80100a0f:	89 15 e0 19 19 80    	mov    %edx,0x801919e0
80100a15:	83 e0 7f             	and    $0x7f,%eax
80100a18:	0f b6 80 60 19 19 80 	movzbl -0x7fe6e6a0(%eax),%eax
80100a1f:	0f be c0             	movsbl %al,%eax
80100a22:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a25:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a29:	75 17                	jne    80100a42 <consoleread+0xc2>
      if(n < target){
80100a2b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a2e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a31:	73 2f                	jae    80100a62 <consoleread+0xe2>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a33:	a1 e0 19 19 80       	mov    0x801919e0,%eax
80100a38:	83 e8 01             	sub    $0x1,%eax
80100a3b:	a3 e0 19 19 80       	mov    %eax,0x801919e0
      }
      break;
80100a40:	eb 20                	jmp    80100a62 <consoleread+0xe2>
    }
    *dst++ = c;
80100a42:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a45:	8d 50 01             	lea    0x1(%eax),%edx
80100a48:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a4e:	88 10                	mov    %dl,(%eax)
    --n;
80100a50:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a54:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a58:	74 0b                	je     80100a65 <consoleread+0xe5>
  while(n > 0){
80100a5a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a5e:	7f 98                	jg     801009f8 <consoleread+0x78>
80100a60:	eb 04                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a62:	90                   	nop
80100a63:	eb 01                	jmp    80100a66 <consoleread+0xe6>
      break;
80100a65:	90                   	nop
  }
  release(&cons.lock);
80100a66:	83 ec 0c             	sub    $0xc,%esp
80100a69:	68 00 1a 19 80       	push   $0x80191a00
80100a6e:	e8 11 3d 00 00       	call   80104784 <release>
80100a73:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	push   0x8(%ebp)
80100a7c:	e8 71 0f 00 00       	call   801019f2 <ilock>
80100a81:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a84:	8b 45 10             	mov    0x10(%ebp),%eax
80100a87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a8a:	29 c2                	sub    %eax,%edx
80100a8c:	89 d0                	mov    %edx,%eax
}
80100a8e:	c9                   	leave
80100a8f:	c3                   	ret

80100a90 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a90:	55                   	push   %ebp
80100a91:	89 e5                	mov    %esp,%ebp
80100a93:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a96:	83 ec 0c             	sub    $0xc,%esp
80100a99:	ff 75 08             	push   0x8(%ebp)
80100a9c:	e8 64 10 00 00       	call   80101b05 <iunlock>
80100aa1:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100aa4:	83 ec 0c             	sub    $0xc,%esp
80100aa7:	68 00 1a 19 80       	push   $0x80191a00
80100aac:	e8 65 3c 00 00       	call   80104716 <acquire>
80100ab1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ab4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100abb:	eb 21                	jmp    80100ade <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100abd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100ac0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100ac3:	01 d0                	add    %edx,%eax
80100ac5:	0f b6 00             	movzbl (%eax),%eax
80100ac8:	0f be c0             	movsbl %al,%eax
80100acb:	0f b6 c0             	movzbl %al,%eax
80100ace:	83 ec 0c             	sub    $0xc,%esp
80100ad1:	50                   	push   %eax
80100ad2:	e8 97 fc ff ff       	call   8010076e <consputc>
80100ad7:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100ada:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ae1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ae4:	7c d7                	jl     80100abd <consolewrite+0x2d>
  release(&cons.lock);
80100ae6:	83 ec 0c             	sub    $0xc,%esp
80100ae9:	68 00 1a 19 80       	push   $0x80191a00
80100aee:	e8 91 3c 00 00       	call   80104784 <release>
80100af3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100af6:	83 ec 0c             	sub    $0xc,%esp
80100af9:	ff 75 08             	push   0x8(%ebp)
80100afc:	e8 f1 0e 00 00       	call   801019f2 <ilock>
80100b01:	83 c4 10             	add    $0x10,%esp

  return n;
80100b04:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100b07:	c9                   	leave
80100b08:	c3                   	ret

80100b09 <consoleinit>:

void
consoleinit(void)
{
80100b09:	55                   	push   %ebp
80100b0a:	89 e5                	mov    %esp,%ebp
80100b0c:	83 ec 18             	sub    $0x18,%esp
  panicked = 0;
80100b0f:	c7 05 ec 19 19 80 00 	movl   $0x0,0x801919ec
80100b16:	00 00 00 
  initlock(&cons.lock, "console");
80100b19:	83 ec 08             	sub    $0x8,%esp
80100b1c:	68 77 a0 10 80       	push   $0x8010a077
80100b21:	68 00 1a 19 80       	push   $0x80191a00
80100b26:	e8 c9 3b 00 00       	call   801046f4 <initlock>
80100b2b:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b2e:	c7 05 4c 1a 19 80 90 	movl   $0x80100a90,0x80191a4c
80100b35:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b38:	c7 05 48 1a 19 80 80 	movl   $0x80100980,0x80191a48
80100b3f:	09 10 80 
  
  char *p;
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b42:	c7 45 f4 7f a0 10 80 	movl   $0x8010a07f,-0xc(%ebp)
80100b49:	eb 19                	jmp    80100b64 <consoleinit+0x5b>
    graphic_putc(*p);
80100b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b4e:	0f b6 00             	movzbl (%eax),%eax
80100b51:	0f be c0             	movsbl %al,%eax
80100b54:	83 ec 0c             	sub    $0xc,%esp
80100b57:	50                   	push   %eax
80100b58:	e8 e1 fa ff ff       	call   8010063e <graphic_putc>
80100b5d:	83 c4 10             	add    $0x10,%esp
  for(p="Starting XV6_UEFI...\n"; *p; p++)
80100b60:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100b67:	0f b6 00             	movzbl (%eax),%eax
80100b6a:	84 c0                	test   %al,%al
80100b6c:	75 dd                	jne    80100b4b <consoleinit+0x42>
  
  cons.locking = 1;
80100b6e:	c7 05 34 1a 19 80 01 	movl   $0x1,0x80191a34
80100b75:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
80100b78:	83 ec 08             	sub    $0x8,%esp
80100b7b:	6a 00                	push   $0x0
80100b7d:	6a 01                	push   $0x1
80100b7f:	e8 b2 1a 00 00       	call   80102636 <ioapicenable>
80100b84:	83 c4 10             	add    $0x10,%esp
}
80100b87:	90                   	nop
80100b88:	c9                   	leave
80100b89:	c3                   	ret

80100b8a <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b8a:	55                   	push   %ebp
80100b8b:	89 e5                	mov    %esp,%ebp
80100b8d:	81 ec 18 01 00 00    	sub    $0x118,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b93:	e8 98 2e 00 00       	call   80103a30 <myproc>
80100b98:	89 45 d0             	mov    %eax,-0x30(%ebp)

  begin_op();
80100b9b:	e8 9e 24 00 00       	call   8010303e <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	push   0x8(%ebp)
80100ba6:	e8 7a 19 00 00       	call   80102525 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100bb1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100bb5:	75 1f                	jne    80100bd6 <exec+0x4c>
    end_op();
80100bb7:	e8 0e 25 00 00       	call   801030ca <end_op>
    cprintf("exec: fail\n");
80100bbc:	83 ec 0c             	sub    $0xc,%esp
80100bbf:	68 95 a0 10 80       	push   $0x8010a095
80100bc4:	e8 2b f8 ff ff       	call   801003f4 <cprintf>
80100bc9:	83 c4 10             	add    $0x10,%esp
    return -1;
80100bcc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100bd1:	e9 f1 03 00 00       	jmp    80100fc7 <exec+0x43d>
  }
  ilock(ip);
80100bd6:	83 ec 0c             	sub    $0xc,%esp
80100bd9:	ff 75 d8             	push   -0x28(%ebp)
80100bdc:	e8 11 0e 00 00       	call   801019f2 <ilock>
80100be1:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100be4:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100beb:	6a 34                	push   $0x34
80100bed:	6a 00                	push   $0x0
80100bef:	8d 85 08 ff ff ff    	lea    -0xf8(%ebp),%eax
80100bf5:	50                   	push   %eax
80100bf6:	ff 75 d8             	push   -0x28(%ebp)
80100bf9:	e8 e0 12 00 00       	call   80101ede <readi>
80100bfe:	83 c4 10             	add    $0x10,%esp
80100c01:	83 f8 34             	cmp    $0x34,%eax
80100c04:	0f 85 66 03 00 00    	jne    80100f70 <exec+0x3e6>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100c0a:	8b 85 08 ff ff ff    	mov    -0xf8(%ebp),%eax
80100c10:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100c15:	0f 85 58 03 00 00    	jne    80100f73 <exec+0x3e9>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100c1b:	e8 d4 66 00 00       	call   801072f4 <setupkvm>
80100c20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100c23:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100c27:	0f 84 49 03 00 00    	je     80100f76 <exec+0x3ec>
    goto bad;

  // Load program into memory.
  sz = 0;
80100c2d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c34:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100c3b:	8b 85 24 ff ff ff    	mov    -0xdc(%ebp),%eax
80100c41:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100c44:	e9 de 00 00 00       	jmp    80100d27 <exec+0x19d>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c49:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c4c:	6a 20                	push   $0x20
80100c4e:	50                   	push   %eax
80100c4f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
80100c55:	50                   	push   %eax
80100c56:	ff 75 d8             	push   -0x28(%ebp)
80100c59:	e8 80 12 00 00       	call   80101ede <readi>
80100c5e:	83 c4 10             	add    $0x10,%esp
80100c61:	83 f8 20             	cmp    $0x20,%eax
80100c64:	0f 85 0f 03 00 00    	jne    80100f79 <exec+0x3ef>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c6a:	8b 85 e8 fe ff ff    	mov    -0x118(%ebp),%eax
80100c70:	83 f8 01             	cmp    $0x1,%eax
80100c73:	0f 85 a0 00 00 00    	jne    80100d19 <exec+0x18f>
      continue;
    if(ph.memsz < ph.filesz)
80100c79:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c7f:	8b 85 f8 fe ff ff    	mov    -0x108(%ebp),%eax
80100c85:	39 c2                	cmp    %eax,%edx
80100c87:	0f 82 ef 02 00 00    	jb     80100f7c <exec+0x3f2>
      goto bad;
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c8d:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100c93:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c99:	01 c2                	add    %eax,%edx
80100c9b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100ca1:	39 c2                	cmp    %eax,%edx
80100ca3:	0f 82 d6 02 00 00    	jb     80100f7f <exec+0x3f5>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100ca9:	8b 95 f0 fe ff ff    	mov    -0x110(%ebp),%edx
80100caf:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100cb5:	01 d0                	add    %edx,%eax
80100cb7:	83 ec 04             	sub    $0x4,%esp
80100cba:	50                   	push   %eax
80100cbb:	ff 75 e0             	push   -0x20(%ebp)
80100cbe:	ff 75 d4             	push   -0x2c(%ebp)
80100cc1:	e8 28 6a 00 00       	call   801076ee <allocuvm>
80100cc6:	83 c4 10             	add    $0x10,%esp
80100cc9:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100ccc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100cd0:	0f 84 ac 02 00 00    	je     80100f82 <exec+0x3f8>
      goto bad;
    if(ph.vaddr % PGSIZE != 0)
80100cd6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100cdc:	25 ff 0f 00 00       	and    $0xfff,%eax
80100ce1:	85 c0                	test   %eax,%eax
80100ce3:	0f 85 9c 02 00 00    	jne    80100f85 <exec+0x3fb>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100ce9:	8b 95 f8 fe ff ff    	mov    -0x108(%ebp),%edx
80100cef:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100cf5:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	52                   	push   %edx
80100cff:	50                   	push   %eax
80100d00:	ff 75 d8             	push   -0x28(%ebp)
80100d03:	51                   	push   %ecx
80100d04:	ff 75 d4             	push   -0x2c(%ebp)
80100d07:	e8 15 69 00 00       	call   80107621 <loaduvm>
80100d0c:	83 c4 20             	add    $0x20,%esp
80100d0f:	85 c0                	test   %eax,%eax
80100d11:	0f 88 71 02 00 00    	js     80100f88 <exec+0x3fe>
80100d17:	eb 01                	jmp    80100d1a <exec+0x190>
      continue;
80100d19:	90                   	nop
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100d1a:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100d1e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100d21:	83 c0 20             	add    $0x20,%eax
80100d24:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d27:	0f b7 85 34 ff ff ff 	movzwl -0xcc(%ebp),%eax
80100d2e:	0f b7 c0             	movzwl %ax,%eax
80100d31:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80100d34:	0f 8c 0f ff ff ff    	jl     80100c49 <exec+0xbf>
      goto bad;
  }
  iunlockput(ip);
80100d3a:	83 ec 0c             	sub    $0xc,%esp
80100d3d:	ff 75 d8             	push   -0x28(%ebp)
80100d40:	e8 de 0e 00 00       	call   80101c23 <iunlockput>
80100d45:	83 c4 10             	add    $0x10,%esp
  end_op();
80100d48:	e8 7d 23 00 00       	call   801030ca <end_op>
  ip = 0;
80100d4d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100d54:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d57:	05 ff 0f 00 00       	add    $0xfff,%eax
80100d5c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100d61:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d64:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d67:	05 00 20 00 00       	add    $0x2000,%eax
80100d6c:	83 ec 04             	sub    $0x4,%esp
80100d6f:	50                   	push   %eax
80100d70:	ff 75 e0             	push   -0x20(%ebp)
80100d73:	ff 75 d4             	push   -0x2c(%ebp)
80100d76:	e8 73 69 00 00       	call   801076ee <allocuvm>
80100d7b:	83 c4 10             	add    $0x10,%esp
80100d7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d81:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d85:	0f 84 00 02 00 00    	je     80100f8b <exec+0x401>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d8e:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d93:	83 ec 08             	sub    $0x8,%esp
80100d96:	50                   	push   %eax
80100d97:	ff 75 d4             	push   -0x2c(%ebp)
80100d9a:	e8 b1 6b 00 00       	call   80107950 <clearpteu>
80100d9f:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100da2:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100da5:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100da8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100daf:	e9 96 00 00 00       	jmp    80100e4a <exec+0x2c0>
    if(argc >= MAXARG)
80100db4:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100db8:	0f 87 d0 01 00 00    	ja     80100f8e <exec+0x404>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100dbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dc1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dcb:	01 d0                	add    %edx,%eax
80100dcd:	8b 00                	mov    (%eax),%eax
80100dcf:	83 ec 0c             	sub    $0xc,%esp
80100dd2:	50                   	push   %eax
80100dd3:	e8 02 3e 00 00       	call   80104bda <strlen>
80100dd8:	83 c4 10             	add    $0x10,%esp
80100ddb:	89 c2                	mov    %eax,%edx
80100ddd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100de0:	29 d0                	sub    %edx,%eax
80100de2:	83 e8 01             	sub    $0x1,%eax
80100de5:	83 e0 fc             	and    $0xfffffffc,%eax
80100de8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100deb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dee:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100df5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100df8:	01 d0                	add    %edx,%eax
80100dfa:	8b 00                	mov    (%eax),%eax
80100dfc:	83 ec 0c             	sub    $0xc,%esp
80100dff:	50                   	push   %eax
80100e00:	e8 d5 3d 00 00       	call   80104bda <strlen>
80100e05:	83 c4 10             	add    $0x10,%esp
80100e08:	83 c0 01             	add    $0x1,%eax
80100e0b:	89 c1                	mov    %eax,%ecx
80100e0d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e10:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e17:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e1a:	01 d0                	add    %edx,%eax
80100e1c:	8b 00                	mov    (%eax),%eax
80100e1e:	51                   	push   %ecx
80100e1f:	50                   	push   %eax
80100e20:	ff 75 dc             	push   -0x24(%ebp)
80100e23:	ff 75 d4             	push   -0x2c(%ebp)
80100e26:	e8 c4 6c 00 00       	call   80107aef <copyout>
80100e2b:	83 c4 10             	add    $0x10,%esp
80100e2e:	85 c0                	test   %eax,%eax
80100e30:	0f 88 5b 01 00 00    	js     80100f91 <exec+0x407>
      goto bad;
    ustack[3+argc] = sp;
80100e36:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e39:	8d 50 03             	lea    0x3(%eax),%edx
80100e3c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e3f:	89 84 95 3c ff ff ff 	mov    %eax,-0xc4(%ebp,%edx,4)
  for(argc = 0; argv[argc]; argc++) {
80100e46:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100e4a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e4d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e54:	8b 45 0c             	mov    0xc(%ebp),%eax
80100e57:	01 d0                	add    %edx,%eax
80100e59:	8b 00                	mov    (%eax),%eax
80100e5b:	85 c0                	test   %eax,%eax
80100e5d:	0f 85 51 ff ff ff    	jne    80100db4 <exec+0x22a>
  }
  ustack[3+argc] = 0;
80100e63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e66:	83 c0 03             	add    $0x3,%eax
80100e69:	c7 84 85 3c ff ff ff 	movl   $0x0,-0xc4(%ebp,%eax,4)
80100e70:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100e74:	c7 85 3c ff ff ff ff 	movl   $0xffffffff,-0xc4(%ebp)
80100e7b:	ff ff ff 
  ustack[1] = argc;
80100e7e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e81:	89 85 40 ff ff ff    	mov    %eax,-0xc0(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e87:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e8a:	83 c0 01             	add    $0x1,%eax
80100e8d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e94:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e97:	29 d0                	sub    %edx,%eax
80100e99:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)

  sp -= (3+argc+1) * 4;
80100e9f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100ea2:	83 c0 04             	add    $0x4,%eax
80100ea5:	c1 e0 02             	shl    $0x2,%eax
80100ea8:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100eab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100eae:	83 c0 04             	add    $0x4,%eax
80100eb1:	c1 e0 02             	shl    $0x2,%eax
80100eb4:	50                   	push   %eax
80100eb5:	8d 85 3c ff ff ff    	lea    -0xc4(%ebp),%eax
80100ebb:	50                   	push   %eax
80100ebc:	ff 75 dc             	push   -0x24(%ebp)
80100ebf:	ff 75 d4             	push   -0x2c(%ebp)
80100ec2:	e8 28 6c 00 00       	call   80107aef <copyout>
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	0f 88 c2 00 00 00    	js     80100f94 <exec+0x40a>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100ed2:	8b 45 08             	mov    0x8(%ebp),%eax
80100ed5:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100ed8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100edb:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100ede:	eb 17                	jmp    80100ef7 <exec+0x36d>
    if(*s == '/')
80100ee0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ee3:	0f b6 00             	movzbl (%eax),%eax
80100ee6:	3c 2f                	cmp    $0x2f,%al
80100ee8:	75 09                	jne    80100ef3 <exec+0x369>
      last = s+1;
80100eea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100eed:	83 c0 01             	add    $0x1,%eax
80100ef0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(last=s=path; *s; s++)
80100ef3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100ef7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100efa:	0f b6 00             	movzbl (%eax),%eax
80100efd:	84 c0                	test   %al,%al
80100eff:	75 df                	jne    80100ee0 <exec+0x356>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f04:	83 c0 6c             	add    $0x6c,%eax
80100f07:	83 ec 04             	sub    $0x4,%esp
80100f0a:	6a 10                	push   $0x10
80100f0c:	ff 75 f0             	push   -0x10(%ebp)
80100f0f:	50                   	push   %eax
80100f10:	e8 7a 3c 00 00       	call   80104b8f <safestrcpy>
80100f15:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = curproc->pgdir;
80100f18:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f1b:	8b 40 04             	mov    0x4(%eax),%eax
80100f1e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  curproc->pgdir = pgdir;
80100f21:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f24:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100f27:	89 50 04             	mov    %edx,0x4(%eax)
  curproc->sz = sz;
80100f2a:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f2d:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100f30:	89 10                	mov    %edx,(%eax)
  curproc->tf->eip = elf.entry;  // main
80100f32:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f35:	8b 40 18             	mov    0x18(%eax),%eax
80100f38:	8b 95 20 ff ff ff    	mov    -0xe0(%ebp),%edx
80100f3e:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100f41:	8b 45 d0             	mov    -0x30(%ebp),%eax
80100f44:	8b 40 18             	mov    0x18(%eax),%eax
80100f47:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100f4a:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(curproc);
80100f4d:	83 ec 0c             	sub    $0xc,%esp
80100f50:	ff 75 d0             	push   -0x30(%ebp)
80100f53:	e8 ba 64 00 00       	call   80107412 <switchuvm>
80100f58:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100f5b:	83 ec 0c             	sub    $0xc,%esp
80100f5e:	ff 75 cc             	push   -0x34(%ebp)
80100f61:	e8 51 69 00 00       	call   801078b7 <freevm>
80100f66:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f69:	b8 00 00 00 00       	mov    $0x0,%eax
80100f6e:	eb 57                	jmp    80100fc7 <exec+0x43d>
    goto bad;
80100f70:	90                   	nop
80100f71:	eb 22                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f73:	90                   	nop
80100f74:	eb 1f                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f76:	90                   	nop
80100f77:	eb 1c                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f79:	90                   	nop
80100f7a:	eb 19                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7c:	90                   	nop
80100f7d:	eb 16                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f7f:	90                   	nop
80100f80:	eb 13                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f82:	90                   	nop
80100f83:	eb 10                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f85:	90                   	nop
80100f86:	eb 0d                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f88:	90                   	nop
80100f89:	eb 0a                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f8b:	90                   	nop
80100f8c:	eb 07                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f8e:	90                   	nop
80100f8f:	eb 04                	jmp    80100f95 <exec+0x40b>
      goto bad;
80100f91:	90                   	nop
80100f92:	eb 01                	jmp    80100f95 <exec+0x40b>
    goto bad;
80100f94:	90                   	nop

 bad:
  if(pgdir)
80100f95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f99:	74 0e                	je     80100fa9 <exec+0x41f>
    freevm(pgdir);
80100f9b:	83 ec 0c             	sub    $0xc,%esp
80100f9e:	ff 75 d4             	push   -0x2c(%ebp)
80100fa1:	e8 11 69 00 00       	call   801078b7 <freevm>
80100fa6:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100fa9:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100fad:	74 13                	je     80100fc2 <exec+0x438>
    iunlockput(ip);
80100faf:	83 ec 0c             	sub    $0xc,%esp
80100fb2:	ff 75 d8             	push   -0x28(%ebp)
80100fb5:	e8 69 0c 00 00       	call   80101c23 <iunlockput>
80100fba:	83 c4 10             	add    $0x10,%esp
    end_op();
80100fbd:	e8 08 21 00 00       	call   801030ca <end_op>
  }
  return -1;
80100fc2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100fc7:	c9                   	leave
80100fc8:	c3                   	ret

80100fc9 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100fc9:	55                   	push   %ebp
80100fca:	89 e5                	mov    %esp,%ebp
80100fcc:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100fcf:	83 ec 08             	sub    $0x8,%esp
80100fd2:	68 a1 a0 10 80       	push   $0x8010a0a1
80100fd7:	68 a0 1a 19 80       	push   $0x80191aa0
80100fdc:	e8 13 37 00 00       	call   801046f4 <initlock>
80100fe1:	83 c4 10             	add    $0x10,%esp
}
80100fe4:	90                   	nop
80100fe5:	c9                   	leave
80100fe6:	c3                   	ret

80100fe7 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100fe7:	55                   	push   %ebp
80100fe8:	89 e5                	mov    %esp,%ebp
80100fea:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100fed:	83 ec 0c             	sub    $0xc,%esp
80100ff0:	68 a0 1a 19 80       	push   $0x80191aa0
80100ff5:	e8 1c 37 00 00       	call   80104716 <acquire>
80100ffa:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100ffd:	c7 45 f4 d4 1a 19 80 	movl   $0x80191ad4,-0xc(%ebp)
80101004:	eb 2d                	jmp    80101033 <filealloc+0x4c>
    if(f->ref == 0){
80101006:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101009:	8b 40 04             	mov    0x4(%eax),%eax
8010100c:	85 c0                	test   %eax,%eax
8010100e:	75 1f                	jne    8010102f <filealloc+0x48>
      f->ref = 1;
80101010:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101013:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
8010101a:	83 ec 0c             	sub    $0xc,%esp
8010101d:	68 a0 1a 19 80       	push   $0x80191aa0
80101022:	e8 5d 37 00 00       	call   80104784 <release>
80101027:	83 c4 10             	add    $0x10,%esp
      return f;
8010102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010102d:	eb 23                	jmp    80101052 <filealloc+0x6b>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
8010102f:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80101033:	b8 34 24 19 80       	mov    $0x80192434,%eax
80101038:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010103b:	72 c9                	jb     80101006 <filealloc+0x1f>
    }
  }
  release(&ftable.lock);
8010103d:	83 ec 0c             	sub    $0xc,%esp
80101040:	68 a0 1a 19 80       	push   $0x80191aa0
80101045:	e8 3a 37 00 00       	call   80104784 <release>
8010104a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010104d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101052:	c9                   	leave
80101053:	c3                   	ret

80101054 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80101054:	55                   	push   %ebp
80101055:	89 e5                	mov    %esp,%ebp
80101057:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
8010105a:	83 ec 0c             	sub    $0xc,%esp
8010105d:	68 a0 1a 19 80       	push   $0x80191aa0
80101062:	e8 af 36 00 00       	call   80104716 <acquire>
80101067:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010106a:	8b 45 08             	mov    0x8(%ebp),%eax
8010106d:	8b 40 04             	mov    0x4(%eax),%eax
80101070:	85 c0                	test   %eax,%eax
80101072:	7f 0d                	jg     80101081 <filedup+0x2d>
    panic("filedup");
80101074:	83 ec 0c             	sub    $0xc,%esp
80101077:	68 a8 a0 10 80       	push   $0x8010a0a8
8010107c:	e8 28 f5 ff ff       	call   801005a9 <panic>
  f->ref++;
80101081:	8b 45 08             	mov    0x8(%ebp),%eax
80101084:	8b 40 04             	mov    0x4(%eax),%eax
80101087:	8d 50 01             	lea    0x1(%eax),%edx
8010108a:	8b 45 08             	mov    0x8(%ebp),%eax
8010108d:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101090:	83 ec 0c             	sub    $0xc,%esp
80101093:	68 a0 1a 19 80       	push   $0x80191aa0
80101098:	e8 e7 36 00 00       	call   80104784 <release>
8010109d:	83 c4 10             	add    $0x10,%esp
  return f;
801010a0:	8b 45 08             	mov    0x8(%ebp),%eax
}
801010a3:	c9                   	leave
801010a4:	c3                   	ret

801010a5 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
801010a5:	55                   	push   %ebp
801010a6:	89 e5                	mov    %esp,%ebp
801010a8:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
801010ab:	83 ec 0c             	sub    $0xc,%esp
801010ae:	68 a0 1a 19 80       	push   $0x80191aa0
801010b3:	e8 5e 36 00 00       	call   80104716 <acquire>
801010b8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
801010bb:	8b 45 08             	mov    0x8(%ebp),%eax
801010be:	8b 40 04             	mov    0x4(%eax),%eax
801010c1:	85 c0                	test   %eax,%eax
801010c3:	7f 0d                	jg     801010d2 <fileclose+0x2d>
    panic("fileclose");
801010c5:	83 ec 0c             	sub    $0xc,%esp
801010c8:	68 b0 a0 10 80       	push   $0x8010a0b0
801010cd:	e8 d7 f4 ff ff       	call   801005a9 <panic>
  if(--f->ref > 0){
801010d2:	8b 45 08             	mov    0x8(%ebp),%eax
801010d5:	8b 40 04             	mov    0x4(%eax),%eax
801010d8:	8d 50 ff             	lea    -0x1(%eax),%edx
801010db:	8b 45 08             	mov    0x8(%ebp),%eax
801010de:	89 50 04             	mov    %edx,0x4(%eax)
801010e1:	8b 45 08             	mov    0x8(%ebp),%eax
801010e4:	8b 40 04             	mov    0x4(%eax),%eax
801010e7:	85 c0                	test   %eax,%eax
801010e9:	7e 15                	jle    80101100 <fileclose+0x5b>
    release(&ftable.lock);
801010eb:	83 ec 0c             	sub    $0xc,%esp
801010ee:	68 a0 1a 19 80       	push   $0x80191aa0
801010f3:	e8 8c 36 00 00       	call   80104784 <release>
801010f8:	83 c4 10             	add    $0x10,%esp
801010fb:	e9 8b 00 00 00       	jmp    8010118b <fileclose+0xe6>
    return;
  }
  ff = *f;
80101100:	8b 45 08             	mov    0x8(%ebp),%eax
80101103:	8b 10                	mov    (%eax),%edx
80101105:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101108:	8b 50 04             	mov    0x4(%eax),%edx
8010110b:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010110e:	8b 50 08             	mov    0x8(%eax),%edx
80101111:	89 55 e8             	mov    %edx,-0x18(%ebp)
80101114:	8b 50 0c             	mov    0xc(%eax),%edx
80101117:	89 55 ec             	mov    %edx,-0x14(%ebp)
8010111a:	8b 50 10             	mov    0x10(%eax),%edx
8010111d:	89 55 f0             	mov    %edx,-0x10(%ebp)
80101120:	8b 40 14             	mov    0x14(%eax),%eax
80101123:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
80101126:	8b 45 08             	mov    0x8(%ebp),%eax
80101129:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
80101130:	8b 45 08             	mov    0x8(%ebp),%eax
80101133:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	68 a0 1a 19 80       	push   $0x80191aa0
80101141:	e8 3e 36 00 00       	call   80104784 <release>
80101146:	83 c4 10             	add    $0x10,%esp

  if(ff.type == FD_PIPE)
80101149:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010114c:	83 f8 01             	cmp    $0x1,%eax
8010114f:	75 19                	jne    8010116a <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
80101151:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
80101155:	0f be d0             	movsbl %al,%edx
80101158:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010115b:	83 ec 08             	sub    $0x8,%esp
8010115e:	52                   	push   %edx
8010115f:	50                   	push   %eax
80101160:	e8 5a 25 00 00       	call   801036bf <pipeclose>
80101165:	83 c4 10             	add    $0x10,%esp
80101168:	eb 21                	jmp    8010118b <fileclose+0xe6>
  else if(ff.type == FD_INODE){
8010116a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010116d:	83 f8 02             	cmp    $0x2,%eax
80101170:	75 19                	jne    8010118b <fileclose+0xe6>
    begin_op();
80101172:	e8 c7 1e 00 00       	call   8010303e <begin_op>
    iput(ff.ip);
80101177:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	50                   	push   %eax
8010117e:	e8 d0 09 00 00       	call   80101b53 <iput>
80101183:	83 c4 10             	add    $0x10,%esp
    end_op();
80101186:	e8 3f 1f 00 00       	call   801030ca <end_op>
  }
}
8010118b:	c9                   	leave
8010118c:	c3                   	ret

8010118d <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010118d:	55                   	push   %ebp
8010118e:	89 e5                	mov    %esp,%ebp
80101190:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101193:	8b 45 08             	mov    0x8(%ebp),%eax
80101196:	8b 00                	mov    (%eax),%eax
80101198:	83 f8 02             	cmp    $0x2,%eax
8010119b:	75 40                	jne    801011dd <filestat+0x50>
    ilock(f->ip);
8010119d:	8b 45 08             	mov    0x8(%ebp),%eax
801011a0:	8b 40 10             	mov    0x10(%eax),%eax
801011a3:	83 ec 0c             	sub    $0xc,%esp
801011a6:	50                   	push   %eax
801011a7:	e8 46 08 00 00       	call   801019f2 <ilock>
801011ac:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
801011af:	8b 45 08             	mov    0x8(%ebp),%eax
801011b2:	8b 40 10             	mov    0x10(%eax),%eax
801011b5:	83 ec 08             	sub    $0x8,%esp
801011b8:	ff 75 0c             	push   0xc(%ebp)
801011bb:	50                   	push   %eax
801011bc:	e8 d7 0c 00 00       	call   80101e98 <stati>
801011c1:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
801011c4:	8b 45 08             	mov    0x8(%ebp),%eax
801011c7:	8b 40 10             	mov    0x10(%eax),%eax
801011ca:	83 ec 0c             	sub    $0xc,%esp
801011cd:	50                   	push   %eax
801011ce:	e8 32 09 00 00       	call   80101b05 <iunlock>
801011d3:	83 c4 10             	add    $0x10,%esp
    return 0;
801011d6:	b8 00 00 00 00       	mov    $0x0,%eax
801011db:	eb 05                	jmp    801011e2 <filestat+0x55>
  }
  return -1;
801011dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801011e2:	c9                   	leave
801011e3:	c3                   	ret

801011e4 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801011e4:	55                   	push   %ebp
801011e5:	89 e5                	mov    %esp,%ebp
801011e7:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
801011ea:	8b 45 08             	mov    0x8(%ebp),%eax
801011ed:	0f b6 40 08          	movzbl 0x8(%eax),%eax
801011f1:	84 c0                	test   %al,%al
801011f3:	75 0a                	jne    801011ff <fileread+0x1b>
    return -1;
801011f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801011fa:	e9 9b 00 00 00       	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_PIPE)
801011ff:	8b 45 08             	mov    0x8(%ebp),%eax
80101202:	8b 00                	mov    (%eax),%eax
80101204:	83 f8 01             	cmp    $0x1,%eax
80101207:	75 1a                	jne    80101223 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
80101209:	8b 45 08             	mov    0x8(%ebp),%eax
8010120c:	8b 40 0c             	mov    0xc(%eax),%eax
8010120f:	83 ec 04             	sub    $0x4,%esp
80101212:	ff 75 10             	push   0x10(%ebp)
80101215:	ff 75 0c             	push   0xc(%ebp)
80101218:	50                   	push   %eax
80101219:	e8 4e 26 00 00       	call   8010386c <piperead>
8010121e:	83 c4 10             	add    $0x10,%esp
80101221:	eb 77                	jmp    8010129a <fileread+0xb6>
  if(f->type == FD_INODE){
80101223:	8b 45 08             	mov    0x8(%ebp),%eax
80101226:	8b 00                	mov    (%eax),%eax
80101228:	83 f8 02             	cmp    $0x2,%eax
8010122b:	75 60                	jne    8010128d <fileread+0xa9>
    ilock(f->ip);
8010122d:	8b 45 08             	mov    0x8(%ebp),%eax
80101230:	8b 40 10             	mov    0x10(%eax),%eax
80101233:	83 ec 0c             	sub    $0xc,%esp
80101236:	50                   	push   %eax
80101237:	e8 b6 07 00 00       	call   801019f2 <ilock>
8010123c:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010123f:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101242:	8b 45 08             	mov    0x8(%ebp),%eax
80101245:	8b 50 14             	mov    0x14(%eax),%edx
80101248:	8b 45 08             	mov    0x8(%ebp),%eax
8010124b:	8b 40 10             	mov    0x10(%eax),%eax
8010124e:	51                   	push   %ecx
8010124f:	52                   	push   %edx
80101250:	ff 75 0c             	push   0xc(%ebp)
80101253:	50                   	push   %eax
80101254:	e8 85 0c 00 00       	call   80101ede <readi>
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010125f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101263:	7e 11                	jle    80101276 <fileread+0x92>
      f->off += r;
80101265:	8b 45 08             	mov    0x8(%ebp),%eax
80101268:	8b 50 14             	mov    0x14(%eax),%edx
8010126b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010126e:	01 c2                	add    %eax,%edx
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101276:	8b 45 08             	mov    0x8(%ebp),%eax
80101279:	8b 40 10             	mov    0x10(%eax),%eax
8010127c:	83 ec 0c             	sub    $0xc,%esp
8010127f:	50                   	push   %eax
80101280:	e8 80 08 00 00       	call   80101b05 <iunlock>
80101285:	83 c4 10             	add    $0x10,%esp
    return r;
80101288:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010128b:	eb 0d                	jmp    8010129a <fileread+0xb6>
  }
  panic("fileread");
8010128d:	83 ec 0c             	sub    $0xc,%esp
80101290:	68 ba a0 10 80       	push   $0x8010a0ba
80101295:	e8 0f f3 ff ff       	call   801005a9 <panic>
}
8010129a:	c9                   	leave
8010129b:	c3                   	ret

8010129c <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010129c:	55                   	push   %ebp
8010129d:	89 e5                	mov    %esp,%ebp
8010129f:	53                   	push   %ebx
801012a0:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
801012a3:	8b 45 08             	mov    0x8(%ebp),%eax
801012a6:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801012aa:	84 c0                	test   %al,%al
801012ac:	75 0a                	jne    801012b8 <filewrite+0x1c>
    return -1;
801012ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801012b3:	e9 1b 01 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_PIPE)
801012b8:	8b 45 08             	mov    0x8(%ebp),%eax
801012bb:	8b 00                	mov    (%eax),%eax
801012bd:	83 f8 01             	cmp    $0x1,%eax
801012c0:	75 1d                	jne    801012df <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 40 0c             	mov    0xc(%eax),%eax
801012c8:	83 ec 04             	sub    $0x4,%esp
801012cb:	ff 75 10             	push   0x10(%ebp)
801012ce:	ff 75 0c             	push   0xc(%ebp)
801012d1:	50                   	push   %eax
801012d2:	e8 93 24 00 00       	call   8010376a <pipewrite>
801012d7:	83 c4 10             	add    $0x10,%esp
801012da:	e9 f4 00 00 00       	jmp    801013d3 <filewrite+0x137>
  if(f->type == FD_INODE){
801012df:	8b 45 08             	mov    0x8(%ebp),%eax
801012e2:	8b 00                	mov    (%eax),%eax
801012e4:	83 f8 02             	cmp    $0x2,%eax
801012e7:	0f 85 d9 00 00 00    	jne    801013c6 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
801012ed:	c7 45 ec 00 06 00 00 	movl   $0x600,-0x14(%ebp)
    int i = 0;
801012f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
801012fb:	e9 a3 00 00 00       	jmp    801013a3 <filewrite+0x107>
      int n1 = n - i;
80101300:	8b 45 10             	mov    0x10(%ebp),%eax
80101303:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101306:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
80101309:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010130c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
8010130f:	7e 06                	jle    80101317 <filewrite+0x7b>
        n1 = max;
80101311:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101314:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
80101317:	e8 22 1d 00 00       	call   8010303e <begin_op>
      ilock(f->ip);
8010131c:	8b 45 08             	mov    0x8(%ebp),%eax
8010131f:	8b 40 10             	mov    0x10(%eax),%eax
80101322:	83 ec 0c             	sub    $0xc,%esp
80101325:	50                   	push   %eax
80101326:	e8 c7 06 00 00       	call   801019f2 <ilock>
8010132b:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010132e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80101331:	8b 45 08             	mov    0x8(%ebp),%eax
80101334:	8b 50 14             	mov    0x14(%eax),%edx
80101337:	8b 5d f4             	mov    -0xc(%ebp),%ebx
8010133a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010133d:	01 c3                	add    %eax,%ebx
8010133f:	8b 45 08             	mov    0x8(%ebp),%eax
80101342:	8b 40 10             	mov    0x10(%eax),%eax
80101345:	51                   	push   %ecx
80101346:	52                   	push   %edx
80101347:	53                   	push   %ebx
80101348:	50                   	push   %eax
80101349:	e8 e5 0c 00 00       	call   80102033 <writei>
8010134e:	83 c4 10             	add    $0x10,%esp
80101351:	89 45 e8             	mov    %eax,-0x18(%ebp)
80101354:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101358:	7e 11                	jle    8010136b <filewrite+0xcf>
        f->off += r;
8010135a:	8b 45 08             	mov    0x8(%ebp),%eax
8010135d:	8b 50 14             	mov    0x14(%eax),%edx
80101360:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101363:	01 c2                	add    %eax,%edx
80101365:	8b 45 08             	mov    0x8(%ebp),%eax
80101368:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
8010136b:	8b 45 08             	mov    0x8(%ebp),%eax
8010136e:	8b 40 10             	mov    0x10(%eax),%eax
80101371:	83 ec 0c             	sub    $0xc,%esp
80101374:	50                   	push   %eax
80101375:	e8 8b 07 00 00       	call   80101b05 <iunlock>
8010137a:	83 c4 10             	add    $0x10,%esp
      end_op();
8010137d:	e8 48 1d 00 00       	call   801030ca <end_op>

      if(r < 0)
80101382:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101386:	78 29                	js     801013b1 <filewrite+0x115>
        break;
      if(r != n1)
80101388:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010138b:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010138e:	74 0d                	je     8010139d <filewrite+0x101>
        panic("short filewrite");
80101390:	83 ec 0c             	sub    $0xc,%esp
80101393:	68 c3 a0 10 80       	push   $0x8010a0c3
80101398:	e8 0c f2 ff ff       	call   801005a9 <panic>
      i += r;
8010139d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801013a0:	01 45 f4             	add    %eax,-0xc(%ebp)
    while(i < n){
801013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013a6:	3b 45 10             	cmp    0x10(%ebp),%eax
801013a9:	0f 8c 51 ff ff ff    	jl     80101300 <filewrite+0x64>
801013af:	eb 01                	jmp    801013b2 <filewrite+0x116>
        break;
801013b1:	90                   	nop
    }
    return i == n ? n : -1;
801013b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801013b8:	75 05                	jne    801013bf <filewrite+0x123>
801013ba:	8b 45 10             	mov    0x10(%ebp),%eax
801013bd:	eb 14                	jmp    801013d3 <filewrite+0x137>
801013bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801013c4:	eb 0d                	jmp    801013d3 <filewrite+0x137>
  }
  panic("filewrite");
801013c6:	83 ec 0c             	sub    $0xc,%esp
801013c9:	68 d3 a0 10 80       	push   $0x8010a0d3
801013ce:	e8 d6 f1 ff ff       	call   801005a9 <panic>
}
801013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801013d6:	c9                   	leave
801013d7:	c3                   	ret

801013d8 <readsb>:
struct superblock sb; 

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
801013d8:	55                   	push   %ebp
801013d9:	89 e5                	mov    %esp,%ebp
801013db:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, 1);
801013de:	8b 45 08             	mov    0x8(%ebp),%eax
801013e1:	83 ec 08             	sub    $0x8,%esp
801013e4:	6a 01                	push   $0x1
801013e6:	50                   	push   %eax
801013e7:	e8 15 ee ff ff       	call   80100201 <bread>
801013ec:	83 c4 10             	add    $0x10,%esp
801013ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
801013f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013f5:	83 c0 5c             	add    $0x5c,%eax
801013f8:	83 ec 04             	sub    $0x4,%esp
801013fb:	6a 1c                	push   $0x1c
801013fd:	50                   	push   %eax
801013fe:	ff 75 0c             	push   0xc(%ebp)
80101401:	e8 45 36 00 00       	call   80104a4b <memmove>
80101406:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101409:	83 ec 0c             	sub    $0xc,%esp
8010140c:	ff 75 f4             	push   -0xc(%ebp)
8010140f:	e8 6f ee ff ff       	call   80100283 <brelse>
80101414:	83 c4 10             	add    $0x10,%esp
}
80101417:	90                   	nop
80101418:	c9                   	leave
80101419:	c3                   	ret

8010141a <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
8010141a:	55                   	push   %ebp
8010141b:	89 e5                	mov    %esp,%ebp
8010141d:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;

  bp = bread(dev, bno);
80101420:	8b 55 0c             	mov    0xc(%ebp),%edx
80101423:	8b 45 08             	mov    0x8(%ebp),%eax
80101426:	83 ec 08             	sub    $0x8,%esp
80101429:	52                   	push   %edx
8010142a:	50                   	push   %eax
8010142b:	e8 d1 ed ff ff       	call   80100201 <bread>
80101430:	83 c4 10             	add    $0x10,%esp
80101433:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
80101436:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101439:	83 c0 5c             	add    $0x5c,%eax
8010143c:	83 ec 04             	sub    $0x4,%esp
8010143f:	68 00 02 00 00       	push   $0x200
80101444:	6a 00                	push   $0x0
80101446:	50                   	push   %eax
80101447:	e8 40 35 00 00       	call   8010498c <memset>
8010144c:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
8010144f:	83 ec 0c             	sub    $0xc,%esp
80101452:	ff 75 f4             	push   -0xc(%ebp)
80101455:	e8 1d 1e 00 00       	call   80103277 <log_write>
8010145a:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010145d:	83 ec 0c             	sub    $0xc,%esp
80101460:	ff 75 f4             	push   -0xc(%ebp)
80101463:	e8 1b ee ff ff       	call   80100283 <brelse>
80101468:	83 c4 10             	add    $0x10,%esp
}
8010146b:	90                   	nop
8010146c:	c9                   	leave
8010146d:	c3                   	ret

8010146e <balloc>:
// Blocks.

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
8010146e:	55                   	push   %ebp
8010146f:	89 e5                	mov    %esp,%ebp
80101471:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101474:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010147b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101482:	e9 0b 01 00 00       	jmp    80101592 <balloc+0x124>
    bp = bread(dev, BBLOCK(b, sb));
80101487:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010148a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101490:	85 c0                	test   %eax,%eax
80101492:	0f 48 c2             	cmovs  %edx,%eax
80101495:	c1 f8 0c             	sar    $0xc,%eax
80101498:	89 c2                	mov    %eax,%edx
8010149a:	a1 58 24 19 80       	mov    0x80192458,%eax
8010149f:	01 d0                	add    %edx,%eax
801014a1:	83 ec 08             	sub    $0x8,%esp
801014a4:	50                   	push   %eax
801014a5:	ff 75 08             	push   0x8(%ebp)
801014a8:	e8 54 ed ff ff       	call   80100201 <bread>
801014ad:	83 c4 10             	add    $0x10,%esp
801014b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014b3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801014ba:	e9 9e 00 00 00       	jmp    8010155d <balloc+0xef>
      m = 1 << (bi % 8);
801014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014c2:	83 e0 07             	and    $0x7,%eax
801014c5:	ba 01 00 00 00       	mov    $0x1,%edx
801014ca:	89 c1                	mov    %eax,%ecx
801014cc:	d3 e2                	shl    %cl,%edx
801014ce:	89 d0                	mov    %edx,%eax
801014d0:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	8d 50 07             	lea    0x7(%eax),%edx
801014d9:	85 c0                	test   %eax,%eax
801014db:	0f 48 c2             	cmovs  %edx,%eax
801014de:	c1 f8 03             	sar    $0x3,%eax
801014e1:	89 c2                	mov    %eax,%edx
801014e3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801014e6:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
801014eb:	0f b6 c0             	movzbl %al,%eax
801014ee:	23 45 e8             	and    -0x18(%ebp),%eax
801014f1:	85 c0                	test   %eax,%eax
801014f3:	75 64                	jne    80101559 <balloc+0xeb>
        bp->data[bi/8] |= m;  // Mark block in use.
801014f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014f8:	8d 50 07             	lea    0x7(%eax),%edx
801014fb:	85 c0                	test   %eax,%eax
801014fd:	0f 48 c2             	cmovs  %edx,%eax
80101500:	c1 f8 03             	sar    $0x3,%eax
80101503:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101506:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
8010150b:	89 d1                	mov    %edx,%ecx
8010150d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80101510:	09 ca                	or     %ecx,%edx
80101512:	89 d1                	mov    %edx,%ecx
80101514:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101517:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
        log_write(bp);
8010151b:	83 ec 0c             	sub    $0xc,%esp
8010151e:	ff 75 ec             	push   -0x14(%ebp)
80101521:	e8 51 1d 00 00       	call   80103277 <log_write>
80101526:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
80101529:	83 ec 0c             	sub    $0xc,%esp
8010152c:	ff 75 ec             	push   -0x14(%ebp)
8010152f:	e8 4f ed ff ff       	call   80100283 <brelse>
80101534:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
80101537:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010153a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010153d:	01 c2                	add    %eax,%edx
8010153f:	8b 45 08             	mov    0x8(%ebp),%eax
80101542:	83 ec 08             	sub    $0x8,%esp
80101545:	52                   	push   %edx
80101546:	50                   	push   %eax
80101547:	e8 ce fe ff ff       	call   8010141a <bzero>
8010154c:	83 c4 10             	add    $0x10,%esp
        return b + bi;
8010154f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101552:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101555:	01 d0                	add    %edx,%eax
80101557:	eb 56                	jmp    801015af <balloc+0x141>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101559:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010155d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101564:	7f 17                	jg     8010157d <balloc+0x10f>
80101566:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101569:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010156c:	01 d0                	add    %edx,%eax
8010156e:	89 c2                	mov    %eax,%edx
80101570:	a1 40 24 19 80       	mov    0x80192440,%eax
80101575:	39 c2                	cmp    %eax,%edx
80101577:	0f 82 42 ff ff ff    	jb     801014bf <balloc+0x51>
      }
    }
    brelse(bp);
8010157d:	83 ec 0c             	sub    $0xc,%esp
80101580:	ff 75 ec             	push   -0x14(%ebp)
80101583:	e8 fb ec ff ff       	call   80100283 <brelse>
80101588:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010158b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101592:	a1 40 24 19 80       	mov    0x80192440,%eax
80101597:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010159a:	39 c2                	cmp    %eax,%edx
8010159c:	0f 82 e5 fe ff ff    	jb     80101487 <balloc+0x19>
  }
  panic("balloc: out of blocks");
801015a2:	83 ec 0c             	sub    $0xc,%esp
801015a5:	68 e0 a0 10 80       	push   $0x8010a0e0
801015aa:	e8 fa ef ff ff       	call   801005a9 <panic>
}
801015af:	c9                   	leave
801015b0:	c3                   	ret

801015b1 <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
801015b1:	55                   	push   %ebp
801015b2:	89 e5                	mov    %esp,%ebp
801015b4:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
801015b7:	83 ec 08             	sub    $0x8,%esp
801015ba:	68 40 24 19 80       	push   $0x80192440
801015bf:	ff 75 08             	push   0x8(%ebp)
801015c2:	e8 11 fe ff ff       	call   801013d8 <readsb>
801015c7:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801015ca:	8b 45 0c             	mov    0xc(%ebp),%eax
801015cd:	c1 e8 0c             	shr    $0xc,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	a1 58 24 19 80       	mov    0x80192458,%eax
801015d7:	01 c2                	add    %eax,%edx
801015d9:	8b 45 08             	mov    0x8(%ebp),%eax
801015dc:	83 ec 08             	sub    $0x8,%esp
801015df:	52                   	push   %edx
801015e0:	50                   	push   %eax
801015e1:	e8 1b ec ff ff       	call   80100201 <bread>
801015e6:	83 c4 10             	add    $0x10,%esp
801015e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
801015ec:	8b 45 0c             	mov    0xc(%ebp),%eax
801015ef:	25 ff 0f 00 00       	and    $0xfff,%eax
801015f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015fa:	83 e0 07             	and    $0x7,%eax
801015fd:	ba 01 00 00 00       	mov    $0x1,%edx
80101602:	89 c1                	mov    %eax,%ecx
80101604:	d3 e2                	shl    %cl,%edx
80101606:	89 d0                	mov    %edx,%eax
80101608:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
8010160b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010160e:	8d 50 07             	lea    0x7(%eax),%edx
80101611:	85 c0                	test   %eax,%eax
80101613:	0f 48 c2             	cmovs  %edx,%eax
80101616:	c1 f8 03             	sar    $0x3,%eax
80101619:	89 c2                	mov    %eax,%edx
8010161b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010161e:	0f b6 44 10 5c       	movzbl 0x5c(%eax,%edx,1),%eax
80101623:	0f b6 c0             	movzbl %al,%eax
80101626:	23 45 ec             	and    -0x14(%ebp),%eax
80101629:	85 c0                	test   %eax,%eax
8010162b:	75 0d                	jne    8010163a <bfree+0x89>
    panic("freeing free block");
8010162d:	83 ec 0c             	sub    $0xc,%esp
80101630:	68 f6 a0 10 80       	push   $0x8010a0f6
80101635:	e8 6f ef ff ff       	call   801005a9 <panic>
  bp->data[bi/8] &= ~m;
8010163a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010163d:	8d 50 07             	lea    0x7(%eax),%edx
80101640:	85 c0                	test   %eax,%eax
80101642:	0f 48 c2             	cmovs  %edx,%eax
80101645:	c1 f8 03             	sar    $0x3,%eax
80101648:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010164b:	0f b6 54 02 5c       	movzbl 0x5c(%edx,%eax,1),%edx
80101650:	89 d1                	mov    %edx,%ecx
80101652:	8b 55 ec             	mov    -0x14(%ebp),%edx
80101655:	f7 d2                	not    %edx
80101657:	21 ca                	and    %ecx,%edx
80101659:	89 d1                	mov    %edx,%ecx
8010165b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010165e:	88 4c 02 5c          	mov    %cl,0x5c(%edx,%eax,1)
  log_write(bp);
80101662:	83 ec 0c             	sub    $0xc,%esp
80101665:	ff 75 f4             	push   -0xc(%ebp)
80101668:	e8 0a 1c 00 00       	call   80103277 <log_write>
8010166d:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101670:	83 ec 0c             	sub    $0xc,%esp
80101673:	ff 75 f4             	push   -0xc(%ebp)
80101676:	e8 08 ec ff ff       	call   80100283 <brelse>
8010167b:	83 c4 10             	add    $0x10,%esp
}
8010167e:	90                   	nop
8010167f:	c9                   	leave
80101680:	c3                   	ret

80101681 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101681:	55                   	push   %ebp
80101682:	89 e5                	mov    %esp,%ebp
80101684:	57                   	push   %edi
80101685:	56                   	push   %esi
80101686:	53                   	push   %ebx
80101687:	83 ec 2c             	sub    $0x2c,%esp
  int i = 0;
8010168a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  
  initlock(&icache.lock, "icache");
80101691:	83 ec 08             	sub    $0x8,%esp
80101694:	68 09 a1 10 80       	push   $0x8010a109
80101699:	68 60 24 19 80       	push   $0x80192460
8010169e:	e8 51 30 00 00       	call   801046f4 <initlock>
801016a3:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016a6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801016ad:	eb 2d                	jmp    801016dc <iinit+0x5b>
    initsleeplock(&icache.inode[i].lock, "inode");
801016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801016b2:	89 d0                	mov    %edx,%eax
801016b4:	c1 e0 03             	shl    $0x3,%eax
801016b7:	01 d0                	add    %edx,%eax
801016b9:	c1 e0 04             	shl    $0x4,%eax
801016bc:	83 c0 30             	add    $0x30,%eax
801016bf:	05 60 24 19 80       	add    $0x80192460,%eax
801016c4:	83 c0 10             	add    $0x10,%eax
801016c7:	83 ec 08             	sub    $0x8,%esp
801016ca:	68 10 a1 10 80       	push   $0x8010a110
801016cf:	50                   	push   %eax
801016d0:	e8 c2 2e 00 00       	call   80104597 <initsleeplock>
801016d5:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NINODE; i++) {
801016d8:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801016dc:	83 7d e4 31          	cmpl   $0x31,-0x1c(%ebp)
801016e0:	7e cd                	jle    801016af <iinit+0x2e>
  }

  readsb(dev, &sb);
801016e2:	83 ec 08             	sub    $0x8,%esp
801016e5:	68 40 24 19 80       	push   $0x80192440
801016ea:	ff 75 08             	push   0x8(%ebp)
801016ed:	e8 e6 fc ff ff       	call   801013d8 <readsb>
801016f2:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801016f5:	a1 58 24 19 80       	mov    0x80192458,%eax
801016fa:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801016fd:	8b 3d 54 24 19 80    	mov    0x80192454,%edi
80101703:	8b 35 50 24 19 80    	mov    0x80192450,%esi
80101709:	8b 1d 4c 24 19 80    	mov    0x8019244c,%ebx
8010170f:	8b 0d 48 24 19 80    	mov    0x80192448,%ecx
80101715:	8b 15 44 24 19 80    	mov    0x80192444,%edx
8010171b:	a1 40 24 19 80       	mov    0x80192440,%eax
80101720:	ff 75 d4             	push   -0x2c(%ebp)
80101723:	57                   	push   %edi
80101724:	56                   	push   %esi
80101725:	53                   	push   %ebx
80101726:	51                   	push   %ecx
80101727:	52                   	push   %edx
80101728:	50                   	push   %eax
80101729:	68 18 a1 10 80       	push   $0x8010a118
8010172e:	e8 c1 ec ff ff       	call   801003f4 <cprintf>
80101733:	83 c4 20             	add    $0x20,%esp
 inodestart %d bmap start %d\n", sb.size, sb.nblocks,
          sb.ninodes, sb.nlog, sb.logstart, sb.inodestart,
          sb.bmapstart);
}
80101736:	90                   	nop
80101737:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010173a:	5b                   	pop    %ebx
8010173b:	5e                   	pop    %esi
8010173c:	5f                   	pop    %edi
8010173d:	5d                   	pop    %ebp
8010173e:	c3                   	ret

8010173f <ialloc>:
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode*
ialloc(uint dev, short type)
{
8010173f:	55                   	push   %ebp
80101740:	89 e5                	mov    %esp,%ebp
80101742:	83 ec 28             	sub    $0x28,%esp
80101745:	8b 45 0c             	mov    0xc(%ebp),%eax
80101748:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
8010174c:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
80101753:	e9 9e 00 00 00       	jmp    801017f6 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
80101758:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175b:	c1 e8 03             	shr    $0x3,%eax
8010175e:	89 c2                	mov    %eax,%edx
80101760:	a1 54 24 19 80       	mov    0x80192454,%eax
80101765:	01 d0                	add    %edx,%eax
80101767:	83 ec 08             	sub    $0x8,%esp
8010176a:	50                   	push   %eax
8010176b:	ff 75 08             	push   0x8(%ebp)
8010176e:	e8 8e ea ff ff       	call   80100201 <bread>
80101773:	83 c4 10             	add    $0x10,%esp
80101776:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
80101779:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177c:	8d 50 5c             	lea    0x5c(%eax),%edx
8010177f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101782:	83 e0 07             	and    $0x7,%eax
80101785:	c1 e0 06             	shl    $0x6,%eax
80101788:	01 d0                	add    %edx,%eax
8010178a:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
8010178d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101790:	0f b7 00             	movzwl (%eax),%eax
80101793:	66 85 c0             	test   %ax,%ax
80101796:	75 4c                	jne    801017e4 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
80101798:	83 ec 04             	sub    $0x4,%esp
8010179b:	6a 40                	push   $0x40
8010179d:	6a 00                	push   $0x0
8010179f:	ff 75 ec             	push   -0x14(%ebp)
801017a2:	e8 e5 31 00 00       	call   8010498c <memset>
801017a7:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801017aa:	8b 45 ec             	mov    -0x14(%ebp),%eax
801017ad:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
801017b1:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801017b4:	83 ec 0c             	sub    $0xc,%esp
801017b7:	ff 75 f0             	push   -0x10(%ebp)
801017ba:	e8 b8 1a 00 00       	call   80103277 <log_write>
801017bf:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801017c2:	83 ec 0c             	sub    $0xc,%esp
801017c5:	ff 75 f0             	push   -0x10(%ebp)
801017c8:	e8 b6 ea ff ff       	call   80100283 <brelse>
801017cd:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801017d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	50                   	push   %eax
801017d7:	ff 75 08             	push   0x8(%ebp)
801017da:	e8 f7 00 00 00       	call   801018d6 <iget>
801017df:	83 c4 10             	add    $0x10,%esp
801017e2:	eb 2f                	jmp    80101813 <ialloc+0xd4>
    }
    brelse(bp);
801017e4:	83 ec 0c             	sub    $0xc,%esp
801017e7:	ff 75 f0             	push   -0x10(%ebp)
801017ea:	e8 94 ea ff ff       	call   80100283 <brelse>
801017ef:	83 c4 10             	add    $0x10,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
801017f2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801017f6:	a1 48 24 19 80       	mov    0x80192448,%eax
801017fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801017fe:	39 c2                	cmp    %eax,%edx
80101800:	0f 82 52 ff ff ff    	jb     80101758 <ialloc+0x19>
  }
  panic("ialloc: no inodes");
80101806:	83 ec 0c             	sub    $0xc,%esp
80101809:	68 6b a1 10 80       	push   $0x8010a16b
8010180e:	e8 96 ed ff ff       	call   801005a9 <panic>
}
80101813:	c9                   	leave
80101814:	c3                   	ret

80101815 <iupdate>:
// Must be called after every change to an ip->xxx field
// that lives on disk, since i-node cache is write-through.
// Caller must hold ip->lock.
void
iupdate(struct inode *ip)
{
80101815:	55                   	push   %ebp
80101816:	89 e5                	mov    %esp,%ebp
80101818:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010181b:	8b 45 08             	mov    0x8(%ebp),%eax
8010181e:	8b 40 04             	mov    0x4(%eax),%eax
80101821:	c1 e8 03             	shr    $0x3,%eax
80101824:	89 c2                	mov    %eax,%edx
80101826:	a1 54 24 19 80       	mov    0x80192454,%eax
8010182b:	01 c2                	add    %eax,%edx
8010182d:	8b 45 08             	mov    0x8(%ebp),%eax
80101830:	8b 00                	mov    (%eax),%eax
80101832:	83 ec 08             	sub    $0x8,%esp
80101835:	52                   	push   %edx
80101836:	50                   	push   %eax
80101837:	e8 c5 e9 ff ff       	call   80100201 <bread>
8010183c:	83 c4 10             	add    $0x10,%esp
8010183f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101842:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101845:	8d 50 5c             	lea    0x5c(%eax),%edx
80101848:	8b 45 08             	mov    0x8(%ebp),%eax
8010184b:	8b 40 04             	mov    0x4(%eax),%eax
8010184e:	83 e0 07             	and    $0x7,%eax
80101851:	c1 e0 06             	shl    $0x6,%eax
80101854:	01 d0                	add    %edx,%eax
80101856:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101859:	8b 45 08             	mov    0x8(%ebp),%eax
8010185c:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101860:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101863:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101866:	8b 45 08             	mov    0x8(%ebp),%eax
80101869:	0f b7 50 52          	movzwl 0x52(%eax),%edx
8010186d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101870:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101874:	8b 45 08             	mov    0x8(%ebp),%eax
80101877:	0f b7 50 54          	movzwl 0x54(%eax),%edx
8010187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010187e:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101882:	8b 45 08             	mov    0x8(%ebp),%eax
80101885:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101889:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010188c:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
80101890:	8b 45 08             	mov    0x8(%ebp),%eax
80101893:	8b 50 58             	mov    0x58(%eax),%edx
80101896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101899:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010189c:	8b 45 08             	mov    0x8(%ebp),%eax
8010189f:	8d 50 5c             	lea    0x5c(%eax),%edx
801018a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018a5:	83 c0 0c             	add    $0xc,%eax
801018a8:	83 ec 04             	sub    $0x4,%esp
801018ab:	6a 34                	push   $0x34
801018ad:	52                   	push   %edx
801018ae:	50                   	push   %eax
801018af:	e8 97 31 00 00       	call   80104a4b <memmove>
801018b4:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801018b7:	83 ec 0c             	sub    $0xc,%esp
801018ba:	ff 75 f4             	push   -0xc(%ebp)
801018bd:	e8 b5 19 00 00       	call   80103277 <log_write>
801018c2:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801018c5:	83 ec 0c             	sub    $0xc,%esp
801018c8:	ff 75 f4             	push   -0xc(%ebp)
801018cb:	e8 b3 e9 ff ff       	call   80100283 <brelse>
801018d0:	83 c4 10             	add    $0x10,%esp
}
801018d3:	90                   	nop
801018d4:	c9                   	leave
801018d5:	c3                   	ret

801018d6 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801018d6:	55                   	push   %ebp
801018d7:	89 e5                	mov    %esp,%ebp
801018d9:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801018dc:	83 ec 0c             	sub    $0xc,%esp
801018df:	68 60 24 19 80       	push   $0x80192460
801018e4:	e8 2d 2e 00 00       	call   80104716 <acquire>
801018e9:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
801018ec:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018f3:	c7 45 f4 94 24 19 80 	movl   $0x80192494,-0xc(%ebp)
801018fa:	eb 60                	jmp    8010195c <iget+0x86>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801018fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ff:	8b 40 08             	mov    0x8(%eax),%eax
80101902:	85 c0                	test   %eax,%eax
80101904:	7e 39                	jle    8010193f <iget+0x69>
80101906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101909:	8b 00                	mov    (%eax),%eax
8010190b:	39 45 08             	cmp    %eax,0x8(%ebp)
8010190e:	75 2f                	jne    8010193f <iget+0x69>
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101913:	8b 40 04             	mov    0x4(%eax),%eax
80101916:	39 45 0c             	cmp    %eax,0xc(%ebp)
80101919:	75 24                	jne    8010193f <iget+0x69>
      ip->ref++;
8010191b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010191e:	8b 40 08             	mov    0x8(%eax),%eax
80101921:	8d 50 01             	lea    0x1(%eax),%edx
80101924:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101927:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010192a:	83 ec 0c             	sub    $0xc,%esp
8010192d:	68 60 24 19 80       	push   $0x80192460
80101932:	e8 4d 2e 00 00       	call   80104784 <release>
80101937:	83 c4 10             	add    $0x10,%esp
      return ip;
8010193a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010193d:	eb 77                	jmp    801019b6 <iget+0xe0>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010193f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101943:	75 10                	jne    80101955 <iget+0x7f>
80101945:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101948:	8b 40 08             	mov    0x8(%eax),%eax
8010194b:	85 c0                	test   %eax,%eax
8010194d:	75 06                	jne    80101955 <iget+0x7f>
      empty = ip;
8010194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101955:	81 45 f4 90 00 00 00 	addl   $0x90,-0xc(%ebp)
8010195c:	81 7d f4 b4 40 19 80 	cmpl   $0x801940b4,-0xc(%ebp)
80101963:	72 97                	jb     801018fc <iget+0x26>
  }

  // Recycle an inode cache entry.
  if(empty == 0)
80101965:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101969:	75 0d                	jne    80101978 <iget+0xa2>
    panic("iget: no inodes");
8010196b:	83 ec 0c             	sub    $0xc,%esp
8010196e:	68 7d a1 10 80       	push   $0x8010a17d
80101973:	e8 31 ec ff ff       	call   801005a9 <panic>

  ip = empty;
80101978:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010197b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
8010197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101981:	8b 55 08             	mov    0x8(%ebp),%edx
80101984:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
80101986:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101989:	8b 55 0c             	mov    0xc(%ebp),%edx
8010198c:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
8010198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101992:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->valid = 0;
80101999:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010199c:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  release(&icache.lock);
801019a3:	83 ec 0c             	sub    $0xc,%esp
801019a6:	68 60 24 19 80       	push   $0x80192460
801019ab:	e8 d4 2d 00 00       	call   80104784 <release>
801019b0:	83 c4 10             	add    $0x10,%esp

  return ip;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801019b6:	c9                   	leave
801019b7:	c3                   	ret

801019b8 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801019b8:	55                   	push   %ebp
801019b9:	89 e5                	mov    %esp,%ebp
801019bb:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801019be:	83 ec 0c             	sub    $0xc,%esp
801019c1:	68 60 24 19 80       	push   $0x80192460
801019c6:	e8 4b 2d 00 00       	call   80104716 <acquire>
801019cb:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801019ce:	8b 45 08             	mov    0x8(%ebp),%eax
801019d1:	8b 40 08             	mov    0x8(%eax),%eax
801019d4:	8d 50 01             	lea    0x1(%eax),%edx
801019d7:	8b 45 08             	mov    0x8(%ebp),%eax
801019da:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801019dd:	83 ec 0c             	sub    $0xc,%esp
801019e0:	68 60 24 19 80       	push   $0x80192460
801019e5:	e8 9a 2d 00 00       	call   80104784 <release>
801019ea:	83 c4 10             	add    $0x10,%esp
  return ip;
801019ed:	8b 45 08             	mov    0x8(%ebp),%eax
}
801019f0:	c9                   	leave
801019f1:	c3                   	ret

801019f2 <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
801019f2:	55                   	push   %ebp
801019f3:	89 e5                	mov    %esp,%ebp
801019f5:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
801019f8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801019fc:	74 0a                	je     80101a08 <ilock+0x16>
801019fe:	8b 45 08             	mov    0x8(%ebp),%eax
80101a01:	8b 40 08             	mov    0x8(%eax),%eax
80101a04:	85 c0                	test   %eax,%eax
80101a06:	7f 0d                	jg     80101a15 <ilock+0x23>
    panic("ilock");
80101a08:	83 ec 0c             	sub    $0xc,%esp
80101a0b:	68 8d a1 10 80       	push   $0x8010a18d
80101a10:	e8 94 eb ff ff       	call   801005a9 <panic>

  acquiresleep(&ip->lock);
80101a15:	8b 45 08             	mov    0x8(%ebp),%eax
80101a18:	83 c0 0c             	add    $0xc,%eax
80101a1b:	83 ec 0c             	sub    $0xc,%esp
80101a1e:	50                   	push   %eax
80101a1f:	e8 af 2b 00 00       	call   801045d3 <acquiresleep>
80101a24:	83 c4 10             	add    $0x10,%esp

  if(ip->valid == 0){
80101a27:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101a2d:	85 c0                	test   %eax,%eax
80101a2f:	0f 85 cd 00 00 00    	jne    80101b02 <ilock+0x110>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101a35:	8b 45 08             	mov    0x8(%ebp),%eax
80101a38:	8b 40 04             	mov    0x4(%eax),%eax
80101a3b:	c1 e8 03             	shr    $0x3,%eax
80101a3e:	89 c2                	mov    %eax,%edx
80101a40:	a1 54 24 19 80       	mov    0x80192454,%eax
80101a45:	01 c2                	add    %eax,%edx
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	8b 00                	mov    (%eax),%eax
80101a4c:	83 ec 08             	sub    $0x8,%esp
80101a4f:	52                   	push   %edx
80101a50:	50                   	push   %eax
80101a51:	e8 ab e7 ff ff       	call   80100201 <bread>
80101a56:	83 c4 10             	add    $0x10,%esp
80101a59:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
80101a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a5f:	8d 50 5c             	lea    0x5c(%eax),%edx
80101a62:	8b 45 08             	mov    0x8(%ebp),%eax
80101a65:	8b 40 04             	mov    0x4(%eax),%eax
80101a68:	83 e0 07             	and    $0x7,%eax
80101a6b:	c1 e0 06             	shl    $0x6,%eax
80101a6e:	01 d0                	add    %edx,%eax
80101a70:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a76:	0f b7 10             	movzwl (%eax),%edx
80101a79:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7c:	66 89 50 50          	mov    %dx,0x50(%eax)
    ip->major = dip->major;
80101a80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a83:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a87:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8a:	66 89 50 52          	mov    %dx,0x52(%eax)
    ip->minor = dip->minor;
80101a8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a91:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a95:	8b 45 08             	mov    0x8(%ebp),%eax
80101a98:	66 89 50 54          	mov    %dx,0x54(%eax)
    ip->nlink = dip->nlink;
80101a9c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a9f:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	66 89 50 56          	mov    %dx,0x56(%eax)
    ip->size = dip->size;
80101aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101aad:	8b 50 08             	mov    0x8(%eax),%edx
80101ab0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab3:	89 50 58             	mov    %edx,0x58(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101ab6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ab9:	8d 50 0c             	lea    0xc(%eax),%edx
80101abc:	8b 45 08             	mov    0x8(%ebp),%eax
80101abf:	83 c0 5c             	add    $0x5c,%eax
80101ac2:	83 ec 04             	sub    $0x4,%esp
80101ac5:	6a 34                	push   $0x34
80101ac7:	52                   	push   %edx
80101ac8:	50                   	push   %eax
80101ac9:	e8 7d 2f 00 00       	call   80104a4b <memmove>
80101ace:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101ad1:	83 ec 0c             	sub    $0xc,%esp
80101ad4:	ff 75 f4             	push   -0xc(%ebp)
80101ad7:	e8 a7 e7 ff ff       	call   80100283 <brelse>
80101adc:	83 c4 10             	add    $0x10,%esp
    ip->valid = 1;
80101adf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ae2:	c7 40 4c 01 00 00 00 	movl   $0x1,0x4c(%eax)
    if(ip->type == 0)
80101ae9:	8b 45 08             	mov    0x8(%ebp),%eax
80101aec:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101af0:	66 85 c0             	test   %ax,%ax
80101af3:	75 0d                	jne    80101b02 <ilock+0x110>
      panic("ilock: no type");
80101af5:	83 ec 0c             	sub    $0xc,%esp
80101af8:	68 93 a1 10 80       	push   $0x8010a193
80101afd:	e8 a7 ea ff ff       	call   801005a9 <panic>
  }
}
80101b02:	90                   	nop
80101b03:	c9                   	leave
80101b04:	c3                   	ret

80101b05 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101b05:	55                   	push   %ebp
80101b06:	89 e5                	mov    %esp,%ebp
80101b08:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101b0b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101b0f:	74 20                	je     80101b31 <iunlock+0x2c>
80101b11:	8b 45 08             	mov    0x8(%ebp),%eax
80101b14:	83 c0 0c             	add    $0xc,%eax
80101b17:	83 ec 0c             	sub    $0xc,%esp
80101b1a:	50                   	push   %eax
80101b1b:	e8 65 2b 00 00       	call   80104685 <holdingsleep>
80101b20:	83 c4 10             	add    $0x10,%esp
80101b23:	85 c0                	test   %eax,%eax
80101b25:	74 0a                	je     80101b31 <iunlock+0x2c>
80101b27:	8b 45 08             	mov    0x8(%ebp),%eax
80101b2a:	8b 40 08             	mov    0x8(%eax),%eax
80101b2d:	85 c0                	test   %eax,%eax
80101b2f:	7f 0d                	jg     80101b3e <iunlock+0x39>
    panic("iunlock");
80101b31:	83 ec 0c             	sub    $0xc,%esp
80101b34:	68 a2 a1 10 80       	push   $0x8010a1a2
80101b39:	e8 6b ea ff ff       	call   801005a9 <panic>

  releasesleep(&ip->lock);
80101b3e:	8b 45 08             	mov    0x8(%ebp),%eax
80101b41:	83 c0 0c             	add    $0xc,%eax
80101b44:	83 ec 0c             	sub    $0xc,%esp
80101b47:	50                   	push   %eax
80101b48:	e8 ea 2a 00 00       	call   80104637 <releasesleep>
80101b4d:	83 c4 10             	add    $0x10,%esp
}
80101b50:	90                   	nop
80101b51:	c9                   	leave
80101b52:	c3                   	ret

80101b53 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b53:	55                   	push   %ebp
80101b54:	89 e5                	mov    %esp,%ebp
80101b56:	83 ec 18             	sub    $0x18,%esp
  acquiresleep(&ip->lock);
80101b59:	8b 45 08             	mov    0x8(%ebp),%eax
80101b5c:	83 c0 0c             	add    $0xc,%eax
80101b5f:	83 ec 0c             	sub    $0xc,%esp
80101b62:	50                   	push   %eax
80101b63:	e8 6b 2a 00 00       	call   801045d3 <acquiresleep>
80101b68:	83 c4 10             	add    $0x10,%esp
  if(ip->valid && ip->nlink == 0){
80101b6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b6e:	8b 40 4c             	mov    0x4c(%eax),%eax
80101b71:	85 c0                	test   %eax,%eax
80101b73:	74 6a                	je     80101bdf <iput+0x8c>
80101b75:	8b 45 08             	mov    0x8(%ebp),%eax
80101b78:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80101b7c:	66 85 c0             	test   %ax,%ax
80101b7f:	75 5e                	jne    80101bdf <iput+0x8c>
    acquire(&icache.lock);
80101b81:	83 ec 0c             	sub    $0xc,%esp
80101b84:	68 60 24 19 80       	push   $0x80192460
80101b89:	e8 88 2b 00 00       	call   80104716 <acquire>
80101b8e:	83 c4 10             	add    $0x10,%esp
    int r = ip->ref;
80101b91:	8b 45 08             	mov    0x8(%ebp),%eax
80101b94:	8b 40 08             	mov    0x8(%eax),%eax
80101b97:	89 45 f4             	mov    %eax,-0xc(%ebp)
    release(&icache.lock);
80101b9a:	83 ec 0c             	sub    $0xc,%esp
80101b9d:	68 60 24 19 80       	push   $0x80192460
80101ba2:	e8 dd 2b 00 00       	call   80104784 <release>
80101ba7:	83 c4 10             	add    $0x10,%esp
    if(r == 1){
80101baa:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80101bae:	75 2f                	jne    80101bdf <iput+0x8c>
      // inode has no links and no other references: truncate and free.
      itrunc(ip);
80101bb0:	83 ec 0c             	sub    $0xc,%esp
80101bb3:	ff 75 08             	push   0x8(%ebp)
80101bb6:	e8 ad 01 00 00       	call   80101d68 <itrunc>
80101bbb:	83 c4 10             	add    $0x10,%esp
      ip->type = 0;
80101bbe:	8b 45 08             	mov    0x8(%ebp),%eax
80101bc1:	66 c7 40 50 00 00    	movw   $0x0,0x50(%eax)
      iupdate(ip);
80101bc7:	83 ec 0c             	sub    $0xc,%esp
80101bca:	ff 75 08             	push   0x8(%ebp)
80101bcd:	e8 43 fc ff ff       	call   80101815 <iupdate>
80101bd2:	83 c4 10             	add    $0x10,%esp
      ip->valid = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
    }
  }
  releasesleep(&ip->lock);
80101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80101be2:	83 c0 0c             	add    $0xc,%eax
80101be5:	83 ec 0c             	sub    $0xc,%esp
80101be8:	50                   	push   %eax
80101be9:	e8 49 2a 00 00       	call   80104637 <releasesleep>
80101bee:	83 c4 10             	add    $0x10,%esp

  acquire(&icache.lock);
80101bf1:	83 ec 0c             	sub    $0xc,%esp
80101bf4:	68 60 24 19 80       	push   $0x80192460
80101bf9:	e8 18 2b 00 00       	call   80104716 <acquire>
80101bfe:	83 c4 10             	add    $0x10,%esp
  ip->ref--;
80101c01:	8b 45 08             	mov    0x8(%ebp),%eax
80101c04:	8b 40 08             	mov    0x8(%eax),%eax
80101c07:	8d 50 ff             	lea    -0x1(%eax),%edx
80101c0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0d:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101c10:	83 ec 0c             	sub    $0xc,%esp
80101c13:	68 60 24 19 80       	push   $0x80192460
80101c18:	e8 67 2b 00 00       	call   80104784 <release>
80101c1d:	83 c4 10             	add    $0x10,%esp
}
80101c20:	90                   	nop
80101c21:	c9                   	leave
80101c22:	c3                   	ret

80101c23 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c23:	55                   	push   %ebp
80101c24:	89 e5                	mov    %esp,%ebp
80101c26:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c29:	83 ec 0c             	sub    $0xc,%esp
80101c2c:	ff 75 08             	push   0x8(%ebp)
80101c2f:	e8 d1 fe ff ff       	call   80101b05 <iunlock>
80101c34:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c37:	83 ec 0c             	sub    $0xc,%esp
80101c3a:	ff 75 08             	push   0x8(%ebp)
80101c3d:	e8 11 ff ff ff       	call   80101b53 <iput>
80101c42:	83 c4 10             	add    $0x10,%esp
}
80101c45:	90                   	nop
80101c46:	c9                   	leave
80101c47:	c3                   	ret

80101c48 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c48:	55                   	push   %ebp
80101c49:	89 e5                	mov    %esp,%ebp
80101c4b:	83 ec 18             	sub    $0x18,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c4e:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c52:	77 42                	ja     80101c96 <bmap+0x4e>
    if((addr = ip->addrs[bn]) == 0)
80101c54:	8b 45 08             	mov    0x8(%ebp),%eax
80101c57:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c5a:	83 c2 14             	add    $0x14,%edx
80101c5d:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c61:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c64:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c68:	75 24                	jne    80101c8e <bmap+0x46>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 00                	mov    (%eax),%eax
80101c6f:	83 ec 0c             	sub    $0xc,%esp
80101c72:	50                   	push   %eax
80101c73:	e8 f6 f7 ff ff       	call   8010146e <balloc>
80101c78:	83 c4 10             	add    $0x10,%esp
80101c7b:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c7e:	8b 45 08             	mov    0x8(%ebp),%eax
80101c81:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c84:	8d 4a 14             	lea    0x14(%edx),%ecx
80101c87:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c8a:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c91:	e9 d0 00 00 00       	jmp    80101d66 <bmap+0x11e>
  }
  bn -= NDIRECT;
80101c96:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c9a:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c9e:	0f 87 b5 00 00 00    	ja     80101d59 <bmap+0x111>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101ca4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca7:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101cad:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cb4:	75 20                	jne    80101cd6 <bmap+0x8e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101cb6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb9:	8b 00                	mov    (%eax),%eax
80101cbb:	83 ec 0c             	sub    $0xc,%esp
80101cbe:	50                   	push   %eax
80101cbf:	e8 aa f7 ff ff       	call   8010146e <balloc>
80101cc4:	83 c4 10             	add    $0x10,%esp
80101cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cca:	8b 45 08             	mov    0x8(%ebp),%eax
80101ccd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cd0:	89 90 8c 00 00 00    	mov    %edx,0x8c(%eax)
    bp = bread(ip->dev, addr);
80101cd6:	8b 45 08             	mov    0x8(%ebp),%eax
80101cd9:	8b 00                	mov    (%eax),%eax
80101cdb:	83 ec 08             	sub    $0x8,%esp
80101cde:	ff 75 f4             	push   -0xc(%ebp)
80101ce1:	50                   	push   %eax
80101ce2:	e8 1a e5 ff ff       	call   80100201 <bread>
80101ce7:	83 c4 10             	add    $0x10,%esp
80101cea:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cf0:	83 c0 5c             	add    $0x5c,%eax
80101cf3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cf6:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cf9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d00:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d03:	01 d0                	add    %edx,%eax
80101d05:	8b 00                	mov    (%eax),%eax
80101d07:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d0a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101d0e:	75 36                	jne    80101d46 <bmap+0xfe>
      a[bn] = addr = balloc(ip->dev);
80101d10:	8b 45 08             	mov    0x8(%ebp),%eax
80101d13:	8b 00                	mov    (%eax),%eax
80101d15:	83 ec 0c             	sub    $0xc,%esp
80101d18:	50                   	push   %eax
80101d19:	e8 50 f7 ff ff       	call   8010146e <balloc>
80101d1e:	83 c4 10             	add    $0x10,%esp
80101d21:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d24:	8b 45 0c             	mov    0xc(%ebp),%eax
80101d27:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d31:	01 c2                	add    %eax,%edx
80101d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d36:	89 02                	mov    %eax,(%edx)
      log_write(bp);
80101d38:	83 ec 0c             	sub    $0xc,%esp
80101d3b:	ff 75 f0             	push   -0x10(%ebp)
80101d3e:	e8 34 15 00 00       	call   80103277 <log_write>
80101d43:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d46:	83 ec 0c             	sub    $0xc,%esp
80101d49:	ff 75 f0             	push   -0x10(%ebp)
80101d4c:	e8 32 e5 ff ff       	call   80100283 <brelse>
80101d51:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d57:	eb 0d                	jmp    80101d66 <bmap+0x11e>
  }

  panic("bmap: out of range");
80101d59:	83 ec 0c             	sub    $0xc,%esp
80101d5c:	68 aa a1 10 80       	push   $0x8010a1aa
80101d61:	e8 43 e8 ff ff       	call   801005a9 <panic>
}
80101d66:	c9                   	leave
80101d67:	c3                   	ret

80101d68 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d68:	55                   	push   %ebp
80101d69:	89 e5                	mov    %esp,%ebp
80101d6b:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d75:	eb 45                	jmp    80101dbc <itrunc+0x54>
    if(ip->addrs[i]){
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d7d:	83 c2 14             	add    $0x14,%edx
80101d80:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d84:	85 c0                	test   %eax,%eax
80101d86:	74 30                	je     80101db8 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d88:	8b 45 08             	mov    0x8(%ebp),%eax
80101d8b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d8e:	83 c2 14             	add    $0x14,%edx
80101d91:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d95:	8b 55 08             	mov    0x8(%ebp),%edx
80101d98:	8b 12                	mov    (%edx),%edx
80101d9a:	83 ec 08             	sub    $0x8,%esp
80101d9d:	50                   	push   %eax
80101d9e:	52                   	push   %edx
80101d9f:	e8 0d f8 ff ff       	call   801015b1 <bfree>
80101da4:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101da7:	8b 45 08             	mov    0x8(%ebp),%eax
80101daa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101dad:	83 c2 14             	add    $0x14,%edx
80101db0:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101db7:	00 
  for(i = 0; i < NDIRECT; i++){
80101db8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101dbc:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dc0:	7e b5                	jle    80101d77 <itrunc+0xf>
    }
  }

  if(ip->addrs[NDIRECT]){
80101dc2:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc5:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101dcb:	85 c0                	test   %eax,%eax
80101dcd:	0f 84 aa 00 00 00    	je     80101e7d <itrunc+0x115>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dd3:	8b 45 08             	mov    0x8(%ebp),%eax
80101dd6:	8b 90 8c 00 00 00    	mov    0x8c(%eax),%edx
80101ddc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ddf:	8b 00                	mov    (%eax),%eax
80101de1:	83 ec 08             	sub    $0x8,%esp
80101de4:	52                   	push   %edx
80101de5:	50                   	push   %eax
80101de6:	e8 16 e4 ff ff       	call   80100201 <bread>
80101deb:	83 c4 10             	add    $0x10,%esp
80101dee:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101df1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101df4:	83 c0 5c             	add    $0x5c,%eax
80101df7:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101dfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101e01:	eb 3c                	jmp    80101e3f <itrunc+0xd7>
      if(a[j])
80101e03:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e06:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e0d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e10:	01 d0                	add    %edx,%eax
80101e12:	8b 00                	mov    (%eax),%eax
80101e14:	85 c0                	test   %eax,%eax
80101e16:	74 23                	je     80101e3b <itrunc+0xd3>
        bfree(ip->dev, a[j]);
80101e18:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e1b:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e22:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e25:	01 d0                	add    %edx,%eax
80101e27:	8b 00                	mov    (%eax),%eax
80101e29:	8b 55 08             	mov    0x8(%ebp),%edx
80101e2c:	8b 12                	mov    (%edx),%edx
80101e2e:	83 ec 08             	sub    $0x8,%esp
80101e31:	50                   	push   %eax
80101e32:	52                   	push   %edx
80101e33:	e8 79 f7 ff ff       	call   801015b1 <bfree>
80101e38:	83 c4 10             	add    $0x10,%esp
    for(j = 0; j < NINDIRECT; j++){
80101e3b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e3f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e42:	83 f8 7f             	cmp    $0x7f,%eax
80101e45:	76 bc                	jbe    80101e03 <itrunc+0x9b>
    }
    brelse(bp);
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	ff 75 ec             	push   -0x14(%ebp)
80101e4d:	e8 31 e4 ff ff       	call   80100283 <brelse>
80101e52:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e55:	8b 45 08             	mov    0x8(%ebp),%eax
80101e58:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101e5e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e61:	8b 12                	mov    (%edx),%edx
80101e63:	83 ec 08             	sub    $0x8,%esp
80101e66:	50                   	push   %eax
80101e67:	52                   	push   %edx
80101e68:	e8 44 f7 ff ff       	call   801015b1 <bfree>
80101e6d:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e70:	8b 45 08             	mov    0x8(%ebp),%eax
80101e73:	c7 80 8c 00 00 00 00 	movl   $0x0,0x8c(%eax)
80101e7a:	00 00 00 
  }

  ip->size = 0;
80101e7d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e80:	c7 40 58 00 00 00 00 	movl   $0x0,0x58(%eax)
  iupdate(ip);
80101e87:	83 ec 0c             	sub    $0xc,%esp
80101e8a:	ff 75 08             	push   0x8(%ebp)
80101e8d:	e8 83 f9 ff ff       	call   80101815 <iupdate>
80101e92:	83 c4 10             	add    $0x10,%esp
}
80101e95:	90                   	nop
80101e96:	c9                   	leave
80101e97:	c3                   	ret

80101e98 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101e98:	55                   	push   %ebp
80101e99:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e9b:	8b 45 08             	mov    0x8(%ebp),%eax
80101e9e:	8b 00                	mov    (%eax),%eax
80101ea0:	89 c2                	mov    %eax,%edx
80101ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ea5:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101ea8:	8b 45 08             	mov    0x8(%ebp),%eax
80101eab:	8b 50 04             	mov    0x4(%eax),%edx
80101eae:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb1:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101eb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb7:	0f b7 50 50          	movzwl 0x50(%eax),%edx
80101ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ebe:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ec1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec4:	0f b7 50 56          	movzwl 0x56(%eax),%edx
80101ec8:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ecb:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101ecf:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed2:	8b 50 58             	mov    0x58(%eax),%edx
80101ed5:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ed8:	89 50 10             	mov    %edx,0x10(%eax)
}
80101edb:	90                   	nop
80101edc:	5d                   	pop    %ebp
80101edd:	c3                   	ret

80101ede <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ede:	55                   	push   %ebp
80101edf:	89 e5                	mov    %esp,%ebp
80101ee1:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ee4:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee7:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80101eeb:	66 83 f8 03          	cmp    $0x3,%ax
80101eef:	75 5c                	jne    80101f4d <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ef1:	8b 45 08             	mov    0x8(%ebp),%eax
80101ef4:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101ef8:	66 85 c0             	test   %ax,%ax
80101efb:	78 20                	js     80101f1d <readi+0x3f>
80101efd:	8b 45 08             	mov    0x8(%ebp),%eax
80101f00:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f04:	66 83 f8 09          	cmp    $0x9,%ax
80101f08:	7f 13                	jg     80101f1d <readi+0x3f>
80101f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0d:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f11:	98                   	cwtl
80101f12:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f19:	85 c0                	test   %eax,%eax
80101f1b:	75 0a                	jne    80101f27 <readi+0x49>
      return -1;
80101f1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f22:	e9 0a 01 00 00       	jmp    80102031 <readi+0x153>
    return devsw[ip->major].read(ip, dst, n);
80101f27:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2a:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80101f2e:	98                   	cwtl
80101f2f:	8b 04 c5 40 1a 19 80 	mov    -0x7fe6e5c0(,%eax,8),%eax
80101f36:	8b 55 14             	mov    0x14(%ebp),%edx
80101f39:	83 ec 04             	sub    $0x4,%esp
80101f3c:	52                   	push   %edx
80101f3d:	ff 75 0c             	push   0xc(%ebp)
80101f40:	ff 75 08             	push   0x8(%ebp)
80101f43:	ff d0                	call   *%eax
80101f45:	83 c4 10             	add    $0x10,%esp
80101f48:	e9 e4 00 00 00       	jmp    80102031 <readi+0x153>
  }

  if(off > ip->size || off + n < off)
80101f4d:	8b 45 08             	mov    0x8(%ebp),%eax
80101f50:	8b 40 58             	mov    0x58(%eax),%eax
80101f53:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f56:	72 0d                	jb     80101f65 <readi+0x87>
80101f58:	8b 55 10             	mov    0x10(%ebp),%edx
80101f5b:	8b 45 14             	mov    0x14(%ebp),%eax
80101f5e:	01 d0                	add    %edx,%eax
80101f60:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f63:	73 0a                	jae    80101f6f <readi+0x91>
    return -1;
80101f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f6a:	e9 c2 00 00 00       	jmp    80102031 <readi+0x153>
  if(off + n > ip->size)
80101f6f:	8b 55 10             	mov    0x10(%ebp),%edx
80101f72:	8b 45 14             	mov    0x14(%ebp),%eax
80101f75:	01 c2                	add    %eax,%edx
80101f77:	8b 45 08             	mov    0x8(%ebp),%eax
80101f7a:	8b 40 58             	mov    0x58(%eax),%eax
80101f7d:	39 d0                	cmp    %edx,%eax
80101f7f:	73 0c                	jae    80101f8d <readi+0xaf>
    n = ip->size - off;
80101f81:	8b 45 08             	mov    0x8(%ebp),%eax
80101f84:	8b 40 58             	mov    0x58(%eax),%eax
80101f87:	2b 45 10             	sub    0x10(%ebp),%eax
80101f8a:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f8d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f94:	e9 89 00 00 00       	jmp    80102022 <readi+0x144>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f99:	8b 45 10             	mov    0x10(%ebp),%eax
80101f9c:	c1 e8 09             	shr    $0x9,%eax
80101f9f:	83 ec 08             	sub    $0x8,%esp
80101fa2:	50                   	push   %eax
80101fa3:	ff 75 08             	push   0x8(%ebp)
80101fa6:	e8 9d fc ff ff       	call   80101c48 <bmap>
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	8b 55 08             	mov    0x8(%ebp),%edx
80101fb1:	8b 12                	mov    (%edx),%edx
80101fb3:	83 ec 08             	sub    $0x8,%esp
80101fb6:	50                   	push   %eax
80101fb7:	52                   	push   %edx
80101fb8:	e8 44 e2 ff ff       	call   80100201 <bread>
80101fbd:	83 c4 10             	add    $0x10,%esp
80101fc0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fc3:	8b 45 10             	mov    0x10(%ebp),%eax
80101fc6:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcb:	ba 00 02 00 00       	mov    $0x200,%edx
80101fd0:	29 c2                	sub    %eax,%edx
80101fd2:	8b 45 14             	mov    0x14(%ebp),%eax
80101fd5:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fd8:	39 c2                	cmp    %eax,%edx
80101fda:	0f 46 c2             	cmovbe %edx,%eax
80101fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fe0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fe3:	8d 50 5c             	lea    0x5c(%eax),%edx
80101fe6:	8b 45 10             	mov    0x10(%ebp),%eax
80101fe9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fee:	01 d0                	add    %edx,%eax
80101ff0:	83 ec 04             	sub    $0x4,%esp
80101ff3:	ff 75 ec             	push   -0x14(%ebp)
80101ff6:	50                   	push   %eax
80101ff7:	ff 75 0c             	push   0xc(%ebp)
80101ffa:	e8 4c 2a 00 00       	call   80104a4b <memmove>
80101fff:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	ff 75 f0             	push   -0x10(%ebp)
80102008:	e8 76 e2 ff ff       	call   80100283 <brelse>
8010200d:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80102010:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102013:	01 45 f4             	add    %eax,-0xc(%ebp)
80102016:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102019:	01 45 10             	add    %eax,0x10(%ebp)
8010201c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010201f:	01 45 0c             	add    %eax,0xc(%ebp)
80102022:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102025:	3b 45 14             	cmp    0x14(%ebp),%eax
80102028:	0f 82 6b ff ff ff    	jb     80101f99 <readi+0xbb>
  }
  return n;
8010202e:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102031:	c9                   	leave
80102032:	c3                   	ret

80102033 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80102040:	66 83 f8 03          	cmp    $0x3,%ax
80102044:	75 5c                	jne    801020a2 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102046:	8b 45 08             	mov    0x8(%ebp),%eax
80102049:	0f b7 40 52          	movzwl 0x52(%eax),%eax
8010204d:	66 85 c0             	test   %ax,%ax
80102050:	78 20                	js     80102072 <writei+0x3f>
80102052:	8b 45 08             	mov    0x8(%ebp),%eax
80102055:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102059:	66 83 f8 09          	cmp    $0x9,%ax
8010205d:	7f 13                	jg     80102072 <writei+0x3f>
8010205f:	8b 45 08             	mov    0x8(%ebp),%eax
80102062:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102066:	98                   	cwtl
80102067:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010206e:	85 c0                	test   %eax,%eax
80102070:	75 0a                	jne    8010207c <writei+0x49>
      return -1;
80102072:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102077:	e9 3b 01 00 00       	jmp    801021b7 <writei+0x184>
    return devsw[ip->major].write(ip, src, n);
8010207c:	8b 45 08             	mov    0x8(%ebp),%eax
8010207f:	0f b7 40 52          	movzwl 0x52(%eax),%eax
80102083:	98                   	cwtl
80102084:	8b 04 c5 44 1a 19 80 	mov    -0x7fe6e5bc(,%eax,8),%eax
8010208b:	8b 55 14             	mov    0x14(%ebp),%edx
8010208e:	83 ec 04             	sub    $0x4,%esp
80102091:	52                   	push   %edx
80102092:	ff 75 0c             	push   0xc(%ebp)
80102095:	ff 75 08             	push   0x8(%ebp)
80102098:	ff d0                	call   *%eax
8010209a:	83 c4 10             	add    $0x10,%esp
8010209d:	e9 15 01 00 00       	jmp    801021b7 <writei+0x184>
  }

  if(off > ip->size || off + n < off)
801020a2:	8b 45 08             	mov    0x8(%ebp),%eax
801020a5:	8b 40 58             	mov    0x58(%eax),%eax
801020a8:	3b 45 10             	cmp    0x10(%ebp),%eax
801020ab:	72 0d                	jb     801020ba <writei+0x87>
801020ad:	8b 55 10             	mov    0x10(%ebp),%edx
801020b0:	8b 45 14             	mov    0x14(%ebp),%eax
801020b3:	01 d0                	add    %edx,%eax
801020b5:	3b 45 10             	cmp    0x10(%ebp),%eax
801020b8:	73 0a                	jae    801020c4 <writei+0x91>
    return -1;
801020ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020bf:	e9 f3 00 00 00       	jmp    801021b7 <writei+0x184>
  if(off + n > MAXFILE*BSIZE)
801020c4:	8b 55 10             	mov    0x10(%ebp),%edx
801020c7:	8b 45 14             	mov    0x14(%ebp),%eax
801020ca:	01 d0                	add    %edx,%eax
801020cc:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020d1:	76 0a                	jbe    801020dd <writei+0xaa>
    return -1;
801020d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020d8:	e9 da 00 00 00       	jmp    801021b7 <writei+0x184>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020dd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020e4:	e9 97 00 00 00       	jmp    80102180 <writei+0x14d>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020e9:	8b 45 10             	mov    0x10(%ebp),%eax
801020ec:	c1 e8 09             	shr    $0x9,%eax
801020ef:	83 ec 08             	sub    $0x8,%esp
801020f2:	50                   	push   %eax
801020f3:	ff 75 08             	push   0x8(%ebp)
801020f6:	e8 4d fb ff ff       	call   80101c48 <bmap>
801020fb:	83 c4 10             	add    $0x10,%esp
801020fe:	8b 55 08             	mov    0x8(%ebp),%edx
80102101:	8b 12                	mov    (%edx),%edx
80102103:	83 ec 08             	sub    $0x8,%esp
80102106:	50                   	push   %eax
80102107:	52                   	push   %edx
80102108:	e8 f4 e0 ff ff       	call   80100201 <bread>
8010210d:	83 c4 10             	add    $0x10,%esp
80102110:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80102113:	8b 45 10             	mov    0x10(%ebp),%eax
80102116:	25 ff 01 00 00       	and    $0x1ff,%eax
8010211b:	ba 00 02 00 00       	mov    $0x200,%edx
80102120:	29 c2                	sub    %eax,%edx
80102122:	8b 45 14             	mov    0x14(%ebp),%eax
80102125:	2b 45 f4             	sub    -0xc(%ebp),%eax
80102128:	39 c2                	cmp    %eax,%edx
8010212a:	0f 46 c2             	cmovbe %edx,%eax
8010212d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102130:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102133:	8d 50 5c             	lea    0x5c(%eax),%edx
80102136:	8b 45 10             	mov    0x10(%ebp),%eax
80102139:	25 ff 01 00 00       	and    $0x1ff,%eax
8010213e:	01 d0                	add    %edx,%eax
80102140:	83 ec 04             	sub    $0x4,%esp
80102143:	ff 75 ec             	push   -0x14(%ebp)
80102146:	ff 75 0c             	push   0xc(%ebp)
80102149:	50                   	push   %eax
8010214a:	e8 fc 28 00 00       	call   80104a4b <memmove>
8010214f:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	ff 75 f0             	push   -0x10(%ebp)
80102158:	e8 1a 11 00 00       	call   80103277 <log_write>
8010215d:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102160:	83 ec 0c             	sub    $0xc,%esp
80102163:	ff 75 f0             	push   -0x10(%ebp)
80102166:	e8 18 e1 ff ff       	call   80100283 <brelse>
8010216b:	83 c4 10             	add    $0x10,%esp
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010216e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102171:	01 45 f4             	add    %eax,-0xc(%ebp)
80102174:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102177:	01 45 10             	add    %eax,0x10(%ebp)
8010217a:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010217d:	01 45 0c             	add    %eax,0xc(%ebp)
80102180:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102183:	3b 45 14             	cmp    0x14(%ebp),%eax
80102186:	0f 82 5d ff ff ff    	jb     801020e9 <writei+0xb6>
  }

  if(n > 0 && off > ip->size){
8010218c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102190:	74 22                	je     801021b4 <writei+0x181>
80102192:	8b 45 08             	mov    0x8(%ebp),%eax
80102195:	8b 40 58             	mov    0x58(%eax),%eax
80102198:	3b 45 10             	cmp    0x10(%ebp),%eax
8010219b:	73 17                	jae    801021b4 <writei+0x181>
    ip->size = off;
8010219d:	8b 45 08             	mov    0x8(%ebp),%eax
801021a0:	8b 55 10             	mov    0x10(%ebp),%edx
801021a3:	89 50 58             	mov    %edx,0x58(%eax)
    iupdate(ip);
801021a6:	83 ec 0c             	sub    $0xc,%esp
801021a9:	ff 75 08             	push   0x8(%ebp)
801021ac:	e8 64 f6 ff ff       	call   80101815 <iupdate>
801021b1:	83 c4 10             	add    $0x10,%esp
  }
  return n;
801021b4:	8b 45 14             	mov    0x14(%ebp),%eax
}
801021b7:	c9                   	leave
801021b8:	c3                   	ret

801021b9 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
801021b9:	55                   	push   %ebp
801021ba:	89 e5                	mov    %esp,%ebp
801021bc:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021bf:	83 ec 04             	sub    $0x4,%esp
801021c2:	6a 0e                	push   $0xe
801021c4:	ff 75 0c             	push   0xc(%ebp)
801021c7:	ff 75 08             	push   0x8(%ebp)
801021ca:	e8 12 29 00 00       	call   80104ae1 <strncmp>
801021cf:	83 c4 10             	add    $0x10,%esp
}
801021d2:	c9                   	leave
801021d3:	c3                   	ret

801021d4 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021d4:	55                   	push   %ebp
801021d5:	89 e5                	mov    %esp,%ebp
801021d7:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021da:	8b 45 08             	mov    0x8(%ebp),%eax
801021dd:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801021e1:	66 83 f8 01          	cmp    $0x1,%ax
801021e5:	74 0d                	je     801021f4 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021e7:	83 ec 0c             	sub    $0xc,%esp
801021ea:	68 bd a1 10 80       	push   $0x8010a1bd
801021ef:	e8 b5 e3 ff ff       	call   801005a9 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021f4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021fb:	eb 7b                	jmp    80102278 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021fd:	6a 10                	push   $0x10
801021ff:	ff 75 f4             	push   -0xc(%ebp)
80102202:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102205:	50                   	push   %eax
80102206:	ff 75 08             	push   0x8(%ebp)
80102209:	e8 d0 fc ff ff       	call   80101ede <readi>
8010220e:	83 c4 10             	add    $0x10,%esp
80102211:	83 f8 10             	cmp    $0x10,%eax
80102214:	74 0d                	je     80102223 <dirlookup+0x4f>
      panic("dirlookup read");
80102216:	83 ec 0c             	sub    $0xc,%esp
80102219:	68 cf a1 10 80       	push   $0x8010a1cf
8010221e:	e8 86 e3 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
80102223:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102227:	66 85 c0             	test   %ax,%ax
8010222a:	74 47                	je     80102273 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010222c:	83 ec 08             	sub    $0x8,%esp
8010222f:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102232:	83 c0 02             	add    $0x2,%eax
80102235:	50                   	push   %eax
80102236:	ff 75 0c             	push   0xc(%ebp)
80102239:	e8 7b ff ff ff       	call   801021b9 <namecmp>
8010223e:	83 c4 10             	add    $0x10,%esp
80102241:	85 c0                	test   %eax,%eax
80102243:	75 2f                	jne    80102274 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102245:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80102249:	74 08                	je     80102253 <dirlookup+0x7f>
        *poff = off;
8010224b:	8b 45 10             	mov    0x10(%ebp),%eax
8010224e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102251:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102253:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102257:	0f b7 c0             	movzwl %ax,%eax
8010225a:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
8010225d:	8b 45 08             	mov    0x8(%ebp),%eax
80102260:	8b 00                	mov    (%eax),%eax
80102262:	83 ec 08             	sub    $0x8,%esp
80102265:	ff 75 f0             	push   -0x10(%ebp)
80102268:	50                   	push   %eax
80102269:	e8 68 f6 ff ff       	call   801018d6 <iget>
8010226e:	83 c4 10             	add    $0x10,%esp
80102271:	eb 19                	jmp    8010228c <dirlookup+0xb8>
      continue;
80102273:	90                   	nop
  for(off = 0; off < dp->size; off += sizeof(de)){
80102274:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102278:	8b 45 08             	mov    0x8(%ebp),%eax
8010227b:	8b 40 58             	mov    0x58(%eax),%eax
8010227e:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102281:	0f 82 76 ff ff ff    	jb     801021fd <dirlookup+0x29>
    }
  }

  return 0;
80102287:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010228c:	c9                   	leave
8010228d:	c3                   	ret

8010228e <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
8010228e:	55                   	push   %ebp
8010228f:	89 e5                	mov    %esp,%ebp
80102291:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102294:	83 ec 04             	sub    $0x4,%esp
80102297:	6a 00                	push   $0x0
80102299:	ff 75 0c             	push   0xc(%ebp)
8010229c:	ff 75 08             	push   0x8(%ebp)
8010229f:	e8 30 ff ff ff       	call   801021d4 <dirlookup>
801022a4:	83 c4 10             	add    $0x10,%esp
801022a7:	89 45 f0             	mov    %eax,-0x10(%ebp)
801022aa:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801022ae:	74 18                	je     801022c8 <dirlink+0x3a>
    iput(ip);
801022b0:	83 ec 0c             	sub    $0xc,%esp
801022b3:	ff 75 f0             	push   -0x10(%ebp)
801022b6:	e8 98 f8 ff ff       	call   80101b53 <iput>
801022bb:	83 c4 10             	add    $0x10,%esp
    return -1;
801022be:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022c3:	e9 9c 00 00 00       	jmp    80102364 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022c8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022cf:	eb 39                	jmp    8010230a <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	push   0x8(%ebp)
801022de:	e8 fb fb ff ff       	call   80101ede <readi>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0x6a>
      panic("dirlink read");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 de a1 10 80       	push   $0x8010a1de
801022f3:	e8 b1 e2 ff ff       	call   801005a9 <panic>
    if(de.inum == 0)
801022f8:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022fc:	66 85 c0             	test   %ax,%ax
801022ff:	74 18                	je     80102319 <dirlink+0x8b>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102301:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102304:	83 c0 10             	add    $0x10,%eax
80102307:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010230a:	8b 45 08             	mov    0x8(%ebp),%eax
8010230d:	8b 40 58             	mov    0x58(%eax),%eax
80102310:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102313:	39 c2                	cmp    %eax,%edx
80102315:	72 ba                	jb     801022d1 <dirlink+0x43>
80102317:	eb 01                	jmp    8010231a <dirlink+0x8c>
      break;
80102319:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
8010231a:	83 ec 04             	sub    $0x4,%esp
8010231d:	6a 0e                	push   $0xe
8010231f:	ff 75 0c             	push   0xc(%ebp)
80102322:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102325:	83 c0 02             	add    $0x2,%eax
80102328:	50                   	push   %eax
80102329:	e8 09 28 00 00       	call   80104b37 <strncpy>
8010232e:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102331:	8b 45 10             	mov    0x10(%ebp),%eax
80102334:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102338:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010233b:	6a 10                	push   $0x10
8010233d:	50                   	push   %eax
8010233e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102341:	50                   	push   %eax
80102342:	ff 75 08             	push   0x8(%ebp)
80102345:	e8 e9 fc ff ff       	call   80102033 <writei>
8010234a:	83 c4 10             	add    $0x10,%esp
8010234d:	83 f8 10             	cmp    $0x10,%eax
80102350:	74 0d                	je     8010235f <dirlink+0xd1>
    panic("dirlink");
80102352:	83 ec 0c             	sub    $0xc,%esp
80102355:	68 eb a1 10 80       	push   $0x8010a1eb
8010235a:	e8 4a e2 ff ff       	call   801005a9 <panic>

  return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102364:	c9                   	leave
80102365:	c3                   	ret

80102366 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
80102369:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010236c:	eb 04                	jmp    80102372 <skipelem+0xc>
    path++;
8010236e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
80102372:	8b 45 08             	mov    0x8(%ebp),%eax
80102375:	0f b6 00             	movzbl (%eax),%eax
80102378:	3c 2f                	cmp    $0x2f,%al
8010237a:	74 f2                	je     8010236e <skipelem+0x8>
  if(*path == 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	84 c0                	test   %al,%al
80102384:	75 07                	jne    8010238d <skipelem+0x27>
    return 0;
80102386:	b8 00 00 00 00       	mov    $0x0,%eax
8010238b:	eb 77                	jmp    80102404 <skipelem+0x9e>
  s = path;
8010238d:	8b 45 08             	mov    0x8(%ebp),%eax
80102390:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102393:	eb 04                	jmp    80102399 <skipelem+0x33>
    path++;
80102395:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path != '/' && *path != 0)
80102399:	8b 45 08             	mov    0x8(%ebp),%eax
8010239c:	0f b6 00             	movzbl (%eax),%eax
8010239f:	3c 2f                	cmp    $0x2f,%al
801023a1:	74 0a                	je     801023ad <skipelem+0x47>
801023a3:	8b 45 08             	mov    0x8(%ebp),%eax
801023a6:	0f b6 00             	movzbl (%eax),%eax
801023a9:	84 c0                	test   %al,%al
801023ab:	75 e8                	jne    80102395 <skipelem+0x2f>
  len = path - s;
801023ad:	8b 45 08             	mov    0x8(%ebp),%eax
801023b0:	2b 45 f4             	sub    -0xc(%ebp),%eax
801023b3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
801023b6:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023ba:	7e 15                	jle    801023d1 <skipelem+0x6b>
    memmove(name, s, DIRSIZ);
801023bc:	83 ec 04             	sub    $0x4,%esp
801023bf:	6a 0e                	push   $0xe
801023c1:	ff 75 f4             	push   -0xc(%ebp)
801023c4:	ff 75 0c             	push   0xc(%ebp)
801023c7:	e8 7f 26 00 00       	call   80104a4b <memmove>
801023cc:	83 c4 10             	add    $0x10,%esp
801023cf:	eb 26                	jmp    801023f7 <skipelem+0x91>
  else {
    memmove(name, s, len);
801023d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023d4:	83 ec 04             	sub    $0x4,%esp
801023d7:	50                   	push   %eax
801023d8:	ff 75 f4             	push   -0xc(%ebp)
801023db:	ff 75 0c             	push   0xc(%ebp)
801023de:	e8 68 26 00 00       	call   80104a4b <memmove>
801023e3:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023e6:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023e9:	8b 45 0c             	mov    0xc(%ebp),%eax
801023ec:	01 d0                	add    %edx,%eax
801023ee:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023f1:	eb 04                	jmp    801023f7 <skipelem+0x91>
    path++;
801023f3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
801023f7:	8b 45 08             	mov    0x8(%ebp),%eax
801023fa:	0f b6 00             	movzbl (%eax),%eax
801023fd:	3c 2f                	cmp    $0x2f,%al
801023ff:	74 f2                	je     801023f3 <skipelem+0x8d>
  return path;
80102401:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102404:	c9                   	leave
80102405:	c3                   	ret

80102406 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80102406:	55                   	push   %ebp
80102407:	89 e5                	mov    %esp,%ebp
80102409:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
8010240c:	8b 45 08             	mov    0x8(%ebp),%eax
8010240f:	0f b6 00             	movzbl (%eax),%eax
80102412:	3c 2f                	cmp    $0x2f,%al
80102414:	75 17                	jne    8010242d <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
80102416:	83 ec 08             	sub    $0x8,%esp
80102419:	6a 01                	push   $0x1
8010241b:	6a 01                	push   $0x1
8010241d:	e8 b4 f4 ff ff       	call   801018d6 <iget>
80102422:	83 c4 10             	add    $0x10,%esp
80102425:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102428:	e9 ba 00 00 00       	jmp    801024e7 <namex+0xe1>
  else
    ip = idup(myproc()->cwd);
8010242d:	e8 fe 15 00 00       	call   80103a30 <myproc>
80102432:	8b 40 68             	mov    0x68(%eax),%eax
80102435:	83 ec 0c             	sub    $0xc,%esp
80102438:	50                   	push   %eax
80102439:	e8 7a f5 ff ff       	call   801019b8 <idup>
8010243e:	83 c4 10             	add    $0x10,%esp
80102441:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
80102444:	e9 9e 00 00 00       	jmp    801024e7 <namex+0xe1>
    ilock(ip);
80102449:	83 ec 0c             	sub    $0xc,%esp
8010244c:	ff 75 f4             	push   -0xc(%ebp)
8010244f:	e8 9e f5 ff ff       	call   801019f2 <ilock>
80102454:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
80102457:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010245a:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010245e:	66 83 f8 01          	cmp    $0x1,%ax
80102462:	74 18                	je     8010247c <namex+0x76>
      iunlockput(ip);
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	ff 75 f4             	push   -0xc(%ebp)
8010246a:	e8 b4 f7 ff ff       	call   80101c23 <iunlockput>
8010246f:	83 c4 10             	add    $0x10,%esp
      return 0;
80102472:	b8 00 00 00 00       	mov    $0x0,%eax
80102477:	e9 a7 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if(nameiparent && *path == '\0'){
8010247c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102480:	74 20                	je     801024a2 <namex+0x9c>
80102482:	8b 45 08             	mov    0x8(%ebp),%eax
80102485:	0f b6 00             	movzbl (%eax),%eax
80102488:	84 c0                	test   %al,%al
8010248a:	75 16                	jne    801024a2 <namex+0x9c>
      // Stop one level early.
      iunlock(ip);
8010248c:	83 ec 0c             	sub    $0xc,%esp
8010248f:	ff 75 f4             	push   -0xc(%ebp)
80102492:	e8 6e f6 ff ff       	call   80101b05 <iunlock>
80102497:	83 c4 10             	add    $0x10,%esp
      return ip;
8010249a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010249d:	e9 81 00 00 00       	jmp    80102523 <namex+0x11d>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
801024a2:	83 ec 04             	sub    $0x4,%esp
801024a5:	6a 00                	push   $0x0
801024a7:	ff 75 10             	push   0x10(%ebp)
801024aa:	ff 75 f4             	push   -0xc(%ebp)
801024ad:	e8 22 fd ff ff       	call   801021d4 <dirlookup>
801024b2:	83 c4 10             	add    $0x10,%esp
801024b5:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024b8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024bc:	75 15                	jne    801024d3 <namex+0xcd>
      iunlockput(ip);
801024be:	83 ec 0c             	sub    $0xc,%esp
801024c1:	ff 75 f4             	push   -0xc(%ebp)
801024c4:	e8 5a f7 ff ff       	call   80101c23 <iunlockput>
801024c9:	83 c4 10             	add    $0x10,%esp
      return 0;
801024cc:	b8 00 00 00 00       	mov    $0x0,%eax
801024d1:	eb 50                	jmp    80102523 <namex+0x11d>
    }
    iunlockput(ip);
801024d3:	83 ec 0c             	sub    $0xc,%esp
801024d6:	ff 75 f4             	push   -0xc(%ebp)
801024d9:	e8 45 f7 ff ff       	call   80101c23 <iunlockput>
801024de:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024e4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while((path = skipelem(path, name)) != 0){
801024e7:	83 ec 08             	sub    $0x8,%esp
801024ea:	ff 75 10             	push   0x10(%ebp)
801024ed:	ff 75 08             	push   0x8(%ebp)
801024f0:	e8 71 fe ff ff       	call   80102366 <skipelem>
801024f5:	83 c4 10             	add    $0x10,%esp
801024f8:	89 45 08             	mov    %eax,0x8(%ebp)
801024fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024ff:	0f 85 44 ff ff ff    	jne    80102449 <namex+0x43>
  }
  if(nameiparent){
80102505:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102509:	74 15                	je     80102520 <namex+0x11a>
    iput(ip);
8010250b:	83 ec 0c             	sub    $0xc,%esp
8010250e:	ff 75 f4             	push   -0xc(%ebp)
80102511:	e8 3d f6 ff ff       	call   80101b53 <iput>
80102516:	83 c4 10             	add    $0x10,%esp
    return 0;
80102519:	b8 00 00 00 00       	mov    $0x0,%eax
8010251e:	eb 03                	jmp    80102523 <namex+0x11d>
  }
  return ip;
80102520:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102523:	c9                   	leave
80102524:	c3                   	ret

80102525 <namei>:

struct inode*
namei(char *path)
{
80102525:	55                   	push   %ebp
80102526:	89 e5                	mov    %esp,%ebp
80102528:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
8010252b:	83 ec 04             	sub    $0x4,%esp
8010252e:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102531:	50                   	push   %eax
80102532:	6a 00                	push   $0x0
80102534:	ff 75 08             	push   0x8(%ebp)
80102537:	e8 ca fe ff ff       	call   80102406 <namex>
8010253c:	83 c4 10             	add    $0x10,%esp
}
8010253f:	c9                   	leave
80102540:	c3                   	ret

80102541 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102541:	55                   	push   %ebp
80102542:	89 e5                	mov    %esp,%ebp
80102544:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80102547:	83 ec 04             	sub    $0x4,%esp
8010254a:	ff 75 0c             	push   0xc(%ebp)
8010254d:	6a 01                	push   $0x1
8010254f:	ff 75 08             	push   0x8(%ebp)
80102552:	e8 af fe ff ff       	call   80102406 <namex>
80102557:	83 c4 10             	add    $0x10,%esp
}
8010255a:	c9                   	leave
8010255b:	c3                   	ret

8010255c <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010255f:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102564:	8b 55 08             	mov    0x8(%ebp),%edx
80102567:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
80102569:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010256e:	8b 40 10             	mov    0x10(%eax),%eax
}
80102571:	5d                   	pop    %ebp
80102572:	c3                   	ret

80102573 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102573:	55                   	push   %ebp
80102574:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102576:	a1 b4 40 19 80       	mov    0x801940b4,%eax
8010257b:	8b 55 08             	mov    0x8(%ebp),%edx
8010257e:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102580:	a1 b4 40 19 80       	mov    0x801940b4,%eax
80102585:	8b 55 0c             	mov    0xc(%ebp),%edx
80102588:	89 50 10             	mov    %edx,0x10(%eax)
}
8010258b:	90                   	nop
8010258c:	5d                   	pop    %ebp
8010258d:	c3                   	ret

8010258e <ioapicinit>:

void
ioapicinit(void)
{
8010258e:	55                   	push   %ebp
8010258f:	89 e5                	mov    %esp,%ebp
80102591:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102594:	c7 05 b4 40 19 80 00 	movl   $0xfec00000,0x801940b4
8010259b:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
8010259e:	6a 01                	push   $0x1
801025a0:	e8 b7 ff ff ff       	call   8010255c <ioapicread>
801025a5:	83 c4 04             	add    $0x4,%esp
801025a8:	c1 e8 10             	shr    $0x10,%eax
801025ab:	25 ff 00 00 00       	and    $0xff,%eax
801025b0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801025b3:	6a 00                	push   $0x0
801025b5:	e8 a2 ff ff ff       	call   8010255c <ioapicread>
801025ba:	83 c4 04             	add    $0x4,%esp
801025bd:	c1 e8 18             	shr    $0x18,%eax
801025c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801025c3:	0f b6 05 44 6d 19 80 	movzbl 0x80196d44,%eax
801025ca:	0f b6 c0             	movzbl %al,%eax
801025cd:	39 45 ec             	cmp    %eax,-0x14(%ebp)
801025d0:	74 10                	je     801025e2 <ioapicinit+0x54>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801025d2:	83 ec 0c             	sub    $0xc,%esp
801025d5:	68 f4 a1 10 80       	push   $0x8010a1f4
801025da:	e8 15 de ff ff       	call   801003f4 <cprintf>
801025df:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801025e2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801025e9:	eb 3f                	jmp    8010262a <ioapicinit+0x9c>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801025eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025ee:	83 c0 20             	add    $0x20,%eax
801025f1:	0d 00 00 01 00       	or     $0x10000,%eax
801025f6:	89 c2                	mov    %eax,%edx
801025f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801025fb:	83 c0 08             	add    $0x8,%eax
801025fe:	01 c0                	add    %eax,%eax
80102600:	83 ec 08             	sub    $0x8,%esp
80102603:	52                   	push   %edx
80102604:	50                   	push   %eax
80102605:	e8 69 ff ff ff       	call   80102573 <ioapicwrite>
8010260a:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
8010260d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102610:	83 c0 08             	add    $0x8,%eax
80102613:	01 c0                	add    %eax,%eax
80102615:	83 c0 01             	add    $0x1,%eax
80102618:	83 ec 08             	sub    $0x8,%esp
8010261b:	6a 00                	push   $0x0
8010261d:	50                   	push   %eax
8010261e:	e8 50 ff ff ff       	call   80102573 <ioapicwrite>
80102623:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i <= maxintr; i++){
80102626:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010262a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010262d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102630:	7e b9                	jle    801025eb <ioapicinit+0x5d>
  }
}
80102632:	90                   	nop
80102633:	90                   	nop
80102634:	c9                   	leave
80102635:	c3                   	ret

80102636 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102636:	55                   	push   %ebp
80102637:	89 e5                	mov    %esp,%ebp
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102639:	8b 45 08             	mov    0x8(%ebp),%eax
8010263c:	83 c0 20             	add    $0x20,%eax
8010263f:	89 c2                	mov    %eax,%edx
80102641:	8b 45 08             	mov    0x8(%ebp),%eax
80102644:	83 c0 08             	add    $0x8,%eax
80102647:	01 c0                	add    %eax,%eax
80102649:	52                   	push   %edx
8010264a:	50                   	push   %eax
8010264b:	e8 23 ff ff ff       	call   80102573 <ioapicwrite>
80102650:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102653:	8b 45 0c             	mov    0xc(%ebp),%eax
80102656:	c1 e0 18             	shl    $0x18,%eax
80102659:	89 c2                	mov    %eax,%edx
8010265b:	8b 45 08             	mov    0x8(%ebp),%eax
8010265e:	83 c0 08             	add    $0x8,%eax
80102661:	01 c0                	add    %eax,%eax
80102663:	83 c0 01             	add    $0x1,%eax
80102666:	52                   	push   %edx
80102667:	50                   	push   %eax
80102668:	e8 06 ff ff ff       	call   80102573 <ioapicwrite>
8010266d:	83 c4 08             	add    $0x8,%esp
}
80102670:	90                   	nop
80102671:	c9                   	leave
80102672:	c3                   	ret

80102673 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102673:	55                   	push   %ebp
80102674:	89 e5                	mov    %esp,%ebp
80102676:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102679:	83 ec 08             	sub    $0x8,%esp
8010267c:	68 26 a2 10 80       	push   $0x8010a226
80102681:	68 c0 40 19 80       	push   $0x801940c0
80102686:	e8 69 20 00 00       	call   801046f4 <initlock>
8010268b:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
8010268e:	c7 05 f4 40 19 80 00 	movl   $0x0,0x801940f4
80102695:	00 00 00 
  freerange(vstart, vend);
80102698:	83 ec 08             	sub    $0x8,%esp
8010269b:	ff 75 0c             	push   0xc(%ebp)
8010269e:	ff 75 08             	push   0x8(%ebp)
801026a1:	e8 2a 00 00 00       	call   801026d0 <freerange>
801026a6:	83 c4 10             	add    $0x10,%esp
}
801026a9:	90                   	nop
801026aa:	c9                   	leave
801026ab:	c3                   	ret

801026ac <kinit2>:

void
kinit2(void *vstart, void *vend)
{
801026ac:	55                   	push   %ebp
801026ad:	89 e5                	mov    %esp,%ebp
801026af:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
801026b2:	83 ec 08             	sub    $0x8,%esp
801026b5:	ff 75 0c             	push   0xc(%ebp)
801026b8:	ff 75 08             	push   0x8(%ebp)
801026bb:	e8 10 00 00 00       	call   801026d0 <freerange>
801026c0:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
801026c3:	c7 05 f4 40 19 80 01 	movl   $0x1,0x801940f4
801026ca:	00 00 00 
}
801026cd:	90                   	nop
801026ce:	c9                   	leave
801026cf:	c3                   	ret

801026d0 <freerange>:

void
freerange(void *vstart, void *vend)
{
801026d0:	55                   	push   %ebp
801026d1:	89 e5                	mov    %esp,%ebp
801026d3:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
801026d6:	8b 45 08             	mov    0x8(%ebp),%eax
801026d9:	05 ff 0f 00 00       	add    $0xfff,%eax
801026de:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801026e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e6:	eb 15                	jmp    801026fd <freerange+0x2d>
    kfree(p);
801026e8:	83 ec 0c             	sub    $0xc,%esp
801026eb:	ff 75 f4             	push   -0xc(%ebp)
801026ee:	e8 1b 00 00 00       	call   8010270e <kfree>
801026f3:	83 c4 10             	add    $0x10,%esp
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026f6:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801026fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102700:	05 00 10 00 00       	add    $0x1000,%eax
80102705:	39 45 0c             	cmp    %eax,0xc(%ebp)
80102708:	73 de                	jae    801026e8 <freerange+0x18>
}
8010270a:	90                   	nop
8010270b:	90                   	nop
8010270c:	c9                   	leave
8010270d:	c3                   	ret

8010270e <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
8010270e:	55                   	push   %ebp
8010270f:	89 e5                	mov    %esp,%ebp
80102711:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102714:	8b 45 08             	mov    0x8(%ebp),%eax
80102717:	25 ff 0f 00 00       	and    $0xfff,%eax
8010271c:	85 c0                	test   %eax,%eax
8010271e:	75 18                	jne    80102738 <kfree+0x2a>
80102720:	81 7d 08 00 90 19 80 	cmpl   $0x80199000,0x8(%ebp)
80102727:	72 0f                	jb     80102738 <kfree+0x2a>
80102729:	8b 45 08             	mov    0x8(%ebp),%eax
8010272c:	05 00 00 00 80       	add    $0x80000000,%eax
80102731:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
80102736:	76 0d                	jbe    80102745 <kfree+0x37>
    panic("kfree");
80102738:	83 ec 0c             	sub    $0xc,%esp
8010273b:	68 2b a2 10 80       	push   $0x8010a22b
80102740:	e8 64 de ff ff       	call   801005a9 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102745:	83 ec 04             	sub    $0x4,%esp
80102748:	68 00 10 00 00       	push   $0x1000
8010274d:	6a 01                	push   $0x1
8010274f:	ff 75 08             	push   0x8(%ebp)
80102752:	e8 35 22 00 00       	call   8010498c <memset>
80102757:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
8010275a:	a1 f4 40 19 80       	mov    0x801940f4,%eax
8010275f:	85 c0                	test   %eax,%eax
80102761:	74 10                	je     80102773 <kfree+0x65>
    acquire(&kmem.lock);
80102763:	83 ec 0c             	sub    $0xc,%esp
80102766:	68 c0 40 19 80       	push   $0x801940c0
8010276b:	e8 a6 1f 00 00       	call   80104716 <acquire>
80102770:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102773:	8b 45 08             	mov    0x8(%ebp),%eax
80102776:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102779:	8b 15 f8 40 19 80    	mov    0x801940f8,%edx
8010277f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102782:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102787:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
8010278c:	a1 f4 40 19 80       	mov    0x801940f4,%eax
80102791:	85 c0                	test   %eax,%eax
80102793:	74 10                	je     801027a5 <kfree+0x97>
    release(&kmem.lock);
80102795:	83 ec 0c             	sub    $0xc,%esp
80102798:	68 c0 40 19 80       	push   $0x801940c0
8010279d:	e8 e2 1f 00 00       	call   80104784 <release>
801027a2:	83 c4 10             	add    $0x10,%esp
}
801027a5:	90                   	nop
801027a6:	c9                   	leave
801027a7:	c3                   	ret

801027a8 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801027a8:	55                   	push   %ebp
801027a9:	89 e5                	mov    %esp,%ebp
801027ab:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
801027ae:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027b3:	85 c0                	test   %eax,%eax
801027b5:	74 10                	je     801027c7 <kalloc+0x1f>
    acquire(&kmem.lock);
801027b7:	83 ec 0c             	sub    $0xc,%esp
801027ba:	68 c0 40 19 80       	push   $0x801940c0
801027bf:	e8 52 1f 00 00       	call   80104716 <acquire>
801027c4:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
801027c7:	a1 f8 40 19 80       	mov    0x801940f8,%eax
801027cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
801027cf:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027d3:	74 0a                	je     801027df <kalloc+0x37>
    kmem.freelist = r->next;
801027d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d8:	8b 00                	mov    (%eax),%eax
801027da:	a3 f8 40 19 80       	mov    %eax,0x801940f8
  if(kmem.use_lock)
801027df:	a1 f4 40 19 80       	mov    0x801940f4,%eax
801027e4:	85 c0                	test   %eax,%eax
801027e6:	74 10                	je     801027f8 <kalloc+0x50>
    release(&kmem.lock);
801027e8:	83 ec 0c             	sub    $0xc,%esp
801027eb:	68 c0 40 19 80       	push   $0x801940c0
801027f0:	e8 8f 1f 00 00       	call   80104784 <release>
801027f5:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801027fb:	c9                   	leave
801027fc:	c3                   	ret

801027fd <inb>:
{
801027fd:	55                   	push   %ebp
801027fe:	89 e5                	mov    %esp,%ebp
80102800:	83 ec 14             	sub    $0x14,%esp
80102803:	8b 45 08             	mov    0x8(%ebp),%eax
80102806:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010280a:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010280e:	89 c2                	mov    %eax,%edx
80102810:	ec                   	in     (%dx),%al
80102811:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102814:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102818:	c9                   	leave
80102819:	c3                   	ret

8010281a <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010281a:	55                   	push   %ebp
8010281b:	89 e5                	mov    %esp,%ebp
8010281d:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102820:	6a 64                	push   $0x64
80102822:	e8 d6 ff ff ff       	call   801027fd <inb>
80102827:	83 c4 04             	add    $0x4,%esp
8010282a:	0f b6 c0             	movzbl %al,%eax
8010282d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102830:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102833:	83 e0 01             	and    $0x1,%eax
80102836:	85 c0                	test   %eax,%eax
80102838:	75 0a                	jne    80102844 <kbdgetc+0x2a>
    return -1;
8010283a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010283f:	e9 23 01 00 00       	jmp    80102967 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102844:	6a 60                	push   $0x60
80102846:	e8 b2 ff ff ff       	call   801027fd <inb>
8010284b:	83 c4 04             	add    $0x4,%esp
8010284e:	0f b6 c0             	movzbl %al,%eax
80102851:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102854:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
8010285b:	75 17                	jne    80102874 <kbdgetc+0x5a>
    shift |= E0ESC;
8010285d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102862:	83 c8 40             	or     $0x40,%eax
80102865:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
8010286a:	b8 00 00 00 00       	mov    $0x0,%eax
8010286f:	e9 f3 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102874:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102877:	25 80 00 00 00       	and    $0x80,%eax
8010287c:	85 c0                	test   %eax,%eax
8010287e:	74 45                	je     801028c5 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102880:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102885:	83 e0 40             	and    $0x40,%eax
80102888:	85 c0                	test   %eax,%eax
8010288a:	75 08                	jne    80102894 <kbdgetc+0x7a>
8010288c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010288f:	83 e0 7f             	and    $0x7f,%eax
80102892:	eb 03                	jmp    80102897 <kbdgetc+0x7d>
80102894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102897:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
8010289a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010289d:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028a2:	0f b6 00             	movzbl (%eax),%eax
801028a5:	83 c8 40             	or     $0x40,%eax
801028a8:	0f b6 c0             	movzbl %al,%eax
801028ab:	f7 d0                	not    %eax
801028ad:	89 c2                	mov    %eax,%edx
801028af:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028b4:	21 d0                	and    %edx,%eax
801028b6:	a3 fc 40 19 80       	mov    %eax,0x801940fc
    return 0;
801028bb:	b8 00 00 00 00       	mov    $0x0,%eax
801028c0:	e9 a2 00 00 00       	jmp    80102967 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
801028c5:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028ca:	83 e0 40             	and    $0x40,%eax
801028cd:	85 c0                	test   %eax,%eax
801028cf:	74 14                	je     801028e5 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028d1:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
801028d8:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028dd:	83 e0 bf             	and    $0xffffffbf,%eax
801028e0:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  }

  shift |= shiftcode[data];
801028e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
801028e8:	05 20 d0 10 80       	add    $0x8010d020,%eax
801028ed:	0f b6 00             	movzbl (%eax),%eax
801028f0:	0f b6 d0             	movzbl %al,%edx
801028f3:	a1 fc 40 19 80       	mov    0x801940fc,%eax
801028f8:	09 d0                	or     %edx,%eax
801028fa:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  shift ^= togglecode[data];
801028ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102902:	05 20 d1 10 80       	add    $0x8010d120,%eax
80102907:	0f b6 00             	movzbl (%eax),%eax
8010290a:	0f b6 d0             	movzbl %al,%edx
8010290d:	a1 fc 40 19 80       	mov    0x801940fc,%eax
80102912:	31 d0                	xor    %edx,%eax
80102914:	a3 fc 40 19 80       	mov    %eax,0x801940fc
  c = charcode[shift & (CTL | SHIFT)][data];
80102919:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010291e:	83 e0 03             	and    $0x3,%eax
80102921:	8b 14 85 20 d5 10 80 	mov    -0x7fef2ae0(,%eax,4),%edx
80102928:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010292b:	01 d0                	add    %edx,%eax
8010292d:	0f b6 00             	movzbl (%eax),%eax
80102930:	0f b6 c0             	movzbl %al,%eax
80102933:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102936:	a1 fc 40 19 80       	mov    0x801940fc,%eax
8010293b:	83 e0 08             	and    $0x8,%eax
8010293e:	85 c0                	test   %eax,%eax
80102940:	74 22                	je     80102964 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102942:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102946:	76 0c                	jbe    80102954 <kbdgetc+0x13a>
80102948:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
8010294c:	77 06                	ja     80102954 <kbdgetc+0x13a>
      c += 'A' - 'a';
8010294e:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102952:	eb 10                	jmp    80102964 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102954:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102958:	76 0a                	jbe    80102964 <kbdgetc+0x14a>
8010295a:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
8010295e:	77 04                	ja     80102964 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102960:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102964:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102967:	c9                   	leave
80102968:	c3                   	ret

80102969 <kbdintr>:

void
kbdintr(void)
{
80102969:	55                   	push   %ebp
8010296a:	89 e5                	mov    %esp,%ebp
8010296c:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
8010296f:	83 ec 0c             	sub    $0xc,%esp
80102972:	68 1a 28 10 80       	push   $0x8010281a
80102977:	e8 5a de ff ff       	call   801007d6 <consoleintr>
8010297c:	83 c4 10             	add    $0x10,%esp
}
8010297f:	90                   	nop
80102980:	c9                   	leave
80102981:	c3                   	ret

80102982 <inb>:
{
80102982:	55                   	push   %ebp
80102983:	89 e5                	mov    %esp,%ebp
80102985:	83 ec 14             	sub    $0x14,%esp
80102988:	8b 45 08             	mov    0x8(%ebp),%eax
8010298b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010298f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102993:	89 c2                	mov    %eax,%edx
80102995:	ec                   	in     (%dx),%al
80102996:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102999:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010299d:	c9                   	leave
8010299e:	c3                   	ret

8010299f <outb>:
{
8010299f:	55                   	push   %ebp
801029a0:	89 e5                	mov    %esp,%ebp
801029a2:	83 ec 08             	sub    $0x8,%esp
801029a5:	8b 55 08             	mov    0x8(%ebp),%edx
801029a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801029ab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801029af:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029b2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801029b6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801029ba:	ee                   	out    %al,(%dx)
}
801029bb:	90                   	nop
801029bc:	c9                   	leave
801029bd:	c3                   	ret

801029be <lapicw>:
volatile uint *lapic;  // Initialized in mp.c

//PAGEBREAK!
static void
lapicw(int index, int value)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801029c1:	a1 00 41 19 80       	mov    0x80194100,%eax
801029c6:	8b 55 08             	mov    0x8(%ebp),%edx
801029c9:	c1 e2 02             	shl    $0x2,%edx
801029cc:	01 c2                	add    %eax,%edx
801029ce:	8b 45 0c             	mov    0xc(%ebp),%eax
801029d1:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
801029d3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029d8:	83 c0 20             	add    $0x20,%eax
801029db:	8b 00                	mov    (%eax),%eax
}
801029dd:	90                   	nop
801029de:	5d                   	pop    %ebp
801029df:	c3                   	ret

801029e0 <lapicinit>:

void
lapicinit(void)
{
801029e0:	55                   	push   %ebp
801029e1:	89 e5                	mov    %esp,%ebp
  if(!lapic)
801029e3:	a1 00 41 19 80       	mov    0x80194100,%eax
801029e8:	85 c0                	test   %eax,%eax
801029ea:	0f 84 09 01 00 00    	je     80102af9 <lapicinit+0x119>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801029f0:	68 3f 01 00 00       	push   $0x13f
801029f5:	6a 3c                	push   $0x3c
801029f7:	e8 c2 ff ff ff       	call   801029be <lapicw>
801029fc:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
801029ff:	6a 0b                	push   $0xb
80102a01:	68 f8 00 00 00       	push   $0xf8
80102a06:	e8 b3 ff ff ff       	call   801029be <lapicw>
80102a0b:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102a0e:	68 20 00 02 00       	push   $0x20020
80102a13:	68 c8 00 00 00       	push   $0xc8
80102a18:	e8 a1 ff ff ff       	call   801029be <lapicw>
80102a1d:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000);
80102a20:	68 80 96 98 00       	push   $0x989680
80102a25:	68 e0 00 00 00       	push   $0xe0
80102a2a:	e8 8f ff ff ff       	call   801029be <lapicw>
80102a2f:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102a32:	68 00 00 01 00       	push   $0x10000
80102a37:	68 d4 00 00 00       	push   $0xd4
80102a3c:	e8 7d ff ff ff       	call   801029be <lapicw>
80102a41:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102a44:	68 00 00 01 00       	push   $0x10000
80102a49:	68 d8 00 00 00       	push   $0xd8
80102a4e:	e8 6b ff ff ff       	call   801029be <lapicw>
80102a53:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a56:	a1 00 41 19 80       	mov    0x80194100,%eax
80102a5b:	83 c0 30             	add    $0x30,%eax
80102a5e:	8b 00                	mov    (%eax),%eax
80102a60:	25 00 00 fc 00       	and    $0xfc0000,%eax
80102a65:	85 c0                	test   %eax,%eax
80102a67:	74 12                	je     80102a7b <lapicinit+0x9b>
    lapicw(PCINT, MASKED);
80102a69:	68 00 00 01 00       	push   $0x10000
80102a6e:	68 d0 00 00 00       	push   $0xd0
80102a73:	e8 46 ff ff ff       	call   801029be <lapicw>
80102a78:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102a7b:	6a 33                	push   $0x33
80102a7d:	68 dc 00 00 00       	push   $0xdc
80102a82:	e8 37 ff ff ff       	call   801029be <lapicw>
80102a87:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102a8a:	6a 00                	push   $0x0
80102a8c:	68 a0 00 00 00       	push   $0xa0
80102a91:	e8 28 ff ff ff       	call   801029be <lapicw>
80102a96:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102a99:	6a 00                	push   $0x0
80102a9b:	68 a0 00 00 00       	push   $0xa0
80102aa0:	e8 19 ff ff ff       	call   801029be <lapicw>
80102aa5:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102aa8:	6a 00                	push   $0x0
80102aaa:	6a 2c                	push   $0x2c
80102aac:	e8 0d ff ff ff       	call   801029be <lapicw>
80102ab1:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ab4:	6a 00                	push   $0x0
80102ab6:	68 c4 00 00 00       	push   $0xc4
80102abb:	e8 fe fe ff ff       	call   801029be <lapicw>
80102ac0:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ac3:	68 00 85 08 00       	push   $0x88500
80102ac8:	68 c0 00 00 00       	push   $0xc0
80102acd:	e8 ec fe ff ff       	call   801029be <lapicw>
80102ad2:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102ad5:	90                   	nop
80102ad6:	a1 00 41 19 80       	mov    0x80194100,%eax
80102adb:	05 00 03 00 00       	add    $0x300,%eax
80102ae0:	8b 00                	mov    (%eax),%eax
80102ae2:	25 00 10 00 00       	and    $0x1000,%eax
80102ae7:	85 c0                	test   %eax,%eax
80102ae9:	75 eb                	jne    80102ad6 <lapicinit+0xf6>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102aeb:	6a 00                	push   $0x0
80102aed:	6a 20                	push   $0x20
80102aef:	e8 ca fe ff ff       	call   801029be <lapicw>
80102af4:	83 c4 08             	add    $0x8,%esp
80102af7:	eb 01                	jmp    80102afa <lapicinit+0x11a>
    return;
80102af9:	90                   	nop
}
80102afa:	c9                   	leave
80102afb:	c3                   	ret

80102afc <lapicid>:

int
lapicid(void)
{
80102afc:	55                   	push   %ebp
80102afd:	89 e5                	mov    %esp,%ebp

  if (!lapic){
80102aff:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b04:	85 c0                	test   %eax,%eax
80102b06:	75 07                	jne    80102b0f <lapicid+0x13>
    return 0;
80102b08:	b8 00 00 00 00       	mov    $0x0,%eax
80102b0d:	eb 0d                	jmp    80102b1c <lapicid+0x20>
  }
  return lapic[ID] >> 24;
80102b0f:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b14:	83 c0 20             	add    $0x20,%eax
80102b17:	8b 00                	mov    (%eax),%eax
80102b19:	c1 e8 18             	shr    $0x18,%eax
}
80102b1c:	5d                   	pop    %ebp
80102b1d:	c3                   	ret

80102b1e <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102b1e:	55                   	push   %ebp
80102b1f:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102b21:	a1 00 41 19 80       	mov    0x80194100,%eax
80102b26:	85 c0                	test   %eax,%eax
80102b28:	74 0c                	je     80102b36 <lapiceoi+0x18>
    lapicw(EOI, 0);
80102b2a:	6a 00                	push   $0x0
80102b2c:	6a 2c                	push   $0x2c
80102b2e:	e8 8b fe ff ff       	call   801029be <lapicw>
80102b33:	83 c4 08             	add    $0x8,%esp
}
80102b36:	90                   	nop
80102b37:	c9                   	leave
80102b38:	c3                   	ret

80102b39 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102b39:	55                   	push   %ebp
80102b3a:	89 e5                	mov    %esp,%ebp
}
80102b3c:	90                   	nop
80102b3d:	5d                   	pop    %ebp
80102b3e:	c3                   	ret

80102b3f <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b3f:	55                   	push   %ebp
80102b40:	89 e5                	mov    %esp,%ebp
80102b42:	83 ec 14             	sub    $0x14,%esp
80102b45:	8b 45 08             	mov    0x8(%ebp),%eax
80102b48:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;

  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102b4b:	6a 0f                	push   $0xf
80102b4d:	6a 70                	push   $0x70
80102b4f:	e8 4b fe ff ff       	call   8010299f <outb>
80102b54:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102b57:	6a 0a                	push   $0xa
80102b59:	6a 71                	push   $0x71
80102b5b:	e8 3f fe ff ff       	call   8010299f <outb>
80102b60:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102b63:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102b6a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b6d:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102b72:	8b 45 0c             	mov    0xc(%ebp),%eax
80102b75:	c1 e8 04             	shr    $0x4,%eax
80102b78:	89 c2                	mov    %eax,%edx
80102b7a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102b7d:	83 c0 02             	add    $0x2,%eax
80102b80:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b83:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102b87:	c1 e0 18             	shl    $0x18,%eax
80102b8a:	50                   	push   %eax
80102b8b:	68 c4 00 00 00       	push   $0xc4
80102b90:	e8 29 fe ff ff       	call   801029be <lapicw>
80102b95:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102b98:	68 00 c5 00 00       	push   $0xc500
80102b9d:	68 c0 00 00 00       	push   $0xc0
80102ba2:	e8 17 fe ff ff       	call   801029be <lapicw>
80102ba7:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102baa:	68 c8 00 00 00       	push   $0xc8
80102baf:	e8 85 ff ff ff       	call   80102b39 <microdelay>
80102bb4:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
80102bb7:	68 00 85 00 00       	push   $0x8500
80102bbc:	68 c0 00 00 00       	push   $0xc0
80102bc1:	e8 f8 fd ff ff       	call   801029be <lapicw>
80102bc6:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
80102bc9:	6a 64                	push   $0x64
80102bcb:	e8 69 ff ff ff       	call   80102b39 <microdelay>
80102bd0:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80102bd3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80102bda:	eb 3d                	jmp    80102c19 <lapicstartap+0xda>
    lapicw(ICRHI, apicid<<24);
80102bdc:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102be0:	c1 e0 18             	shl    $0x18,%eax
80102be3:	50                   	push   %eax
80102be4:	68 c4 00 00 00       	push   $0xc4
80102be9:	e8 d0 fd ff ff       	call   801029be <lapicw>
80102bee:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80102bf1:	8b 45 0c             	mov    0xc(%ebp),%eax
80102bf4:	c1 e8 0c             	shr    $0xc,%eax
80102bf7:	80 cc 06             	or     $0x6,%ah
80102bfa:	50                   	push   %eax
80102bfb:	68 c0 00 00 00       	push   $0xc0
80102c00:	e8 b9 fd ff ff       	call   801029be <lapicw>
80102c05:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
80102c08:	68 c8 00 00 00       	push   $0xc8
80102c0d:	e8 27 ff ff ff       	call   80102b39 <microdelay>
80102c12:	83 c4 04             	add    $0x4,%esp
  for(i = 0; i < 2; i++){
80102c15:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80102c19:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80102c1d:	7e bd                	jle    80102bdc <lapicstartap+0x9d>
  }
}
80102c1f:	90                   	nop
80102c20:	90                   	nop
80102c21:	c9                   	leave
80102c22:	c3                   	ret

80102c23 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80102c23:	55                   	push   %ebp
80102c24:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80102c26:	8b 45 08             	mov    0x8(%ebp),%eax
80102c29:	0f b6 c0             	movzbl %al,%eax
80102c2c:	50                   	push   %eax
80102c2d:	6a 70                	push   $0x70
80102c2f:	e8 6b fd ff ff       	call   8010299f <outb>
80102c34:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80102c37:	68 c8 00 00 00       	push   $0xc8
80102c3c:	e8 f8 fe ff ff       	call   80102b39 <microdelay>
80102c41:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
80102c44:	6a 71                	push   $0x71
80102c46:	e8 37 fd ff ff       	call   80102982 <inb>
80102c4b:	83 c4 04             	add    $0x4,%esp
80102c4e:	0f b6 c0             	movzbl %al,%eax
}
80102c51:	c9                   	leave
80102c52:	c3                   	ret

80102c53 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
80102c53:	55                   	push   %ebp
80102c54:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
80102c56:	6a 00                	push   $0x0
80102c58:	e8 c6 ff ff ff       	call   80102c23 <cmos_read>
80102c5d:	83 c4 04             	add    $0x4,%esp
80102c60:	8b 55 08             	mov    0x8(%ebp),%edx
80102c63:	89 02                	mov    %eax,(%edx)
  r->minute = cmos_read(MINS);
80102c65:	6a 02                	push   $0x2
80102c67:	e8 b7 ff ff ff       	call   80102c23 <cmos_read>
80102c6c:	83 c4 04             	add    $0x4,%esp
80102c6f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c72:	89 42 04             	mov    %eax,0x4(%edx)
  r->hour   = cmos_read(HOURS);
80102c75:	6a 04                	push   $0x4
80102c77:	e8 a7 ff ff ff       	call   80102c23 <cmos_read>
80102c7c:	83 c4 04             	add    $0x4,%esp
80102c7f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c82:	89 42 08             	mov    %eax,0x8(%edx)
  r->day    = cmos_read(DAY);
80102c85:	6a 07                	push   $0x7
80102c87:	e8 97 ff ff ff       	call   80102c23 <cmos_read>
80102c8c:	83 c4 04             	add    $0x4,%esp
80102c8f:	8b 55 08             	mov    0x8(%ebp),%edx
80102c92:	89 42 0c             	mov    %eax,0xc(%edx)
  r->month  = cmos_read(MONTH);
80102c95:	6a 08                	push   $0x8
80102c97:	e8 87 ff ff ff       	call   80102c23 <cmos_read>
80102c9c:	83 c4 04             	add    $0x4,%esp
80102c9f:	8b 55 08             	mov    0x8(%ebp),%edx
80102ca2:	89 42 10             	mov    %eax,0x10(%edx)
  r->year   = cmos_read(YEAR);
80102ca5:	6a 09                	push   $0x9
80102ca7:	e8 77 ff ff ff       	call   80102c23 <cmos_read>
80102cac:	83 c4 04             	add    $0x4,%esp
80102caf:	8b 55 08             	mov    0x8(%ebp),%edx
80102cb2:	89 42 14             	mov    %eax,0x14(%edx)
}
80102cb5:	90                   	nop
80102cb6:	c9                   	leave
80102cb7:	c3                   	ret

80102cb8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80102cb8:	55                   	push   %ebp
80102cb9:	89 e5                	mov    %esp,%ebp
80102cbb:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102cbe:	6a 0b                	push   $0xb
80102cc0:	e8 5e ff ff ff       	call   80102c23 <cmos_read>
80102cc5:	83 c4 04             	add    $0x4,%esp
80102cc8:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
80102ccb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cce:	83 e0 04             	and    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	0f 94 c0             	sete   %al
80102cd6:	0f b6 c0             	movzbl %al,%eax
80102cd9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102cdc:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102cdf:	50                   	push   %eax
80102ce0:	e8 6e ff ff ff       	call   80102c53 <fill_rtcdate>
80102ce5:	83 c4 04             	add    $0x4,%esp
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102ce8:	6a 0a                	push   $0xa
80102cea:	e8 34 ff ff ff       	call   80102c23 <cmos_read>
80102cef:	83 c4 04             	add    $0x4,%esp
80102cf2:	25 80 00 00 00       	and    $0x80,%eax
80102cf7:	85 c0                	test   %eax,%eax
80102cf9:	75 27                	jne    80102d22 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
80102cfb:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102cfe:	50                   	push   %eax
80102cff:	e8 4f ff ff ff       	call   80102c53 <fill_rtcdate>
80102d04:	83 c4 04             	add    $0x4,%esp
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102d07:	83 ec 04             	sub    $0x4,%esp
80102d0a:	6a 18                	push   $0x18
80102d0c:	8d 45 c0             	lea    -0x40(%ebp),%eax
80102d0f:	50                   	push   %eax
80102d10:	8d 45 d8             	lea    -0x28(%ebp),%eax
80102d13:	50                   	push   %eax
80102d14:	e8 da 1c 00 00       	call   801049f3 <memcmp>
80102d19:	83 c4 10             	add    $0x10,%esp
80102d1c:	85 c0                	test   %eax,%eax
80102d1e:	74 05                	je     80102d25 <cmostime+0x6d>
80102d20:	eb ba                	jmp    80102cdc <cmostime+0x24>
        continue;
80102d22:	90                   	nop
    fill_rtcdate(&t1);
80102d23:	eb b7                	jmp    80102cdc <cmostime+0x24>
      break;
80102d25:	90                   	nop
  }

  // convert
  if(bcd) {
80102d26:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102d2a:	0f 84 b4 00 00 00    	je     80102de4 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102d30:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d33:	c1 e8 04             	shr    $0x4,%eax
80102d36:	89 c2                	mov    %eax,%edx
80102d38:	89 d0                	mov    %edx,%eax
80102d3a:	c1 e0 02             	shl    $0x2,%eax
80102d3d:	01 d0                	add    %edx,%eax
80102d3f:	01 c0                	add    %eax,%eax
80102d41:	89 c2                	mov    %eax,%edx
80102d43:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102d46:	83 e0 0f             	and    $0xf,%eax
80102d49:	01 d0                	add    %edx,%eax
80102d4b:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80102d4e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d51:	c1 e8 04             	shr    $0x4,%eax
80102d54:	89 c2                	mov    %eax,%edx
80102d56:	89 d0                	mov    %edx,%eax
80102d58:	c1 e0 02             	shl    $0x2,%eax
80102d5b:	01 d0                	add    %edx,%eax
80102d5d:	01 c0                	add    %eax,%eax
80102d5f:	89 c2                	mov    %eax,%edx
80102d61:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102d64:	83 e0 0f             	and    $0xf,%eax
80102d67:	01 d0                	add    %edx,%eax
80102d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80102d6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d6f:	c1 e8 04             	shr    $0x4,%eax
80102d72:	89 c2                	mov    %eax,%edx
80102d74:	89 d0                	mov    %edx,%eax
80102d76:	c1 e0 02             	shl    $0x2,%eax
80102d79:	01 d0                	add    %edx,%eax
80102d7b:	01 c0                	add    %eax,%eax
80102d7d:	89 c2                	mov    %eax,%edx
80102d7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102d82:	83 e0 0f             	and    $0xf,%eax
80102d85:	01 d0                	add    %edx,%eax
80102d87:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
80102d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d8d:	c1 e8 04             	shr    $0x4,%eax
80102d90:	89 c2                	mov    %eax,%edx
80102d92:	89 d0                	mov    %edx,%eax
80102d94:	c1 e0 02             	shl    $0x2,%eax
80102d97:	01 d0                	add    %edx,%eax
80102d99:	01 c0                	add    %eax,%eax
80102d9b:	89 c2                	mov    %eax,%edx
80102d9d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102da0:	83 e0 0f             	and    $0xf,%eax
80102da3:	01 d0                	add    %edx,%eax
80102da5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80102da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dab:	c1 e8 04             	shr    $0x4,%eax
80102dae:	89 c2                	mov    %eax,%edx
80102db0:	89 d0                	mov    %edx,%eax
80102db2:	c1 e0 02             	shl    $0x2,%eax
80102db5:	01 d0                	add    %edx,%eax
80102db7:	01 c0                	add    %eax,%eax
80102db9:	89 c2                	mov    %eax,%edx
80102dbb:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102dbe:	83 e0 0f             	and    $0xf,%eax
80102dc1:	01 d0                	add    %edx,%eax
80102dc3:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80102dc6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102dc9:	c1 e8 04             	shr    $0x4,%eax
80102dcc:	89 c2                	mov    %eax,%edx
80102dce:	89 d0                	mov    %edx,%eax
80102dd0:	c1 e0 02             	shl    $0x2,%eax
80102dd3:	01 d0                	add    %edx,%eax
80102dd5:	01 c0                	add    %eax,%eax
80102dd7:	89 c2                	mov    %eax,%edx
80102dd9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ddc:	83 e0 0f             	and    $0xf,%eax
80102ddf:	01 d0                	add    %edx,%eax
80102de1:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80102de4:	8b 45 08             	mov    0x8(%ebp),%eax
80102de7:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102dea:	89 10                	mov    %edx,(%eax)
80102dec:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102def:	89 50 04             	mov    %edx,0x4(%eax)
80102df2:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102df5:	89 50 08             	mov    %edx,0x8(%eax)
80102df8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102dfb:	89 50 0c             	mov    %edx,0xc(%eax)
80102dfe:	8b 55 e8             	mov    -0x18(%ebp),%edx
80102e01:	89 50 10             	mov    %edx,0x10(%eax)
80102e04:	8b 55 ec             	mov    -0x14(%ebp),%edx
80102e07:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80102e0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102e0d:	8b 40 14             	mov    0x14(%eax),%eax
80102e10:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80102e16:	8b 45 08             	mov    0x8(%ebp),%eax
80102e19:	89 50 14             	mov    %edx,0x14(%eax)
}
80102e1c:	90                   	nop
80102e1d:	c9                   	leave
80102e1e:	c3                   	ret

80102e1f <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80102e1f:	55                   	push   %ebp
80102e20:	89 e5                	mov    %esp,%ebp
80102e22:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80102e25:	83 ec 08             	sub    $0x8,%esp
80102e28:	68 31 a2 10 80       	push   $0x8010a231
80102e2d:	68 20 41 19 80       	push   $0x80194120
80102e32:	e8 bd 18 00 00       	call   801046f4 <initlock>
80102e37:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80102e3a:	83 ec 08             	sub    $0x8,%esp
80102e3d:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102e40:	50                   	push   %eax
80102e41:	ff 75 08             	push   0x8(%ebp)
80102e44:	e8 8f e5 ff ff       	call   801013d8 <readsb>
80102e49:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80102e4c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102e4f:	a3 54 41 19 80       	mov    %eax,0x80194154
  log.size = sb.nlog;
80102e54:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102e57:	a3 58 41 19 80       	mov    %eax,0x80194158
  log.dev = dev;
80102e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80102e5f:	a3 64 41 19 80       	mov    %eax,0x80194164
  recover_from_log();
80102e64:	e8 b3 01 00 00       	call   8010301c <recover_from_log>
}
80102e69:	90                   	nop
80102e6a:	c9                   	leave
80102e6b:	c3                   	ret

80102e6c <install_trans>:

// Copy committed blocks from log to their home location
static void
install_trans(void)
{
80102e6c:	55                   	push   %ebp
80102e6d:	89 e5                	mov    %esp,%ebp
80102e6f:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102e72:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102e79:	e9 95 00 00 00       	jmp    80102f13 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102e7e:	8b 15 54 41 19 80    	mov    0x80194154,%edx
80102e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102e87:	01 d0                	add    %edx,%eax
80102e89:	83 c0 01             	add    $0x1,%eax
80102e8c:	89 c2                	mov    %eax,%edx
80102e8e:	a1 64 41 19 80       	mov    0x80194164,%eax
80102e93:	83 ec 08             	sub    $0x8,%esp
80102e96:	52                   	push   %edx
80102e97:	50                   	push   %eax
80102e98:	e8 64 d3 ff ff       	call   80100201 <bread>
80102e9d:	83 c4 10             	add    $0x10,%esp
80102ea0:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ea6:	83 c0 10             	add    $0x10,%eax
80102ea9:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
80102eb0:	89 c2                	mov    %eax,%edx
80102eb2:	a1 64 41 19 80       	mov    0x80194164,%eax
80102eb7:	83 ec 08             	sub    $0x8,%esp
80102eba:	52                   	push   %edx
80102ebb:	50                   	push   %eax
80102ebc:	e8 40 d3 ff ff       	call   80100201 <bread>
80102ec1:	83 c4 10             	add    $0x10,%esp
80102ec4:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102eca:	8d 50 5c             	lea    0x5c(%eax),%edx
80102ecd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102ed0:	83 c0 5c             	add    $0x5c,%eax
80102ed3:	83 ec 04             	sub    $0x4,%esp
80102ed6:	68 00 02 00 00       	push   $0x200
80102edb:	52                   	push   %edx
80102edc:	50                   	push   %eax
80102edd:	e8 69 1b 00 00       	call   80104a4b <memmove>
80102ee2:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
80102ee5:	83 ec 0c             	sub    $0xc,%esp
80102ee8:	ff 75 ec             	push   -0x14(%ebp)
80102eeb:	e8 4a d3 ff ff       	call   8010023a <bwrite>
80102ef0:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf);
80102ef3:	83 ec 0c             	sub    $0xc,%esp
80102ef6:	ff 75 f0             	push   -0x10(%ebp)
80102ef9:	e8 85 d3 ff ff       	call   80100283 <brelse>
80102efe:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80102f01:	83 ec 0c             	sub    $0xc,%esp
80102f04:	ff 75 ec             	push   -0x14(%ebp)
80102f07:	e8 77 d3 ff ff       	call   80100283 <brelse>
80102f0c:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102f0f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f13:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f18:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f1b:	0f 8c 5d ff ff ff    	jl     80102e7e <install_trans+0x12>
  }
}
80102f21:	90                   	nop
80102f22:	90                   	nop
80102f23:	c9                   	leave
80102f24:	c3                   	ret

80102f25 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80102f25:	55                   	push   %ebp
80102f26:	89 e5                	mov    %esp,%ebp
80102f28:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f2b:	a1 54 41 19 80       	mov    0x80194154,%eax
80102f30:	89 c2                	mov    %eax,%edx
80102f32:	a1 64 41 19 80       	mov    0x80194164,%eax
80102f37:	83 ec 08             	sub    $0x8,%esp
80102f3a:	52                   	push   %edx
80102f3b:	50                   	push   %eax
80102f3c:	e8 c0 d2 ff ff       	call   80100201 <bread>
80102f41:	83 c4 10             	add    $0x10,%esp
80102f44:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
80102f47:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102f4a:	83 c0 5c             	add    $0x5c,%eax
80102f4d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80102f50:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f53:	8b 00                	mov    (%eax),%eax
80102f55:	a3 68 41 19 80       	mov    %eax,0x80194168
  for (i = 0; i < log.lh.n; i++) {
80102f5a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102f61:	eb 1b                	jmp    80102f7e <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80102f63:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102f66:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f69:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80102f6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102f70:	83 c2 10             	add    $0x10,%edx
80102f73:	89 04 95 2c 41 19 80 	mov    %eax,-0x7fe6bed4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f7a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102f7e:	a1 68 41 19 80       	mov    0x80194168,%eax
80102f83:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102f86:	7c db                	jl     80102f63 <read_head+0x3e>
  }
  brelse(buf);
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	ff 75 f0             	push   -0x10(%ebp)
80102f8e:	e8 f0 d2 ff ff       	call   80100283 <brelse>
80102f93:	83 c4 10             	add    $0x10,%esp
}
80102f96:	90                   	nop
80102f97:	c9                   	leave
80102f98:	c3                   	ret

80102f99 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102f99:	55                   	push   %ebp
80102f9a:	89 e5                	mov    %esp,%ebp
80102f9c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80102f9f:	a1 54 41 19 80       	mov    0x80194154,%eax
80102fa4:	89 c2                	mov    %eax,%edx
80102fa6:	a1 64 41 19 80       	mov    0x80194164,%eax
80102fab:	83 ec 08             	sub    $0x8,%esp
80102fae:	52                   	push   %edx
80102faf:	50                   	push   %eax
80102fb0:	e8 4c d2 ff ff       	call   80100201 <bread>
80102fb5:	83 c4 10             	add    $0x10,%esp
80102fb8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80102fbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102fbe:	83 c0 5c             	add    $0x5c,%eax
80102fc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
80102fc4:	8b 15 68 41 19 80    	mov    0x80194168,%edx
80102fca:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fcd:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102fcf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102fd6:	eb 1b                	jmp    80102ff3 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
80102fd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102fdb:	83 c0 10             	add    $0x10,%eax
80102fde:	8b 0c 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%ecx
80102fe5:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102fe8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102feb:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102fef:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ff3:	a1 68 41 19 80       	mov    0x80194168,%eax
80102ff8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80102ffb:	7c db                	jl     80102fd8 <write_head+0x3f>
  }
  bwrite(buf);
80102ffd:	83 ec 0c             	sub    $0xc,%esp
80103000:	ff 75 f0             	push   -0x10(%ebp)
80103003:	e8 32 d2 ff ff       	call   8010023a <bwrite>
80103008:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	ff 75 f0             	push   -0x10(%ebp)
80103011:	e8 6d d2 ff ff       	call   80100283 <brelse>
80103016:	83 c4 10             	add    $0x10,%esp
}
80103019:	90                   	nop
8010301a:	c9                   	leave
8010301b:	c3                   	ret

8010301c <recover_from_log>:

static void
recover_from_log(void)
{
8010301c:	55                   	push   %ebp
8010301d:	89 e5                	mov    %esp,%ebp
8010301f:	83 ec 08             	sub    $0x8,%esp
  read_head();
80103022:	e8 fe fe ff ff       	call   80102f25 <read_head>
  install_trans(); // if committed, copy from log to disk
80103027:	e8 40 fe ff ff       	call   80102e6c <install_trans>
  log.lh.n = 0;
8010302c:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
80103033:	00 00 00 
  write_head(); // clear the log
80103036:	e8 5e ff ff ff       	call   80102f99 <write_head>
}
8010303b:	90                   	nop
8010303c:	c9                   	leave
8010303d:	c3                   	ret

8010303e <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
8010303e:	55                   	push   %ebp
8010303f:	89 e5                	mov    %esp,%ebp
80103041:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103044:	83 ec 0c             	sub    $0xc,%esp
80103047:	68 20 41 19 80       	push   $0x80194120
8010304c:	e8 c5 16 00 00       	call   80104716 <acquire>
80103051:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103054:	a1 60 41 19 80       	mov    0x80194160,%eax
80103059:	85 c0                	test   %eax,%eax
8010305b:	74 17                	je     80103074 <begin_op+0x36>
      sleep(&log, &log.lock);
8010305d:	83 ec 08             	sub    $0x8,%esp
80103060:	68 20 41 19 80       	push   $0x80194120
80103065:	68 20 41 19 80       	push   $0x80194120
8010306a:	e8 74 12 00 00       	call   801042e3 <sleep>
8010306f:	83 c4 10             	add    $0x10,%esp
80103072:	eb e0                	jmp    80103054 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103074:	8b 0d 68 41 19 80    	mov    0x80194168,%ecx
8010307a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010307f:	8d 50 01             	lea    0x1(%eax),%edx
80103082:	89 d0                	mov    %edx,%eax
80103084:	c1 e0 02             	shl    $0x2,%eax
80103087:	01 d0                	add    %edx,%eax
80103089:	01 c0                	add    %eax,%eax
8010308b:	01 c8                	add    %ecx,%eax
8010308d:	83 f8 1e             	cmp    $0x1e,%eax
80103090:	7e 17                	jle    801030a9 <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103092:	83 ec 08             	sub    $0x8,%esp
80103095:	68 20 41 19 80       	push   $0x80194120
8010309a:	68 20 41 19 80       	push   $0x80194120
8010309f:	e8 3f 12 00 00       	call   801042e3 <sleep>
801030a4:	83 c4 10             	add    $0x10,%esp
801030a7:	eb ab                	jmp    80103054 <begin_op+0x16>
    } else {
      log.outstanding += 1;
801030a9:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ae:	83 c0 01             	add    $0x1,%eax
801030b1:	a3 5c 41 19 80       	mov    %eax,0x8019415c
      release(&log.lock);
801030b6:	83 ec 0c             	sub    $0xc,%esp
801030b9:	68 20 41 19 80       	push   $0x80194120
801030be:	e8 c1 16 00 00       	call   80104784 <release>
801030c3:	83 c4 10             	add    $0x10,%esp
      break;
801030c6:	90                   	nop
    }
  }
}
801030c7:	90                   	nop
801030c8:	c9                   	leave
801030c9:	c3                   	ret

801030ca <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801030ca:	55                   	push   %ebp
801030cb:	89 e5                	mov    %esp,%ebp
801030cd:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801030d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801030d7:	83 ec 0c             	sub    $0xc,%esp
801030da:	68 20 41 19 80       	push   $0x80194120
801030df:	e8 32 16 00 00       	call   80104716 <acquire>
801030e4:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801030e7:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801030ec:	83 e8 01             	sub    $0x1,%eax
801030ef:	a3 5c 41 19 80       	mov    %eax,0x8019415c
  if(log.committing)
801030f4:	a1 60 41 19 80       	mov    0x80194160,%eax
801030f9:	85 c0                	test   %eax,%eax
801030fb:	74 0d                	je     8010310a <end_op+0x40>
    panic("log.committing");
801030fd:	83 ec 0c             	sub    $0xc,%esp
80103100:	68 35 a2 10 80       	push   $0x8010a235
80103105:	e8 9f d4 ff ff       	call   801005a9 <panic>
  if(log.outstanding == 0){
8010310a:	a1 5c 41 19 80       	mov    0x8019415c,%eax
8010310f:	85 c0                	test   %eax,%eax
80103111:	75 13                	jne    80103126 <end_op+0x5c>
    do_commit = 1;
80103113:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010311a:	c7 05 60 41 19 80 01 	movl   $0x1,0x80194160
80103121:	00 00 00 
80103124:	eb 10                	jmp    80103136 <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
80103126:	83 ec 0c             	sub    $0xc,%esp
80103129:	68 20 41 19 80       	push   $0x80194120
8010312e:	e8 97 12 00 00       	call   801043ca <wakeup>
80103133:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
80103136:	83 ec 0c             	sub    $0xc,%esp
80103139:	68 20 41 19 80       	push   $0x80194120
8010313e:	e8 41 16 00 00       	call   80104784 <release>
80103143:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
80103146:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010314a:	74 3f                	je     8010318b <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
8010314c:	e8 f6 00 00 00       	call   80103247 <commit>
    acquire(&log.lock);
80103151:	83 ec 0c             	sub    $0xc,%esp
80103154:	68 20 41 19 80       	push   $0x80194120
80103159:	e8 b8 15 00 00       	call   80104716 <acquire>
8010315e:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103161:	c7 05 60 41 19 80 00 	movl   $0x0,0x80194160
80103168:	00 00 00 
    wakeup(&log);
8010316b:	83 ec 0c             	sub    $0xc,%esp
8010316e:	68 20 41 19 80       	push   $0x80194120
80103173:	e8 52 12 00 00       	call   801043ca <wakeup>
80103178:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010317b:	83 ec 0c             	sub    $0xc,%esp
8010317e:	68 20 41 19 80       	push   $0x80194120
80103183:	e8 fc 15 00 00       	call   80104784 <release>
80103188:	83 c4 10             	add    $0x10,%esp
  }
}
8010318b:	90                   	nop
8010318c:	c9                   	leave
8010318d:	c3                   	ret

8010318e <write_log>:

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010318e:	55                   	push   %ebp
8010318f:	89 e5                	mov    %esp,%ebp
80103191:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010319b:	e9 95 00 00 00       	jmp    80103235 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
801031a0:	8b 15 54 41 19 80    	mov    0x80194154,%edx
801031a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031a9:	01 d0                	add    %edx,%eax
801031ab:	83 c0 01             	add    $0x1,%eax
801031ae:	89 c2                	mov    %eax,%edx
801031b0:	a1 64 41 19 80       	mov    0x80194164,%eax
801031b5:	83 ec 08             	sub    $0x8,%esp
801031b8:	52                   	push   %edx
801031b9:	50                   	push   %eax
801031ba:	e8 42 d0 ff ff       	call   80100201 <bread>
801031bf:	83 c4 10             	add    $0x10,%esp
801031c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801031c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c8:	83 c0 10             	add    $0x10,%eax
801031cb:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801031d2:	89 c2                	mov    %eax,%edx
801031d4:	a1 64 41 19 80       	mov    0x80194164,%eax
801031d9:	83 ec 08             	sub    $0x8,%esp
801031dc:	52                   	push   %edx
801031dd:	50                   	push   %eax
801031de:	e8 1e d0 ff ff       	call   80100201 <bread>
801031e3:	83 c4 10             	add    $0x10,%esp
801031e6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801031e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801031ec:	8d 50 5c             	lea    0x5c(%eax),%edx
801031ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801031f2:	83 c0 5c             	add    $0x5c,%eax
801031f5:	83 ec 04             	sub    $0x4,%esp
801031f8:	68 00 02 00 00       	push   $0x200
801031fd:	52                   	push   %edx
801031fe:	50                   	push   %eax
801031ff:	e8 47 18 00 00       	call   80104a4b <memmove>
80103204:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
80103207:	83 ec 0c             	sub    $0xc,%esp
8010320a:	ff 75 f0             	push   -0x10(%ebp)
8010320d:	e8 28 d0 ff ff       	call   8010023a <bwrite>
80103212:	83 c4 10             	add    $0x10,%esp
    brelse(from);
80103215:	83 ec 0c             	sub    $0xc,%esp
80103218:	ff 75 ec             	push   -0x14(%ebp)
8010321b:	e8 63 d0 ff ff       	call   80100283 <brelse>
80103220:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103223:	83 ec 0c             	sub    $0xc,%esp
80103226:	ff 75 f0             	push   -0x10(%ebp)
80103229:	e8 55 d0 ff ff       	call   80100283 <brelse>
8010322e:	83 c4 10             	add    $0x10,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80103231:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103235:	a1 68 41 19 80       	mov    0x80194168,%eax
8010323a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010323d:	0f 8c 5d ff ff ff    	jl     801031a0 <write_log+0x12>
  }
}
80103243:	90                   	nop
80103244:	90                   	nop
80103245:	c9                   	leave
80103246:	c3                   	ret

80103247 <commit>:

static void
commit()
{
80103247:	55                   	push   %ebp
80103248:	89 e5                	mov    %esp,%ebp
8010324a:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
8010324d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103252:	85 c0                	test   %eax,%eax
80103254:	7e 1e                	jle    80103274 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103256:	e8 33 ff ff ff       	call   8010318e <write_log>
    write_head();    // Write header to disk -- the real commit
8010325b:	e8 39 fd ff ff       	call   80102f99 <write_head>
    install_trans(); // Now install writes to home locations
80103260:	e8 07 fc ff ff       	call   80102e6c <install_trans>
    log.lh.n = 0;
80103265:	c7 05 68 41 19 80 00 	movl   $0x0,0x80194168
8010326c:	00 00 00 
    write_head();    // Erase the transaction from the log
8010326f:	e8 25 fd ff ff       	call   80102f99 <write_head>
  }
}
80103274:	90                   	nop
80103275:	c9                   	leave
80103276:	c3                   	ret

80103277 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103277:	55                   	push   %ebp
80103278:	89 e5                	mov    %esp,%ebp
8010327a:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010327d:	a1 68 41 19 80       	mov    0x80194168,%eax
80103282:	83 f8 1d             	cmp    $0x1d,%eax
80103285:	7f 12                	jg     80103299 <log_write+0x22>
80103287:	8b 15 68 41 19 80    	mov    0x80194168,%edx
8010328d:	a1 58 41 19 80       	mov    0x80194158,%eax
80103292:	83 e8 01             	sub    $0x1,%eax
80103295:	39 c2                	cmp    %eax,%edx
80103297:	7c 0d                	jl     801032a6 <log_write+0x2f>
    panic("too big a transaction");
80103299:	83 ec 0c             	sub    $0xc,%esp
8010329c:	68 44 a2 10 80       	push   $0x8010a244
801032a1:	e8 03 d3 ff ff       	call   801005a9 <panic>
  if (log.outstanding < 1)
801032a6:	a1 5c 41 19 80       	mov    0x8019415c,%eax
801032ab:	85 c0                	test   %eax,%eax
801032ad:	7f 0d                	jg     801032bc <log_write+0x45>
    panic("log_write outside of trans");
801032af:	83 ec 0c             	sub    $0xc,%esp
801032b2:	68 5a a2 10 80       	push   $0x8010a25a
801032b7:	e8 ed d2 ff ff       	call   801005a9 <panic>

  acquire(&log.lock);
801032bc:	83 ec 0c             	sub    $0xc,%esp
801032bf:	68 20 41 19 80       	push   $0x80194120
801032c4:	e8 4d 14 00 00       	call   80104716 <acquire>
801032c9:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801032cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032d3:	eb 1d                	jmp    801032f2 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801032d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032d8:	83 c0 10             	add    $0x10,%eax
801032db:	8b 04 85 2c 41 19 80 	mov    -0x7fe6bed4(,%eax,4),%eax
801032e2:	89 c2                	mov    %eax,%edx
801032e4:	8b 45 08             	mov    0x8(%ebp),%eax
801032e7:	8b 40 08             	mov    0x8(%eax),%eax
801032ea:	39 c2                	cmp    %eax,%edx
801032ec:	74 10                	je     801032fe <log_write+0x87>
  for (i = 0; i < log.lh.n; i++) {
801032ee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801032f2:	a1 68 41 19 80       	mov    0x80194168,%eax
801032f7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801032fa:	7c d9                	jl     801032d5 <log_write+0x5e>
801032fc:	eb 01                	jmp    801032ff <log_write+0x88>
      break;
801032fe:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 08             	mov    0x8(%eax),%eax
80103305:	89 c2                	mov    %eax,%edx
80103307:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010330a:	83 c0 10             	add    $0x10,%eax
8010330d:	89 14 85 2c 41 19 80 	mov    %edx,-0x7fe6bed4(,%eax,4)
  if (i == log.lh.n)
80103314:	a1 68 41 19 80       	mov    0x80194168,%eax
80103319:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010331c:	75 0d                	jne    8010332b <log_write+0xb4>
    log.lh.n++;
8010331e:	a1 68 41 19 80       	mov    0x80194168,%eax
80103323:	83 c0 01             	add    $0x1,%eax
80103326:	a3 68 41 19 80       	mov    %eax,0x80194168
  b->flags |= B_DIRTY; // prevent eviction
8010332b:	8b 45 08             	mov    0x8(%ebp),%eax
8010332e:	8b 00                	mov    (%eax),%eax
80103330:	83 c8 04             	or     $0x4,%eax
80103333:	89 c2                	mov    %eax,%edx
80103335:	8b 45 08             	mov    0x8(%ebp),%eax
80103338:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010333a:	83 ec 0c             	sub    $0xc,%esp
8010333d:	68 20 41 19 80       	push   $0x80194120
80103342:	e8 3d 14 00 00       	call   80104784 <release>
80103347:	83 c4 10             	add    $0x10,%esp
}
8010334a:	90                   	nop
8010334b:	c9                   	leave
8010334c:	c3                   	ret

8010334d <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010334d:	55                   	push   %ebp
8010334e:	89 e5                	mov    %esp,%ebp
80103350:	83 ec 10             	sub    $0x10,%esp
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103353:	8b 55 08             	mov    0x8(%ebp),%edx
80103356:	8b 45 0c             	mov    0xc(%ebp),%eax
80103359:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010335c:	f0 87 02             	lock xchg %eax,(%edx)
8010335f:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80103362:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103365:	c9                   	leave
80103366:	c3                   	ret

80103367 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103367:	8d 4c 24 04          	lea    0x4(%esp),%ecx
8010336b:	83 e4 f0             	and    $0xfffffff0,%esp
8010336e:	ff 71 fc             	push   -0x4(%ecx)
80103371:	55                   	push   %ebp
80103372:	89 e5                	mov    %esp,%ebp
80103374:	51                   	push   %ecx
80103375:	83 ec 04             	sub    $0x4,%esp
  graphic_init();
80103378:	e8 47 4a 00 00       	call   80107dc4 <graphic_init>
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010337d:	83 ec 08             	sub    $0x8,%esp
80103380:	68 00 00 40 80       	push   $0x80400000
80103385:	68 00 90 19 80       	push   $0x80199000
8010338a:	e8 e4 f2 ff ff       	call   80102673 <kinit1>
8010338f:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
80103392:	e8 4a 40 00 00       	call   801073e1 <kvmalloc>
  mpinit_uefi();
80103397:	e8 f1 47 00 00       	call   80107b8d <mpinit_uefi>
  lapicinit();     // interrupt controller
8010339c:	e8 3f f6 ff ff       	call   801029e0 <lapicinit>
  seginit();       // segment descriptors
801033a1:	e8 d2 3a 00 00       	call   80106e78 <seginit>
  picinit();    // disable pic
801033a6:	e8 9b 01 00 00       	call   80103546 <picinit>
  ioapicinit();    // another interrupt controller
801033ab:	e8 de f1 ff ff       	call   8010258e <ioapicinit>
  consoleinit();   // console hardware
801033b0:	e8 54 d7 ff ff       	call   80100b09 <consoleinit>
  uartinit();      // serial port
801033b5:	e8 57 2e 00 00       	call   80106211 <uartinit>
  pinit();         // process table
801033ba:	e8 c0 05 00 00       	call   8010397f <pinit>
  tvinit();        // trap vectors
801033bf:	e8 ca 29 00 00       	call   80105d8e <tvinit>
  binit();         // buffer cache
801033c4:	e8 9d cc ff ff       	call   80100066 <binit>
  fileinit();      // file table
801033c9:	e8 fb db ff ff       	call   80100fc9 <fileinit>
  ideinit();       // disk 
801033ce:	e8 1c 6b 00 00       	call   80109eef <ideinit>
  startothers();   // start other processors
801033d3:	e8 8a 00 00 00       	call   80103462 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
801033d8:	83 ec 08             	sub    $0x8,%esp
801033db:	68 00 00 00 a0       	push   $0xa0000000
801033e0:	68 00 00 40 80       	push   $0x80400000
801033e5:	e8 c2 f2 ff ff       	call   801026ac <kinit2>
801033ea:	83 c4 10             	add    $0x10,%esp
  pci_init();
801033ed:	e8 2d 4c 00 00       	call   8010801f <pci_init>
  arp_scan();
801033f2:	e8 62 59 00 00       	call   80108d59 <arp_scan>
  //i8254_recv();
  userinit();      // first user process
801033f7:	e8 6b 07 00 00       	call   80103b67 <userinit>

  mpmain();        // finish this processor's setup
801033fc:	e8 1a 00 00 00       	call   8010341b <mpmain>

80103401 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
80103401:	55                   	push   %ebp
80103402:	89 e5                	mov    %esp,%ebp
80103404:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103407:	e8 ed 3f 00 00       	call   801073f9 <switchkvm>
  seginit();
8010340c:	e8 67 3a 00 00       	call   80106e78 <seginit>
  lapicinit();
80103411:	e8 ca f5 ff ff       	call   801029e0 <lapicinit>
  mpmain();
80103416:	e8 00 00 00 00       	call   8010341b <mpmain>

8010341b <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
8010341b:	55                   	push   %ebp
8010341c:	89 e5                	mov    %esp,%ebp
8010341e:	53                   	push   %ebx
8010341f:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103422:	e8 76 05 00 00       	call   8010399d <cpuid>
80103427:	89 c3                	mov    %eax,%ebx
80103429:	e8 6f 05 00 00       	call   8010399d <cpuid>
8010342e:	83 ec 04             	sub    $0x4,%esp
80103431:	53                   	push   %ebx
80103432:	50                   	push   %eax
80103433:	68 75 a2 10 80       	push   $0x8010a275
80103438:	e8 b7 cf ff ff       	call   801003f4 <cprintf>
8010343d:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103440:	e8 bf 2a 00 00       	call   80105f04 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103445:	e8 6e 05 00 00       	call   801039b8 <mycpu>
8010344a:	05 a0 00 00 00       	add    $0xa0,%eax
8010344f:	83 ec 08             	sub    $0x8,%esp
80103452:	6a 01                	push   $0x1
80103454:	50                   	push   %eax
80103455:	e8 f3 fe ff ff       	call   8010334d <xchg>
8010345a:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
8010345d:	e8 90 0c 00 00       	call   801040f2 <scheduler>

80103462 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103462:	55                   	push   %ebp
80103463:	89 e5                	mov    %esp,%ebp
80103465:	83 ec 18             	sub    $0x18,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
80103468:	c7 45 f0 00 70 00 80 	movl   $0x80007000,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010346f:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103474:	83 ec 04             	sub    $0x4,%esp
80103477:	50                   	push   %eax
80103478:	68 18 f5 10 80       	push   $0x8010f518
8010347d:	ff 75 f0             	push   -0x10(%ebp)
80103480:	e8 c6 15 00 00       	call   80104a4b <memmove>
80103485:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103488:	c7 45 f4 80 6a 19 80 	movl   $0x80196a80,-0xc(%ebp)
8010348f:	eb 79                	jmp    8010350a <startothers+0xa8>
    if(c == mycpu()){  // We've started already.
80103491:	e8 22 05 00 00       	call   801039b8 <mycpu>
80103496:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103499:	74 67                	je     80103502 <startothers+0xa0>
      continue;
    }
    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
8010349b:	e8 08 f3 ff ff       	call   801027a8 <kalloc>
801034a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801034a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034a6:	83 e8 04             	sub    $0x4,%eax
801034a9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801034ac:	81 c2 00 10 00 00    	add    $0x1000,%edx
801034b2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801034b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b7:	83 e8 08             	sub    $0x8,%eax
801034ba:	c7 00 01 34 10 80    	movl   $0x80103401,(%eax)
    *(int**)(code-12) = (void *) V2P(entrypgdir);
801034c0:	b8 00 e0 10 80       	mov    $0x8010e000,%eax
801034c5:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034ce:	83 e8 0c             	sub    $0xc,%eax
801034d1:	89 10                	mov    %edx,(%eax)

    lapicstartap(c->apicid, V2P(code));
801034d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034d6:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801034dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034df:	0f b6 00             	movzbl (%eax),%eax
801034e2:	0f b6 c0             	movzbl %al,%eax
801034e5:	83 ec 08             	sub    $0x8,%esp
801034e8:	52                   	push   %edx
801034e9:	50                   	push   %eax
801034ea:	e8 50 f6 ff ff       	call   80102b3f <lapicstartap>
801034ef:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801034f2:	90                   	nop
801034f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034f6:	8b 80 a0 00 00 00    	mov    0xa0(%eax),%eax
801034fc:	85 c0                	test   %eax,%eax
801034fe:	74 f3                	je     801034f3 <startothers+0x91>
80103500:	eb 01                	jmp    80103503 <startothers+0xa1>
      continue;
80103502:	90                   	nop
  for(c = cpus; c < cpus+ncpu; c++){
80103503:	81 45 f4 b0 00 00 00 	addl   $0xb0,-0xc(%ebp)
8010350a:	a1 40 6d 19 80       	mov    0x80196d40,%eax
8010350f:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103515:	05 80 6a 19 80       	add    $0x80196a80,%eax
8010351a:	39 45 f4             	cmp    %eax,-0xc(%ebp)
8010351d:	0f 82 6e ff ff ff    	jb     80103491 <startothers+0x2f>
      ;
  }
}
80103523:	90                   	nop
80103524:	90                   	nop
80103525:	c9                   	leave
80103526:	c3                   	ret

80103527 <outb>:
{
80103527:	55                   	push   %ebp
80103528:	89 e5                	mov    %esp,%ebp
8010352a:	83 ec 08             	sub    $0x8,%esp
8010352d:	8b 55 08             	mov    0x8(%ebp),%edx
80103530:	8b 45 0c             	mov    0xc(%ebp),%eax
80103533:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103537:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010353a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010353e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103542:	ee                   	out    %al,(%dx)
}
80103543:	90                   	nop
80103544:	c9                   	leave
80103545:	c3                   	ret

80103546 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103546:	55                   	push   %ebp
80103547:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103549:	68 ff 00 00 00       	push   $0xff
8010354e:	6a 21                	push   $0x21
80103550:	e8 d2 ff ff ff       	call   80103527 <outb>
80103555:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103558:	68 ff 00 00 00       	push   $0xff
8010355d:	68 a1 00 00 00       	push   $0xa1
80103562:	e8 c0 ff ff ff       	call   80103527 <outb>
80103567:	83 c4 08             	add    $0x8,%esp
}
8010356a:	90                   	nop
8010356b:	c9                   	leave
8010356c:	c3                   	ret

8010356d <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
8010356d:	55                   	push   %ebp
8010356e:	89 e5                	mov    %esp,%ebp
80103570:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103573:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
8010357a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010357d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103583:	8b 45 0c             	mov    0xc(%ebp),%eax
80103586:	8b 10                	mov    (%eax),%edx
80103588:	8b 45 08             	mov    0x8(%ebp),%eax
8010358b:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010358d:	e8 55 da ff ff       	call   80100fe7 <filealloc>
80103592:	8b 55 08             	mov    0x8(%ebp),%edx
80103595:	89 02                	mov    %eax,(%edx)
80103597:	8b 45 08             	mov    0x8(%ebp),%eax
8010359a:	8b 00                	mov    (%eax),%eax
8010359c:	85 c0                	test   %eax,%eax
8010359e:	0f 84 c8 00 00 00    	je     8010366c <pipealloc+0xff>
801035a4:	e8 3e da ff ff       	call   80100fe7 <filealloc>
801035a9:	8b 55 0c             	mov    0xc(%ebp),%edx
801035ac:	89 02                	mov    %eax,(%edx)
801035ae:	8b 45 0c             	mov    0xc(%ebp),%eax
801035b1:	8b 00                	mov    (%eax),%eax
801035b3:	85 c0                	test   %eax,%eax
801035b5:	0f 84 b1 00 00 00    	je     8010366c <pipealloc+0xff>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
801035bb:	e8 e8 f1 ff ff       	call   801027a8 <kalloc>
801035c0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801035c3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c7:	0f 84 a2 00 00 00    	je     8010366f <pipealloc+0x102>
    goto bad;
  p->readopen = 1;
801035cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035d0:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
801035d7:	00 00 00 
  p->writeopen = 1;
801035da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035dd:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801035e4:	00 00 00 
  p->nwrite = 0;
801035e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035ea:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801035f1:	00 00 00 
  p->nread = 0;
801035f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801035f7:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801035fe:	00 00 00 
  initlock(&p->lock, "pipe");
80103601:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103604:	83 ec 08             	sub    $0x8,%esp
80103607:	68 89 a2 10 80       	push   $0x8010a289
8010360c:	50                   	push   %eax
8010360d:	e8 e2 10 00 00       	call   801046f4 <initlock>
80103612:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
80103615:	8b 45 08             	mov    0x8(%ebp),%eax
80103618:	8b 00                	mov    (%eax),%eax
8010361a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80103620:	8b 45 08             	mov    0x8(%ebp),%eax
80103623:	8b 00                	mov    (%eax),%eax
80103625:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103629:	8b 45 08             	mov    0x8(%ebp),%eax
8010362c:	8b 00                	mov    (%eax),%eax
8010362e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103632:	8b 45 08             	mov    0x8(%ebp),%eax
80103635:	8b 00                	mov    (%eax),%eax
80103637:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010363a:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010363d:	8b 45 0c             	mov    0xc(%ebp),%eax
80103640:	8b 00                	mov    (%eax),%eax
80103642:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103648:	8b 45 0c             	mov    0xc(%ebp),%eax
8010364b:	8b 00                	mov    (%eax),%eax
8010364d:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103651:	8b 45 0c             	mov    0xc(%ebp),%eax
80103654:	8b 00                	mov    (%eax),%eax
80103656:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010365a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010365d:	8b 00                	mov    (%eax),%eax
8010365f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103662:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80103665:	b8 00 00 00 00       	mov    $0x0,%eax
8010366a:	eb 51                	jmp    801036bd <pipealloc+0x150>
    goto bad;
8010366c:	90                   	nop
8010366d:	eb 01                	jmp    80103670 <pipealloc+0x103>
    goto bad;
8010366f:	90                   	nop

//PAGEBREAK: 20
 bad:
  if(p)
80103670:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103674:	74 0e                	je     80103684 <pipealloc+0x117>
    kfree((char*)p);
80103676:	83 ec 0c             	sub    $0xc,%esp
80103679:	ff 75 f4             	push   -0xc(%ebp)
8010367c:	e8 8d f0 ff ff       	call   8010270e <kfree>
80103681:	83 c4 10             	add    $0x10,%esp
  if(*f0)
80103684:	8b 45 08             	mov    0x8(%ebp),%eax
80103687:	8b 00                	mov    (%eax),%eax
80103689:	85 c0                	test   %eax,%eax
8010368b:	74 11                	je     8010369e <pipealloc+0x131>
    fileclose(*f0);
8010368d:	8b 45 08             	mov    0x8(%ebp),%eax
80103690:	8b 00                	mov    (%eax),%eax
80103692:	83 ec 0c             	sub    $0xc,%esp
80103695:	50                   	push   %eax
80103696:	e8 0a da ff ff       	call   801010a5 <fileclose>
8010369b:	83 c4 10             	add    $0x10,%esp
  if(*f1)
8010369e:	8b 45 0c             	mov    0xc(%ebp),%eax
801036a1:	8b 00                	mov    (%eax),%eax
801036a3:	85 c0                	test   %eax,%eax
801036a5:	74 11                	je     801036b8 <pipealloc+0x14b>
    fileclose(*f1);
801036a7:	8b 45 0c             	mov    0xc(%ebp),%eax
801036aa:	8b 00                	mov    (%eax),%eax
801036ac:	83 ec 0c             	sub    $0xc,%esp
801036af:	50                   	push   %eax
801036b0:	e8 f0 d9 ff ff       	call   801010a5 <fileclose>
801036b5:	83 c4 10             	add    $0x10,%esp
  return -1;
801036b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801036bd:	c9                   	leave
801036be:	c3                   	ret

801036bf <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
801036bf:	55                   	push   %ebp
801036c0:	89 e5                	mov    %esp,%ebp
801036c2:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
801036c5:	8b 45 08             	mov    0x8(%ebp),%eax
801036c8:	83 ec 0c             	sub    $0xc,%esp
801036cb:	50                   	push   %eax
801036cc:	e8 45 10 00 00       	call   80104716 <acquire>
801036d1:	83 c4 10             	add    $0x10,%esp
  if(writable){
801036d4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801036d8:	74 23                	je     801036fd <pipeclose+0x3e>
    p->writeopen = 0;
801036da:	8b 45 08             	mov    0x8(%ebp),%eax
801036dd:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
801036e4:	00 00 00 
    wakeup(&p->nread);
801036e7:	8b 45 08             	mov    0x8(%ebp),%eax
801036ea:	05 34 02 00 00       	add    $0x234,%eax
801036ef:	83 ec 0c             	sub    $0xc,%esp
801036f2:	50                   	push   %eax
801036f3:	e8 d2 0c 00 00       	call   801043ca <wakeup>
801036f8:	83 c4 10             	add    $0x10,%esp
801036fb:	eb 21                	jmp    8010371e <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801036fd:	8b 45 08             	mov    0x8(%ebp),%eax
80103700:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
80103707:	00 00 00 
    wakeup(&p->nwrite);
8010370a:	8b 45 08             	mov    0x8(%ebp),%eax
8010370d:	05 38 02 00 00       	add    $0x238,%eax
80103712:	83 ec 0c             	sub    $0xc,%esp
80103715:	50                   	push   %eax
80103716:	e8 af 0c 00 00       	call   801043ca <wakeup>
8010371b:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
8010371e:	8b 45 08             	mov    0x8(%ebp),%eax
80103721:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103727:	85 c0                	test   %eax,%eax
80103729:	75 2c                	jne    80103757 <pipeclose+0x98>
8010372b:	8b 45 08             	mov    0x8(%ebp),%eax
8010372e:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80103734:	85 c0                	test   %eax,%eax
80103736:	75 1f                	jne    80103757 <pipeclose+0x98>
    release(&p->lock);
80103738:	8b 45 08             	mov    0x8(%ebp),%eax
8010373b:	83 ec 0c             	sub    $0xc,%esp
8010373e:	50                   	push   %eax
8010373f:	e8 40 10 00 00       	call   80104784 <release>
80103744:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80103747:	83 ec 0c             	sub    $0xc,%esp
8010374a:	ff 75 08             	push   0x8(%ebp)
8010374d:	e8 bc ef ff ff       	call   8010270e <kfree>
80103752:	83 c4 10             	add    $0x10,%esp
80103755:	eb 10                	jmp    80103767 <pipeclose+0xa8>
  } else
    release(&p->lock);
80103757:	8b 45 08             	mov    0x8(%ebp),%eax
8010375a:	83 ec 0c             	sub    $0xc,%esp
8010375d:	50                   	push   %eax
8010375e:	e8 21 10 00 00       	call   80104784 <release>
80103763:	83 c4 10             	add    $0x10,%esp
}
80103766:	90                   	nop
80103767:	90                   	nop
80103768:	c9                   	leave
80103769:	c3                   	ret

8010376a <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	53                   	push   %ebx
8010376e:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80103771:	8b 45 08             	mov    0x8(%ebp),%eax
80103774:	83 ec 0c             	sub    $0xc,%esp
80103777:	50                   	push   %eax
80103778:	e8 99 0f 00 00       	call   80104716 <acquire>
8010377d:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80103780:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103787:	e9 ad 00 00 00       	jmp    80103839 <pipewrite+0xcf>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
8010378c:	8b 45 08             	mov    0x8(%ebp),%eax
8010378f:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
80103795:	85 c0                	test   %eax,%eax
80103797:	74 0c                	je     801037a5 <pipewrite+0x3b>
80103799:	e8 92 02 00 00       	call   80103a30 <myproc>
8010379e:	8b 40 24             	mov    0x24(%eax),%eax
801037a1:	85 c0                	test   %eax,%eax
801037a3:	74 19                	je     801037be <pipewrite+0x54>
        release(&p->lock);
801037a5:	8b 45 08             	mov    0x8(%ebp),%eax
801037a8:	83 ec 0c             	sub    $0xc,%esp
801037ab:	50                   	push   %eax
801037ac:	e8 d3 0f 00 00       	call   80104784 <release>
801037b1:	83 c4 10             	add    $0x10,%esp
        return -1;
801037b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801037b9:	e9 a9 00 00 00       	jmp    80103867 <pipewrite+0xfd>
      }
      wakeup(&p->nread);
801037be:	8b 45 08             	mov    0x8(%ebp),%eax
801037c1:	05 34 02 00 00       	add    $0x234,%eax
801037c6:	83 ec 0c             	sub    $0xc,%esp
801037c9:	50                   	push   %eax
801037ca:	e8 fb 0b 00 00       	call   801043ca <wakeup>
801037cf:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	8b 55 08             	mov    0x8(%ebp),%edx
801037d8:	81 c2 38 02 00 00    	add    $0x238,%edx
801037de:	83 ec 08             	sub    $0x8,%esp
801037e1:	50                   	push   %eax
801037e2:	52                   	push   %edx
801037e3:	e8 fb 0a 00 00       	call   801042e3 <sleep>
801037e8:	83 c4 10             	add    $0x10,%esp
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801037eb:	8b 45 08             	mov    0x8(%ebp),%eax
801037ee:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801037f4:	8b 45 08             	mov    0x8(%ebp),%eax
801037f7:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801037fd:	05 00 02 00 00       	add    $0x200,%eax
80103802:	39 c2                	cmp    %eax,%edx
80103804:	74 86                	je     8010378c <pipewrite+0x22>
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103806:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103809:	8b 45 0c             	mov    0xc(%ebp),%eax
8010380c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010380f:	8b 45 08             	mov    0x8(%ebp),%eax
80103812:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80103818:	8d 48 01             	lea    0x1(%eax),%ecx
8010381b:	8b 55 08             	mov    0x8(%ebp),%edx
8010381e:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80103824:	25 ff 01 00 00       	and    $0x1ff,%eax
80103829:	89 c1                	mov    %eax,%ecx
8010382b:	0f b6 13             	movzbl (%ebx),%edx
8010382e:	8b 45 08             	mov    0x8(%ebp),%eax
80103831:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
  for(i = 0; i < n; i++){
80103835:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103839:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010383c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010383f:	7c aa                	jl     801037eb <pipewrite+0x81>
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103841:	8b 45 08             	mov    0x8(%ebp),%eax
80103844:	05 34 02 00 00       	add    $0x234,%eax
80103849:	83 ec 0c             	sub    $0xc,%esp
8010384c:	50                   	push   %eax
8010384d:	e8 78 0b 00 00       	call   801043ca <wakeup>
80103852:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103855:	8b 45 08             	mov    0x8(%ebp),%eax
80103858:	83 ec 0c             	sub    $0xc,%esp
8010385b:	50                   	push   %eax
8010385c:	e8 23 0f 00 00       	call   80104784 <release>
80103861:	83 c4 10             	add    $0x10,%esp
  return n;
80103864:	8b 45 10             	mov    0x10(%ebp),%eax
}
80103867:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010386a:	c9                   	leave
8010386b:	c3                   	ret

8010386c <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010386c:	55                   	push   %ebp
8010386d:	89 e5                	mov    %esp,%ebp
8010386f:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80103872:	8b 45 08             	mov    0x8(%ebp),%eax
80103875:	83 ec 0c             	sub    $0xc,%esp
80103878:	50                   	push   %eax
80103879:	e8 98 0e 00 00       	call   80104716 <acquire>
8010387e:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103881:	eb 3e                	jmp    801038c1 <piperead+0x55>
    if(myproc()->killed){
80103883:	e8 a8 01 00 00       	call   80103a30 <myproc>
80103888:	8b 40 24             	mov    0x24(%eax),%eax
8010388b:	85 c0                	test   %eax,%eax
8010388d:	74 19                	je     801038a8 <piperead+0x3c>
      release(&p->lock);
8010388f:	8b 45 08             	mov    0x8(%ebp),%eax
80103892:	83 ec 0c             	sub    $0xc,%esp
80103895:	50                   	push   %eax
80103896:	e8 e9 0e 00 00       	call   80104784 <release>
8010389b:	83 c4 10             	add    $0x10,%esp
      return -1;
8010389e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038a3:	e9 be 00 00 00       	jmp    80103966 <piperead+0xfa>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801038a8:	8b 45 08             	mov    0x8(%ebp),%eax
801038ab:	8b 55 08             	mov    0x8(%ebp),%edx
801038ae:	81 c2 34 02 00 00    	add    $0x234,%edx
801038b4:	83 ec 08             	sub    $0x8,%esp
801038b7:	50                   	push   %eax
801038b8:	52                   	push   %edx
801038b9:	e8 25 0a 00 00       	call   801042e3 <sleep>
801038be:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801038c1:	8b 45 08             	mov    0x8(%ebp),%eax
801038c4:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038ca:	8b 45 08             	mov    0x8(%ebp),%eax
801038cd:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038d3:	39 c2                	cmp    %eax,%edx
801038d5:	75 0d                	jne    801038e4 <piperead+0x78>
801038d7:	8b 45 08             	mov    0x8(%ebp),%eax
801038da:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801038e0:	85 c0                	test   %eax,%eax
801038e2:	75 9f                	jne    80103883 <piperead+0x17>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801038e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801038eb:	eb 48                	jmp    80103935 <piperead+0xc9>
    if(p->nread == p->nwrite)
801038ed:	8b 45 08             	mov    0x8(%ebp),%eax
801038f0:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801038f6:	8b 45 08             	mov    0x8(%ebp),%eax
801038f9:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801038ff:	39 c2                	cmp    %eax,%edx
80103901:	74 3c                	je     8010393f <piperead+0xd3>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103903:	8b 45 08             	mov    0x8(%ebp),%eax
80103906:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
8010390c:	8d 48 01             	lea    0x1(%eax),%ecx
8010390f:	8b 55 08             	mov    0x8(%ebp),%edx
80103912:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80103918:	25 ff 01 00 00       	and    $0x1ff,%eax
8010391d:	89 c1                	mov    %eax,%ecx
8010391f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103922:	8b 45 0c             	mov    0xc(%ebp),%eax
80103925:	01 c2                	add    %eax,%edx
80103927:	8b 45 08             	mov    0x8(%ebp),%eax
8010392a:	0f b6 44 08 34       	movzbl 0x34(%eax,%ecx,1),%eax
8010392f:	88 02                	mov    %al,(%edx)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103931:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103935:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103938:	3b 45 10             	cmp    0x10(%ebp),%eax
8010393b:	7c b0                	jl     801038ed <piperead+0x81>
8010393d:	eb 01                	jmp    80103940 <piperead+0xd4>
      break;
8010393f:	90                   	nop
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103940:	8b 45 08             	mov    0x8(%ebp),%eax
80103943:	05 38 02 00 00       	add    $0x238,%eax
80103948:	83 ec 0c             	sub    $0xc,%esp
8010394b:	50                   	push   %eax
8010394c:	e8 79 0a 00 00       	call   801043ca <wakeup>
80103951:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80103954:	8b 45 08             	mov    0x8(%ebp),%eax
80103957:	83 ec 0c             	sub    $0xc,%esp
8010395a:	50                   	push   %eax
8010395b:	e8 24 0e 00 00       	call   80104784 <release>
80103960:	83 c4 10             	add    $0x10,%esp
  return i;
80103963:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103966:	c9                   	leave
80103967:	c3                   	ret

80103968 <readeflags>:
{
80103968:	55                   	push   %ebp
80103969:	89 e5                	mov    %esp,%ebp
8010396b:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010396e:	9c                   	pushf
8010396f:	58                   	pop    %eax
80103970:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80103973:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103976:	c9                   	leave
80103977:	c3                   	ret

80103978 <sti>:
{
80103978:	55                   	push   %ebp
80103979:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
8010397b:	fb                   	sti
}
8010397c:	90                   	nop
8010397d:	5d                   	pop    %ebp
8010397e:	c3                   	ret

8010397f <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010397f:	55                   	push   %ebp
80103980:	89 e5                	mov    %esp,%ebp
80103982:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 90 a2 10 80       	push   $0x8010a290
8010398d:	68 00 42 19 80       	push   $0x80194200
80103992:	e8 5d 0d 00 00       	call   801046f4 <initlock>
80103997:	83 c4 10             	add    $0x10,%esp
}
8010399a:	90                   	nop
8010399b:	c9                   	leave
8010399c:	c3                   	ret

8010399d <cpuid>:

// Must be called with interrupts disabled
int
cpuid() {
8010399d:	55                   	push   %ebp
8010399e:	89 e5                	mov    %esp,%ebp
801039a0:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801039a3:	e8 10 00 00 00       	call   801039b8 <mycpu>
801039a8:	2d 80 6a 19 80       	sub    $0x80196a80,%eax
801039ad:	c1 f8 04             	sar    $0x4,%eax
801039b0:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039b6:	c9                   	leave
801039b7:	c3                   	ret

801039b8 <mycpu>:

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
801039b8:	55                   	push   %ebp
801039b9:	89 e5                	mov    %esp,%ebp
801039bb:	83 ec 18             	sub    $0x18,%esp
  int apicid, i;
  
  if(readeflags()&FL_IF){
801039be:	e8 a5 ff ff ff       	call   80103968 <readeflags>
801039c3:	25 00 02 00 00       	and    $0x200,%eax
801039c8:	85 c0                	test   %eax,%eax
801039ca:	74 0d                	je     801039d9 <mycpu+0x21>
    panic("mycpu called with interrupts enabled\n");
801039cc:	83 ec 0c             	sub    $0xc,%esp
801039cf:	68 98 a2 10 80       	push   $0x8010a298
801039d4:	e8 d0 cb ff ff       	call   801005a9 <panic>
  }

  apicid = lapicid();
801039d9:	e8 1e f1 ff ff       	call   80102afc <lapicid>
801039de:	89 45 f0             	mov    %eax,-0x10(%ebp)
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
801039e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801039e8:	eb 2d                	jmp    80103a17 <mycpu+0x5f>
    if (cpus[i].apicid == apicid){
801039ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ed:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801039f3:	05 80 6a 19 80       	add    $0x80196a80,%eax
801039f8:	0f b6 00             	movzbl (%eax),%eax
801039fb:	0f b6 c0             	movzbl %al,%eax
801039fe:	39 45 f0             	cmp    %eax,-0x10(%ebp)
80103a01:	75 10                	jne    80103a13 <mycpu+0x5b>
      return &cpus[i];
80103a03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a06:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80103a0c:	05 80 6a 19 80       	add    $0x80196a80,%eax
80103a11:	eb 1b                	jmp    80103a2e <mycpu+0x76>
  for (i = 0; i < ncpu; ++i) {
80103a13:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103a17:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80103a1c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80103a1f:	7c c9                	jl     801039ea <mycpu+0x32>
    }
  }
  panic("unknown apicid\n");
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 be a2 10 80       	push   $0x8010a2be
80103a29:	e8 7b cb ff ff       	call   801005a9 <panic>
}
80103a2e:	c9                   	leave
80103a2f:	c3                   	ret

80103a30 <myproc>:

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
80103a30:	55                   	push   %ebp
80103a31:	89 e5                	mov    %esp,%ebp
80103a33:	83 ec 18             	sub    $0x18,%esp
  struct cpu *c;
  struct proc *p;
  pushcli();
80103a36:	e8 46 0e 00 00       	call   80104881 <pushcli>
  c = mycpu();
80103a3b:	e8 78 ff ff ff       	call   801039b8 <mycpu>
80103a40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  p = c->proc;
80103a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a46:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80103a4c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  popcli();
80103a4f:	e8 7a 0e 00 00       	call   801048ce <popcli>
  return p;
80103a54:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103a57:	c9                   	leave
80103a58:	c3                   	ret

80103a59 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103a59:	55                   	push   %ebp
80103a5a:	89 e5                	mov    %esp,%ebp
80103a5c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
80103a5f:	83 ec 0c             	sub    $0xc,%esp
80103a62:	68 00 42 19 80       	push   $0x80194200
80103a67:	e8 aa 0c 00 00       	call   80104716 <acquire>
80103a6c:	83 c4 10             	add    $0x10,%esp

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a6f:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103a76:	eb 0e                	jmp    80103a86 <allocproc+0x2d>
    if(p->state == UNUSED){
80103a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80103a7e:	85 c0                	test   %eax,%eax
80103a80:	74 27                	je     80103aa9 <allocproc+0x50>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103a82:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103a86:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103a8d:	72 e9                	jb     80103a78 <allocproc+0x1f>
      goto found;
    }

  release(&ptable.lock);
80103a8f:	83 ec 0c             	sub    $0xc,%esp
80103a92:	68 00 42 19 80       	push   $0x80194200
80103a97:	e8 e8 0c 00 00       	call   80104784 <release>
80103a9c:	83 c4 10             	add    $0x10,%esp
  return 0;
80103a9f:	b8 00 00 00 00       	mov    $0x0,%eax
80103aa4:	e9 bc 00 00 00       	jmp    80103b65 <allocproc+0x10c>
      goto found;
80103aa9:	90                   	nop

found:
  p->state = EMBRYO;
80103aaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103aad:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80103ab4:	a1 00 f0 10 80       	mov    0x8010f000,%eax
80103ab9:	8d 50 01             	lea    0x1(%eax),%edx
80103abc:	89 15 00 f0 10 80    	mov    %edx,0x8010f000
80103ac2:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ac5:	89 42 10             	mov    %eax,0x10(%edx)
  //LAB2 추가
  p->scheduler=-1; 
80103ac8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103acb:	c7 40 7c ff ff ff ff 	movl   $0xffffffff,0x7c(%eax)
  release(&ptable.lock);
80103ad2:	83 ec 0c             	sub    $0xc,%esp
80103ad5:	68 00 42 19 80       	push   $0x80194200
80103ada:	e8 a5 0c 00 00       	call   80104784 <release>
80103adf:	83 c4 10             	add    $0x10,%esp


  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103ae2:	e8 c1 ec ff ff       	call   801027a8 <kalloc>
80103ae7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103aea:	89 42 08             	mov    %eax,0x8(%edx)
80103aed:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af0:	8b 40 08             	mov    0x8(%eax),%eax
80103af3:	85 c0                	test   %eax,%eax
80103af5:	75 11                	jne    80103b08 <allocproc+0xaf>
    p->state = UNUSED;
80103af7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103afa:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80103b01:	b8 00 00 00 00       	mov    $0x0,%eax
80103b06:	eb 5d                	jmp    80103b65 <allocproc+0x10c>
  }
  sp = p->kstack + KSTACKSIZE;
80103b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b0b:	8b 40 08             	mov    0x8(%eax),%eax
80103b0e:	05 00 10 00 00       	add    $0x1000,%eax
80103b13:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103b16:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80103b1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b20:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80103b23:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80103b27:	ba 48 5d 10 80       	mov    $0x80105d48,%edx
80103b2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2f:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
80103b31:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80103b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b38:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103b3b:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
80103b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b41:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b44:	83 ec 04             	sub    $0x4,%esp
80103b47:	6a 14                	push   $0x14
80103b49:	6a 00                	push   $0x0
80103b4b:	50                   	push   %eax
80103b4c:	e8 3b 0e 00 00       	call   8010498c <memset>
80103b51:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103b54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b57:	8b 40 1c             	mov    0x1c(%eax),%eax
80103b5a:	ba 9d 42 10 80       	mov    $0x8010429d,%edx
80103b5f:	89 50 10             	mov    %edx,0x10(%eax)

  return p;
80103b62:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80103b65:	c9                   	leave
80103b66:	c3                   	ret

80103b67 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80103b67:	55                   	push   %ebp
80103b68:	89 e5                	mov    %esp,%ebp
80103b6a:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
80103b6d:	e8 e7 fe ff ff       	call   80103a59 <allocproc>
80103b72:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  initproc = p;
80103b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b78:	a3 34 62 19 80       	mov    %eax,0x80196234
  if((p->pgdir = setupkvm()) == 0){
80103b7d:	e8 72 37 00 00       	call   801072f4 <setupkvm>
80103b82:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103b85:	89 42 04             	mov    %eax,0x4(%edx)
80103b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b8b:	8b 40 04             	mov    0x4(%eax),%eax
80103b8e:	85 c0                	test   %eax,%eax
80103b90:	75 0d                	jne    80103b9f <userinit+0x38>
    panic("userinit: out of memory?");
80103b92:	83 ec 0c             	sub    $0xc,%esp
80103b95:	68 ce a2 10 80       	push   $0x8010a2ce
80103b9a:	e8 0a ca ff ff       	call   801005a9 <panic>
  }
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103b9f:	ba 2c 00 00 00       	mov    $0x2c,%edx
80103ba4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba7:	8b 40 04             	mov    0x4(%eax),%eax
80103baa:	83 ec 04             	sub    $0x4,%esp
80103bad:	52                   	push   %edx
80103bae:	68 ec f4 10 80       	push   $0x8010f4ec
80103bb3:	50                   	push   %eax
80103bb4:	e8 f8 39 00 00       	call   801075b1 <inituvm>
80103bb9:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80103bbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bbf:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80103bc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bc8:	8b 40 18             	mov    0x18(%eax),%eax
80103bcb:	83 ec 04             	sub    $0x4,%esp
80103bce:	6a 4c                	push   $0x4c
80103bd0:	6a 00                	push   $0x0
80103bd2:	50                   	push   %eax
80103bd3:	e8 b4 0d 00 00       	call   8010498c <memset>
80103bd8:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bde:	8b 40 18             	mov    0x18(%eax),%eax
80103be1:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bea:	8b 40 18             	mov    0x18(%eax),%eax
80103bed:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf6:	8b 50 18             	mov    0x18(%eax),%edx
80103bf9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bfc:	8b 40 18             	mov    0x18(%eax),%eax
80103bff:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c03:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103c07:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c0a:	8b 50 18             	mov    0x18(%eax),%edx
80103c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c10:	8b 40 18             	mov    0x18(%eax),%eax
80103c13:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80103c17:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103c1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c1e:	8b 40 18             	mov    0x18(%eax),%eax
80103c21:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103c28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c2b:	8b 40 18             	mov    0x18(%eax),%eax
80103c2e:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c38:	8b 40 18             	mov    0x18(%eax),%eax
80103c3b:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80103c42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c45:	83 c0 6c             	add    $0x6c,%eax
80103c48:	83 ec 04             	sub    $0x4,%esp
80103c4b:	6a 10                	push   $0x10
80103c4d:	68 e7 a2 10 80       	push   $0x8010a2e7
80103c52:	50                   	push   %eax
80103c53:	e8 37 0f 00 00       	call   80104b8f <safestrcpy>
80103c58:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
80103c5b:	83 ec 0c             	sub    $0xc,%esp
80103c5e:	68 f0 a2 10 80       	push   $0x8010a2f0
80103c63:	e8 bd e8 ff ff       	call   80102525 <namei>
80103c68:	83 c4 10             	add    $0x10,%esp
80103c6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c6e:	89 42 68             	mov    %eax,0x68(%edx)

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);
80103c71:	83 ec 0c             	sub    $0xc,%esp
80103c74:	68 00 42 19 80       	push   $0x80194200
80103c79:	e8 98 0a 00 00       	call   80104716 <acquire>
80103c7e:	83 c4 10             	add    $0x10,%esp

  p->state = RUNNABLE;
80103c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c84:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103c8b:	83 ec 0c             	sub    $0xc,%esp
80103c8e:	68 00 42 19 80       	push   $0x80194200
80103c93:	e8 ec 0a 00 00       	call   80104784 <release>
80103c98:	83 c4 10             	add    $0x10,%esp
}
80103c9b:	90                   	nop
80103c9c:	c9                   	leave
80103c9d:	c3                   	ret

80103c9e <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
80103c9e:	55                   	push   %ebp
80103c9f:	89 e5                	mov    %esp,%ebp
80103ca1:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  struct proc *curproc = myproc();
80103ca4:	e8 87 fd ff ff       	call   80103a30 <myproc>
80103ca9:	89 45 f0             	mov    %eax,-0x10(%ebp)

  sz = curproc->sz;
80103cac:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103caf:	8b 00                	mov    (%eax),%eax
80103cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80103cb4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cb8:	7e 2e                	jle    80103ce8 <growproc+0x4a>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cba:	8b 55 08             	mov    0x8(%ebp),%edx
80103cbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cc0:	01 c2                	add    %eax,%edx
80103cc2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc5:	8b 40 04             	mov    0x4(%eax),%eax
80103cc8:	83 ec 04             	sub    $0x4,%esp
80103ccb:	52                   	push   %edx
80103ccc:	ff 75 f4             	push   -0xc(%ebp)
80103ccf:	50                   	push   %eax
80103cd0:	e8 19 3a 00 00       	call   801076ee <allocuvm>
80103cd5:	83 c4 10             	add    $0x10,%esp
80103cd8:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cdb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103cdf:	75 3b                	jne    80103d1c <growproc+0x7e>
      return -1;
80103ce1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ce6:	eb 4f                	jmp    80103d37 <growproc+0x99>
  } else if(n < 0){
80103ce8:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80103cec:	79 2e                	jns    80103d1c <growproc+0x7e>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103cee:	8b 55 08             	mov    0x8(%ebp),%edx
80103cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf4:	01 c2                	add    %eax,%edx
80103cf6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cf9:	8b 40 04             	mov    0x4(%eax),%eax
80103cfc:	83 ec 04             	sub    $0x4,%esp
80103cff:	52                   	push   %edx
80103d00:	ff 75 f4             	push   -0xc(%ebp)
80103d03:	50                   	push   %eax
80103d04:	e8 ea 3a 00 00       	call   801077f3 <deallocuvm>
80103d09:	83 c4 10             	add    $0x10,%esp
80103d0c:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d0f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103d13:	75 07                	jne    80103d1c <growproc+0x7e>
      return -1;
80103d15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d1a:	eb 1b                	jmp    80103d37 <growproc+0x99>
  }
  curproc->sz = sz;
80103d1c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d1f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103d22:	89 10                	mov    %edx,(%eax)
  switchuvm(curproc);
80103d24:	83 ec 0c             	sub    $0xc,%esp
80103d27:	ff 75 f0             	push   -0x10(%ebp)
80103d2a:	e8 e3 36 00 00       	call   80107412 <switchuvm>
80103d2f:	83 c4 10             	add    $0x10,%esp
  return 0;
80103d32:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103d37:	c9                   	leave
80103d38:	c3                   	ret

80103d39 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80103d39:	55                   	push   %ebp
80103d3a:	89 e5                	mov    %esp,%ebp
80103d3c:	57                   	push   %edi
80103d3d:	56                   	push   %esi
80103d3e:	53                   	push   %ebx
80103d3f:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();
80103d42:	e8 e9 fc ff ff       	call   80103a30 <myproc>
80103d47:	89 45 e0             	mov    %eax,-0x20(%ebp)

  // Allocate process.
  if((np = allocproc()) == 0){
80103d4a:	e8 0a fd ff ff       	call   80103a59 <allocproc>
80103d4f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80103d52:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
80103d56:	75 0a                	jne    80103d62 <fork+0x29>
    return -1;
80103d58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103d5d:	e9 48 01 00 00       	jmp    80103eaa <fork+0x171>
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103d62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d65:	8b 10                	mov    (%eax),%edx
80103d67:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103d6a:	8b 40 04             	mov    0x4(%eax),%eax
80103d6d:	83 ec 08             	sub    $0x8,%esp
80103d70:	52                   	push   %edx
80103d71:	50                   	push   %eax
80103d72:	e8 1a 3c 00 00       	call   80107991 <copyuvm>
80103d77:	83 c4 10             	add    $0x10,%esp
80103d7a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103d7d:	89 42 04             	mov    %eax,0x4(%edx)
80103d80:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d83:	8b 40 04             	mov    0x4(%eax),%eax
80103d86:	85 c0                	test   %eax,%eax
80103d88:	75 30                	jne    80103dba <fork+0x81>
    kfree(np->kstack);
80103d8a:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d8d:	8b 40 08             	mov    0x8(%eax),%eax
80103d90:	83 ec 0c             	sub    $0xc,%esp
80103d93:	50                   	push   %eax
80103d94:	e8 75 e9 ff ff       	call   8010270e <kfree>
80103d99:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103d9c:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103d9f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
80103da6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103da9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80103db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103db5:	e9 f0 00 00 00       	jmp    80103eaa <fork+0x171>
  }
  np->sz = curproc->sz;
80103dba:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dbd:	8b 10                	mov    (%eax),%edx
80103dbf:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc2:	89 10                	mov    %edx,(%eax)
  np->parent = curproc;
80103dc4:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dc7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103dca:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *curproc->tf;
80103dcd:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dd0:	8b 48 18             	mov    0x18(%eax),%ecx
80103dd3:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103dd6:	8b 40 18             	mov    0x18(%eax),%eax
80103dd9:	89 c2                	mov    %eax,%edx
80103ddb:	89 cb                	mov    %ecx,%ebx
80103ddd:	b8 13 00 00 00       	mov    $0x13,%eax
80103de2:	89 d7                	mov    %edx,%edi
80103de4:	89 de                	mov    %ebx,%esi
80103de6:	89 c1                	mov    %eax,%ecx
80103de8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
80103dea:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103ded:	8b 40 18             	mov    0x18(%eax),%eax
80103df0:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80103df7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80103dfe:	eb 3b                	jmp    80103e3b <fork+0x102>
    if(curproc->ofile[i])
80103e00:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e03:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e06:	83 c2 08             	add    $0x8,%edx
80103e09:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e0d:	85 c0                	test   %eax,%eax
80103e0f:	74 26                	je     80103e37 <fork+0xfe>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103e11:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e14:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103e17:	83 c2 08             	add    $0x8,%edx
80103e1a:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103e1e:	83 ec 0c             	sub    $0xc,%esp
80103e21:	50                   	push   %eax
80103e22:	e8 2d d2 ff ff       	call   80101054 <filedup>
80103e27:	83 c4 10             	add    $0x10,%esp
80103e2a:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e2d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103e30:	83 c1 08             	add    $0x8,%ecx
80103e33:	89 44 8a 08          	mov    %eax,0x8(%edx,%ecx,4)
  for(i = 0; i < NOFILE; i++)
80103e37:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80103e3b:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
80103e3f:	7e bf                	jle    80103e00 <fork+0xc7>
  np->cwd = idup(curproc->cwd);
80103e41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e44:	8b 40 68             	mov    0x68(%eax),%eax
80103e47:	83 ec 0c             	sub    $0xc,%esp
80103e4a:	50                   	push   %eax
80103e4b:	e8 68 db ff ff       	call   801019b8 <idup>
80103e50:	83 c4 10             	add    $0x10,%esp
80103e53:	8b 55 dc             	mov    -0x24(%ebp),%edx
80103e56:	89 42 68             	mov    %eax,0x68(%edx)

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103e59:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e5c:	8d 50 6c             	lea    0x6c(%eax),%edx
80103e5f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e62:	83 c0 6c             	add    $0x6c,%eax
80103e65:	83 ec 04             	sub    $0x4,%esp
80103e68:	6a 10                	push   $0x10
80103e6a:	52                   	push   %edx
80103e6b:	50                   	push   %eax
80103e6c:	e8 1e 0d 00 00       	call   80104b8f <safestrcpy>
80103e71:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80103e74:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e77:	8b 40 10             	mov    0x10(%eax),%eax
80103e7a:	89 45 d8             	mov    %eax,-0x28(%ebp)

  acquire(&ptable.lock);
80103e7d:	83 ec 0c             	sub    $0xc,%esp
80103e80:	68 00 42 19 80       	push   $0x80194200
80103e85:	e8 8c 08 00 00       	call   80104716 <acquire>
80103e8a:	83 c4 10             	add    $0x10,%esp

  np->state = RUNNABLE;
80103e8d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103e90:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)

  release(&ptable.lock);
80103e97:	83 ec 0c             	sub    $0xc,%esp
80103e9a:	68 00 42 19 80       	push   $0x80194200
80103e9f:	e8 e0 08 00 00       	call   80104784 <release>
80103ea4:	83 c4 10             	add    $0x10,%esp

  return pid;
80103ea7:	8b 45 d8             	mov    -0x28(%ebp),%eax
}
80103eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103ead:	5b                   	pop    %ebx
80103eae:	5e                   	pop    %esi
80103eaf:	5f                   	pop    %edi
80103eb0:	5d                   	pop    %ebp
80103eb1:	c3                   	ret

80103eb2 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80103eb2:	55                   	push   %ebp
80103eb3:	89 e5                	mov    %esp,%ebp
80103eb5:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80103eb8:	e8 73 fb ff ff       	call   80103a30 <myproc>
80103ebd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct proc *p;
  int fd;

  if(curproc == initproc)
80103ec0:	a1 34 62 19 80       	mov    0x80196234,%eax
80103ec5:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103ec8:	75 0d                	jne    80103ed7 <exit+0x25>
    panic("init exiting");
80103eca:	83 ec 0c             	sub    $0xc,%esp
80103ecd:	68 f2 a2 10 80       	push   $0x8010a2f2
80103ed2:	e8 d2 c6 ff ff       	call   801005a9 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80103ed7:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80103ede:	eb 3f                	jmp    80103f1f <exit+0x6d>
    if(curproc->ofile[fd]){
80103ee0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ee3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ee6:	83 c2 08             	add    $0x8,%edx
80103ee9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103eed:	85 c0                	test   %eax,%eax
80103eef:	74 2a                	je     80103f1b <exit+0x69>
      fileclose(curproc->ofile[fd]);
80103ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103ef4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103ef7:	83 c2 08             	add    $0x8,%edx
80103efa:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80103efe:	83 ec 0c             	sub    $0xc,%esp
80103f01:	50                   	push   %eax
80103f02:	e8 9e d1 ff ff       	call   801010a5 <fileclose>
80103f07:	83 c4 10             	add    $0x10,%esp
      curproc->ofile[fd] = 0;
80103f0a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f0d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80103f10:	83 c2 08             	add    $0x8,%edx
80103f13:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80103f1a:	00 
  for(fd = 0; fd < NOFILE; fd++){
80103f1b:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80103f1f:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80103f23:	7e bb                	jle    80103ee0 <exit+0x2e>
    }
  }

  begin_op();
80103f25:	e8 14 f1 ff ff       	call   8010303e <begin_op>
  iput(curproc->cwd);
80103f2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f2d:	8b 40 68             	mov    0x68(%eax),%eax
80103f30:	83 ec 0c             	sub    $0xc,%esp
80103f33:	50                   	push   %eax
80103f34:	e8 1a dc ff ff       	call   80101b53 <iput>
80103f39:	83 c4 10             	add    $0x10,%esp
  end_op();
80103f3c:	e8 89 f1 ff ff       	call   801030ca <end_op>
  curproc->cwd = 0;
80103f41:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f44:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80103f4b:	83 ec 0c             	sub    $0xc,%esp
80103f4e:	68 00 42 19 80       	push   $0x80194200
80103f53:	e8 be 07 00 00       	call   80104716 <acquire>
80103f58:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);
80103f5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103f5e:	8b 40 14             	mov    0x14(%eax),%eax
80103f61:	83 ec 0c             	sub    $0xc,%esp
80103f64:	50                   	push   %eax
80103f65:	e8 20 04 00 00       	call   8010438a <wakeup1>
80103f6a:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f6d:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103f74:	eb 37                	jmp    80103fad <exit+0xfb>
    if(p->parent == curproc){
80103f76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f79:	8b 40 14             	mov    0x14(%eax),%eax
80103f7c:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80103f7f:	75 28                	jne    80103fa9 <exit+0xf7>
      p->parent = initproc;
80103f81:	8b 15 34 62 19 80    	mov    0x80196234,%edx
80103f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f8a:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80103f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f90:	8b 40 0c             	mov    0xc(%eax),%eax
80103f93:	83 f8 05             	cmp    $0x5,%eax
80103f96:	75 11                	jne    80103fa9 <exit+0xf7>
        wakeup1(initproc);
80103f98:	a1 34 62 19 80       	mov    0x80196234,%eax
80103f9d:	83 ec 0c             	sub    $0xc,%esp
80103fa0:	50                   	push   %eax
80103fa1:	e8 e4 03 00 00       	call   8010438a <wakeup1>
80103fa6:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103fa9:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80103fad:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80103fb4:	72 c0                	jb     80103f76 <exit+0xc4>
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
80103fb6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103fb9:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80103fc0:	e8 e5 01 00 00       	call   801041aa <sched>
  panic("zombie exit");
80103fc5:	83 ec 0c             	sub    $0xc,%esp
80103fc8:	68 ff a2 10 80       	push   $0x8010a2ff
80103fcd:	e8 d7 c5 ff ff       	call   801005a9 <panic>

80103fd2 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80103fd2:	55                   	push   %ebp
80103fd3:	89 e5                	mov    %esp,%ebp
80103fd5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
80103fd8:	e8 53 fa ff ff       	call   80103a30 <myproc>
80103fdd:	89 45 ec             	mov    %eax,-0x14(%ebp)
  
  acquire(&ptable.lock);
80103fe0:	83 ec 0c             	sub    $0xc,%esp
80103fe3:	68 00 42 19 80       	push   $0x80194200
80103fe8:	e8 29 07 00 00       	call   80104716 <acquire>
80103fed:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
80103ff0:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ff7:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80103ffe:	e9 a1 00 00 00       	jmp    801040a4 <wait+0xd2>
      if(p->parent != curproc)
80104003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104006:	8b 40 14             	mov    0x14(%eax),%eax
80104009:	39 45 ec             	cmp    %eax,-0x14(%ebp)
8010400c:	0f 85 8d 00 00 00    	jne    8010409f <wait+0xcd>
        continue;
      havekids = 1;
80104012:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104019:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010401c:	8b 40 0c             	mov    0xc(%eax),%eax
8010401f:	83 f8 05             	cmp    $0x5,%eax
80104022:	75 7c                	jne    801040a0 <wait+0xce>
        // Found one.
        pid = p->pid;
80104024:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104027:	8b 40 10             	mov    0x10(%eax),%eax
8010402a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        kfree(p->kstack);
8010402d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104030:	8b 40 08             	mov    0x8(%eax),%eax
80104033:	83 ec 0c             	sub    $0xc,%esp
80104036:	50                   	push   %eax
80104037:	e8 d2 e6 ff ff       	call   8010270e <kfree>
8010403c:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
8010403f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104042:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104049:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404c:	8b 40 04             	mov    0x4(%eax),%eax
8010404f:	83 ec 0c             	sub    $0xc,%esp
80104052:	50                   	push   %eax
80104053:	e8 5f 38 00 00       	call   801078b7 <freevm>
80104058:	83 c4 10             	add    $0x10,%esp
        p->pid = 0;
8010405b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010405e:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104065:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104068:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
8010406f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104072:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104076:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104079:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        p->state = UNUSED;
80104080:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104083:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        release(&ptable.lock);
8010408a:	83 ec 0c             	sub    $0xc,%esp
8010408d:	68 00 42 19 80       	push   $0x80194200
80104092:	e8 ed 06 00 00       	call   80104784 <release>
80104097:	83 c4 10             	add    $0x10,%esp
        return pid;
8010409a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010409d:	eb 51                	jmp    801040f0 <wait+0x11e>
        continue;
8010409f:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801040a0:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
801040a4:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
801040ab:	0f 82 52 ff ff ff    	jb     80104003 <wait+0x31>
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
801040b1:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801040b5:	74 0a                	je     801040c1 <wait+0xef>
801040b7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801040ba:	8b 40 24             	mov    0x24(%eax),%eax
801040bd:	85 c0                	test   %eax,%eax
801040bf:	74 17                	je     801040d8 <wait+0x106>
      release(&ptable.lock);
801040c1:	83 ec 0c             	sub    $0xc,%esp
801040c4:	68 00 42 19 80       	push   $0x80194200
801040c9:	e8 b6 06 00 00       	call   80104784 <release>
801040ce:	83 c4 10             	add    $0x10,%esp
      return -1;
801040d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d6:	eb 18                	jmp    801040f0 <wait+0x11e>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801040d8:	83 ec 08             	sub    $0x8,%esp
801040db:	68 00 42 19 80       	push   $0x80194200
801040e0:	ff 75 ec             	push   -0x14(%ebp)
801040e3:	e8 fb 01 00 00       	call   801042e3 <sleep>
801040e8:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801040eb:	e9 00 ff ff ff       	jmp    80103ff0 <wait+0x1e>
  }
}
801040f0:	c9                   	leave
801040f1:	c3                   	ret

801040f2 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
801040f2:	55                   	push   %ebp
801040f3:	89 e5                	mov    %esp,%ebp
801040f5:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  struct cpu *c = mycpu();
801040f8:	e8 bb f8 ff ff       	call   801039b8 <mycpu>
801040fd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  c->proc = 0;
80104100:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104103:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
8010410a:	00 00 00 
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
8010410d:	e8 66 f8 ff ff       	call   80103978 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104112:	83 ec 0c             	sub    $0xc,%esp
80104115:	68 00 42 19 80       	push   $0x80194200
8010411a:	e8 f7 05 00 00       	call   80104716 <acquire>
8010411f:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104122:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
80104129:	eb 61                	jmp    8010418c <scheduler+0x9a>
      if(p->state != RUNNABLE)
8010412b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010412e:	8b 40 0c             	mov    0xc(%eax),%eax
80104131:	83 f8 03             	cmp    $0x3,%eax
80104134:	75 51                	jne    80104187 <scheduler+0x95>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
80104136:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104139:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010413c:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
      switchuvm(p);
80104142:	83 ec 0c             	sub    $0xc,%esp
80104145:	ff 75 f4             	push   -0xc(%ebp)
80104148:	e8 c5 32 00 00       	call   80107412 <switchuvm>
8010414d:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104150:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104153:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)

      swtch(&(c->scheduler), p->context);
8010415a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010415d:	8b 40 1c             	mov    0x1c(%eax),%eax
80104160:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104163:	83 c2 04             	add    $0x4,%edx
80104166:	83 ec 08             	sub    $0x8,%esp
80104169:	50                   	push   %eax
8010416a:	52                   	push   %edx
8010416b:	e8 91 0a 00 00       	call   80104c01 <swtch>
80104170:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104173:	e8 81 32 00 00       	call   801073f9 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
80104178:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010417b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80104182:	00 00 00 
80104185:	eb 01                	jmp    80104188 <scheduler+0x96>
        continue;
80104187:	90                   	nop
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104188:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
8010418c:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
80104193:	72 96                	jb     8010412b <scheduler+0x39>
    }
    release(&ptable.lock);
80104195:	83 ec 0c             	sub    $0xc,%esp
80104198:	68 00 42 19 80       	push   $0x80194200
8010419d:	e8 e2 05 00 00       	call   80104784 <release>
801041a2:	83 c4 10             	add    $0x10,%esp
    sti();
801041a5:	e9 63 ff ff ff       	jmp    8010410d <scheduler+0x1b>

801041aa <sched>:
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
801041aa:	55                   	push   %ebp
801041ab:	89 e5                	mov    %esp,%ebp
801041ad:	83 ec 18             	sub    $0x18,%esp
  int intena;
  struct proc *p = myproc();
801041b0:	e8 7b f8 ff ff       	call   80103a30 <myproc>
801041b5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(!holding(&ptable.lock))
801041b8:	83 ec 0c             	sub    $0xc,%esp
801041bb:	68 00 42 19 80       	push   $0x80194200
801041c0:	e8 8c 06 00 00       	call   80104851 <holding>
801041c5:	83 c4 10             	add    $0x10,%esp
801041c8:	85 c0                	test   %eax,%eax
801041ca:	75 0d                	jne    801041d9 <sched+0x2f>
    panic("sched ptable.lock");
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	68 0b a3 10 80       	push   $0x8010a30b
801041d4:	e8 d0 c3 ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli != 1)
801041d9:	e8 da f7 ff ff       	call   801039b8 <mycpu>
801041de:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
801041e4:	83 f8 01             	cmp    $0x1,%eax
801041e7:	74 0d                	je     801041f6 <sched+0x4c>
    panic("sched locks");
801041e9:	83 ec 0c             	sub    $0xc,%esp
801041ec:	68 1d a3 10 80       	push   $0x8010a31d
801041f1:	e8 b3 c3 ff ff       	call   801005a9 <panic>
  if(p->state == RUNNING)
801041f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801041f9:	8b 40 0c             	mov    0xc(%eax),%eax
801041fc:	83 f8 04             	cmp    $0x4,%eax
801041ff:	75 0d                	jne    8010420e <sched+0x64>
    panic("sched running");
80104201:	83 ec 0c             	sub    $0xc,%esp
80104204:	68 29 a3 10 80       	push   $0x8010a329
80104209:	e8 9b c3 ff ff       	call   801005a9 <panic>
  if(readeflags()&FL_IF)
8010420e:	e8 55 f7 ff ff       	call   80103968 <readeflags>
80104213:	25 00 02 00 00       	and    $0x200,%eax
80104218:	85 c0                	test   %eax,%eax
8010421a:	74 0d                	je     80104229 <sched+0x7f>
    panic("sched interruptible");
8010421c:	83 ec 0c             	sub    $0xc,%esp
8010421f:	68 37 a3 10 80       	push   $0x8010a337
80104224:	e8 80 c3 ff ff       	call   801005a9 <panic>
  intena = mycpu()->intena;
80104229:	e8 8a f7 ff ff       	call   801039b8 <mycpu>
8010422e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104234:	89 45 f0             	mov    %eax,-0x10(%ebp)
  swtch(&p->context, mycpu()->scheduler);
80104237:	e8 7c f7 ff ff       	call   801039b8 <mycpu>
8010423c:	8b 40 04             	mov    0x4(%eax),%eax
8010423f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104242:	83 c2 1c             	add    $0x1c,%edx
80104245:	83 ec 08             	sub    $0x8,%esp
80104248:	50                   	push   %eax
80104249:	52                   	push   %edx
8010424a:	e8 b2 09 00 00       	call   80104c01 <swtch>
8010424f:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80104252:	e8 61 f7 ff ff       	call   801039b8 <mycpu>
80104257:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010425a:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
}
80104260:	90                   	nop
80104261:	c9                   	leave
80104262:	c3                   	ret

80104263 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104263:	55                   	push   %ebp
80104264:	89 e5                	mov    %esp,%ebp
80104266:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104269:	83 ec 0c             	sub    $0xc,%esp
8010426c:	68 00 42 19 80       	push   $0x80194200
80104271:	e8 a0 04 00 00       	call   80104716 <acquire>
80104276:	83 c4 10             	add    $0x10,%esp
  myproc()->state = RUNNABLE;
80104279:	e8 b2 f7 ff ff       	call   80103a30 <myproc>
8010427e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104285:	e8 20 ff ff ff       	call   801041aa <sched>
  release(&ptable.lock);
8010428a:	83 ec 0c             	sub    $0xc,%esp
8010428d:	68 00 42 19 80       	push   $0x80194200
80104292:	e8 ed 04 00 00       	call   80104784 <release>
80104297:	83 c4 10             	add    $0x10,%esp
}
8010429a:	90                   	nop
8010429b:	c9                   	leave
8010429c:	c3                   	ret

8010429d <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
8010429d:	55                   	push   %ebp
8010429e:	89 e5                	mov    %esp,%ebp
801042a0:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801042a3:	83 ec 0c             	sub    $0xc,%esp
801042a6:	68 00 42 19 80       	push   $0x80194200
801042ab:	e8 d4 04 00 00       	call   80104784 <release>
801042b0:	83 c4 10             	add    $0x10,%esp

  if (first) {
801042b3:	a1 04 f0 10 80       	mov    0x8010f004,%eax
801042b8:	85 c0                	test   %eax,%eax
801042ba:	74 24                	je     801042e0 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
801042bc:	c7 05 04 f0 10 80 00 	movl   $0x0,0x8010f004
801042c3:	00 00 00 
    iinit(ROOTDEV);
801042c6:	83 ec 0c             	sub    $0xc,%esp
801042c9:	6a 01                	push   $0x1
801042cb:	e8 b1 d3 ff ff       	call   80101681 <iinit>
801042d0:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
801042d3:	83 ec 0c             	sub    $0xc,%esp
801042d6:	6a 01                	push   $0x1
801042d8:	e8 42 eb ff ff       	call   80102e1f <initlog>
801042dd:	83 c4 10             	add    $0x10,%esp
  }

  // Return to "caller", actually trapret (see allocproc).
}
801042e0:	90                   	nop
801042e1:	c9                   	leave
801042e2:	c3                   	ret

801042e3 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
801042e3:	55                   	push   %ebp
801042e4:	89 e5                	mov    %esp,%ebp
801042e6:	83 ec 18             	sub    $0x18,%esp
  struct proc *p = myproc();
801042e9:	e8 42 f7 ff ff       	call   80103a30 <myproc>
801042ee:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  if(p == 0)
801042f1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801042f5:	75 0d                	jne    80104304 <sleep+0x21>
    panic("sleep");
801042f7:	83 ec 0c             	sub    $0xc,%esp
801042fa:	68 4b a3 10 80       	push   $0x8010a34b
801042ff:	e8 a5 c2 ff ff       	call   801005a9 <panic>

  if(lk == 0)
80104304:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104308:	75 0d                	jne    80104317 <sleep+0x34>
    panic("sleep without lk");
8010430a:	83 ec 0c             	sub    $0xc,%esp
8010430d:	68 51 a3 10 80       	push   $0x8010a351
80104312:	e8 92 c2 ff ff       	call   801005a9 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104317:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
8010431e:	74 1e                	je     8010433e <sleep+0x5b>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104320:	83 ec 0c             	sub    $0xc,%esp
80104323:	68 00 42 19 80       	push   $0x80194200
80104328:	e8 e9 03 00 00       	call   80104716 <acquire>
8010432d:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104330:	83 ec 0c             	sub    $0xc,%esp
80104333:	ff 75 0c             	push   0xc(%ebp)
80104336:	e8 49 04 00 00       	call   80104784 <release>
8010433b:	83 c4 10             	add    $0x10,%esp
  }
  // Go to sleep.
  p->chan = chan;
8010433e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104341:	8b 55 08             	mov    0x8(%ebp),%edx
80104344:	89 50 20             	mov    %edx,0x20(%eax)
  p->state = SLEEPING;
80104347:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010434a:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)

  sched();
80104351:	e8 54 fe ff ff       	call   801041aa <sched>

  // Tidy up.
  p->chan = 0;
80104356:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104359:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104360:	81 7d 0c 00 42 19 80 	cmpl   $0x80194200,0xc(%ebp)
80104367:	74 1e                	je     80104387 <sleep+0xa4>
    release(&ptable.lock);
80104369:	83 ec 0c             	sub    $0xc,%esp
8010436c:	68 00 42 19 80       	push   $0x80194200
80104371:	e8 0e 04 00 00       	call   80104784 <release>
80104376:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104379:	83 ec 0c             	sub    $0xc,%esp
8010437c:	ff 75 0c             	push   0xc(%ebp)
8010437f:	e8 92 03 00 00       	call   80104716 <acquire>
80104384:	83 c4 10             	add    $0x10,%esp
  }
}
80104387:	90                   	nop
80104388:	c9                   	leave
80104389:	c3                   	ret

8010438a <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
8010438a:	55                   	push   %ebp
8010438b:	89 e5                	mov    %esp,%ebp
8010438d:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104390:	c7 45 fc 34 42 19 80 	movl   $0x80194234,-0x4(%ebp)
80104397:	eb 24                	jmp    801043bd <wakeup1+0x33>
    if(p->state == SLEEPING && p->chan == chan)
80104399:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010439c:	8b 40 0c             	mov    0xc(%eax),%eax
8010439f:	83 f8 02             	cmp    $0x2,%eax
801043a2:	75 15                	jne    801043b9 <wakeup1+0x2f>
801043a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043a7:	8b 40 20             	mov    0x20(%eax),%eax
801043aa:	39 45 08             	cmp    %eax,0x8(%ebp)
801043ad:	75 0a                	jne    801043b9 <wakeup1+0x2f>
      p->state = RUNNABLE;
801043af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801043b2:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043b9:	83 6d fc 80          	subl   $0xffffff80,-0x4(%ebp)
801043bd:	81 7d fc 34 62 19 80 	cmpl   $0x80196234,-0x4(%ebp)
801043c4:	72 d3                	jb     80104399 <wakeup1+0xf>
}
801043c6:	90                   	nop
801043c7:	90                   	nop
801043c8:	c9                   	leave
801043c9:	c3                   	ret

801043ca <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801043ca:	55                   	push   %ebp
801043cb:	89 e5                	mov    %esp,%ebp
801043cd:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
801043d0:	83 ec 0c             	sub    $0xc,%esp
801043d3:	68 00 42 19 80       	push   $0x80194200
801043d8:	e8 39 03 00 00       	call   80104716 <acquire>
801043dd:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
801043e0:	83 ec 0c             	sub    $0xc,%esp
801043e3:	ff 75 08             	push   0x8(%ebp)
801043e6:	e8 9f ff ff ff       	call   8010438a <wakeup1>
801043eb:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
801043ee:	83 ec 0c             	sub    $0xc,%esp
801043f1:	68 00 42 19 80       	push   $0x80194200
801043f6:	e8 89 03 00 00       	call   80104784 <release>
801043fb:	83 c4 10             	add    $0x10,%esp
}
801043fe:	90                   	nop
801043ff:	c9                   	leave
80104400:	c3                   	ret

80104401 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104401:	55                   	push   %ebp
80104402:	89 e5                	mov    %esp,%ebp
80104404:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104407:	83 ec 0c             	sub    $0xc,%esp
8010440a:	68 00 42 19 80       	push   $0x80194200
8010440f:	e8 02 03 00 00       	call   80104716 <acquire>
80104414:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104417:	c7 45 f4 34 42 19 80 	movl   $0x80194234,-0xc(%ebp)
8010441e:	eb 45                	jmp    80104465 <kill+0x64>
    if(p->pid == pid){
80104420:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104423:	8b 40 10             	mov    0x10(%eax),%eax
80104426:	39 45 08             	cmp    %eax,0x8(%ebp)
80104429:	75 36                	jne    80104461 <kill+0x60>
      p->killed = 1;
8010442b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010442e:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104435:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104438:	8b 40 0c             	mov    0xc(%eax),%eax
8010443b:	83 f8 02             	cmp    $0x2,%eax
8010443e:	75 0a                	jne    8010444a <kill+0x49>
        p->state = RUNNABLE;
80104440:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104443:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
8010444a:	83 ec 0c             	sub    $0xc,%esp
8010444d:	68 00 42 19 80       	push   $0x80194200
80104452:	e8 2d 03 00 00       	call   80104784 <release>
80104457:	83 c4 10             	add    $0x10,%esp
      return 0;
8010445a:	b8 00 00 00 00       	mov    $0x0,%eax
8010445f:	eb 22                	jmp    80104483 <kill+0x82>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104461:	83 6d f4 80          	subl   $0xffffff80,-0xc(%ebp)
80104465:	81 7d f4 34 62 19 80 	cmpl   $0x80196234,-0xc(%ebp)
8010446c:	72 b2                	jb     80104420 <kill+0x1f>
    }
  }
  release(&ptable.lock);
8010446e:	83 ec 0c             	sub    $0xc,%esp
80104471:	68 00 42 19 80       	push   $0x80194200
80104476:	e8 09 03 00 00       	call   80104784 <release>
8010447b:	83 c4 10             	add    $0x10,%esp
  return -1;
8010447e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104483:	c9                   	leave
80104484:	c3                   	ret

80104485 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104485:	55                   	push   %ebp
80104486:	89 e5                	mov    %esp,%ebp
80104488:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010448b:	c7 45 f0 34 42 19 80 	movl   $0x80194234,-0x10(%ebp)
80104492:	e9 d7 00 00 00       	jmp    8010456e <procdump+0xe9>
    if(p->state == UNUSED)
80104497:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010449a:	8b 40 0c             	mov    0xc(%eax),%eax
8010449d:	85 c0                	test   %eax,%eax
8010449f:	0f 84 c4 00 00 00    	je     80104569 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801044a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044a8:	8b 40 0c             	mov    0xc(%eax),%eax
801044ab:	83 f8 05             	cmp    $0x5,%eax
801044ae:	77 23                	ja     801044d3 <procdump+0x4e>
801044b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b3:	8b 40 0c             	mov    0xc(%eax),%eax
801044b6:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044bd:	85 c0                	test   %eax,%eax
801044bf:	74 12                	je     801044d3 <procdump+0x4e>
      state = states[p->state];
801044c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044c4:	8b 40 0c             	mov    0xc(%eax),%eax
801044c7:	8b 04 85 08 f0 10 80 	mov    -0x7fef0ff8(,%eax,4),%eax
801044ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801044d1:	eb 07                	jmp    801044da <procdump+0x55>
    else
      state = "???";
801044d3:	c7 45 ec 62 a3 10 80 	movl   $0x8010a362,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801044da:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044dd:	8d 50 6c             	lea    0x6c(%eax),%edx
801044e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044e3:	8b 40 10             	mov    0x10(%eax),%eax
801044e6:	52                   	push   %edx
801044e7:	ff 75 ec             	push   -0x14(%ebp)
801044ea:	50                   	push   %eax
801044eb:	68 66 a3 10 80       	push   $0x8010a366
801044f0:	e8 ff be ff ff       	call   801003f4 <cprintf>
801044f5:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801044f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044fb:	8b 40 0c             	mov    0xc(%eax),%eax
801044fe:	83 f8 02             	cmp    $0x2,%eax
80104501:	75 54                	jne    80104557 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80104503:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104506:	8b 40 1c             	mov    0x1c(%eax),%eax
80104509:	8b 40 0c             	mov    0xc(%eax),%eax
8010450c:	83 c0 08             	add    $0x8,%eax
8010450f:	89 c2                	mov    %eax,%edx
80104511:	83 ec 08             	sub    $0x8,%esp
80104514:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104517:	50                   	push   %eax
80104518:	52                   	push   %edx
80104519:	e8 b8 02 00 00       	call   801047d6 <getcallerpcs>
8010451e:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104521:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104528:	eb 1c                	jmp    80104546 <procdump+0xc1>
        cprintf(" %p", pc[i]);
8010452a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010452d:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104531:	83 ec 08             	sub    $0x8,%esp
80104534:	50                   	push   %eax
80104535:	68 6f a3 10 80       	push   $0x8010a36f
8010453a:	e8 b5 be ff ff       	call   801003f4 <cprintf>
8010453f:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
80104542:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104546:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
8010454a:	7f 0b                	jg     80104557 <procdump+0xd2>
8010454c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010454f:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
80104553:	85 c0                	test   %eax,%eax
80104555:	75 d3                	jne    8010452a <procdump+0xa5>
    }
    cprintf("\n");
80104557:	83 ec 0c             	sub    $0xc,%esp
8010455a:	68 73 a3 10 80       	push   $0x8010a373
8010455f:	e8 90 be ff ff       	call   801003f4 <cprintf>
80104564:	83 c4 10             	add    $0x10,%esp
80104567:	eb 01                	jmp    8010456a <procdump+0xe5>
      continue;
80104569:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010456a:	83 6d f0 80          	subl   $0xffffff80,-0x10(%ebp)
8010456e:	81 7d f0 34 62 19 80 	cmpl   $0x80196234,-0x10(%ebp)
80104575:	0f 82 1c ff ff ff    	jb     80104497 <procdump+0x12>
  }
}
8010457b:	90                   	nop
8010457c:	90                   	nop
8010457d:	c9                   	leave
8010457e:	c3                   	ret

8010457f <uthread_init>:

//LAB2 추가
int uthread_init(int address){
8010457f:	55                   	push   %ebp
80104580:	89 e5                	mov    %esp,%ebp
80104582:	83 ec 08             	sub    $0x8,%esp
  myproc()->scheduler = address;
80104585:	e8 a6 f4 ff ff       	call   80103a30 <myproc>
8010458a:	8b 55 08             	mov    0x8(%ebp),%edx
8010458d:	89 50 7c             	mov    %edx,0x7c(%eax)
  return 0;
80104590:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104595:	c9                   	leave
80104596:	c3                   	ret

80104597 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104597:	55                   	push   %ebp
80104598:	89 e5                	mov    %esp,%ebp
8010459a:	83 ec 08             	sub    $0x8,%esp
  initlock(&lk->lk, "sleep lock");
8010459d:	8b 45 08             	mov    0x8(%ebp),%eax
801045a0:	83 c0 04             	add    $0x4,%eax
801045a3:	83 ec 08             	sub    $0x8,%esp
801045a6:	68 9f a3 10 80       	push   $0x8010a39f
801045ab:	50                   	push   %eax
801045ac:	e8 43 01 00 00       	call   801046f4 <initlock>
801045b1:	83 c4 10             	add    $0x10,%esp
  lk->name = name;
801045b4:	8b 45 08             	mov    0x8(%ebp),%eax
801045b7:	8b 55 0c             	mov    0xc(%ebp),%edx
801045ba:	89 50 38             	mov    %edx,0x38(%eax)
  lk->locked = 0;
801045bd:	8b 45 08             	mov    0x8(%ebp),%eax
801045c0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
801045c6:	8b 45 08             	mov    0x8(%ebp),%eax
801045c9:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
}
801045d0:	90                   	nop
801045d1:	c9                   	leave
801045d2:	c3                   	ret

801045d3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801045d3:	55                   	push   %ebp
801045d4:	89 e5                	mov    %esp,%ebp
801045d6:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
801045d9:	8b 45 08             	mov    0x8(%ebp),%eax
801045dc:	83 c0 04             	add    $0x4,%eax
801045df:	83 ec 0c             	sub    $0xc,%esp
801045e2:	50                   	push   %eax
801045e3:	e8 2e 01 00 00       	call   80104716 <acquire>
801045e8:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801045eb:	eb 15                	jmp    80104602 <acquiresleep+0x2f>
    sleep(lk, &lk->lk);
801045ed:	8b 45 08             	mov    0x8(%ebp),%eax
801045f0:	83 c0 04             	add    $0x4,%eax
801045f3:	83 ec 08             	sub    $0x8,%esp
801045f6:	50                   	push   %eax
801045f7:	ff 75 08             	push   0x8(%ebp)
801045fa:	e8 e4 fc ff ff       	call   801042e3 <sleep>
801045ff:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80104602:	8b 45 08             	mov    0x8(%ebp),%eax
80104605:	8b 00                	mov    (%eax),%eax
80104607:	85 c0                	test   %eax,%eax
80104609:	75 e2                	jne    801045ed <acquiresleep+0x1a>
  }
  lk->locked = 1;
8010460b:	8b 45 08             	mov    0x8(%ebp),%eax
8010460e:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  lk->pid = myproc()->pid;
80104614:	e8 17 f4 ff ff       	call   80103a30 <myproc>
80104619:	8b 50 10             	mov    0x10(%eax),%edx
8010461c:	8b 45 08             	mov    0x8(%ebp),%eax
8010461f:	89 50 3c             	mov    %edx,0x3c(%eax)
  release(&lk->lk);
80104622:	8b 45 08             	mov    0x8(%ebp),%eax
80104625:	83 c0 04             	add    $0x4,%eax
80104628:	83 ec 0c             	sub    $0xc,%esp
8010462b:	50                   	push   %eax
8010462c:	e8 53 01 00 00       	call   80104784 <release>
80104631:	83 c4 10             	add    $0x10,%esp
}
80104634:	90                   	nop
80104635:	c9                   	leave
80104636:	c3                   	ret

80104637 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104637:	55                   	push   %ebp
80104638:	89 e5                	mov    %esp,%ebp
8010463a:	83 ec 08             	sub    $0x8,%esp
  acquire(&lk->lk);
8010463d:	8b 45 08             	mov    0x8(%ebp),%eax
80104640:	83 c0 04             	add    $0x4,%eax
80104643:	83 ec 0c             	sub    $0xc,%esp
80104646:	50                   	push   %eax
80104647:	e8 ca 00 00 00       	call   80104716 <acquire>
8010464c:	83 c4 10             	add    $0x10,%esp
  lk->locked = 0;
8010464f:	8b 45 08             	mov    0x8(%ebp),%eax
80104652:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->pid = 0;
80104658:	8b 45 08             	mov    0x8(%ebp),%eax
8010465b:	c7 40 3c 00 00 00 00 	movl   $0x0,0x3c(%eax)
  wakeup(lk);
80104662:	83 ec 0c             	sub    $0xc,%esp
80104665:	ff 75 08             	push   0x8(%ebp)
80104668:	e8 5d fd ff ff       	call   801043ca <wakeup>
8010466d:	83 c4 10             	add    $0x10,%esp
  release(&lk->lk);
80104670:	8b 45 08             	mov    0x8(%ebp),%eax
80104673:	83 c0 04             	add    $0x4,%eax
80104676:	83 ec 0c             	sub    $0xc,%esp
80104679:	50                   	push   %eax
8010467a:	e8 05 01 00 00       	call   80104784 <release>
8010467f:	83 c4 10             	add    $0x10,%esp
}
80104682:	90                   	nop
80104683:	c9                   	leave
80104684:	c3                   	ret

80104685 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104685:	55                   	push   %ebp
80104686:	89 e5                	mov    %esp,%ebp
80104688:	83 ec 18             	sub    $0x18,%esp
  int r;
  
  acquire(&lk->lk);
8010468b:	8b 45 08             	mov    0x8(%ebp),%eax
8010468e:	83 c0 04             	add    $0x4,%eax
80104691:	83 ec 0c             	sub    $0xc,%esp
80104694:	50                   	push   %eax
80104695:	e8 7c 00 00 00       	call   80104716 <acquire>
8010469a:	83 c4 10             	add    $0x10,%esp
  r = lk->locked;
8010469d:	8b 45 08             	mov    0x8(%ebp),%eax
801046a0:	8b 00                	mov    (%eax),%eax
801046a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&lk->lk);
801046a5:	8b 45 08             	mov    0x8(%ebp),%eax
801046a8:	83 c0 04             	add    $0x4,%eax
801046ab:	83 ec 0c             	sub    $0xc,%esp
801046ae:	50                   	push   %eax
801046af:	e8 d0 00 00 00       	call   80104784 <release>
801046b4:	83 c4 10             	add    $0x10,%esp
  return r;
801046b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801046ba:	c9                   	leave
801046bb:	c3                   	ret

801046bc <readeflags>:
{
801046bc:	55                   	push   %ebp
801046bd:	89 e5                	mov    %esp,%ebp
801046bf:	83 ec 10             	sub    $0x10,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801046c2:	9c                   	pushf
801046c3:	58                   	pop    %eax
801046c4:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801046c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046ca:	c9                   	leave
801046cb:	c3                   	ret

801046cc <cli>:
{
801046cc:	55                   	push   %ebp
801046cd:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
801046cf:	fa                   	cli
}
801046d0:	90                   	nop
801046d1:	5d                   	pop    %ebp
801046d2:	c3                   	ret

801046d3 <sti>:
{
801046d3:	55                   	push   %ebp
801046d4:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801046d6:	fb                   	sti
}
801046d7:	90                   	nop
801046d8:	5d                   	pop    %ebp
801046d9:	c3                   	ret

801046da <xchg>:
{
801046da:	55                   	push   %ebp
801046db:	89 e5                	mov    %esp,%ebp
801046dd:	83 ec 10             	sub    $0x10,%esp
  asm volatile("lock; xchgl %0, %1" :
801046e0:	8b 55 08             	mov    0x8(%ebp),%edx
801046e3:	8b 45 0c             	mov    0xc(%ebp),%eax
801046e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
801046e9:	f0 87 02             	lock xchg %eax,(%edx)
801046ec:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return result;
801046ef:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801046f2:	c9                   	leave
801046f3:	c3                   	ret

801046f4 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801046f4:	55                   	push   %ebp
801046f5:	89 e5                	mov    %esp,%ebp
  lk->name = name;
801046f7:	8b 45 08             	mov    0x8(%ebp),%eax
801046fa:	8b 55 0c             	mov    0xc(%ebp),%edx
801046fd:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80104700:	8b 45 08             	mov    0x8(%ebp),%eax
80104703:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80104709:	8b 45 08             	mov    0x8(%ebp),%eax
8010470c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80104713:	90                   	nop
80104714:	5d                   	pop    %ebp
80104715:	c3                   	ret

80104716 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80104716:	55                   	push   %ebp
80104717:	89 e5                	mov    %esp,%ebp
80104719:	53                   	push   %ebx
8010471a:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010471d:	e8 5f 01 00 00       	call   80104881 <pushcli>
  if(holding(lk)){
80104722:	8b 45 08             	mov    0x8(%ebp),%eax
80104725:	83 ec 0c             	sub    $0xc,%esp
80104728:	50                   	push   %eax
80104729:	e8 23 01 00 00       	call   80104851 <holding>
8010472e:	83 c4 10             	add    $0x10,%esp
80104731:	85 c0                	test   %eax,%eax
80104733:	74 0d                	je     80104742 <acquire+0x2c>
    panic("acquire");
80104735:	83 ec 0c             	sub    $0xc,%esp
80104738:	68 aa a3 10 80       	push   $0x8010a3aa
8010473d:	e8 67 be ff ff       	call   801005a9 <panic>
  }

  // The xchg is atomic.
  while(xchg(&lk->locked, 1) != 0)
80104742:	90                   	nop
80104743:	8b 45 08             	mov    0x8(%ebp),%eax
80104746:	83 ec 08             	sub    $0x8,%esp
80104749:	6a 01                	push   $0x1
8010474b:	50                   	push   %eax
8010474c:	e8 89 ff ff ff       	call   801046da <xchg>
80104751:	83 c4 10             	add    $0x10,%esp
80104754:	85 c0                	test   %eax,%eax
80104756:	75 eb                	jne    80104743 <acquire+0x2d>
    ;

  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that the critical section's memory
  // references happen after the lock is acquired.
  __sync_synchronize();
80104758:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Record info about lock acquisition for debugging.
  lk->cpu = mycpu();
8010475d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104760:	e8 53 f2 ff ff       	call   801039b8 <mycpu>
80104765:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80104768:	8b 45 08             	mov    0x8(%ebp),%eax
8010476b:	83 c0 0c             	add    $0xc,%eax
8010476e:	83 ec 08             	sub    $0x8,%esp
80104771:	50                   	push   %eax
80104772:	8d 45 08             	lea    0x8(%ebp),%eax
80104775:	50                   	push   %eax
80104776:	e8 5b 00 00 00       	call   801047d6 <getcallerpcs>
8010477b:	83 c4 10             	add    $0x10,%esp
}
8010477e:	90                   	nop
8010477f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104782:	c9                   	leave
80104783:	c3                   	ret

80104784 <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
80104784:	55                   	push   %ebp
80104785:	89 e5                	mov    %esp,%ebp
80104787:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
8010478a:	83 ec 0c             	sub    $0xc,%esp
8010478d:	ff 75 08             	push   0x8(%ebp)
80104790:	e8 bc 00 00 00       	call   80104851 <holding>
80104795:	83 c4 10             	add    $0x10,%esp
80104798:	85 c0                	test   %eax,%eax
8010479a:	75 0d                	jne    801047a9 <release+0x25>
    panic("release");
8010479c:	83 ec 0c             	sub    $0xc,%esp
8010479f:	68 b2 a3 10 80       	push   $0x8010a3b2
801047a4:	e8 00 be ff ff       	call   801005a9 <panic>

  lk->pcs[0] = 0;
801047a9:	8b 45 08             	mov    0x8(%ebp),%eax
801047ac:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
801047b3:	8b 45 08             	mov    0x8(%ebp),%eax
801047b6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // Tell the C compiler and the processor to not move loads or stores
  // past this point, to ensure that all the stores in the critical
  // section are visible to other cores before the lock is released.
  // Both the C compiler and the hardware may re-order loads and
  // stores; __sync_synchronize() tells them both not to.
  __sync_synchronize();
801047bd:	f0 83 0c 24 00       	lock orl $0x0,(%esp)

  // Release the lock, equivalent to lk->locked = 0.
  // This code can't use a C assignment, since it might
  // not be atomic. A real OS would use C atomics here.
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
801047c2:	8b 45 08             	mov    0x8(%ebp),%eax
801047c5:	8b 55 08             	mov    0x8(%ebp),%edx
801047c8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  popcli();
801047ce:	e8 fb 00 00 00       	call   801048ce <popcli>
}
801047d3:	90                   	nop
801047d4:	c9                   	leave
801047d5:	c3                   	ret

801047d6 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801047d6:	55                   	push   %ebp
801047d7:	89 e5                	mov    %esp,%ebp
801047d9:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
801047dc:	8b 45 08             	mov    0x8(%ebp),%eax
801047df:	83 e8 08             	sub    $0x8,%eax
801047e2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
801047e5:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
801047ec:	eb 38                	jmp    80104826 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801047ee:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
801047f2:	74 53                	je     80104847 <getcallerpcs+0x71>
801047f4:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
801047fb:	76 4a                	jbe    80104847 <getcallerpcs+0x71>
801047fd:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
80104801:	74 44                	je     80104847 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104803:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104806:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010480d:	8b 45 0c             	mov    0xc(%ebp),%eax
80104810:	01 c2                	add    %eax,%edx
80104812:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104815:	8b 40 04             	mov    0x4(%eax),%eax
80104818:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
8010481a:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010481d:	8b 00                	mov    (%eax),%eax
8010481f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
80104822:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104826:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010482a:	7e c2                	jle    801047ee <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
8010482c:	eb 19                	jmp    80104847 <getcallerpcs+0x71>
    pcs[i] = 0;
8010482e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104831:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80104838:	8b 45 0c             	mov    0xc(%ebp),%eax
8010483b:	01 d0                	add    %edx,%eax
8010483d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104843:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
80104847:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
8010484b:	7e e1                	jle    8010482e <getcallerpcs+0x58>
}
8010484d:	90                   	nop
8010484e:	90                   	nop
8010484f:	c9                   	leave
80104850:	c3                   	ret

80104851 <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
80104851:	55                   	push   %ebp
80104852:	89 e5                	mov    %esp,%ebp
80104854:	53                   	push   %ebx
80104855:	83 ec 04             	sub    $0x4,%esp
  return lock->locked && lock->cpu == mycpu();
80104858:	8b 45 08             	mov    0x8(%ebp),%eax
8010485b:	8b 00                	mov    (%eax),%eax
8010485d:	85 c0                	test   %eax,%eax
8010485f:	74 16                	je     80104877 <holding+0x26>
80104861:	8b 45 08             	mov    0x8(%ebp),%eax
80104864:	8b 58 08             	mov    0x8(%eax),%ebx
80104867:	e8 4c f1 ff ff       	call   801039b8 <mycpu>
8010486c:	39 c3                	cmp    %eax,%ebx
8010486e:	75 07                	jne    80104877 <holding+0x26>
80104870:	b8 01 00 00 00       	mov    $0x1,%eax
80104875:	eb 05                	jmp    8010487c <holding+0x2b>
80104877:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010487c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010487f:	c9                   	leave
80104880:	c3                   	ret

80104881 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104881:	55                   	push   %ebp
80104882:	89 e5                	mov    %esp,%ebp
80104884:	83 ec 18             	sub    $0x18,%esp
  int eflags;

  eflags = readeflags();
80104887:	e8 30 fe ff ff       	call   801046bc <readeflags>
8010488c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  cli();
8010488f:	e8 38 fe ff ff       	call   801046cc <cli>
  if(mycpu()->ncli == 0)
80104894:	e8 1f f1 ff ff       	call   801039b8 <mycpu>
80104899:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
8010489f:	85 c0                	test   %eax,%eax
801048a1:	75 14                	jne    801048b7 <pushcli+0x36>
    mycpu()->intena = eflags & FL_IF;
801048a3:	e8 10 f1 ff ff       	call   801039b8 <mycpu>
801048a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801048ab:	81 e2 00 02 00 00    	and    $0x200,%edx
801048b1:	89 90 a8 00 00 00    	mov    %edx,0xa8(%eax)
  mycpu()->ncli += 1;
801048b7:	e8 fc f0 ff ff       	call   801039b8 <mycpu>
801048bc:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048c2:	83 c2 01             	add    $0x1,%edx
801048c5:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
}
801048cb:	90                   	nop
801048cc:	c9                   	leave
801048cd:	c3                   	ret

801048ce <popcli>:

void
popcli(void)
{
801048ce:	55                   	push   %ebp
801048cf:	89 e5                	mov    %esp,%ebp
801048d1:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
801048d4:	e8 e3 fd ff ff       	call   801046bc <readeflags>
801048d9:	25 00 02 00 00       	and    $0x200,%eax
801048de:	85 c0                	test   %eax,%eax
801048e0:	74 0d                	je     801048ef <popcli+0x21>
    panic("popcli - interruptible");
801048e2:	83 ec 0c             	sub    $0xc,%esp
801048e5:	68 ba a3 10 80       	push   $0x8010a3ba
801048ea:	e8 ba bc ff ff       	call   801005a9 <panic>
  if(--mycpu()->ncli < 0)
801048ef:	e8 c4 f0 ff ff       	call   801039b8 <mycpu>
801048f4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
801048fa:	83 ea 01             	sub    $0x1,%edx
801048fd:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80104903:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104909:	85 c0                	test   %eax,%eax
8010490b:	79 0d                	jns    8010491a <popcli+0x4c>
    panic("popcli");
8010490d:	83 ec 0c             	sub    $0xc,%esp
80104910:	68 d1 a3 10 80       	push   $0x8010a3d1
80104915:	e8 8f bc ff ff       	call   801005a9 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
8010491a:	e8 99 f0 ff ff       	call   801039b8 <mycpu>
8010491f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104925:	85 c0                	test   %eax,%eax
80104927:	75 14                	jne    8010493d <popcli+0x6f>
80104929:	e8 8a f0 ff ff       	call   801039b8 <mycpu>
8010492e:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104934:	85 c0                	test   %eax,%eax
80104936:	74 05                	je     8010493d <popcli+0x6f>
    sti();
80104938:	e8 96 fd ff ff       	call   801046d3 <sti>
}
8010493d:	90                   	nop
8010493e:	c9                   	leave
8010493f:	c3                   	ret

80104940 <stosb>:
{
80104940:	55                   	push   %ebp
80104941:	89 e5                	mov    %esp,%ebp
80104943:	57                   	push   %edi
80104944:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
80104945:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104948:	8b 55 10             	mov    0x10(%ebp),%edx
8010494b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010494e:	89 cb                	mov    %ecx,%ebx
80104950:	89 df                	mov    %ebx,%edi
80104952:	89 d1                	mov    %edx,%ecx
80104954:	fc                   	cld
80104955:	f3 aa                	rep stos %al,%es:(%edi)
80104957:	89 ca                	mov    %ecx,%edx
80104959:	89 fb                	mov    %edi,%ebx
8010495b:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010495e:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104961:	90                   	nop
80104962:	5b                   	pop    %ebx
80104963:	5f                   	pop    %edi
80104964:	5d                   	pop    %ebp
80104965:	c3                   	ret

80104966 <stosl>:
{
80104966:	55                   	push   %ebp
80104967:	89 e5                	mov    %esp,%ebp
80104969:	57                   	push   %edi
8010496a:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
8010496b:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010496e:	8b 55 10             	mov    0x10(%ebp),%edx
80104971:	8b 45 0c             	mov    0xc(%ebp),%eax
80104974:	89 cb                	mov    %ecx,%ebx
80104976:	89 df                	mov    %ebx,%edi
80104978:	89 d1                	mov    %edx,%ecx
8010497a:	fc                   	cld
8010497b:	f3 ab                	rep stos %eax,%es:(%edi)
8010497d:	89 ca                	mov    %ecx,%edx
8010497f:	89 fb                	mov    %edi,%ebx
80104981:	89 5d 08             	mov    %ebx,0x8(%ebp)
80104984:	89 55 10             	mov    %edx,0x10(%ebp)
}
80104987:	90                   	nop
80104988:	5b                   	pop    %ebx
80104989:	5f                   	pop    %edi
8010498a:	5d                   	pop    %ebp
8010498b:	c3                   	ret

8010498c <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010498c:	55                   	push   %ebp
8010498d:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010498f:	8b 45 08             	mov    0x8(%ebp),%eax
80104992:	83 e0 03             	and    $0x3,%eax
80104995:	85 c0                	test   %eax,%eax
80104997:	75 43                	jne    801049dc <memset+0x50>
80104999:	8b 45 10             	mov    0x10(%ebp),%eax
8010499c:	83 e0 03             	and    $0x3,%eax
8010499f:	85 c0                	test   %eax,%eax
801049a1:	75 39                	jne    801049dc <memset+0x50>
    c &= 0xFF;
801049a3:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
801049aa:	8b 45 10             	mov    0x10(%ebp),%eax
801049ad:	c1 e8 02             	shr    $0x2,%eax
801049b0:	89 c1                	mov    %eax,%ecx
801049b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801049b5:	c1 e0 18             	shl    $0x18,%eax
801049b8:	89 c2                	mov    %eax,%edx
801049ba:	8b 45 0c             	mov    0xc(%ebp),%eax
801049bd:	c1 e0 10             	shl    $0x10,%eax
801049c0:	09 c2                	or     %eax,%edx
801049c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801049c5:	c1 e0 08             	shl    $0x8,%eax
801049c8:	09 d0                	or     %edx,%eax
801049ca:	0b 45 0c             	or     0xc(%ebp),%eax
801049cd:	51                   	push   %ecx
801049ce:	50                   	push   %eax
801049cf:	ff 75 08             	push   0x8(%ebp)
801049d2:	e8 8f ff ff ff       	call   80104966 <stosl>
801049d7:	83 c4 0c             	add    $0xc,%esp
801049da:	eb 12                	jmp    801049ee <memset+0x62>
  } else
    stosb(dst, c, n);
801049dc:	8b 45 10             	mov    0x10(%ebp),%eax
801049df:	50                   	push   %eax
801049e0:	ff 75 0c             	push   0xc(%ebp)
801049e3:	ff 75 08             	push   0x8(%ebp)
801049e6:	e8 55 ff ff ff       	call   80104940 <stosb>
801049eb:	83 c4 0c             	add    $0xc,%esp
  return dst;
801049ee:	8b 45 08             	mov    0x8(%ebp),%eax
}
801049f1:	c9                   	leave
801049f2:	c3                   	ret

801049f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
801049f3:	55                   	push   %ebp
801049f4:	89 e5                	mov    %esp,%ebp
801049f6:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;

  s1 = v1;
801049f9:	8b 45 08             	mov    0x8(%ebp),%eax
801049fc:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
801049ff:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a02:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80104a05:	eb 2e                	jmp    80104a35 <memcmp+0x42>
    if(*s1 != *s2)
80104a07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a0a:	0f b6 10             	movzbl (%eax),%edx
80104a0d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a10:	0f b6 00             	movzbl (%eax),%eax
80104a13:	38 c2                	cmp    %al,%dl
80104a15:	74 16                	je     80104a2d <memcmp+0x3a>
      return *s1 - *s2;
80104a17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a1a:	0f b6 00             	movzbl (%eax),%eax
80104a1d:	0f b6 d0             	movzbl %al,%edx
80104a20:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a23:	0f b6 00             	movzbl (%eax),%eax
80104a26:	0f b6 c0             	movzbl %al,%eax
80104a29:	29 c2                	sub    %eax,%edx
80104a2b:	eb 1a                	jmp    80104a47 <memcmp+0x54>
    s1++, s2++;
80104a2d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104a31:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
  while(n-- > 0){
80104a35:	8b 45 10             	mov    0x10(%ebp),%eax
80104a38:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a3b:	89 55 10             	mov    %edx,0x10(%ebp)
80104a3e:	85 c0                	test   %eax,%eax
80104a40:	75 c5                	jne    80104a07 <memcmp+0x14>
  }

  return 0;
80104a42:	ba 00 00 00 00       	mov    $0x0,%edx
}
80104a47:	89 d0                	mov    %edx,%eax
80104a49:	c9                   	leave
80104a4a:	c3                   	ret

80104a4b <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104a4b:	55                   	push   %ebp
80104a4c:	89 e5                	mov    %esp,%ebp
80104a4e:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80104a51:	8b 45 0c             	mov    0xc(%ebp),%eax
80104a54:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80104a57:	8b 45 08             	mov    0x8(%ebp),%eax
80104a5a:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80104a5d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a60:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80104a63:	73 54                	jae    80104ab9 <memmove+0x6e>
80104a65:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104a68:	8b 45 10             	mov    0x10(%ebp),%eax
80104a6b:	01 d0                	add    %edx,%eax
80104a6d:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80104a70:	73 47                	jae    80104ab9 <memmove+0x6e>
    s += n;
80104a72:	8b 45 10             	mov    0x10(%ebp),%eax
80104a75:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80104a78:	8b 45 10             	mov    0x10(%ebp),%eax
80104a7b:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80104a7e:	eb 13                	jmp    80104a93 <memmove+0x48>
      *--d = *--s;
80104a80:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80104a84:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80104a88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104a8b:	0f b6 10             	movzbl (%eax),%edx
80104a8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104a91:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104a93:	8b 45 10             	mov    0x10(%ebp),%eax
80104a96:	8d 50 ff             	lea    -0x1(%eax),%edx
80104a99:	89 55 10             	mov    %edx,0x10(%ebp)
80104a9c:	85 c0                	test   %eax,%eax
80104a9e:	75 e0                	jne    80104a80 <memmove+0x35>
  if(s < d && s + n > d){
80104aa0:	eb 24                	jmp    80104ac6 <memmove+0x7b>
  } else
    while(n-- > 0)
      *d++ = *s++;
80104aa2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104aa5:	8d 42 01             	lea    0x1(%edx),%eax
80104aa8:	89 45 fc             	mov    %eax,-0x4(%ebp)
80104aab:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104aae:	8d 48 01             	lea    0x1(%eax),%ecx
80104ab1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
80104ab4:	0f b6 12             	movzbl (%edx),%edx
80104ab7:	88 10                	mov    %dl,(%eax)
    while(n-- > 0)
80104ab9:	8b 45 10             	mov    0x10(%ebp),%eax
80104abc:	8d 50 ff             	lea    -0x1(%eax),%edx
80104abf:	89 55 10             	mov    %edx,0x10(%ebp)
80104ac2:	85 c0                	test   %eax,%eax
80104ac4:	75 dc                	jne    80104aa2 <memmove+0x57>

  return dst;
80104ac6:	8b 45 08             	mov    0x8(%ebp),%eax
}
80104ac9:	c9                   	leave
80104aca:	c3                   	ret

80104acb <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104acb:	55                   	push   %ebp
80104acc:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80104ace:	ff 75 10             	push   0x10(%ebp)
80104ad1:	ff 75 0c             	push   0xc(%ebp)
80104ad4:	ff 75 08             	push   0x8(%ebp)
80104ad7:	e8 6f ff ff ff       	call   80104a4b <memmove>
80104adc:	83 c4 0c             	add    $0xc,%esp
}
80104adf:	c9                   	leave
80104ae0:	c3                   	ret

80104ae1 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80104ae1:	55                   	push   %ebp
80104ae2:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80104ae4:	eb 0c                	jmp    80104af2 <strncmp+0x11>
    n--, p++, q++;
80104ae6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104aea:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80104aee:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(n > 0 && *p && *p == *q)
80104af2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104af6:	74 1a                	je     80104b12 <strncmp+0x31>
80104af8:	8b 45 08             	mov    0x8(%ebp),%eax
80104afb:	0f b6 00             	movzbl (%eax),%eax
80104afe:	84 c0                	test   %al,%al
80104b00:	74 10                	je     80104b12 <strncmp+0x31>
80104b02:	8b 45 08             	mov    0x8(%ebp),%eax
80104b05:	0f b6 10             	movzbl (%eax),%edx
80104b08:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b0b:	0f b6 00             	movzbl (%eax),%eax
80104b0e:	38 c2                	cmp    %al,%dl
80104b10:	74 d4                	je     80104ae6 <strncmp+0x5>
  if(n == 0)
80104b12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b16:	75 07                	jne    80104b1f <strncmp+0x3e>
    return 0;
80104b18:	ba 00 00 00 00       	mov    $0x0,%edx
80104b1d:	eb 14                	jmp    80104b33 <strncmp+0x52>
  return (uchar)*p - (uchar)*q;
80104b1f:	8b 45 08             	mov    0x8(%ebp),%eax
80104b22:	0f b6 00             	movzbl (%eax),%eax
80104b25:	0f b6 d0             	movzbl %al,%edx
80104b28:	8b 45 0c             	mov    0xc(%ebp),%eax
80104b2b:	0f b6 00             	movzbl (%eax),%eax
80104b2e:	0f b6 c0             	movzbl %al,%eax
80104b31:	29 c2                	sub    %eax,%edx
}
80104b33:	89 d0                	mov    %edx,%eax
80104b35:	5d                   	pop    %ebp
80104b36:	c3                   	ret

80104b37 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104b37:	55                   	push   %ebp
80104b38:	89 e5                	mov    %esp,%ebp
80104b3a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b3d:	8b 45 08             	mov    0x8(%ebp),%eax
80104b40:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80104b43:	90                   	nop
80104b44:	8b 45 10             	mov    0x10(%ebp),%eax
80104b47:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b4a:	89 55 10             	mov    %edx,0x10(%ebp)
80104b4d:	85 c0                	test   %eax,%eax
80104b4f:	7e 2c                	jle    80104b7d <strncpy+0x46>
80104b51:	8b 55 0c             	mov    0xc(%ebp),%edx
80104b54:	8d 42 01             	lea    0x1(%edx),%eax
80104b57:	89 45 0c             	mov    %eax,0xc(%ebp)
80104b5a:	8b 45 08             	mov    0x8(%ebp),%eax
80104b5d:	8d 48 01             	lea    0x1(%eax),%ecx
80104b60:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104b63:	0f b6 12             	movzbl (%edx),%edx
80104b66:	88 10                	mov    %dl,(%eax)
80104b68:	0f b6 00             	movzbl (%eax),%eax
80104b6b:	84 c0                	test   %al,%al
80104b6d:	75 d5                	jne    80104b44 <strncpy+0xd>
    ;
  while(n-- > 0)
80104b6f:	eb 0c                	jmp    80104b7d <strncpy+0x46>
    *s++ = 0;
80104b71:	8b 45 08             	mov    0x8(%ebp),%eax
80104b74:	8d 50 01             	lea    0x1(%eax),%edx
80104b77:	89 55 08             	mov    %edx,0x8(%ebp)
80104b7a:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104b7d:	8b 45 10             	mov    0x10(%ebp),%eax
80104b80:	8d 50 ff             	lea    -0x1(%eax),%edx
80104b83:	89 55 10             	mov    %edx,0x10(%ebp)
80104b86:	85 c0                	test   %eax,%eax
80104b88:	7f e7                	jg     80104b71 <strncpy+0x3a>
  return os;
80104b8a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104b8d:	c9                   	leave
80104b8e:	c3                   	ret

80104b8f <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104b8f:	55                   	push   %ebp
80104b90:	89 e5                	mov    %esp,%ebp
80104b92:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
80104b95:	8b 45 08             	mov    0x8(%ebp),%eax
80104b98:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80104b9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104b9f:	7f 05                	jg     80104ba6 <safestrcpy+0x17>
    return os;
80104ba1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104ba4:	eb 32                	jmp    80104bd8 <safestrcpy+0x49>
  while(--n > 0 && (*s++ = *t++) != 0)
80104ba6:	90                   	nop
80104ba7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80104bab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104baf:	7e 1e                	jle    80104bcf <safestrcpy+0x40>
80104bb1:	8b 55 0c             	mov    0xc(%ebp),%edx
80104bb4:	8d 42 01             	lea    0x1(%edx),%eax
80104bb7:	89 45 0c             	mov    %eax,0xc(%ebp)
80104bba:	8b 45 08             	mov    0x8(%ebp),%eax
80104bbd:	8d 48 01             	lea    0x1(%eax),%ecx
80104bc0:	89 4d 08             	mov    %ecx,0x8(%ebp)
80104bc3:	0f b6 12             	movzbl (%edx),%edx
80104bc6:	88 10                	mov    %dl,(%eax)
80104bc8:	0f b6 00             	movzbl (%eax),%eax
80104bcb:	84 c0                	test   %al,%al
80104bcd:	75 d8                	jne    80104ba7 <safestrcpy+0x18>
    ;
  *s = 0;
80104bcf:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd2:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80104bd5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bd8:	c9                   	leave
80104bd9:	c3                   	ret

80104bda <strlen>:

int
strlen(const char *s)
{
80104bda:	55                   	push   %ebp
80104bdb:	89 e5                	mov    %esp,%ebp
80104bdd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80104be0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80104be7:	eb 04                	jmp    80104bed <strlen+0x13>
80104be9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80104bed:	8b 55 fc             	mov    -0x4(%ebp),%edx
80104bf0:	8b 45 08             	mov    0x8(%ebp),%eax
80104bf3:	01 d0                	add    %edx,%eax
80104bf5:	0f b6 00             	movzbl (%eax),%eax
80104bf8:	84 c0                	test   %al,%al
80104bfa:	75 ed                	jne    80104be9 <strlen+0xf>
    ;
  return n;
80104bfc:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104bff:	c9                   	leave
80104c00:	c3                   	ret

80104c01 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104c01:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104c05:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80104c09:	55                   	push   %ebp
  pushl %ebx
80104c0a:	53                   	push   %ebx
  pushl %esi
80104c0b:	56                   	push   %esi
  pushl %edi
80104c0c:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104c0d:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104c0f:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80104c11:	5f                   	pop    %edi
  popl %esi
80104c12:	5e                   	pop    %esi
  popl %ebx
80104c13:	5b                   	pop    %ebx
  popl %ebp
80104c14:	5d                   	pop    %ebp
  ret
80104c15:	c3                   	ret

80104c16 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104c16:	55                   	push   %ebp
80104c17:	89 e5                	mov    %esp,%ebp
80104c19:	83 ec 18             	sub    $0x18,%esp
  struct proc *curproc = myproc();
80104c1c:	e8 0f ee ff ff       	call   80103a30 <myproc>
80104c21:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104c24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c27:	8b 00                	mov    (%eax),%eax
80104c29:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c2c:	73 0f                	jae    80104c3d <fetchint+0x27>
80104c2e:	8b 45 08             	mov    0x8(%ebp),%eax
80104c31:	8d 50 04             	lea    0x4(%eax),%edx
80104c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c37:	8b 00                	mov    (%eax),%eax
80104c39:	39 d0                	cmp    %edx,%eax
80104c3b:	73 07                	jae    80104c44 <fetchint+0x2e>
    return -1;
80104c3d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c42:	eb 0f                	jmp    80104c53 <fetchint+0x3d>
  *ip = *(int*)(addr);
80104c44:	8b 45 08             	mov    0x8(%ebp),%eax
80104c47:	8b 10                	mov    (%eax),%edx
80104c49:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c4c:	89 10                	mov    %edx,(%eax)
  return 0;
80104c4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c53:	c9                   	leave
80104c54:	c3                   	ret

80104c55 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104c55:	55                   	push   %ebp
80104c56:	89 e5                	mov    %esp,%ebp
80104c58:	83 ec 18             	sub    $0x18,%esp
  char *s, *ep;
  struct proc *curproc = myproc();
80104c5b:	e8 d0 ed ff ff       	call   80103a30 <myproc>
80104c60:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if(addr >= curproc->sz)
80104c63:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c66:	8b 00                	mov    (%eax),%eax
80104c68:	39 45 08             	cmp    %eax,0x8(%ebp)
80104c6b:	72 07                	jb     80104c74 <fetchstr+0x1f>
    return -1;
80104c6d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c72:	eb 41                	jmp    80104cb5 <fetchstr+0x60>
  *pp = (char*)addr;
80104c74:	8b 55 08             	mov    0x8(%ebp),%edx
80104c77:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c7a:	89 10                	mov    %edx,(%eax)
  ep = (char*)curproc->sz;
80104c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7f:	8b 00                	mov    (%eax),%eax
80104c81:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(s = *pp; s < ep; s++){
80104c84:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c87:	8b 00                	mov    (%eax),%eax
80104c89:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104c8c:	eb 1a                	jmp    80104ca8 <fetchstr+0x53>
    if(*s == 0)
80104c8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c91:	0f b6 00             	movzbl (%eax),%eax
80104c94:	84 c0                	test   %al,%al
80104c96:	75 0c                	jne    80104ca4 <fetchstr+0x4f>
      return s - *pp;
80104c98:	8b 45 0c             	mov    0xc(%ebp),%eax
80104c9b:	8b 10                	mov    (%eax),%edx
80104c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ca0:	29 d0                	sub    %edx,%eax
80104ca2:	eb 11                	jmp    80104cb5 <fetchstr+0x60>
  for(s = *pp; s < ep; s++){
80104ca4:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104ca8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cab:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80104cae:	72 de                	jb     80104c8e <fetchstr+0x39>
  }
  return -1;
80104cb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104cb5:	c9                   	leave
80104cb6:	c3                   	ret

80104cb7 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104cb7:	55                   	push   %ebp
80104cb8:	89 e5                	mov    %esp,%ebp
80104cba:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104cbd:	e8 6e ed ff ff       	call   80103a30 <myproc>
80104cc2:	8b 40 18             	mov    0x18(%eax),%eax
80104cc5:	8b 40 44             	mov    0x44(%eax),%eax
80104cc8:	8b 55 08             	mov    0x8(%ebp),%edx
80104ccb:	c1 e2 02             	shl    $0x2,%edx
80104cce:	01 d0                	add    %edx,%eax
80104cd0:	83 c0 04             	add    $0x4,%eax
80104cd3:	83 ec 08             	sub    $0x8,%esp
80104cd6:	ff 75 0c             	push   0xc(%ebp)
80104cd9:	50                   	push   %eax
80104cda:	e8 37 ff ff ff       	call   80104c16 <fetchint>
80104cdf:	83 c4 10             	add    $0x10,%esp
}
80104ce2:	c9                   	leave
80104ce3:	c3                   	ret

80104ce4 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104ce4:	55                   	push   %ebp
80104ce5:	89 e5                	mov    %esp,%ebp
80104ce7:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct proc *curproc = myproc();
80104cea:	e8 41 ed ff ff       	call   80103a30 <myproc>
80104cef:	89 45 f4             	mov    %eax,-0xc(%ebp)
 
  if(argint(n, &i) < 0)
80104cf2:	83 ec 08             	sub    $0x8,%esp
80104cf5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cf8:	50                   	push   %eax
80104cf9:	ff 75 08             	push   0x8(%ebp)
80104cfc:	e8 b6 ff ff ff       	call   80104cb7 <argint>
80104d01:	83 c4 10             	add    $0x10,%esp
80104d04:	85 c0                	test   %eax,%eax
80104d06:	79 07                	jns    80104d0f <argptr+0x2b>
    return -1;
80104d08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d0d:	eb 3b                	jmp    80104d4a <argptr+0x66>
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104d0f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104d13:	78 1f                	js     80104d34 <argptr+0x50>
80104d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d18:	8b 00                	mov    (%eax),%eax
80104d1a:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104d1d:	39 c2                	cmp    %eax,%edx
80104d1f:	73 13                	jae    80104d34 <argptr+0x50>
80104d21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d24:	89 c2                	mov    %eax,%edx
80104d26:	8b 45 10             	mov    0x10(%ebp),%eax
80104d29:	01 c2                	add    %eax,%edx
80104d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d2e:	8b 00                	mov    (%eax),%eax
80104d30:	39 d0                	cmp    %edx,%eax
80104d32:	73 07                	jae    80104d3b <argptr+0x57>
    return -1;
80104d34:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d39:	eb 0f                	jmp    80104d4a <argptr+0x66>
  *pp = (char*)i;
80104d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d3e:	89 c2                	mov    %eax,%edx
80104d40:	8b 45 0c             	mov    0xc(%ebp),%eax
80104d43:	89 10                	mov    %edx,(%eax)
  return 0;
80104d45:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d4a:	c9                   	leave
80104d4b:	c3                   	ret

80104d4c <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104d4c:	55                   	push   %ebp
80104d4d:	89 e5                	mov    %esp,%ebp
80104d4f:	83 ec 18             	sub    $0x18,%esp
  int addr;
  if(argint(n, &addr) < 0)
80104d52:	83 ec 08             	sub    $0x8,%esp
80104d55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d58:	50                   	push   %eax
80104d59:	ff 75 08             	push   0x8(%ebp)
80104d5c:	e8 56 ff ff ff       	call   80104cb7 <argint>
80104d61:	83 c4 10             	add    $0x10,%esp
80104d64:	85 c0                	test   %eax,%eax
80104d66:	79 07                	jns    80104d6f <argstr+0x23>
    return -1;
80104d68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d6d:	eb 12                	jmp    80104d81 <argstr+0x35>
  return fetchstr(addr, pp);
80104d6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d72:	83 ec 08             	sub    $0x8,%esp
80104d75:	ff 75 0c             	push   0xc(%ebp)
80104d78:	50                   	push   %eax
80104d79:	e8 d7 fe ff ff       	call   80104c55 <fetchstr>
80104d7e:	83 c4 10             	add    $0x10,%esp
}
80104d81:	c9                   	leave
80104d82:	c3                   	ret

80104d83 <syscall>:
[SYS_uthread_init] sys_uthread_init,
};

void
syscall(void)
{
80104d83:	55                   	push   %ebp
80104d84:	89 e5                	mov    %esp,%ebp
80104d86:	83 ec 18             	sub    $0x18,%esp
  int num;
  struct proc *curproc = myproc();
80104d89:	e8 a2 ec ff ff       	call   80103a30 <myproc>
80104d8e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  num = curproc->tf->eax;
80104d91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d94:	8b 40 18             	mov    0x18(%eax),%eax
80104d97:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d9a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80104d9d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104da1:	7e 2f                	jle    80104dd2 <syscall+0x4f>
80104da3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104da6:	83 f8 16             	cmp    $0x16,%eax
80104da9:	77 27                	ja     80104dd2 <syscall+0x4f>
80104dab:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dae:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104db5:	85 c0                	test   %eax,%eax
80104db7:	74 19                	je     80104dd2 <syscall+0x4f>
    curproc->tf->eax = syscalls[num]();
80104db9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104dbc:	8b 04 85 20 f0 10 80 	mov    -0x7fef0fe0(,%eax,4),%eax
80104dc3:	ff d0                	call   *%eax
80104dc5:	89 c2                	mov    %eax,%edx
80104dc7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dca:	8b 40 18             	mov    0x18(%eax),%eax
80104dcd:	89 50 1c             	mov    %edx,0x1c(%eax)
80104dd0:	eb 2c                	jmp    80104dfe <syscall+0x7b>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
80104dd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104dd5:	8d 50 6c             	lea    0x6c(%eax),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104dd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ddb:	8b 40 10             	mov    0x10(%eax),%eax
80104dde:	ff 75 f0             	push   -0x10(%ebp)
80104de1:	52                   	push   %edx
80104de2:	50                   	push   %eax
80104de3:	68 d8 a3 10 80       	push   $0x8010a3d8
80104de8:	e8 07 b6 ff ff       	call   801003f4 <cprintf>
80104ded:	83 c4 10             	add    $0x10,%esp
    curproc->tf->eax = -1;
80104df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104df3:	8b 40 18             	mov    0x18(%eax),%eax
80104df6:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80104dfd:	90                   	nop
80104dfe:	90                   	nop
80104dff:	c9                   	leave
80104e00:	c3                   	ret

80104e01 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104e01:	55                   	push   %ebp
80104e02:	89 e5                	mov    %esp,%ebp
80104e04:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104e07:	83 ec 08             	sub    $0x8,%esp
80104e0a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e0d:	50                   	push   %eax
80104e0e:	ff 75 08             	push   0x8(%ebp)
80104e11:	e8 a1 fe ff ff       	call   80104cb7 <argint>
80104e16:	83 c4 10             	add    $0x10,%esp
80104e19:	85 c0                	test   %eax,%eax
80104e1b:	79 07                	jns    80104e24 <argfd+0x23>
    return -1;
80104e1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e22:	eb 4f                	jmp    80104e73 <argfd+0x72>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e27:	85 c0                	test   %eax,%eax
80104e29:	78 20                	js     80104e4b <argfd+0x4a>
80104e2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e2e:	83 f8 0f             	cmp    $0xf,%eax
80104e31:	7f 18                	jg     80104e4b <argfd+0x4a>
80104e33:	e8 f8 eb ff ff       	call   80103a30 <myproc>
80104e38:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e3b:	83 c2 08             	add    $0x8,%edx
80104e3e:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e42:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104e45:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104e49:	75 07                	jne    80104e52 <argfd+0x51>
    return -1;
80104e4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e50:	eb 21                	jmp    80104e73 <argfd+0x72>
  if(pfd)
80104e52:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e56:	74 08                	je     80104e60 <argfd+0x5f>
    *pfd = fd;
80104e58:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104e5b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e5e:	89 10                	mov    %edx,(%eax)
  if(pf)
80104e60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80104e64:	74 08                	je     80104e6e <argfd+0x6d>
    *pf = f;
80104e66:	8b 45 10             	mov    0x10(%ebp),%eax
80104e69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e6c:	89 10                	mov    %edx,(%eax)
  return 0;
80104e6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e73:	c9                   	leave
80104e74:	c3                   	ret

80104e75 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104e75:	55                   	push   %ebp
80104e76:	89 e5                	mov    %esp,%ebp
80104e78:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct proc *curproc = myproc();
80104e7b:	e8 b0 eb ff ff       	call   80103a30 <myproc>
80104e80:	89 45 f0             	mov    %eax,-0x10(%ebp)

  for(fd = 0; fd < NOFILE; fd++){
80104e83:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104e8a:	eb 2a                	jmp    80104eb6 <fdalloc+0x41>
    if(curproc->ofile[fd] == 0){
80104e8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e92:	83 c2 08             	add    $0x8,%edx
80104e95:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104e99:	85 c0                	test   %eax,%eax
80104e9b:	75 15                	jne    80104eb2 <fdalloc+0x3d>
      curproc->ofile[fd] = f;
80104e9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104ea0:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ea3:	8d 4a 08             	lea    0x8(%edx),%ecx
80104ea6:	8b 55 08             	mov    0x8(%ebp),%edx
80104ea9:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80104ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104eb0:	eb 0f                	jmp    80104ec1 <fdalloc+0x4c>
  for(fd = 0; fd < NOFILE; fd++){
80104eb2:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104eb6:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104eba:	7e d0                	jle    80104e8c <fdalloc+0x17>
    }
  }
  return -1;
80104ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ec1:	c9                   	leave
80104ec2:	c3                   	ret

80104ec3 <sys_dup>:

int
sys_dup(void)
{
80104ec3:	55                   	push   %ebp
80104ec4:	89 e5                	mov    %esp,%ebp
80104ec6:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;

  if(argfd(0, 0, &f) < 0)
80104ec9:	83 ec 04             	sub    $0x4,%esp
80104ecc:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ecf:	50                   	push   %eax
80104ed0:	6a 00                	push   $0x0
80104ed2:	6a 00                	push   $0x0
80104ed4:	e8 28 ff ff ff       	call   80104e01 <argfd>
80104ed9:	83 c4 10             	add    $0x10,%esp
80104edc:	85 c0                	test   %eax,%eax
80104ede:	79 07                	jns    80104ee7 <sys_dup+0x24>
    return -1;
80104ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee5:	eb 31                	jmp    80104f18 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80104ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104eea:	83 ec 0c             	sub    $0xc,%esp
80104eed:	50                   	push   %eax
80104eee:	e8 82 ff ff ff       	call   80104e75 <fdalloc>
80104ef3:	83 c4 10             	add    $0x10,%esp
80104ef6:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104ef9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104efd:	79 07                	jns    80104f06 <sys_dup+0x43>
    return -1;
80104eff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f04:	eb 12                	jmp    80104f18 <sys_dup+0x55>
  filedup(f);
80104f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f09:	83 ec 0c             	sub    $0xc,%esp
80104f0c:	50                   	push   %eax
80104f0d:	e8 42 c1 ff ff       	call   80101054 <filedup>
80104f12:	83 c4 10             	add    $0x10,%esp
  return fd;
80104f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104f18:	c9                   	leave
80104f19:	c3                   	ret

80104f1a <sys_read>:

int
sys_read(void)
{
80104f1a:	55                   	push   %ebp
80104f1b:	89 e5                	mov    %esp,%ebp
80104f1d:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f20:	83 ec 04             	sub    $0x4,%esp
80104f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f26:	50                   	push   %eax
80104f27:	6a 00                	push   $0x0
80104f29:	6a 00                	push   $0x0
80104f2b:	e8 d1 fe ff ff       	call   80104e01 <argfd>
80104f30:	83 c4 10             	add    $0x10,%esp
80104f33:	85 c0                	test   %eax,%eax
80104f35:	78 2e                	js     80104f65 <sys_read+0x4b>
80104f37:	83 ec 08             	sub    $0x8,%esp
80104f3a:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f3d:	50                   	push   %eax
80104f3e:	6a 02                	push   $0x2
80104f40:	e8 72 fd ff ff       	call   80104cb7 <argint>
80104f45:	83 c4 10             	add    $0x10,%esp
80104f48:	85 c0                	test   %eax,%eax
80104f4a:	78 19                	js     80104f65 <sys_read+0x4b>
80104f4c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104f4f:	83 ec 04             	sub    $0x4,%esp
80104f52:	50                   	push   %eax
80104f53:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f56:	50                   	push   %eax
80104f57:	6a 01                	push   $0x1
80104f59:	e8 86 fd ff ff       	call   80104ce4 <argptr>
80104f5e:	83 c4 10             	add    $0x10,%esp
80104f61:	85 c0                	test   %eax,%eax
80104f63:	79 07                	jns    80104f6c <sys_read+0x52>
    return -1;
80104f65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f6a:	eb 17                	jmp    80104f83 <sys_read+0x69>
  return fileread(f, p, n);
80104f6c:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104f6f:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104f72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104f75:	83 ec 04             	sub    $0x4,%esp
80104f78:	51                   	push   %ecx
80104f79:	52                   	push   %edx
80104f7a:	50                   	push   %eax
80104f7b:	e8 64 c2 ff ff       	call   801011e4 <fileread>
80104f80:	83 c4 10             	add    $0x10,%esp
}
80104f83:	c9                   	leave
80104f84:	c3                   	ret

80104f85 <sys_write>:

int
sys_write(void)
{
80104f85:	55                   	push   %ebp
80104f86:	89 e5                	mov    %esp,%ebp
80104f88:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104f8b:	83 ec 04             	sub    $0x4,%esp
80104f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f91:	50                   	push   %eax
80104f92:	6a 00                	push   $0x0
80104f94:	6a 00                	push   $0x0
80104f96:	e8 66 fe ff ff       	call   80104e01 <argfd>
80104f9b:	83 c4 10             	add    $0x10,%esp
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	78 2e                	js     80104fd0 <sys_write+0x4b>
80104fa2:	83 ec 08             	sub    $0x8,%esp
80104fa5:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104fa8:	50                   	push   %eax
80104fa9:	6a 02                	push   $0x2
80104fab:	e8 07 fd ff ff       	call   80104cb7 <argint>
80104fb0:	83 c4 10             	add    $0x10,%esp
80104fb3:	85 c0                	test   %eax,%eax
80104fb5:	78 19                	js     80104fd0 <sys_write+0x4b>
80104fb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104fba:	83 ec 04             	sub    $0x4,%esp
80104fbd:	50                   	push   %eax
80104fbe:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104fc1:	50                   	push   %eax
80104fc2:	6a 01                	push   $0x1
80104fc4:	e8 1b fd ff ff       	call   80104ce4 <argptr>
80104fc9:	83 c4 10             	add    $0x10,%esp
80104fcc:	85 c0                	test   %eax,%eax
80104fce:	79 07                	jns    80104fd7 <sys_write+0x52>
    return -1;
80104fd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fd5:	eb 17                	jmp    80104fee <sys_write+0x69>
  return filewrite(f, p, n);
80104fd7:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80104fda:	8b 55 ec             	mov    -0x14(%ebp),%edx
80104fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fe0:	83 ec 04             	sub    $0x4,%esp
80104fe3:	51                   	push   %ecx
80104fe4:	52                   	push   %edx
80104fe5:	50                   	push   %eax
80104fe6:	e8 b1 c2 ff ff       	call   8010129c <filewrite>
80104feb:	83 c4 10             	add    $0x10,%esp
}
80104fee:	c9                   	leave
80104fef:	c3                   	ret

80104ff0 <sys_close>:

int
sys_close(void)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argfd(0, &fd, &f) < 0)
80104ff6:	83 ec 04             	sub    $0x4,%esp
80104ff9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ffc:	50                   	push   %eax
80104ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105000:	50                   	push   %eax
80105001:	6a 00                	push   $0x0
80105003:	e8 f9 fd ff ff       	call   80104e01 <argfd>
80105008:	83 c4 10             	add    $0x10,%esp
8010500b:	85 c0                	test   %eax,%eax
8010500d:	79 07                	jns    80105016 <sys_close+0x26>
    return -1;
8010500f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105014:	eb 27                	jmp    8010503d <sys_close+0x4d>
  myproc()->ofile[fd] = 0;
80105016:	e8 15 ea ff ff       	call   80103a30 <myproc>
8010501b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010501e:	83 c2 08             	add    $0x8,%edx
80105021:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105028:	00 
  fileclose(f);
80105029:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010502c:	83 ec 0c             	sub    $0xc,%esp
8010502f:	50                   	push   %eax
80105030:	e8 70 c0 ff ff       	call   801010a5 <fileclose>
80105035:	83 c4 10             	add    $0x10,%esp
  return 0;
80105038:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010503d:	c9                   	leave
8010503e:	c3                   	ret

8010503f <sys_fstat>:

int
sys_fstat(void)
{
8010503f:	55                   	push   %ebp
80105040:	89 e5                	mov    %esp,%ebp
80105042:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;

  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105045:	83 ec 04             	sub    $0x4,%esp
80105048:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010504b:	50                   	push   %eax
8010504c:	6a 00                	push   $0x0
8010504e:	6a 00                	push   $0x0
80105050:	e8 ac fd ff ff       	call   80104e01 <argfd>
80105055:	83 c4 10             	add    $0x10,%esp
80105058:	85 c0                	test   %eax,%eax
8010505a:	78 17                	js     80105073 <sys_fstat+0x34>
8010505c:	83 ec 04             	sub    $0x4,%esp
8010505f:	6a 14                	push   $0x14
80105061:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105064:	50                   	push   %eax
80105065:	6a 01                	push   $0x1
80105067:	e8 78 fc ff ff       	call   80104ce4 <argptr>
8010506c:	83 c4 10             	add    $0x10,%esp
8010506f:	85 c0                	test   %eax,%eax
80105071:	79 07                	jns    8010507a <sys_fstat+0x3b>
    return -1;
80105073:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105078:	eb 13                	jmp    8010508d <sys_fstat+0x4e>
  return filestat(f, st);
8010507a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010507d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105080:	83 ec 08             	sub    $0x8,%esp
80105083:	52                   	push   %edx
80105084:	50                   	push   %eax
80105085:	e8 03 c1 ff ff       	call   8010118d <filestat>
8010508a:	83 c4 10             	add    $0x10,%esp
}
8010508d:	c9                   	leave
8010508e:	c3                   	ret

8010508f <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
8010508f:	55                   	push   %ebp
80105090:	89 e5                	mov    %esp,%ebp
80105092:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105095:	83 ec 08             	sub    $0x8,%esp
80105098:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010509b:	50                   	push   %eax
8010509c:	6a 00                	push   $0x0
8010509e:	e8 a9 fc ff ff       	call   80104d4c <argstr>
801050a3:	83 c4 10             	add    $0x10,%esp
801050a6:	85 c0                	test   %eax,%eax
801050a8:	78 15                	js     801050bf <sys_link+0x30>
801050aa:	83 ec 08             	sub    $0x8,%esp
801050ad:	8d 45 dc             	lea    -0x24(%ebp),%eax
801050b0:	50                   	push   %eax
801050b1:	6a 01                	push   $0x1
801050b3:	e8 94 fc ff ff       	call   80104d4c <argstr>
801050b8:	83 c4 10             	add    $0x10,%esp
801050bb:	85 c0                	test   %eax,%eax
801050bd:	79 0a                	jns    801050c9 <sys_link+0x3a>
    return -1;
801050bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050c4:	e9 68 01 00 00       	jmp    80105231 <sys_link+0x1a2>

  begin_op();
801050c9:	e8 70 df ff ff       	call   8010303e <begin_op>
  if((ip = namei(old)) == 0){
801050ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801050d1:	83 ec 0c             	sub    $0xc,%esp
801050d4:	50                   	push   %eax
801050d5:	e8 4b d4 ff ff       	call   80102525 <namei>
801050da:	83 c4 10             	add    $0x10,%esp
801050dd:	89 45 f4             	mov    %eax,-0xc(%ebp)
801050e0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801050e4:	75 0f                	jne    801050f5 <sys_link+0x66>
    end_op();
801050e6:	e8 df df ff ff       	call   801030ca <end_op>
    return -1;
801050eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050f0:	e9 3c 01 00 00       	jmp    80105231 <sys_link+0x1a2>
  }

  ilock(ip);
801050f5:	83 ec 0c             	sub    $0xc,%esp
801050f8:	ff 75 f4             	push   -0xc(%ebp)
801050fb:	e8 f2 c8 ff ff       	call   801019f2 <ilock>
80105100:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105103:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105106:	0f b7 40 50          	movzwl 0x50(%eax),%eax
8010510a:	66 83 f8 01          	cmp    $0x1,%ax
8010510e:	75 1d                	jne    8010512d <sys_link+0x9e>
    iunlockput(ip);
80105110:	83 ec 0c             	sub    $0xc,%esp
80105113:	ff 75 f4             	push   -0xc(%ebp)
80105116:	e8 08 cb ff ff       	call   80101c23 <iunlockput>
8010511b:	83 c4 10             	add    $0x10,%esp
    end_op();
8010511e:	e8 a7 df ff ff       	call   801030ca <end_op>
    return -1;
80105123:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105128:	e9 04 01 00 00       	jmp    80105231 <sys_link+0x1a2>
  }

  ip->nlink++;
8010512d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105130:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105134:	83 c0 01             	add    $0x1,%eax
80105137:	89 c2                	mov    %eax,%edx
80105139:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010513c:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105140:	83 ec 0c             	sub    $0xc,%esp
80105143:	ff 75 f4             	push   -0xc(%ebp)
80105146:	e8 ca c6 ff ff       	call   80101815 <iupdate>
8010514b:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
8010514e:	83 ec 0c             	sub    $0xc,%esp
80105151:	ff 75 f4             	push   -0xc(%ebp)
80105154:	e8 ac c9 ff ff       	call   80101b05 <iunlock>
80105159:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
8010515c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010515f:	83 ec 08             	sub    $0x8,%esp
80105162:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105165:	52                   	push   %edx
80105166:	50                   	push   %eax
80105167:	e8 d5 d3 ff ff       	call   80102541 <nameiparent>
8010516c:	83 c4 10             	add    $0x10,%esp
8010516f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105172:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105176:	74 71                	je     801051e9 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105178:	83 ec 0c             	sub    $0xc,%esp
8010517b:	ff 75 f0             	push   -0x10(%ebp)
8010517e:	e8 6f c8 ff ff       	call   801019f2 <ilock>
80105183:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105186:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105189:	8b 10                	mov    (%eax),%edx
8010518b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010518e:	8b 00                	mov    (%eax),%eax
80105190:	39 c2                	cmp    %eax,%edx
80105192:	75 1d                	jne    801051b1 <sys_link+0x122>
80105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105197:	8b 40 04             	mov    0x4(%eax),%eax
8010519a:	83 ec 04             	sub    $0x4,%esp
8010519d:	50                   	push   %eax
8010519e:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801051a1:	50                   	push   %eax
801051a2:	ff 75 f0             	push   -0x10(%ebp)
801051a5:	e8 e4 d0 ff ff       	call   8010228e <dirlink>
801051aa:	83 c4 10             	add    $0x10,%esp
801051ad:	85 c0                	test   %eax,%eax
801051af:	79 10                	jns    801051c1 <sys_link+0x132>
    iunlockput(dp);
801051b1:	83 ec 0c             	sub    $0xc,%esp
801051b4:	ff 75 f0             	push   -0x10(%ebp)
801051b7:	e8 67 ca ff ff       	call   80101c23 <iunlockput>
801051bc:	83 c4 10             	add    $0x10,%esp
    goto bad;
801051bf:	eb 29                	jmp    801051ea <sys_link+0x15b>
  }
  iunlockput(dp);
801051c1:	83 ec 0c             	sub    $0xc,%esp
801051c4:	ff 75 f0             	push   -0x10(%ebp)
801051c7:	e8 57 ca ff ff       	call   80101c23 <iunlockput>
801051cc:	83 c4 10             	add    $0x10,%esp
  iput(ip);
801051cf:	83 ec 0c             	sub    $0xc,%esp
801051d2:	ff 75 f4             	push   -0xc(%ebp)
801051d5:	e8 79 c9 ff ff       	call   80101b53 <iput>
801051da:	83 c4 10             	add    $0x10,%esp

  end_op();
801051dd:	e8 e8 de ff ff       	call   801030ca <end_op>

  return 0;
801051e2:	b8 00 00 00 00       	mov    $0x0,%eax
801051e7:	eb 48                	jmp    80105231 <sys_link+0x1a2>
    goto bad;
801051e9:	90                   	nop

bad:
  ilock(ip);
801051ea:	83 ec 0c             	sub    $0xc,%esp
801051ed:	ff 75 f4             	push   -0xc(%ebp)
801051f0:	e8 fd c7 ff ff       	call   801019f2 <ilock>
801051f5:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
801051f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fb:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801051ff:	83 e8 01             	sub    $0x1,%eax
80105202:	89 c2                	mov    %eax,%edx
80105204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105207:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
8010520b:	83 ec 0c             	sub    $0xc,%esp
8010520e:	ff 75 f4             	push   -0xc(%ebp)
80105211:	e8 ff c5 ff ff       	call   80101815 <iupdate>
80105216:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105219:	83 ec 0c             	sub    $0xc,%esp
8010521c:	ff 75 f4             	push   -0xc(%ebp)
8010521f:	e8 ff c9 ff ff       	call   80101c23 <iunlockput>
80105224:	83 c4 10             	add    $0x10,%esp
  end_op();
80105227:	e8 9e de ff ff       	call   801030ca <end_op>
  return -1;
8010522c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105231:	c9                   	leave
80105232:	c3                   	ret

80105233 <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105233:	55                   	push   %ebp
80105234:	89 e5                	mov    %esp,%ebp
80105236:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105239:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105240:	eb 40                	jmp    80105282 <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105242:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105245:	6a 10                	push   $0x10
80105247:	50                   	push   %eax
80105248:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010524b:	50                   	push   %eax
8010524c:	ff 75 08             	push   0x8(%ebp)
8010524f:	e8 8a cc ff ff       	call   80101ede <readi>
80105254:	83 c4 10             	add    $0x10,%esp
80105257:	83 f8 10             	cmp    $0x10,%eax
8010525a:	74 0d                	je     80105269 <isdirempty+0x36>
      panic("isdirempty: readi");
8010525c:	83 ec 0c             	sub    $0xc,%esp
8010525f:	68 f4 a3 10 80       	push   $0x8010a3f4
80105264:	e8 40 b3 ff ff       	call   801005a9 <panic>
    if(de.inum != 0)
80105269:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
8010526d:	66 85 c0             	test   %ax,%ax
80105270:	74 07                	je     80105279 <isdirempty+0x46>
      return 0;
80105272:	b8 00 00 00 00       	mov    $0x0,%eax
80105277:	eb 1b                	jmp    80105294 <isdirempty+0x61>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105279:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010527c:	83 c0 10             	add    $0x10,%eax
8010527f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105282:	8b 45 08             	mov    0x8(%ebp),%eax
80105285:	8b 40 58             	mov    0x58(%eax),%eax
80105288:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010528b:	39 c2                	cmp    %eax,%edx
8010528d:	72 b3                	jb     80105242 <isdirempty+0xf>
  }
  return 1;
8010528f:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105294:	c9                   	leave
80105295:	c3                   	ret

80105296 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105296:	55                   	push   %ebp
80105297:	89 e5                	mov    %esp,%ebp
80105299:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
8010529c:	83 ec 08             	sub    $0x8,%esp
8010529f:	8d 45 cc             	lea    -0x34(%ebp),%eax
801052a2:	50                   	push   %eax
801052a3:	6a 00                	push   $0x0
801052a5:	e8 a2 fa ff ff       	call   80104d4c <argstr>
801052aa:	83 c4 10             	add    $0x10,%esp
801052ad:	85 c0                	test   %eax,%eax
801052af:	79 0a                	jns    801052bb <sys_unlink+0x25>
    return -1;
801052b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052b6:	e9 bf 01 00 00       	jmp    8010547a <sys_unlink+0x1e4>

  begin_op();
801052bb:	e8 7e dd ff ff       	call   8010303e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801052c0:	8b 45 cc             	mov    -0x34(%ebp),%eax
801052c3:	83 ec 08             	sub    $0x8,%esp
801052c6:	8d 55 d2             	lea    -0x2e(%ebp),%edx
801052c9:	52                   	push   %edx
801052ca:	50                   	push   %eax
801052cb:	e8 71 d2 ff ff       	call   80102541 <nameiparent>
801052d0:	83 c4 10             	add    $0x10,%esp
801052d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801052d6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801052da:	75 0f                	jne    801052eb <sys_unlink+0x55>
    end_op();
801052dc:	e8 e9 dd ff ff       	call   801030ca <end_op>
    return -1;
801052e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801052e6:	e9 8f 01 00 00       	jmp    8010547a <sys_unlink+0x1e4>
  }

  ilock(dp);
801052eb:	83 ec 0c             	sub    $0xc,%esp
801052ee:	ff 75 f4             	push   -0xc(%ebp)
801052f1:	e8 fc c6 ff ff       	call   801019f2 <ilock>
801052f6:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801052f9:	83 ec 08             	sub    $0x8,%esp
801052fc:	68 06 a4 10 80       	push   $0x8010a406
80105301:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105304:	50                   	push   %eax
80105305:	e8 af ce ff ff       	call   801021b9 <namecmp>
8010530a:	83 c4 10             	add    $0x10,%esp
8010530d:	85 c0                	test   %eax,%eax
8010530f:	0f 84 49 01 00 00    	je     8010545e <sys_unlink+0x1c8>
80105315:	83 ec 08             	sub    $0x8,%esp
80105318:	68 08 a4 10 80       	push   $0x8010a408
8010531d:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105320:	50                   	push   %eax
80105321:	e8 93 ce ff ff       	call   801021b9 <namecmp>
80105326:	83 c4 10             	add    $0x10,%esp
80105329:	85 c0                	test   %eax,%eax
8010532b:	0f 84 2d 01 00 00    	je     8010545e <sys_unlink+0x1c8>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105331:	83 ec 04             	sub    $0x4,%esp
80105334:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105337:	50                   	push   %eax
80105338:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010533b:	50                   	push   %eax
8010533c:	ff 75 f4             	push   -0xc(%ebp)
8010533f:	e8 90 ce ff ff       	call   801021d4 <dirlookup>
80105344:	83 c4 10             	add    $0x10,%esp
80105347:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010534a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010534e:	0f 84 0d 01 00 00    	je     80105461 <sys_unlink+0x1cb>
    goto bad;
  ilock(ip);
80105354:	83 ec 0c             	sub    $0xc,%esp
80105357:	ff 75 f0             	push   -0x10(%ebp)
8010535a:	e8 93 c6 ff ff       	call   801019f2 <ilock>
8010535f:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105362:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105365:	0f b7 40 56          	movzwl 0x56(%eax),%eax
80105369:	66 85 c0             	test   %ax,%ax
8010536c:	7f 0d                	jg     8010537b <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
8010536e:	83 ec 0c             	sub    $0xc,%esp
80105371:	68 0b a4 10 80       	push   $0x8010a40b
80105376:	e8 2e b2 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
8010537b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010537e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105382:	66 83 f8 01          	cmp    $0x1,%ax
80105386:	75 25                	jne    801053ad <sys_unlink+0x117>
80105388:	83 ec 0c             	sub    $0xc,%esp
8010538b:	ff 75 f0             	push   -0x10(%ebp)
8010538e:	e8 a0 fe ff ff       	call   80105233 <isdirempty>
80105393:	83 c4 10             	add    $0x10,%esp
80105396:	85 c0                	test   %eax,%eax
80105398:	75 13                	jne    801053ad <sys_unlink+0x117>
    iunlockput(ip);
8010539a:	83 ec 0c             	sub    $0xc,%esp
8010539d:	ff 75 f0             	push   -0x10(%ebp)
801053a0:	e8 7e c8 ff ff       	call   80101c23 <iunlockput>
801053a5:	83 c4 10             	add    $0x10,%esp
    goto bad;
801053a8:	e9 b5 00 00 00       	jmp    80105462 <sys_unlink+0x1cc>
  }

  memset(&de, 0, sizeof(de));
801053ad:	83 ec 04             	sub    $0x4,%esp
801053b0:	6a 10                	push   $0x10
801053b2:	6a 00                	push   $0x0
801053b4:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053b7:	50                   	push   %eax
801053b8:	e8 cf f5 ff ff       	call   8010498c <memset>
801053bd:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801053c0:	8b 45 c8             	mov    -0x38(%ebp),%eax
801053c3:	6a 10                	push   $0x10
801053c5:	50                   	push   %eax
801053c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
801053c9:	50                   	push   %eax
801053ca:	ff 75 f4             	push   -0xc(%ebp)
801053cd:	e8 61 cc ff ff       	call   80102033 <writei>
801053d2:	83 c4 10             	add    $0x10,%esp
801053d5:	83 f8 10             	cmp    $0x10,%eax
801053d8:	74 0d                	je     801053e7 <sys_unlink+0x151>
    panic("unlink: writei");
801053da:	83 ec 0c             	sub    $0xc,%esp
801053dd:	68 1d a4 10 80       	push   $0x8010a41d
801053e2:	e8 c2 b1 ff ff       	call   801005a9 <panic>
  if(ip->type == T_DIR){
801053e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053ea:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801053ee:	66 83 f8 01          	cmp    $0x1,%ax
801053f2:	75 21                	jne    80105415 <sys_unlink+0x17f>
    dp->nlink--;
801053f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801053f7:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801053fb:	83 e8 01             	sub    $0x1,%eax
801053fe:	89 c2                	mov    %eax,%edx
80105400:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105403:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
80105407:	83 ec 0c             	sub    $0xc,%esp
8010540a:	ff 75 f4             	push   -0xc(%ebp)
8010540d:	e8 03 c4 ff ff       	call   80101815 <iupdate>
80105412:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105415:	83 ec 0c             	sub    $0xc,%esp
80105418:	ff 75 f4             	push   -0xc(%ebp)
8010541b:	e8 03 c8 ff ff       	call   80101c23 <iunlockput>
80105420:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105426:	0f b7 40 56          	movzwl 0x56(%eax),%eax
8010542a:	83 e8 01             	sub    $0x1,%eax
8010542d:	89 c2                	mov    %eax,%edx
8010542f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105432:	66 89 50 56          	mov    %dx,0x56(%eax)
  iupdate(ip);
80105436:	83 ec 0c             	sub    $0xc,%esp
80105439:	ff 75 f0             	push   -0x10(%ebp)
8010543c:	e8 d4 c3 ff ff       	call   80101815 <iupdate>
80105441:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105444:	83 ec 0c             	sub    $0xc,%esp
80105447:	ff 75 f0             	push   -0x10(%ebp)
8010544a:	e8 d4 c7 ff ff       	call   80101c23 <iunlockput>
8010544f:	83 c4 10             	add    $0x10,%esp

  end_op();
80105452:	e8 73 dc ff ff       	call   801030ca <end_op>

  return 0;
80105457:	b8 00 00 00 00       	mov    $0x0,%eax
8010545c:	eb 1c                	jmp    8010547a <sys_unlink+0x1e4>
    goto bad;
8010545e:	90                   	nop
8010545f:	eb 01                	jmp    80105462 <sys_unlink+0x1cc>
    goto bad;
80105461:	90                   	nop

bad:
  iunlockput(dp);
80105462:	83 ec 0c             	sub    $0xc,%esp
80105465:	ff 75 f4             	push   -0xc(%ebp)
80105468:	e8 b6 c7 ff ff       	call   80101c23 <iunlockput>
8010546d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105470:	e8 55 dc ff ff       	call   801030ca <end_op>
  return -1;
80105475:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010547a:	c9                   	leave
8010547b:	c3                   	ret

8010547c <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
8010547c:	55                   	push   %ebp
8010547d:	89 e5                	mov    %esp,%ebp
8010547f:	83 ec 38             	sub    $0x38,%esp
80105482:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105485:	8b 55 10             	mov    0x10(%ebp),%edx
80105488:	8b 45 14             	mov    0x14(%ebp),%eax
8010548b:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
8010548f:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105493:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105497:	83 ec 08             	sub    $0x8,%esp
8010549a:	8d 45 de             	lea    -0x22(%ebp),%eax
8010549d:	50                   	push   %eax
8010549e:	ff 75 08             	push   0x8(%ebp)
801054a1:	e8 9b d0 ff ff       	call   80102541 <nameiparent>
801054a6:	83 c4 10             	add    $0x10,%esp
801054a9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801054ac:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801054b0:	75 0a                	jne    801054bc <create+0x40>
    return 0;
801054b2:	b8 00 00 00 00       	mov    $0x0,%eax
801054b7:	e9 90 01 00 00       	jmp    8010564c <create+0x1d0>
  ilock(dp);
801054bc:	83 ec 0c             	sub    $0xc,%esp
801054bf:	ff 75 f4             	push   -0xc(%ebp)
801054c2:	e8 2b c5 ff ff       	call   801019f2 <ilock>
801054c7:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
801054ca:	83 ec 04             	sub    $0x4,%esp
801054cd:	8d 45 ec             	lea    -0x14(%ebp),%eax
801054d0:	50                   	push   %eax
801054d1:	8d 45 de             	lea    -0x22(%ebp),%eax
801054d4:	50                   	push   %eax
801054d5:	ff 75 f4             	push   -0xc(%ebp)
801054d8:	e8 f7 cc ff ff       	call   801021d4 <dirlookup>
801054dd:	83 c4 10             	add    $0x10,%esp
801054e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
801054e3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801054e7:	74 50                	je     80105539 <create+0xbd>
    iunlockput(dp);
801054e9:	83 ec 0c             	sub    $0xc,%esp
801054ec:	ff 75 f4             	push   -0xc(%ebp)
801054ef:	e8 2f c7 ff ff       	call   80101c23 <iunlockput>
801054f4:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
801054f7:	83 ec 0c             	sub    $0xc,%esp
801054fa:	ff 75 f0             	push   -0x10(%ebp)
801054fd:	e8 f0 c4 ff ff       	call   801019f2 <ilock>
80105502:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105505:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
8010550a:	75 15                	jne    80105521 <create+0xa5>
8010550c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010550f:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105513:	66 83 f8 02          	cmp    $0x2,%ax
80105517:	75 08                	jne    80105521 <create+0xa5>
      return ip;
80105519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010551c:	e9 2b 01 00 00       	jmp    8010564c <create+0x1d0>
    iunlockput(ip);
80105521:	83 ec 0c             	sub    $0xc,%esp
80105524:	ff 75 f0             	push   -0x10(%ebp)
80105527:	e8 f7 c6 ff ff       	call   80101c23 <iunlockput>
8010552c:	83 c4 10             	add    $0x10,%esp
    return 0;
8010552f:	b8 00 00 00 00       	mov    $0x0,%eax
80105534:	e9 13 01 00 00       	jmp    8010564c <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105539:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
8010553d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105540:	8b 00                	mov    (%eax),%eax
80105542:	83 ec 08             	sub    $0x8,%esp
80105545:	52                   	push   %edx
80105546:	50                   	push   %eax
80105547:	e8 f3 c1 ff ff       	call   8010173f <ialloc>
8010554c:	83 c4 10             	add    $0x10,%esp
8010554f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105552:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105556:	75 0d                	jne    80105565 <create+0xe9>
    panic("create: ialloc");
80105558:	83 ec 0c             	sub    $0xc,%esp
8010555b:	68 2c a4 10 80       	push   $0x8010a42c
80105560:	e8 44 b0 ff ff       	call   801005a9 <panic>

  ilock(ip);
80105565:	83 ec 0c             	sub    $0xc,%esp
80105568:	ff 75 f0             	push   -0x10(%ebp)
8010556b:	e8 82 c4 ff ff       	call   801019f2 <ilock>
80105570:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105573:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105576:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
8010557a:	66 89 50 52          	mov    %dx,0x52(%eax)
  ip->minor = minor;
8010557e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105581:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105585:	66 89 50 54          	mov    %dx,0x54(%eax)
  ip->nlink = 1;
80105589:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010558c:	66 c7 40 56 01 00    	movw   $0x1,0x56(%eax)
  iupdate(ip);
80105592:	83 ec 0c             	sub    $0xc,%esp
80105595:	ff 75 f0             	push   -0x10(%ebp)
80105598:	e8 78 c2 ff ff       	call   80101815 <iupdate>
8010559d:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801055a0:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801055a5:	75 6a                	jne    80105611 <create+0x195>
    dp->nlink++;  // for ".."
801055a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055aa:	0f b7 40 56          	movzwl 0x56(%eax),%eax
801055ae:	83 c0 01             	add    $0x1,%eax
801055b1:	89 c2                	mov    %eax,%edx
801055b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055b6:	66 89 50 56          	mov    %dx,0x56(%eax)
    iupdate(dp);
801055ba:	83 ec 0c             	sub    $0xc,%esp
801055bd:	ff 75 f4             	push   -0xc(%ebp)
801055c0:	e8 50 c2 ff ff       	call   80101815 <iupdate>
801055c5:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801055c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801055cb:	8b 40 04             	mov    0x4(%eax),%eax
801055ce:	83 ec 04             	sub    $0x4,%esp
801055d1:	50                   	push   %eax
801055d2:	68 06 a4 10 80       	push   $0x8010a406
801055d7:	ff 75 f0             	push   -0x10(%ebp)
801055da:	e8 af cc ff ff       	call   8010228e <dirlink>
801055df:	83 c4 10             	add    $0x10,%esp
801055e2:	85 c0                	test   %eax,%eax
801055e4:	78 1e                	js     80105604 <create+0x188>
801055e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801055e9:	8b 40 04             	mov    0x4(%eax),%eax
801055ec:	83 ec 04             	sub    $0x4,%esp
801055ef:	50                   	push   %eax
801055f0:	68 08 a4 10 80       	push   $0x8010a408
801055f5:	ff 75 f0             	push   -0x10(%ebp)
801055f8:	e8 91 cc ff ff       	call   8010228e <dirlink>
801055fd:	83 c4 10             	add    $0x10,%esp
80105600:	85 c0                	test   %eax,%eax
80105602:	79 0d                	jns    80105611 <create+0x195>
      panic("create dots");
80105604:	83 ec 0c             	sub    $0xc,%esp
80105607:	68 3b a4 10 80       	push   $0x8010a43b
8010560c:	e8 98 af ff ff       	call   801005a9 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80105611:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105614:	8b 40 04             	mov    0x4(%eax),%eax
80105617:	83 ec 04             	sub    $0x4,%esp
8010561a:	50                   	push   %eax
8010561b:	8d 45 de             	lea    -0x22(%ebp),%eax
8010561e:	50                   	push   %eax
8010561f:	ff 75 f4             	push   -0xc(%ebp)
80105622:	e8 67 cc ff ff       	call   8010228e <dirlink>
80105627:	83 c4 10             	add    $0x10,%esp
8010562a:	85 c0                	test   %eax,%eax
8010562c:	79 0d                	jns    8010563b <create+0x1bf>
    panic("create: dirlink");
8010562e:	83 ec 0c             	sub    $0xc,%esp
80105631:	68 47 a4 10 80       	push   $0x8010a447
80105636:	e8 6e af ff ff       	call   801005a9 <panic>

  iunlockput(dp);
8010563b:	83 ec 0c             	sub    $0xc,%esp
8010563e:	ff 75 f4             	push   -0xc(%ebp)
80105641:	e8 dd c5 ff ff       	call   80101c23 <iunlockput>
80105646:	83 c4 10             	add    $0x10,%esp

  return ip;
80105649:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
8010564c:	c9                   	leave
8010564d:	c3                   	ret

8010564e <sys_open>:

int
sys_open(void)
{
8010564e:	55                   	push   %ebp
8010564f:	89 e5                	mov    %esp,%ebp
80105651:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80105654:	83 ec 08             	sub    $0x8,%esp
80105657:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010565a:	50                   	push   %eax
8010565b:	6a 00                	push   $0x0
8010565d:	e8 ea f6 ff ff       	call   80104d4c <argstr>
80105662:	83 c4 10             	add    $0x10,%esp
80105665:	85 c0                	test   %eax,%eax
80105667:	78 15                	js     8010567e <sys_open+0x30>
80105669:	83 ec 08             	sub    $0x8,%esp
8010566c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010566f:	50                   	push   %eax
80105670:	6a 01                	push   $0x1
80105672:	e8 40 f6 ff ff       	call   80104cb7 <argint>
80105677:	83 c4 10             	add    $0x10,%esp
8010567a:	85 c0                	test   %eax,%eax
8010567c:	79 0a                	jns    80105688 <sys_open+0x3a>
    return -1;
8010567e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105683:	e9 61 01 00 00       	jmp    801057e9 <sys_open+0x19b>

  begin_op();
80105688:	e8 b1 d9 ff ff       	call   8010303e <begin_op>

  if(omode & O_CREATE){
8010568d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105690:	25 00 02 00 00       	and    $0x200,%eax
80105695:	85 c0                	test   %eax,%eax
80105697:	74 2a                	je     801056c3 <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80105699:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010569c:	6a 00                	push   $0x0
8010569e:	6a 00                	push   $0x0
801056a0:	6a 02                	push   $0x2
801056a2:	50                   	push   %eax
801056a3:	e8 d4 fd ff ff       	call   8010547c <create>
801056a8:	83 c4 10             	add    $0x10,%esp
801056ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
801056ae:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056b2:	75 75                	jne    80105729 <sys_open+0xdb>
      end_op();
801056b4:	e8 11 da ff ff       	call   801030ca <end_op>
      return -1;
801056b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056be:	e9 26 01 00 00       	jmp    801057e9 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
801056c3:	8b 45 e8             	mov    -0x18(%ebp),%eax
801056c6:	83 ec 0c             	sub    $0xc,%esp
801056c9:	50                   	push   %eax
801056ca:	e8 56 ce ff ff       	call   80102525 <namei>
801056cf:	83 c4 10             	add    $0x10,%esp
801056d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801056d5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801056d9:	75 0f                	jne    801056ea <sys_open+0x9c>
      end_op();
801056db:	e8 ea d9 ff ff       	call   801030ca <end_op>
      return -1;
801056e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e5:	e9 ff 00 00 00       	jmp    801057e9 <sys_open+0x19b>
    }
    ilock(ip);
801056ea:	83 ec 0c             	sub    $0xc,%esp
801056ed:	ff 75 f4             	push   -0xc(%ebp)
801056f0:	e8 fd c2 ff ff       	call   801019f2 <ilock>
801056f5:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
801056f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801056fb:	0f b7 40 50          	movzwl 0x50(%eax),%eax
801056ff:	66 83 f8 01          	cmp    $0x1,%ax
80105703:	75 24                	jne    80105729 <sys_open+0xdb>
80105705:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105708:	85 c0                	test   %eax,%eax
8010570a:	74 1d                	je     80105729 <sys_open+0xdb>
      iunlockput(ip);
8010570c:	83 ec 0c             	sub    $0xc,%esp
8010570f:	ff 75 f4             	push   -0xc(%ebp)
80105712:	e8 0c c5 ff ff       	call   80101c23 <iunlockput>
80105717:	83 c4 10             	add    $0x10,%esp
      end_op();
8010571a:	e8 ab d9 ff ff       	call   801030ca <end_op>
      return -1;
8010571f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105724:	e9 c0 00 00 00       	jmp    801057e9 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80105729:	e8 b9 b8 ff ff       	call   80100fe7 <filealloc>
8010572e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105731:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105735:	74 17                	je     8010574e <sys_open+0x100>
80105737:	83 ec 0c             	sub    $0xc,%esp
8010573a:	ff 75 f0             	push   -0x10(%ebp)
8010573d:	e8 33 f7 ff ff       	call   80104e75 <fdalloc>
80105742:	83 c4 10             	add    $0x10,%esp
80105745:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105748:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010574c:	79 2e                	jns    8010577c <sys_open+0x12e>
    if(f)
8010574e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105752:	74 0e                	je     80105762 <sys_open+0x114>
      fileclose(f);
80105754:	83 ec 0c             	sub    $0xc,%esp
80105757:	ff 75 f0             	push   -0x10(%ebp)
8010575a:	e8 46 b9 ff ff       	call   801010a5 <fileclose>
8010575f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80105762:	83 ec 0c             	sub    $0xc,%esp
80105765:	ff 75 f4             	push   -0xc(%ebp)
80105768:	e8 b6 c4 ff ff       	call   80101c23 <iunlockput>
8010576d:	83 c4 10             	add    $0x10,%esp
    end_op();
80105770:	e8 55 d9 ff ff       	call   801030ca <end_op>
    return -1;
80105775:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577a:	eb 6d                	jmp    801057e9 <sys_open+0x19b>
  }
  iunlock(ip);
8010577c:	83 ec 0c             	sub    $0xc,%esp
8010577f:	ff 75 f4             	push   -0xc(%ebp)
80105782:	e8 7e c3 ff ff       	call   80101b05 <iunlock>
80105787:	83 c4 10             	add    $0x10,%esp
  end_op();
8010578a:	e8 3b d9 ff ff       	call   801030ca <end_op>

  f->type = FD_INODE;
8010578f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105792:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
80105798:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010579b:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010579e:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801057a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057a4:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
801057ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057ae:	83 e0 01             	and    $0x1,%eax
801057b1:	85 c0                	test   %eax,%eax
801057b3:	0f 94 c0             	sete   %al
801057b6:	89 c2                	mov    %eax,%edx
801057b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057bb:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801057be:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057c1:	83 e0 01             	and    $0x1,%eax
801057c4:	85 c0                	test   %eax,%eax
801057c6:	75 0a                	jne    801057d2 <sys_open+0x184>
801057c8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801057cb:	83 e0 02             	and    $0x2,%eax
801057ce:	85 c0                	test   %eax,%eax
801057d0:	74 07                	je     801057d9 <sys_open+0x18b>
801057d2:	b8 01 00 00 00       	mov    $0x1,%eax
801057d7:	eb 05                	jmp    801057de <sys_open+0x190>
801057d9:	b8 00 00 00 00       	mov    $0x0,%eax
801057de:	89 c2                	mov    %eax,%edx
801057e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801057e3:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
801057e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
801057e9:	c9                   	leave
801057ea:	c3                   	ret

801057eb <sys_mkdir>:

int
sys_mkdir(void)
{
801057eb:	55                   	push   %ebp
801057ec:	89 e5                	mov    %esp,%ebp
801057ee:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801057f1:	e8 48 d8 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801057f6:	83 ec 08             	sub    $0x8,%esp
801057f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
801057fc:	50                   	push   %eax
801057fd:	6a 00                	push   $0x0
801057ff:	e8 48 f5 ff ff       	call   80104d4c <argstr>
80105804:	83 c4 10             	add    $0x10,%esp
80105807:	85 c0                	test   %eax,%eax
80105809:	78 1b                	js     80105826 <sys_mkdir+0x3b>
8010580b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010580e:	6a 00                	push   $0x0
80105810:	6a 00                	push   $0x0
80105812:	6a 01                	push   $0x1
80105814:	50                   	push   %eax
80105815:	e8 62 fc ff ff       	call   8010547c <create>
8010581a:	83 c4 10             	add    $0x10,%esp
8010581d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105820:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105824:	75 0c                	jne    80105832 <sys_mkdir+0x47>
    end_op();
80105826:	e8 9f d8 ff ff       	call   801030ca <end_op>
    return -1;
8010582b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105830:	eb 18                	jmp    8010584a <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80105832:	83 ec 0c             	sub    $0xc,%esp
80105835:	ff 75 f4             	push   -0xc(%ebp)
80105838:	e8 e6 c3 ff ff       	call   80101c23 <iunlockput>
8010583d:	83 c4 10             	add    $0x10,%esp
  end_op();
80105840:	e8 85 d8 ff ff       	call   801030ca <end_op>
  return 0;
80105845:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010584a:	c9                   	leave
8010584b:	c3                   	ret

8010584c <sys_mknod>:

int
sys_mknod(void)
{
8010584c:	55                   	push   %ebp
8010584d:	89 e5                	mov    %esp,%ebp
8010584f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105852:	e8 e7 d7 ff ff       	call   8010303e <begin_op>
  if((argstr(0, &path)) < 0 ||
80105857:	83 ec 08             	sub    $0x8,%esp
8010585a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010585d:	50                   	push   %eax
8010585e:	6a 00                	push   $0x0
80105860:	e8 e7 f4 ff ff       	call   80104d4c <argstr>
80105865:	83 c4 10             	add    $0x10,%esp
80105868:	85 c0                	test   %eax,%eax
8010586a:	78 4f                	js     801058bb <sys_mknod+0x6f>
     argint(1, &major) < 0 ||
8010586c:	83 ec 08             	sub    $0x8,%esp
8010586f:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105872:	50                   	push   %eax
80105873:	6a 01                	push   $0x1
80105875:	e8 3d f4 ff ff       	call   80104cb7 <argint>
8010587a:	83 c4 10             	add    $0x10,%esp
  if((argstr(0, &path)) < 0 ||
8010587d:	85 c0                	test   %eax,%eax
8010587f:	78 3a                	js     801058bb <sys_mknod+0x6f>
     argint(2, &minor) < 0 ||
80105881:	83 ec 08             	sub    $0x8,%esp
80105884:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105887:	50                   	push   %eax
80105888:	6a 02                	push   $0x2
8010588a:	e8 28 f4 ff ff       	call   80104cb7 <argint>
8010588f:	83 c4 10             	add    $0x10,%esp
     argint(1, &major) < 0 ||
80105892:	85 c0                	test   %eax,%eax
80105894:	78 25                	js     801058bb <sys_mknod+0x6f>
     (ip = create(path, T_DEV, major, minor)) == 0){
80105896:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105899:	0f bf c8             	movswl %ax,%ecx
8010589c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010589f:	0f bf d0             	movswl %ax,%edx
801058a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801058a5:	51                   	push   %ecx
801058a6:	52                   	push   %edx
801058a7:	6a 03                	push   $0x3
801058a9:	50                   	push   %eax
801058aa:	e8 cd fb ff ff       	call   8010547c <create>
801058af:	83 c4 10             	add    $0x10,%esp
801058b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
     argint(2, &minor) < 0 ||
801058b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b9:	75 0c                	jne    801058c7 <sys_mknod+0x7b>
    end_op();
801058bb:	e8 0a d8 ff ff       	call   801030ca <end_op>
    return -1;
801058c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058c5:	eb 18                	jmp    801058df <sys_mknod+0x93>
  }
  iunlockput(ip);
801058c7:	83 ec 0c             	sub    $0xc,%esp
801058ca:	ff 75 f4             	push   -0xc(%ebp)
801058cd:	e8 51 c3 ff ff       	call   80101c23 <iunlockput>
801058d2:	83 c4 10             	add    $0x10,%esp
  end_op();
801058d5:	e8 f0 d7 ff ff       	call   801030ca <end_op>
  return 0;
801058da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058df:	c9                   	leave
801058e0:	c3                   	ret

801058e1 <sys_chdir>:

int
sys_chdir(void)
{
801058e1:	55                   	push   %ebp
801058e2:	89 e5                	mov    %esp,%ebp
801058e4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801058e7:	e8 44 e1 ff ff       	call   80103a30 <myproc>
801058ec:	89 45 f4             	mov    %eax,-0xc(%ebp)
  
  begin_op();
801058ef:	e8 4a d7 ff ff       	call   8010303e <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
801058f4:	83 ec 08             	sub    $0x8,%esp
801058f7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801058fa:	50                   	push   %eax
801058fb:	6a 00                	push   $0x0
801058fd:	e8 4a f4 ff ff       	call   80104d4c <argstr>
80105902:	83 c4 10             	add    $0x10,%esp
80105905:	85 c0                	test   %eax,%eax
80105907:	78 18                	js     80105921 <sys_chdir+0x40>
80105909:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010590c:	83 ec 0c             	sub    $0xc,%esp
8010590f:	50                   	push   %eax
80105910:	e8 10 cc ff ff       	call   80102525 <namei>
80105915:	83 c4 10             	add    $0x10,%esp
80105918:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010591b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010591f:	75 0c                	jne    8010592d <sys_chdir+0x4c>
    end_op();
80105921:	e8 a4 d7 ff ff       	call   801030ca <end_op>
    return -1;
80105926:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010592b:	eb 68                	jmp    80105995 <sys_chdir+0xb4>
  }
  ilock(ip);
8010592d:	83 ec 0c             	sub    $0xc,%esp
80105930:	ff 75 f0             	push   -0x10(%ebp)
80105933:	e8 ba c0 ff ff       	call   801019f2 <ilock>
80105938:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010593b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010593e:	0f b7 40 50          	movzwl 0x50(%eax),%eax
80105942:	66 83 f8 01          	cmp    $0x1,%ax
80105946:	74 1a                	je     80105962 <sys_chdir+0x81>
    iunlockput(ip);
80105948:	83 ec 0c             	sub    $0xc,%esp
8010594b:	ff 75 f0             	push   -0x10(%ebp)
8010594e:	e8 d0 c2 ff ff       	call   80101c23 <iunlockput>
80105953:	83 c4 10             	add    $0x10,%esp
    end_op();
80105956:	e8 6f d7 ff ff       	call   801030ca <end_op>
    return -1;
8010595b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105960:	eb 33                	jmp    80105995 <sys_chdir+0xb4>
  }
  iunlock(ip);
80105962:	83 ec 0c             	sub    $0xc,%esp
80105965:	ff 75 f0             	push   -0x10(%ebp)
80105968:	e8 98 c1 ff ff       	call   80101b05 <iunlock>
8010596d:	83 c4 10             	add    $0x10,%esp
  iput(curproc->cwd);
80105970:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105973:	8b 40 68             	mov    0x68(%eax),%eax
80105976:	83 ec 0c             	sub    $0xc,%esp
80105979:	50                   	push   %eax
8010597a:	e8 d4 c1 ff ff       	call   80101b53 <iput>
8010597f:	83 c4 10             	add    $0x10,%esp
  end_op();
80105982:	e8 43 d7 ff ff       	call   801030ca <end_op>
  curproc->cwd = ip;
80105987:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010598a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010598d:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
80105990:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105995:	c9                   	leave
80105996:	c3                   	ret

80105997 <sys_exec>:

int
sys_exec(void)
{
80105997:	55                   	push   %ebp
80105998:	89 e5                	mov    %esp,%ebp
8010599a:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801059a0:	83 ec 08             	sub    $0x8,%esp
801059a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a6:	50                   	push   %eax
801059a7:	6a 00                	push   $0x0
801059a9:	e8 9e f3 ff ff       	call   80104d4c <argstr>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	78 18                	js     801059cd <sys_exec+0x36>
801059b5:	83 ec 08             	sub    $0x8,%esp
801059b8:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
801059be:	50                   	push   %eax
801059bf:	6a 01                	push   $0x1
801059c1:	e8 f1 f2 ff ff       	call   80104cb7 <argint>
801059c6:	83 c4 10             	add    $0x10,%esp
801059c9:	85 c0                	test   %eax,%eax
801059cb:	79 0a                	jns    801059d7 <sys_exec+0x40>
    return -1;
801059cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d2:	e9 c6 00 00 00       	jmp    80105a9d <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
801059d7:	83 ec 04             	sub    $0x4,%esp
801059da:	68 80 00 00 00       	push   $0x80
801059df:	6a 00                	push   $0x0
801059e1:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801059e7:	50                   	push   %eax
801059e8:	e8 9f ef ff ff       	call   8010498c <memset>
801059ed:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
801059f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
801059f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059fa:	83 f8 1f             	cmp    $0x1f,%eax
801059fd:	76 0a                	jbe    80105a09 <sys_exec+0x72>
      return -1;
801059ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a04:	e9 94 00 00 00       	jmp    80105a9d <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105a09:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a0c:	c1 e0 02             	shl    $0x2,%eax
80105a0f:	89 c2                	mov    %eax,%edx
80105a11:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80105a17:	01 c2                	add    %eax,%edx
80105a19:	83 ec 08             	sub    $0x8,%esp
80105a1c:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80105a22:	50                   	push   %eax
80105a23:	52                   	push   %edx
80105a24:	e8 ed f1 ff ff       	call   80104c16 <fetchint>
80105a29:	83 c4 10             	add    $0x10,%esp
80105a2c:	85 c0                	test   %eax,%eax
80105a2e:	79 07                	jns    80105a37 <sys_exec+0xa0>
      return -1;
80105a30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a35:	eb 66                	jmp    80105a9d <sys_exec+0x106>
    if(uarg == 0){
80105a37:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a3d:	85 c0                	test   %eax,%eax
80105a3f:	75 27                	jne    80105a68 <sys_exec+0xd1>
      argv[i] = 0;
80105a41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a44:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80105a4b:	00 00 00 00 
      break;
80105a4f:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80105a50:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a53:	83 ec 08             	sub    $0x8,%esp
80105a56:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80105a5c:	52                   	push   %edx
80105a5d:	50                   	push   %eax
80105a5e:	e8 27 b1 ff ff       	call   80100b8a <exec>
80105a63:	83 c4 10             	add    $0x10,%esp
80105a66:	eb 35                	jmp    80105a9d <sys_exec+0x106>
    if(fetchstr(uarg, &argv[i]) < 0)
80105a68:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80105a6e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a71:	c1 e2 02             	shl    $0x2,%edx
80105a74:	01 c2                	add    %eax,%edx
80105a76:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80105a7c:	83 ec 08             	sub    $0x8,%esp
80105a7f:	52                   	push   %edx
80105a80:	50                   	push   %eax
80105a81:	e8 cf f1 ff ff       	call   80104c55 <fetchstr>
80105a86:	83 c4 10             	add    $0x10,%esp
80105a89:	85 c0                	test   %eax,%eax
80105a8b:	79 07                	jns    80105a94 <sys_exec+0xfd>
      return -1;
80105a8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a92:	eb 09                	jmp    80105a9d <sys_exec+0x106>
  for(i=0;; i++){
80105a94:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    if(i >= NELEM(argv))
80105a98:	e9 5a ff ff ff       	jmp    801059f7 <sys_exec+0x60>
}
80105a9d:	c9                   	leave
80105a9e:	c3                   	ret

80105a9f <sys_pipe>:

int
sys_pipe(void)
{
80105a9f:	55                   	push   %ebp
80105aa0:	89 e5                	mov    %esp,%ebp
80105aa2:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105aa5:	83 ec 04             	sub    $0x4,%esp
80105aa8:	6a 08                	push   $0x8
80105aaa:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105aad:	50                   	push   %eax
80105aae:	6a 00                	push   $0x0
80105ab0:	e8 2f f2 ff ff       	call   80104ce4 <argptr>
80105ab5:	83 c4 10             	add    $0x10,%esp
80105ab8:	85 c0                	test   %eax,%eax
80105aba:	79 0a                	jns    80105ac6 <sys_pipe+0x27>
    return -1;
80105abc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ac1:	e9 ae 00 00 00       	jmp    80105b74 <sys_pipe+0xd5>
  if(pipealloc(&rf, &wf) < 0)
80105ac6:	83 ec 08             	sub    $0x8,%esp
80105ac9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105acc:	50                   	push   %eax
80105acd:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105ad0:	50                   	push   %eax
80105ad1:	e8 97 da ff ff       	call   8010356d <pipealloc>
80105ad6:	83 c4 10             	add    $0x10,%esp
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	79 0a                	jns    80105ae7 <sys_pipe+0x48>
    return -1;
80105add:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae2:	e9 8d 00 00 00       	jmp    80105b74 <sys_pipe+0xd5>
  fd0 = -1;
80105ae7:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105aee:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105af1:	83 ec 0c             	sub    $0xc,%esp
80105af4:	50                   	push   %eax
80105af5:	e8 7b f3 ff ff       	call   80104e75 <fdalloc>
80105afa:	83 c4 10             	add    $0x10,%esp
80105afd:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b00:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b04:	78 18                	js     80105b1e <sys_pipe+0x7f>
80105b06:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b09:	83 ec 0c             	sub    $0xc,%esp
80105b0c:	50                   	push   %eax
80105b0d:	e8 63 f3 ff ff       	call   80104e75 <fdalloc>
80105b12:	83 c4 10             	add    $0x10,%esp
80105b15:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105b18:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105b1c:	79 3e                	jns    80105b5c <sys_pipe+0xbd>
    if(fd0 >= 0)
80105b1e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b22:	78 13                	js     80105b37 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105b24:	e8 07 df ff ff       	call   80103a30 <myproc>
80105b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b2c:	83 c2 08             	add    $0x8,%edx
80105b2f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105b36:	00 
    fileclose(rf);
80105b37:	8b 45 e8             	mov    -0x18(%ebp),%eax
80105b3a:	83 ec 0c             	sub    $0xc,%esp
80105b3d:	50                   	push   %eax
80105b3e:	e8 62 b5 ff ff       	call   801010a5 <fileclose>
80105b43:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80105b46:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105b49:	83 ec 0c             	sub    $0xc,%esp
80105b4c:	50                   	push   %eax
80105b4d:	e8 53 b5 ff ff       	call   801010a5 <fileclose>
80105b52:	83 c4 10             	add    $0x10,%esp
    return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	eb 18                	jmp    80105b74 <sys_pipe+0xd5>
  }
  fd[0] = fd0;
80105b5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105b62:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80105b64:	8b 45 ec             	mov    -0x14(%ebp),%eax
80105b67:	8d 50 04             	lea    0x4(%eax),%edx
80105b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105b6d:	89 02                	mov    %eax,(%edx)
  return 0;
80105b6f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b74:	c9                   	leave
80105b75:	c3                   	ret

80105b76 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80105b76:	55                   	push   %ebp
80105b77:	89 e5                	mov    %esp,%ebp
80105b79:	83 ec 08             	sub    $0x8,%esp
  return fork();
80105b7c:	e8 b8 e1 ff ff       	call   80103d39 <fork>
}
80105b81:	c9                   	leave
80105b82:	c3                   	ret

80105b83 <sys_exit>:

int
sys_exit(void)
{
80105b83:	55                   	push   %ebp
80105b84:	89 e5                	mov    %esp,%ebp
80105b86:	83 ec 08             	sub    $0x8,%esp
  exit();
80105b89:	e8 24 e3 ff ff       	call   80103eb2 <exit>
  return 0;  // not reached
80105b8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105b93:	c9                   	leave
80105b94:	c3                   	ret

80105b95 <sys_wait>:

int
sys_wait(void)
{
80105b95:	55                   	push   %ebp
80105b96:	89 e5                	mov    %esp,%ebp
80105b98:	83 ec 08             	sub    $0x8,%esp
  return wait();
80105b9b:	e8 32 e4 ff ff       	call   80103fd2 <wait>
}
80105ba0:	c9                   	leave
80105ba1:	c3                   	ret

80105ba2 <sys_kill>:

int
sys_kill(void)
{
80105ba2:	55                   	push   %ebp
80105ba3:	89 e5                	mov    %esp,%ebp
80105ba5:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105ba8:	83 ec 08             	sub    $0x8,%esp
80105bab:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105bae:	50                   	push   %eax
80105baf:	6a 00                	push   $0x0
80105bb1:	e8 01 f1 ff ff       	call   80104cb7 <argint>
80105bb6:	83 c4 10             	add    $0x10,%esp
80105bb9:	85 c0                	test   %eax,%eax
80105bbb:	79 07                	jns    80105bc4 <sys_kill+0x22>
    return -1;
80105bbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bc2:	eb 0f                	jmp    80105bd3 <sys_kill+0x31>
  return kill(pid);
80105bc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bc7:	83 ec 0c             	sub    $0xc,%esp
80105bca:	50                   	push   %eax
80105bcb:	e8 31 e8 ff ff       	call   80104401 <kill>
80105bd0:	83 c4 10             	add    $0x10,%esp
}
80105bd3:	c9                   	leave
80105bd4:	c3                   	ret

80105bd5 <sys_getpid>:

int
sys_getpid(void)
{
80105bd5:	55                   	push   %ebp
80105bd6:	89 e5                	mov    %esp,%ebp
80105bd8:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105bdb:	e8 50 de ff ff       	call   80103a30 <myproc>
80105be0:	8b 40 10             	mov    0x10(%eax),%eax
}
80105be3:	c9                   	leave
80105be4:	c3                   	ret

80105be5 <sys_sbrk>:

int
sys_sbrk(void)
{
80105be5:	55                   	push   %ebp
80105be6:	89 e5                	mov    %esp,%ebp
80105be8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105beb:	83 ec 08             	sub    $0x8,%esp
80105bee:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105bf1:	50                   	push   %eax
80105bf2:	6a 00                	push   $0x0
80105bf4:	e8 be f0 ff ff       	call   80104cb7 <argint>
80105bf9:	83 c4 10             	add    $0x10,%esp
80105bfc:	85 c0                	test   %eax,%eax
80105bfe:	79 07                	jns    80105c07 <sys_sbrk+0x22>
    return -1;
80105c00:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c05:	eb 27                	jmp    80105c2e <sys_sbrk+0x49>
  addr = myproc()->sz;
80105c07:	e8 24 de ff ff       	call   80103a30 <myproc>
80105c0c:	8b 00                	mov    (%eax),%eax
80105c0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80105c11:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105c14:	83 ec 0c             	sub    $0xc,%esp
80105c17:	50                   	push   %eax
80105c18:	e8 81 e0 ff ff       	call   80103c9e <growproc>
80105c1d:	83 c4 10             	add    $0x10,%esp
80105c20:	85 c0                	test   %eax,%eax
80105c22:	79 07                	jns    80105c2b <sys_sbrk+0x46>
    return -1;
80105c24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c29:	eb 03                	jmp    80105c2e <sys_sbrk+0x49>
  return addr;
80105c2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105c2e:	c9                   	leave
80105c2f:	c3                   	ret

80105c30 <sys_sleep>:

int
sys_sleep(void)
{
80105c30:	55                   	push   %ebp
80105c31:	89 e5                	mov    %esp,%ebp
80105c33:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105c36:	83 ec 08             	sub    $0x8,%esp
80105c39:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105c3c:	50                   	push   %eax
80105c3d:	6a 00                	push   $0x0
80105c3f:	e8 73 f0 ff ff       	call   80104cb7 <argint>
80105c44:	83 c4 10             	add    $0x10,%esp
80105c47:	85 c0                	test   %eax,%eax
80105c49:	79 07                	jns    80105c52 <sys_sleep+0x22>
    return -1;
80105c4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c50:	eb 76                	jmp    80105cc8 <sys_sleep+0x98>
  acquire(&tickslock);
80105c52:	83 ec 0c             	sub    $0xc,%esp
80105c55:	68 40 6a 19 80       	push   $0x80196a40
80105c5a:	e8 b7 ea ff ff       	call   80104716 <acquire>
80105c5f:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80105c62:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80105c6a:	eb 38                	jmp    80105ca4 <sys_sleep+0x74>
    if(myproc()->killed){
80105c6c:	e8 bf dd ff ff       	call   80103a30 <myproc>
80105c71:	8b 40 24             	mov    0x24(%eax),%eax
80105c74:	85 c0                	test   %eax,%eax
80105c76:	74 17                	je     80105c8f <sys_sleep+0x5f>
      release(&tickslock);
80105c78:	83 ec 0c             	sub    $0xc,%esp
80105c7b:	68 40 6a 19 80       	push   $0x80196a40
80105c80:	e8 ff ea ff ff       	call   80104784 <release>
80105c85:	83 c4 10             	add    $0x10,%esp
      return -1;
80105c88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c8d:	eb 39                	jmp    80105cc8 <sys_sleep+0x98>
    }
    sleep(&ticks, &tickslock);
80105c8f:	83 ec 08             	sub    $0x8,%esp
80105c92:	68 40 6a 19 80       	push   $0x80196a40
80105c97:	68 74 6a 19 80       	push   $0x80196a74
80105c9c:	e8 42 e6 ff ff       	call   801042e3 <sleep>
80105ca1:	83 c4 10             	add    $0x10,%esp
  while(ticks - ticks0 < n){
80105ca4:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105ca9:	2b 45 f4             	sub    -0xc(%ebp),%eax
80105cac:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105caf:	39 d0                	cmp    %edx,%eax
80105cb1:	72 b9                	jb     80105c6c <sys_sleep+0x3c>
  }
  release(&tickslock);
80105cb3:	83 ec 0c             	sub    $0xc,%esp
80105cb6:	68 40 6a 19 80       	push   $0x80196a40
80105cbb:	e8 c4 ea ff ff       	call   80104784 <release>
80105cc0:	83 c4 10             	add    $0x10,%esp
  return 0;
80105cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cc8:	c9                   	leave
80105cc9:	c3                   	ret

80105cca <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105cca:	55                   	push   %ebp
80105ccb:	89 e5                	mov    %esp,%ebp
80105ccd:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80105cd0:	83 ec 0c             	sub    $0xc,%esp
80105cd3:	68 40 6a 19 80       	push   $0x80196a40
80105cd8:	e8 39 ea ff ff       	call   80104716 <acquire>
80105cdd:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80105ce0:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105ce5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80105ce8:	83 ec 0c             	sub    $0xc,%esp
80105ceb:	68 40 6a 19 80       	push   $0x80196a40
80105cf0:	e8 8f ea ff ff       	call   80104784 <release>
80105cf5:	83 c4 10             	add    $0x10,%esp
  return xticks;
80105cf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105cfb:	c9                   	leave
80105cfc:	c3                   	ret

80105cfd <sys_uthread_init>:

//LAB2 추가
int
sys_uthread_init(void){
80105cfd:	55                   	push   %ebp
80105cfe:	89 e5                	mov    %esp,%ebp
80105d00:	83 ec 18             	sub    $0x18,%esp
  int funcaddr;
  //struct proc *p;

  if(argint(0, &funcaddr) < 0) 
80105d03:	83 ec 08             	sub    $0x8,%esp
80105d06:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d09:	50                   	push   %eax
80105d0a:	6a 00                	push   $0x0
80105d0c:	e8 a6 ef ff ff       	call   80104cb7 <argint>
80105d11:	83 c4 10             	add    $0x10,%esp
80105d14:	85 c0                	test   %eax,%eax
80105d16:	79 07                	jns    80105d1f <sys_uthread_init+0x22>
    return -1; 
80105d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d1d:	eb 0f                	jmp    80105d2e <sys_uthread_init+0x31>
  
  return uthread_init(funcaddr);
80105d1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105d22:	83 ec 0c             	sub    $0xc,%esp
80105d25:	50                   	push   %eax
80105d26:	e8 54 e8 ff ff       	call   8010457f <uthread_init>
80105d2b:	83 c4 10             	add    $0x10,%esp
  
80105d2e:	c9                   	leave
80105d2f:	c3                   	ret

80105d30 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105d30:	1e                   	push   %ds
  pushl %es
80105d31:	06                   	push   %es
  pushl %fs
80105d32:	0f a0                	push   %fs
  pushl %gs
80105d34:	0f a8                	push   %gs
  pushal
80105d36:	60                   	pusha
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105d37:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105d3b:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105d3d:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105d3f:	54                   	push   %esp
  call trap
80105d40:	e8 d7 01 00 00       	call   80105f1c <trap>
  addl $4, %esp
80105d45:	83 c4 04             	add    $0x4,%esp

80105d48 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105d48:	61                   	popa
  popl %gs
80105d49:	0f a9                	pop    %gs
  popl %fs
80105d4b:	0f a1                	pop    %fs
  popl %es
80105d4d:	07                   	pop    %es
  popl %ds
80105d4e:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105d4f:	83 c4 08             	add    $0x8,%esp
  iret
80105d52:	cf                   	iret

80105d53 <lidt>:
{
80105d53:	55                   	push   %ebp
80105d54:	89 e5                	mov    %esp,%ebp
80105d56:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80105d59:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d5c:	83 e8 01             	sub    $0x1,%eax
80105d5f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105d63:	8b 45 08             	mov    0x8(%ebp),%eax
80105d66:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105d6a:	8b 45 08             	mov    0x8(%ebp),%eax
80105d6d:	c1 e8 10             	shr    $0x10,%eax
80105d70:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105d74:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105d77:	0f 01 18             	lidtl  (%eax)
}
80105d7a:	90                   	nop
80105d7b:	c9                   	leave
80105d7c:	c3                   	ret

80105d7d <rcr2>:

static inline uint
rcr2(void)
{
80105d7d:	55                   	push   %ebp
80105d7e:	89 e5                	mov    %esp,%ebp
80105d80:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105d83:	0f 20 d0             	mov    %cr2,%eax
80105d86:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80105d89:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105d8c:	c9                   	leave
80105d8d:	c3                   	ret

80105d8e <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105d8e:	55                   	push   %ebp
80105d8f:	89 e5                	mov    %esp,%ebp
80105d91:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80105d94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105d9b:	e9 c3 00 00 00       	jmp    80105e63 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105da0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105da3:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105daa:	89 c2                	mov    %eax,%edx
80105dac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105daf:	66 89 14 c5 40 62 19 	mov    %dx,-0x7fe69dc0(,%eax,8)
80105db6:	80 
80105db7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dba:	66 c7 04 c5 42 62 19 	movw   $0x8,-0x7fe69dbe(,%eax,8)
80105dc1:	80 08 00 
80105dc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dc7:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105dce:	80 
80105dcf:	83 e2 e0             	and    $0xffffffe0,%edx
80105dd2:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ddc:	0f b6 14 c5 44 62 19 	movzbl -0x7fe69dbc(,%eax,8),%edx
80105de3:	80 
80105de4:	83 e2 1f             	and    $0x1f,%edx
80105de7:	88 14 c5 44 62 19 80 	mov    %dl,-0x7fe69dbc(,%eax,8)
80105dee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df1:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105df8:	80 
80105df9:	83 e2 f0             	and    $0xfffffff0,%edx
80105dfc:	83 ca 0e             	or     $0xe,%edx
80105dff:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e09:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e10:	80 
80105e11:	83 e2 ef             	and    $0xffffffef,%edx
80105e14:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e1e:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e25:	80 
80105e26:	83 e2 9f             	and    $0xffffff9f,%edx
80105e29:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e30:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e33:	0f b6 14 c5 45 62 19 	movzbl -0x7fe69dbb(,%eax,8),%edx
80105e3a:	80 
80105e3b:	83 ca 80             	or     $0xffffff80,%edx
80105e3e:	88 14 c5 45 62 19 80 	mov    %dl,-0x7fe69dbb(,%eax,8)
80105e45:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e48:	8b 04 85 7c f0 10 80 	mov    -0x7fef0f84(,%eax,4),%eax
80105e4f:	c1 e8 10             	shr    $0x10,%eax
80105e52:	89 c2                	mov    %eax,%edx
80105e54:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e57:	66 89 14 c5 46 62 19 	mov    %dx,-0x7fe69dba(,%eax,8)
80105e5e:	80 
  for(i = 0; i < 256; i++)
80105e5f:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105e63:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80105e6a:	0f 8e 30 ff ff ff    	jle    80105da0 <tvinit+0x12>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105e70:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105e75:	66 a3 40 64 19 80    	mov    %ax,0x80196440
80105e7b:	66 c7 05 42 64 19 80 	movw   $0x8,0x80196442
80105e82:	08 00 
80105e84:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105e8b:	83 e0 e0             	and    $0xffffffe0,%eax
80105e8e:	a2 44 64 19 80       	mov    %al,0x80196444
80105e93:	0f b6 05 44 64 19 80 	movzbl 0x80196444,%eax
80105e9a:	83 e0 1f             	and    $0x1f,%eax
80105e9d:	a2 44 64 19 80       	mov    %al,0x80196444
80105ea2:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ea9:	83 c8 0f             	or     $0xf,%eax
80105eac:	a2 45 64 19 80       	mov    %al,0x80196445
80105eb1:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105eb8:	83 e0 ef             	and    $0xffffffef,%eax
80105ebb:	a2 45 64 19 80       	mov    %al,0x80196445
80105ec0:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ec7:	83 c8 60             	or     $0x60,%eax
80105eca:	a2 45 64 19 80       	mov    %al,0x80196445
80105ecf:	0f b6 05 45 64 19 80 	movzbl 0x80196445,%eax
80105ed6:	83 c8 80             	or     $0xffffff80,%eax
80105ed9:	a2 45 64 19 80       	mov    %al,0x80196445
80105ede:	a1 7c f1 10 80       	mov    0x8010f17c,%eax
80105ee3:	c1 e8 10             	shr    $0x10,%eax
80105ee6:	66 a3 46 64 19 80    	mov    %ax,0x80196446

  initlock(&tickslock, "time");
80105eec:	83 ec 08             	sub    $0x8,%esp
80105eef:	68 58 a4 10 80       	push   $0x8010a458
80105ef4:	68 40 6a 19 80       	push   $0x80196a40
80105ef9:	e8 f6 e7 ff ff       	call   801046f4 <initlock>
80105efe:	83 c4 10             	add    $0x10,%esp
}
80105f01:	90                   	nop
80105f02:	c9                   	leave
80105f03:	c3                   	ret

80105f04 <idtinit>:

void
idtinit(void)
{
80105f04:	55                   	push   %ebp
80105f05:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
80105f07:	68 00 08 00 00       	push   $0x800
80105f0c:	68 40 62 19 80       	push   $0x80196240
80105f11:	e8 3d fe ff ff       	call   80105d53 <lidt>
80105f16:	83 c4 08             	add    $0x8,%esp
}
80105f19:	90                   	nop
80105f1a:	c9                   	leave
80105f1b:	c3                   	ret

80105f1c <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f1c:	55                   	push   %ebp
80105f1d:	89 e5                	mov    %esp,%ebp
80105f1f:	57                   	push   %edi
80105f20:	56                   	push   %esi
80105f21:	53                   	push   %ebx
80105f22:	83 ec 2c             	sub    $0x2c,%esp
  if(tf->trapno == T_SYSCALL){
80105f25:	8b 45 08             	mov    0x8(%ebp),%eax
80105f28:	8b 40 30             	mov    0x30(%eax),%eax
80105f2b:	83 f8 40             	cmp    $0x40,%eax
80105f2e:	75 3b                	jne    80105f6b <trap+0x4f>
    if(myproc()->killed)
80105f30:	e8 fb da ff ff       	call   80103a30 <myproc>
80105f35:	8b 40 24             	mov    0x24(%eax),%eax
80105f38:	85 c0                	test   %eax,%eax
80105f3a:	74 05                	je     80105f41 <trap+0x25>
      exit();
80105f3c:	e8 71 df ff ff       	call   80103eb2 <exit>
    myproc()->tf = tf;
80105f41:	e8 ea da ff ff       	call   80103a30 <myproc>
80105f46:	8b 55 08             	mov    0x8(%ebp),%edx
80105f49:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80105f4c:	e8 32 ee ff ff       	call   80104d83 <syscall>
    if(myproc()->killed)
80105f51:	e8 da da ff ff       	call   80103a30 <myproc>
80105f56:	8b 40 24             	mov    0x24(%eax),%eax
80105f59:	85 c0                	test   %eax,%eax
80105f5b:	0f 84 6b 02 00 00    	je     801061cc <trap+0x2b0>
      exit();
80105f61:	e8 4c df ff ff       	call   80103eb2 <exit>
    return;
80105f66:	e9 61 02 00 00       	jmp    801061cc <trap+0x2b0>
  }

  switch(tf->trapno){
80105f6b:	8b 45 08             	mov    0x8(%ebp),%eax
80105f6e:	8b 40 30             	mov    0x30(%eax),%eax
80105f71:	83 e8 20             	sub    $0x20,%eax
80105f74:	83 f8 1f             	cmp    $0x1f,%eax
80105f77:	0f 87 17 01 00 00    	ja     80106094 <trap+0x178>
80105f7d:	8b 04 85 00 a5 10 80 	mov    -0x7fef5b00(,%eax,4),%eax
80105f84:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105f86:	e8 12 da ff ff       	call   8010399d <cpuid>
80105f8b:	85 c0                	test   %eax,%eax
80105f8d:	75 3d                	jne    80105fcc <trap+0xb0>
      acquire(&tickslock);
80105f8f:	83 ec 0c             	sub    $0xc,%esp
80105f92:	68 40 6a 19 80       	push   $0x80196a40
80105f97:	e8 7a e7 ff ff       	call   80104716 <acquire>
80105f9c:	83 c4 10             	add    $0x10,%esp
      ticks++;
80105f9f:	a1 74 6a 19 80       	mov    0x80196a74,%eax
80105fa4:	83 c0 01             	add    $0x1,%eax
80105fa7:	a3 74 6a 19 80       	mov    %eax,0x80196a74
      wakeup(&ticks);
80105fac:	83 ec 0c             	sub    $0xc,%esp
80105faf:	68 74 6a 19 80       	push   $0x80196a74
80105fb4:	e8 11 e4 ff ff       	call   801043ca <wakeup>
80105fb9:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80105fbc:	83 ec 0c             	sub    $0xc,%esp
80105fbf:	68 40 6a 19 80       	push   $0x80196a40
80105fc4:	e8 bb e7 ff ff       	call   80104784 <release>
80105fc9:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80105fcc:	e8 4d cb ff ff       	call   80102b1e <lapiceoi>

    //LAB2 추가
    struct proc *p = myproc();
80105fd1:	e8 5a da ff ff       	call   80103a30 <myproc>
80105fd6:	89 45 e4             	mov    %eax,-0x1c(%ebp)

    if (p && p->scheduler != -1 && ticks % 30 == 0){
80105fd9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80105fdd:	0f 84 68 01 00 00    	je     8010614b <trap+0x22f>
80105fe3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105fe6:	8b 40 7c             	mov    0x7c(%eax),%eax
80105fe9:	83 f8 ff             	cmp    $0xffffffff,%eax
80105fec:	0f 84 59 01 00 00    	je     8010614b <trap+0x22f>
80105ff2:	8b 0d 74 6a 19 80    	mov    0x80196a74,%ecx
80105ff8:	ba 89 88 88 88       	mov    $0x88888889,%edx
80105ffd:	89 c8                	mov    %ecx,%eax
80105fff:	f7 e2                	mul    %edx
80106001:	89 d0                	mov    %edx,%eax
80106003:	c1 e8 04             	shr    $0x4,%eax
80106006:	6b d0 1e             	imul   $0x1e,%eax,%edx
80106009:	89 c8                	mov    %ecx,%eax
8010600b:	29 d0                	sub    %edx,%eax
8010600d:	85 c0                	test   %eax,%eax
8010600f:	0f 85 36 01 00 00    	jne    8010614b <trap+0x22f>
      p->tf->eip = p->scheduler;
80106015:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106018:	8b 40 18             	mov    0x18(%eax),%eax
8010601b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010601e:	8b 52 7c             	mov    0x7c(%edx),%edx
80106021:	89 50 38             	mov    %edx,0x38(%eax)
    }
    
    break;
80106024:	e9 22 01 00 00       	jmp    8010614b <trap+0x22f>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106029:	e8 de 3e 00 00       	call   80109f0c <ideintr>
    lapiceoi();
8010602e:	e8 eb ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106033:	e9 14 01 00 00       	jmp    8010614c <trap+0x230>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106038:	e8 2c c9 ff ff       	call   80102969 <kbdintr>
    lapiceoi();
8010603d:	e8 dc ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106042:	e9 05 01 00 00       	jmp    8010614c <trap+0x230>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106047:	e8 54 03 00 00       	call   801063a0 <uartintr>
    lapiceoi();
8010604c:	e8 cd ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106051:	e9 f6 00 00 00       	jmp    8010614c <trap+0x230>
  case T_IRQ0 + 0xB:
    i8254_intr();
80106056:	e8 7a 2b 00 00       	call   80108bd5 <i8254_intr>
    lapiceoi();
8010605b:	e8 be ca ff ff       	call   80102b1e <lapiceoi>
    break;
80106060:	e9 e7 00 00 00       	jmp    8010614c <trap+0x230>
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106065:	8b 45 08             	mov    0x8(%ebp),%eax
80106068:	8b 70 38             	mov    0x38(%eax),%esi
            cpuid(), tf->cs, tf->eip);
8010606b:	8b 45 08             	mov    0x8(%ebp),%eax
8010606e:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106072:	0f b7 d8             	movzwl %ax,%ebx
80106075:	e8 23 d9 ff ff       	call   8010399d <cpuid>
8010607a:	56                   	push   %esi
8010607b:	53                   	push   %ebx
8010607c:	50                   	push   %eax
8010607d:	68 60 a4 10 80       	push   $0x8010a460
80106082:	e8 6d a3 ff ff       	call   801003f4 <cprintf>
80106087:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
8010608a:	e8 8f ca ff ff       	call   80102b1e <lapiceoi>
    break;
8010608f:	e9 b8 00 00 00       	jmp    8010614c <trap+0x230>

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80106094:	e8 97 d9 ff ff       	call   80103a30 <myproc>
80106099:	85 c0                	test   %eax,%eax
8010609b:	74 11                	je     801060ae <trap+0x192>
8010609d:	8b 45 08             	mov    0x8(%ebp),%eax
801060a0:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801060a4:	0f b7 c0             	movzwl %ax,%eax
801060a7:	83 e0 03             	and    $0x3,%eax
801060aa:	85 c0                	test   %eax,%eax
801060ac:	75 39                	jne    801060e7 <trap+0x1cb>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801060ae:	e8 ca fc ff ff       	call   80105d7d <rcr2>
801060b3:	89 c3                	mov    %eax,%ebx
801060b5:	8b 45 08             	mov    0x8(%ebp),%eax
801060b8:	8b 70 38             	mov    0x38(%eax),%esi
801060bb:	e8 dd d8 ff ff       	call   8010399d <cpuid>
801060c0:	8b 55 08             	mov    0x8(%ebp),%edx
801060c3:	8b 52 30             	mov    0x30(%edx),%edx
801060c6:	83 ec 0c             	sub    $0xc,%esp
801060c9:	53                   	push   %ebx
801060ca:	56                   	push   %esi
801060cb:	50                   	push   %eax
801060cc:	52                   	push   %edx
801060cd:	68 84 a4 10 80       	push   $0x8010a484
801060d2:	e8 1d a3 ff ff       	call   801003f4 <cprintf>
801060d7:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
801060da:	83 ec 0c             	sub    $0xc,%esp
801060dd:	68 b6 a4 10 80       	push   $0x8010a4b6
801060e2:	e8 c2 a4 ff ff       	call   801005a9 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801060e7:	e8 91 fc ff ff       	call   80105d7d <rcr2>
801060ec:	89 c6                	mov    %eax,%esi
801060ee:	8b 45 08             	mov    0x8(%ebp),%eax
801060f1:	8b 40 38             	mov    0x38(%eax),%eax
801060f4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
801060f7:	e8 a1 d8 ff ff       	call   8010399d <cpuid>
801060fc:	89 c3                	mov    %eax,%ebx
801060fe:	8b 45 08             	mov    0x8(%ebp),%eax
80106101:	8b 78 34             	mov    0x34(%eax),%edi
80106104:	89 7d d0             	mov    %edi,-0x30(%ebp)
80106107:	8b 45 08             	mov    0x8(%ebp),%eax
8010610a:	8b 78 30             	mov    0x30(%eax),%edi
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
8010610d:	e8 1e d9 ff ff       	call   80103a30 <myproc>
80106112:	8d 48 6c             	lea    0x6c(%eax),%ecx
80106115:	89 4d cc             	mov    %ecx,-0x34(%ebp)
80106118:	e8 13 d9 ff ff       	call   80103a30 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010611d:	8b 40 10             	mov    0x10(%eax),%eax
80106120:	56                   	push   %esi
80106121:	ff 75 d4             	push   -0x2c(%ebp)
80106124:	53                   	push   %ebx
80106125:	ff 75 d0             	push   -0x30(%ebp)
80106128:	57                   	push   %edi
80106129:	ff 75 cc             	push   -0x34(%ebp)
8010612c:	50                   	push   %eax
8010612d:	68 bc a4 10 80       	push   $0x8010a4bc
80106132:	e8 bd a2 ff ff       	call   801003f4 <cprintf>
80106137:	83 c4 20             	add    $0x20,%esp
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
8010613a:	e8 f1 d8 ff ff       	call   80103a30 <myproc>
8010613f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106146:	eb 04                	jmp    8010614c <trap+0x230>
    break;
80106148:	90                   	nop
80106149:	eb 01                	jmp    8010614c <trap+0x230>
    break;
8010614b:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010614c:	e8 df d8 ff ff       	call   80103a30 <myproc>
80106151:	85 c0                	test   %eax,%eax
80106153:	74 23                	je     80106178 <trap+0x25c>
80106155:	e8 d6 d8 ff ff       	call   80103a30 <myproc>
8010615a:	8b 40 24             	mov    0x24(%eax),%eax
8010615d:	85 c0                	test   %eax,%eax
8010615f:	74 17                	je     80106178 <trap+0x25c>
80106161:	8b 45 08             	mov    0x8(%ebp),%eax
80106164:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106168:	0f b7 c0             	movzwl %ax,%eax
8010616b:	83 e0 03             	and    $0x3,%eax
8010616e:	83 f8 03             	cmp    $0x3,%eax
80106171:	75 05                	jne    80106178 <trap+0x25c>
    exit();
80106173:	e8 3a dd ff ff       	call   80103eb2 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106178:	e8 b3 d8 ff ff       	call   80103a30 <myproc>
8010617d:	85 c0                	test   %eax,%eax
8010617f:	74 1d                	je     8010619e <trap+0x282>
80106181:	e8 aa d8 ff ff       	call   80103a30 <myproc>
80106186:	8b 40 0c             	mov    0xc(%eax),%eax
80106189:	83 f8 04             	cmp    $0x4,%eax
8010618c:	75 10                	jne    8010619e <trap+0x282>
     tf->trapno == T_IRQ0+IRQ_TIMER)
8010618e:	8b 45 08             	mov    0x8(%ebp),%eax
80106191:	8b 40 30             	mov    0x30(%eax),%eax
  if(myproc() && myproc()->state == RUNNING &&
80106194:	83 f8 20             	cmp    $0x20,%eax
80106197:	75 05                	jne    8010619e <trap+0x282>
    yield();
80106199:	e8 c5 e0 ff ff       	call   80104263 <yield>

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010619e:	e8 8d d8 ff ff       	call   80103a30 <myproc>
801061a3:	85 c0                	test   %eax,%eax
801061a5:	74 26                	je     801061cd <trap+0x2b1>
801061a7:	e8 84 d8 ff ff       	call   80103a30 <myproc>
801061ac:	8b 40 24             	mov    0x24(%eax),%eax
801061af:	85 c0                	test   %eax,%eax
801061b1:	74 1a                	je     801061cd <trap+0x2b1>
801061b3:	8b 45 08             	mov    0x8(%ebp),%eax
801061b6:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801061ba:	0f b7 c0             	movzwl %ax,%eax
801061bd:	83 e0 03             	and    $0x3,%eax
801061c0:	83 f8 03             	cmp    $0x3,%eax
801061c3:	75 08                	jne    801061cd <trap+0x2b1>
    exit();
801061c5:	e8 e8 dc ff ff       	call   80103eb2 <exit>
801061ca:	eb 01                	jmp    801061cd <trap+0x2b1>
    return;
801061cc:	90                   	nop
}
801061cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061d0:	5b                   	pop    %ebx
801061d1:	5e                   	pop    %esi
801061d2:	5f                   	pop    %edi
801061d3:	5d                   	pop    %ebp
801061d4:	c3                   	ret

801061d5 <inb>:
{
801061d5:	55                   	push   %ebp
801061d6:	89 e5                	mov    %esp,%ebp
801061d8:	83 ec 14             	sub    $0x14,%esp
801061db:	8b 45 08             	mov    0x8(%ebp),%eax
801061de:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801061e2:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801061e6:	89 c2                	mov    %eax,%edx
801061e8:	ec                   	in     (%dx),%al
801061e9:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801061ec:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801061f0:	c9                   	leave
801061f1:	c3                   	ret

801061f2 <outb>:
{
801061f2:	55                   	push   %ebp
801061f3:	89 e5                	mov    %esp,%ebp
801061f5:	83 ec 08             	sub    $0x8,%esp
801061f8:	8b 55 08             	mov    0x8(%ebp),%edx
801061fb:	8b 45 0c             	mov    0xc(%ebp),%eax
801061fe:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106202:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106205:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106209:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010620d:	ee                   	out    %al,(%dx)
}
8010620e:	90                   	nop
8010620f:	c9                   	leave
80106210:	c3                   	ret

80106211 <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106211:	55                   	push   %ebp
80106212:	89 e5                	mov    %esp,%ebp
80106214:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106217:	6a 00                	push   $0x0
80106219:	68 fa 03 00 00       	push   $0x3fa
8010621e:	e8 cf ff ff ff       	call   801061f2 <outb>
80106223:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106226:	68 80 00 00 00       	push   $0x80
8010622b:	68 fb 03 00 00       	push   $0x3fb
80106230:	e8 bd ff ff ff       	call   801061f2 <outb>
80106235:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106238:	6a 0c                	push   $0xc
8010623a:	68 f8 03 00 00       	push   $0x3f8
8010623f:	e8 ae ff ff ff       	call   801061f2 <outb>
80106244:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106247:	6a 00                	push   $0x0
80106249:	68 f9 03 00 00       	push   $0x3f9
8010624e:	e8 9f ff ff ff       	call   801061f2 <outb>
80106253:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106256:	6a 03                	push   $0x3
80106258:	68 fb 03 00 00       	push   $0x3fb
8010625d:	e8 90 ff ff ff       	call   801061f2 <outb>
80106262:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106265:	6a 00                	push   $0x0
80106267:	68 fc 03 00 00       	push   $0x3fc
8010626c:	e8 81 ff ff ff       	call   801061f2 <outb>
80106271:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106274:	6a 01                	push   $0x1
80106276:	68 f9 03 00 00       	push   $0x3f9
8010627b:	e8 72 ff ff ff       	call   801061f2 <outb>
80106280:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106283:	68 fd 03 00 00       	push   $0x3fd
80106288:	e8 48 ff ff ff       	call   801061d5 <inb>
8010628d:	83 c4 04             	add    $0x4,%esp
80106290:	3c ff                	cmp    $0xff,%al
80106292:	74 61                	je     801062f5 <uartinit+0xe4>
    return;
  uart = 1;
80106294:	c7 05 78 6a 19 80 01 	movl   $0x1,0x80196a78
8010629b:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010629e:	68 fa 03 00 00       	push   $0x3fa
801062a3:	e8 2d ff ff ff       	call   801061d5 <inb>
801062a8:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
801062ab:	68 f8 03 00 00       	push   $0x3f8
801062b0:	e8 20 ff ff ff       	call   801061d5 <inb>
801062b5:	83 c4 04             	add    $0x4,%esp
  ioapicenable(IRQ_COM1, 0);
801062b8:	83 ec 08             	sub    $0x8,%esp
801062bb:	6a 00                	push   $0x0
801062bd:	6a 04                	push   $0x4
801062bf:	e8 72 c3 ff ff       	call   80102636 <ioapicenable>
801062c4:	83 c4 10             	add    $0x10,%esp

  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801062c7:	c7 45 f4 80 a5 10 80 	movl   $0x8010a580,-0xc(%ebp)
801062ce:	eb 19                	jmp    801062e9 <uartinit+0xd8>
    uartputc(*p);
801062d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d3:	0f b6 00             	movzbl (%eax),%eax
801062d6:	0f be c0             	movsbl %al,%eax
801062d9:	83 ec 0c             	sub    $0xc,%esp
801062dc:	50                   	push   %eax
801062dd:	e8 16 00 00 00       	call   801062f8 <uartputc>
801062e2:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801062e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801062e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062ec:	0f b6 00             	movzbl (%eax),%eax
801062ef:	84 c0                	test   %al,%al
801062f1:	75 dd                	jne    801062d0 <uartinit+0xbf>
801062f3:	eb 01                	jmp    801062f6 <uartinit+0xe5>
    return;
801062f5:	90                   	nop
}
801062f6:	c9                   	leave
801062f7:	c3                   	ret

801062f8 <uartputc>:

void
uartputc(int c)
{
801062f8:	55                   	push   %ebp
801062f9:	89 e5                	mov    %esp,%ebp
801062fb:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801062fe:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106303:	85 c0                	test   %eax,%eax
80106305:	74 53                	je     8010635a <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106307:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010630e:	eb 11                	jmp    80106321 <uartputc+0x29>
    microdelay(10);
80106310:	83 ec 0c             	sub    $0xc,%esp
80106313:	6a 0a                	push   $0xa
80106315:	e8 1f c8 ff ff       	call   80102b39 <microdelay>
8010631a:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010631d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106321:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106325:	7f 1a                	jg     80106341 <uartputc+0x49>
80106327:	83 ec 0c             	sub    $0xc,%esp
8010632a:	68 fd 03 00 00       	push   $0x3fd
8010632f:	e8 a1 fe ff ff       	call   801061d5 <inb>
80106334:	83 c4 10             	add    $0x10,%esp
80106337:	0f b6 c0             	movzbl %al,%eax
8010633a:	83 e0 20             	and    $0x20,%eax
8010633d:	85 c0                	test   %eax,%eax
8010633f:	74 cf                	je     80106310 <uartputc+0x18>
  outb(COM1+0, c);
80106341:	8b 45 08             	mov    0x8(%ebp),%eax
80106344:	0f b6 c0             	movzbl %al,%eax
80106347:	83 ec 08             	sub    $0x8,%esp
8010634a:	50                   	push   %eax
8010634b:	68 f8 03 00 00       	push   $0x3f8
80106350:	e8 9d fe ff ff       	call   801061f2 <outb>
80106355:	83 c4 10             	add    $0x10,%esp
80106358:	eb 01                	jmp    8010635b <uartputc+0x63>
    return;
8010635a:	90                   	nop
}
8010635b:	c9                   	leave
8010635c:	c3                   	ret

8010635d <uartgetc>:

static int
uartgetc(void)
{
8010635d:	55                   	push   %ebp
8010635e:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106360:	a1 78 6a 19 80       	mov    0x80196a78,%eax
80106365:	85 c0                	test   %eax,%eax
80106367:	75 07                	jne    80106370 <uartgetc+0x13>
    return -1;
80106369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010636e:	eb 2e                	jmp    8010639e <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106370:	68 fd 03 00 00       	push   $0x3fd
80106375:	e8 5b fe ff ff       	call   801061d5 <inb>
8010637a:	83 c4 04             	add    $0x4,%esp
8010637d:	0f b6 c0             	movzbl %al,%eax
80106380:	83 e0 01             	and    $0x1,%eax
80106383:	85 c0                	test   %eax,%eax
80106385:	75 07                	jne    8010638e <uartgetc+0x31>
    return -1;
80106387:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638c:	eb 10                	jmp    8010639e <uartgetc+0x41>
  return inb(COM1+0);
8010638e:	68 f8 03 00 00       	push   $0x3f8
80106393:	e8 3d fe ff ff       	call   801061d5 <inb>
80106398:	83 c4 04             	add    $0x4,%esp
8010639b:	0f b6 c0             	movzbl %al,%eax
}
8010639e:	c9                   	leave
8010639f:	c3                   	ret

801063a0 <uartintr>:

void
uartintr(void)
{
801063a0:	55                   	push   %ebp
801063a1:	89 e5                	mov    %esp,%ebp
801063a3:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
801063a6:	83 ec 0c             	sub    $0xc,%esp
801063a9:	68 5d 63 10 80       	push   $0x8010635d
801063ae:	e8 23 a4 ff ff       	call   801007d6 <consoleintr>
801063b3:	83 c4 10             	add    $0x10,%esp
}
801063b6:	90                   	nop
801063b7:	c9                   	leave
801063b8:	c3                   	ret

801063b9 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801063b9:	6a 00                	push   $0x0
  pushl $0
801063bb:	6a 00                	push   $0x0
  jmp alltraps
801063bd:	e9 6e f9 ff ff       	jmp    80105d30 <alltraps>

801063c2 <vector1>:
.globl vector1
vector1:
  pushl $0
801063c2:	6a 00                	push   $0x0
  pushl $1
801063c4:	6a 01                	push   $0x1
  jmp alltraps
801063c6:	e9 65 f9 ff ff       	jmp    80105d30 <alltraps>

801063cb <vector2>:
.globl vector2
vector2:
  pushl $0
801063cb:	6a 00                	push   $0x0
  pushl $2
801063cd:	6a 02                	push   $0x2
  jmp alltraps
801063cf:	e9 5c f9 ff ff       	jmp    80105d30 <alltraps>

801063d4 <vector3>:
.globl vector3
vector3:
  pushl $0
801063d4:	6a 00                	push   $0x0
  pushl $3
801063d6:	6a 03                	push   $0x3
  jmp alltraps
801063d8:	e9 53 f9 ff ff       	jmp    80105d30 <alltraps>

801063dd <vector4>:
.globl vector4
vector4:
  pushl $0
801063dd:	6a 00                	push   $0x0
  pushl $4
801063df:	6a 04                	push   $0x4
  jmp alltraps
801063e1:	e9 4a f9 ff ff       	jmp    80105d30 <alltraps>

801063e6 <vector5>:
.globl vector5
vector5:
  pushl $0
801063e6:	6a 00                	push   $0x0
  pushl $5
801063e8:	6a 05                	push   $0x5
  jmp alltraps
801063ea:	e9 41 f9 ff ff       	jmp    80105d30 <alltraps>

801063ef <vector6>:
.globl vector6
vector6:
  pushl $0
801063ef:	6a 00                	push   $0x0
  pushl $6
801063f1:	6a 06                	push   $0x6
  jmp alltraps
801063f3:	e9 38 f9 ff ff       	jmp    80105d30 <alltraps>

801063f8 <vector7>:
.globl vector7
vector7:
  pushl $0
801063f8:	6a 00                	push   $0x0
  pushl $7
801063fa:	6a 07                	push   $0x7
  jmp alltraps
801063fc:	e9 2f f9 ff ff       	jmp    80105d30 <alltraps>

80106401 <vector8>:
.globl vector8
vector8:
  pushl $8
80106401:	6a 08                	push   $0x8
  jmp alltraps
80106403:	e9 28 f9 ff ff       	jmp    80105d30 <alltraps>

80106408 <vector9>:
.globl vector9
vector9:
  pushl $0
80106408:	6a 00                	push   $0x0
  pushl $9
8010640a:	6a 09                	push   $0x9
  jmp alltraps
8010640c:	e9 1f f9 ff ff       	jmp    80105d30 <alltraps>

80106411 <vector10>:
.globl vector10
vector10:
  pushl $10
80106411:	6a 0a                	push   $0xa
  jmp alltraps
80106413:	e9 18 f9 ff ff       	jmp    80105d30 <alltraps>

80106418 <vector11>:
.globl vector11
vector11:
  pushl $11
80106418:	6a 0b                	push   $0xb
  jmp alltraps
8010641a:	e9 11 f9 ff ff       	jmp    80105d30 <alltraps>

8010641f <vector12>:
.globl vector12
vector12:
  pushl $12
8010641f:	6a 0c                	push   $0xc
  jmp alltraps
80106421:	e9 0a f9 ff ff       	jmp    80105d30 <alltraps>

80106426 <vector13>:
.globl vector13
vector13:
  pushl $13
80106426:	6a 0d                	push   $0xd
  jmp alltraps
80106428:	e9 03 f9 ff ff       	jmp    80105d30 <alltraps>

8010642d <vector14>:
.globl vector14
vector14:
  pushl $14
8010642d:	6a 0e                	push   $0xe
  jmp alltraps
8010642f:	e9 fc f8 ff ff       	jmp    80105d30 <alltraps>

80106434 <vector15>:
.globl vector15
vector15:
  pushl $0
80106434:	6a 00                	push   $0x0
  pushl $15
80106436:	6a 0f                	push   $0xf
  jmp alltraps
80106438:	e9 f3 f8 ff ff       	jmp    80105d30 <alltraps>

8010643d <vector16>:
.globl vector16
vector16:
  pushl $0
8010643d:	6a 00                	push   $0x0
  pushl $16
8010643f:	6a 10                	push   $0x10
  jmp alltraps
80106441:	e9 ea f8 ff ff       	jmp    80105d30 <alltraps>

80106446 <vector17>:
.globl vector17
vector17:
  pushl $17
80106446:	6a 11                	push   $0x11
  jmp alltraps
80106448:	e9 e3 f8 ff ff       	jmp    80105d30 <alltraps>

8010644d <vector18>:
.globl vector18
vector18:
  pushl $0
8010644d:	6a 00                	push   $0x0
  pushl $18
8010644f:	6a 12                	push   $0x12
  jmp alltraps
80106451:	e9 da f8 ff ff       	jmp    80105d30 <alltraps>

80106456 <vector19>:
.globl vector19
vector19:
  pushl $0
80106456:	6a 00                	push   $0x0
  pushl $19
80106458:	6a 13                	push   $0x13
  jmp alltraps
8010645a:	e9 d1 f8 ff ff       	jmp    80105d30 <alltraps>

8010645f <vector20>:
.globl vector20
vector20:
  pushl $0
8010645f:	6a 00                	push   $0x0
  pushl $20
80106461:	6a 14                	push   $0x14
  jmp alltraps
80106463:	e9 c8 f8 ff ff       	jmp    80105d30 <alltraps>

80106468 <vector21>:
.globl vector21
vector21:
  pushl $0
80106468:	6a 00                	push   $0x0
  pushl $21
8010646a:	6a 15                	push   $0x15
  jmp alltraps
8010646c:	e9 bf f8 ff ff       	jmp    80105d30 <alltraps>

80106471 <vector22>:
.globl vector22
vector22:
  pushl $0
80106471:	6a 00                	push   $0x0
  pushl $22
80106473:	6a 16                	push   $0x16
  jmp alltraps
80106475:	e9 b6 f8 ff ff       	jmp    80105d30 <alltraps>

8010647a <vector23>:
.globl vector23
vector23:
  pushl $0
8010647a:	6a 00                	push   $0x0
  pushl $23
8010647c:	6a 17                	push   $0x17
  jmp alltraps
8010647e:	e9 ad f8 ff ff       	jmp    80105d30 <alltraps>

80106483 <vector24>:
.globl vector24
vector24:
  pushl $0
80106483:	6a 00                	push   $0x0
  pushl $24
80106485:	6a 18                	push   $0x18
  jmp alltraps
80106487:	e9 a4 f8 ff ff       	jmp    80105d30 <alltraps>

8010648c <vector25>:
.globl vector25
vector25:
  pushl $0
8010648c:	6a 00                	push   $0x0
  pushl $25
8010648e:	6a 19                	push   $0x19
  jmp alltraps
80106490:	e9 9b f8 ff ff       	jmp    80105d30 <alltraps>

80106495 <vector26>:
.globl vector26
vector26:
  pushl $0
80106495:	6a 00                	push   $0x0
  pushl $26
80106497:	6a 1a                	push   $0x1a
  jmp alltraps
80106499:	e9 92 f8 ff ff       	jmp    80105d30 <alltraps>

8010649e <vector27>:
.globl vector27
vector27:
  pushl $0
8010649e:	6a 00                	push   $0x0
  pushl $27
801064a0:	6a 1b                	push   $0x1b
  jmp alltraps
801064a2:	e9 89 f8 ff ff       	jmp    80105d30 <alltraps>

801064a7 <vector28>:
.globl vector28
vector28:
  pushl $0
801064a7:	6a 00                	push   $0x0
  pushl $28
801064a9:	6a 1c                	push   $0x1c
  jmp alltraps
801064ab:	e9 80 f8 ff ff       	jmp    80105d30 <alltraps>

801064b0 <vector29>:
.globl vector29
vector29:
  pushl $0
801064b0:	6a 00                	push   $0x0
  pushl $29
801064b2:	6a 1d                	push   $0x1d
  jmp alltraps
801064b4:	e9 77 f8 ff ff       	jmp    80105d30 <alltraps>

801064b9 <vector30>:
.globl vector30
vector30:
  pushl $0
801064b9:	6a 00                	push   $0x0
  pushl $30
801064bb:	6a 1e                	push   $0x1e
  jmp alltraps
801064bd:	e9 6e f8 ff ff       	jmp    80105d30 <alltraps>

801064c2 <vector31>:
.globl vector31
vector31:
  pushl $0
801064c2:	6a 00                	push   $0x0
  pushl $31
801064c4:	6a 1f                	push   $0x1f
  jmp alltraps
801064c6:	e9 65 f8 ff ff       	jmp    80105d30 <alltraps>

801064cb <vector32>:
.globl vector32
vector32:
  pushl $0
801064cb:	6a 00                	push   $0x0
  pushl $32
801064cd:	6a 20                	push   $0x20
  jmp alltraps
801064cf:	e9 5c f8 ff ff       	jmp    80105d30 <alltraps>

801064d4 <vector33>:
.globl vector33
vector33:
  pushl $0
801064d4:	6a 00                	push   $0x0
  pushl $33
801064d6:	6a 21                	push   $0x21
  jmp alltraps
801064d8:	e9 53 f8 ff ff       	jmp    80105d30 <alltraps>

801064dd <vector34>:
.globl vector34
vector34:
  pushl $0
801064dd:	6a 00                	push   $0x0
  pushl $34
801064df:	6a 22                	push   $0x22
  jmp alltraps
801064e1:	e9 4a f8 ff ff       	jmp    80105d30 <alltraps>

801064e6 <vector35>:
.globl vector35
vector35:
  pushl $0
801064e6:	6a 00                	push   $0x0
  pushl $35
801064e8:	6a 23                	push   $0x23
  jmp alltraps
801064ea:	e9 41 f8 ff ff       	jmp    80105d30 <alltraps>

801064ef <vector36>:
.globl vector36
vector36:
  pushl $0
801064ef:	6a 00                	push   $0x0
  pushl $36
801064f1:	6a 24                	push   $0x24
  jmp alltraps
801064f3:	e9 38 f8 ff ff       	jmp    80105d30 <alltraps>

801064f8 <vector37>:
.globl vector37
vector37:
  pushl $0
801064f8:	6a 00                	push   $0x0
  pushl $37
801064fa:	6a 25                	push   $0x25
  jmp alltraps
801064fc:	e9 2f f8 ff ff       	jmp    80105d30 <alltraps>

80106501 <vector38>:
.globl vector38
vector38:
  pushl $0
80106501:	6a 00                	push   $0x0
  pushl $38
80106503:	6a 26                	push   $0x26
  jmp alltraps
80106505:	e9 26 f8 ff ff       	jmp    80105d30 <alltraps>

8010650a <vector39>:
.globl vector39
vector39:
  pushl $0
8010650a:	6a 00                	push   $0x0
  pushl $39
8010650c:	6a 27                	push   $0x27
  jmp alltraps
8010650e:	e9 1d f8 ff ff       	jmp    80105d30 <alltraps>

80106513 <vector40>:
.globl vector40
vector40:
  pushl $0
80106513:	6a 00                	push   $0x0
  pushl $40
80106515:	6a 28                	push   $0x28
  jmp alltraps
80106517:	e9 14 f8 ff ff       	jmp    80105d30 <alltraps>

8010651c <vector41>:
.globl vector41
vector41:
  pushl $0
8010651c:	6a 00                	push   $0x0
  pushl $41
8010651e:	6a 29                	push   $0x29
  jmp alltraps
80106520:	e9 0b f8 ff ff       	jmp    80105d30 <alltraps>

80106525 <vector42>:
.globl vector42
vector42:
  pushl $0
80106525:	6a 00                	push   $0x0
  pushl $42
80106527:	6a 2a                	push   $0x2a
  jmp alltraps
80106529:	e9 02 f8 ff ff       	jmp    80105d30 <alltraps>

8010652e <vector43>:
.globl vector43
vector43:
  pushl $0
8010652e:	6a 00                	push   $0x0
  pushl $43
80106530:	6a 2b                	push   $0x2b
  jmp alltraps
80106532:	e9 f9 f7 ff ff       	jmp    80105d30 <alltraps>

80106537 <vector44>:
.globl vector44
vector44:
  pushl $0
80106537:	6a 00                	push   $0x0
  pushl $44
80106539:	6a 2c                	push   $0x2c
  jmp alltraps
8010653b:	e9 f0 f7 ff ff       	jmp    80105d30 <alltraps>

80106540 <vector45>:
.globl vector45
vector45:
  pushl $0
80106540:	6a 00                	push   $0x0
  pushl $45
80106542:	6a 2d                	push   $0x2d
  jmp alltraps
80106544:	e9 e7 f7 ff ff       	jmp    80105d30 <alltraps>

80106549 <vector46>:
.globl vector46
vector46:
  pushl $0
80106549:	6a 00                	push   $0x0
  pushl $46
8010654b:	6a 2e                	push   $0x2e
  jmp alltraps
8010654d:	e9 de f7 ff ff       	jmp    80105d30 <alltraps>

80106552 <vector47>:
.globl vector47
vector47:
  pushl $0
80106552:	6a 00                	push   $0x0
  pushl $47
80106554:	6a 2f                	push   $0x2f
  jmp alltraps
80106556:	e9 d5 f7 ff ff       	jmp    80105d30 <alltraps>

8010655b <vector48>:
.globl vector48
vector48:
  pushl $0
8010655b:	6a 00                	push   $0x0
  pushl $48
8010655d:	6a 30                	push   $0x30
  jmp alltraps
8010655f:	e9 cc f7 ff ff       	jmp    80105d30 <alltraps>

80106564 <vector49>:
.globl vector49
vector49:
  pushl $0
80106564:	6a 00                	push   $0x0
  pushl $49
80106566:	6a 31                	push   $0x31
  jmp alltraps
80106568:	e9 c3 f7 ff ff       	jmp    80105d30 <alltraps>

8010656d <vector50>:
.globl vector50
vector50:
  pushl $0
8010656d:	6a 00                	push   $0x0
  pushl $50
8010656f:	6a 32                	push   $0x32
  jmp alltraps
80106571:	e9 ba f7 ff ff       	jmp    80105d30 <alltraps>

80106576 <vector51>:
.globl vector51
vector51:
  pushl $0
80106576:	6a 00                	push   $0x0
  pushl $51
80106578:	6a 33                	push   $0x33
  jmp alltraps
8010657a:	e9 b1 f7 ff ff       	jmp    80105d30 <alltraps>

8010657f <vector52>:
.globl vector52
vector52:
  pushl $0
8010657f:	6a 00                	push   $0x0
  pushl $52
80106581:	6a 34                	push   $0x34
  jmp alltraps
80106583:	e9 a8 f7 ff ff       	jmp    80105d30 <alltraps>

80106588 <vector53>:
.globl vector53
vector53:
  pushl $0
80106588:	6a 00                	push   $0x0
  pushl $53
8010658a:	6a 35                	push   $0x35
  jmp alltraps
8010658c:	e9 9f f7 ff ff       	jmp    80105d30 <alltraps>

80106591 <vector54>:
.globl vector54
vector54:
  pushl $0
80106591:	6a 00                	push   $0x0
  pushl $54
80106593:	6a 36                	push   $0x36
  jmp alltraps
80106595:	e9 96 f7 ff ff       	jmp    80105d30 <alltraps>

8010659a <vector55>:
.globl vector55
vector55:
  pushl $0
8010659a:	6a 00                	push   $0x0
  pushl $55
8010659c:	6a 37                	push   $0x37
  jmp alltraps
8010659e:	e9 8d f7 ff ff       	jmp    80105d30 <alltraps>

801065a3 <vector56>:
.globl vector56
vector56:
  pushl $0
801065a3:	6a 00                	push   $0x0
  pushl $56
801065a5:	6a 38                	push   $0x38
  jmp alltraps
801065a7:	e9 84 f7 ff ff       	jmp    80105d30 <alltraps>

801065ac <vector57>:
.globl vector57
vector57:
  pushl $0
801065ac:	6a 00                	push   $0x0
  pushl $57
801065ae:	6a 39                	push   $0x39
  jmp alltraps
801065b0:	e9 7b f7 ff ff       	jmp    80105d30 <alltraps>

801065b5 <vector58>:
.globl vector58
vector58:
  pushl $0
801065b5:	6a 00                	push   $0x0
  pushl $58
801065b7:	6a 3a                	push   $0x3a
  jmp alltraps
801065b9:	e9 72 f7 ff ff       	jmp    80105d30 <alltraps>

801065be <vector59>:
.globl vector59
vector59:
  pushl $0
801065be:	6a 00                	push   $0x0
  pushl $59
801065c0:	6a 3b                	push   $0x3b
  jmp alltraps
801065c2:	e9 69 f7 ff ff       	jmp    80105d30 <alltraps>

801065c7 <vector60>:
.globl vector60
vector60:
  pushl $0
801065c7:	6a 00                	push   $0x0
  pushl $60
801065c9:	6a 3c                	push   $0x3c
  jmp alltraps
801065cb:	e9 60 f7 ff ff       	jmp    80105d30 <alltraps>

801065d0 <vector61>:
.globl vector61
vector61:
  pushl $0
801065d0:	6a 00                	push   $0x0
  pushl $61
801065d2:	6a 3d                	push   $0x3d
  jmp alltraps
801065d4:	e9 57 f7 ff ff       	jmp    80105d30 <alltraps>

801065d9 <vector62>:
.globl vector62
vector62:
  pushl $0
801065d9:	6a 00                	push   $0x0
  pushl $62
801065db:	6a 3e                	push   $0x3e
  jmp alltraps
801065dd:	e9 4e f7 ff ff       	jmp    80105d30 <alltraps>

801065e2 <vector63>:
.globl vector63
vector63:
  pushl $0
801065e2:	6a 00                	push   $0x0
  pushl $63
801065e4:	6a 3f                	push   $0x3f
  jmp alltraps
801065e6:	e9 45 f7 ff ff       	jmp    80105d30 <alltraps>

801065eb <vector64>:
.globl vector64
vector64:
  pushl $0
801065eb:	6a 00                	push   $0x0
  pushl $64
801065ed:	6a 40                	push   $0x40
  jmp alltraps
801065ef:	e9 3c f7 ff ff       	jmp    80105d30 <alltraps>

801065f4 <vector65>:
.globl vector65
vector65:
  pushl $0
801065f4:	6a 00                	push   $0x0
  pushl $65
801065f6:	6a 41                	push   $0x41
  jmp alltraps
801065f8:	e9 33 f7 ff ff       	jmp    80105d30 <alltraps>

801065fd <vector66>:
.globl vector66
vector66:
  pushl $0
801065fd:	6a 00                	push   $0x0
  pushl $66
801065ff:	6a 42                	push   $0x42
  jmp alltraps
80106601:	e9 2a f7 ff ff       	jmp    80105d30 <alltraps>

80106606 <vector67>:
.globl vector67
vector67:
  pushl $0
80106606:	6a 00                	push   $0x0
  pushl $67
80106608:	6a 43                	push   $0x43
  jmp alltraps
8010660a:	e9 21 f7 ff ff       	jmp    80105d30 <alltraps>

8010660f <vector68>:
.globl vector68
vector68:
  pushl $0
8010660f:	6a 00                	push   $0x0
  pushl $68
80106611:	6a 44                	push   $0x44
  jmp alltraps
80106613:	e9 18 f7 ff ff       	jmp    80105d30 <alltraps>

80106618 <vector69>:
.globl vector69
vector69:
  pushl $0
80106618:	6a 00                	push   $0x0
  pushl $69
8010661a:	6a 45                	push   $0x45
  jmp alltraps
8010661c:	e9 0f f7 ff ff       	jmp    80105d30 <alltraps>

80106621 <vector70>:
.globl vector70
vector70:
  pushl $0
80106621:	6a 00                	push   $0x0
  pushl $70
80106623:	6a 46                	push   $0x46
  jmp alltraps
80106625:	e9 06 f7 ff ff       	jmp    80105d30 <alltraps>

8010662a <vector71>:
.globl vector71
vector71:
  pushl $0
8010662a:	6a 00                	push   $0x0
  pushl $71
8010662c:	6a 47                	push   $0x47
  jmp alltraps
8010662e:	e9 fd f6 ff ff       	jmp    80105d30 <alltraps>

80106633 <vector72>:
.globl vector72
vector72:
  pushl $0
80106633:	6a 00                	push   $0x0
  pushl $72
80106635:	6a 48                	push   $0x48
  jmp alltraps
80106637:	e9 f4 f6 ff ff       	jmp    80105d30 <alltraps>

8010663c <vector73>:
.globl vector73
vector73:
  pushl $0
8010663c:	6a 00                	push   $0x0
  pushl $73
8010663e:	6a 49                	push   $0x49
  jmp alltraps
80106640:	e9 eb f6 ff ff       	jmp    80105d30 <alltraps>

80106645 <vector74>:
.globl vector74
vector74:
  pushl $0
80106645:	6a 00                	push   $0x0
  pushl $74
80106647:	6a 4a                	push   $0x4a
  jmp alltraps
80106649:	e9 e2 f6 ff ff       	jmp    80105d30 <alltraps>

8010664e <vector75>:
.globl vector75
vector75:
  pushl $0
8010664e:	6a 00                	push   $0x0
  pushl $75
80106650:	6a 4b                	push   $0x4b
  jmp alltraps
80106652:	e9 d9 f6 ff ff       	jmp    80105d30 <alltraps>

80106657 <vector76>:
.globl vector76
vector76:
  pushl $0
80106657:	6a 00                	push   $0x0
  pushl $76
80106659:	6a 4c                	push   $0x4c
  jmp alltraps
8010665b:	e9 d0 f6 ff ff       	jmp    80105d30 <alltraps>

80106660 <vector77>:
.globl vector77
vector77:
  pushl $0
80106660:	6a 00                	push   $0x0
  pushl $77
80106662:	6a 4d                	push   $0x4d
  jmp alltraps
80106664:	e9 c7 f6 ff ff       	jmp    80105d30 <alltraps>

80106669 <vector78>:
.globl vector78
vector78:
  pushl $0
80106669:	6a 00                	push   $0x0
  pushl $78
8010666b:	6a 4e                	push   $0x4e
  jmp alltraps
8010666d:	e9 be f6 ff ff       	jmp    80105d30 <alltraps>

80106672 <vector79>:
.globl vector79
vector79:
  pushl $0
80106672:	6a 00                	push   $0x0
  pushl $79
80106674:	6a 4f                	push   $0x4f
  jmp alltraps
80106676:	e9 b5 f6 ff ff       	jmp    80105d30 <alltraps>

8010667b <vector80>:
.globl vector80
vector80:
  pushl $0
8010667b:	6a 00                	push   $0x0
  pushl $80
8010667d:	6a 50                	push   $0x50
  jmp alltraps
8010667f:	e9 ac f6 ff ff       	jmp    80105d30 <alltraps>

80106684 <vector81>:
.globl vector81
vector81:
  pushl $0
80106684:	6a 00                	push   $0x0
  pushl $81
80106686:	6a 51                	push   $0x51
  jmp alltraps
80106688:	e9 a3 f6 ff ff       	jmp    80105d30 <alltraps>

8010668d <vector82>:
.globl vector82
vector82:
  pushl $0
8010668d:	6a 00                	push   $0x0
  pushl $82
8010668f:	6a 52                	push   $0x52
  jmp alltraps
80106691:	e9 9a f6 ff ff       	jmp    80105d30 <alltraps>

80106696 <vector83>:
.globl vector83
vector83:
  pushl $0
80106696:	6a 00                	push   $0x0
  pushl $83
80106698:	6a 53                	push   $0x53
  jmp alltraps
8010669a:	e9 91 f6 ff ff       	jmp    80105d30 <alltraps>

8010669f <vector84>:
.globl vector84
vector84:
  pushl $0
8010669f:	6a 00                	push   $0x0
  pushl $84
801066a1:	6a 54                	push   $0x54
  jmp alltraps
801066a3:	e9 88 f6 ff ff       	jmp    80105d30 <alltraps>

801066a8 <vector85>:
.globl vector85
vector85:
  pushl $0
801066a8:	6a 00                	push   $0x0
  pushl $85
801066aa:	6a 55                	push   $0x55
  jmp alltraps
801066ac:	e9 7f f6 ff ff       	jmp    80105d30 <alltraps>

801066b1 <vector86>:
.globl vector86
vector86:
  pushl $0
801066b1:	6a 00                	push   $0x0
  pushl $86
801066b3:	6a 56                	push   $0x56
  jmp alltraps
801066b5:	e9 76 f6 ff ff       	jmp    80105d30 <alltraps>

801066ba <vector87>:
.globl vector87
vector87:
  pushl $0
801066ba:	6a 00                	push   $0x0
  pushl $87
801066bc:	6a 57                	push   $0x57
  jmp alltraps
801066be:	e9 6d f6 ff ff       	jmp    80105d30 <alltraps>

801066c3 <vector88>:
.globl vector88
vector88:
  pushl $0
801066c3:	6a 00                	push   $0x0
  pushl $88
801066c5:	6a 58                	push   $0x58
  jmp alltraps
801066c7:	e9 64 f6 ff ff       	jmp    80105d30 <alltraps>

801066cc <vector89>:
.globl vector89
vector89:
  pushl $0
801066cc:	6a 00                	push   $0x0
  pushl $89
801066ce:	6a 59                	push   $0x59
  jmp alltraps
801066d0:	e9 5b f6 ff ff       	jmp    80105d30 <alltraps>

801066d5 <vector90>:
.globl vector90
vector90:
  pushl $0
801066d5:	6a 00                	push   $0x0
  pushl $90
801066d7:	6a 5a                	push   $0x5a
  jmp alltraps
801066d9:	e9 52 f6 ff ff       	jmp    80105d30 <alltraps>

801066de <vector91>:
.globl vector91
vector91:
  pushl $0
801066de:	6a 00                	push   $0x0
  pushl $91
801066e0:	6a 5b                	push   $0x5b
  jmp alltraps
801066e2:	e9 49 f6 ff ff       	jmp    80105d30 <alltraps>

801066e7 <vector92>:
.globl vector92
vector92:
  pushl $0
801066e7:	6a 00                	push   $0x0
  pushl $92
801066e9:	6a 5c                	push   $0x5c
  jmp alltraps
801066eb:	e9 40 f6 ff ff       	jmp    80105d30 <alltraps>

801066f0 <vector93>:
.globl vector93
vector93:
  pushl $0
801066f0:	6a 00                	push   $0x0
  pushl $93
801066f2:	6a 5d                	push   $0x5d
  jmp alltraps
801066f4:	e9 37 f6 ff ff       	jmp    80105d30 <alltraps>

801066f9 <vector94>:
.globl vector94
vector94:
  pushl $0
801066f9:	6a 00                	push   $0x0
  pushl $94
801066fb:	6a 5e                	push   $0x5e
  jmp alltraps
801066fd:	e9 2e f6 ff ff       	jmp    80105d30 <alltraps>

80106702 <vector95>:
.globl vector95
vector95:
  pushl $0
80106702:	6a 00                	push   $0x0
  pushl $95
80106704:	6a 5f                	push   $0x5f
  jmp alltraps
80106706:	e9 25 f6 ff ff       	jmp    80105d30 <alltraps>

8010670b <vector96>:
.globl vector96
vector96:
  pushl $0
8010670b:	6a 00                	push   $0x0
  pushl $96
8010670d:	6a 60                	push   $0x60
  jmp alltraps
8010670f:	e9 1c f6 ff ff       	jmp    80105d30 <alltraps>

80106714 <vector97>:
.globl vector97
vector97:
  pushl $0
80106714:	6a 00                	push   $0x0
  pushl $97
80106716:	6a 61                	push   $0x61
  jmp alltraps
80106718:	e9 13 f6 ff ff       	jmp    80105d30 <alltraps>

8010671d <vector98>:
.globl vector98
vector98:
  pushl $0
8010671d:	6a 00                	push   $0x0
  pushl $98
8010671f:	6a 62                	push   $0x62
  jmp alltraps
80106721:	e9 0a f6 ff ff       	jmp    80105d30 <alltraps>

80106726 <vector99>:
.globl vector99
vector99:
  pushl $0
80106726:	6a 00                	push   $0x0
  pushl $99
80106728:	6a 63                	push   $0x63
  jmp alltraps
8010672a:	e9 01 f6 ff ff       	jmp    80105d30 <alltraps>

8010672f <vector100>:
.globl vector100
vector100:
  pushl $0
8010672f:	6a 00                	push   $0x0
  pushl $100
80106731:	6a 64                	push   $0x64
  jmp alltraps
80106733:	e9 f8 f5 ff ff       	jmp    80105d30 <alltraps>

80106738 <vector101>:
.globl vector101
vector101:
  pushl $0
80106738:	6a 00                	push   $0x0
  pushl $101
8010673a:	6a 65                	push   $0x65
  jmp alltraps
8010673c:	e9 ef f5 ff ff       	jmp    80105d30 <alltraps>

80106741 <vector102>:
.globl vector102
vector102:
  pushl $0
80106741:	6a 00                	push   $0x0
  pushl $102
80106743:	6a 66                	push   $0x66
  jmp alltraps
80106745:	e9 e6 f5 ff ff       	jmp    80105d30 <alltraps>

8010674a <vector103>:
.globl vector103
vector103:
  pushl $0
8010674a:	6a 00                	push   $0x0
  pushl $103
8010674c:	6a 67                	push   $0x67
  jmp alltraps
8010674e:	e9 dd f5 ff ff       	jmp    80105d30 <alltraps>

80106753 <vector104>:
.globl vector104
vector104:
  pushl $0
80106753:	6a 00                	push   $0x0
  pushl $104
80106755:	6a 68                	push   $0x68
  jmp alltraps
80106757:	e9 d4 f5 ff ff       	jmp    80105d30 <alltraps>

8010675c <vector105>:
.globl vector105
vector105:
  pushl $0
8010675c:	6a 00                	push   $0x0
  pushl $105
8010675e:	6a 69                	push   $0x69
  jmp alltraps
80106760:	e9 cb f5 ff ff       	jmp    80105d30 <alltraps>

80106765 <vector106>:
.globl vector106
vector106:
  pushl $0
80106765:	6a 00                	push   $0x0
  pushl $106
80106767:	6a 6a                	push   $0x6a
  jmp alltraps
80106769:	e9 c2 f5 ff ff       	jmp    80105d30 <alltraps>

8010676e <vector107>:
.globl vector107
vector107:
  pushl $0
8010676e:	6a 00                	push   $0x0
  pushl $107
80106770:	6a 6b                	push   $0x6b
  jmp alltraps
80106772:	e9 b9 f5 ff ff       	jmp    80105d30 <alltraps>

80106777 <vector108>:
.globl vector108
vector108:
  pushl $0
80106777:	6a 00                	push   $0x0
  pushl $108
80106779:	6a 6c                	push   $0x6c
  jmp alltraps
8010677b:	e9 b0 f5 ff ff       	jmp    80105d30 <alltraps>

80106780 <vector109>:
.globl vector109
vector109:
  pushl $0
80106780:	6a 00                	push   $0x0
  pushl $109
80106782:	6a 6d                	push   $0x6d
  jmp alltraps
80106784:	e9 a7 f5 ff ff       	jmp    80105d30 <alltraps>

80106789 <vector110>:
.globl vector110
vector110:
  pushl $0
80106789:	6a 00                	push   $0x0
  pushl $110
8010678b:	6a 6e                	push   $0x6e
  jmp alltraps
8010678d:	e9 9e f5 ff ff       	jmp    80105d30 <alltraps>

80106792 <vector111>:
.globl vector111
vector111:
  pushl $0
80106792:	6a 00                	push   $0x0
  pushl $111
80106794:	6a 6f                	push   $0x6f
  jmp alltraps
80106796:	e9 95 f5 ff ff       	jmp    80105d30 <alltraps>

8010679b <vector112>:
.globl vector112
vector112:
  pushl $0
8010679b:	6a 00                	push   $0x0
  pushl $112
8010679d:	6a 70                	push   $0x70
  jmp alltraps
8010679f:	e9 8c f5 ff ff       	jmp    80105d30 <alltraps>

801067a4 <vector113>:
.globl vector113
vector113:
  pushl $0
801067a4:	6a 00                	push   $0x0
  pushl $113
801067a6:	6a 71                	push   $0x71
  jmp alltraps
801067a8:	e9 83 f5 ff ff       	jmp    80105d30 <alltraps>

801067ad <vector114>:
.globl vector114
vector114:
  pushl $0
801067ad:	6a 00                	push   $0x0
  pushl $114
801067af:	6a 72                	push   $0x72
  jmp alltraps
801067b1:	e9 7a f5 ff ff       	jmp    80105d30 <alltraps>

801067b6 <vector115>:
.globl vector115
vector115:
  pushl $0
801067b6:	6a 00                	push   $0x0
  pushl $115
801067b8:	6a 73                	push   $0x73
  jmp alltraps
801067ba:	e9 71 f5 ff ff       	jmp    80105d30 <alltraps>

801067bf <vector116>:
.globl vector116
vector116:
  pushl $0
801067bf:	6a 00                	push   $0x0
  pushl $116
801067c1:	6a 74                	push   $0x74
  jmp alltraps
801067c3:	e9 68 f5 ff ff       	jmp    80105d30 <alltraps>

801067c8 <vector117>:
.globl vector117
vector117:
  pushl $0
801067c8:	6a 00                	push   $0x0
  pushl $117
801067ca:	6a 75                	push   $0x75
  jmp alltraps
801067cc:	e9 5f f5 ff ff       	jmp    80105d30 <alltraps>

801067d1 <vector118>:
.globl vector118
vector118:
  pushl $0
801067d1:	6a 00                	push   $0x0
  pushl $118
801067d3:	6a 76                	push   $0x76
  jmp alltraps
801067d5:	e9 56 f5 ff ff       	jmp    80105d30 <alltraps>

801067da <vector119>:
.globl vector119
vector119:
  pushl $0
801067da:	6a 00                	push   $0x0
  pushl $119
801067dc:	6a 77                	push   $0x77
  jmp alltraps
801067de:	e9 4d f5 ff ff       	jmp    80105d30 <alltraps>

801067e3 <vector120>:
.globl vector120
vector120:
  pushl $0
801067e3:	6a 00                	push   $0x0
  pushl $120
801067e5:	6a 78                	push   $0x78
  jmp alltraps
801067e7:	e9 44 f5 ff ff       	jmp    80105d30 <alltraps>

801067ec <vector121>:
.globl vector121
vector121:
  pushl $0
801067ec:	6a 00                	push   $0x0
  pushl $121
801067ee:	6a 79                	push   $0x79
  jmp alltraps
801067f0:	e9 3b f5 ff ff       	jmp    80105d30 <alltraps>

801067f5 <vector122>:
.globl vector122
vector122:
  pushl $0
801067f5:	6a 00                	push   $0x0
  pushl $122
801067f7:	6a 7a                	push   $0x7a
  jmp alltraps
801067f9:	e9 32 f5 ff ff       	jmp    80105d30 <alltraps>

801067fe <vector123>:
.globl vector123
vector123:
  pushl $0
801067fe:	6a 00                	push   $0x0
  pushl $123
80106800:	6a 7b                	push   $0x7b
  jmp alltraps
80106802:	e9 29 f5 ff ff       	jmp    80105d30 <alltraps>

80106807 <vector124>:
.globl vector124
vector124:
  pushl $0
80106807:	6a 00                	push   $0x0
  pushl $124
80106809:	6a 7c                	push   $0x7c
  jmp alltraps
8010680b:	e9 20 f5 ff ff       	jmp    80105d30 <alltraps>

80106810 <vector125>:
.globl vector125
vector125:
  pushl $0
80106810:	6a 00                	push   $0x0
  pushl $125
80106812:	6a 7d                	push   $0x7d
  jmp alltraps
80106814:	e9 17 f5 ff ff       	jmp    80105d30 <alltraps>

80106819 <vector126>:
.globl vector126
vector126:
  pushl $0
80106819:	6a 00                	push   $0x0
  pushl $126
8010681b:	6a 7e                	push   $0x7e
  jmp alltraps
8010681d:	e9 0e f5 ff ff       	jmp    80105d30 <alltraps>

80106822 <vector127>:
.globl vector127
vector127:
  pushl $0
80106822:	6a 00                	push   $0x0
  pushl $127
80106824:	6a 7f                	push   $0x7f
  jmp alltraps
80106826:	e9 05 f5 ff ff       	jmp    80105d30 <alltraps>

8010682b <vector128>:
.globl vector128
vector128:
  pushl $0
8010682b:	6a 00                	push   $0x0
  pushl $128
8010682d:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106832:	e9 f9 f4 ff ff       	jmp    80105d30 <alltraps>

80106837 <vector129>:
.globl vector129
vector129:
  pushl $0
80106837:	6a 00                	push   $0x0
  pushl $129
80106839:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010683e:	e9 ed f4 ff ff       	jmp    80105d30 <alltraps>

80106843 <vector130>:
.globl vector130
vector130:
  pushl $0
80106843:	6a 00                	push   $0x0
  pushl $130
80106845:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010684a:	e9 e1 f4 ff ff       	jmp    80105d30 <alltraps>

8010684f <vector131>:
.globl vector131
vector131:
  pushl $0
8010684f:	6a 00                	push   $0x0
  pushl $131
80106851:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106856:	e9 d5 f4 ff ff       	jmp    80105d30 <alltraps>

8010685b <vector132>:
.globl vector132
vector132:
  pushl $0
8010685b:	6a 00                	push   $0x0
  pushl $132
8010685d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106862:	e9 c9 f4 ff ff       	jmp    80105d30 <alltraps>

80106867 <vector133>:
.globl vector133
vector133:
  pushl $0
80106867:	6a 00                	push   $0x0
  pushl $133
80106869:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010686e:	e9 bd f4 ff ff       	jmp    80105d30 <alltraps>

80106873 <vector134>:
.globl vector134
vector134:
  pushl $0
80106873:	6a 00                	push   $0x0
  pushl $134
80106875:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010687a:	e9 b1 f4 ff ff       	jmp    80105d30 <alltraps>

8010687f <vector135>:
.globl vector135
vector135:
  pushl $0
8010687f:	6a 00                	push   $0x0
  pushl $135
80106881:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106886:	e9 a5 f4 ff ff       	jmp    80105d30 <alltraps>

8010688b <vector136>:
.globl vector136
vector136:
  pushl $0
8010688b:	6a 00                	push   $0x0
  pushl $136
8010688d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106892:	e9 99 f4 ff ff       	jmp    80105d30 <alltraps>

80106897 <vector137>:
.globl vector137
vector137:
  pushl $0
80106897:	6a 00                	push   $0x0
  pushl $137
80106899:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010689e:	e9 8d f4 ff ff       	jmp    80105d30 <alltraps>

801068a3 <vector138>:
.globl vector138
vector138:
  pushl $0
801068a3:	6a 00                	push   $0x0
  pushl $138
801068a5:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801068aa:	e9 81 f4 ff ff       	jmp    80105d30 <alltraps>

801068af <vector139>:
.globl vector139
vector139:
  pushl $0
801068af:	6a 00                	push   $0x0
  pushl $139
801068b1:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801068b6:	e9 75 f4 ff ff       	jmp    80105d30 <alltraps>

801068bb <vector140>:
.globl vector140
vector140:
  pushl $0
801068bb:	6a 00                	push   $0x0
  pushl $140
801068bd:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801068c2:	e9 69 f4 ff ff       	jmp    80105d30 <alltraps>

801068c7 <vector141>:
.globl vector141
vector141:
  pushl $0
801068c7:	6a 00                	push   $0x0
  pushl $141
801068c9:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801068ce:	e9 5d f4 ff ff       	jmp    80105d30 <alltraps>

801068d3 <vector142>:
.globl vector142
vector142:
  pushl $0
801068d3:	6a 00                	push   $0x0
  pushl $142
801068d5:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801068da:	e9 51 f4 ff ff       	jmp    80105d30 <alltraps>

801068df <vector143>:
.globl vector143
vector143:
  pushl $0
801068df:	6a 00                	push   $0x0
  pushl $143
801068e1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801068e6:	e9 45 f4 ff ff       	jmp    80105d30 <alltraps>

801068eb <vector144>:
.globl vector144
vector144:
  pushl $0
801068eb:	6a 00                	push   $0x0
  pushl $144
801068ed:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801068f2:	e9 39 f4 ff ff       	jmp    80105d30 <alltraps>

801068f7 <vector145>:
.globl vector145
vector145:
  pushl $0
801068f7:	6a 00                	push   $0x0
  pushl $145
801068f9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068fe:	e9 2d f4 ff ff       	jmp    80105d30 <alltraps>

80106903 <vector146>:
.globl vector146
vector146:
  pushl $0
80106903:	6a 00                	push   $0x0
  pushl $146
80106905:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010690a:	e9 21 f4 ff ff       	jmp    80105d30 <alltraps>

8010690f <vector147>:
.globl vector147
vector147:
  pushl $0
8010690f:	6a 00                	push   $0x0
  pushl $147
80106911:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106916:	e9 15 f4 ff ff       	jmp    80105d30 <alltraps>

8010691b <vector148>:
.globl vector148
vector148:
  pushl $0
8010691b:	6a 00                	push   $0x0
  pushl $148
8010691d:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106922:	e9 09 f4 ff ff       	jmp    80105d30 <alltraps>

80106927 <vector149>:
.globl vector149
vector149:
  pushl $0
80106927:	6a 00                	push   $0x0
  pushl $149
80106929:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010692e:	e9 fd f3 ff ff       	jmp    80105d30 <alltraps>

80106933 <vector150>:
.globl vector150
vector150:
  pushl $0
80106933:	6a 00                	push   $0x0
  pushl $150
80106935:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010693a:	e9 f1 f3 ff ff       	jmp    80105d30 <alltraps>

8010693f <vector151>:
.globl vector151
vector151:
  pushl $0
8010693f:	6a 00                	push   $0x0
  pushl $151
80106941:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106946:	e9 e5 f3 ff ff       	jmp    80105d30 <alltraps>

8010694b <vector152>:
.globl vector152
vector152:
  pushl $0
8010694b:	6a 00                	push   $0x0
  pushl $152
8010694d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106952:	e9 d9 f3 ff ff       	jmp    80105d30 <alltraps>

80106957 <vector153>:
.globl vector153
vector153:
  pushl $0
80106957:	6a 00                	push   $0x0
  pushl $153
80106959:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010695e:	e9 cd f3 ff ff       	jmp    80105d30 <alltraps>

80106963 <vector154>:
.globl vector154
vector154:
  pushl $0
80106963:	6a 00                	push   $0x0
  pushl $154
80106965:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010696a:	e9 c1 f3 ff ff       	jmp    80105d30 <alltraps>

8010696f <vector155>:
.globl vector155
vector155:
  pushl $0
8010696f:	6a 00                	push   $0x0
  pushl $155
80106971:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106976:	e9 b5 f3 ff ff       	jmp    80105d30 <alltraps>

8010697b <vector156>:
.globl vector156
vector156:
  pushl $0
8010697b:	6a 00                	push   $0x0
  pushl $156
8010697d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106982:	e9 a9 f3 ff ff       	jmp    80105d30 <alltraps>

80106987 <vector157>:
.globl vector157
vector157:
  pushl $0
80106987:	6a 00                	push   $0x0
  pushl $157
80106989:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010698e:	e9 9d f3 ff ff       	jmp    80105d30 <alltraps>

80106993 <vector158>:
.globl vector158
vector158:
  pushl $0
80106993:	6a 00                	push   $0x0
  pushl $158
80106995:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010699a:	e9 91 f3 ff ff       	jmp    80105d30 <alltraps>

8010699f <vector159>:
.globl vector159
vector159:
  pushl $0
8010699f:	6a 00                	push   $0x0
  pushl $159
801069a1:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801069a6:	e9 85 f3 ff ff       	jmp    80105d30 <alltraps>

801069ab <vector160>:
.globl vector160
vector160:
  pushl $0
801069ab:	6a 00                	push   $0x0
  pushl $160
801069ad:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801069b2:	e9 79 f3 ff ff       	jmp    80105d30 <alltraps>

801069b7 <vector161>:
.globl vector161
vector161:
  pushl $0
801069b7:	6a 00                	push   $0x0
  pushl $161
801069b9:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801069be:	e9 6d f3 ff ff       	jmp    80105d30 <alltraps>

801069c3 <vector162>:
.globl vector162
vector162:
  pushl $0
801069c3:	6a 00                	push   $0x0
  pushl $162
801069c5:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801069ca:	e9 61 f3 ff ff       	jmp    80105d30 <alltraps>

801069cf <vector163>:
.globl vector163
vector163:
  pushl $0
801069cf:	6a 00                	push   $0x0
  pushl $163
801069d1:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801069d6:	e9 55 f3 ff ff       	jmp    80105d30 <alltraps>

801069db <vector164>:
.globl vector164
vector164:
  pushl $0
801069db:	6a 00                	push   $0x0
  pushl $164
801069dd:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801069e2:	e9 49 f3 ff ff       	jmp    80105d30 <alltraps>

801069e7 <vector165>:
.globl vector165
vector165:
  pushl $0
801069e7:	6a 00                	push   $0x0
  pushl $165
801069e9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801069ee:	e9 3d f3 ff ff       	jmp    80105d30 <alltraps>

801069f3 <vector166>:
.globl vector166
vector166:
  pushl $0
801069f3:	6a 00                	push   $0x0
  pushl $166
801069f5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069fa:	e9 31 f3 ff ff       	jmp    80105d30 <alltraps>

801069ff <vector167>:
.globl vector167
vector167:
  pushl $0
801069ff:	6a 00                	push   $0x0
  pushl $167
80106a01:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106a06:	e9 25 f3 ff ff       	jmp    80105d30 <alltraps>

80106a0b <vector168>:
.globl vector168
vector168:
  pushl $0
80106a0b:	6a 00                	push   $0x0
  pushl $168
80106a0d:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106a12:	e9 19 f3 ff ff       	jmp    80105d30 <alltraps>

80106a17 <vector169>:
.globl vector169
vector169:
  pushl $0
80106a17:	6a 00                	push   $0x0
  pushl $169
80106a19:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106a1e:	e9 0d f3 ff ff       	jmp    80105d30 <alltraps>

80106a23 <vector170>:
.globl vector170
vector170:
  pushl $0
80106a23:	6a 00                	push   $0x0
  pushl $170
80106a25:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106a2a:	e9 01 f3 ff ff       	jmp    80105d30 <alltraps>

80106a2f <vector171>:
.globl vector171
vector171:
  pushl $0
80106a2f:	6a 00                	push   $0x0
  pushl $171
80106a31:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106a36:	e9 f5 f2 ff ff       	jmp    80105d30 <alltraps>

80106a3b <vector172>:
.globl vector172
vector172:
  pushl $0
80106a3b:	6a 00                	push   $0x0
  pushl $172
80106a3d:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a42:	e9 e9 f2 ff ff       	jmp    80105d30 <alltraps>

80106a47 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a47:	6a 00                	push   $0x0
  pushl $173
80106a49:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a4e:	e9 dd f2 ff ff       	jmp    80105d30 <alltraps>

80106a53 <vector174>:
.globl vector174
vector174:
  pushl $0
80106a53:	6a 00                	push   $0x0
  pushl $174
80106a55:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a5a:	e9 d1 f2 ff ff       	jmp    80105d30 <alltraps>

80106a5f <vector175>:
.globl vector175
vector175:
  pushl $0
80106a5f:	6a 00                	push   $0x0
  pushl $175
80106a61:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a66:	e9 c5 f2 ff ff       	jmp    80105d30 <alltraps>

80106a6b <vector176>:
.globl vector176
vector176:
  pushl $0
80106a6b:	6a 00                	push   $0x0
  pushl $176
80106a6d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a72:	e9 b9 f2 ff ff       	jmp    80105d30 <alltraps>

80106a77 <vector177>:
.globl vector177
vector177:
  pushl $0
80106a77:	6a 00                	push   $0x0
  pushl $177
80106a79:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a7e:	e9 ad f2 ff ff       	jmp    80105d30 <alltraps>

80106a83 <vector178>:
.globl vector178
vector178:
  pushl $0
80106a83:	6a 00                	push   $0x0
  pushl $178
80106a85:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a8a:	e9 a1 f2 ff ff       	jmp    80105d30 <alltraps>

80106a8f <vector179>:
.globl vector179
vector179:
  pushl $0
80106a8f:	6a 00                	push   $0x0
  pushl $179
80106a91:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a96:	e9 95 f2 ff ff       	jmp    80105d30 <alltraps>

80106a9b <vector180>:
.globl vector180
vector180:
  pushl $0
80106a9b:	6a 00                	push   $0x0
  pushl $180
80106a9d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106aa2:	e9 89 f2 ff ff       	jmp    80105d30 <alltraps>

80106aa7 <vector181>:
.globl vector181
vector181:
  pushl $0
80106aa7:	6a 00                	push   $0x0
  pushl $181
80106aa9:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106aae:	e9 7d f2 ff ff       	jmp    80105d30 <alltraps>

80106ab3 <vector182>:
.globl vector182
vector182:
  pushl $0
80106ab3:	6a 00                	push   $0x0
  pushl $182
80106ab5:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106aba:	e9 71 f2 ff ff       	jmp    80105d30 <alltraps>

80106abf <vector183>:
.globl vector183
vector183:
  pushl $0
80106abf:	6a 00                	push   $0x0
  pushl $183
80106ac1:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106ac6:	e9 65 f2 ff ff       	jmp    80105d30 <alltraps>

80106acb <vector184>:
.globl vector184
vector184:
  pushl $0
80106acb:	6a 00                	push   $0x0
  pushl $184
80106acd:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106ad2:	e9 59 f2 ff ff       	jmp    80105d30 <alltraps>

80106ad7 <vector185>:
.globl vector185
vector185:
  pushl $0
80106ad7:	6a 00                	push   $0x0
  pushl $185
80106ad9:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106ade:	e9 4d f2 ff ff       	jmp    80105d30 <alltraps>

80106ae3 <vector186>:
.globl vector186
vector186:
  pushl $0
80106ae3:	6a 00                	push   $0x0
  pushl $186
80106ae5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106aea:	e9 41 f2 ff ff       	jmp    80105d30 <alltraps>

80106aef <vector187>:
.globl vector187
vector187:
  pushl $0
80106aef:	6a 00                	push   $0x0
  pushl $187
80106af1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106af6:	e9 35 f2 ff ff       	jmp    80105d30 <alltraps>

80106afb <vector188>:
.globl vector188
vector188:
  pushl $0
80106afb:	6a 00                	push   $0x0
  pushl $188
80106afd:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106b02:	e9 29 f2 ff ff       	jmp    80105d30 <alltraps>

80106b07 <vector189>:
.globl vector189
vector189:
  pushl $0
80106b07:	6a 00                	push   $0x0
  pushl $189
80106b09:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106b0e:	e9 1d f2 ff ff       	jmp    80105d30 <alltraps>

80106b13 <vector190>:
.globl vector190
vector190:
  pushl $0
80106b13:	6a 00                	push   $0x0
  pushl $190
80106b15:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106b1a:	e9 11 f2 ff ff       	jmp    80105d30 <alltraps>

80106b1f <vector191>:
.globl vector191
vector191:
  pushl $0
80106b1f:	6a 00                	push   $0x0
  pushl $191
80106b21:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106b26:	e9 05 f2 ff ff       	jmp    80105d30 <alltraps>

80106b2b <vector192>:
.globl vector192
vector192:
  pushl $0
80106b2b:	6a 00                	push   $0x0
  pushl $192
80106b2d:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106b32:	e9 f9 f1 ff ff       	jmp    80105d30 <alltraps>

80106b37 <vector193>:
.globl vector193
vector193:
  pushl $0
80106b37:	6a 00                	push   $0x0
  pushl $193
80106b39:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106b3e:	e9 ed f1 ff ff       	jmp    80105d30 <alltraps>

80106b43 <vector194>:
.globl vector194
vector194:
  pushl $0
80106b43:	6a 00                	push   $0x0
  pushl $194
80106b45:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b4a:	e9 e1 f1 ff ff       	jmp    80105d30 <alltraps>

80106b4f <vector195>:
.globl vector195
vector195:
  pushl $0
80106b4f:	6a 00                	push   $0x0
  pushl $195
80106b51:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b56:	e9 d5 f1 ff ff       	jmp    80105d30 <alltraps>

80106b5b <vector196>:
.globl vector196
vector196:
  pushl $0
80106b5b:	6a 00                	push   $0x0
  pushl $196
80106b5d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b62:	e9 c9 f1 ff ff       	jmp    80105d30 <alltraps>

80106b67 <vector197>:
.globl vector197
vector197:
  pushl $0
80106b67:	6a 00                	push   $0x0
  pushl $197
80106b69:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b6e:	e9 bd f1 ff ff       	jmp    80105d30 <alltraps>

80106b73 <vector198>:
.globl vector198
vector198:
  pushl $0
80106b73:	6a 00                	push   $0x0
  pushl $198
80106b75:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b7a:	e9 b1 f1 ff ff       	jmp    80105d30 <alltraps>

80106b7f <vector199>:
.globl vector199
vector199:
  pushl $0
80106b7f:	6a 00                	push   $0x0
  pushl $199
80106b81:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b86:	e9 a5 f1 ff ff       	jmp    80105d30 <alltraps>

80106b8b <vector200>:
.globl vector200
vector200:
  pushl $0
80106b8b:	6a 00                	push   $0x0
  pushl $200
80106b8d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b92:	e9 99 f1 ff ff       	jmp    80105d30 <alltraps>

80106b97 <vector201>:
.globl vector201
vector201:
  pushl $0
80106b97:	6a 00                	push   $0x0
  pushl $201
80106b99:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b9e:	e9 8d f1 ff ff       	jmp    80105d30 <alltraps>

80106ba3 <vector202>:
.globl vector202
vector202:
  pushl $0
80106ba3:	6a 00                	push   $0x0
  pushl $202
80106ba5:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106baa:	e9 81 f1 ff ff       	jmp    80105d30 <alltraps>

80106baf <vector203>:
.globl vector203
vector203:
  pushl $0
80106baf:	6a 00                	push   $0x0
  pushl $203
80106bb1:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106bb6:	e9 75 f1 ff ff       	jmp    80105d30 <alltraps>

80106bbb <vector204>:
.globl vector204
vector204:
  pushl $0
80106bbb:	6a 00                	push   $0x0
  pushl $204
80106bbd:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106bc2:	e9 69 f1 ff ff       	jmp    80105d30 <alltraps>

80106bc7 <vector205>:
.globl vector205
vector205:
  pushl $0
80106bc7:	6a 00                	push   $0x0
  pushl $205
80106bc9:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106bce:	e9 5d f1 ff ff       	jmp    80105d30 <alltraps>

80106bd3 <vector206>:
.globl vector206
vector206:
  pushl $0
80106bd3:	6a 00                	push   $0x0
  pushl $206
80106bd5:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106bda:	e9 51 f1 ff ff       	jmp    80105d30 <alltraps>

80106bdf <vector207>:
.globl vector207
vector207:
  pushl $0
80106bdf:	6a 00                	push   $0x0
  pushl $207
80106be1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106be6:	e9 45 f1 ff ff       	jmp    80105d30 <alltraps>

80106beb <vector208>:
.globl vector208
vector208:
  pushl $0
80106beb:	6a 00                	push   $0x0
  pushl $208
80106bed:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106bf2:	e9 39 f1 ff ff       	jmp    80105d30 <alltraps>

80106bf7 <vector209>:
.globl vector209
vector209:
  pushl $0
80106bf7:	6a 00                	push   $0x0
  pushl $209
80106bf9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106bfe:	e9 2d f1 ff ff       	jmp    80105d30 <alltraps>

80106c03 <vector210>:
.globl vector210
vector210:
  pushl $0
80106c03:	6a 00                	push   $0x0
  pushl $210
80106c05:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106c0a:	e9 21 f1 ff ff       	jmp    80105d30 <alltraps>

80106c0f <vector211>:
.globl vector211
vector211:
  pushl $0
80106c0f:	6a 00                	push   $0x0
  pushl $211
80106c11:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106c16:	e9 15 f1 ff ff       	jmp    80105d30 <alltraps>

80106c1b <vector212>:
.globl vector212
vector212:
  pushl $0
80106c1b:	6a 00                	push   $0x0
  pushl $212
80106c1d:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106c22:	e9 09 f1 ff ff       	jmp    80105d30 <alltraps>

80106c27 <vector213>:
.globl vector213
vector213:
  pushl $0
80106c27:	6a 00                	push   $0x0
  pushl $213
80106c29:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106c2e:	e9 fd f0 ff ff       	jmp    80105d30 <alltraps>

80106c33 <vector214>:
.globl vector214
vector214:
  pushl $0
80106c33:	6a 00                	push   $0x0
  pushl $214
80106c35:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106c3a:	e9 f1 f0 ff ff       	jmp    80105d30 <alltraps>

80106c3f <vector215>:
.globl vector215
vector215:
  pushl $0
80106c3f:	6a 00                	push   $0x0
  pushl $215
80106c41:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c46:	e9 e5 f0 ff ff       	jmp    80105d30 <alltraps>

80106c4b <vector216>:
.globl vector216
vector216:
  pushl $0
80106c4b:	6a 00                	push   $0x0
  pushl $216
80106c4d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c52:	e9 d9 f0 ff ff       	jmp    80105d30 <alltraps>

80106c57 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c57:	6a 00                	push   $0x0
  pushl $217
80106c59:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c5e:	e9 cd f0 ff ff       	jmp    80105d30 <alltraps>

80106c63 <vector218>:
.globl vector218
vector218:
  pushl $0
80106c63:	6a 00                	push   $0x0
  pushl $218
80106c65:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c6a:	e9 c1 f0 ff ff       	jmp    80105d30 <alltraps>

80106c6f <vector219>:
.globl vector219
vector219:
  pushl $0
80106c6f:	6a 00                	push   $0x0
  pushl $219
80106c71:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c76:	e9 b5 f0 ff ff       	jmp    80105d30 <alltraps>

80106c7b <vector220>:
.globl vector220
vector220:
  pushl $0
80106c7b:	6a 00                	push   $0x0
  pushl $220
80106c7d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c82:	e9 a9 f0 ff ff       	jmp    80105d30 <alltraps>

80106c87 <vector221>:
.globl vector221
vector221:
  pushl $0
80106c87:	6a 00                	push   $0x0
  pushl $221
80106c89:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c8e:	e9 9d f0 ff ff       	jmp    80105d30 <alltraps>

80106c93 <vector222>:
.globl vector222
vector222:
  pushl $0
80106c93:	6a 00                	push   $0x0
  pushl $222
80106c95:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c9a:	e9 91 f0 ff ff       	jmp    80105d30 <alltraps>

80106c9f <vector223>:
.globl vector223
vector223:
  pushl $0
80106c9f:	6a 00                	push   $0x0
  pushl $223
80106ca1:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106ca6:	e9 85 f0 ff ff       	jmp    80105d30 <alltraps>

80106cab <vector224>:
.globl vector224
vector224:
  pushl $0
80106cab:	6a 00                	push   $0x0
  pushl $224
80106cad:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106cb2:	e9 79 f0 ff ff       	jmp    80105d30 <alltraps>

80106cb7 <vector225>:
.globl vector225
vector225:
  pushl $0
80106cb7:	6a 00                	push   $0x0
  pushl $225
80106cb9:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106cbe:	e9 6d f0 ff ff       	jmp    80105d30 <alltraps>

80106cc3 <vector226>:
.globl vector226
vector226:
  pushl $0
80106cc3:	6a 00                	push   $0x0
  pushl $226
80106cc5:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106cca:	e9 61 f0 ff ff       	jmp    80105d30 <alltraps>

80106ccf <vector227>:
.globl vector227
vector227:
  pushl $0
80106ccf:	6a 00                	push   $0x0
  pushl $227
80106cd1:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106cd6:	e9 55 f0 ff ff       	jmp    80105d30 <alltraps>

80106cdb <vector228>:
.globl vector228
vector228:
  pushl $0
80106cdb:	6a 00                	push   $0x0
  pushl $228
80106cdd:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106ce2:	e9 49 f0 ff ff       	jmp    80105d30 <alltraps>

80106ce7 <vector229>:
.globl vector229
vector229:
  pushl $0
80106ce7:	6a 00                	push   $0x0
  pushl $229
80106ce9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106cee:	e9 3d f0 ff ff       	jmp    80105d30 <alltraps>

80106cf3 <vector230>:
.globl vector230
vector230:
  pushl $0
80106cf3:	6a 00                	push   $0x0
  pushl $230
80106cf5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106cfa:	e9 31 f0 ff ff       	jmp    80105d30 <alltraps>

80106cff <vector231>:
.globl vector231
vector231:
  pushl $0
80106cff:	6a 00                	push   $0x0
  pushl $231
80106d01:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106d06:	e9 25 f0 ff ff       	jmp    80105d30 <alltraps>

80106d0b <vector232>:
.globl vector232
vector232:
  pushl $0
80106d0b:	6a 00                	push   $0x0
  pushl $232
80106d0d:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106d12:	e9 19 f0 ff ff       	jmp    80105d30 <alltraps>

80106d17 <vector233>:
.globl vector233
vector233:
  pushl $0
80106d17:	6a 00                	push   $0x0
  pushl $233
80106d19:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106d1e:	e9 0d f0 ff ff       	jmp    80105d30 <alltraps>

80106d23 <vector234>:
.globl vector234
vector234:
  pushl $0
80106d23:	6a 00                	push   $0x0
  pushl $234
80106d25:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106d2a:	e9 01 f0 ff ff       	jmp    80105d30 <alltraps>

80106d2f <vector235>:
.globl vector235
vector235:
  pushl $0
80106d2f:	6a 00                	push   $0x0
  pushl $235
80106d31:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106d36:	e9 f5 ef ff ff       	jmp    80105d30 <alltraps>

80106d3b <vector236>:
.globl vector236
vector236:
  pushl $0
80106d3b:	6a 00                	push   $0x0
  pushl $236
80106d3d:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d42:	e9 e9 ef ff ff       	jmp    80105d30 <alltraps>

80106d47 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d47:	6a 00                	push   $0x0
  pushl $237
80106d49:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d4e:	e9 dd ef ff ff       	jmp    80105d30 <alltraps>

80106d53 <vector238>:
.globl vector238
vector238:
  pushl $0
80106d53:	6a 00                	push   $0x0
  pushl $238
80106d55:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d5a:	e9 d1 ef ff ff       	jmp    80105d30 <alltraps>

80106d5f <vector239>:
.globl vector239
vector239:
  pushl $0
80106d5f:	6a 00                	push   $0x0
  pushl $239
80106d61:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d66:	e9 c5 ef ff ff       	jmp    80105d30 <alltraps>

80106d6b <vector240>:
.globl vector240
vector240:
  pushl $0
80106d6b:	6a 00                	push   $0x0
  pushl $240
80106d6d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d72:	e9 b9 ef ff ff       	jmp    80105d30 <alltraps>

80106d77 <vector241>:
.globl vector241
vector241:
  pushl $0
80106d77:	6a 00                	push   $0x0
  pushl $241
80106d79:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d7e:	e9 ad ef ff ff       	jmp    80105d30 <alltraps>

80106d83 <vector242>:
.globl vector242
vector242:
  pushl $0
80106d83:	6a 00                	push   $0x0
  pushl $242
80106d85:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d8a:	e9 a1 ef ff ff       	jmp    80105d30 <alltraps>

80106d8f <vector243>:
.globl vector243
vector243:
  pushl $0
80106d8f:	6a 00                	push   $0x0
  pushl $243
80106d91:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d96:	e9 95 ef ff ff       	jmp    80105d30 <alltraps>

80106d9b <vector244>:
.globl vector244
vector244:
  pushl $0
80106d9b:	6a 00                	push   $0x0
  pushl $244
80106d9d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106da2:	e9 89 ef ff ff       	jmp    80105d30 <alltraps>

80106da7 <vector245>:
.globl vector245
vector245:
  pushl $0
80106da7:	6a 00                	push   $0x0
  pushl $245
80106da9:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106dae:	e9 7d ef ff ff       	jmp    80105d30 <alltraps>

80106db3 <vector246>:
.globl vector246
vector246:
  pushl $0
80106db3:	6a 00                	push   $0x0
  pushl $246
80106db5:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106dba:	e9 71 ef ff ff       	jmp    80105d30 <alltraps>

80106dbf <vector247>:
.globl vector247
vector247:
  pushl $0
80106dbf:	6a 00                	push   $0x0
  pushl $247
80106dc1:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106dc6:	e9 65 ef ff ff       	jmp    80105d30 <alltraps>

80106dcb <vector248>:
.globl vector248
vector248:
  pushl $0
80106dcb:	6a 00                	push   $0x0
  pushl $248
80106dcd:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106dd2:	e9 59 ef ff ff       	jmp    80105d30 <alltraps>

80106dd7 <vector249>:
.globl vector249
vector249:
  pushl $0
80106dd7:	6a 00                	push   $0x0
  pushl $249
80106dd9:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106dde:	e9 4d ef ff ff       	jmp    80105d30 <alltraps>

80106de3 <vector250>:
.globl vector250
vector250:
  pushl $0
80106de3:	6a 00                	push   $0x0
  pushl $250
80106de5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106dea:	e9 41 ef ff ff       	jmp    80105d30 <alltraps>

80106def <vector251>:
.globl vector251
vector251:
  pushl $0
80106def:	6a 00                	push   $0x0
  pushl $251
80106df1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106df6:	e9 35 ef ff ff       	jmp    80105d30 <alltraps>

80106dfb <vector252>:
.globl vector252
vector252:
  pushl $0
80106dfb:	6a 00                	push   $0x0
  pushl $252
80106dfd:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106e02:	e9 29 ef ff ff       	jmp    80105d30 <alltraps>

80106e07 <vector253>:
.globl vector253
vector253:
  pushl $0
80106e07:	6a 00                	push   $0x0
  pushl $253
80106e09:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106e0e:	e9 1d ef ff ff       	jmp    80105d30 <alltraps>

80106e13 <vector254>:
.globl vector254
vector254:
  pushl $0
80106e13:	6a 00                	push   $0x0
  pushl $254
80106e15:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106e1a:	e9 11 ef ff ff       	jmp    80105d30 <alltraps>

80106e1f <vector255>:
.globl vector255
vector255:
  pushl $0
80106e1f:	6a 00                	push   $0x0
  pushl $255
80106e21:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106e26:	e9 05 ef ff ff       	jmp    80105d30 <alltraps>

80106e2b <lgdt>:
{
80106e2b:	55                   	push   %ebp
80106e2c:	89 e5                	mov    %esp,%ebp
80106e2e:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80106e31:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e34:	83 e8 01             	sub    $0x1,%eax
80106e37:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106e3b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e3e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106e42:	8b 45 08             	mov    0x8(%ebp),%eax
80106e45:	c1 e8 10             	shr    $0x10,%eax
80106e48:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80106e4c:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106e4f:	0f 01 10             	lgdtl  (%eax)
}
80106e52:	90                   	nop
80106e53:	c9                   	leave
80106e54:	c3                   	ret

80106e55 <ltr>:
{
80106e55:	55                   	push   %ebp
80106e56:	89 e5                	mov    %esp,%ebp
80106e58:	83 ec 04             	sub    $0x4,%esp
80106e5b:	8b 45 08             	mov    0x8(%ebp),%eax
80106e5e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
80106e62:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80106e66:	0f 00 d8             	ltr    %eax
}
80106e69:	90                   	nop
80106e6a:	c9                   	leave
80106e6b:	c3                   	ret

80106e6c <lcr3>:

static inline void
lcr3(uint val)
{
80106e6c:	55                   	push   %ebp
80106e6d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106e6f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e72:	0f 22 d8             	mov    %eax,%cr3
}
80106e75:	90                   	nop
80106e76:	5d                   	pop    %ebp
80106e77:	c3                   	ret

80106e78 <seginit>:
extern struct gpu gpu;
// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80106e78:	55                   	push   %ebp
80106e79:	89 e5                	mov    %esp,%ebp
80106e7b:	83 ec 18             	sub    $0x18,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpuid()];
80106e7e:	e8 1a cb ff ff       	call   8010399d <cpuid>
80106e83:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106e89:	05 80 6a 19 80       	add    $0x80196a80,%eax
80106e8e:	89 45 f4             	mov    %eax,-0xc(%ebp)

  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e94:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
80106e9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e9d:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
80106ea3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ea6:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
80106eaa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ead:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106eb1:	83 e2 f0             	and    $0xfffffff0,%edx
80106eb4:	83 ca 0a             	or     $0xa,%edx
80106eb7:	88 50 7d             	mov    %dl,0x7d(%eax)
80106eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ebd:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ec1:	83 ca 10             	or     $0x10,%edx
80106ec4:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106eca:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106ece:	83 e2 9f             	and    $0xffffff9f,%edx
80106ed1:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ed7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80106edb:	83 ca 80             	or     $0xffffff80,%edx
80106ede:	88 50 7d             	mov    %dl,0x7d(%eax)
80106ee1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ee4:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ee8:	83 ca 0f             	or     $0xf,%edx
80106eeb:	88 50 7e             	mov    %dl,0x7e(%eax)
80106eee:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ef1:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106ef5:	83 e2 ef             	and    $0xffffffef,%edx
80106ef8:	88 50 7e             	mov    %dl,0x7e(%eax)
80106efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106efe:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f02:	83 e2 df             	and    $0xffffffdf,%edx
80106f05:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f0b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f0f:	83 ca 40             	or     $0x40,%edx
80106f12:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f18:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80106f1c:	83 ca 80             	or     $0xffffff80,%edx
80106f1f:	88 50 7e             	mov    %dl,0x7e(%eax)
80106f22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f25:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106f29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f2c:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80106f33:	ff ff 
80106f35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f38:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80106f3f:	00 00 
80106f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f44:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80106f4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f4e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f55:	83 e2 f0             	and    $0xfffffff0,%edx
80106f58:	83 ca 02             	or     $0x2,%edx
80106f5b:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f64:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f6b:	83 ca 10             	or     $0x10,%edx
80106f6e:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f74:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f77:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f7e:	83 e2 9f             	and    $0xffffff9f,%edx
80106f81:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f8a:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80106f91:	83 ca 80             	or     $0xffffff80,%edx
80106f94:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80106f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f9d:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fa4:	83 ca 0f             	or     $0xf,%edx
80106fa7:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fad:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fb0:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fb7:	83 e2 ef             	and    $0xffffffef,%edx
80106fba:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc3:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fca:	83 e2 df             	and    $0xffffffdf,%edx
80106fcd:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd6:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106fdd:	83 ca 40             	or     $0x40,%edx
80106fe0:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fe9:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80106ff0:	83 ca 80             	or     $0xffffff80,%edx
80106ff3:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80106ff9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ffc:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107006:	66 c7 80 88 00 00 00 	movw   $0xffff,0x88(%eax)
8010700d:	ff ff 
8010700f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107012:	66 c7 80 8a 00 00 00 	movw   $0x0,0x8a(%eax)
80107019:	00 00 
8010701b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010701e:	c6 80 8c 00 00 00 00 	movb   $0x0,0x8c(%eax)
80107025:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107028:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010702f:	83 e2 f0             	and    $0xfffffff0,%edx
80107032:	83 ca 0a             	or     $0xa,%edx
80107035:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010703b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010703e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107045:	83 ca 10             	or     $0x10,%edx
80107048:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010704e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107051:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107058:	83 ca 60             	or     $0x60,%edx
8010705b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107061:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107064:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010706b:	83 ca 80             	or     $0xffffff80,%edx
8010706e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107074:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107077:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010707e:	83 ca 0f             	or     $0xf,%edx
80107081:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107087:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010708a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107091:	83 e2 ef             	and    $0xffffffef,%edx
80107094:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010709a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010709d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070a4:	83 e2 df             	and    $0xffffffdf,%edx
801070a7:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070b0:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070b7:	83 ca 40             	or     $0x40,%edx
801070ba:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070c3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801070ca:	83 ca 80             	or     $0xffffff80,%edx
801070cd:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801070d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070d6:	c6 80 8f 00 00 00 00 	movb   $0x0,0x8f(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801070dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070e0:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
801070e7:	ff ff 
801070e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070ec:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
801070f3:	00 00 
801070f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801070f8:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
801070ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107102:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107109:	83 e2 f0             	and    $0xfffffff0,%edx
8010710c:	83 ca 02             	or     $0x2,%edx
8010710f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107118:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010711f:	83 ca 10             	or     $0x10,%edx
80107122:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107128:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010712b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107132:	83 ca 60             	or     $0x60,%edx
80107135:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010713b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010713e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107145:	83 ca 80             	or     $0xffffff80,%edx
80107148:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010714e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107151:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107158:	83 ca 0f             	or     $0xf,%edx
8010715b:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107161:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107164:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010716b:	83 e2 ef             	and    $0xffffffef,%edx
8010716e:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107174:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107177:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010717e:	83 e2 df             	and    $0xffffffdf,%edx
80107181:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010718a:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107191:	83 ca 40             	or     $0x40,%edx
80107194:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
8010719a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010719d:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801071a4:	83 ca 80             	or     $0xffffff80,%edx
801071a7:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801071ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071b0:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
801071b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801071ba:	83 c0 70             	add    $0x70,%eax
801071bd:	83 ec 08             	sub    $0x8,%esp
801071c0:	6a 30                	push   $0x30
801071c2:	50                   	push   %eax
801071c3:	e8 63 fc ff ff       	call   80106e2b <lgdt>
801071c8:	83 c4 10             	add    $0x10,%esp
}
801071cb:	90                   	nop
801071cc:	c9                   	leave
801071cd:	c3                   	ret

801071ce <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801071ce:	55                   	push   %ebp
801071cf:	89 e5                	mov    %esp,%ebp
801071d1:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801071d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801071d7:	c1 e8 16             	shr    $0x16,%eax
801071da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801071e1:	8b 45 08             	mov    0x8(%ebp),%eax
801071e4:	01 d0                	add    %edx,%eax
801071e6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
801071e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071ec:	8b 00                	mov    (%eax),%eax
801071ee:	83 e0 01             	and    $0x1,%eax
801071f1:	85 c0                	test   %eax,%eax
801071f3:	74 14                	je     80107209 <walkpgdir+0x3b>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801071f5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801071f8:	8b 00                	mov    (%eax),%eax
801071fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801071ff:	05 00 00 00 80       	add    $0x80000000,%eax
80107204:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107207:	eb 42                	jmp    8010724b <walkpgdir+0x7d>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107209:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010720d:	74 0e                	je     8010721d <walkpgdir+0x4f>
8010720f:	e8 94 b5 ff ff       	call   801027a8 <kalloc>
80107214:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107217:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010721b:	75 07                	jne    80107224 <walkpgdir+0x56>
      return 0;
8010721d:	b8 00 00 00 00       	mov    $0x0,%eax
80107222:	eb 3e                	jmp    80107262 <walkpgdir+0x94>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107224:	83 ec 04             	sub    $0x4,%esp
80107227:	68 00 10 00 00       	push   $0x1000
8010722c:	6a 00                	push   $0x0
8010722e:	ff 75 f4             	push   -0xc(%ebp)
80107231:	e8 56 d7 ff ff       	call   8010498c <memset>
80107236:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107239:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010723c:	05 00 00 00 80       	add    $0x80000000,%eax
80107241:	83 c8 07             	or     $0x7,%eax
80107244:	89 c2                	mov    %eax,%edx
80107246:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107249:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010724b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010724e:	c1 e8 0c             	shr    $0xc,%eax
80107251:	25 ff 03 00 00       	and    $0x3ff,%eax
80107256:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010725d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107260:	01 d0                	add    %edx,%eax
}
80107262:	c9                   	leave
80107263:	c3                   	ret

80107264 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107264:	55                   	push   %ebp
80107265:	89 e5                	mov    %esp,%ebp
80107267:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
8010726a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010726d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107272:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107275:	8b 55 0c             	mov    0xc(%ebp),%edx
80107278:	8b 45 10             	mov    0x10(%ebp),%eax
8010727b:	01 d0                	add    %edx,%eax
8010727d:	83 e8 01             	sub    $0x1,%eax
80107280:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107285:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107288:	83 ec 04             	sub    $0x4,%esp
8010728b:	6a 01                	push   $0x1
8010728d:	ff 75 f4             	push   -0xc(%ebp)
80107290:	ff 75 08             	push   0x8(%ebp)
80107293:	e8 36 ff ff ff       	call   801071ce <walkpgdir>
80107298:	83 c4 10             	add    $0x10,%esp
8010729b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010729e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801072a2:	75 07                	jne    801072ab <mappages+0x47>
      return -1;
801072a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801072a9:	eb 47                	jmp    801072f2 <mappages+0x8e>
    if(*pte & PTE_P)
801072ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072ae:	8b 00                	mov    (%eax),%eax
801072b0:	83 e0 01             	and    $0x1,%eax
801072b3:	85 c0                	test   %eax,%eax
801072b5:	74 0d                	je     801072c4 <mappages+0x60>
      panic("remap");
801072b7:	83 ec 0c             	sub    $0xc,%esp
801072ba:	68 88 a5 10 80       	push   $0x8010a588
801072bf:	e8 e5 92 ff ff       	call   801005a9 <panic>
    *pte = pa | perm | PTE_P;
801072c4:	8b 45 18             	mov    0x18(%ebp),%eax
801072c7:	0b 45 14             	or     0x14(%ebp),%eax
801072ca:	83 c8 01             	or     $0x1,%eax
801072cd:	89 c2                	mov    %eax,%edx
801072cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801072d2:	89 10                	mov    %edx,(%eax)
    if(a == last)
801072d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801072d7:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801072da:	74 10                	je     801072ec <mappages+0x88>
      break;
    a += PGSIZE;
801072dc:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
801072e3:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801072ea:	eb 9c                	jmp    80107288 <mappages+0x24>
      break;
801072ec:	90                   	nop
  }
  return 0;
801072ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801072f2:	c9                   	leave
801072f3:	c3                   	ret

801072f4 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
801072f4:	55                   	push   %ebp
801072f5:	89 e5                	mov    %esp,%ebp
801072f7:	53                   	push   %ebx
801072f8:	83 ec 24             	sub    $0x24,%esp
  pde_t *pgdir;
  struct kmap *k;
  k = kmap;
801072fb:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
  struct kmap vram = { (void*)(DEVSPACE - gpu.vram_size),gpu.pvram_addr,gpu.pvram_addr+gpu.vram_size, PTE_W};
80107302:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107307:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
8010730c:	29 c2                	sub    %eax,%edx
8010730e:	89 d0                	mov    %edx,%eax
80107310:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107313:	a1 48 6d 19 80       	mov    0x80196d48,%eax
80107318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010731b:	8b 15 48 6d 19 80    	mov    0x80196d48,%edx
80107321:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107326:	01 d0                	add    %edx,%eax
80107328:	89 45 e8             	mov    %eax,-0x18(%ebp)
8010732b:	c7 45 ec 02 00 00 00 	movl   $0x2,-0x14(%ebp)
  k[3] = vram;
80107332:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107335:	83 c0 30             	add    $0x30,%eax
80107338:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010733b:	89 10                	mov    %edx,(%eax)
8010733d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107340:	89 50 04             	mov    %edx,0x4(%eax)
80107343:	8b 55 e8             	mov    -0x18(%ebp),%edx
80107346:	89 50 08             	mov    %edx,0x8(%eax)
80107349:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010734c:	89 50 0c             	mov    %edx,0xc(%eax)
  if((pgdir = (pde_t*)kalloc()) == 0){
8010734f:	e8 54 b4 ff ff       	call   801027a8 <kalloc>
80107354:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107357:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010735b:	75 07                	jne    80107364 <setupkvm+0x70>
    return 0;
8010735d:	b8 00 00 00 00       	mov    $0x0,%eax
80107362:	eb 78                	jmp    801073dc <setupkvm+0xe8>
  }
  memset(pgdir, 0, PGSIZE);
80107364:	83 ec 04             	sub    $0x4,%esp
80107367:	68 00 10 00 00       	push   $0x1000
8010736c:	6a 00                	push   $0x0
8010736e:	ff 75 f0             	push   -0x10(%ebp)
80107371:	e8 16 d6 ff ff       	call   8010498c <memset>
80107376:	83 c4 10             	add    $0x10,%esp
  if (P2V(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107379:	c7 45 f4 80 f4 10 80 	movl   $0x8010f480,-0xc(%ebp)
80107380:	eb 4e                	jmp    801073d0 <setupkvm+0xdc>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80107382:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107385:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0) {
80107388:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010738b:	8b 50 04             	mov    0x4(%eax),%edx
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010738e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107391:	8b 58 08             	mov    0x8(%eax),%ebx
80107394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107397:	8b 40 04             	mov    0x4(%eax),%eax
8010739a:	29 c3                	sub    %eax,%ebx
8010739c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010739f:	8b 00                	mov    (%eax),%eax
801073a1:	83 ec 0c             	sub    $0xc,%esp
801073a4:	51                   	push   %ecx
801073a5:	52                   	push   %edx
801073a6:	53                   	push   %ebx
801073a7:	50                   	push   %eax
801073a8:	ff 75 f0             	push   -0x10(%ebp)
801073ab:	e8 b4 fe ff ff       	call   80107264 <mappages>
801073b0:	83 c4 20             	add    $0x20,%esp
801073b3:	85 c0                	test   %eax,%eax
801073b5:	79 15                	jns    801073cc <setupkvm+0xd8>
      freevm(pgdir);
801073b7:	83 ec 0c             	sub    $0xc,%esp
801073ba:	ff 75 f0             	push   -0x10(%ebp)
801073bd:	e8 f5 04 00 00       	call   801078b7 <freevm>
801073c2:	83 c4 10             	add    $0x10,%esp
      return 0;
801073c5:	b8 00 00 00 00       	mov    $0x0,%eax
801073ca:	eb 10                	jmp    801073dc <setupkvm+0xe8>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801073cc:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801073d0:	81 7d f4 e0 f4 10 80 	cmpl   $0x8010f4e0,-0xc(%ebp)
801073d7:	72 a9                	jb     80107382 <setupkvm+0x8e>
    }
  return pgdir;
801073d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801073dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801073df:	c9                   	leave
801073e0:	c3                   	ret

801073e1 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801073e1:	55                   	push   %ebp
801073e2:	89 e5                	mov    %esp,%ebp
801073e4:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801073e7:	e8 08 ff ff ff       	call   801072f4 <setupkvm>
801073ec:	a3 7c 6a 19 80       	mov    %eax,0x80196a7c
  switchkvm();
801073f1:	e8 03 00 00 00       	call   801073f9 <switchkvm>
}
801073f6:	90                   	nop
801073f7:	c9                   	leave
801073f8:	c3                   	ret

801073f9 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801073f9:	55                   	push   %ebp
801073fa:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073fc:	a1 7c 6a 19 80       	mov    0x80196a7c,%eax
80107401:	05 00 00 00 80       	add    $0x80000000,%eax
80107406:	50                   	push   %eax
80107407:	e8 60 fa ff ff       	call   80106e6c <lcr3>
8010740c:	83 c4 04             	add    $0x4,%esp
}
8010740f:	90                   	nop
80107410:	c9                   	leave
80107411:	c3                   	ret

80107412 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80107412:	55                   	push   %ebp
80107413:	89 e5                	mov    %esp,%ebp
80107415:	56                   	push   %esi
80107416:	53                   	push   %ebx
80107417:	83 ec 10             	sub    $0x10,%esp
  if(p == 0)
8010741a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010741e:	75 0d                	jne    8010742d <switchuvm+0x1b>
    panic("switchuvm: no process");
80107420:	83 ec 0c             	sub    $0xc,%esp
80107423:	68 8e a5 10 80       	push   $0x8010a58e
80107428:	e8 7c 91 ff ff       	call   801005a9 <panic>
  if(p->kstack == 0)
8010742d:	8b 45 08             	mov    0x8(%ebp),%eax
80107430:	8b 40 08             	mov    0x8(%eax),%eax
80107433:	85 c0                	test   %eax,%eax
80107435:	75 0d                	jne    80107444 <switchuvm+0x32>
    panic("switchuvm: no kstack");
80107437:	83 ec 0c             	sub    $0xc,%esp
8010743a:	68 a4 a5 10 80       	push   $0x8010a5a4
8010743f:	e8 65 91 ff ff       	call   801005a9 <panic>
  if(p->pgdir == 0)
80107444:	8b 45 08             	mov    0x8(%ebp),%eax
80107447:	8b 40 04             	mov    0x4(%eax),%eax
8010744a:	85 c0                	test   %eax,%eax
8010744c:	75 0d                	jne    8010745b <switchuvm+0x49>
    panic("switchuvm: no pgdir");
8010744e:	83 ec 0c             	sub    $0xc,%esp
80107451:	68 b9 a5 10 80       	push   $0x8010a5b9
80107456:	e8 4e 91 ff ff       	call   801005a9 <panic>

  pushcli();
8010745b:	e8 21 d4 ff ff       	call   80104881 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80107460:	e8 53 c5 ff ff       	call   801039b8 <mycpu>
80107465:	89 c3                	mov    %eax,%ebx
80107467:	e8 4c c5 ff ff       	call   801039b8 <mycpu>
8010746c:	83 c0 08             	add    $0x8,%eax
8010746f:	89 c6                	mov    %eax,%esi
80107471:	e8 42 c5 ff ff       	call   801039b8 <mycpu>
80107476:	83 c0 08             	add    $0x8,%eax
80107479:	c1 e8 10             	shr    $0x10,%eax
8010747c:	88 45 f7             	mov    %al,-0x9(%ebp)
8010747f:	e8 34 c5 ff ff       	call   801039b8 <mycpu>
80107484:	83 c0 08             	add    $0x8,%eax
80107487:	c1 e8 18             	shr    $0x18,%eax
8010748a:	89 c2                	mov    %eax,%edx
8010748c:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80107493:	67 00 
80107495:	66 89 b3 9a 00 00 00 	mov    %si,0x9a(%ebx)
8010749c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
801074a0:	88 83 9c 00 00 00    	mov    %al,0x9c(%ebx)
801074a6:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074ad:	83 e0 f0             	and    $0xfffffff0,%eax
801074b0:	83 c8 09             	or     $0x9,%eax
801074b3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074b9:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074c0:	83 c8 10             	or     $0x10,%eax
801074c3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074c9:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074d0:	83 e0 9f             	and    $0xffffff9f,%eax
801074d3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074d9:	0f b6 83 9d 00 00 00 	movzbl 0x9d(%ebx),%eax
801074e0:	83 c8 80             	or     $0xffffff80,%eax
801074e3:	88 83 9d 00 00 00    	mov    %al,0x9d(%ebx)
801074e9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
801074f0:	83 e0 f0             	and    $0xfffffff0,%eax
801074f3:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
801074f9:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107500:	83 e0 ef             	and    $0xffffffef,%eax
80107503:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107509:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107510:	83 e0 df             	and    $0xffffffdf,%eax
80107513:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107519:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107520:	83 c8 40             	or     $0x40,%eax
80107523:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107529:	0f b6 83 9e 00 00 00 	movzbl 0x9e(%ebx),%eax
80107530:	83 e0 7f             	and    $0x7f,%eax
80107533:	88 83 9e 00 00 00    	mov    %al,0x9e(%ebx)
80107539:	88 93 9f 00 00 00    	mov    %dl,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010753f:	e8 74 c4 ff ff       	call   801039b8 <mycpu>
80107544:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010754b:	83 e2 ef             	and    $0xffffffef,%edx
8010754e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107554:	e8 5f c4 ff ff       	call   801039b8 <mycpu>
80107559:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010755f:	8b 45 08             	mov    0x8(%ebp),%eax
80107562:	8b 40 08             	mov    0x8(%eax),%eax
80107565:	89 c3                	mov    %eax,%ebx
80107567:	e8 4c c4 ff ff       	call   801039b8 <mycpu>
8010756c:	8d 93 00 10 00 00    	lea    0x1000(%ebx),%edx
80107572:	89 50 0c             	mov    %edx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107575:	e8 3e c4 ff ff       	call   801039b8 <mycpu>
8010757a:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  ltr(SEG_TSS << 3);
80107580:	83 ec 0c             	sub    $0xc,%esp
80107583:	6a 28                	push   $0x28
80107585:	e8 cb f8 ff ff       	call   80106e55 <ltr>
8010758a:	83 c4 10             	add    $0x10,%esp
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010758d:	8b 45 08             	mov    0x8(%ebp),%eax
80107590:	8b 40 04             	mov    0x4(%eax),%eax
80107593:	05 00 00 00 80       	add    $0x80000000,%eax
80107598:	83 ec 0c             	sub    $0xc,%esp
8010759b:	50                   	push   %eax
8010759c:	e8 cb f8 ff ff       	call   80106e6c <lcr3>
801075a1:	83 c4 10             	add    $0x10,%esp
  popcli();
801075a4:	e8 25 d3 ff ff       	call   801048ce <popcli>
}
801075a9:	90                   	nop
801075aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801075ad:	5b                   	pop    %ebx
801075ae:	5e                   	pop    %esi
801075af:	5d                   	pop    %ebp
801075b0:	c3                   	ret

801075b1 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801075b1:	55                   	push   %ebp
801075b2:	89 e5                	mov    %esp,%ebp
801075b4:	83 ec 18             	sub    $0x18,%esp
  char *mem;

  if(sz >= PGSIZE)
801075b7:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801075be:	76 0d                	jbe    801075cd <inituvm+0x1c>
    panic("inituvm: more than a page");
801075c0:	83 ec 0c             	sub    $0xc,%esp
801075c3:	68 cd a5 10 80       	push   $0x8010a5cd
801075c8:	e8 dc 8f ff ff       	call   801005a9 <panic>
  mem = kalloc();
801075cd:	e8 d6 b1 ff ff       	call   801027a8 <kalloc>
801075d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801075d5:	83 ec 04             	sub    $0x4,%esp
801075d8:	68 00 10 00 00       	push   $0x1000
801075dd:	6a 00                	push   $0x0
801075df:	ff 75 f4             	push   -0xc(%ebp)
801075e2:	e8 a5 d3 ff ff       	call   8010498c <memset>
801075e7:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801075ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801075ed:	05 00 00 00 80       	add    $0x80000000,%eax
801075f2:	83 ec 0c             	sub    $0xc,%esp
801075f5:	6a 06                	push   $0x6
801075f7:	50                   	push   %eax
801075f8:	68 00 10 00 00       	push   $0x1000
801075fd:	6a 00                	push   $0x0
801075ff:	ff 75 08             	push   0x8(%ebp)
80107602:	e8 5d fc ff ff       	call   80107264 <mappages>
80107607:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010760a:	83 ec 04             	sub    $0x4,%esp
8010760d:	ff 75 10             	push   0x10(%ebp)
80107610:	ff 75 0c             	push   0xc(%ebp)
80107613:	ff 75 f4             	push   -0xc(%ebp)
80107616:	e8 30 d4 ff ff       	call   80104a4b <memmove>
8010761b:	83 c4 10             	add    $0x10,%esp
}
8010761e:	90                   	nop
8010761f:	c9                   	leave
80107620:	c3                   	ret

80107621 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80107621:	55                   	push   %ebp
80107622:	89 e5                	mov    %esp,%ebp
80107624:	83 ec 18             	sub    $0x18,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80107627:	8b 45 0c             	mov    0xc(%ebp),%eax
8010762a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010762f:	85 c0                	test   %eax,%eax
80107631:	74 0d                	je     80107640 <loaduvm+0x1f>
    panic("loaduvm: addr must be page aligned");
80107633:	83 ec 0c             	sub    $0xc,%esp
80107636:	68 e8 a5 10 80       	push   $0x8010a5e8
8010763b:	e8 69 8f ff ff       	call   801005a9 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80107640:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107647:	e9 8f 00 00 00       	jmp    801076db <loaduvm+0xba>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
8010764c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010764f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107652:	01 d0                	add    %edx,%eax
80107654:	83 ec 04             	sub    $0x4,%esp
80107657:	6a 00                	push   $0x0
80107659:	50                   	push   %eax
8010765a:	ff 75 08             	push   0x8(%ebp)
8010765d:	e8 6c fb ff ff       	call   801071ce <walkpgdir>
80107662:	83 c4 10             	add    $0x10,%esp
80107665:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107668:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010766c:	75 0d                	jne    8010767b <loaduvm+0x5a>
      panic("loaduvm: address should exist");
8010766e:	83 ec 0c             	sub    $0xc,%esp
80107671:	68 0b a6 10 80       	push   $0x8010a60b
80107676:	e8 2e 8f ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
8010767b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010767e:	8b 00                	mov    (%eax),%eax
80107680:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107685:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
80107688:	8b 45 18             	mov    0x18(%ebp),%eax
8010768b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010768e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80107693:	77 0b                	ja     801076a0 <loaduvm+0x7f>
      n = sz - i;
80107695:	8b 45 18             	mov    0x18(%ebp),%eax
80107698:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010769b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010769e:	eb 07                	jmp    801076a7 <loaduvm+0x86>
    else
      n = PGSIZE;
801076a0:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
801076a7:	8b 55 14             	mov    0x14(%ebp),%edx
801076aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076ad:	01 d0                	add    %edx,%eax
801076af:	8b 55 e8             	mov    -0x18(%ebp),%edx
801076b2:	81 c2 00 00 00 80    	add    $0x80000000,%edx
801076b8:	ff 75 f0             	push   -0x10(%ebp)
801076bb:	50                   	push   %eax
801076bc:	52                   	push   %edx
801076bd:	ff 75 10             	push   0x10(%ebp)
801076c0:	e8 19 a8 ff ff       	call   80101ede <readi>
801076c5:	83 c4 10             	add    $0x10,%esp
801076c8:	39 45 f0             	cmp    %eax,-0x10(%ebp)
801076cb:	74 07                	je     801076d4 <loaduvm+0xb3>
      return -1;
801076cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801076d2:	eb 18                	jmp    801076ec <loaduvm+0xcb>
  for(i = 0; i < sz; i += PGSIZE){
801076d4:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801076db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801076de:	3b 45 18             	cmp    0x18(%ebp),%eax
801076e1:	0f 82 65 ff ff ff    	jb     8010764c <loaduvm+0x2b>
  }
  return 0;
801076e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801076ec:	c9                   	leave
801076ed:	c3                   	ret

801076ee <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801076ee:	55                   	push   %ebp
801076ef:	89 e5                	mov    %esp,%ebp
801076f1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801076f4:	8b 45 10             	mov    0x10(%ebp),%eax
801076f7:	85 c0                	test   %eax,%eax
801076f9:	79 0a                	jns    80107705 <allocuvm+0x17>
    return 0;
801076fb:	b8 00 00 00 00       	mov    $0x0,%eax
80107700:	e9 ec 00 00 00       	jmp    801077f1 <allocuvm+0x103>
  if(newsz < oldsz)
80107705:	8b 45 10             	mov    0x10(%ebp),%eax
80107708:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010770b:	73 08                	jae    80107715 <allocuvm+0x27>
    return oldsz;
8010770d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107710:	e9 dc 00 00 00       	jmp    801077f1 <allocuvm+0x103>

  a = PGROUNDUP(oldsz);
80107715:	8b 45 0c             	mov    0xc(%ebp),%eax
80107718:	05 ff 0f 00 00       	add    $0xfff,%eax
8010771d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107722:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80107725:	e9 b8 00 00 00       	jmp    801077e2 <allocuvm+0xf4>
    mem = kalloc();
8010772a:	e8 79 b0 ff ff       	call   801027a8 <kalloc>
8010772f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80107732:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107736:	75 2e                	jne    80107766 <allocuvm+0x78>
      cprintf("allocuvm out of memory\n");
80107738:	83 ec 0c             	sub    $0xc,%esp
8010773b:	68 29 a6 10 80       	push   $0x8010a629
80107740:	e8 af 8c ff ff       	call   801003f4 <cprintf>
80107745:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80107748:	83 ec 04             	sub    $0x4,%esp
8010774b:	ff 75 0c             	push   0xc(%ebp)
8010774e:	ff 75 10             	push   0x10(%ebp)
80107751:	ff 75 08             	push   0x8(%ebp)
80107754:	e8 9a 00 00 00       	call   801077f3 <deallocuvm>
80107759:	83 c4 10             	add    $0x10,%esp
      return 0;
8010775c:	b8 00 00 00 00       	mov    $0x0,%eax
80107761:	e9 8b 00 00 00       	jmp    801077f1 <allocuvm+0x103>
    }
    memset(mem, 0, PGSIZE);
80107766:	83 ec 04             	sub    $0x4,%esp
80107769:	68 00 10 00 00       	push   $0x1000
8010776e:	6a 00                	push   $0x0
80107770:	ff 75 f0             	push   -0x10(%ebp)
80107773:	e8 14 d2 ff ff       	call   8010498c <memset>
80107778:	83 c4 10             	add    $0x10,%esp
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010777b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010777e:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80107784:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107787:	83 ec 0c             	sub    $0xc,%esp
8010778a:	6a 06                	push   $0x6
8010778c:	52                   	push   %edx
8010778d:	68 00 10 00 00       	push   $0x1000
80107792:	50                   	push   %eax
80107793:	ff 75 08             	push   0x8(%ebp)
80107796:	e8 c9 fa ff ff       	call   80107264 <mappages>
8010779b:	83 c4 20             	add    $0x20,%esp
8010779e:	85 c0                	test   %eax,%eax
801077a0:	79 39                	jns    801077db <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
801077a2:	83 ec 0c             	sub    $0xc,%esp
801077a5:	68 41 a6 10 80       	push   $0x8010a641
801077aa:	e8 45 8c ff ff       	call   801003f4 <cprintf>
801077af:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
801077b2:	83 ec 04             	sub    $0x4,%esp
801077b5:	ff 75 0c             	push   0xc(%ebp)
801077b8:	ff 75 10             	push   0x10(%ebp)
801077bb:	ff 75 08             	push   0x8(%ebp)
801077be:	e8 30 00 00 00       	call   801077f3 <deallocuvm>
801077c3:	83 c4 10             	add    $0x10,%esp
      kfree(mem);
801077c6:	83 ec 0c             	sub    $0xc,%esp
801077c9:	ff 75 f0             	push   -0x10(%ebp)
801077cc:	e8 3d af ff ff       	call   8010270e <kfree>
801077d1:	83 c4 10             	add    $0x10,%esp
      return 0;
801077d4:	b8 00 00 00 00       	mov    $0x0,%eax
801077d9:	eb 16                	jmp    801077f1 <allocuvm+0x103>
  for(; a < newsz; a += PGSIZE){
801077db:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801077e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801077e5:	3b 45 10             	cmp    0x10(%ebp),%eax
801077e8:	0f 82 3c ff ff ff    	jb     8010772a <allocuvm+0x3c>
    }
  }
  return newsz;
801077ee:	8b 45 10             	mov    0x10(%ebp),%eax
}
801077f1:	c9                   	leave
801077f2:	c3                   	ret

801077f3 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801077f3:	55                   	push   %ebp
801077f4:	89 e5                	mov    %esp,%ebp
801077f6:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801077f9:	8b 45 10             	mov    0x10(%ebp),%eax
801077fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
801077ff:	72 08                	jb     80107809 <deallocuvm+0x16>
    return oldsz;
80107801:	8b 45 0c             	mov    0xc(%ebp),%eax
80107804:	e9 ac 00 00 00       	jmp    801078b5 <deallocuvm+0xc2>

  a = PGROUNDUP(newsz);
80107809:	8b 45 10             	mov    0x10(%ebp),%eax
8010780c:	05 ff 0f 00 00       	add    $0xfff,%eax
80107811:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107816:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107819:	e9 88 00 00 00       	jmp    801078a6 <deallocuvm+0xb3>
    pte = walkpgdir(pgdir, (char*)a, 0);
8010781e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107821:	83 ec 04             	sub    $0x4,%esp
80107824:	6a 00                	push   $0x0
80107826:	50                   	push   %eax
80107827:	ff 75 08             	push   0x8(%ebp)
8010782a:	e8 9f f9 ff ff       	call   801071ce <walkpgdir>
8010782f:	83 c4 10             	add    $0x10,%esp
80107832:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80107835:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107839:	75 16                	jne    80107851 <deallocuvm+0x5e>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010783b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010783e:	c1 e8 16             	shr    $0x16,%eax
80107841:	83 c0 01             	add    $0x1,%eax
80107844:	c1 e0 16             	shl    $0x16,%eax
80107847:	2d 00 10 00 00       	sub    $0x1000,%eax
8010784c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010784f:	eb 4e                	jmp    8010789f <deallocuvm+0xac>
    else if((*pte & PTE_P) != 0){
80107851:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107854:	8b 00                	mov    (%eax),%eax
80107856:	83 e0 01             	and    $0x1,%eax
80107859:	85 c0                	test   %eax,%eax
8010785b:	74 42                	je     8010789f <deallocuvm+0xac>
      pa = PTE_ADDR(*pte);
8010785d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107860:	8b 00                	mov    (%eax),%eax
80107862:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107867:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
8010786a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
8010786e:	75 0d                	jne    8010787d <deallocuvm+0x8a>
        panic("kfree");
80107870:	83 ec 0c             	sub    $0xc,%esp
80107873:	68 5d a6 10 80       	push   $0x8010a65d
80107878:	e8 2c 8d ff ff       	call   801005a9 <panic>
      char *v = P2V(pa);
8010787d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107880:	05 00 00 00 80       	add    $0x80000000,%eax
80107885:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80107888:	83 ec 0c             	sub    $0xc,%esp
8010788b:	ff 75 e8             	push   -0x18(%ebp)
8010788e:	e8 7b ae ff ff       	call   8010270e <kfree>
80107893:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80107896:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107899:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; a  < oldsz; a += PGSIZE){
8010789f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801078a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078a9:	3b 45 0c             	cmp    0xc(%ebp),%eax
801078ac:	0f 82 6c ff ff ff    	jb     8010781e <deallocuvm+0x2b>
    }
  }
  return newsz;
801078b2:	8b 45 10             	mov    0x10(%ebp),%eax
}
801078b5:	c9                   	leave
801078b6:	c3                   	ret

801078b7 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801078b7:	55                   	push   %ebp
801078b8:	89 e5                	mov    %esp,%ebp
801078ba:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
801078bd:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801078c1:	75 0d                	jne    801078d0 <freevm+0x19>
    panic("freevm: no pgdir");
801078c3:	83 ec 0c             	sub    $0xc,%esp
801078c6:	68 63 a6 10 80       	push   $0x8010a663
801078cb:	e8 d9 8c ff ff       	call   801005a9 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
801078d0:	83 ec 04             	sub    $0x4,%esp
801078d3:	6a 00                	push   $0x0
801078d5:	68 00 00 00 80       	push   $0x80000000
801078da:	ff 75 08             	push   0x8(%ebp)
801078dd:	e8 11 ff ff ff       	call   801077f3 <deallocuvm>
801078e2:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801078e5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801078ec:	eb 48                	jmp    80107936 <freevm+0x7f>
    if(pgdir[i] & PTE_P){
801078ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801078f1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801078f8:	8b 45 08             	mov    0x8(%ebp),%eax
801078fb:	01 d0                	add    %edx,%eax
801078fd:	8b 00                	mov    (%eax),%eax
801078ff:	83 e0 01             	and    $0x1,%eax
80107902:	85 c0                	test   %eax,%eax
80107904:	74 2c                	je     80107932 <freevm+0x7b>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107906:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107909:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107910:	8b 45 08             	mov    0x8(%ebp),%eax
80107913:	01 d0                	add    %edx,%eax
80107915:	8b 00                	mov    (%eax),%eax
80107917:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010791c:	05 00 00 00 80       	add    $0x80000000,%eax
80107921:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80107924:	83 ec 0c             	sub    $0xc,%esp
80107927:	ff 75 f0             	push   -0x10(%ebp)
8010792a:	e8 df ad ff ff       	call   8010270e <kfree>
8010792f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107932:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107936:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
8010793d:	76 af                	jbe    801078ee <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010793f:	83 ec 0c             	sub    $0xc,%esp
80107942:	ff 75 08             	push   0x8(%ebp)
80107945:	e8 c4 ad ff ff       	call   8010270e <kfree>
8010794a:	83 c4 10             	add    $0x10,%esp
}
8010794d:	90                   	nop
8010794e:	c9                   	leave
8010794f:	c3                   	ret

80107950 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107950:	55                   	push   %ebp
80107951:	89 e5                	mov    %esp,%ebp
80107953:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107956:	83 ec 04             	sub    $0x4,%esp
80107959:	6a 00                	push   $0x0
8010795b:	ff 75 0c             	push   0xc(%ebp)
8010795e:	ff 75 08             	push   0x8(%ebp)
80107961:	e8 68 f8 ff ff       	call   801071ce <walkpgdir>
80107966:	83 c4 10             	add    $0x10,%esp
80107969:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010796c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107970:	75 0d                	jne    8010797f <clearpteu+0x2f>
    panic("clearpteu");
80107972:	83 ec 0c             	sub    $0xc,%esp
80107975:	68 74 a6 10 80       	push   $0x8010a674
8010797a:	e8 2a 8c ff ff       	call   801005a9 <panic>
  *pte &= ~PTE_U;
8010797f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107982:	8b 00                	mov    (%eax),%eax
80107984:	83 e0 fb             	and    $0xfffffffb,%eax
80107987:	89 c2                	mov    %eax,%edx
80107989:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010798c:	89 10                	mov    %edx,(%eax)
}
8010798e:	90                   	nop
8010798f:	c9                   	leave
80107990:	c3                   	ret

80107991 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107991:	55                   	push   %ebp
80107992:	89 e5                	mov    %esp,%ebp
80107994:	83 ec 28             	sub    $0x28,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80107997:	e8 58 f9 ff ff       	call   801072f4 <setupkvm>
8010799c:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010799f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801079a3:	75 0a                	jne    801079af <copyuvm+0x1e>
    return 0;
801079a5:	b8 00 00 00 00       	mov    $0x0,%eax
801079aa:	e9 eb 00 00 00       	jmp    80107a9a <copyuvm+0x109>
  for(i = 0; i < sz; i += PGSIZE){
801079af:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801079b6:	e9 b7 00 00 00       	jmp    80107a72 <copyuvm+0xe1>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801079bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079be:	83 ec 04             	sub    $0x4,%esp
801079c1:	6a 00                	push   $0x0
801079c3:	50                   	push   %eax
801079c4:	ff 75 08             	push   0x8(%ebp)
801079c7:	e8 02 f8 ff ff       	call   801071ce <walkpgdir>
801079cc:	83 c4 10             	add    $0x10,%esp
801079cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
801079d2:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801079d6:	75 0d                	jne    801079e5 <copyuvm+0x54>
      panic("copyuvm: pte should exist");
801079d8:	83 ec 0c             	sub    $0xc,%esp
801079db:	68 7e a6 10 80       	push   $0x8010a67e
801079e0:	e8 c4 8b ff ff       	call   801005a9 <panic>
    if(!(*pte & PTE_P))
801079e5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801079e8:	8b 00                	mov    (%eax),%eax
801079ea:	83 e0 01             	and    $0x1,%eax
801079ed:	85 c0                	test   %eax,%eax
801079ef:	75 0d                	jne    801079fe <copyuvm+0x6d>
      panic("copyuvm: page not present");
801079f1:	83 ec 0c             	sub    $0xc,%esp
801079f4:	68 98 a6 10 80       	push   $0x8010a698
801079f9:	e8 ab 8b ff ff       	call   801005a9 <panic>
    pa = PTE_ADDR(*pte);
801079fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a01:	8b 00                	mov    (%eax),%eax
80107a03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107a08:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80107a0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107a0e:	8b 00                	mov    (%eax),%eax
80107a10:	25 ff 0f 00 00       	and    $0xfff,%eax
80107a15:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80107a18:	e8 8b ad ff ff       	call   801027a8 <kalloc>
80107a1d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107a20:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80107a24:	74 5d                	je     80107a83 <copyuvm+0xf2>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80107a26:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107a29:	05 00 00 00 80       	add    $0x80000000,%eax
80107a2e:	83 ec 04             	sub    $0x4,%esp
80107a31:	68 00 10 00 00       	push   $0x1000
80107a36:	50                   	push   %eax
80107a37:	ff 75 e0             	push   -0x20(%ebp)
80107a3a:	e8 0c d0 ff ff       	call   80104a4b <memmove>
80107a3f:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0)
80107a42:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107a45:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107a48:	8d 88 00 00 00 80    	lea    -0x80000000(%eax),%ecx
80107a4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a51:	83 ec 0c             	sub    $0xc,%esp
80107a54:	52                   	push   %edx
80107a55:	51                   	push   %ecx
80107a56:	68 00 10 00 00       	push   $0x1000
80107a5b:	50                   	push   %eax
80107a5c:	ff 75 f0             	push   -0x10(%ebp)
80107a5f:	e8 00 f8 ff ff       	call   80107264 <mappages>
80107a64:	83 c4 20             	add    $0x20,%esp
80107a67:	85 c0                	test   %eax,%eax
80107a69:	78 1b                	js     80107a86 <copyuvm+0xf5>
  for(i = 0; i < sz; i += PGSIZE){
80107a6b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80107a72:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a75:	3b 45 0c             	cmp    0xc(%ebp),%eax
80107a78:	0f 82 3d ff ff ff    	jb     801079bb <copyuvm+0x2a>
      goto bad;
  }
  return d;
80107a7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107a81:	eb 17                	jmp    80107a9a <copyuvm+0x109>
      goto bad;
80107a83:	90                   	nop
80107a84:	eb 01                	jmp    80107a87 <copyuvm+0xf6>
      goto bad;
80107a86:	90                   	nop

bad:
  freevm(d);
80107a87:	83 ec 0c             	sub    $0xc,%esp
80107a8a:	ff 75 f0             	push   -0x10(%ebp)
80107a8d:	e8 25 fe ff ff       	call   801078b7 <freevm>
80107a92:	83 c4 10             	add    $0x10,%esp
  return 0;
80107a95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107a9a:	c9                   	leave
80107a9b:	c3                   	ret

80107a9c <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a9c:	55                   	push   %ebp
80107a9d:	89 e5                	mov    %esp,%ebp
80107a9f:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107aa2:	83 ec 04             	sub    $0x4,%esp
80107aa5:	6a 00                	push   $0x0
80107aa7:	ff 75 0c             	push   0xc(%ebp)
80107aaa:	ff 75 08             	push   0x8(%ebp)
80107aad:	e8 1c f7 ff ff       	call   801071ce <walkpgdir>
80107ab2:	83 c4 10             	add    $0x10,%esp
80107ab5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80107ab8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107abb:	8b 00                	mov    (%eax),%eax
80107abd:	83 e0 01             	and    $0x1,%eax
80107ac0:	85 c0                	test   %eax,%eax
80107ac2:	75 07                	jne    80107acb <uva2ka+0x2f>
    return 0;
80107ac4:	b8 00 00 00 00       	mov    $0x0,%eax
80107ac9:	eb 22                	jmp    80107aed <uva2ka+0x51>
  if((*pte & PTE_U) == 0)
80107acb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ace:	8b 00                	mov    (%eax),%eax
80107ad0:	83 e0 04             	and    $0x4,%eax
80107ad3:	85 c0                	test   %eax,%eax
80107ad5:	75 07                	jne    80107ade <uva2ka+0x42>
    return 0;
80107ad7:	b8 00 00 00 00       	mov    $0x0,%eax
80107adc:	eb 0f                	jmp    80107aed <uva2ka+0x51>
  return (char*)P2V(PTE_ADDR(*pte));
80107ade:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ae1:	8b 00                	mov    (%eax),%eax
80107ae3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ae8:	05 00 00 00 80       	add    $0x80000000,%eax
}
80107aed:	c9                   	leave
80107aee:	c3                   	ret

80107aef <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107aef:	55                   	push   %ebp
80107af0:	89 e5                	mov    %esp,%ebp
80107af2:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80107af5:	8b 45 10             	mov    0x10(%ebp),%eax
80107af8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80107afb:	eb 7f                	jmp    80107b7c <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80107afd:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b00:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107b05:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80107b08:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b0b:	83 ec 08             	sub    $0x8,%esp
80107b0e:	50                   	push   %eax
80107b0f:	ff 75 08             	push   0x8(%ebp)
80107b12:	e8 85 ff ff ff       	call   80107a9c <uva2ka>
80107b17:	83 c4 10             	add    $0x10,%esp
80107b1a:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80107b1d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80107b21:	75 07                	jne    80107b2a <copyout+0x3b>
      return -1;
80107b23:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107b28:	eb 61                	jmp    80107b8b <copyout+0x9c>
    n = PGSIZE - (va - va0);
80107b2a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b2d:	2b 45 0c             	sub    0xc(%ebp),%eax
80107b30:	05 00 10 00 00       	add    $0x1000,%eax
80107b35:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80107b38:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b3b:	39 45 14             	cmp    %eax,0x14(%ebp)
80107b3e:	73 06                	jae    80107b46 <copyout+0x57>
      n = len;
80107b40:	8b 45 14             	mov    0x14(%ebp),%eax
80107b43:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80107b46:	8b 45 0c             	mov    0xc(%ebp),%eax
80107b49:	2b 45 ec             	sub    -0x14(%ebp),%eax
80107b4c:	89 c2                	mov    %eax,%edx
80107b4e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107b51:	01 d0                	add    %edx,%eax
80107b53:	83 ec 04             	sub    $0x4,%esp
80107b56:	ff 75 f0             	push   -0x10(%ebp)
80107b59:	ff 75 f4             	push   -0xc(%ebp)
80107b5c:	50                   	push   %eax
80107b5d:	e8 e9 ce ff ff       	call   80104a4b <memmove>
80107b62:	83 c4 10             	add    $0x10,%esp
    len -= n;
80107b65:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b68:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80107b6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107b6e:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80107b71:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107b74:	05 00 10 00 00       	add    $0x1000,%eax
80107b79:	89 45 0c             	mov    %eax,0xc(%ebp)
  while(len > 0){
80107b7c:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80107b80:	0f 85 77 ff ff ff    	jne    80107afd <copyout+0xe>
  }
  return 0;
80107b86:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107b8b:	c9                   	leave
80107b8c:	c3                   	ret

80107b8d <mpinit_uefi>:

struct cpu cpus[NCPU];
int ncpu;
uchar ioapicid;
void mpinit_uefi(void)
{
80107b8d:	55                   	push   %ebp
80107b8e:	89 e5                	mov    %esp,%ebp
80107b90:	83 ec 20             	sub    $0x20,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107b93:	c7 45 f8 00 00 05 80 	movl   $0x80050000,-0x8(%ebp)
  struct uefi_madt *madt = (struct uefi_madt*)(P2V_WO(boot_param->madt_addr));
80107b9a:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107b9d:	8b 40 08             	mov    0x8(%eax),%eax
80107ba0:	05 00 00 00 80       	add    $0x80000000,%eax
80107ba5:	89 45 f4             	mov    %eax,-0xc(%ebp)

  uint i=sizeof(struct uefi_madt);
80107ba8:	c7 45 fc 2c 00 00 00 	movl   $0x2c,-0x4(%ebp)
  struct uefi_lapic *lapic_entry;
  struct uefi_ioapic *ioapic;
  struct uefi_iso *iso;
  struct uefi_non_maskable_intr *non_mask_intr; 
  
  lapic = (uint *)(madt->lapic_addr);
80107baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb2:	8b 40 24             	mov    0x24(%eax),%eax
80107bb5:	a3 00 41 19 80       	mov    %eax,0x80194100
  ncpu = 0;
80107bba:	c7 05 40 6d 19 80 00 	movl   $0x0,0x80196d40
80107bc1:	00 00 00 

  while(i<madt->len){
80107bc4:	e9 bd 00 00 00       	jmp    80107c86 <mpinit_uefi+0xf9>
    uchar *entry_type = ((uchar *)madt)+i;
80107bc9:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107bcc:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107bcf:	01 d0                	add    %edx,%eax
80107bd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    switch(*entry_type){
80107bd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bd7:	0f b6 00             	movzbl (%eax),%eax
80107bda:	0f b6 c0             	movzbl %al,%eax
80107bdd:	83 f8 05             	cmp    $0x5,%eax
80107be0:	0f 87 a0 00 00 00    	ja     80107c86 <mpinit_uefi+0xf9>
80107be6:	8b 04 85 b4 a6 10 80 	mov    -0x7fef594c(,%eax,4),%eax
80107bed:	ff e0                	jmp    *%eax
      case 0:
        lapic_entry = (struct uefi_lapic *)entry_type;
80107bef:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107bf2:	89 45 e0             	mov    %eax,-0x20(%ebp)
        if(ncpu < NCPU) {
80107bf5:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107bfa:	83 f8 03             	cmp    $0x3,%eax
80107bfd:	7f 28                	jg     80107c27 <mpinit_uefi+0x9a>
          cpus[ncpu].apicid = lapic_entry->lapic_id;
80107bff:	8b 15 40 6d 19 80    	mov    0x80196d40,%edx
80107c05:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c08:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80107c0c:	69 d2 b0 00 00 00    	imul   $0xb0,%edx,%edx
80107c12:	81 c2 80 6a 19 80    	add    $0x80196a80,%edx
80107c18:	88 02                	mov    %al,(%edx)
          ncpu++;
80107c1a:	a1 40 6d 19 80       	mov    0x80196d40,%eax
80107c1f:	83 c0 01             	add    $0x1,%eax
80107c22:	a3 40 6d 19 80       	mov    %eax,0x80196d40
        }
        i += lapic_entry->record_len;
80107c27:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107c2a:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c2e:	0f b6 c0             	movzbl %al,%eax
80107c31:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c34:	eb 50                	jmp    80107c86 <mpinit_uefi+0xf9>

      case 1:
        ioapic = (struct uefi_ioapic *)entry_type;
80107c36:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c39:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        ioapicid = ioapic->ioapic_id;
80107c3c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c3f:	0f b6 40 02          	movzbl 0x2(%eax),%eax
80107c43:	a2 44 6d 19 80       	mov    %al,0x80196d44
        i += ioapic->record_len;
80107c48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107c4b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c4f:	0f b6 c0             	movzbl %al,%eax
80107c52:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c55:	eb 2f                	jmp    80107c86 <mpinit_uefi+0xf9>

      case 2:
        iso = (struct uefi_iso *)entry_type;
80107c57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c5a:	89 45 e8             	mov    %eax,-0x18(%ebp)
        i += iso->record_len;
80107c5d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80107c60:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c64:	0f b6 c0             	movzbl %al,%eax
80107c67:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c6a:	eb 1a                	jmp    80107c86 <mpinit_uefi+0xf9>

      case 4:
        non_mask_intr = (struct uefi_non_maskable_intr *)entry_type;
80107c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107c6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
        i += non_mask_intr->record_len;
80107c72:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107c75:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80107c79:	0f b6 c0             	movzbl %al,%eax
80107c7c:	01 45 fc             	add    %eax,-0x4(%ebp)
        break;
80107c7f:	eb 05                	jmp    80107c86 <mpinit_uefi+0xf9>

      case 5:
        i = i + 0xC;
80107c81:	83 45 fc 0c          	addl   $0xc,-0x4(%ebp)
        break;
80107c85:	90                   	nop
  while(i<madt->len){
80107c86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c89:	8b 40 04             	mov    0x4(%eax),%eax
80107c8c:	39 45 fc             	cmp    %eax,-0x4(%ebp)
80107c8f:	0f 82 34 ff ff ff    	jb     80107bc9 <mpinit_uefi+0x3c>
    }
  }

}
80107c95:	90                   	nop
80107c96:	90                   	nop
80107c97:	c9                   	leave
80107c98:	c3                   	ret

80107c99 <inb>:
{
80107c99:	55                   	push   %ebp
80107c9a:	89 e5                	mov    %esp,%ebp
80107c9c:	83 ec 14             	sub    $0x14,%esp
80107c9f:	8b 45 08             	mov    0x8(%ebp),%eax
80107ca2:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80107ca6:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80107caa:	89 c2                	mov    %eax,%edx
80107cac:	ec                   	in     (%dx),%al
80107cad:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80107cb0:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80107cb4:	c9                   	leave
80107cb5:	c3                   	ret

80107cb6 <outb>:
{
80107cb6:	55                   	push   %ebp
80107cb7:	89 e5                	mov    %esp,%ebp
80107cb9:	83 ec 08             	sub    $0x8,%esp
80107cbc:	8b 55 08             	mov    0x8(%ebp),%edx
80107cbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107cc2:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80107cc6:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80107cc9:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80107ccd:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80107cd1:	ee                   	out    %al,(%dx)
}
80107cd2:	90                   	nop
80107cd3:	c9                   	leave
80107cd4:	c3                   	ret

80107cd5 <uart_debug>:
#include "proc.h"
#include "x86.h"

#define COM1    0x3f8

void uart_debug(char p){
80107cd5:	55                   	push   %ebp
80107cd6:	89 e5                	mov    %esp,%ebp
80107cd8:	83 ec 28             	sub    $0x28,%esp
80107cdb:	8b 45 08             	mov    0x8(%ebp),%eax
80107cde:	88 45 e4             	mov    %al,-0x1c(%ebp)
    // Turn off the FIFO
  outb(COM1+2, 0);
80107ce1:	6a 00                	push   $0x0
80107ce3:	68 fa 03 00 00       	push   $0x3fa
80107ce8:	e8 c9 ff ff ff       	call   80107cb6 <outb>
80107ced:	83 c4 08             	add    $0x8,%esp

  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80107cf0:	68 80 00 00 00       	push   $0x80
80107cf5:	68 fb 03 00 00       	push   $0x3fb
80107cfa:	e8 b7 ff ff ff       	call   80107cb6 <outb>
80107cff:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107d02:	6a 0c                	push   $0xc
80107d04:	68 f8 03 00 00       	push   $0x3f8
80107d09:	e8 a8 ff ff ff       	call   80107cb6 <outb>
80107d0e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107d11:	6a 00                	push   $0x0
80107d13:	68 f9 03 00 00       	push   $0x3f9
80107d18:	e8 99 ff ff ff       	call   80107cb6 <outb>
80107d1d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107d20:	6a 03                	push   $0x3
80107d22:	68 fb 03 00 00       	push   $0x3fb
80107d27:	e8 8a ff ff ff       	call   80107cb6 <outb>
80107d2c:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107d2f:	6a 00                	push   $0x0
80107d31:	68 fc 03 00 00       	push   $0x3fc
80107d36:	e8 7b ff ff ff       	call   80107cb6 <outb>
80107d3b:	83 c4 08             	add    $0x8,%esp

  for(int i=0;i<128 && !(inb(COM1+5) & 0x20); i++) microdelay(10);
80107d3e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107d45:	eb 11                	jmp    80107d58 <uart_debug+0x83>
80107d47:	83 ec 0c             	sub    $0xc,%esp
80107d4a:	6a 0a                	push   $0xa
80107d4c:	e8 e8 ad ff ff       	call   80102b39 <microdelay>
80107d51:	83 c4 10             	add    $0x10,%esp
80107d54:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107d58:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80107d5c:	7f 1a                	jg     80107d78 <uart_debug+0xa3>
80107d5e:	83 ec 0c             	sub    $0xc,%esp
80107d61:	68 fd 03 00 00       	push   $0x3fd
80107d66:	e8 2e ff ff ff       	call   80107c99 <inb>
80107d6b:	83 c4 10             	add    $0x10,%esp
80107d6e:	0f b6 c0             	movzbl %al,%eax
80107d71:	83 e0 20             	and    $0x20,%eax
80107d74:	85 c0                	test   %eax,%eax
80107d76:	74 cf                	je     80107d47 <uart_debug+0x72>
  outb(COM1+0, p);
80107d78:	0f b6 45 e4          	movzbl -0x1c(%ebp),%eax
80107d7c:	0f b6 c0             	movzbl %al,%eax
80107d7f:	83 ec 08             	sub    $0x8,%esp
80107d82:	50                   	push   %eax
80107d83:	68 f8 03 00 00       	push   $0x3f8
80107d88:	e8 29 ff ff ff       	call   80107cb6 <outb>
80107d8d:	83 c4 10             	add    $0x10,%esp
}
80107d90:	90                   	nop
80107d91:	c9                   	leave
80107d92:	c3                   	ret

80107d93 <uart_debugs>:

void uart_debugs(char *p){
80107d93:	55                   	push   %ebp
80107d94:	89 e5                	mov    %esp,%ebp
80107d96:	83 ec 08             	sub    $0x8,%esp
  while(*p){
80107d99:	eb 1b                	jmp    80107db6 <uart_debugs+0x23>
    uart_debug(*p++);
80107d9b:	8b 45 08             	mov    0x8(%ebp),%eax
80107d9e:	8d 50 01             	lea    0x1(%eax),%edx
80107da1:	89 55 08             	mov    %edx,0x8(%ebp)
80107da4:	0f b6 00             	movzbl (%eax),%eax
80107da7:	0f be c0             	movsbl %al,%eax
80107daa:	83 ec 0c             	sub    $0xc,%esp
80107dad:	50                   	push   %eax
80107dae:	e8 22 ff ff ff       	call   80107cd5 <uart_debug>
80107db3:	83 c4 10             	add    $0x10,%esp
  while(*p){
80107db6:	8b 45 08             	mov    0x8(%ebp),%eax
80107db9:	0f b6 00             	movzbl (%eax),%eax
80107dbc:	84 c0                	test   %al,%al
80107dbe:	75 db                	jne    80107d9b <uart_debugs+0x8>
  }
}
80107dc0:	90                   	nop
80107dc1:	90                   	nop
80107dc2:	c9                   	leave
80107dc3:	c3                   	ret

80107dc4 <graphic_init>:
 * i%4 = 2 : red
 * i%4 = 3 : black
 */

struct gpu gpu;
void graphic_init(){
80107dc4:	55                   	push   %ebp
80107dc5:	89 e5                	mov    %esp,%ebp
80107dc7:	83 ec 10             	sub    $0x10,%esp
  struct boot_param *boot_param = (struct boot_param *)P2V_WO(BOOTPARAM);
80107dca:	c7 45 fc 00 00 05 80 	movl   $0x80050000,-0x4(%ebp)
  gpu.pvram_addr = boot_param->graphic_config.frame_base;
80107dd1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107dd4:	8b 50 14             	mov    0x14(%eax),%edx
80107dd7:	8b 40 10             	mov    0x10(%eax),%eax
80107dda:	a3 48 6d 19 80       	mov    %eax,0x80196d48
  gpu.vram_size = boot_param->graphic_config.frame_size;
80107ddf:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107de2:	8b 50 1c             	mov    0x1c(%eax),%edx
80107de5:	8b 40 18             	mov    0x18(%eax),%eax
80107de8:	a3 50 6d 19 80       	mov    %eax,0x80196d50
  gpu.vvram_addr = DEVSPACE - gpu.vram_size;
80107ded:	a1 50 6d 19 80       	mov    0x80196d50,%eax
80107df2:	ba 00 00 00 fe       	mov    $0xfe000000,%edx
80107df7:	29 c2                	sub    %eax,%edx
80107df9:	89 15 4c 6d 19 80    	mov    %edx,0x80196d4c
  gpu.horizontal_resolution = (uint)(boot_param->graphic_config.horizontal_resolution & 0xFFFFFFFF);
80107dff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e02:	8b 50 24             	mov    0x24(%eax),%edx
80107e05:	8b 40 20             	mov    0x20(%eax),%eax
80107e08:	a3 54 6d 19 80       	mov    %eax,0x80196d54
  gpu.vertical_resolution = (uint)(boot_param->graphic_config.vertical_resolution & 0xFFFFFFFF);
80107e0d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e10:	8b 50 2c             	mov    0x2c(%eax),%edx
80107e13:	8b 40 28             	mov    0x28(%eax),%eax
80107e16:	a3 58 6d 19 80       	mov    %eax,0x80196d58
  gpu.pixels_per_line = (uint)(boot_param->graphic_config.pixels_per_line & 0xFFFFFFFF);
80107e1b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e1e:	8b 50 34             	mov    0x34(%eax),%edx
80107e21:	8b 40 30             	mov    0x30(%eax),%eax
80107e24:	a3 5c 6d 19 80       	mov    %eax,0x80196d5c
}
80107e29:	90                   	nop
80107e2a:	c9                   	leave
80107e2b:	c3                   	ret

80107e2c <graphic_draw_pixel>:

void graphic_draw_pixel(int x,int y,struct graphic_pixel * buffer){
80107e2c:	55                   	push   %ebp
80107e2d:	89 e5                	mov    %esp,%ebp
80107e2f:	83 ec 10             	sub    $0x10,%esp
  int pixel_addr = (sizeof(struct graphic_pixel))*(y*gpu.pixels_per_line + x);
80107e32:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107e38:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e3b:	0f af d0             	imul   %eax,%edx
80107e3e:	8b 45 08             	mov    0x8(%ebp),%eax
80107e41:	01 d0                	add    %edx,%eax
80107e43:	c1 e0 02             	shl    $0x2,%eax
80107e46:	89 45 fc             	mov    %eax,-0x4(%ebp)
  struct graphic_pixel *pixel = (struct graphic_pixel *)(gpu.vvram_addr + pixel_addr);
80107e49:	8b 15 4c 6d 19 80    	mov    0x80196d4c,%edx
80107e4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80107e52:	01 d0                	add    %edx,%eax
80107e54:	89 45 f8             	mov    %eax,-0x8(%ebp)
  pixel->blue = buffer->blue;
80107e57:	8b 45 10             	mov    0x10(%ebp),%eax
80107e5a:	0f b6 10             	movzbl (%eax),%edx
80107e5d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e60:	88 10                	mov    %dl,(%eax)
  pixel->green = buffer->green;
80107e62:	8b 45 10             	mov    0x10(%ebp),%eax
80107e65:	0f b6 50 01          	movzbl 0x1(%eax),%edx
80107e69:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e6c:	88 50 01             	mov    %dl,0x1(%eax)
  pixel->red = buffer->red;
80107e6f:	8b 45 10             	mov    0x10(%ebp),%eax
80107e72:	0f b6 50 02          	movzbl 0x2(%eax),%edx
80107e76:	8b 45 f8             	mov    -0x8(%ebp),%eax
80107e79:	88 50 02             	mov    %dl,0x2(%eax)
}
80107e7c:	90                   	nop
80107e7d:	c9                   	leave
80107e7e:	c3                   	ret

80107e7f <graphic_scroll_up>:

void graphic_scroll_up(int height){
80107e7f:	55                   	push   %ebp
80107e80:	89 e5                	mov    %esp,%ebp
80107e82:	83 ec 18             	sub    $0x18,%esp
  int addr_diff = (sizeof(struct graphic_pixel))*gpu.pixels_per_line*height;
80107e85:	8b 15 5c 6d 19 80    	mov    0x80196d5c,%edx
80107e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80107e8e:	0f af c2             	imul   %edx,%eax
80107e91:	c1 e0 02             	shl    $0x2,%eax
80107e94:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove((unsigned int *)gpu.vvram_addr,(unsigned int *)(gpu.vvram_addr + addr_diff),gpu.vram_size - addr_diff);
80107e97:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107e9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ea0:	29 c2                	sub    %eax,%edx
80107ea2:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107eab:	01 c8                	add    %ecx,%eax
80107ead:	89 c1                	mov    %eax,%ecx
80107eaf:	a1 4c 6d 19 80       	mov    0x80196d4c,%eax
80107eb4:	83 ec 04             	sub    $0x4,%esp
80107eb7:	52                   	push   %edx
80107eb8:	51                   	push   %ecx
80107eb9:	50                   	push   %eax
80107eba:	e8 8c cb ff ff       	call   80104a4b <memmove>
80107ebf:	83 c4 10             	add    $0x10,%esp
  memset((unsigned int *)(gpu.vvram_addr + gpu.vram_size - addr_diff),0,addr_diff);
80107ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec5:	8b 0d 4c 6d 19 80    	mov    0x80196d4c,%ecx
80107ecb:	8b 15 50 6d 19 80    	mov    0x80196d50,%edx
80107ed1:	01 d1                	add    %edx,%ecx
80107ed3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107ed6:	29 d1                	sub    %edx,%ecx
80107ed8:	89 ca                	mov    %ecx,%edx
80107eda:	83 ec 04             	sub    $0x4,%esp
80107edd:	50                   	push   %eax
80107ede:	6a 00                	push   $0x0
80107ee0:	52                   	push   %edx
80107ee1:	e8 a6 ca ff ff       	call   8010498c <memset>
80107ee6:	83 c4 10             	add    $0x10,%esp
}
80107ee9:	90                   	nop
80107eea:	c9                   	leave
80107eeb:	c3                   	ret

80107eec <font_render>:
#include "font.h"


struct graphic_pixel black_pixel = {0x0,0x0,0x0,0x0};
struct graphic_pixel white_pixel = {0xFF,0xFF,0xFF,0x0};
void font_render(int x,int y,int index){
80107eec:	55                   	push   %ebp
80107eed:	89 e5                	mov    %esp,%ebp
80107eef:	53                   	push   %ebx
80107ef0:	83 ec 14             	sub    $0x14,%esp
  int bin;
  for(int i=0;i<30;i++){
80107ef3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80107efa:	e9 b1 00 00 00       	jmp    80107fb0 <font_render+0xc4>
    for(int j=14;j>-1;j--){
80107eff:	c7 45 f0 0e 00 00 00 	movl   $0xe,-0x10(%ebp)
80107f06:	e9 97 00 00 00       	jmp    80107fa2 <font_render+0xb6>
      bin = (font_bin[index-0x20][i])&(1 << j);
80107f0b:	8b 45 10             	mov    0x10(%ebp),%eax
80107f0e:	83 e8 20             	sub    $0x20,%eax
80107f11:	6b d0 1e             	imul   $0x1e,%eax,%edx
80107f14:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f17:	01 d0                	add    %edx,%eax
80107f19:	0f b7 84 00 e0 a6 10 	movzwl -0x7fef5920(%eax,%eax,1),%eax
80107f20:	80 
80107f21:	0f b7 d0             	movzwl %ax,%edx
80107f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f27:	bb 01 00 00 00       	mov    $0x1,%ebx
80107f2c:	89 c1                	mov    %eax,%ecx
80107f2e:	d3 e3                	shl    %cl,%ebx
80107f30:	89 d8                	mov    %ebx,%eax
80107f32:	21 d0                	and    %edx,%eax
80107f34:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(bin == (1 << j)){
80107f37:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107f3a:	ba 01 00 00 00       	mov    $0x1,%edx
80107f3f:	89 c1                	mov    %eax,%ecx
80107f41:	d3 e2                	shl    %cl,%edx
80107f43:	89 d0                	mov    %edx,%eax
80107f45:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80107f48:	75 2b                	jne    80107f75 <font_render+0x89>
        graphic_draw_pixel(x+(14-j),y+i,&white_pixel);
80107f4a:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f50:	01 c2                	add    %eax,%edx
80107f52:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f57:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f5a:	89 c1                	mov    %eax,%ecx
80107f5c:	8b 45 08             	mov    0x8(%ebp),%eax
80107f5f:	01 c8                	add    %ecx,%eax
80107f61:	83 ec 04             	sub    $0x4,%esp
80107f64:	68 e0 f4 10 80       	push   $0x8010f4e0
80107f69:	52                   	push   %edx
80107f6a:	50                   	push   %eax
80107f6b:	e8 bc fe ff ff       	call   80107e2c <graphic_draw_pixel>
80107f70:	83 c4 10             	add    $0x10,%esp
80107f73:	eb 29                	jmp    80107f9e <font_render+0xb2>
      } else {
        graphic_draw_pixel(x+(14-j),y+i,&black_pixel);
80107f75:	8b 55 0c             	mov    0xc(%ebp),%edx
80107f78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f7b:	01 c2                	add    %eax,%edx
80107f7d:	b8 0e 00 00 00       	mov    $0xe,%eax
80107f82:	2b 45 f0             	sub    -0x10(%ebp),%eax
80107f85:	89 c1                	mov    %eax,%ecx
80107f87:	8b 45 08             	mov    0x8(%ebp),%eax
80107f8a:	01 c8                	add    %ecx,%eax
80107f8c:	83 ec 04             	sub    $0x4,%esp
80107f8f:	68 60 6d 19 80       	push   $0x80196d60
80107f94:	52                   	push   %edx
80107f95:	50                   	push   %eax
80107f96:	e8 91 fe ff ff       	call   80107e2c <graphic_draw_pixel>
80107f9b:	83 c4 10             	add    $0x10,%esp
    for(int j=14;j>-1;j--){
80107f9e:	83 6d f0 01          	subl   $0x1,-0x10(%ebp)
80107fa2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107fa6:	0f 89 5f ff ff ff    	jns    80107f0b <font_render+0x1f>
  for(int i=0;i<30;i++){
80107fac:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107fb0:	83 7d f4 1d          	cmpl   $0x1d,-0xc(%ebp)
80107fb4:	0f 8e 45 ff ff ff    	jle    80107eff <font_render+0x13>
      }
    }
  }
}
80107fba:	90                   	nop
80107fbb:	90                   	nop
80107fbc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107fbf:	c9                   	leave
80107fc0:	c3                   	ret

80107fc1 <font_render_string>:

void font_render_string(char *string,int row){
80107fc1:	55                   	push   %ebp
80107fc2:	89 e5                	mov    %esp,%ebp
80107fc4:	53                   	push   %ebx
80107fc5:	83 ec 14             	sub    $0x14,%esp
  int i = 0;
80107fc8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  while(string[i] && i < 52){
80107fcf:	eb 33                	jmp    80108004 <font_render_string+0x43>
    font_render(i*15+2,row*30,string[i]);
80107fd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fd4:	8b 45 08             	mov    0x8(%ebp),%eax
80107fd7:	01 d0                	add    %edx,%eax
80107fd9:	0f b6 00             	movzbl (%eax),%eax
80107fdc:	0f be d8             	movsbl %al,%ebx
80107fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
80107fe2:	6b c8 1e             	imul   $0x1e,%eax,%ecx
80107fe5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80107fe8:	89 d0                	mov    %edx,%eax
80107fea:	c1 e0 04             	shl    $0x4,%eax
80107fed:	29 d0                	sub    %edx,%eax
80107fef:	83 c0 02             	add    $0x2,%eax
80107ff2:	83 ec 04             	sub    $0x4,%esp
80107ff5:	53                   	push   %ebx
80107ff6:	51                   	push   %ecx
80107ff7:	50                   	push   %eax
80107ff8:	e8 ef fe ff ff       	call   80107eec <font_render>
80107ffd:	83 c4 10             	add    $0x10,%esp
    i++;
80108000:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  while(string[i] && i < 52){
80108004:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108007:	8b 45 08             	mov    0x8(%ebp),%eax
8010800a:	01 d0                	add    %edx,%eax
8010800c:	0f b6 00             	movzbl (%eax),%eax
8010800f:	84 c0                	test   %al,%al
80108011:	74 06                	je     80108019 <font_render_string+0x58>
80108013:	83 7d f4 33          	cmpl   $0x33,-0xc(%ebp)
80108017:	7e b8                	jle    80107fd1 <font_render_string+0x10>
  }
}
80108019:	90                   	nop
8010801a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010801d:	c9                   	leave
8010801e:	c3                   	ret

8010801f <pci_init>:
#include "pci.h"
#include "defs.h"
#include "types.h"
#include "i8254.h"

void pci_init(){
8010801f:	55                   	push   %ebp
80108020:	89 e5                	mov    %esp,%ebp
80108022:	53                   	push   %ebx
80108023:	83 ec 14             	sub    $0x14,%esp
  uint data;
  for(int i=0;i<256;i++){
80108026:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010802d:	eb 6b                	jmp    8010809a <pci_init+0x7b>
    for(int j=0;j<32;j++){
8010802f:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108036:	eb 58                	jmp    80108090 <pci_init+0x71>
      for(int k=0;k<8;k++){
80108038:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
8010803f:	eb 45                	jmp    80108086 <pci_init+0x67>
      pci_access_config(i,j,k,0,&data);
80108041:	8b 4d ec             	mov    -0x14(%ebp),%ecx
80108044:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108047:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010804a:	83 ec 0c             	sub    $0xc,%esp
8010804d:	8d 5d e8             	lea    -0x18(%ebp),%ebx
80108050:	53                   	push   %ebx
80108051:	6a 00                	push   $0x0
80108053:	51                   	push   %ecx
80108054:	52                   	push   %edx
80108055:	50                   	push   %eax
80108056:	e8 b0 00 00 00       	call   8010810b <pci_access_config>
8010805b:	83 c4 20             	add    $0x20,%esp
      if((data&0xFFFF) != 0xFFFF){
8010805e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108061:	0f b7 c0             	movzwl %ax,%eax
80108064:	3d ff ff 00 00       	cmp    $0xffff,%eax
80108069:	74 17                	je     80108082 <pci_init+0x63>
        pci_init_device(i,j,k);
8010806b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
8010806e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108071:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108074:	83 ec 04             	sub    $0x4,%esp
80108077:	51                   	push   %ecx
80108078:	52                   	push   %edx
80108079:	50                   	push   %eax
8010807a:	e8 37 01 00 00       	call   801081b6 <pci_init_device>
8010807f:	83 c4 10             	add    $0x10,%esp
      for(int k=0;k<8;k++){
80108082:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80108086:	83 7d ec 07          	cmpl   $0x7,-0x14(%ebp)
8010808a:	7e b5                	jle    80108041 <pci_init+0x22>
    for(int j=0;j<32;j++){
8010808c:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80108090:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
80108094:	7e a2                	jle    80108038 <pci_init+0x19>
  for(int i=0;i<256;i++){
80108096:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010809a:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
801080a1:	7e 8c                	jle    8010802f <pci_init+0x10>
      }
      }
    }
  }
}
801080a3:	90                   	nop
801080a4:	90                   	nop
801080a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801080a8:	c9                   	leave
801080a9:	c3                   	ret

801080aa <pci_write_config>:

void pci_write_config(uint config){
801080aa:	55                   	push   %ebp
801080ab:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCF8,%%edx\n\t"
801080ad:	8b 45 08             	mov    0x8(%ebp),%eax
801080b0:	ba f8 0c 00 00       	mov    $0xcf8,%edx
801080b5:	89 c0                	mov    %eax,%eax
801080b7:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080b8:	90                   	nop
801080b9:	5d                   	pop    %ebp
801080ba:	c3                   	ret

801080bb <pci_write_data>:

void pci_write_data(uint config){
801080bb:	55                   	push   %ebp
801080bc:	89 e5                	mov    %esp,%ebp
  asm("mov $0xCFC,%%edx\n\t"
801080be:	8b 45 08             	mov    0x8(%ebp),%eax
801080c1:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080c6:	89 c0                	mov    %eax,%eax
801080c8:	ef                   	out    %eax,(%dx)
      "mov %0,%%eax\n\t"
      "out %%eax,%%dx\n\t"
      : :"r"(config));
}
801080c9:	90                   	nop
801080ca:	5d                   	pop    %ebp
801080cb:	c3                   	ret

801080cc <pci_read_config>:
uint pci_read_config(){
801080cc:	55                   	push   %ebp
801080cd:	89 e5                	mov    %esp,%ebp
801080cf:	83 ec 18             	sub    $0x18,%esp
  uint data;
  asm("mov $0xCFC,%%edx\n\t"
801080d2:	ba fc 0c 00 00       	mov    $0xcfc,%edx
801080d7:	ed                   	in     (%dx),%eax
801080d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
      "in %%dx,%%eax\n\t"
      "mov %%eax,%0"
      :"=m"(data):);
  microdelay(200);
801080db:	83 ec 0c             	sub    $0xc,%esp
801080de:	68 c8 00 00 00       	push   $0xc8
801080e3:	e8 51 aa ff ff       	call   80102b39 <microdelay>
801080e8:	83 c4 10             	add    $0x10,%esp
  return data;
801080eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801080ee:	c9                   	leave
801080ef:	c3                   	ret

801080f0 <pci_test>:


void pci_test(){
801080f0:	55                   	push   %ebp
801080f1:	89 e5                	mov    %esp,%ebp
801080f3:	83 ec 10             	sub    $0x10,%esp
  uint data = 0x80001804;
801080f6:	c7 45 fc 04 18 00 80 	movl   $0x80001804,-0x4(%ebp)
  pci_write_config(data);
801080fd:	ff 75 fc             	push   -0x4(%ebp)
80108100:	e8 a5 ff ff ff       	call   801080aa <pci_write_config>
80108105:	83 c4 04             	add    $0x4,%esp
}
80108108:	90                   	nop
80108109:	c9                   	leave
8010810a:	c3                   	ret

8010810b <pci_access_config>:

void pci_access_config(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint *data){
8010810b:	55                   	push   %ebp
8010810c:	89 e5                	mov    %esp,%ebp
8010810e:	83 ec 18             	sub    $0x18,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108111:	8b 45 08             	mov    0x8(%ebp),%eax
80108114:	c1 e0 10             	shl    $0x10,%eax
80108117:	25 00 00 ff 00       	and    $0xff0000,%eax
8010811c:	89 c2                	mov    %eax,%edx
8010811e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108121:	c1 e0 0b             	shl    $0xb,%eax
80108124:	0f b7 c0             	movzwl %ax,%eax
80108127:	09 c2                	or     %eax,%edx
80108129:	8b 45 10             	mov    0x10(%ebp),%eax
8010812c:	c1 e0 08             	shl    $0x8,%eax
8010812f:	25 00 07 00 00       	and    $0x700,%eax
80108134:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
80108136:	8b 45 14             	mov    0x14(%ebp),%eax
80108139:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
8010813e:	09 d0                	or     %edx,%eax
80108140:	0d 00 00 00 80       	or     $0x80000000,%eax
80108145:	89 45 f4             	mov    %eax,-0xc(%ebp)
  pci_write_config(config_addr);
80108148:	ff 75 f4             	push   -0xc(%ebp)
8010814b:	e8 5a ff ff ff       	call   801080aa <pci_write_config>
80108150:	83 c4 04             	add    $0x4,%esp
  *data = pci_read_config();
80108153:	e8 74 ff ff ff       	call   801080cc <pci_read_config>
80108158:	8b 55 18             	mov    0x18(%ebp),%edx
8010815b:	89 02                	mov    %eax,(%edx)
}
8010815d:	90                   	nop
8010815e:	c9                   	leave
8010815f:	c3                   	ret

80108160 <pci_write_config_register>:

void pci_write_config_register(uint bus_num,uint device_num,uint function_num,uint reg_addr,uint data){
80108160:	55                   	push   %ebp
80108161:	89 e5                	mov    %esp,%ebp
80108163:	83 ec 10             	sub    $0x10,%esp
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108166:	8b 45 08             	mov    0x8(%ebp),%eax
80108169:	c1 e0 10             	shl    $0x10,%eax
8010816c:	25 00 00 ff 00       	and    $0xff0000,%eax
80108171:	89 c2                	mov    %eax,%edx
80108173:	8b 45 0c             	mov    0xc(%ebp),%eax
80108176:	c1 e0 0b             	shl    $0xb,%eax
80108179:	0f b7 c0             	movzwl %ax,%eax
8010817c:	09 c2                	or     %eax,%edx
8010817e:	8b 45 10             	mov    0x10(%ebp),%eax
80108181:	c1 e0 08             	shl    $0x8,%eax
80108184:	25 00 07 00 00       	and    $0x700,%eax
80108189:	09 c2                	or     %eax,%edx
    (reg_addr & 0xFC) | 0x80000000;
8010818b:	8b 45 14             	mov    0x14(%ebp),%eax
8010818e:	25 fc 00 00 00       	and    $0xfc,%eax
  uint config_addr = ((bus_num & 0xFF)<<16) | ((device_num & 0x1F)<<11) | ((function_num & 0x7)<<8) |
80108193:	09 d0                	or     %edx,%eax
80108195:	0d 00 00 00 80       	or     $0x80000000,%eax
8010819a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  pci_write_config(config_addr);
8010819d:	ff 75 fc             	push   -0x4(%ebp)
801081a0:	e8 05 ff ff ff       	call   801080aa <pci_write_config>
801081a5:	83 c4 04             	add    $0x4,%esp
  pci_write_data(data);
801081a8:	ff 75 18             	push   0x18(%ebp)
801081ab:	e8 0b ff ff ff       	call   801080bb <pci_write_data>
801081b0:	83 c4 04             	add    $0x4,%esp
}
801081b3:	90                   	nop
801081b4:	c9                   	leave
801081b5:	c3                   	ret

801081b6 <pci_init_device>:

struct pci_dev dev;
void pci_init_device(uint bus_num,uint device_num,uint function_num){
801081b6:	55                   	push   %ebp
801081b7:	89 e5                	mov    %esp,%ebp
801081b9:	53                   	push   %ebx
801081ba:	83 ec 14             	sub    $0x14,%esp
  uint data;
  dev.bus_num = bus_num;
801081bd:	8b 45 08             	mov    0x8(%ebp),%eax
801081c0:	a2 64 6d 19 80       	mov    %al,0x80196d64
  dev.device_num = device_num;
801081c5:	8b 45 0c             	mov    0xc(%ebp),%eax
801081c8:	a2 65 6d 19 80       	mov    %al,0x80196d65
  dev.function_num = function_num;
801081cd:	8b 45 10             	mov    0x10(%ebp),%eax
801081d0:	a2 66 6d 19 80       	mov    %al,0x80196d66
  cprintf("PCI Device Found Bus:0x%x Device:0x%x Function:%x\n",bus_num,device_num,function_num);
801081d5:	ff 75 10             	push   0x10(%ebp)
801081d8:	ff 75 0c             	push   0xc(%ebp)
801081db:	ff 75 08             	push   0x8(%ebp)
801081de:	68 24 bd 10 80       	push   $0x8010bd24
801081e3:	e8 0c 82 ff ff       	call   801003f4 <cprintf>
801081e8:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0,&data);
801081eb:	83 ec 0c             	sub    $0xc,%esp
801081ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
801081f1:	50                   	push   %eax
801081f2:	6a 00                	push   $0x0
801081f4:	ff 75 10             	push   0x10(%ebp)
801081f7:	ff 75 0c             	push   0xc(%ebp)
801081fa:	ff 75 08             	push   0x8(%ebp)
801081fd:	e8 09 ff ff ff       	call   8010810b <pci_access_config>
80108202:	83 c4 20             	add    $0x20,%esp
  uint device_id = data>>16;
80108205:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108208:	c1 e8 10             	shr    $0x10,%eax
8010820b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint vendor_id = data&0xFFFF;
8010820e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108211:	25 ff ff 00 00       	and    $0xffff,%eax
80108216:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dev.device_id = device_id;
80108219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821c:	a3 68 6d 19 80       	mov    %eax,0x80196d68
  dev.vendor_id = vendor_id;
80108221:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108224:	a3 6c 6d 19 80       	mov    %eax,0x80196d6c
  cprintf("  Device ID:0x%x  Vendor ID:0x%x\n",device_id,vendor_id);
80108229:	83 ec 04             	sub    $0x4,%esp
8010822c:	ff 75 f0             	push   -0x10(%ebp)
8010822f:	ff 75 f4             	push   -0xc(%ebp)
80108232:	68 58 bd 10 80       	push   $0x8010bd58
80108237:	e8 b8 81 ff ff       	call   801003f4 <cprintf>
8010823c:	83 c4 10             	add    $0x10,%esp
  
  pci_access_config(bus_num,device_num,function_num,0x8,&data);
8010823f:	83 ec 0c             	sub    $0xc,%esp
80108242:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108245:	50                   	push   %eax
80108246:	6a 08                	push   $0x8
80108248:	ff 75 10             	push   0x10(%ebp)
8010824b:	ff 75 0c             	push   0xc(%ebp)
8010824e:	ff 75 08             	push   0x8(%ebp)
80108251:	e8 b5 fe ff ff       	call   8010810b <pci_access_config>
80108256:	83 c4 20             	add    $0x20,%esp
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108259:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010825c:	0f b6 c8             	movzbl %al,%ecx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
8010825f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108262:	c1 e8 08             	shr    $0x8,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
80108265:	0f b6 d0             	movzbl %al,%edx
      data>>24,(data>>16)&0xFF,(data>>8)&0xFF,data&0xFF);
80108268:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010826b:	c1 e8 10             	shr    $0x10,%eax
  cprintf("  Base Class:0x%x  Sub Class:0x%x  Interface:0x%x  Revision ID:0x%x\n",
8010826e:	0f b6 c0             	movzbl %al,%eax
80108271:	8b 5d ec             	mov    -0x14(%ebp),%ebx
80108274:	c1 eb 18             	shr    $0x18,%ebx
80108277:	83 ec 0c             	sub    $0xc,%esp
8010827a:	51                   	push   %ecx
8010827b:	52                   	push   %edx
8010827c:	50                   	push   %eax
8010827d:	53                   	push   %ebx
8010827e:	68 7c bd 10 80       	push   $0x8010bd7c
80108283:	e8 6c 81 ff ff       	call   801003f4 <cprintf>
80108288:	83 c4 20             	add    $0x20,%esp
  dev.base_class = data>>24;
8010828b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010828e:	c1 e8 18             	shr    $0x18,%eax
80108291:	a2 70 6d 19 80       	mov    %al,0x80196d70
  dev.sub_class = (data>>16)&0xFF;
80108296:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108299:	c1 e8 10             	shr    $0x10,%eax
8010829c:	a2 71 6d 19 80       	mov    %al,0x80196d71
  dev.interface = (data>>8)&0xFF;
801082a1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082a4:	c1 e8 08             	shr    $0x8,%eax
801082a7:	a2 72 6d 19 80       	mov    %al,0x80196d72
  dev.revision_id = data&0xFF;
801082ac:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082af:	a2 73 6d 19 80       	mov    %al,0x80196d73
  
  pci_access_config(bus_num,device_num,function_num,0x10,&data);
801082b4:	83 ec 0c             	sub    $0xc,%esp
801082b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082ba:	50                   	push   %eax
801082bb:	6a 10                	push   $0x10
801082bd:	ff 75 10             	push   0x10(%ebp)
801082c0:	ff 75 0c             	push   0xc(%ebp)
801082c3:	ff 75 08             	push   0x8(%ebp)
801082c6:	e8 40 fe ff ff       	call   8010810b <pci_access_config>
801082cb:	83 c4 20             	add    $0x20,%esp
  dev.bar0 = data;
801082ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082d1:	a3 74 6d 19 80       	mov    %eax,0x80196d74
  pci_access_config(bus_num,device_num,function_num,0x14,&data);
801082d6:	83 ec 0c             	sub    $0xc,%esp
801082d9:	8d 45 ec             	lea    -0x14(%ebp),%eax
801082dc:	50                   	push   %eax
801082dd:	6a 14                	push   $0x14
801082df:	ff 75 10             	push   0x10(%ebp)
801082e2:	ff 75 0c             	push   0xc(%ebp)
801082e5:	ff 75 08             	push   0x8(%ebp)
801082e8:	e8 1e fe ff ff       	call   8010810b <pci_access_config>
801082ed:	83 c4 20             	add    $0x20,%esp
  dev.bar1 = data;
801082f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
801082f3:	a3 78 6d 19 80       	mov    %eax,0x80196d78
  if(device_id == I8254_DEVICE_ID && vendor_id == I8254_VENDOR_ID){
801082f8:	81 7d f4 0e 10 00 00 	cmpl   $0x100e,-0xc(%ebp)
801082ff:	75 5a                	jne    8010835b <pci_init_device+0x1a5>
80108301:	81 7d f0 86 80 00 00 	cmpl   $0x8086,-0x10(%ebp)
80108308:	75 51                	jne    8010835b <pci_init_device+0x1a5>
    cprintf("E1000 Ethernet NIC Found\n");
8010830a:	83 ec 0c             	sub    $0xc,%esp
8010830d:	68 c1 bd 10 80       	push   $0x8010bdc1
80108312:	e8 dd 80 ff ff       	call   801003f4 <cprintf>
80108317:	83 c4 10             	add    $0x10,%esp
    pci_access_config(bus_num,device_num,function_num,0xF0,&data);
8010831a:	83 ec 0c             	sub    $0xc,%esp
8010831d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108320:	50                   	push   %eax
80108321:	68 f0 00 00 00       	push   $0xf0
80108326:	ff 75 10             	push   0x10(%ebp)
80108329:	ff 75 0c             	push   0xc(%ebp)
8010832c:	ff 75 08             	push   0x8(%ebp)
8010832f:	e8 d7 fd ff ff       	call   8010810b <pci_access_config>
80108334:	83 c4 20             	add    $0x20,%esp
    cprintf("Message Control:%x\n",data);
80108337:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010833a:	83 ec 08             	sub    $0x8,%esp
8010833d:	50                   	push   %eax
8010833e:	68 db bd 10 80       	push   $0x8010bddb
80108343:	e8 ac 80 ff ff       	call   801003f4 <cprintf>
80108348:	83 c4 10             	add    $0x10,%esp
    i8254_init(&dev);
8010834b:	83 ec 0c             	sub    $0xc,%esp
8010834e:	68 64 6d 19 80       	push   $0x80196d64
80108353:	e8 09 00 00 00       	call   80108361 <i8254_init>
80108358:	83 c4 10             	add    $0x10,%esp
  }
}
8010835b:	90                   	nop
8010835c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010835f:	c9                   	leave
80108360:	c3                   	ret

80108361 <i8254_init>:

uint base_addr;
uchar mac_addr[6] = {0};
uchar my_ip[4] = {10,0,1,10}; 
uint *intr_addr;
void i8254_init(struct pci_dev *dev){
80108361:	55                   	push   %ebp
80108362:	89 e5                	mov    %esp,%ebp
80108364:	53                   	push   %ebx
80108365:	83 ec 14             	sub    $0x14,%esp
  uint cmd_reg;
  //Enable Bus Master
  pci_access_config(dev->bus_num,dev->device_num,dev->function_num,0x04,&cmd_reg);
80108368:	8b 45 08             	mov    0x8(%ebp),%eax
8010836b:	0f b6 40 02          	movzbl 0x2(%eax),%eax
8010836f:	0f b6 c8             	movzbl %al,%ecx
80108372:	8b 45 08             	mov    0x8(%ebp),%eax
80108375:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80108379:	0f b6 d0             	movzbl %al,%edx
8010837c:	8b 45 08             	mov    0x8(%ebp),%eax
8010837f:	0f b6 00             	movzbl (%eax),%eax
80108382:	0f b6 c0             	movzbl %al,%eax
80108385:	83 ec 0c             	sub    $0xc,%esp
80108388:	8d 5d ec             	lea    -0x14(%ebp),%ebx
8010838b:	53                   	push   %ebx
8010838c:	6a 04                	push   $0x4
8010838e:	51                   	push   %ecx
8010838f:	52                   	push   %edx
80108390:	50                   	push   %eax
80108391:	e8 75 fd ff ff       	call   8010810b <pci_access_config>
80108396:	83 c4 20             	add    $0x20,%esp
  cmd_reg = cmd_reg | PCI_CMD_BUS_MASTER;
80108399:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010839c:	83 c8 04             	or     $0x4,%eax
8010839f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  pci_write_config_register(dev->bus_num,dev->device_num,dev->function_num,0x04,cmd_reg);
801083a2:	8b 5d ec             	mov    -0x14(%ebp),%ebx
801083a5:	8b 45 08             	mov    0x8(%ebp),%eax
801083a8:	0f b6 40 02          	movzbl 0x2(%eax),%eax
801083ac:	0f b6 c8             	movzbl %al,%ecx
801083af:	8b 45 08             	mov    0x8(%ebp),%eax
801083b2:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801083b6:	0f b6 d0             	movzbl %al,%edx
801083b9:	8b 45 08             	mov    0x8(%ebp),%eax
801083bc:	0f b6 00             	movzbl (%eax),%eax
801083bf:	0f b6 c0             	movzbl %al,%eax
801083c2:	83 ec 0c             	sub    $0xc,%esp
801083c5:	53                   	push   %ebx
801083c6:	6a 04                	push   $0x4
801083c8:	51                   	push   %ecx
801083c9:	52                   	push   %edx
801083ca:	50                   	push   %eax
801083cb:	e8 90 fd ff ff       	call   80108160 <pci_write_config_register>
801083d0:	83 c4 20             	add    $0x20,%esp
  
  base_addr = PCI_P2V(dev->bar0);
801083d3:	8b 45 08             	mov    0x8(%ebp),%eax
801083d6:	8b 40 10             	mov    0x10(%eax),%eax
801083d9:	05 00 00 00 40       	add    $0x40000000,%eax
801083de:	a3 7c 6d 19 80       	mov    %eax,0x80196d7c
  uint *ctrl = (uint *)base_addr;
801083e3:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801083e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  //Disable Interrupts
  uint *imc = (uint *)(base_addr+0xD8);
801083eb:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801083f0:	05 d8 00 00 00       	add    $0xd8,%eax
801083f5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  *imc = 0xFFFFFFFF;
801083f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801083fb:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)
  
  //Reset NIC
  *ctrl = *ctrl | I8254_CTRL_RST;
80108401:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108404:	8b 00                	mov    (%eax),%eax
80108406:	0d 00 00 00 04       	or     $0x4000000,%eax
8010840b:	89 c2                	mov    %eax,%edx
8010840d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108410:	89 10                	mov    %edx,(%eax)

  //Enable Interrupts
  *imc = 0xFFFFFFFF;
80108412:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108415:	c7 00 ff ff ff ff    	movl   $0xffffffff,(%eax)

  //Enable Link
  *ctrl |= I8254_CTRL_SLU;
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	8b 00                	mov    (%eax),%eax
80108420:	83 c8 40             	or     $0x40,%eax
80108423:	89 c2                	mov    %eax,%edx
80108425:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108428:	89 10                	mov    %edx,(%eax)
  
  //General Configuration
  *ctrl &= (~I8254_CTRL_PHY_RST | ~I8254_CTRL_VME | ~I8254_CTRL_ILOS);
8010842a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010842d:	8b 10                	mov    (%eax),%edx
8010842f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108432:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 General Configuration Done\n");
80108434:	83 ec 0c             	sub    $0xc,%esp
80108437:	68 f0 bd 10 80       	push   $0x8010bdf0
8010843c:	e8 b3 7f ff ff       	call   801003f4 <cprintf>
80108441:	83 c4 10             	add    $0x10,%esp
  intr_addr = (uint *)kalloc();
80108444:	e8 5f a3 ff ff       	call   801027a8 <kalloc>
80108449:	a3 88 6d 19 80       	mov    %eax,0x80196d88
  *intr_addr = 0;
8010844e:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108453:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  cprintf("INTR_ADDR:%x\n",intr_addr);
80108459:	a1 88 6d 19 80       	mov    0x80196d88,%eax
8010845e:	83 ec 08             	sub    $0x8,%esp
80108461:	50                   	push   %eax
80108462:	68 12 be 10 80       	push   $0x8010be12
80108467:	e8 88 7f ff ff       	call   801003f4 <cprintf>
8010846c:	83 c4 10             	add    $0x10,%esp
  i8254_init_recv();
8010846f:	e8 50 00 00 00       	call   801084c4 <i8254_init_recv>
  i8254_init_send();
80108474:	e8 69 03 00 00       	call   801087e2 <i8254_init_send>
  cprintf("IP Address %d.%d.%d.%d\n",
      my_ip[0],
      my_ip[1],
      my_ip[2],
      my_ip[3]);
80108479:	0f b6 05 e7 f4 10 80 	movzbl 0x8010f4e7,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108480:	0f b6 d8             	movzbl %al,%ebx
      my_ip[2],
80108483:	0f b6 05 e6 f4 10 80 	movzbl 0x8010f4e6,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010848a:	0f b6 c8             	movzbl %al,%ecx
      my_ip[1],
8010848d:	0f b6 05 e5 f4 10 80 	movzbl 0x8010f4e5,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
80108494:	0f b6 d0             	movzbl %al,%edx
      my_ip[0],
80108497:	0f b6 05 e4 f4 10 80 	movzbl 0x8010f4e4,%eax
  cprintf("IP Address %d.%d.%d.%d\n",
8010849e:	0f b6 c0             	movzbl %al,%eax
801084a1:	83 ec 0c             	sub    $0xc,%esp
801084a4:	53                   	push   %ebx
801084a5:	51                   	push   %ecx
801084a6:	52                   	push   %edx
801084a7:	50                   	push   %eax
801084a8:	68 20 be 10 80       	push   $0x8010be20
801084ad:	e8 42 7f ff ff       	call   801003f4 <cprintf>
801084b2:	83 c4 20             	add    $0x20,%esp
  *imc = 0x0;
801084b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801084b8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
801084be:	90                   	nop
801084bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084c2:	c9                   	leave
801084c3:	c3                   	ret

801084c4 <i8254_init_recv>:

void i8254_init_recv(){
801084c4:	55                   	push   %ebp
801084c5:	89 e5                	mov    %esp,%ebp
801084c7:	57                   	push   %edi
801084c8:	56                   	push   %esi
801084c9:	53                   	push   %ebx
801084ca:	83 ec 6c             	sub    $0x6c,%esp
  
  uint data_l = i8254_read_eeprom(0x0);
801084cd:	83 ec 0c             	sub    $0xc,%esp
801084d0:	6a 00                	push   $0x0
801084d2:	e8 e8 04 00 00       	call   801089bf <i8254_read_eeprom>
801084d7:	83 c4 10             	add    $0x10,%esp
801084da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  mac_addr[0] = data_l&0xFF;
801084dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084e0:	a2 80 6d 19 80       	mov    %al,0x80196d80
  mac_addr[1] = data_l>>8;
801084e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
801084e8:	c1 e8 08             	shr    $0x8,%eax
801084eb:	a2 81 6d 19 80       	mov    %al,0x80196d81
  uint data_m = i8254_read_eeprom(0x1);
801084f0:	83 ec 0c             	sub    $0xc,%esp
801084f3:	6a 01                	push   $0x1
801084f5:	e8 c5 04 00 00       	call   801089bf <i8254_read_eeprom>
801084fa:	83 c4 10             	add    $0x10,%esp
801084fd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  mac_addr[2] = data_m&0xFF;
80108500:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108503:	a2 82 6d 19 80       	mov    %al,0x80196d82
  mac_addr[3] = data_m>>8;
80108508:	8b 45 d4             	mov    -0x2c(%ebp),%eax
8010850b:	c1 e8 08             	shr    $0x8,%eax
8010850e:	a2 83 6d 19 80       	mov    %al,0x80196d83
  uint data_h = i8254_read_eeprom(0x2);
80108513:	83 ec 0c             	sub    $0xc,%esp
80108516:	6a 02                	push   $0x2
80108518:	e8 a2 04 00 00       	call   801089bf <i8254_read_eeprom>
8010851d:	83 c4 10             	add    $0x10,%esp
80108520:	89 45 d0             	mov    %eax,-0x30(%ebp)
  mac_addr[4] = data_h&0xFF;
80108523:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108526:	a2 84 6d 19 80       	mov    %al,0x80196d84
  mac_addr[5] = data_h>>8;
8010852b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010852e:	c1 e8 08             	shr    $0x8,%eax
80108531:	a2 85 6d 19 80       	mov    %al,0x80196d85
      mac_addr[0],
      mac_addr[1],
      mac_addr[2],
      mac_addr[3],
      mac_addr[4],
      mac_addr[5]);
80108536:	0f b6 05 85 6d 19 80 	movzbl 0x80196d85,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010853d:	0f b6 f8             	movzbl %al,%edi
      mac_addr[4],
80108540:	0f b6 05 84 6d 19 80 	movzbl 0x80196d84,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108547:	0f b6 f0             	movzbl %al,%esi
      mac_addr[3],
8010854a:	0f b6 05 83 6d 19 80 	movzbl 0x80196d83,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108551:	0f b6 d8             	movzbl %al,%ebx
      mac_addr[2],
80108554:	0f b6 05 82 6d 19 80 	movzbl 0x80196d82,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010855b:	0f b6 c8             	movzbl %al,%ecx
      mac_addr[1],
8010855e:	0f b6 05 81 6d 19 80 	movzbl 0x80196d81,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
80108565:	0f b6 d0             	movzbl %al,%edx
      mac_addr[0],
80108568:	0f b6 05 80 6d 19 80 	movzbl 0x80196d80,%eax
  cprintf("MAC Address %x:%x:%x:%x:%x:%x\n",
8010856f:	0f b6 c0             	movzbl %al,%eax
80108572:	83 ec 04             	sub    $0x4,%esp
80108575:	57                   	push   %edi
80108576:	56                   	push   %esi
80108577:	53                   	push   %ebx
80108578:	51                   	push   %ecx
80108579:	52                   	push   %edx
8010857a:	50                   	push   %eax
8010857b:	68 38 be 10 80       	push   $0x8010be38
80108580:	e8 6f 7e ff ff       	call   801003f4 <cprintf>
80108585:	83 c4 20             	add    $0x20,%esp

  uint *ral = (uint *)(base_addr + 0x5400);
80108588:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010858d:	05 00 54 00 00       	add    $0x5400,%eax
80108592:	89 45 cc             	mov    %eax,-0x34(%ebp)
  uint *rah = (uint *)(base_addr + 0x5404);
80108595:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010859a:	05 04 54 00 00       	add    $0x5404,%eax
8010859f:	89 45 c8             	mov    %eax,-0x38(%ebp)

  *ral = (data_l | (data_m << 16));
801085a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801085a5:	c1 e0 10             	shl    $0x10,%eax
801085a8:	0b 45 d8             	or     -0x28(%ebp),%eax
801085ab:	89 c2                	mov    %eax,%edx
801085ad:	8b 45 cc             	mov    -0x34(%ebp),%eax
801085b0:	89 10                	mov    %edx,(%eax)
  *rah = (data_h | I8254_RAH_AS_DEST | I8254_RAH_AV);
801085b2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801085b5:	0d 00 00 00 80       	or     $0x80000000,%eax
801085ba:	89 c2                	mov    %eax,%edx
801085bc:	8b 45 c8             	mov    -0x38(%ebp),%eax
801085bf:	89 10                	mov    %edx,(%eax)

  uint *mta = (uint *)(base_addr + 0x5200);
801085c1:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085c6:	05 00 52 00 00       	add    $0x5200,%eax
801085cb:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  for(int i=0;i<128;i++){
801085ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801085d5:	eb 19                	jmp    801085f0 <i8254_init_recv+0x12c>
    mta[i] = 0;
801085d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801085da:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801085e1:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801085e4:	01 d0                	add    %edx,%eax
801085e6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(int i=0;i<128;i++){
801085ec:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801085f0:	83 7d e4 7f          	cmpl   $0x7f,-0x1c(%ebp)
801085f4:	7e e1                	jle    801085d7 <i8254_init_recv+0x113>
  }

  uint *ims = (uint *)(base_addr + 0xD0);
801085f6:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801085fb:	05 d0 00 00 00       	add    $0xd0,%eax
80108600:	89 45 c0             	mov    %eax,-0x40(%ebp)
  *ims = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108603:	8b 45 c0             	mov    -0x40(%ebp),%eax
80108606:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)
  uint *ics = (uint *)(base_addr + 0xC8);
8010860c:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108611:	05 c8 00 00 00       	add    $0xc8,%eax
80108616:	89 45 bc             	mov    %eax,-0x44(%ebp)
  *ics = (I8254_IMS_RXT0 | I8254_IMS_RXDMT0 | I8254_IMS_RXSEQ | I8254_IMS_LSC | I8254_IMS_RXO);
80108619:	8b 45 bc             	mov    -0x44(%ebp),%eax
8010861c:	c7 00 dc 00 00 00    	movl   $0xdc,(%eax)



  uint *rxdctl = (uint *)(base_addr + 0x2828);
80108622:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108627:	05 28 28 00 00       	add    $0x2828,%eax
8010862c:	89 45 b8             	mov    %eax,-0x48(%ebp)
  *rxdctl = 0;
8010862f:	8b 45 b8             	mov    -0x48(%ebp),%eax
80108632:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  uint *rctl = (uint *)(base_addr + 0x100);
80108638:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010863d:	05 00 01 00 00       	add    $0x100,%eax
80108642:	89 45 b4             	mov    %eax,-0x4c(%ebp)
  *rctl = (I8254_RCTL_UPE | I8254_RCTL_MPE | I8254_RCTL_BAM | I8254_RCTL_BSIZE | I8254_RCTL_SECRC);
80108645:	8b 45 b4             	mov    -0x4c(%ebp),%eax
80108648:	c7 00 18 80 00 04    	movl   $0x4008018,(%eax)

  uint recv_desc_addr = (uint)kalloc();
8010864e:	e8 55 a1 ff ff       	call   801027a8 <kalloc>
80108653:	89 45 b0             	mov    %eax,-0x50(%ebp)
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108656:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010865b:	05 00 28 00 00       	add    $0x2800,%eax
80108660:	89 45 ac             	mov    %eax,-0x54(%ebp)
  uint *rdbah = (uint *)(base_addr + 0x2804);
80108663:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108668:	05 04 28 00 00       	add    $0x2804,%eax
8010866d:	89 45 a8             	mov    %eax,-0x58(%ebp)
  uint *rdlen = (uint *)(base_addr + 0x2808);
80108670:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108675:	05 08 28 00 00       	add    $0x2808,%eax
8010867a:	89 45 a4             	mov    %eax,-0x5c(%ebp)
  uint *rdh = (uint *)(base_addr + 0x2810);
8010867d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108682:	05 10 28 00 00       	add    $0x2810,%eax
80108687:	89 45 a0             	mov    %eax,-0x60(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
8010868a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010868f:	05 18 28 00 00       	add    $0x2818,%eax
80108694:	89 45 9c             	mov    %eax,-0x64(%ebp)

  *rdbal = V2P(recv_desc_addr);
80108697:	8b 45 b0             	mov    -0x50(%ebp),%eax
8010869a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
801086a0:	8b 45 ac             	mov    -0x54(%ebp),%eax
801086a3:	89 10                	mov    %edx,(%eax)
  *rdbah = 0;
801086a5:	8b 45 a8             	mov    -0x58(%ebp),%eax
801086a8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdlen = sizeof(struct i8254_recv_desc)*I8254_RECV_DESC_NUM;
801086ae:	8b 45 a4             	mov    -0x5c(%ebp),%eax
801086b1:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  *rdh = 0;
801086b7:	8b 45 a0             	mov    -0x60(%ebp),%eax
801086ba:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *rdt = I8254_RECV_DESC_NUM;
801086c0:	8b 45 9c             	mov    -0x64(%ebp),%eax
801086c3:	c7 00 00 01 00 00    	movl   $0x100,(%eax)

  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)recv_desc_addr;
801086c9:	8b 45 b0             	mov    -0x50(%ebp),%eax
801086cc:	89 45 98             	mov    %eax,-0x68(%ebp)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
801086cf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
801086d6:	eb 73                	jmp    8010874b <i8254_init_recv+0x287>
    recv_desc[i].padding = 0;
801086d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086db:	c1 e0 04             	shl    $0x4,%eax
801086de:	89 c2                	mov    %eax,%edx
801086e0:	8b 45 98             	mov    -0x68(%ebp),%eax
801086e3:	01 d0                	add    %edx,%eax
801086e5:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    recv_desc[i].len = 0;
801086ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
801086ef:	c1 e0 04             	shl    $0x4,%eax
801086f2:	89 c2                	mov    %eax,%edx
801086f4:	8b 45 98             	mov    -0x68(%ebp),%eax
801086f7:	01 d0                	add    %edx,%eax
801086f9:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    recv_desc[i].chk_sum = 0;
801086ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108702:	c1 e0 04             	shl    $0x4,%eax
80108705:	89 c2                	mov    %eax,%edx
80108707:	8b 45 98             	mov    -0x68(%ebp),%eax
8010870a:	01 d0                	add    %edx,%eax
8010870c:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
    recv_desc[i].status = 0;
80108712:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108715:	c1 e0 04             	shl    $0x4,%eax
80108718:	89 c2                	mov    %eax,%edx
8010871a:	8b 45 98             	mov    -0x68(%ebp),%eax
8010871d:	01 d0                	add    %edx,%eax
8010871f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    recv_desc[i].errors = 0;
80108723:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108726:	c1 e0 04             	shl    $0x4,%eax
80108729:	89 c2                	mov    %eax,%edx
8010872b:	8b 45 98             	mov    -0x68(%ebp),%eax
8010872e:	01 d0                	add    %edx,%eax
80108730:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    recv_desc[i].special = 0;
80108734:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108737:	c1 e0 04             	shl    $0x4,%eax
8010873a:	89 c2                	mov    %eax,%edx
8010873c:	8b 45 98             	mov    -0x68(%ebp),%eax
8010873f:	01 d0                	add    %edx,%eax
80108741:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_RECV_DESC_NUM;i++){
80108747:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
8010874b:	81 7d e0 ff 00 00 00 	cmpl   $0xff,-0x20(%ebp)
80108752:	7e 84                	jle    801086d8 <i8254_init_recv+0x214>
  }

  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
80108754:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
8010875b:	eb 57                	jmp    801087b4 <i8254_init_recv+0x2f0>
    uint buf_addr = (uint)kalloc();
8010875d:	e8 46 a0 ff ff       	call   801027a8 <kalloc>
80108762:	89 45 94             	mov    %eax,-0x6c(%ebp)
    if(buf_addr == 0){
80108765:	83 7d 94 00          	cmpl   $0x0,-0x6c(%ebp)
80108769:	75 12                	jne    8010877d <i8254_init_recv+0x2b9>
      cprintf("failed to allocate buffer area\n");
8010876b:	83 ec 0c             	sub    $0xc,%esp
8010876e:	68 58 be 10 80       	push   $0x8010be58
80108773:	e8 7c 7c ff ff       	call   801003f4 <cprintf>
80108778:	83 c4 10             	add    $0x10,%esp
      break;
8010877b:	eb 3d                	jmp    801087ba <i8254_init_recv+0x2f6>
    }
    recv_desc[i].buf_addr = V2P(buf_addr);
8010877d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108780:	c1 e0 04             	shl    $0x4,%eax
80108783:	89 c2                	mov    %eax,%edx
80108785:	8b 45 98             	mov    -0x68(%ebp),%eax
80108788:	01 d0                	add    %edx,%eax
8010878a:	8b 55 94             	mov    -0x6c(%ebp),%edx
8010878d:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108793:	89 10                	mov    %edx,(%eax)
    recv_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
80108795:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108798:	83 c0 01             	add    $0x1,%eax
8010879b:	c1 e0 04             	shl    $0x4,%eax
8010879e:	89 c2                	mov    %eax,%edx
801087a0:	8b 45 98             	mov    -0x68(%ebp),%eax
801087a3:	01 d0                	add    %edx,%eax
801087a5:	8b 55 94             	mov    -0x6c(%ebp),%edx
801087a8:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
801087ae:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_RECV_DESC_NUM)/2;i++){
801087b0:	83 45 dc 01          	addl   $0x1,-0x24(%ebp)
801087b4:	83 7d dc 7f          	cmpl   $0x7f,-0x24(%ebp)
801087b8:	7e a3                	jle    8010875d <i8254_init_recv+0x299>
  }

  *rctl |= I8254_RCTL_EN;
801087ba:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087bd:	8b 00                	mov    (%eax),%eax
801087bf:	83 c8 02             	or     $0x2,%eax
801087c2:	89 c2                	mov    %eax,%edx
801087c4:	8b 45 b4             	mov    -0x4c(%ebp),%eax
801087c7:	89 10                	mov    %edx,(%eax)
  cprintf("E1000 Recieve Initialize Done\n");
801087c9:	83 ec 0c             	sub    $0xc,%esp
801087cc:	68 78 be 10 80       	push   $0x8010be78
801087d1:	e8 1e 7c ff ff       	call   801003f4 <cprintf>
801087d6:	83 c4 10             	add    $0x10,%esp
}
801087d9:	90                   	nop
801087da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801087dd:	5b                   	pop    %ebx
801087de:	5e                   	pop    %esi
801087df:	5f                   	pop    %edi
801087e0:	5d                   	pop    %ebp
801087e1:	c3                   	ret

801087e2 <i8254_init_send>:

void i8254_init_send(){
801087e2:	55                   	push   %ebp
801087e3:	89 e5                	mov    %esp,%ebp
801087e5:	83 ec 48             	sub    $0x48,%esp
  uint *txdctl = (uint *)(base_addr + 0x3828);
801087e8:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801087ed:	05 28 38 00 00       	add    $0x3828,%eax
801087f2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  *txdctl = (I8254_TXDCTL_WTHRESH | I8254_TXDCTL_GRAN_DESC);
801087f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
801087f8:	c7 00 00 00 01 01    	movl   $0x1010000,(%eax)

  uint tx_desc_addr = (uint)kalloc();
801087fe:	e8 a5 9f ff ff       	call   801027a8 <kalloc>
80108803:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108806:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010880b:	05 00 38 00 00       	add    $0x3800,%eax
80108810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  uint *tdbah = (uint *)(base_addr + 0x3804);
80108813:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108818:	05 04 38 00 00       	add    $0x3804,%eax
8010881d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  uint *tdlen = (uint *)(base_addr + 0x3808);
80108820:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108825:	05 08 38 00 00       	add    $0x3808,%eax
8010882a:	89 45 dc             	mov    %eax,-0x24(%ebp)

  *tdbal = V2P(tx_desc_addr);
8010882d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108830:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80108836:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80108839:	89 10                	mov    %edx,(%eax)
  *tdbah = 0;
8010883b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010883e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdlen = sizeof(struct i8254_send_desc)*I8254_SEND_DESC_NUM;
80108844:	8b 45 dc             	mov    -0x24(%ebp),%eax
80108847:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  uint *tdh = (uint *)(base_addr + 0x3810);
8010884d:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108852:	05 10 38 00 00       	add    $0x3810,%eax
80108857:	89 45 d8             	mov    %eax,-0x28(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
8010885a:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010885f:	05 18 38 00 00       	add    $0x3818,%eax
80108864:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  
  *tdh = 0;
80108867:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010886a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  *tdt = 0;
80108870:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80108873:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  struct i8254_send_desc *send_desc = (struct i8254_send_desc *)tx_desc_addr;
80108879:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010887c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
8010887f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108886:	e9 82 00 00 00       	jmp    8010890d <i8254_init_send+0x12b>
    send_desc[i].padding = 0;
8010888b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010888e:	c1 e0 04             	shl    $0x4,%eax
80108891:	89 c2                	mov    %eax,%edx
80108893:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108896:	01 d0                	add    %edx,%eax
80108898:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    send_desc[i].len = 0;
8010889f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088a2:	c1 e0 04             	shl    $0x4,%eax
801088a5:	89 c2                	mov    %eax,%edx
801088a7:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088aa:	01 d0                	add    %edx,%eax
801088ac:	66 c7 40 08 00 00    	movw   $0x0,0x8(%eax)
    send_desc[i].cso = 0;
801088b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088b5:	c1 e0 04             	shl    $0x4,%eax
801088b8:	89 c2                	mov    %eax,%edx
801088ba:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088bd:	01 d0                	add    %edx,%eax
801088bf:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    send_desc[i].cmd = 0;
801088c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088c6:	c1 e0 04             	shl    $0x4,%eax
801088c9:	89 c2                	mov    %eax,%edx
801088cb:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088ce:	01 d0                	add    %edx,%eax
801088d0:	c6 40 0b 00          	movb   $0x0,0xb(%eax)
    send_desc[i].sta = 0;
801088d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088d7:	c1 e0 04             	shl    $0x4,%eax
801088da:	89 c2                	mov    %eax,%edx
801088dc:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088df:	01 d0                	add    %edx,%eax
801088e1:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    send_desc[i].css = 0;
801088e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088e8:	c1 e0 04             	shl    $0x4,%eax
801088eb:	89 c2                	mov    %eax,%edx
801088ed:	8b 45 d0             	mov    -0x30(%ebp),%eax
801088f0:	01 d0                	add    %edx,%eax
801088f2:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    send_desc[i].special = 0;
801088f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801088f9:	c1 e0 04             	shl    $0x4,%eax
801088fc:	89 c2                	mov    %eax,%edx
801088fe:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108901:	01 d0                	add    %edx,%eax
80108903:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
  for(int i=0;i<I8254_SEND_DESC_NUM;i++){
80108909:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010890d:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108914:	0f 8e 71 ff ff ff    	jle    8010888b <i8254_init_send+0xa9>
  }

  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
8010891a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108921:	eb 57                	jmp    8010897a <i8254_init_send+0x198>
    uint buf_addr = (uint)kalloc();
80108923:	e8 80 9e ff ff       	call   801027a8 <kalloc>
80108928:	89 45 cc             	mov    %eax,-0x34(%ebp)
    if(buf_addr == 0){
8010892b:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
8010892f:	75 12                	jne    80108943 <i8254_init_send+0x161>
      cprintf("failed to allocate buffer area\n");
80108931:	83 ec 0c             	sub    $0xc,%esp
80108934:	68 58 be 10 80       	push   $0x8010be58
80108939:	e8 b6 7a ff ff       	call   801003f4 <cprintf>
8010893e:	83 c4 10             	add    $0x10,%esp
      break;
80108941:	eb 3d                	jmp    80108980 <i8254_init_send+0x19e>
    }
    send_desc[i].buf_addr = V2P(buf_addr);
80108943:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108946:	c1 e0 04             	shl    $0x4,%eax
80108949:	89 c2                	mov    %eax,%edx
8010894b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010894e:	01 d0                	add    %edx,%eax
80108950:	8b 55 cc             	mov    -0x34(%ebp),%edx
80108953:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108959:	89 10                	mov    %edx,(%eax)
    send_desc[i+1].buf_addr = V2P(buf_addr + 0x800);
8010895b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010895e:	83 c0 01             	add    $0x1,%eax
80108961:	c1 e0 04             	shl    $0x4,%eax
80108964:	89 c2                	mov    %eax,%edx
80108966:	8b 45 d0             	mov    -0x30(%ebp),%eax
80108969:	01 d0                	add    %edx,%eax
8010896b:	8b 55 cc             	mov    -0x34(%ebp),%edx
8010896e:	81 ea 00 f8 ff 7f    	sub    $0x7ffff800,%edx
80108974:	89 10                	mov    %edx,(%eax)
  for(int i=0;i<(I8254_SEND_DESC_NUM)/2;i++){
80108976:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010897a:	83 7d f0 7f          	cmpl   $0x7f,-0x10(%ebp)
8010897e:	7e a3                	jle    80108923 <i8254_init_send+0x141>
  }

  uint *tctl = (uint *)(base_addr + 0x400);
80108980:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108985:	05 00 04 00 00       	add    $0x400,%eax
8010898a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  *tctl = (I8254_TCTL_EN | I8254_TCTL_PSP | I8254_TCTL_COLD | I8254_TCTL_CT);
8010898d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80108990:	c7 00 fa 00 04 00    	movl   $0x400fa,(%eax)

  uint *tipg = (uint *)(base_addr + 0x410);
80108996:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
8010899b:	05 10 04 00 00       	add    $0x410,%eax
801089a0:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  *tipg = (10 | (10<<10) | (10<<20));
801089a3:	8b 45 c4             	mov    -0x3c(%ebp),%eax
801089a6:	c7 00 0a 28 a0 00    	movl   $0xa0280a,(%eax)
  cprintf("E1000 Transmit Initialize Done\n");
801089ac:	83 ec 0c             	sub    $0xc,%esp
801089af:	68 98 be 10 80       	push   $0x8010be98
801089b4:	e8 3b 7a ff ff       	call   801003f4 <cprintf>
801089b9:	83 c4 10             	add    $0x10,%esp

}
801089bc:	90                   	nop
801089bd:	c9                   	leave
801089be:	c3                   	ret

801089bf <i8254_read_eeprom>:
uint i8254_read_eeprom(uint addr){
801089bf:	55                   	push   %ebp
801089c0:	89 e5                	mov    %esp,%ebp
801089c2:	83 ec 18             	sub    $0x18,%esp
  uint *eerd = (uint *)(base_addr + 0x14);
801089c5:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
801089ca:	83 c0 14             	add    $0x14,%eax
801089cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  *eerd = (((addr & 0xFF) << 8) | 1);
801089d0:	8b 45 08             	mov    0x8(%ebp),%eax
801089d3:	c1 e0 08             	shl    $0x8,%eax
801089d6:	0f b7 c0             	movzwl %ax,%eax
801089d9:	83 c8 01             	or     $0x1,%eax
801089dc:	89 c2                	mov    %eax,%edx
801089de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089e1:	89 10                	mov    %edx,(%eax)
  while(1){
    cprintf("");
801089e3:	83 ec 0c             	sub    $0xc,%esp
801089e6:	68 b8 be 10 80       	push   $0x8010beb8
801089eb:	e8 04 7a ff ff       	call   801003f4 <cprintf>
801089f0:	83 c4 10             	add    $0x10,%esp
    volatile uint data = *eerd;
801089f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089f6:	8b 00                	mov    (%eax),%eax
801089f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((data & (1<<4)) != 0){
801089fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801089fe:	83 e0 10             	and    $0x10,%eax
80108a01:	85 c0                	test   %eax,%eax
80108a03:	75 02                	jne    80108a07 <i8254_read_eeprom+0x48>
  while(1){
80108a05:	eb dc                	jmp    801089e3 <i8254_read_eeprom+0x24>
      break;
80108a07:	90                   	nop
    }
  }

  return (*eerd >> 16) & 0xFFFF;
80108a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a0b:	8b 00                	mov    (%eax),%eax
80108a0d:	c1 e8 10             	shr    $0x10,%eax
}
80108a10:	c9                   	leave
80108a11:	c3                   	ret

80108a12 <i8254_recv>:
void i8254_recv(){
80108a12:	55                   	push   %ebp
80108a13:	89 e5                	mov    %esp,%ebp
80108a15:	83 ec 28             	sub    $0x28,%esp
  uint *rdh = (uint *)(base_addr + 0x2810);
80108a18:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a1d:	05 10 28 00 00       	add    $0x2810,%eax
80108a22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *rdt = (uint *)(base_addr + 0x2818);
80108a25:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a2a:	05 18 28 00 00       	add    $0x2818,%eax
80108a2f:	89 45 f0             	mov    %eax,-0x10(%ebp)
//  uint *torl = (uint *)(base_addr + 0x40C0);
//  uint *tpr = (uint *)(base_addr + 0x40D0);
//  uint *icr = (uint *)(base_addr + 0xC0);
  uint *rdbal = (uint *)(base_addr + 0x2800);
80108a32:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108a37:	05 00 28 00 00       	add    $0x2800,%eax
80108a3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_recv_desc *recv_desc = (struct i8254_recv_desc *)(P2V(*rdbal));
80108a3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108a42:	8b 00                	mov    (%eax),%eax
80108a44:	05 00 00 00 80       	add    $0x80000000,%eax
80108a49:	89 45 e8             	mov    %eax,-0x18(%ebp)
  while(1){
    int rx_available = (I8254_RECV_DESC_NUM - *rdt + *rdh)%I8254_RECV_DESC_NUM;
80108a4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a4f:	8b 10                	mov    (%eax),%edx
80108a51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a54:	8b 00                	mov    (%eax),%eax
80108a56:	29 c2                	sub    %eax,%edx
80108a58:	89 d0                	mov    %edx,%eax
80108a5a:	25 ff 00 00 00       	and    $0xff,%eax
80108a5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(rx_available > 0){
80108a62:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108a66:	7e 37                	jle    80108a9f <i8254_recv+0x8d>
      uint buffer_addr = P2V_WO(recv_desc[*rdt].buf_addr);
80108a68:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a6b:	8b 00                	mov    (%eax),%eax
80108a6d:	c1 e0 04             	shl    $0x4,%eax
80108a70:	89 c2                	mov    %eax,%edx
80108a72:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108a75:	01 d0                	add    %edx,%eax
80108a77:	8b 00                	mov    (%eax),%eax
80108a79:	05 00 00 00 80       	add    $0x80000000,%eax
80108a7e:	89 45 e0             	mov    %eax,-0x20(%ebp)
      *rdt = (*rdt + 1)%I8254_RECV_DESC_NUM;
80108a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a84:	8b 00                	mov    (%eax),%eax
80108a86:	83 c0 01             	add    $0x1,%eax
80108a89:	0f b6 d0             	movzbl %al,%edx
80108a8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108a8f:	89 10                	mov    %edx,(%eax)
      eth_proc(buffer_addr);
80108a91:	83 ec 0c             	sub    $0xc,%esp
80108a94:	ff 75 e0             	push   -0x20(%ebp)
80108a97:	e8 13 09 00 00       	call   801093af <eth_proc>
80108a9c:	83 c4 10             	add    $0x10,%esp
    }
    if(*rdt == *rdh) {
80108a9f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aa2:	8b 10                	mov    (%eax),%edx
80108aa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108aa7:	8b 00                	mov    (%eax),%eax
80108aa9:	39 c2                	cmp    %eax,%edx
80108aab:	75 9f                	jne    80108a4c <i8254_recv+0x3a>
      (*rdt)--;
80108aad:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab0:	8b 00                	mov    (%eax),%eax
80108ab2:	8d 50 ff             	lea    -0x1(%eax),%edx
80108ab5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ab8:	89 10                	mov    %edx,(%eax)
  while(1){
80108aba:	eb 90                	jmp    80108a4c <i8254_recv+0x3a>

80108abc <i8254_send>:
    }
  }
}

int i8254_send(const uint pkt_addr,uint len){
80108abc:	55                   	push   %ebp
80108abd:	89 e5                	mov    %esp,%ebp
80108abf:	83 ec 28             	sub    $0x28,%esp
  uint *tdh = (uint *)(base_addr + 0x3810);
80108ac2:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ac7:	05 10 38 00 00       	add    $0x3810,%eax
80108acc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint *tdt = (uint *)(base_addr + 0x3818);
80108acf:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ad4:	05 18 38 00 00       	add    $0x3818,%eax
80108ad9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  uint *tdbal = (uint *)(base_addr + 0x3800);
80108adc:	a1 7c 6d 19 80       	mov    0x80196d7c,%eax
80108ae1:	05 00 38 00 00       	add    $0x3800,%eax
80108ae6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct i8254_send_desc *txdesc = (struct i8254_send_desc *)P2V_WO(*tdbal);
80108ae9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108aec:	8b 00                	mov    (%eax),%eax
80108aee:	05 00 00 00 80       	add    $0x80000000,%eax
80108af3:	89 45 e8             	mov    %eax,-0x18(%ebp)
  int tx_available = I8254_SEND_DESC_NUM - ((I8254_SEND_DESC_NUM - *tdh + *tdt) % I8254_SEND_DESC_NUM);
80108af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af9:	8b 10                	mov    (%eax),%edx
80108afb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108afe:	8b 00                	mov    (%eax),%eax
80108b00:	29 c2                	sub    %eax,%edx
80108b02:	0f b6 c2             	movzbl %dl,%eax
80108b05:	ba 00 01 00 00       	mov    $0x100,%edx
80108b0a:	29 c2                	sub    %eax,%edx
80108b0c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  uint index = *tdt%I8254_SEND_DESC_NUM;
80108b0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b12:	8b 00                	mov    (%eax),%eax
80108b14:	25 ff 00 00 00       	and    $0xff,%eax
80108b19:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(tx_available > 0) {
80108b1c:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80108b20:	0f 8e a8 00 00 00    	jle    80108bce <i8254_send+0x112>
    memmove(P2V_WO((void *)txdesc[index].buf_addr),(void *)pkt_addr,len);
80108b26:	8b 45 08             	mov    0x8(%ebp),%eax
80108b29:	8b 55 e0             	mov    -0x20(%ebp),%edx
80108b2c:	89 d1                	mov    %edx,%ecx
80108b2e:	c1 e1 04             	shl    $0x4,%ecx
80108b31:	8b 55 e8             	mov    -0x18(%ebp),%edx
80108b34:	01 ca                	add    %ecx,%edx
80108b36:	8b 12                	mov    (%edx),%edx
80108b38:	81 c2 00 00 00 80    	add    $0x80000000,%edx
80108b3e:	83 ec 04             	sub    $0x4,%esp
80108b41:	ff 75 0c             	push   0xc(%ebp)
80108b44:	50                   	push   %eax
80108b45:	52                   	push   %edx
80108b46:	e8 00 bf ff ff       	call   80104a4b <memmove>
80108b4b:	83 c4 10             	add    $0x10,%esp
    txdesc[index].len = len;
80108b4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b51:	c1 e0 04             	shl    $0x4,%eax
80108b54:	89 c2                	mov    %eax,%edx
80108b56:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b59:	01 d0                	add    %edx,%eax
80108b5b:	8b 55 0c             	mov    0xc(%ebp),%edx
80108b5e:	66 89 50 08          	mov    %dx,0x8(%eax)
    txdesc[index].sta = 0;
80108b62:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b65:	c1 e0 04             	shl    $0x4,%eax
80108b68:	89 c2                	mov    %eax,%edx
80108b6a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b6d:	01 d0                	add    %edx,%eax
80108b6f:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
    txdesc[index].css = 0;
80108b73:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b76:	c1 e0 04             	shl    $0x4,%eax
80108b79:	89 c2                	mov    %eax,%edx
80108b7b:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b7e:	01 d0                	add    %edx,%eax
80108b80:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
    txdesc[index].cmd = 0xb;
80108b84:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b87:	c1 e0 04             	shl    $0x4,%eax
80108b8a:	89 c2                	mov    %eax,%edx
80108b8c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108b8f:	01 d0                	add    %edx,%eax
80108b91:	c6 40 0b 0b          	movb   $0xb,0xb(%eax)
    txdesc[index].special = 0;
80108b95:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108b98:	c1 e0 04             	shl    $0x4,%eax
80108b9b:	89 c2                	mov    %eax,%edx
80108b9d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108ba0:	01 d0                	add    %edx,%eax
80108ba2:	66 c7 40 0e 00 00    	movw   $0x0,0xe(%eax)
    txdesc[index].cso = 0;
80108ba8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80108bab:	c1 e0 04             	shl    $0x4,%eax
80108bae:	89 c2                	mov    %eax,%edx
80108bb0:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108bb3:	01 d0                	add    %edx,%eax
80108bb5:	c6 40 0a 00          	movb   $0x0,0xa(%eax)
    *tdt = (*tdt + 1)%I8254_SEND_DESC_NUM;
80108bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bbc:	8b 00                	mov    (%eax),%eax
80108bbe:	83 c0 01             	add    $0x1,%eax
80108bc1:	0f b6 d0             	movzbl %al,%edx
80108bc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108bc7:	89 10                	mov    %edx,(%eax)
    return len;
80108bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108bcc:	eb 05                	jmp    80108bd3 <i8254_send+0x117>
  }else{
    return -1;
80108bce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80108bd3:	c9                   	leave
80108bd4:	c3                   	ret

80108bd5 <i8254_intr>:

void i8254_intr(){
80108bd5:	55                   	push   %ebp
80108bd6:	89 e5                	mov    %esp,%ebp
  *intr_addr = 0xEEEEEE;
80108bd8:	a1 88 6d 19 80       	mov    0x80196d88,%eax
80108bdd:	c7 00 ee ee ee 00    	movl   $0xeeeeee,(%eax)
}
80108be3:	90                   	nop
80108be4:	5d                   	pop    %ebp
80108be5:	c3                   	ret

80108be6 <arp_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

struct arp_entry arp_table[ARP_TABLE_MAX] = {0};

int arp_proc(uint buffer_addr){
80108be6:	55                   	push   %ebp
80108be7:	89 e5                	mov    %esp,%ebp
80108be9:	83 ec 18             	sub    $0x18,%esp
  struct arp_pkt *arp_p = (struct arp_pkt *)(buffer_addr);
80108bec:	8b 45 08             	mov    0x8(%ebp),%eax
80108bef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(arp_p->hrd_type != ARP_HARDWARE_TYPE) return -1;
80108bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108bf5:	0f b7 00             	movzwl (%eax),%eax
80108bf8:	66 3d 00 01          	cmp    $0x100,%ax
80108bfc:	74 0a                	je     80108c08 <arp_proc+0x22>
80108bfe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c03:	e9 4f 01 00 00       	jmp    80108d57 <arp_proc+0x171>
  if(arp_p->pro_type != ARP_PROTOCOL_TYPE) return -1;
80108c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c0b:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80108c0f:	66 83 f8 08          	cmp    $0x8,%ax
80108c13:	74 0a                	je     80108c1f <arp_proc+0x39>
80108c15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c1a:	e9 38 01 00 00       	jmp    80108d57 <arp_proc+0x171>
  if(arp_p->hrd_len != 6) return -1;
80108c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c22:	0f b6 40 04          	movzbl 0x4(%eax),%eax
80108c26:	3c 06                	cmp    $0x6,%al
80108c28:	74 0a                	je     80108c34 <arp_proc+0x4e>
80108c2a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c2f:	e9 23 01 00 00       	jmp    80108d57 <arp_proc+0x171>
  if(arp_p->pro_len != 4) return -1;
80108c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c37:	0f b6 40 05          	movzbl 0x5(%eax),%eax
80108c3b:	3c 04                	cmp    $0x4,%al
80108c3d:	74 0a                	je     80108c49 <arp_proc+0x63>
80108c3f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c44:	e9 0e 01 00 00       	jmp    80108d57 <arp_proc+0x171>
  if(memcmp(my_ip,arp_p->dst_ip,4) != 0 && memcmp(my_ip,arp_p->src_ip,4) != 0) return -1;
80108c49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c4c:	83 c0 18             	add    $0x18,%eax
80108c4f:	83 ec 04             	sub    $0x4,%esp
80108c52:	6a 04                	push   $0x4
80108c54:	50                   	push   %eax
80108c55:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c5a:	e8 94 bd ff ff       	call   801049f3 <memcmp>
80108c5f:	83 c4 10             	add    $0x10,%esp
80108c62:	85 c0                	test   %eax,%eax
80108c64:	74 27                	je     80108c8d <arp_proc+0xa7>
80108c66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c69:	83 c0 0e             	add    $0xe,%eax
80108c6c:	83 ec 04             	sub    $0x4,%esp
80108c6f:	6a 04                	push   $0x4
80108c71:	50                   	push   %eax
80108c72:	68 e4 f4 10 80       	push   $0x8010f4e4
80108c77:	e8 77 bd ff ff       	call   801049f3 <memcmp>
80108c7c:	83 c4 10             	add    $0x10,%esp
80108c7f:	85 c0                	test   %eax,%eax
80108c81:	74 0a                	je     80108c8d <arp_proc+0xa7>
80108c83:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108c88:	e9 ca 00 00 00       	jmp    80108d57 <arp_proc+0x171>
  if(arp_p->op == ARP_OPS_REQUEST && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108c8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c90:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108c94:	66 3d 00 01          	cmp    $0x100,%ax
80108c98:	75 69                	jne    80108d03 <arp_proc+0x11d>
80108c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c9d:	83 c0 18             	add    $0x18,%eax
80108ca0:	83 ec 04             	sub    $0x4,%esp
80108ca3:	6a 04                	push   $0x4
80108ca5:	50                   	push   %eax
80108ca6:	68 e4 f4 10 80       	push   $0x8010f4e4
80108cab:	e8 43 bd ff ff       	call   801049f3 <memcmp>
80108cb0:	83 c4 10             	add    $0x10,%esp
80108cb3:	85 c0                	test   %eax,%eax
80108cb5:	75 4c                	jne    80108d03 <arp_proc+0x11d>
    uint send = (uint)kalloc();
80108cb7:	e8 ec 9a ff ff       	call   801027a8 <kalloc>
80108cbc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    uint send_size=0;
80108cbf:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
    arp_reply_pkt_create(arp_p,send,&send_size);
80108cc6:	83 ec 04             	sub    $0x4,%esp
80108cc9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108ccc:	50                   	push   %eax
80108ccd:	ff 75 f0             	push   -0x10(%ebp)
80108cd0:	ff 75 f4             	push   -0xc(%ebp)
80108cd3:	e8 1f 04 00 00       	call   801090f7 <arp_reply_pkt_create>
80108cd8:	83 c4 10             	add    $0x10,%esp
    i8254_send(send,send_size);
80108cdb:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cde:	83 ec 08             	sub    $0x8,%esp
80108ce1:	50                   	push   %eax
80108ce2:	ff 75 f0             	push   -0x10(%ebp)
80108ce5:	e8 d2 fd ff ff       	call   80108abc <i8254_send>
80108cea:	83 c4 10             	add    $0x10,%esp
    kfree((char *)send);
80108ced:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108cf0:	83 ec 0c             	sub    $0xc,%esp
80108cf3:	50                   	push   %eax
80108cf4:	e8 15 9a ff ff       	call   8010270e <kfree>
80108cf9:	83 c4 10             	add    $0x10,%esp
    return ARP_CREATED_REPLY;
80108cfc:	b8 02 00 00 00       	mov    $0x2,%eax
80108d01:	eb 54                	jmp    80108d57 <arp_proc+0x171>
  }else if(arp_p->op == ARP_OPS_REPLY && memcmp(my_ip,arp_p->dst_ip,4) == 0){
80108d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d06:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80108d0a:	66 3d 00 02          	cmp    $0x200,%ax
80108d0e:	75 42                	jne    80108d52 <arp_proc+0x16c>
80108d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d13:	83 c0 18             	add    $0x18,%eax
80108d16:	83 ec 04             	sub    $0x4,%esp
80108d19:	6a 04                	push   $0x4
80108d1b:	50                   	push   %eax
80108d1c:	68 e4 f4 10 80       	push   $0x8010f4e4
80108d21:	e8 cd bc ff ff       	call   801049f3 <memcmp>
80108d26:	83 c4 10             	add    $0x10,%esp
80108d29:	85 c0                	test   %eax,%eax
80108d2b:	75 25                	jne    80108d52 <arp_proc+0x16c>
    cprintf("ARP TABLE UPDATED\n");
80108d2d:	83 ec 0c             	sub    $0xc,%esp
80108d30:	68 bc be 10 80       	push   $0x8010bebc
80108d35:	e8 ba 76 ff ff       	call   801003f4 <cprintf>
80108d3a:	83 c4 10             	add    $0x10,%esp
    arp_table_update(arp_p);
80108d3d:	83 ec 0c             	sub    $0xc,%esp
80108d40:	ff 75 f4             	push   -0xc(%ebp)
80108d43:	e8 af 01 00 00       	call   80108ef7 <arp_table_update>
80108d48:	83 c4 10             	add    $0x10,%esp
    return ARP_UPDATED_TABLE;
80108d4b:	b8 01 00 00 00       	mov    $0x1,%eax
80108d50:	eb 05                	jmp    80108d57 <arp_proc+0x171>
  }else{
    return -1;
80108d52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
80108d57:	c9                   	leave
80108d58:	c3                   	ret

80108d59 <arp_scan>:

void arp_scan(){
80108d59:	55                   	push   %ebp
80108d5a:	89 e5                	mov    %esp,%ebp
80108d5c:	83 ec 18             	sub    $0x18,%esp
  uint send_size;
  for(int i=0;i<256;i++){
80108d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108d66:	eb 6f                	jmp    80108dd7 <arp_scan+0x7e>
    uint send = (uint)kalloc();
80108d68:	e8 3b 9a ff ff       	call   801027a8 <kalloc>
80108d6d:	89 45 ec             	mov    %eax,-0x14(%ebp)
    arp_broadcast(send,&send_size,i);
80108d70:	83 ec 04             	sub    $0x4,%esp
80108d73:	ff 75 f4             	push   -0xc(%ebp)
80108d76:	8d 45 e8             	lea    -0x18(%ebp),%eax
80108d79:	50                   	push   %eax
80108d7a:	ff 75 ec             	push   -0x14(%ebp)
80108d7d:	e8 62 00 00 00       	call   80108de4 <arp_broadcast>
80108d82:	83 c4 10             	add    $0x10,%esp
    uint res = i8254_send(send,send_size);
80108d85:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108d88:	83 ec 08             	sub    $0x8,%esp
80108d8b:	50                   	push   %eax
80108d8c:	ff 75 ec             	push   -0x14(%ebp)
80108d8f:	e8 28 fd ff ff       	call   80108abc <i8254_send>
80108d94:	83 c4 10             	add    $0x10,%esp
80108d97:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108d9a:	eb 22                	jmp    80108dbe <arp_scan+0x65>
      microdelay(1);
80108d9c:	83 ec 0c             	sub    $0xc,%esp
80108d9f:	6a 01                	push   $0x1
80108da1:	e8 93 9d ff ff       	call   80102b39 <microdelay>
80108da6:	83 c4 10             	add    $0x10,%esp
      res = i8254_send(send,send_size);
80108da9:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108dac:	83 ec 08             	sub    $0x8,%esp
80108daf:	50                   	push   %eax
80108db0:	ff 75 ec             	push   -0x14(%ebp)
80108db3:	e8 04 fd ff ff       	call   80108abc <i8254_send>
80108db8:	83 c4 10             	add    $0x10,%esp
80108dbb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while(res == -1){
80108dbe:	83 7d f0 ff          	cmpl   $0xffffffff,-0x10(%ebp)
80108dc2:	74 d8                	je     80108d9c <arp_scan+0x43>
    }
    kfree((char *)send);
80108dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dc7:	83 ec 0c             	sub    $0xc,%esp
80108dca:	50                   	push   %eax
80108dcb:	e8 3e 99 ff ff       	call   8010270e <kfree>
80108dd0:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i<256;i++){
80108dd3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108dd7:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
80108dde:	7e 88                	jle    80108d68 <arp_scan+0xf>
  }
}
80108de0:	90                   	nop
80108de1:	90                   	nop
80108de2:	c9                   	leave
80108de3:	c3                   	ret

80108de4 <arp_broadcast>:

void arp_broadcast(uint send,uint *send_size,uint ip){
80108de4:	55                   	push   %ebp
80108de5:	89 e5                	mov    %esp,%ebp
80108de7:	83 ec 28             	sub    $0x28,%esp
  uchar dst_ip[4] = {10,0,1,ip};
80108dea:	c6 45 ec 0a          	movb   $0xa,-0x14(%ebp)
80108dee:	c6 45 ed 00          	movb   $0x0,-0x13(%ebp)
80108df2:	c6 45 ee 01          	movb   $0x1,-0x12(%ebp)
80108df6:	8b 45 10             	mov    0x10(%ebp),%eax
80108df9:	88 45 ef             	mov    %al,-0x11(%ebp)
  uchar dst_mac_eth[6] = {0xff,0xff,0xff,0xff,0xff,0xff};
80108dfc:	c7 45 e6 ff ff ff ff 	movl   $0xffffffff,-0x1a(%ebp)
80108e03:	66 c7 45 ea ff ff    	movw   $0xffff,-0x16(%ebp)
  uchar dst_mac_arp[6] = {0,0,0,0,0,0};
80108e09:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80108e10:	66 c7 45 e4 00 00    	movw   $0x0,-0x1c(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
80108e16:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e19:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)

  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80108e1f:	8b 45 08             	mov    0x8(%ebp),%eax
80108e22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
80108e25:	8b 45 08             	mov    0x8(%ebp),%eax
80108e28:	83 c0 0e             	add    $0xe,%eax
80108e2b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  reply_eth->type[0] = 0x08;
80108e2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e31:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
80108e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e38:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,dst_mac_eth,6);
80108e3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e3f:	83 ec 04             	sub    $0x4,%esp
80108e42:	6a 06                	push   $0x6
80108e44:	8d 55 e6             	lea    -0x1a(%ebp),%edx
80108e47:	52                   	push   %edx
80108e48:	50                   	push   %eax
80108e49:	e8 fd bb ff ff       	call   80104a4b <memmove>
80108e4e:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
80108e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108e54:	83 c0 06             	add    $0x6,%eax
80108e57:	83 ec 04             	sub    $0x4,%esp
80108e5a:	6a 06                	push   $0x6
80108e5c:	68 80 6d 19 80       	push   $0x80196d80
80108e61:	50                   	push   %eax
80108e62:	e8 e4 bb ff ff       	call   80104a4b <memmove>
80108e67:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80108e6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e6d:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
80108e72:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e75:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80108e7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e7e:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
80108e82:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e85:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REQUEST;
80108e89:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e8c:	66 c7 40 06 00 01    	movw   $0x100,0x6(%eax)
  memmove(reply_arp->dst_mac,dst_mac_arp,6);
80108e92:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e95:	8d 50 12             	lea    0x12(%eax),%edx
80108e98:	83 ec 04             	sub    $0x4,%esp
80108e9b:	6a 06                	push   $0x6
80108e9d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80108ea0:	50                   	push   %eax
80108ea1:	52                   	push   %edx
80108ea2:	e8 a4 bb ff ff       	call   80104a4b <memmove>
80108ea7:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,dst_ip,4);
80108eaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ead:	8d 50 18             	lea    0x18(%eax),%edx
80108eb0:	83 ec 04             	sub    $0x4,%esp
80108eb3:	6a 04                	push   $0x4
80108eb5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80108eb8:	50                   	push   %eax
80108eb9:	52                   	push   %edx
80108eba:	e8 8c bb ff ff       	call   80104a4b <memmove>
80108ebf:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
80108ec2:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ec5:	83 c0 08             	add    $0x8,%eax
80108ec8:	83 ec 04             	sub    $0x4,%esp
80108ecb:	6a 06                	push   $0x6
80108ecd:	68 80 6d 19 80       	push   $0x80196d80
80108ed2:	50                   	push   %eax
80108ed3:	e8 73 bb ff ff       	call   80104a4b <memmove>
80108ed8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
80108edb:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108ede:	83 c0 0e             	add    $0xe,%eax
80108ee1:	83 ec 04             	sub    $0x4,%esp
80108ee4:	6a 04                	push   $0x4
80108ee6:	68 e4 f4 10 80       	push   $0x8010f4e4
80108eeb:	50                   	push   %eax
80108eec:	e8 5a bb ff ff       	call   80104a4b <memmove>
80108ef1:	83 c4 10             	add    $0x10,%esp
}
80108ef4:	90                   	nop
80108ef5:	c9                   	leave
80108ef6:	c3                   	ret

80108ef7 <arp_table_update>:

void arp_table_update(struct arp_pkt *recv_arp){
80108ef7:	55                   	push   %ebp
80108ef8:	89 e5                	mov    %esp,%ebp
80108efa:	83 ec 18             	sub    $0x18,%esp
  int index = arp_table_search(recv_arp->src_ip);
80108efd:	8b 45 08             	mov    0x8(%ebp),%eax
80108f00:	83 c0 0e             	add    $0xe,%eax
80108f03:	83 ec 0c             	sub    $0xc,%esp
80108f06:	50                   	push   %eax
80108f07:	e8 bc 00 00 00       	call   80108fc8 <arp_table_search>
80108f0c:	83 c4 10             	add    $0x10,%esp
80108f0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(index > -1){
80108f12:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108f16:	78 2d                	js     80108f45 <arp_table_update+0x4e>
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f18:	8b 45 08             	mov    0x8(%ebp),%eax
80108f1b:	8d 48 08             	lea    0x8(%eax),%ecx
80108f1e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f21:	89 d0                	mov    %edx,%eax
80108f23:	c1 e0 02             	shl    $0x2,%eax
80108f26:	01 d0                	add    %edx,%eax
80108f28:	01 c0                	add    %eax,%eax
80108f2a:	01 d0                	add    %edx,%eax
80108f2c:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f31:	83 c0 04             	add    $0x4,%eax
80108f34:	83 ec 04             	sub    $0x4,%esp
80108f37:	6a 06                	push   $0x6
80108f39:	51                   	push   %ecx
80108f3a:	50                   	push   %eax
80108f3b:	e8 0b bb ff ff       	call   80104a4b <memmove>
80108f40:	83 c4 10             	add    $0x10,%esp
80108f43:	eb 70                	jmp    80108fb5 <arp_table_update+0xbe>
  }else{
    index += 1;
80108f45:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
    index = -index;
80108f49:	f7 5d f4             	negl   -0xc(%ebp)
    memmove(arp_table[index].mac,recv_arp->src_mac,6);
80108f4c:	8b 45 08             	mov    0x8(%ebp),%eax
80108f4f:	8d 48 08             	lea    0x8(%eax),%ecx
80108f52:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f55:	89 d0                	mov    %edx,%eax
80108f57:	c1 e0 02             	shl    $0x2,%eax
80108f5a:	01 d0                	add    %edx,%eax
80108f5c:	01 c0                	add    %eax,%eax
80108f5e:	01 d0                	add    %edx,%eax
80108f60:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f65:	83 c0 04             	add    $0x4,%eax
80108f68:	83 ec 04             	sub    $0x4,%esp
80108f6b:	6a 06                	push   $0x6
80108f6d:	51                   	push   %ecx
80108f6e:	50                   	push   %eax
80108f6f:	e8 d7 ba ff ff       	call   80104a4b <memmove>
80108f74:	83 c4 10             	add    $0x10,%esp
    memmove(arp_table[index].ip,recv_arp->src_ip,4);
80108f77:	8b 45 08             	mov    0x8(%ebp),%eax
80108f7a:	8d 48 0e             	lea    0xe(%eax),%ecx
80108f7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108f80:	89 d0                	mov    %edx,%eax
80108f82:	c1 e0 02             	shl    $0x2,%eax
80108f85:	01 d0                	add    %edx,%eax
80108f87:	01 c0                	add    %eax,%eax
80108f89:	01 d0                	add    %edx,%eax
80108f8b:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108f90:	83 ec 04             	sub    $0x4,%esp
80108f93:	6a 04                	push   $0x4
80108f95:	51                   	push   %ecx
80108f96:	50                   	push   %eax
80108f97:	e8 af ba ff ff       	call   80104a4b <memmove>
80108f9c:	83 c4 10             	add    $0x10,%esp
    arp_table[index].use = 1;
80108f9f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80108fa2:	89 d0                	mov    %edx,%eax
80108fa4:	c1 e0 02             	shl    $0x2,%eax
80108fa7:	01 d0                	add    %edx,%eax
80108fa9:	01 c0                	add    %eax,%eax
80108fab:	01 d0                	add    %edx,%eax
80108fad:	05 aa 6d 19 80       	add    $0x80196daa,%eax
80108fb2:	c6 00 01             	movb   $0x1,(%eax)
  }
  print_arp_table(arp_table);
80108fb5:	83 ec 0c             	sub    $0xc,%esp
80108fb8:	68 a0 6d 19 80       	push   $0x80196da0
80108fbd:	e8 83 00 00 00       	call   80109045 <print_arp_table>
80108fc2:	83 c4 10             	add    $0x10,%esp
}
80108fc5:	90                   	nop
80108fc6:	c9                   	leave
80108fc7:	c3                   	ret

80108fc8 <arp_table_search>:

int arp_table_search(uchar *ip){
80108fc8:	55                   	push   %ebp
80108fc9:	89 e5                	mov    %esp,%ebp
80108fcb:	83 ec 18             	sub    $0x18,%esp
  int empty=1;
80108fce:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80108fd5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80108fdc:	eb 59                	jmp    80109037 <arp_table_search+0x6f>
    if(memcmp(arp_table[i].ip,ip,4) == 0){
80108fde:	8b 55 f0             	mov    -0x10(%ebp),%edx
80108fe1:	89 d0                	mov    %edx,%eax
80108fe3:	c1 e0 02             	shl    $0x2,%eax
80108fe6:	01 d0                	add    %edx,%eax
80108fe8:	01 c0                	add    %eax,%eax
80108fea:	01 d0                	add    %edx,%eax
80108fec:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80108ff1:	83 ec 04             	sub    $0x4,%esp
80108ff4:	6a 04                	push   $0x4
80108ff6:	ff 75 08             	push   0x8(%ebp)
80108ff9:	50                   	push   %eax
80108ffa:	e8 f4 b9 ff ff       	call   801049f3 <memcmp>
80108fff:	83 c4 10             	add    $0x10,%esp
80109002:	85 c0                	test   %eax,%eax
80109004:	75 05                	jne    8010900b <arp_table_search+0x43>
      return i;
80109006:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109009:	eb 38                	jmp    80109043 <arp_table_search+0x7b>
    }
    if(arp_table[i].use == 0 && empty == 1){
8010900b:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010900e:	89 d0                	mov    %edx,%eax
80109010:	c1 e0 02             	shl    $0x2,%eax
80109013:	01 d0                	add    %edx,%eax
80109015:	01 c0                	add    %eax,%eax
80109017:	01 d0                	add    %edx,%eax
80109019:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010901e:	0f b6 00             	movzbl (%eax),%eax
80109021:	84 c0                	test   %al,%al
80109023:	75 0e                	jne    80109033 <arp_table_search+0x6b>
80109025:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
80109029:	75 08                	jne    80109033 <arp_table_search+0x6b>
      empty = -i;
8010902b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010902e:	f7 d8                	neg    %eax
80109030:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(int i=0;i<ARP_TABLE_MAX;i++){
80109033:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109037:	83 7d f0 3f          	cmpl   $0x3f,-0x10(%ebp)
8010903b:	7e a1                	jle    80108fde <arp_table_search+0x16>
    }
  }
  return empty-1;
8010903d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109040:	83 e8 01             	sub    $0x1,%eax
}
80109043:	c9                   	leave
80109044:	c3                   	ret

80109045 <print_arp_table>:

void print_arp_table(){
80109045:	55                   	push   %ebp
80109046:	89 e5                	mov    %esp,%ebp
80109048:	83 ec 18             	sub    $0x18,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
8010904b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80109052:	e9 92 00 00 00       	jmp    801090e9 <print_arp_table+0xa4>
    if(arp_table[i].use != 0){
80109057:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010905a:	89 d0                	mov    %edx,%eax
8010905c:	c1 e0 02             	shl    $0x2,%eax
8010905f:	01 d0                	add    %edx,%eax
80109061:	01 c0                	add    %eax,%eax
80109063:	01 d0                	add    %edx,%eax
80109065:	05 aa 6d 19 80       	add    $0x80196daa,%eax
8010906a:	0f b6 00             	movzbl (%eax),%eax
8010906d:	84 c0                	test   %al,%al
8010906f:	74 74                	je     801090e5 <print_arp_table+0xa0>
      cprintf("Entry Num: %d ",i);
80109071:	83 ec 08             	sub    $0x8,%esp
80109074:	ff 75 f4             	push   -0xc(%ebp)
80109077:	68 cf be 10 80       	push   $0x8010becf
8010907c:	e8 73 73 ff ff       	call   801003f4 <cprintf>
80109081:	83 c4 10             	add    $0x10,%esp
      print_ipv4(arp_table[i].ip);
80109084:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109087:	89 d0                	mov    %edx,%eax
80109089:	c1 e0 02             	shl    $0x2,%eax
8010908c:	01 d0                	add    %edx,%eax
8010908e:	01 c0                	add    %eax,%eax
80109090:	01 d0                	add    %edx,%eax
80109092:	05 a0 6d 19 80       	add    $0x80196da0,%eax
80109097:	83 ec 0c             	sub    $0xc,%esp
8010909a:	50                   	push   %eax
8010909b:	e8 54 02 00 00       	call   801092f4 <print_ipv4>
801090a0:	83 c4 10             	add    $0x10,%esp
      cprintf(" ");
801090a3:	83 ec 0c             	sub    $0xc,%esp
801090a6:	68 de be 10 80       	push   $0x8010bede
801090ab:	e8 44 73 ff ff       	call   801003f4 <cprintf>
801090b0:	83 c4 10             	add    $0x10,%esp
      print_mac(arp_table[i].mac);
801090b3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801090b6:	89 d0                	mov    %edx,%eax
801090b8:	c1 e0 02             	shl    $0x2,%eax
801090bb:	01 d0                	add    %edx,%eax
801090bd:	01 c0                	add    %eax,%eax
801090bf:	01 d0                	add    %edx,%eax
801090c1:	05 a0 6d 19 80       	add    $0x80196da0,%eax
801090c6:	83 c0 04             	add    $0x4,%eax
801090c9:	83 ec 0c             	sub    $0xc,%esp
801090cc:	50                   	push   %eax
801090cd:	e8 70 02 00 00       	call   80109342 <print_mac>
801090d2:	83 c4 10             	add    $0x10,%esp
      cprintf("\n");
801090d5:	83 ec 0c             	sub    $0xc,%esp
801090d8:	68 e0 be 10 80       	push   $0x8010bee0
801090dd:	e8 12 73 ff ff       	call   801003f4 <cprintf>
801090e2:	83 c4 10             	add    $0x10,%esp
  for(int i=0;i < ARP_TABLE_MAX;i++){
801090e5:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801090e9:	83 7d f4 3f          	cmpl   $0x3f,-0xc(%ebp)
801090ed:	0f 8e 64 ff ff ff    	jle    80109057 <print_arp_table+0x12>
    }
  }
}
801090f3:	90                   	nop
801090f4:	90                   	nop
801090f5:	c9                   	leave
801090f6:	c3                   	ret

801090f7 <arp_reply_pkt_create>:


void arp_reply_pkt_create(struct arp_pkt *arp_recv,uint send,uint *send_size){
801090f7:	55                   	push   %ebp
801090f8:	89 e5                	mov    %esp,%ebp
801090fa:	83 ec 18             	sub    $0x18,%esp
  *send_size = sizeof(struct eth_pkt) + sizeof(struct arp_pkt);
801090fd:	8b 45 10             	mov    0x10(%ebp),%eax
80109100:	c7 00 2c 00 00 00    	movl   $0x2c,(%eax)
  
  struct eth_pkt *reply_eth = (struct eth_pkt *)send;
80109106:	8b 45 0c             	mov    0xc(%ebp),%eax
80109109:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct arp_pkt *reply_arp = (struct arp_pkt *)(send + sizeof(struct eth_pkt));
8010910c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010910f:	83 c0 0e             	add    $0xe,%eax
80109112:	89 45 f0             	mov    %eax,-0x10(%ebp)

  reply_eth->type[0] = 0x08;
80109115:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109118:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  reply_eth->type[1] = 0x06;
8010911c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010911f:	c6 40 0d 06          	movb   $0x6,0xd(%eax)
  memmove(reply_eth->dst_mac,arp_recv->src_mac,6);
80109123:	8b 45 08             	mov    0x8(%ebp),%eax
80109126:	8d 50 08             	lea    0x8(%eax),%edx
80109129:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010912c:	83 ec 04             	sub    $0x4,%esp
8010912f:	6a 06                	push   $0x6
80109131:	52                   	push   %edx
80109132:	50                   	push   %eax
80109133:	e8 13 b9 ff ff       	call   80104a4b <memmove>
80109138:	83 c4 10             	add    $0x10,%esp
  memmove(reply_eth->src_mac,mac_addr,6);
8010913b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010913e:	83 c0 06             	add    $0x6,%eax
80109141:	83 ec 04             	sub    $0x4,%esp
80109144:	6a 06                	push   $0x6
80109146:	68 80 6d 19 80       	push   $0x80196d80
8010914b:	50                   	push   %eax
8010914c:	e8 fa b8 ff ff       	call   80104a4b <memmove>
80109151:	83 c4 10             	add    $0x10,%esp

  reply_arp->hrd_type = ARP_HARDWARE_TYPE;
80109154:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109157:	66 c7 00 00 01       	movw   $0x100,(%eax)
  reply_arp->pro_type = ARP_PROTOCOL_TYPE;
8010915c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010915f:	66 c7 40 02 08 00    	movw   $0x8,0x2(%eax)
  reply_arp->hrd_len = 6;
80109165:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109168:	c6 40 04 06          	movb   $0x6,0x4(%eax)
  reply_arp->pro_len = 4;
8010916c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010916f:	c6 40 05 04          	movb   $0x4,0x5(%eax)
  reply_arp->op = ARP_OPS_REPLY;
80109173:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109176:	66 c7 40 06 00 02    	movw   $0x200,0x6(%eax)
  memmove(reply_arp->dst_mac,arp_recv->src_mac,6);
8010917c:	8b 45 08             	mov    0x8(%ebp),%eax
8010917f:	8d 50 08             	lea    0x8(%eax),%edx
80109182:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109185:	83 c0 12             	add    $0x12,%eax
80109188:	83 ec 04             	sub    $0x4,%esp
8010918b:	6a 06                	push   $0x6
8010918d:	52                   	push   %edx
8010918e:	50                   	push   %eax
8010918f:	e8 b7 b8 ff ff       	call   80104a4b <memmove>
80109194:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->dst_ip,arp_recv->src_ip,4);
80109197:	8b 45 08             	mov    0x8(%ebp),%eax
8010919a:	8d 50 0e             	lea    0xe(%eax),%edx
8010919d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091a0:	83 c0 18             	add    $0x18,%eax
801091a3:	83 ec 04             	sub    $0x4,%esp
801091a6:	6a 04                	push   $0x4
801091a8:	52                   	push   %edx
801091a9:	50                   	push   %eax
801091aa:	e8 9c b8 ff ff       	call   80104a4b <memmove>
801091af:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_mac,mac_addr,6);
801091b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091b5:	83 c0 08             	add    $0x8,%eax
801091b8:	83 ec 04             	sub    $0x4,%esp
801091bb:	6a 06                	push   $0x6
801091bd:	68 80 6d 19 80       	push   $0x80196d80
801091c2:	50                   	push   %eax
801091c3:	e8 83 b8 ff ff       	call   80104a4b <memmove>
801091c8:	83 c4 10             	add    $0x10,%esp
  memmove(reply_arp->src_ip,my_ip,4);
801091cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801091ce:	83 c0 0e             	add    $0xe,%eax
801091d1:	83 ec 04             	sub    $0x4,%esp
801091d4:	6a 04                	push   $0x4
801091d6:	68 e4 f4 10 80       	push   $0x8010f4e4
801091db:	50                   	push   %eax
801091dc:	e8 6a b8 ff ff       	call   80104a4b <memmove>
801091e1:	83 c4 10             	add    $0x10,%esp
}
801091e4:	90                   	nop
801091e5:	c9                   	leave
801091e6:	c3                   	ret

801091e7 <print_arp_info>:

void print_arp_info(struct arp_pkt* arp_p){
801091e7:	55                   	push   %ebp
801091e8:	89 e5                	mov    %esp,%ebp
801091ea:	83 ec 08             	sub    $0x8,%esp
  cprintf("--------Source-------\n");
801091ed:	83 ec 0c             	sub    $0xc,%esp
801091f0:	68 e2 be 10 80       	push   $0x8010bee2
801091f5:	e8 fa 71 ff ff       	call   801003f4 <cprintf>
801091fa:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->src_ip);
801091fd:	8b 45 08             	mov    0x8(%ebp),%eax
80109200:	83 c0 0e             	add    $0xe,%eax
80109203:	83 ec 0c             	sub    $0xc,%esp
80109206:	50                   	push   %eax
80109207:	e8 e8 00 00 00       	call   801092f4 <print_ipv4>
8010920c:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
8010920f:	83 ec 0c             	sub    $0xc,%esp
80109212:	68 e0 be 10 80       	push   $0x8010bee0
80109217:	e8 d8 71 ff ff       	call   801003f4 <cprintf>
8010921c:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->src_mac);
8010921f:	8b 45 08             	mov    0x8(%ebp),%eax
80109222:	83 c0 08             	add    $0x8,%eax
80109225:	83 ec 0c             	sub    $0xc,%esp
80109228:	50                   	push   %eax
80109229:	e8 14 01 00 00       	call   80109342 <print_mac>
8010922e:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109231:	83 ec 0c             	sub    $0xc,%esp
80109234:	68 e0 be 10 80       	push   $0x8010bee0
80109239:	e8 b6 71 ff ff       	call   801003f4 <cprintf>
8010923e:	83 c4 10             	add    $0x10,%esp
  cprintf("-----Destination-----\n");
80109241:	83 ec 0c             	sub    $0xc,%esp
80109244:	68 f9 be 10 80       	push   $0x8010bef9
80109249:	e8 a6 71 ff ff       	call   801003f4 <cprintf>
8010924e:	83 c4 10             	add    $0x10,%esp
  print_ipv4(arp_p->dst_ip);
80109251:	8b 45 08             	mov    0x8(%ebp),%eax
80109254:	83 c0 18             	add    $0x18,%eax
80109257:	83 ec 0c             	sub    $0xc,%esp
8010925a:	50                   	push   %eax
8010925b:	e8 94 00 00 00       	call   801092f4 <print_ipv4>
80109260:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109263:	83 ec 0c             	sub    $0xc,%esp
80109266:	68 e0 be 10 80       	push   $0x8010bee0
8010926b:	e8 84 71 ff ff       	call   801003f4 <cprintf>
80109270:	83 c4 10             	add    $0x10,%esp
  print_mac(arp_p->dst_mac);
80109273:	8b 45 08             	mov    0x8(%ebp),%eax
80109276:	83 c0 12             	add    $0x12,%eax
80109279:	83 ec 0c             	sub    $0xc,%esp
8010927c:	50                   	push   %eax
8010927d:	e8 c0 00 00 00       	call   80109342 <print_mac>
80109282:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
80109285:	83 ec 0c             	sub    $0xc,%esp
80109288:	68 e0 be 10 80       	push   $0x8010bee0
8010928d:	e8 62 71 ff ff       	call   801003f4 <cprintf>
80109292:	83 c4 10             	add    $0x10,%esp
  cprintf("Operation: ");
80109295:	83 ec 0c             	sub    $0xc,%esp
80109298:	68 10 bf 10 80       	push   $0x8010bf10
8010929d:	e8 52 71 ff ff       	call   801003f4 <cprintf>
801092a2:	83 c4 10             	add    $0x10,%esp
  if(arp_p->op == ARP_OPS_REQUEST) cprintf("Request\n");
801092a5:	8b 45 08             	mov    0x8(%ebp),%eax
801092a8:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092ac:	66 3d 00 01          	cmp    $0x100,%ax
801092b0:	75 12                	jne    801092c4 <print_arp_info+0xdd>
801092b2:	83 ec 0c             	sub    $0xc,%esp
801092b5:	68 1c bf 10 80       	push   $0x8010bf1c
801092ba:	e8 35 71 ff ff       	call   801003f4 <cprintf>
801092bf:	83 c4 10             	add    $0x10,%esp
801092c2:	eb 1d                	jmp    801092e1 <print_arp_info+0xfa>
  else if(arp_p->op == ARP_OPS_REPLY) {
801092c4:	8b 45 08             	mov    0x8(%ebp),%eax
801092c7:	0f b7 40 06          	movzwl 0x6(%eax),%eax
801092cb:	66 3d 00 02          	cmp    $0x200,%ax
801092cf:	75 10                	jne    801092e1 <print_arp_info+0xfa>
    cprintf("Reply\n");
801092d1:	83 ec 0c             	sub    $0xc,%esp
801092d4:	68 25 bf 10 80       	push   $0x8010bf25
801092d9:	e8 16 71 ff ff       	call   801003f4 <cprintf>
801092de:	83 c4 10             	add    $0x10,%esp
  }
  cprintf("\n");
801092e1:	83 ec 0c             	sub    $0xc,%esp
801092e4:	68 e0 be 10 80       	push   $0x8010bee0
801092e9:	e8 06 71 ff ff       	call   801003f4 <cprintf>
801092ee:	83 c4 10             	add    $0x10,%esp
}
801092f1:	90                   	nop
801092f2:	c9                   	leave
801092f3:	c3                   	ret

801092f4 <print_ipv4>:

void print_ipv4(uchar *ip){
801092f4:	55                   	push   %ebp
801092f5:	89 e5                	mov    %esp,%ebp
801092f7:	53                   	push   %ebx
801092f8:	83 ec 04             	sub    $0x4,%esp
  cprintf("IP address: %d.%d.%d.%d",ip[0],ip[1],ip[2],ip[3]);
801092fb:	8b 45 08             	mov    0x8(%ebp),%eax
801092fe:	83 c0 03             	add    $0x3,%eax
80109301:	0f b6 00             	movzbl (%eax),%eax
80109304:	0f b6 d8             	movzbl %al,%ebx
80109307:	8b 45 08             	mov    0x8(%ebp),%eax
8010930a:	83 c0 02             	add    $0x2,%eax
8010930d:	0f b6 00             	movzbl (%eax),%eax
80109310:	0f b6 c8             	movzbl %al,%ecx
80109313:	8b 45 08             	mov    0x8(%ebp),%eax
80109316:	83 c0 01             	add    $0x1,%eax
80109319:	0f b6 00             	movzbl (%eax),%eax
8010931c:	0f b6 d0             	movzbl %al,%edx
8010931f:	8b 45 08             	mov    0x8(%ebp),%eax
80109322:	0f b6 00             	movzbl (%eax),%eax
80109325:	0f b6 c0             	movzbl %al,%eax
80109328:	83 ec 0c             	sub    $0xc,%esp
8010932b:	53                   	push   %ebx
8010932c:	51                   	push   %ecx
8010932d:	52                   	push   %edx
8010932e:	50                   	push   %eax
8010932f:	68 2c bf 10 80       	push   $0x8010bf2c
80109334:	e8 bb 70 ff ff       	call   801003f4 <cprintf>
80109339:	83 c4 20             	add    $0x20,%esp
}
8010933c:	90                   	nop
8010933d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109340:	c9                   	leave
80109341:	c3                   	ret

80109342 <print_mac>:

void print_mac(uchar *mac){
80109342:	55                   	push   %ebp
80109343:	89 e5                	mov    %esp,%ebp
80109345:	57                   	push   %edi
80109346:	56                   	push   %esi
80109347:	53                   	push   %ebx
80109348:	83 ec 0c             	sub    $0xc,%esp
  cprintf("MAC address: %x:%x:%x:%x:%x:%x",mac[0],mac[1],mac[2],mac[3],mac[4],mac[5]);
8010934b:	8b 45 08             	mov    0x8(%ebp),%eax
8010934e:	83 c0 05             	add    $0x5,%eax
80109351:	0f b6 00             	movzbl (%eax),%eax
80109354:	0f b6 f8             	movzbl %al,%edi
80109357:	8b 45 08             	mov    0x8(%ebp),%eax
8010935a:	83 c0 04             	add    $0x4,%eax
8010935d:	0f b6 00             	movzbl (%eax),%eax
80109360:	0f b6 f0             	movzbl %al,%esi
80109363:	8b 45 08             	mov    0x8(%ebp),%eax
80109366:	83 c0 03             	add    $0x3,%eax
80109369:	0f b6 00             	movzbl (%eax),%eax
8010936c:	0f b6 d8             	movzbl %al,%ebx
8010936f:	8b 45 08             	mov    0x8(%ebp),%eax
80109372:	83 c0 02             	add    $0x2,%eax
80109375:	0f b6 00             	movzbl (%eax),%eax
80109378:	0f b6 c8             	movzbl %al,%ecx
8010937b:	8b 45 08             	mov    0x8(%ebp),%eax
8010937e:	83 c0 01             	add    $0x1,%eax
80109381:	0f b6 00             	movzbl (%eax),%eax
80109384:	0f b6 d0             	movzbl %al,%edx
80109387:	8b 45 08             	mov    0x8(%ebp),%eax
8010938a:	0f b6 00             	movzbl (%eax),%eax
8010938d:	0f b6 c0             	movzbl %al,%eax
80109390:	83 ec 04             	sub    $0x4,%esp
80109393:	57                   	push   %edi
80109394:	56                   	push   %esi
80109395:	53                   	push   %ebx
80109396:	51                   	push   %ecx
80109397:	52                   	push   %edx
80109398:	50                   	push   %eax
80109399:	68 44 bf 10 80       	push   $0x8010bf44
8010939e:	e8 51 70 ff ff       	call   801003f4 <cprintf>
801093a3:	83 c4 20             	add    $0x20,%esp
}
801093a6:	90                   	nop
801093a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801093aa:	5b                   	pop    %ebx
801093ab:	5e                   	pop    %esi
801093ac:	5f                   	pop    %edi
801093ad:	5d                   	pop    %ebp
801093ae:	c3                   	ret

801093af <eth_proc>:
#include "arp.h"
#include "types.h"
#include "eth.h"
#include "defs.h"
#include "ipv4.h"
void eth_proc(uint buffer_addr){
801093af:	55                   	push   %ebp
801093b0:	89 e5                	mov    %esp,%ebp
801093b2:	83 ec 18             	sub    $0x18,%esp
  struct eth_pkt *eth_pkt = (struct eth_pkt *)buffer_addr;
801093b5:	8b 45 08             	mov    0x8(%ebp),%eax
801093b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint pkt_addr = buffer_addr+sizeof(struct eth_pkt);
801093bb:	8b 45 08             	mov    0x8(%ebp),%eax
801093be:	83 c0 0e             	add    $0xe,%eax
801093c1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x06){
801093c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093c7:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093cb:	3c 08                	cmp    $0x8,%al
801093cd:	75 1b                	jne    801093ea <eth_proc+0x3b>
801093cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093d2:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093d6:	3c 06                	cmp    $0x6,%al
801093d8:	75 10                	jne    801093ea <eth_proc+0x3b>
    arp_proc(pkt_addr);
801093da:	83 ec 0c             	sub    $0xc,%esp
801093dd:	ff 75 f0             	push   -0x10(%ebp)
801093e0:	e8 01 f8 ff ff       	call   80108be6 <arp_proc>
801093e5:	83 c4 10             	add    $0x10,%esp
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
    ipv4_proc(buffer_addr);
  }else{
  }
}
801093e8:	eb 24                	jmp    8010940e <eth_proc+0x5f>
  }else if(eth_pkt->type[0] == 0x08 && eth_pkt->type[1] == 0x00){
801093ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093ed:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
801093f1:	3c 08                	cmp    $0x8,%al
801093f3:	75 19                	jne    8010940e <eth_proc+0x5f>
801093f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801093f8:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
801093fc:	84 c0                	test   %al,%al
801093fe:	75 0e                	jne    8010940e <eth_proc+0x5f>
    ipv4_proc(buffer_addr);
80109400:	83 ec 0c             	sub    $0xc,%esp
80109403:	ff 75 08             	push   0x8(%ebp)
80109406:	e8 8d 00 00 00       	call   80109498 <ipv4_proc>
8010940b:	83 c4 10             	add    $0x10,%esp
}
8010940e:	90                   	nop
8010940f:	c9                   	leave
80109410:	c3                   	ret

80109411 <N2H_ushort>:

ushort N2H_ushort(ushort value){
80109411:	55                   	push   %ebp
80109412:	89 e5                	mov    %esp,%ebp
80109414:	83 ec 04             	sub    $0x4,%esp
80109417:	8b 45 08             	mov    0x8(%ebp),%eax
8010941a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
8010941e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109422:	66 c1 c0 08          	rol    $0x8,%ax
}
80109426:	c9                   	leave
80109427:	c3                   	ret

80109428 <H2N_ushort>:

ushort H2N_ushort(ushort value){
80109428:	55                   	push   %ebp
80109429:	89 e5                	mov    %esp,%ebp
8010942b:	83 ec 04             	sub    $0x4,%esp
8010942e:	8b 45 08             	mov    0x8(%ebp),%eax
80109431:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  return (((value)&0xFF)<<8)+(value>>8);
80109435:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80109439:	66 c1 c0 08          	rol    $0x8,%ax
}
8010943d:	c9                   	leave
8010943e:	c3                   	ret

8010943f <H2N_uint>:

uint H2N_uint(uint value){
8010943f:	55                   	push   %ebp
80109440:	89 e5                	mov    %esp,%ebp
  return ((value&0xF)<<24)+((value&0xF0)<<8)+((value&0xF00)>>8)+((value&0xF000)>>24);
80109442:	8b 45 08             	mov    0x8(%ebp),%eax
80109445:	c1 e0 18             	shl    $0x18,%eax
80109448:	25 00 00 00 0f       	and    $0xf000000,%eax
8010944d:	89 c2                	mov    %eax,%edx
8010944f:	8b 45 08             	mov    0x8(%ebp),%eax
80109452:	c1 e0 08             	shl    $0x8,%eax
80109455:	25 00 f0 00 00       	and    $0xf000,%eax
8010945a:	09 c2                	or     %eax,%edx
8010945c:	8b 45 08             	mov    0x8(%ebp),%eax
8010945f:	c1 e8 08             	shr    $0x8,%eax
80109462:	83 e0 0f             	and    $0xf,%eax
80109465:	01 d0                	add    %edx,%eax
}
80109467:	5d                   	pop    %ebp
80109468:	c3                   	ret

80109469 <N2H_uint>:

uint N2H_uint(uint value){
80109469:	55                   	push   %ebp
8010946a:	89 e5                	mov    %esp,%ebp
  return ((value&0xFF)<<24)+((value&0xFF00)<<8)+((value&0xFF0000)>>8)+((value&0xFF000000)>>24);
8010946c:	8b 45 08             	mov    0x8(%ebp),%eax
8010946f:	c1 e0 18             	shl    $0x18,%eax
80109472:	89 c2                	mov    %eax,%edx
80109474:	8b 45 08             	mov    0x8(%ebp),%eax
80109477:	c1 e0 08             	shl    $0x8,%eax
8010947a:	25 00 00 ff 00       	and    $0xff0000,%eax
8010947f:	01 c2                	add    %eax,%edx
80109481:	8b 45 08             	mov    0x8(%ebp),%eax
80109484:	c1 e8 08             	shr    $0x8,%eax
80109487:	25 00 ff 00 00       	and    $0xff00,%eax
8010948c:	01 c2                	add    %eax,%edx
8010948e:	8b 45 08             	mov    0x8(%ebp),%eax
80109491:	c1 e8 18             	shr    $0x18,%eax
80109494:	01 d0                	add    %edx,%eax
}
80109496:	5d                   	pop    %ebp
80109497:	c3                   	ret

80109498 <ipv4_proc>:
extern uchar mac_addr[6];
extern uchar my_ip[4];

int ip_id = -1;
ushort send_id = 0;
void ipv4_proc(uint buffer_addr){
80109498:	55                   	push   %ebp
80109499:	89 e5                	mov    %esp,%ebp
8010949b:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+14);
8010949e:	8b 45 08             	mov    0x8(%ebp),%eax
801094a1:	83 c0 0e             	add    $0xe,%eax
801094a4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(ip_id != ipv4_p->id && memcmp(my_ip,ipv4_p->src_ip,4) != 0){
801094a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094aa:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094ae:	0f b7 d0             	movzwl %ax,%edx
801094b1:	a1 e8 f4 10 80       	mov    0x8010f4e8,%eax
801094b6:	39 c2                	cmp    %eax,%edx
801094b8:	74 60                	je     8010951a <ipv4_proc+0x82>
801094ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094bd:	83 c0 0c             	add    $0xc,%eax
801094c0:	83 ec 04             	sub    $0x4,%esp
801094c3:	6a 04                	push   $0x4
801094c5:	50                   	push   %eax
801094c6:	68 e4 f4 10 80       	push   $0x8010f4e4
801094cb:	e8 23 b5 ff ff       	call   801049f3 <memcmp>
801094d0:	83 c4 10             	add    $0x10,%esp
801094d3:	85 c0                	test   %eax,%eax
801094d5:	74 43                	je     8010951a <ipv4_proc+0x82>
    ip_id = ipv4_p->id;
801094d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094da:	0f b7 40 04          	movzwl 0x4(%eax),%eax
801094de:	0f b7 c0             	movzwl %ax,%eax
801094e1:	a3 e8 f4 10 80       	mov    %eax,0x8010f4e8
      if(ipv4_p->protocol == IPV4_TYPE_ICMP){
801094e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801094e9:	0f b6 40 09          	movzbl 0x9(%eax),%eax
801094ed:	3c 01                	cmp    $0x1,%al
801094ef:	75 10                	jne    80109501 <ipv4_proc+0x69>
        icmp_proc(buffer_addr);
801094f1:	83 ec 0c             	sub    $0xc,%esp
801094f4:	ff 75 08             	push   0x8(%ebp)
801094f7:	e8 a3 00 00 00       	call   8010959f <icmp_proc>
801094fc:	83 c4 10             	add    $0x10,%esp
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
        tcp_proc(buffer_addr);
      }
  }
}
801094ff:	eb 19                	jmp    8010951a <ipv4_proc+0x82>
      }else if(ipv4_p->protocol == IPV4_TYPE_TCP){
80109501:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109504:	0f b6 40 09          	movzbl 0x9(%eax),%eax
80109508:	3c 06                	cmp    $0x6,%al
8010950a:	75 0e                	jne    8010951a <ipv4_proc+0x82>
        tcp_proc(buffer_addr);
8010950c:	83 ec 0c             	sub    $0xc,%esp
8010950f:	ff 75 08             	push   0x8(%ebp)
80109512:	e8 b3 03 00 00       	call   801098ca <tcp_proc>
80109517:	83 c4 10             	add    $0x10,%esp
}
8010951a:	90                   	nop
8010951b:	c9                   	leave
8010951c:	c3                   	ret

8010951d <ipv4_chksum>:

ushort ipv4_chksum(uint ipv4_addr){
8010951d:	55                   	push   %ebp
8010951e:	89 e5                	mov    %esp,%ebp
80109520:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)ipv4_addr;
80109523:	8b 45 08             	mov    0x8(%ebp),%eax
80109526:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uchar len = (bin[0]&0xF)*2;
80109529:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010952c:	0f b6 00             	movzbl (%eax),%eax
8010952f:	83 e0 0f             	and    $0xf,%eax
80109532:	01 c0                	add    %eax,%eax
80109534:	88 45 f3             	mov    %al,-0xd(%ebp)
  uint chk_sum = 0;
80109537:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010953e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109545:	eb 48                	jmp    8010958f <ipv4_chksum+0x72>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109547:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010954a:	01 c0                	add    %eax,%eax
8010954c:	89 c2                	mov    %eax,%edx
8010954e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109551:	01 d0                	add    %edx,%eax
80109553:	0f b6 00             	movzbl (%eax),%eax
80109556:	0f b6 c0             	movzbl %al,%eax
80109559:	c1 e0 08             	shl    $0x8,%eax
8010955c:	89 c2                	mov    %eax,%edx
8010955e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109561:	01 c0                	add    %eax,%eax
80109563:	8d 48 01             	lea    0x1(%eax),%ecx
80109566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109569:	01 c8                	add    %ecx,%eax
8010956b:	0f b6 00             	movzbl (%eax),%eax
8010956e:	0f b6 c0             	movzbl %al,%eax
80109571:	01 d0                	add    %edx,%eax
80109573:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
80109576:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
8010957d:	76 0c                	jbe    8010958b <ipv4_chksum+0x6e>
      chk_sum = (chk_sum&0xFFFF)+1;
8010957f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80109582:	0f b7 c0             	movzwl %ax,%eax
80109585:	83 c0 01             	add    $0x1,%eax
80109588:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<len;i++){
8010958b:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
8010958f:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
80109593:	39 45 f8             	cmp    %eax,-0x8(%ebp)
80109596:	7c af                	jl     80109547 <ipv4_chksum+0x2a>
    }
  }
  return ~(chk_sum);
80109598:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010959b:	f7 d0                	not    %eax
}
8010959d:	c9                   	leave
8010959e:	c3                   	ret

8010959f <icmp_proc>:
#include "eth.h"

extern uchar mac_addr[6];
extern uchar my_ip[4];
extern ushort send_id;
void icmp_proc(uint buffer_addr){
8010959f:	55                   	push   %ebp
801095a0:	89 e5                	mov    %esp,%ebp
801095a2:	83 ec 18             	sub    $0x18,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr+sizeof(struct eth_pkt));
801095a5:	8b 45 08             	mov    0x8(%ebp),%eax
801095a8:	83 c0 0e             	add    $0xe,%eax
801095ab:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct icmp_echo_pkt *icmp_p = (struct icmp_echo_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801095ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095b1:	0f b6 00             	movzbl (%eax),%eax
801095b4:	0f b6 c0             	movzbl %al,%eax
801095b7:	83 e0 0f             	and    $0xf,%eax
801095ba:	c1 e0 02             	shl    $0x2,%eax
801095bd:	89 c2                	mov    %eax,%edx
801095bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
801095c2:	01 d0                	add    %edx,%eax
801095c4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(icmp_p->code == 0){
801095c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095ca:	0f b6 40 01          	movzbl 0x1(%eax),%eax
801095ce:	84 c0                	test   %al,%al
801095d0:	75 4f                	jne    80109621 <icmp_proc+0x82>
    if(icmp_p->type == ICMP_TYPE_ECHO_REQUEST){
801095d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801095d5:	0f b6 00             	movzbl (%eax),%eax
801095d8:	3c 08                	cmp    $0x8,%al
801095da:	75 45                	jne    80109621 <icmp_proc+0x82>
      uint send_addr = (uint)kalloc();
801095dc:	e8 c7 91 ff ff       	call   801027a8 <kalloc>
801095e1:	89 45 ec             	mov    %eax,-0x14(%ebp)
      uint send_size = 0;
801095e4:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
      icmp_reply_pkt_create(buffer_addr,send_addr,&send_size);
801095eb:	83 ec 04             	sub    $0x4,%esp
801095ee:	8d 45 e8             	lea    -0x18(%ebp),%eax
801095f1:	50                   	push   %eax
801095f2:	ff 75 ec             	push   -0x14(%ebp)
801095f5:	ff 75 08             	push   0x8(%ebp)
801095f8:	e8 78 00 00 00       	call   80109675 <icmp_reply_pkt_create>
801095fd:	83 c4 10             	add    $0x10,%esp
      i8254_send(send_addr,send_size);
80109600:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109603:	83 ec 08             	sub    $0x8,%esp
80109606:	50                   	push   %eax
80109607:	ff 75 ec             	push   -0x14(%ebp)
8010960a:	e8 ad f4 ff ff       	call   80108abc <i8254_send>
8010960f:	83 c4 10             	add    $0x10,%esp
      kfree((char *)send_addr);
80109612:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109615:	83 ec 0c             	sub    $0xc,%esp
80109618:	50                   	push   %eax
80109619:	e8 f0 90 ff ff       	call   8010270e <kfree>
8010961e:	83 c4 10             	add    $0x10,%esp
    }
  }
}
80109621:	90                   	nop
80109622:	c9                   	leave
80109623:	c3                   	ret

80109624 <icmp_proc_req>:

void icmp_proc_req(struct icmp_echo_pkt * icmp_p){
80109624:	55                   	push   %ebp
80109625:	89 e5                	mov    %esp,%ebp
80109627:	53                   	push   %ebx
80109628:	83 ec 04             	sub    $0x4,%esp
  cprintf("ICMP ID:0x%x SEQ NUM:0x%x\n",N2H_ushort(icmp_p->id),N2H_ushort(icmp_p->seq_num));
8010962b:	8b 45 08             	mov    0x8(%ebp),%eax
8010962e:	0f b7 40 06          	movzwl 0x6(%eax),%eax
80109632:	0f b7 c0             	movzwl %ax,%eax
80109635:	83 ec 0c             	sub    $0xc,%esp
80109638:	50                   	push   %eax
80109639:	e8 d3 fd ff ff       	call   80109411 <N2H_ushort>
8010963e:	83 c4 10             	add    $0x10,%esp
80109641:	0f b7 d8             	movzwl %ax,%ebx
80109644:	8b 45 08             	mov    0x8(%ebp),%eax
80109647:	0f b7 40 04          	movzwl 0x4(%eax),%eax
8010964b:	0f b7 c0             	movzwl %ax,%eax
8010964e:	83 ec 0c             	sub    $0xc,%esp
80109651:	50                   	push   %eax
80109652:	e8 ba fd ff ff       	call   80109411 <N2H_ushort>
80109657:	83 c4 10             	add    $0x10,%esp
8010965a:	0f b7 c0             	movzwl %ax,%eax
8010965d:	83 ec 04             	sub    $0x4,%esp
80109660:	53                   	push   %ebx
80109661:	50                   	push   %eax
80109662:	68 63 bf 10 80       	push   $0x8010bf63
80109667:	e8 88 6d ff ff       	call   801003f4 <cprintf>
8010966c:	83 c4 10             	add    $0x10,%esp
}
8010966f:	90                   	nop
80109670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80109673:	c9                   	leave
80109674:	c3                   	ret

80109675 <icmp_reply_pkt_create>:

void icmp_reply_pkt_create(uint recv_addr,uint send_addr,uint *send_size){
80109675:	55                   	push   %ebp
80109676:	89 e5                	mov    %esp,%ebp
80109678:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
8010967b:	8b 45 08             	mov    0x8(%ebp),%eax
8010967e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109681:	8b 45 08             	mov    0x8(%ebp),%eax
80109684:	83 c0 0e             	add    $0xe,%eax
80109687:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct icmp_echo_pkt *icmp_recv = (struct icmp_echo_pkt *)((uint)ipv4_recv+(ipv4_recv->ver&0xF)*4);
8010968a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010968d:	0f b6 00             	movzbl (%eax),%eax
80109690:	0f b6 c0             	movzbl %al,%eax
80109693:	83 e0 0f             	and    $0xf,%eax
80109696:	c1 e0 02             	shl    $0x2,%eax
80109699:	89 c2                	mov    %eax,%edx
8010969b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010969e:	01 d0                	add    %edx,%eax
801096a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
801096a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801096a6:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr+sizeof(struct eth_pkt));
801096a9:	8b 45 0c             	mov    0xc(%ebp),%eax
801096ac:	83 c0 0e             	add    $0xe,%eax
801096af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct icmp_echo_pkt *icmp_send = (struct icmp_echo_pkt *)((uint)ipv4_send+sizeof(struct ipv4_pkt));
801096b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801096b5:	83 c0 14             	add    $0x14,%eax
801096b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  
  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt);
801096bb:	8b 45 10             	mov    0x10(%ebp),%eax
801096be:	c7 00 62 00 00 00    	movl   $0x62,(%eax)
  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
801096c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801096c7:	8d 50 06             	lea    0x6(%eax),%edx
801096ca:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096cd:	83 ec 04             	sub    $0x4,%esp
801096d0:	6a 06                	push   $0x6
801096d2:	52                   	push   %edx
801096d3:	50                   	push   %eax
801096d4:	e8 72 b3 ff ff       	call   80104a4b <memmove>
801096d9:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
801096dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096df:	83 c0 06             	add    $0x6,%eax
801096e2:	83 ec 04             	sub    $0x4,%esp
801096e5:	6a 06                	push   $0x6
801096e7:	68 80 6d 19 80       	push   $0x80196d80
801096ec:	50                   	push   %eax
801096ed:	e8 59 b3 ff ff       	call   80104a4b <memmove>
801096f2:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
801096f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096f8:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
801096fc:	8b 45 e8             	mov    -0x18(%ebp),%eax
801096ff:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109703:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109706:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109709:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010970c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct icmp_echo_pkt));
80109710:	83 ec 0c             	sub    $0xc,%esp
80109713:	6a 54                	push   $0x54
80109715:	e8 0e fd ff ff       	call   80109428 <H2N_ushort>
8010971a:	83 c4 10             	add    $0x10,%esp
8010971d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109720:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109724:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
8010972b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010972e:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109732:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109739:	83 c0 01             	add    $0x1,%eax
8010973c:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x4000);
80109742:	83 ec 0c             	sub    $0xc,%esp
80109745:	68 00 40 00 00       	push   $0x4000
8010974a:	e8 d9 fc ff ff       	call   80109428 <H2N_ushort>
8010974f:	83 c4 10             	add    $0x10,%esp
80109752:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109755:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109759:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010975c:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = 0x1;
80109760:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109763:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109767:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010976a:	83 c0 0c             	add    $0xc,%eax
8010976d:	83 ec 04             	sub    $0x4,%esp
80109770:	6a 04                	push   $0x4
80109772:	68 e4 f4 10 80       	push   $0x8010f4e4
80109777:	50                   	push   %eax
80109778:	e8 ce b2 ff ff       	call   80104a4b <memmove>
8010977d:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109780:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109783:	8d 50 0c             	lea    0xc(%eax),%edx
80109786:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109789:	83 c0 10             	add    $0x10,%eax
8010978c:	83 ec 04             	sub    $0x4,%esp
8010978f:	6a 04                	push   $0x4
80109791:	52                   	push   %edx
80109792:	50                   	push   %eax
80109793:	e8 b3 b2 ff ff       	call   80104a4b <memmove>
80109798:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
8010979b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010979e:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
801097a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801097a7:	83 ec 0c             	sub    $0xc,%esp
801097aa:	50                   	push   %eax
801097ab:	e8 6d fd ff ff       	call   8010951d <ipv4_chksum>
801097b0:	83 c4 10             	add    $0x10,%esp
801097b3:	0f b7 c0             	movzwl %ax,%eax
801097b6:	83 ec 0c             	sub    $0xc,%esp
801097b9:	50                   	push   %eax
801097ba:	e8 69 fc ff ff       	call   80109428 <H2N_ushort>
801097bf:	83 c4 10             	add    $0x10,%esp
801097c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801097c5:	66 89 42 0a          	mov    %ax,0xa(%edx)

  icmp_send->type = ICMP_TYPE_ECHO_REPLY;
801097c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097cc:	c6 00 00             	movb   $0x0,(%eax)
  icmp_send->code = 0;
801097cf:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097d2:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  icmp_send->id = icmp_recv->id;
801097d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097d9:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801097dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097e0:	66 89 50 04          	mov    %dx,0x4(%eax)
  icmp_send->seq_num = icmp_recv->seq_num;
801097e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097e7:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801097eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097ee:	66 89 50 06          	mov    %dx,0x6(%eax)
  memmove(icmp_send->time_stamp,icmp_recv->time_stamp,8);
801097f2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801097f5:	8d 50 08             	lea    0x8(%eax),%edx
801097f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801097fb:	83 c0 08             	add    $0x8,%eax
801097fe:	83 ec 04             	sub    $0x4,%esp
80109801:	6a 08                	push   $0x8
80109803:	52                   	push   %edx
80109804:	50                   	push   %eax
80109805:	e8 41 b2 ff ff       	call   80104a4b <memmove>
8010980a:	83 c4 10             	add    $0x10,%esp
  memmove(icmp_send->data,icmp_recv->data,48);
8010980d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109810:	8d 50 10             	lea    0x10(%eax),%edx
80109813:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109816:	83 c0 10             	add    $0x10,%eax
80109819:	83 ec 04             	sub    $0x4,%esp
8010981c:	6a 30                	push   $0x30
8010981e:	52                   	push   %edx
8010981f:	50                   	push   %eax
80109820:	e8 26 b2 ff ff       	call   80104a4b <memmove>
80109825:	83 c4 10             	add    $0x10,%esp
  icmp_send->chk_sum = 0;
80109828:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010982b:	66 c7 40 02 00 00    	movw   $0x0,0x2(%eax)
  icmp_send->chk_sum = H2N_ushort(icmp_chksum((uint)icmp_send));
80109831:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109834:	83 ec 0c             	sub    $0xc,%esp
80109837:	50                   	push   %eax
80109838:	e8 1c 00 00 00       	call   80109859 <icmp_chksum>
8010983d:	83 c4 10             	add    $0x10,%esp
80109840:	0f b7 c0             	movzwl %ax,%eax
80109843:	83 ec 0c             	sub    $0xc,%esp
80109846:	50                   	push   %eax
80109847:	e8 dc fb ff ff       	call   80109428 <H2N_ushort>
8010984c:	83 c4 10             	add    $0x10,%esp
8010984f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109852:	66 89 42 02          	mov    %ax,0x2(%edx)
}
80109856:	90                   	nop
80109857:	c9                   	leave
80109858:	c3                   	ret

80109859 <icmp_chksum>:

ushort icmp_chksum(uint icmp_addr){
80109859:	55                   	push   %ebp
8010985a:	89 e5                	mov    %esp,%ebp
8010985c:	83 ec 10             	sub    $0x10,%esp
  uchar* bin = (uchar *)icmp_addr;
8010985f:	8b 45 08             	mov    0x8(%ebp),%eax
80109862:	89 45 f4             	mov    %eax,-0xc(%ebp)
  uint chk_sum = 0;
80109865:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  for(int i=0;i<32;i++){
8010986c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80109873:	eb 48                	jmp    801098bd <icmp_chksum+0x64>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109875:	8b 45 f8             	mov    -0x8(%ebp),%eax
80109878:	01 c0                	add    %eax,%eax
8010987a:	89 c2                	mov    %eax,%edx
8010987c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010987f:	01 d0                	add    %edx,%eax
80109881:	0f b6 00             	movzbl (%eax),%eax
80109884:	0f b6 c0             	movzbl %al,%eax
80109887:	c1 e0 08             	shl    $0x8,%eax
8010988a:	89 c2                	mov    %eax,%edx
8010988c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010988f:	01 c0                	add    %eax,%eax
80109891:	8d 48 01             	lea    0x1(%eax),%ecx
80109894:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109897:	01 c8                	add    %ecx,%eax
80109899:	0f b6 00             	movzbl (%eax),%eax
8010989c:	0f b6 c0             	movzbl %al,%eax
8010989f:	01 d0                	add    %edx,%eax
801098a1:	01 45 fc             	add    %eax,-0x4(%ebp)
    if(chk_sum > 0xFFFF){
801098a4:	81 7d fc ff ff 00 00 	cmpl   $0xffff,-0x4(%ebp)
801098ab:	76 0c                	jbe    801098b9 <icmp_chksum+0x60>
      chk_sum = (chk_sum&0xFFFF)+1;
801098ad:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098b0:	0f b7 c0             	movzwl %ax,%eax
801098b3:	83 c0 01             	add    $0x1,%eax
801098b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(int i=0;i<32;i++){
801098b9:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801098bd:	83 7d f8 1f          	cmpl   $0x1f,-0x8(%ebp)
801098c1:	7e b2                	jle    80109875 <icmp_chksum+0x1c>
    }
  }
  return ~(chk_sum);
801098c3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801098c6:	f7 d0                	not    %eax
}
801098c8:	c9                   	leave
801098c9:	c3                   	ret

801098ca <tcp_proc>:
extern ushort send_id;
extern uchar mac_addr[6];
extern uchar my_ip[4];
int fin_flag = 0;

void tcp_proc(uint buffer_addr){
801098ca:	55                   	push   %ebp
801098cb:	89 e5                	mov    %esp,%ebp
801098cd:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(buffer_addr + sizeof(struct eth_pkt));
801098d0:	8b 45 08             	mov    0x8(%ebp),%eax
801098d3:	83 c0 0e             	add    $0xe,%eax
801098d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + (ipv4_p->ver&0xF)*4);
801098d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098dc:	0f b6 00             	movzbl (%eax),%eax
801098df:	0f b6 c0             	movzbl %al,%eax
801098e2:	83 e0 0f             	and    $0xf,%eax
801098e5:	c1 e0 02             	shl    $0x2,%eax
801098e8:	89 c2                	mov    %eax,%edx
801098ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801098ed:	01 d0                	add    %edx,%eax
801098ef:	89 45 f0             	mov    %eax,-0x10(%ebp)
  char *payload = (char *)((uint)tcp_p + 20);
801098f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801098f5:	83 c0 14             	add    $0x14,%eax
801098f8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  uint send_addr = (uint)kalloc();
801098fb:	e8 a8 8e ff ff       	call   801027a8 <kalloc>
80109900:	89 45 e8             	mov    %eax,-0x18(%ebp)
  uint send_size = 0;
80109903:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  if(tcp_p->code_bits[1]&TCP_CODEBITS_SYN){
8010990a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010990d:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109911:	0f b6 c0             	movzbl %al,%eax
80109914:	83 e0 02             	and    $0x2,%eax
80109917:	85 c0                	test   %eax,%eax
80109919:	74 3d                	je     80109958 <tcp_proc+0x8e>
    tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK | TCP_CODEBITS_SYN,0);
8010991b:	83 ec 0c             	sub    $0xc,%esp
8010991e:	6a 00                	push   $0x0
80109920:	6a 12                	push   $0x12
80109922:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109925:	50                   	push   %eax
80109926:	ff 75 e8             	push   -0x18(%ebp)
80109929:	ff 75 08             	push   0x8(%ebp)
8010992c:	e8 a2 01 00 00       	call   80109ad3 <tcp_pkt_create>
80109931:	83 c4 20             	add    $0x20,%esp
    i8254_send(send_addr,send_size);
80109934:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109937:	83 ec 08             	sub    $0x8,%esp
8010993a:	50                   	push   %eax
8010993b:	ff 75 e8             	push   -0x18(%ebp)
8010993e:	e8 79 f1 ff ff       	call   80108abc <i8254_send>
80109943:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109946:	a1 64 70 19 80       	mov    0x80197064,%eax
8010994b:	83 c0 01             	add    $0x1,%eax
8010994e:	a3 64 70 19 80       	mov    %eax,0x80197064
80109953:	e9 69 01 00 00       	jmp    80109ac1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == (TCP_CODEBITS_PSH | TCP_CODEBITS_ACK)){
80109958:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010995b:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
8010995f:	3c 18                	cmp    $0x18,%al
80109961:	0f 85 10 01 00 00    	jne    80109a77 <tcp_proc+0x1ad>
    if(memcmp(payload,"GET",3)){
80109967:	83 ec 04             	sub    $0x4,%esp
8010996a:	6a 03                	push   $0x3
8010996c:	68 7e bf 10 80       	push   $0x8010bf7e
80109971:	ff 75 ec             	push   -0x14(%ebp)
80109974:	e8 7a b0 ff ff       	call   801049f3 <memcmp>
80109979:	83 c4 10             	add    $0x10,%esp
8010997c:	85 c0                	test   %eax,%eax
8010997e:	74 74                	je     801099f4 <tcp_proc+0x12a>
      cprintf("ACK PSH\n");
80109980:	83 ec 0c             	sub    $0xc,%esp
80109983:	68 82 bf 10 80       	push   $0x8010bf82
80109988:	e8 67 6a ff ff       	call   801003f4 <cprintf>
8010998d:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
80109990:	83 ec 0c             	sub    $0xc,%esp
80109993:	6a 00                	push   $0x0
80109995:	6a 10                	push   $0x10
80109997:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010999a:	50                   	push   %eax
8010999b:	ff 75 e8             	push   -0x18(%ebp)
8010999e:	ff 75 08             	push   0x8(%ebp)
801099a1:	e8 2d 01 00 00       	call   80109ad3 <tcp_pkt_create>
801099a6:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
801099a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
801099ac:	83 ec 08             	sub    $0x8,%esp
801099af:	50                   	push   %eax
801099b0:	ff 75 e8             	push   -0x18(%ebp)
801099b3:	e8 04 f1 ff ff       	call   80108abc <i8254_send>
801099b8:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
801099bb:	8b 45 e8             	mov    -0x18(%ebp),%eax
801099be:	83 c0 36             	add    $0x36,%eax
801099c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
801099c4:	8d 45 d8             	lea    -0x28(%ebp),%eax
801099c7:	50                   	push   %eax
801099c8:	ff 75 e0             	push   -0x20(%ebp)
801099cb:	6a 00                	push   $0x0
801099cd:	6a 00                	push   $0x0
801099cf:	e8 5a 04 00 00       	call   80109e2e <http_proc>
801099d4:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
801099d7:	8b 45 d8             	mov    -0x28(%ebp),%eax
801099da:	83 ec 0c             	sub    $0xc,%esp
801099dd:	50                   	push   %eax
801099de:	6a 18                	push   $0x18
801099e0:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099e3:	50                   	push   %eax
801099e4:	ff 75 e8             	push   -0x18(%ebp)
801099e7:	ff 75 08             	push   0x8(%ebp)
801099ea:	e8 e4 00 00 00       	call   80109ad3 <tcp_pkt_create>
801099ef:	83 c4 20             	add    $0x20,%esp
801099f2:	eb 62                	jmp    80109a56 <tcp_proc+0x18c>
    }else{
     tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_ACK,0);
801099f4:	83 ec 0c             	sub    $0xc,%esp
801099f7:	6a 00                	push   $0x0
801099f9:	6a 10                	push   $0x10
801099fb:	8d 45 dc             	lea    -0x24(%ebp),%eax
801099fe:	50                   	push   %eax
801099ff:	ff 75 e8             	push   -0x18(%ebp)
80109a02:	ff 75 08             	push   0x8(%ebp)
80109a05:	e8 c9 00 00 00       	call   80109ad3 <tcp_pkt_create>
80109a0a:	83 c4 20             	add    $0x20,%esp
     i8254_send(send_addr,send_size);
80109a0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a10:	83 ec 08             	sub    $0x8,%esp
80109a13:	50                   	push   %eax
80109a14:	ff 75 e8             	push   -0x18(%ebp)
80109a17:	e8 a0 f0 ff ff       	call   80108abc <i8254_send>
80109a1c:	83 c4 10             	add    $0x10,%esp
      uint send_payload = (send_addr + sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt));
80109a1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109a22:	83 c0 36             	add    $0x36,%eax
80109a25:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      uint payload_size;
      http_proc(0,0,send_payload,&payload_size);
80109a28:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109a2b:	50                   	push   %eax
80109a2c:	ff 75 e4             	push   -0x1c(%ebp)
80109a2f:	6a 00                	push   $0x0
80109a31:	6a 00                	push   $0x0
80109a33:	e8 f6 03 00 00       	call   80109e2e <http_proc>
80109a38:	83 c4 10             	add    $0x10,%esp
      tcp_pkt_create(buffer_addr,send_addr,&send_size,(TCP_CODEBITS_ACK|TCP_CODEBITS_PSH),payload_size);
80109a3b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80109a3e:	83 ec 0c             	sub    $0xc,%esp
80109a41:	50                   	push   %eax
80109a42:	6a 18                	push   $0x18
80109a44:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a47:	50                   	push   %eax
80109a48:	ff 75 e8             	push   -0x18(%ebp)
80109a4b:	ff 75 08             	push   0x8(%ebp)
80109a4e:	e8 80 00 00 00       	call   80109ad3 <tcp_pkt_create>
80109a53:	83 c4 20             	add    $0x20,%esp
    }
    i8254_send(send_addr,send_size);
80109a56:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109a59:	83 ec 08             	sub    $0x8,%esp
80109a5c:	50                   	push   %eax
80109a5d:	ff 75 e8             	push   -0x18(%ebp)
80109a60:	e8 57 f0 ff ff       	call   80108abc <i8254_send>
80109a65:	83 c4 10             	add    $0x10,%esp
    seq_num++;
80109a68:	a1 64 70 19 80       	mov    0x80197064,%eax
80109a6d:	83 c0 01             	add    $0x1,%eax
80109a70:	a3 64 70 19 80       	mov    %eax,0x80197064
80109a75:	eb 4a                	jmp    80109ac1 <tcp_proc+0x1f7>
  }else if(tcp_p->code_bits[1] == TCP_CODEBITS_ACK){
80109a77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109a7a:	0f b6 40 0d          	movzbl 0xd(%eax),%eax
80109a7e:	3c 10                	cmp    $0x10,%al
80109a80:	75 3f                	jne    80109ac1 <tcp_proc+0x1f7>
    if(fin_flag == 1){
80109a82:	a1 68 70 19 80       	mov    0x80197068,%eax
80109a87:	83 f8 01             	cmp    $0x1,%eax
80109a8a:	75 35                	jne    80109ac1 <tcp_proc+0x1f7>
      tcp_pkt_create(buffer_addr,send_addr,&send_size,TCP_CODEBITS_FIN,0);
80109a8c:	83 ec 0c             	sub    $0xc,%esp
80109a8f:	6a 00                	push   $0x0
80109a91:	6a 01                	push   $0x1
80109a93:	8d 45 dc             	lea    -0x24(%ebp),%eax
80109a96:	50                   	push   %eax
80109a97:	ff 75 e8             	push   -0x18(%ebp)
80109a9a:	ff 75 08             	push   0x8(%ebp)
80109a9d:	e8 31 00 00 00       	call   80109ad3 <tcp_pkt_create>
80109aa2:	83 c4 20             	add    $0x20,%esp
      i8254_send(send_addr,send_size);
80109aa5:	8b 45 dc             	mov    -0x24(%ebp),%eax
80109aa8:	83 ec 08             	sub    $0x8,%esp
80109aab:	50                   	push   %eax
80109aac:	ff 75 e8             	push   -0x18(%ebp)
80109aaf:	e8 08 f0 ff ff       	call   80108abc <i8254_send>
80109ab4:	83 c4 10             	add    $0x10,%esp
      fin_flag = 0;
80109ab7:	c7 05 68 70 19 80 00 	movl   $0x0,0x80197068
80109abe:	00 00 00 
    }
  }
  kfree((char *)send_addr);
80109ac1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109ac4:	83 ec 0c             	sub    $0xc,%esp
80109ac7:	50                   	push   %eax
80109ac8:	e8 41 8c ff ff       	call   8010270e <kfree>
80109acd:	83 c4 10             	add    $0x10,%esp
}
80109ad0:	90                   	nop
80109ad1:	c9                   	leave
80109ad2:	c3                   	ret

80109ad3 <tcp_pkt_create>:

void tcp_pkt_create(uint recv_addr,uint send_addr,uint *send_size,uint pkt_type,uint payload_size){
80109ad3:	55                   	push   %ebp
80109ad4:	89 e5                	mov    %esp,%ebp
80109ad6:	83 ec 28             	sub    $0x28,%esp
  struct eth_pkt *eth_recv = (struct eth_pkt *)(recv_addr);
80109ad9:	8b 45 08             	mov    0x8(%ebp),%eax
80109adc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct ipv4_pkt *ipv4_recv = (struct ipv4_pkt *)(recv_addr+sizeof(struct eth_pkt));
80109adf:	8b 45 08             	mov    0x8(%ebp),%eax
80109ae2:	83 c0 0e             	add    $0xe,%eax
80109ae5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct tcp_pkt *tcp_recv = (struct tcp_pkt *)((uint)ipv4_recv + (ipv4_recv->ver&0xF)*4);
80109ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109aeb:	0f b6 00             	movzbl (%eax),%eax
80109aee:	0f b6 c0             	movzbl %al,%eax
80109af1:	83 e0 0f             	and    $0xf,%eax
80109af4:	c1 e0 02             	shl    $0x2,%eax
80109af7:	89 c2                	mov    %eax,%edx
80109af9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109afc:	01 d0                	add    %edx,%eax
80109afe:	89 45 ec             	mov    %eax,-0x14(%ebp)

  struct eth_pkt *eth_send = (struct eth_pkt *)(send_addr);
80109b01:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b04:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct ipv4_pkt *ipv4_send = (struct ipv4_pkt *)(send_addr + sizeof(struct eth_pkt));
80109b07:	8b 45 0c             	mov    0xc(%ebp),%eax
80109b0a:	83 c0 0e             	add    $0xe,%eax
80109b0d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_pkt *tcp_send = (struct tcp_pkt *)((uint)ipv4_send + sizeof(struct ipv4_pkt));
80109b10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b13:	83 c0 14             	add    $0x14,%eax
80109b16:	89 45 e0             	mov    %eax,-0x20(%ebp)

  *send_size = sizeof(struct eth_pkt) + sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size;
80109b19:	8b 45 18             	mov    0x18(%ebp),%eax
80109b1c:	8d 50 36             	lea    0x36(%eax),%edx
80109b1f:	8b 45 10             	mov    0x10(%ebp),%eax
80109b22:	89 10                	mov    %edx,(%eax)

  memmove(eth_send->dst_mac,eth_recv->src_mac,6);
80109b24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109b27:	8d 50 06             	lea    0x6(%eax),%edx
80109b2a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b2d:	83 ec 04             	sub    $0x4,%esp
80109b30:	6a 06                	push   $0x6
80109b32:	52                   	push   %edx
80109b33:	50                   	push   %eax
80109b34:	e8 12 af ff ff       	call   80104a4b <memmove>
80109b39:	83 c4 10             	add    $0x10,%esp
  memmove(eth_send->src_mac,mac_addr,6);
80109b3c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b3f:	83 c0 06             	add    $0x6,%eax
80109b42:	83 ec 04             	sub    $0x4,%esp
80109b45:	6a 06                	push   $0x6
80109b47:	68 80 6d 19 80       	push   $0x80196d80
80109b4c:	50                   	push   %eax
80109b4d:	e8 f9 ae ff ff       	call   80104a4b <memmove>
80109b52:	83 c4 10             	add    $0x10,%esp
  eth_send->type[0] = 0x08;
80109b55:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b58:	c6 40 0c 08          	movb   $0x8,0xc(%eax)
  eth_send->type[1] = 0x00;
80109b5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109b5f:	c6 40 0d 00          	movb   $0x0,0xd(%eax)

  ipv4_send->ver = ((0x4)<<4)+((sizeof(struct ipv4_pkt)/4)&0xF);
80109b63:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b66:	c6 00 45             	movb   $0x45,(%eax)
  ipv4_send->srv_type = 0;
80109b69:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b6c:	c6 40 01 00          	movb   $0x0,0x1(%eax)
  ipv4_send->total_len = H2N_ushort(sizeof(struct ipv4_pkt) + sizeof(struct tcp_pkt) + payload_size);
80109b70:	8b 45 18             	mov    0x18(%ebp),%eax
80109b73:	83 c0 28             	add    $0x28,%eax
80109b76:	0f b7 c0             	movzwl %ax,%eax
80109b79:	83 ec 0c             	sub    $0xc,%esp
80109b7c:	50                   	push   %eax
80109b7d:	e8 a6 f8 ff ff       	call   80109428 <H2N_ushort>
80109b82:	83 c4 10             	add    $0x10,%esp
80109b85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109b88:	66 89 42 02          	mov    %ax,0x2(%edx)
  ipv4_send->id = send_id;
80109b8c:	0f b7 15 60 70 19 80 	movzwl 0x80197060,%edx
80109b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109b96:	66 89 50 04          	mov    %dx,0x4(%eax)
  send_id++;
80109b9a:	0f b7 05 60 70 19 80 	movzwl 0x80197060,%eax
80109ba1:	83 c0 01             	add    $0x1,%eax
80109ba4:	66 a3 60 70 19 80    	mov    %ax,0x80197060
  ipv4_send->fragment = H2N_ushort(0x0000);
80109baa:	83 ec 0c             	sub    $0xc,%esp
80109bad:	6a 00                	push   $0x0
80109baf:	e8 74 f8 ff ff       	call   80109428 <H2N_ushort>
80109bb4:	83 c4 10             	add    $0x10,%esp
80109bb7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109bba:	66 89 42 06          	mov    %ax,0x6(%edx)
  ipv4_send->ttl = 255;
80109bbe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc1:	c6 40 08 ff          	movb   $0xff,0x8(%eax)
  ipv4_send->protocol = IPV4_TYPE_TCP;
80109bc5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bc8:	c6 40 09 06          	movb   $0x6,0x9(%eax)
  memmove(ipv4_send->src_ip,my_ip,4);
80109bcc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bcf:	83 c0 0c             	add    $0xc,%eax
80109bd2:	83 ec 04             	sub    $0x4,%esp
80109bd5:	6a 04                	push   $0x4
80109bd7:	68 e4 f4 10 80       	push   $0x8010f4e4
80109bdc:	50                   	push   %eax
80109bdd:	e8 69 ae ff ff       	call   80104a4b <memmove>
80109be2:	83 c4 10             	add    $0x10,%esp
  memmove(ipv4_send->dst_ip,ipv4_recv->src_ip,4);
80109be5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109be8:	8d 50 0c             	lea    0xc(%eax),%edx
80109beb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109bee:	83 c0 10             	add    $0x10,%eax
80109bf1:	83 ec 04             	sub    $0x4,%esp
80109bf4:	6a 04                	push   $0x4
80109bf6:	52                   	push   %edx
80109bf7:	50                   	push   %eax
80109bf8:	e8 4e ae ff ff       	call   80104a4b <memmove>
80109bfd:	83 c4 10             	add    $0x10,%esp
  ipv4_send->chk_sum = 0;
80109c00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c03:	66 c7 40 0a 00 00    	movw   $0x0,0xa(%eax)
  ipv4_send->chk_sum = H2N_ushort(ipv4_chksum((uint)ipv4_send));
80109c09:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109c0c:	83 ec 0c             	sub    $0xc,%esp
80109c0f:	50                   	push   %eax
80109c10:	e8 08 f9 ff ff       	call   8010951d <ipv4_chksum>
80109c15:	83 c4 10             	add    $0x10,%esp
80109c18:	0f b7 c0             	movzwl %ax,%eax
80109c1b:	83 ec 0c             	sub    $0xc,%esp
80109c1e:	50                   	push   %eax
80109c1f:	e8 04 f8 ff ff       	call   80109428 <H2N_ushort>
80109c24:	83 c4 10             	add    $0x10,%esp
80109c27:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80109c2a:	66 89 42 0a          	mov    %ax,0xa(%edx)
  

  tcp_send->src_port = tcp_recv->dst_port;
80109c2e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c31:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80109c35:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c38:	66 89 10             	mov    %dx,(%eax)
  tcp_send->dst_port = tcp_recv->src_port;
80109c3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c3e:	0f b7 10             	movzwl (%eax),%edx
80109c41:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c44:	66 89 50 02          	mov    %dx,0x2(%eax)
  tcp_send->seq_num = H2N_uint(seq_num);
80109c48:	a1 64 70 19 80       	mov    0x80197064,%eax
80109c4d:	83 ec 0c             	sub    $0xc,%esp
80109c50:	50                   	push   %eax
80109c51:	e8 e9 f7 ff ff       	call   8010943f <H2N_uint>
80109c56:	83 c4 10             	add    $0x10,%esp
80109c59:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109c5c:	89 42 04             	mov    %eax,0x4(%edx)
  tcp_send->ack_num = tcp_recv->seq_num + (1<<(8*3));
80109c5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109c62:	8b 40 04             	mov    0x4(%eax),%eax
80109c65:	8d 90 00 00 00 01    	lea    0x1000000(%eax),%edx
80109c6b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c6e:	89 50 08             	mov    %edx,0x8(%eax)

  tcp_send->code_bits[0] = 0;
80109c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c74:	c6 40 0c 00          	movb   $0x0,0xc(%eax)
  tcp_send->code_bits[1] = 0;
80109c78:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c7b:	c6 40 0d 00          	movb   $0x0,0xd(%eax)
  tcp_send->code_bits[0] = 5<<4;
80109c7f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c82:	c6 40 0c 50          	movb   $0x50,0xc(%eax)
  tcp_send->code_bits[1] = pkt_type;
80109c86:	8b 45 14             	mov    0x14(%ebp),%eax
80109c89:	89 c2                	mov    %eax,%edx
80109c8b:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109c8e:	88 50 0d             	mov    %dl,0xd(%eax)

  tcp_send->window = H2N_ushort(14480);
80109c91:	83 ec 0c             	sub    $0xc,%esp
80109c94:	68 90 38 00 00       	push   $0x3890
80109c99:	e8 8a f7 ff ff       	call   80109428 <H2N_ushort>
80109c9e:	83 c4 10             	add    $0x10,%esp
80109ca1:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109ca4:	66 89 42 0e          	mov    %ax,0xe(%edx)
  tcp_send->urgent_ptr = 0;
80109ca8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cab:	66 c7 40 12 00 00    	movw   $0x0,0x12(%eax)
  tcp_send->chk_sum = 0;
80109cb1:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109cb4:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)

  tcp_send->chk_sum = H2N_ushort(tcp_chksum((uint)(ipv4_send))+8);
80109cba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109cbd:	83 ec 0c             	sub    $0xc,%esp
80109cc0:	50                   	push   %eax
80109cc1:	e8 1f 00 00 00       	call   80109ce5 <tcp_chksum>
80109cc6:	83 c4 10             	add    $0x10,%esp
80109cc9:	83 c0 08             	add    $0x8,%eax
80109ccc:	0f b7 c0             	movzwl %ax,%eax
80109ccf:	83 ec 0c             	sub    $0xc,%esp
80109cd2:	50                   	push   %eax
80109cd3:	e8 50 f7 ff ff       	call   80109428 <H2N_ushort>
80109cd8:	83 c4 10             	add    $0x10,%esp
80109cdb:	8b 55 e0             	mov    -0x20(%ebp),%edx
80109cde:	66 89 42 10          	mov    %ax,0x10(%edx)


}
80109ce2:	90                   	nop
80109ce3:	c9                   	leave
80109ce4:	c3                   	ret

80109ce5 <tcp_chksum>:

ushort tcp_chksum(uint tcp_addr){
80109ce5:	55                   	push   %ebp
80109ce6:	89 e5                	mov    %esp,%ebp
80109ce8:	83 ec 38             	sub    $0x38,%esp
  struct ipv4_pkt *ipv4_p = (struct ipv4_pkt *)(tcp_addr);
80109ceb:	8b 45 08             	mov    0x8(%ebp),%eax
80109cee:	89 45 e8             	mov    %eax,-0x18(%ebp)
  struct tcp_pkt *tcp_p = (struct tcp_pkt *)((uint)ipv4_p + sizeof(struct ipv4_pkt));
80109cf1:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109cf4:	83 c0 14             	add    $0x14,%eax
80109cf7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct tcp_dummy tcp_dummy;
  
  memmove(tcp_dummy.src_ip,my_ip,4);
80109cfa:	83 ec 04             	sub    $0x4,%esp
80109cfd:	6a 04                	push   $0x4
80109cff:	68 e4 f4 10 80       	push   $0x8010f4e4
80109d04:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d07:	50                   	push   %eax
80109d08:	e8 3e ad ff ff       	call   80104a4b <memmove>
80109d0d:	83 c4 10             	add    $0x10,%esp
  memmove(tcp_dummy.dst_ip,ipv4_p->src_ip,4);
80109d10:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d13:	83 c0 0c             	add    $0xc,%eax
80109d16:	83 ec 04             	sub    $0x4,%esp
80109d19:	6a 04                	push   $0x4
80109d1b:	50                   	push   %eax
80109d1c:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d1f:	83 c0 04             	add    $0x4,%eax
80109d22:	50                   	push   %eax
80109d23:	e8 23 ad ff ff       	call   80104a4b <memmove>
80109d28:	83 c4 10             	add    $0x10,%esp
  tcp_dummy.padding = 0;
80109d2b:	c6 45 dc 00          	movb   $0x0,-0x24(%ebp)
  tcp_dummy.protocol = IPV4_TYPE_TCP;
80109d2f:	c6 45 dd 06          	movb   $0x6,-0x23(%ebp)
  tcp_dummy.tcp_len = H2N_ushort(N2H_ushort(ipv4_p->total_len) - sizeof(struct ipv4_pkt));
80109d33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80109d36:	0f b7 40 02          	movzwl 0x2(%eax),%eax
80109d3a:	0f b7 c0             	movzwl %ax,%eax
80109d3d:	83 ec 0c             	sub    $0xc,%esp
80109d40:	50                   	push   %eax
80109d41:	e8 cb f6 ff ff       	call   80109411 <N2H_ushort>
80109d46:	83 c4 10             	add    $0x10,%esp
80109d49:	83 e8 14             	sub    $0x14,%eax
80109d4c:	0f b7 c0             	movzwl %ax,%eax
80109d4f:	83 ec 0c             	sub    $0xc,%esp
80109d52:	50                   	push   %eax
80109d53:	e8 d0 f6 ff ff       	call   80109428 <H2N_ushort>
80109d58:	83 c4 10             	add    $0x10,%esp
80109d5b:	66 89 45 de          	mov    %ax,-0x22(%ebp)
  uint chk_sum = 0;
80109d5f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  uchar *bin = (uchar *)(&tcp_dummy);
80109d66:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80109d69:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<6;i++){
80109d6c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80109d73:	eb 33                	jmp    80109da8 <tcp_chksum+0xc3>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109d75:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d78:	01 c0                	add    %eax,%eax
80109d7a:	89 c2                	mov    %eax,%edx
80109d7c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d7f:	01 d0                	add    %edx,%eax
80109d81:	0f b6 00             	movzbl (%eax),%eax
80109d84:	0f b6 c0             	movzbl %al,%eax
80109d87:	c1 e0 08             	shl    $0x8,%eax
80109d8a:	89 c2                	mov    %eax,%edx
80109d8c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109d8f:	01 c0                	add    %eax,%eax
80109d91:	8d 48 01             	lea    0x1(%eax),%ecx
80109d94:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109d97:	01 c8                	add    %ecx,%eax
80109d99:	0f b6 00             	movzbl (%eax),%eax
80109d9c:	0f b6 c0             	movzbl %al,%eax
80109d9f:	01 d0                	add    %edx,%eax
80109da1:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<6;i++){
80109da4:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80109da8:	83 7d f0 05          	cmpl   $0x5,-0x10(%ebp)
80109dac:	7e c7                	jle    80109d75 <tcp_chksum+0x90>
  }

  bin = (uchar *)(tcp_p);
80109dae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80109db1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109db4:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80109dbb:	eb 33                	jmp    80109df0 <tcp_chksum+0x10b>
    chk_sum += (bin[i*2]<<8)+bin[i*2+1];
80109dbd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dc0:	01 c0                	add    %eax,%eax
80109dc2:	89 c2                	mov    %eax,%edx
80109dc4:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109dc7:	01 d0                	add    %edx,%eax
80109dc9:	0f b6 00             	movzbl (%eax),%eax
80109dcc:	0f b6 c0             	movzbl %al,%eax
80109dcf:	c1 e0 08             	shl    $0x8,%eax
80109dd2:	89 c2                	mov    %eax,%edx
80109dd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80109dd7:	01 c0                	add    %eax,%eax
80109dd9:	8d 48 01             	lea    0x1(%eax),%ecx
80109ddc:	8b 45 e0             	mov    -0x20(%ebp),%eax
80109ddf:	01 c8                	add    %ecx,%eax
80109de1:	0f b6 00             	movzbl (%eax),%eax
80109de4:	0f b6 c0             	movzbl %al,%eax
80109de7:	01 d0                	add    %edx,%eax
80109de9:	01 45 f4             	add    %eax,-0xc(%ebp)
  for(int i=0;i<(N2H_ushort(tcp_dummy.tcp_len)/2);i++){
80109dec:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80109df0:	0f b7 45 de          	movzwl -0x22(%ebp),%eax
80109df4:	0f b7 c0             	movzwl %ax,%eax
80109df7:	83 ec 0c             	sub    $0xc,%esp
80109dfa:	50                   	push   %eax
80109dfb:	e8 11 f6 ff ff       	call   80109411 <N2H_ushort>
80109e00:	83 c4 10             	add    $0x10,%esp
80109e03:	66 d1 e8             	shr    $1,%ax
80109e06:	0f b7 c0             	movzwl %ax,%eax
80109e09:	39 45 ec             	cmp    %eax,-0x14(%ebp)
80109e0c:	7c af                	jl     80109dbd <tcp_chksum+0xd8>
  }
  chk_sum += (chk_sum>>8*2);
80109e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e11:	c1 e8 10             	shr    $0x10,%eax
80109e14:	01 45 f4             	add    %eax,-0xc(%ebp)
  return ~(chk_sum);
80109e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e1a:	f7 d0                	not    %eax
}
80109e1c:	c9                   	leave
80109e1d:	c3                   	ret

80109e1e <tcp_fin>:

void tcp_fin(){
80109e1e:	55                   	push   %ebp
80109e1f:	89 e5                	mov    %esp,%ebp
  fin_flag =1;
80109e21:	c7 05 68 70 19 80 01 	movl   $0x1,0x80197068
80109e28:	00 00 00 
}
80109e2b:	90                   	nop
80109e2c:	5d                   	pop    %ebp
80109e2d:	c3                   	ret

80109e2e <http_proc>:
#include "defs.h"
#include "types.h"
#include "tcp.h"


void http_proc(uint recv, uint recv_size, uint send, uint *send_size){
80109e2e:	55                   	push   %ebp
80109e2f:	89 e5                	mov    %esp,%ebp
80109e31:	83 ec 18             	sub    $0x18,%esp
  int len;
  len = http_strcpy((char *)send,"HTTP/1.0 200 OK \r\n",0);
80109e34:	8b 45 10             	mov    0x10(%ebp),%eax
80109e37:	83 ec 04             	sub    $0x4,%esp
80109e3a:	6a 00                	push   $0x0
80109e3c:	68 8b bf 10 80       	push   $0x8010bf8b
80109e41:	50                   	push   %eax
80109e42:	e8 65 00 00 00       	call   80109eac <http_strcpy>
80109e47:	83 c4 10             	add    $0x10,%esp
80109e4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"Content-Type: text/html \r\n",len);
80109e4d:	8b 45 10             	mov    0x10(%ebp),%eax
80109e50:	83 ec 04             	sub    $0x4,%esp
80109e53:	ff 75 f4             	push   -0xc(%ebp)
80109e56:	68 9e bf 10 80       	push   $0x8010bf9e
80109e5b:	50                   	push   %eax
80109e5c:	e8 4b 00 00 00       	call   80109eac <http_strcpy>
80109e61:	83 c4 10             	add    $0x10,%esp
80109e64:	01 45 f4             	add    %eax,-0xc(%ebp)
  len += http_strcpy((char *)send,"\r\nHello World!\r\n",len);
80109e67:	8b 45 10             	mov    0x10(%ebp),%eax
80109e6a:	83 ec 04             	sub    $0x4,%esp
80109e6d:	ff 75 f4             	push   -0xc(%ebp)
80109e70:	68 b9 bf 10 80       	push   $0x8010bfb9
80109e75:	50                   	push   %eax
80109e76:	e8 31 00 00 00       	call   80109eac <http_strcpy>
80109e7b:	83 c4 10             	add    $0x10,%esp
80109e7e:	01 45 f4             	add    %eax,-0xc(%ebp)
  if(len%2 != 0){
80109e81:	8b 45 f4             	mov    -0xc(%ebp),%eax
80109e84:	83 e0 01             	and    $0x1,%eax
80109e87:	85 c0                	test   %eax,%eax
80109e89:	74 11                	je     80109e9c <http_proc+0x6e>
    char *payload = (char *)send;
80109e8b:	8b 45 10             	mov    0x10(%ebp),%eax
80109e8e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    payload[len] = 0;
80109e91:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e94:	8b 45 f0             	mov    -0x10(%ebp),%eax
80109e97:	01 d0                	add    %edx,%eax
80109e99:	c6 00 00             	movb   $0x0,(%eax)
  }
  *send_size = len;
80109e9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80109e9f:	8b 45 14             	mov    0x14(%ebp),%eax
80109ea2:	89 10                	mov    %edx,(%eax)
  tcp_fin();
80109ea4:	e8 75 ff ff ff       	call   80109e1e <tcp_fin>
}
80109ea9:	90                   	nop
80109eaa:	c9                   	leave
80109eab:	c3                   	ret

80109eac <http_strcpy>:

int http_strcpy(char *dst,const char *src,int start_index){
80109eac:	55                   	push   %ebp
80109ead:	89 e5                	mov    %esp,%ebp
80109eaf:	83 ec 10             	sub    $0x10,%esp
  int i = 0;
80109eb2:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while(src[i]){
80109eb9:	eb 20                	jmp    80109edb <http_strcpy+0x2f>
    dst[start_index+i] = src[i];
80109ebb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ebe:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ec1:	01 d0                	add    %edx,%eax
80109ec3:	8b 4d 10             	mov    0x10(%ebp),%ecx
80109ec6:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ec9:	01 ca                	add    %ecx,%edx
80109ecb:	89 d1                	mov    %edx,%ecx
80109ecd:	8b 55 08             	mov    0x8(%ebp),%edx
80109ed0:	01 ca                	add    %ecx,%edx
80109ed2:	0f b6 00             	movzbl (%eax),%eax
80109ed5:	88 02                	mov    %al,(%edx)
    i++;
80109ed7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  while(src[i]){
80109edb:	8b 55 fc             	mov    -0x4(%ebp),%edx
80109ede:	8b 45 0c             	mov    0xc(%ebp),%eax
80109ee1:	01 d0                	add    %edx,%eax
80109ee3:	0f b6 00             	movzbl (%eax),%eax
80109ee6:	84 c0                	test   %al,%al
80109ee8:	75 d1                	jne    80109ebb <http_strcpy+0xf>
  }
  return i;
80109eea:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80109eed:	c9                   	leave
80109eee:	c3                   	ret

80109eef <ideinit>:
static int disksize;
static uchar *memdisk;

void
ideinit(void)
{
80109eef:	55                   	push   %ebp
80109ef0:	89 e5                	mov    %esp,%ebp
  memdisk = _binary_fs_img_start;
80109ef2:	c7 05 70 70 19 80 a2 	movl   $0x8010f5a2,0x80197070
80109ef9:	f5 10 80 
  disksize = (uint)_binary_fs_img_size/BSIZE;
80109efc:	b8 00 d0 07 00       	mov    $0x7d000,%eax
80109f01:	c1 e8 09             	shr    $0x9,%eax
80109f04:	a3 6c 70 19 80       	mov    %eax,0x8019706c
}
80109f09:	90                   	nop
80109f0a:	5d                   	pop    %ebp
80109f0b:	c3                   	ret

80109f0c <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80109f0c:	55                   	push   %ebp
80109f0d:	89 e5                	mov    %esp,%ebp
  // no-op
}
80109f0f:	90                   	nop
80109f10:	5d                   	pop    %ebp
80109f11:	c3                   	ret

80109f12 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80109f12:	55                   	push   %ebp
80109f13:	89 e5                	mov    %esp,%ebp
80109f15:	83 ec 18             	sub    $0x18,%esp
  uchar *p;

  if(!holdingsleep(&b->lock))
80109f18:	8b 45 08             	mov    0x8(%ebp),%eax
80109f1b:	83 c0 0c             	add    $0xc,%eax
80109f1e:	83 ec 0c             	sub    $0xc,%esp
80109f21:	50                   	push   %eax
80109f22:	e8 5e a7 ff ff       	call   80104685 <holdingsleep>
80109f27:	83 c4 10             	add    $0x10,%esp
80109f2a:	85 c0                	test   %eax,%eax
80109f2c:	75 0d                	jne    80109f3b <iderw+0x29>
    panic("iderw: buf not locked");
80109f2e:	83 ec 0c             	sub    $0xc,%esp
80109f31:	68 ca bf 10 80       	push   $0x8010bfca
80109f36:	e8 6e 66 ff ff       	call   801005a9 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80109f3b:	8b 45 08             	mov    0x8(%ebp),%eax
80109f3e:	8b 00                	mov    (%eax),%eax
80109f40:	83 e0 06             	and    $0x6,%eax
80109f43:	83 f8 02             	cmp    $0x2,%eax
80109f46:	75 0d                	jne    80109f55 <iderw+0x43>
    panic("iderw: nothing to do");
80109f48:	83 ec 0c             	sub    $0xc,%esp
80109f4b:	68 e0 bf 10 80       	push   $0x8010bfe0
80109f50:	e8 54 66 ff ff       	call   801005a9 <panic>
  if(b->dev != 1)
80109f55:	8b 45 08             	mov    0x8(%ebp),%eax
80109f58:	8b 40 04             	mov    0x4(%eax),%eax
80109f5b:	83 f8 01             	cmp    $0x1,%eax
80109f5e:	74 0d                	je     80109f6d <iderw+0x5b>
    panic("iderw: request not for disk 1");
80109f60:	83 ec 0c             	sub    $0xc,%esp
80109f63:	68 f5 bf 10 80       	push   $0x8010bff5
80109f68:	e8 3c 66 ff ff       	call   801005a9 <panic>
  if(b->blockno >= disksize)
80109f6d:	8b 45 08             	mov    0x8(%ebp),%eax
80109f70:	8b 40 08             	mov    0x8(%eax),%eax
80109f73:	8b 15 6c 70 19 80    	mov    0x8019706c,%edx
80109f79:	39 d0                	cmp    %edx,%eax
80109f7b:	72 0d                	jb     80109f8a <iderw+0x78>
    panic("iderw: block out of range");
80109f7d:	83 ec 0c             	sub    $0xc,%esp
80109f80:	68 13 c0 10 80       	push   $0x8010c013
80109f85:	e8 1f 66 ff ff       	call   801005a9 <panic>

  p = memdisk + b->blockno*BSIZE;
80109f8a:	8b 15 70 70 19 80    	mov    0x80197070,%edx
80109f90:	8b 45 08             	mov    0x8(%ebp),%eax
80109f93:	8b 40 08             	mov    0x8(%eax),%eax
80109f96:	c1 e0 09             	shl    $0x9,%eax
80109f99:	01 d0                	add    %edx,%eax
80109f9b:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(b->flags & B_DIRTY){
80109f9e:	8b 45 08             	mov    0x8(%ebp),%eax
80109fa1:	8b 00                	mov    (%eax),%eax
80109fa3:	83 e0 04             	and    $0x4,%eax
80109fa6:	85 c0                	test   %eax,%eax
80109fa8:	74 2b                	je     80109fd5 <iderw+0xc3>
    b->flags &= ~B_DIRTY;
80109faa:	8b 45 08             	mov    0x8(%ebp),%eax
80109fad:	8b 00                	mov    (%eax),%eax
80109faf:	83 e0 fb             	and    $0xfffffffb,%eax
80109fb2:	89 c2                	mov    %eax,%edx
80109fb4:	8b 45 08             	mov    0x8(%ebp),%eax
80109fb7:	89 10                	mov    %edx,(%eax)
    memmove(p, b->data, BSIZE);
80109fb9:	8b 45 08             	mov    0x8(%ebp),%eax
80109fbc:	83 c0 5c             	add    $0x5c,%eax
80109fbf:	83 ec 04             	sub    $0x4,%esp
80109fc2:	68 00 02 00 00       	push   $0x200
80109fc7:	50                   	push   %eax
80109fc8:	ff 75 f4             	push   -0xc(%ebp)
80109fcb:	e8 7b aa ff ff       	call   80104a4b <memmove>
80109fd0:	83 c4 10             	add    $0x10,%esp
80109fd3:	eb 1a                	jmp    80109fef <iderw+0xdd>
  } else
    memmove(b->data, p, BSIZE);
80109fd5:	8b 45 08             	mov    0x8(%ebp),%eax
80109fd8:	83 c0 5c             	add    $0x5c,%eax
80109fdb:	83 ec 04             	sub    $0x4,%esp
80109fde:	68 00 02 00 00       	push   $0x200
80109fe3:	ff 75 f4             	push   -0xc(%ebp)
80109fe6:	50                   	push   %eax
80109fe7:	e8 5f aa ff ff       	call   80104a4b <memmove>
80109fec:	83 c4 10             	add    $0x10,%esp
  b->flags |= B_VALID;
80109fef:	8b 45 08             	mov    0x8(%ebp),%eax
80109ff2:	8b 00                	mov    (%eax),%eax
80109ff4:	83 c8 02             	or     $0x2,%eax
80109ff7:	89 c2                	mov    %eax,%edx
80109ff9:	8b 45 08             	mov    0x8(%ebp),%eax
80109ffc:	89 10                	mov    %edx,(%eax)
}
80109ffe:	90                   	nop
80109fff:	c9                   	leave
8010a000:	c3                   	ret
