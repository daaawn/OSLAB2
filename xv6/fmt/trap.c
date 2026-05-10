3400 #include "types.h"
3401 #include "defs.h"
3402 #include "param.h"
3403 #include "memlayout.h"
3404 #include "mmu.h"
3405 #include "proc.h"
3406 #include "x86.h"
3407 #include "traps.h"
3408 #include "spinlock.h"
3409 #include "i8254.h"
3410 
3411 // Interrupt descriptor table (shared by all CPUs).
3412 struct gatedesc idt[256];
3413 extern uint vectors[];  // in vectors.S: array of 256 entry pointers
3414 struct spinlock tickslock;
3415 uint ticks;
3416 
3417 void
3418 tvinit(void)
3419 {
3420   int i;
3421 
3422   for(i = 0; i < 256; i++)
3423     SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
3424   SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
3425 
3426   initlock(&tickslock, "time");
3427 }
3428 
3429 void
3430 idtinit(void)
3431 {
3432   lidt(idt, sizeof(idt));
3433 }
3434 
3435 
3436 
3437 
3438 
3439 
3440 
3441 
3442 
3443 
3444 
3445 
3446 
3447 
3448 
3449 
3450 void
3451 trap(struct trapframe *tf)
3452 {
3453   if(tf->trapno == T_SYSCALL){
3454     if(myproc()->killed)
3455       exit();
3456     myproc()->tf = tf;
3457     syscall();
3458     if(myproc()->killed)
3459       exit();
3460     return;
3461   }
3462 
3463   switch(tf->trapno){
3464   case T_IRQ0 + IRQ_TIMER:
3465     if(cpuid() == 0){
3466       acquire(&tickslock);
3467       ticks++;
3468       wakeup(&ticks);
3469       release(&tickslock);
3470     }
3471     lapiceoi();
3472 
3473     //LAB2 추가
3474     struct proc *p = myproc();
3475 
3476     if (p && p->scheduler != 0 && ticks % 30 == 0){
3477       p->tf->eip = p->scheduler;
3478     }
3479 
3480     break;
3481   case T_IRQ0 + IRQ_IDE:
3482     ideintr();
3483     lapiceoi();
3484     break;
3485   case T_IRQ0 + IRQ_IDE+1:
3486     // Bochs generates spurious IDE1 interrupts.
3487     break;
3488   case T_IRQ0 + IRQ_KBD:
3489     kbdintr();
3490     lapiceoi();
3491     break;
3492   case T_IRQ0 + IRQ_COM1:
3493     uartintr();
3494     lapiceoi();
3495     break;
3496   case T_IRQ0 + 0xB:
3497     i8254_intr();
3498     lapiceoi();
3499     break;
3500   case T_IRQ0 + IRQ_SPURIOUS:
3501     cprintf("cpu%d: spurious interrupt at %x:%x\n",
3502             cpuid(), tf->cs, tf->eip);
3503     lapiceoi();
3504     break;
3505 
3506 
3507   default:
3508     if(myproc() == 0 || (tf->cs&3) == 0){
3509       // In kernel, it must be our mistake.
3510       cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
3511               tf->trapno, cpuid(), tf->eip, rcr2());
3512       panic("trap");
3513     }
3514     // In user space, assume process misbehaved.
3515     cprintf("pid %d %s: trap %d err %d on cpu %d "
3516             "eip 0x%x addr 0x%x--kill proc\n",
3517             myproc()->pid, myproc()->name, tf->trapno,
3518             tf->err, cpuid(), tf->eip, rcr2());
3519     myproc()->killed = 1;
3520   }
3521 
3522   // Force process exit if it has been killed and is in user space.
3523   // (If it is still executing in the kernel, let it keep running
3524   // until it gets to the regular system call return.)
3525   if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
3526     exit();
3527 
3528   // Force process to give up CPU on clock tick.
3529   // If interrupts were on while locks held, would need to check nlock.
3530   if(myproc() && myproc()->state == RUNNING &&
3531      tf->trapno == T_IRQ0+IRQ_TIMER)
3532     yield();
3533 
3534   // Check if the process has been killed since we yielded
3535   if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
3536     exit();
3537 }
3538 
3539 
3540 
3541 
3542 
3543 
3544 
3545 
3546 
3547 
3548 
3549 
