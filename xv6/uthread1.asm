
_uthread1:     file format elf32-i386


Disassembly of section .text:

00000000 <thread_schedule>:



static void 
thread_schedule(void)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 18             	sub    $0x18,%esp
  /*if (current_thread != all_thread && current_thread->state == RUNNING){
    current_thread->state = RUNNABLE;
  }*/

  /* Find another runnable thread. */
  next_thread = 0;
   6:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
   d:	00 00 00 
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  10:	c7 45 f4 60 0d 00 00 	movl   $0xd60,-0xc(%ebp)
  17:	eb 29                	jmp    42 <thread_schedule+0x42>
    if (t->state == RUNNABLE && t != current_thread) {
  19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1c:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  22:	83 f8 02             	cmp    $0x2,%eax
  25:	75 14                	jne    3b <thread_schedule+0x3b>
  27:	a1 40 0d 00 00       	mov    0xd40,%eax
  2c:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  2f:	74 0a                	je     3b <thread_schedule+0x3b>
      next_thread = t;
  31:	8b 45 f4             	mov    -0xc(%ebp),%eax
  34:	a3 44 0d 00 00       	mov    %eax,0xd44
      break;
  39:	eb 11                	jmp    4c <thread_schedule+0x4c>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  3b:	81 45 f4 08 20 00 00 	addl   $0x2008,-0xc(%ebp)
  42:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  47:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  4a:	72 cd                	jb     19 <thread_schedule+0x19>
    }
  }

  if (t >= all_thread + MAX_THREAD && current_thread->state == RUNNABLE) {
  4c:	b8 80 8d 00 00       	mov    $0x8d80,%eax
  51:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  54:	72 1a                	jb     70 <thread_schedule+0x70>
  56:	a1 40 0d 00 00       	mov    0xd40,%eax
  5b:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
  61:	83 f8 02             	cmp    $0x2,%eax
  64:	75 0a                	jne    70 <thread_schedule+0x70>
    /* The current thread is the only runnable thread; run it. */
    next_thread = current_thread;
  66:	a1 40 0d 00 00       	mov    0xd40,%eax
  6b:	a3 44 0d 00 00       	mov    %eax,0xd44
  }

  if (next_thread == 0) {
  70:	a1 44 0d 00 00       	mov    0xd44,%eax
  75:	85 c0                	test   %eax,%eax
  77:	75 17                	jne    90 <thread_schedule+0x90>
    printf(2, "thread_schedule: no runnable threads\n");
  79:	83 ec 08             	sub    $0x8,%esp
  7c:	68 f0 09 00 00       	push   $0x9f0
  81:	6a 02                	push   $0x2
  83:	e8 b0 05 00 00       	call   638 <printf>
  88:	83 c4 10             	add    $0x10,%esp
    exit();
  8b:	e8 2c 04 00 00       	call   4bc <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  90:	8b 15 40 0d 00 00    	mov    0xd40,%edx
  96:	a1 44 0d 00 00       	mov    0xd44,%eax
  9b:	39 c2                	cmp    %eax,%edx
  9d:	74 16                	je     b5 <thread_schedule+0xb5>
    next_thread->state = RUNNING;
  9f:	a1 44 0d 00 00       	mov    0xd44,%eax
  a4:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ab:	00 00 00 
    //current_thread->state = RUNNABLE;
    thread_switch();
  ae:	e8 92 01 00 00       	call   245 <thread_switch>
  } else
    next_thread = 0;
}
  b3:	eb 0a                	jmp    bf <thread_schedule+0xbf>
    next_thread = 0;
  b5:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
  bc:	00 00 00 
}
  bf:	90                   	nop
  c0:	c9                   	leave
  c1:	c3                   	ret

000000c2 <thread_init>:

void
thread_init(void)
{ 
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 08             	sub    $0x8,%esp
  //LAB2 추가. 인자 타입캐스팅
  uthread_init((int)thread_schedule);
  c8:	b8 00 00 00 00       	mov    $0x0,%eax
  cd:	83 ec 0c             	sub    $0xc,%esp
  d0:	50                   	push   %eax
  d1:	e8 86 04 00 00       	call   55c <uthread_init>
  d6:	83 c4 10             	add    $0x10,%esp
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  d9:	c7 05 40 0d 00 00 60 	movl   $0xd60,0xd40
  e0:	0d 00 00 
  current_thread->state = RUNNING;
  e3:	a1 40 0d 00 00       	mov    0xd40,%eax
  e8:	c7 80 04 20 00 00 01 	movl   $0x1,0x2004(%eax)
  ef:	00 00 00 
}
  f2:	90                   	nop
  f3:	c9                   	leave
  f4:	c3                   	ret

000000f5 <thread_create>:



void 
thread_create(void (*func)())
{
  f5:	55                   	push   %ebp
  f6:	89 e5                	mov    %esp,%ebp
  f8:	83 ec 10             	sub    $0x10,%esp
  thread_p t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
  fb:	c7 45 fc 60 0d 00 00 	movl   $0xd60,-0x4(%ebp)
 102:	eb 14                	jmp    118 <thread_create+0x23>
    if (t->state == FREE) break;
 104:	8b 45 fc             	mov    -0x4(%ebp),%eax
 107:	8b 80 04 20 00 00    	mov    0x2004(%eax),%eax
 10d:	85 c0                	test   %eax,%eax
 10f:	74 13                	je     124 <thread_create+0x2f>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 111:	81 45 fc 08 20 00 00 	addl   $0x2008,-0x4(%ebp)
 118:	b8 80 8d 00 00       	mov    $0x8d80,%eax
 11d:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 120:	72 e2                	jb     104 <thread_create+0xf>
 122:	eb 01                	jmp    125 <thread_create+0x30>
    if (t->state == FREE) break;
 124:	90                   	nop
  }
  t->sp = (int) (t->stack + STACK_SIZE);   // set sp to the top of the stack
 125:	8b 45 fc             	mov    -0x4(%ebp),%eax
 128:	83 c0 04             	add    $0x4,%eax
 12b:	05 00 20 00 00       	add    $0x2000,%eax
 130:	89 c2                	mov    %eax,%edx
 132:	8b 45 fc             	mov    -0x4(%ebp),%eax
 135:	89 10                	mov    %edx,(%eax)
  t->sp -= 4;                              // space for return address
 137:	8b 45 fc             	mov    -0x4(%ebp),%eax
 13a:	8b 00                	mov    (%eax),%eax
 13c:	8d 50 fc             	lea    -0x4(%eax),%edx
 13f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 142:	89 10                	mov    %edx,(%eax)
  * (int *) (t->sp) = (int)func;           // push return address on stack
 144:	8b 45 fc             	mov    -0x4(%ebp),%eax
 147:	8b 00                	mov    (%eax),%eax
 149:	89 c2                	mov    %eax,%edx
 14b:	8b 45 08             	mov    0x8(%ebp),%eax
 14e:	89 02                	mov    %eax,(%edx)
  t->sp -= 32;                             // space for registers that thread_switch expects
 150:	8b 45 fc             	mov    -0x4(%ebp),%eax
 153:	8b 00                	mov    (%eax),%eax
 155:	8d 50 e0             	lea    -0x20(%eax),%edx
 158:	8b 45 fc             	mov    -0x4(%ebp),%eax
 15b:	89 10                	mov    %edx,(%eax)
  t->state = RUNNABLE;
 15d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 160:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 167:	00 00 00 

}
 16a:	90                   	nop
 16b:	c9                   	leave
 16c:	c3                   	ret

0000016d <mythread>:

static void 
mythread(void)
{
 16d:	55                   	push   %ebp
 16e:	89 e5                	mov    %esp,%ebp
 170:	83 ec 18             	sub    $0x18,%esp
  //LAB2 추가
  current_thread->state= RUNNABLE;
 173:	a1 40 0d 00 00       	mov    0xd40,%eax
 178:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 17f:	00 00 00 
  int i;
  printf(1, "my thread running\n");
 182:	83 ec 08             	sub    $0x8,%esp
 185:	68 16 0a 00 00       	push   $0xa16
 18a:	6a 01                	push   $0x1
 18c:	e8 a7 04 00 00       	call   638 <printf>
 191:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < 100; i++) {
 194:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 19b:	eb 31                	jmp    1ce <mythread+0x61>
    printf(1, "%d my thread 0x%x\n", i+1, (int) current_thread);
 19d:	a1 40 0d 00 00       	mov    0xd40,%eax
 1a2:	89 c2                	mov    %eax,%edx
 1a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1a7:	83 c0 01             	add    $0x1,%eax
 1aa:	52                   	push   %edx
 1ab:	50                   	push   %eax
 1ac:	68 29 0a 00 00       	push   $0xa29
 1b1:	6a 01                	push   $0x1
 1b3:	e8 80 04 00 00       	call   638 <printf>
 1b8:	83 c4 10             	add    $0x10,%esp
    //LAB2 추가
    current_thread->state= RUNNABLE;
 1bb:	a1 40 0d 00 00       	mov    0xd40,%eax
 1c0:	c7 80 04 20 00 00 02 	movl   $0x2,0x2004(%eax)
 1c7:	00 00 00 
  for (i = 0; i < 100; i++) {
 1ca:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1ce:	83 7d f4 63          	cmpl   $0x63,-0xc(%ebp)
 1d2:	7e c9                	jle    19d <mythread+0x30>
  }
  printf(1, "my thread: exit\n");
 1d4:	83 ec 08             	sub    $0x8,%esp
 1d7:	68 3c 0a 00 00       	push   $0xa3c
 1dc:	6a 01                	push   $0x1
 1de:	e8 55 04 00 00       	call   638 <printf>
 1e3:	83 c4 10             	add    $0x10,%esp
  current_thread->state = FREE;
 1e6:	a1 40 0d 00 00       	mov    0xd40,%eax
 1eb:	c7 80 04 20 00 00 00 	movl   $0x0,0x2004(%eax)
 1f2:	00 00 00 
  //LAB2 추가
  thread_schedule();
 1f5:	e8 06 fe ff ff       	call   0 <thread_schedule>
 
}
 1fa:	90                   	nop
 1fb:	c9                   	leave
 1fc:	c3                   	ret

000001fd <main>:



int 
main(int argc, char *argv[]) 
{
 1fd:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 201:	83 e4 f0             	and    $0xfffffff0,%esp
 204:	ff 71 fc             	push   -0x4(%ecx)
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	51                   	push   %ecx
 20b:	83 ec 04             	sub    $0x4,%esp
  thread_init();
 20e:	e8 af fe ff ff       	call   c2 <thread_init>
  thread_create(mythread);
 213:	83 ec 0c             	sub    $0xc,%esp
 216:	68 6d 01 00 00       	push   $0x16d
 21b:	e8 d5 fe ff ff       	call   f5 <thread_create>
 220:	83 c4 10             	add    $0x10,%esp
  thread_create(mythread);
 223:	83 ec 0c             	sub    $0xc,%esp
 226:	68 6d 01 00 00       	push   $0x16d
 22b:	e8 c5 fe ff ff       	call   f5 <thread_create>
 230:	83 c4 10             	add    $0x10,%esp
  thread_schedule();
 233:	e8 c8 fd ff ff       	call   0 <thread_schedule>
  return 0;
 238:	b8 00 00 00 00       	mov    $0x0,%eax
 23d:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 240:	c9                   	leave
 241:	8d 61 fc             	lea    -0x4(%ecx),%esp
 244:	c3                   	ret

00000245 <thread_switch>:

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */

	pushal 							//레지스터를 current_thread의 스택에 저장
 245:	60                   	pusha

	movl current_thread, %eax 		//current_thread의 스택 포인터 저장
 246:	a1 40 0d 00 00       	mov    0xd40,%eax
	movl %esp, (%eax)
 24b:	89 20                	mov    %esp,(%eax)
	movl next_thread, %eax			//next_thread의 스택으로 전환
 24d:	a1 44 0d 00 00       	mov    0xd44,%eax
	movl (%eax), %esp
 252:	8b 20                	mov    (%eax),%esp

	movl %eax, current_thread  		//current_thread를 next_thread로 설정
 254:	a3 40 0d 00 00       	mov    %eax,0xd40
	popal 							//next_thread의 레지스터 상태를 복원
 259:	61                   	popa

	movl $0, next_thread 
 25a:	c7 05 44 0d 00 00 00 	movl   $0x0,0xd44
 261:	00 00 00 
	
	ret    /* return to ra */
 264:	c3                   	ret

00000265 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 265:	55                   	push   %ebp
 266:	89 e5                	mov    %esp,%ebp
 268:	57                   	push   %edi
 269:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 26a:	8b 4d 08             	mov    0x8(%ebp),%ecx
 26d:	8b 55 10             	mov    0x10(%ebp),%edx
 270:	8b 45 0c             	mov    0xc(%ebp),%eax
 273:	89 cb                	mov    %ecx,%ebx
 275:	89 df                	mov    %ebx,%edi
 277:	89 d1                	mov    %edx,%ecx
 279:	fc                   	cld
 27a:	f3 aa                	rep stos %al,%es:(%edi)
 27c:	89 ca                	mov    %ecx,%edx
 27e:	89 fb                	mov    %edi,%ebx
 280:	89 5d 08             	mov    %ebx,0x8(%ebp)
 283:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 286:	90                   	nop
 287:	5b                   	pop    %ebx
 288:	5f                   	pop    %edi
 289:	5d                   	pop    %ebp
 28a:	c3                   	ret

0000028b <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 28b:	55                   	push   %ebp
 28c:	89 e5                	mov    %esp,%ebp
 28e:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 291:	8b 45 08             	mov    0x8(%ebp),%eax
 294:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 297:	90                   	nop
 298:	8b 55 0c             	mov    0xc(%ebp),%edx
 29b:	8d 42 01             	lea    0x1(%edx),%eax
 29e:	89 45 0c             	mov    %eax,0xc(%ebp)
 2a1:	8b 45 08             	mov    0x8(%ebp),%eax
 2a4:	8d 48 01             	lea    0x1(%eax),%ecx
 2a7:	89 4d 08             	mov    %ecx,0x8(%ebp)
 2aa:	0f b6 12             	movzbl (%edx),%edx
 2ad:	88 10                	mov    %dl,(%eax)
 2af:	0f b6 00             	movzbl (%eax),%eax
 2b2:	84 c0                	test   %al,%al
 2b4:	75 e2                	jne    298 <strcpy+0xd>
    ;
  return os;
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2b9:	c9                   	leave
 2ba:	c3                   	ret

000002bb <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2be:	eb 08                	jmp    2c8 <strcmp+0xd>
    p++, q++;
 2c0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c4:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
  while(*p && *p == *q)
 2c8:	8b 45 08             	mov    0x8(%ebp),%eax
 2cb:	0f b6 00             	movzbl (%eax),%eax
 2ce:	84 c0                	test   %al,%al
 2d0:	74 10                	je     2e2 <strcmp+0x27>
 2d2:	8b 45 08             	mov    0x8(%ebp),%eax
 2d5:	0f b6 10             	movzbl (%eax),%edx
 2d8:	8b 45 0c             	mov    0xc(%ebp),%eax
 2db:	0f b6 00             	movzbl (%eax),%eax
 2de:	38 c2                	cmp    %al,%dl
 2e0:	74 de                	je     2c0 <strcmp+0x5>
  return (uchar)*p - (uchar)*q;
 2e2:	8b 45 08             	mov    0x8(%ebp),%eax
 2e5:	0f b6 00             	movzbl (%eax),%eax
 2e8:	0f b6 d0             	movzbl %al,%edx
 2eb:	8b 45 0c             	mov    0xc(%ebp),%eax
 2ee:	0f b6 00             	movzbl (%eax),%eax
 2f1:	0f b6 c0             	movzbl %al,%eax
 2f4:	29 c2                	sub    %eax,%edx
 2f6:	89 d0                	mov    %edx,%eax
}
 2f8:	5d                   	pop    %ebp
 2f9:	c3                   	ret

000002fa <strlen>:

uint
strlen(char *s)
{
 2fa:	55                   	push   %ebp
 2fb:	89 e5                	mov    %esp,%ebp
 2fd:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 300:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 307:	eb 04                	jmp    30d <strlen+0x13>
 309:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 30d:	8b 55 fc             	mov    -0x4(%ebp),%edx
 310:	8b 45 08             	mov    0x8(%ebp),%eax
 313:	01 d0                	add    %edx,%eax
 315:	0f b6 00             	movzbl (%eax),%eax
 318:	84 c0                	test   %al,%al
 31a:	75 ed                	jne    309 <strlen+0xf>
    ;
  return n;
 31c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 31f:	c9                   	leave
 320:	c3                   	ret

00000321 <memset>:

void*
memset(void *dst, int c, uint n)
{
 321:	55                   	push   %ebp
 322:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 324:	8b 45 10             	mov    0x10(%ebp),%eax
 327:	50                   	push   %eax
 328:	ff 75 0c             	push   0xc(%ebp)
 32b:	ff 75 08             	push   0x8(%ebp)
 32e:	e8 32 ff ff ff       	call   265 <stosb>
 333:	83 c4 0c             	add    $0xc,%esp
  return dst;
 336:	8b 45 08             	mov    0x8(%ebp),%eax
}
 339:	c9                   	leave
 33a:	c3                   	ret

0000033b <strchr>:

char*
strchr(const char *s, char c)
{
 33b:	55                   	push   %ebp
 33c:	89 e5                	mov    %esp,%ebp
 33e:	83 ec 04             	sub    $0x4,%esp
 341:	8b 45 0c             	mov    0xc(%ebp),%eax
 344:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 347:	eb 14                	jmp    35d <strchr+0x22>
    if(*s == c)
 349:	8b 45 08             	mov    0x8(%ebp),%eax
 34c:	0f b6 00             	movzbl (%eax),%eax
 34f:	38 45 fc             	cmp    %al,-0x4(%ebp)
 352:	75 05                	jne    359 <strchr+0x1e>
      return (char*)s;
 354:	8b 45 08             	mov    0x8(%ebp),%eax
 357:	eb 13                	jmp    36c <strchr+0x31>
  for(; *s; s++)
 359:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 35d:	8b 45 08             	mov    0x8(%ebp),%eax
 360:	0f b6 00             	movzbl (%eax),%eax
 363:	84 c0                	test   %al,%al
 365:	75 e2                	jne    349 <strchr+0xe>
  return 0;
 367:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36c:	c9                   	leave
 36d:	c3                   	ret

0000036e <gets>:

char*
gets(char *buf, int max)
{
 36e:	55                   	push   %ebp
 36f:	89 e5                	mov    %esp,%ebp
 371:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 374:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37b:	eb 42                	jmp    3bf <gets+0x51>
    cc = read(0, &c, 1);
 37d:	83 ec 04             	sub    $0x4,%esp
 380:	6a 01                	push   $0x1
 382:	8d 45 ef             	lea    -0x11(%ebp),%eax
 385:	50                   	push   %eax
 386:	6a 00                	push   $0x0
 388:	e8 47 01 00 00       	call   4d4 <read>
 38d:	83 c4 10             	add    $0x10,%esp
 390:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 393:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 397:	7e 33                	jle    3cc <gets+0x5e>
      break;
    buf[i++] = c;
 399:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39c:	8d 50 01             	lea    0x1(%eax),%edx
 39f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a2:	89 c2                	mov    %eax,%edx
 3a4:	8b 45 08             	mov    0x8(%ebp),%eax
 3a7:	01 c2                	add    %eax,%edx
 3a9:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3ad:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3af:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3b3:	3c 0a                	cmp    $0xa,%al
 3b5:	74 16                	je     3cd <gets+0x5f>
 3b7:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3bb:	3c 0d                	cmp    $0xd,%al
 3bd:	74 0e                	je     3cd <gets+0x5f>
  for(i=0; i+1 < max; ){
 3bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c2:	83 c0 01             	add    $0x1,%eax
 3c5:	39 45 0c             	cmp    %eax,0xc(%ebp)
 3c8:	7f b3                	jg     37d <gets+0xf>
 3ca:	eb 01                	jmp    3cd <gets+0x5f>
      break;
 3cc:	90                   	nop
      break;
  }
  buf[i] = '\0';
 3cd:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3d0:	8b 45 08             	mov    0x8(%ebp),%eax
 3d3:	01 d0                	add    %edx,%eax
 3d5:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3d8:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3db:	c9                   	leave
 3dc:	c3                   	ret

000003dd <stat>:

int
stat(char *n, struct stat *st)
{
 3dd:	55                   	push   %ebp
 3de:	89 e5                	mov    %esp,%ebp
 3e0:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e3:	83 ec 08             	sub    $0x8,%esp
 3e6:	6a 00                	push   $0x0
 3e8:	ff 75 08             	push   0x8(%ebp)
 3eb:	e8 0c 01 00 00       	call   4fc <open>
 3f0:	83 c4 10             	add    $0x10,%esp
 3f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3f6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fa:	79 07                	jns    403 <stat+0x26>
    return -1;
 3fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 401:	eb 25                	jmp    428 <stat+0x4b>
  r = fstat(fd, st);
 403:	83 ec 08             	sub    $0x8,%esp
 406:	ff 75 0c             	push   0xc(%ebp)
 409:	ff 75 f4             	push   -0xc(%ebp)
 40c:	e8 03 01 00 00       	call   514 <fstat>
 411:	83 c4 10             	add    $0x10,%esp
 414:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 417:	83 ec 0c             	sub    $0xc,%esp
 41a:	ff 75 f4             	push   -0xc(%ebp)
 41d:	e8 c2 00 00 00       	call   4e4 <close>
 422:	83 c4 10             	add    $0x10,%esp
  return r;
 425:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 428:	c9                   	leave
 429:	c3                   	ret

0000042a <atoi>:

int
atoi(const char *s)
{
 42a:	55                   	push   %ebp
 42b:	89 e5                	mov    %esp,%ebp
 42d:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 430:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 437:	eb 25                	jmp    45e <atoi+0x34>
    n = n*10 + *s++ - '0';
 439:	8b 55 fc             	mov    -0x4(%ebp),%edx
 43c:	89 d0                	mov    %edx,%eax
 43e:	c1 e0 02             	shl    $0x2,%eax
 441:	01 d0                	add    %edx,%eax
 443:	01 c0                	add    %eax,%eax
 445:	89 c1                	mov    %eax,%ecx
 447:	8b 45 08             	mov    0x8(%ebp),%eax
 44a:	8d 50 01             	lea    0x1(%eax),%edx
 44d:	89 55 08             	mov    %edx,0x8(%ebp)
 450:	0f b6 00             	movzbl (%eax),%eax
 453:	0f be c0             	movsbl %al,%eax
 456:	01 c8                	add    %ecx,%eax
 458:	83 e8 30             	sub    $0x30,%eax
 45b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 45e:	8b 45 08             	mov    0x8(%ebp),%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	3c 2f                	cmp    $0x2f,%al
 466:	7e 0a                	jle    472 <atoi+0x48>
 468:	8b 45 08             	mov    0x8(%ebp),%eax
 46b:	0f b6 00             	movzbl (%eax),%eax
 46e:	3c 39                	cmp    $0x39,%al
 470:	7e c7                	jle    439 <atoi+0xf>
  return n;
 472:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 475:	c9                   	leave
 476:	c3                   	ret

00000477 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 477:	55                   	push   %ebp
 478:	89 e5                	mov    %esp,%ebp
 47a:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;

  dst = vdst;
 47d:	8b 45 08             	mov    0x8(%ebp),%eax
 480:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 483:	8b 45 0c             	mov    0xc(%ebp),%eax
 486:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 489:	eb 17                	jmp    4a2 <memmove+0x2b>
    *dst++ = *src++;
 48b:	8b 55 f8             	mov    -0x8(%ebp),%edx
 48e:	8d 42 01             	lea    0x1(%edx),%eax
 491:	89 45 f8             	mov    %eax,-0x8(%ebp)
 494:	8b 45 fc             	mov    -0x4(%ebp),%eax
 497:	8d 48 01             	lea    0x1(%eax),%ecx
 49a:	89 4d fc             	mov    %ecx,-0x4(%ebp)
 49d:	0f b6 12             	movzbl (%edx),%edx
 4a0:	88 10                	mov    %dl,(%eax)
  while(n-- > 0)
 4a2:	8b 45 10             	mov    0x10(%ebp),%eax
 4a5:	8d 50 ff             	lea    -0x1(%eax),%edx
 4a8:	89 55 10             	mov    %edx,0x10(%ebp)
 4ab:	85 c0                	test   %eax,%eax
 4ad:	7f dc                	jg     48b <memmove+0x14>
  return vdst;
 4af:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4b2:	c9                   	leave
 4b3:	c3                   	ret

000004b4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4b4:	b8 01 00 00 00       	mov    $0x1,%eax
 4b9:	cd 40                	int    $0x40
 4bb:	c3                   	ret

000004bc <exit>:
SYSCALL(exit)
 4bc:	b8 02 00 00 00       	mov    $0x2,%eax
 4c1:	cd 40                	int    $0x40
 4c3:	c3                   	ret

000004c4 <wait>:
SYSCALL(wait)
 4c4:	b8 03 00 00 00       	mov    $0x3,%eax
 4c9:	cd 40                	int    $0x40
 4cb:	c3                   	ret

000004cc <pipe>:
SYSCALL(pipe)
 4cc:	b8 04 00 00 00       	mov    $0x4,%eax
 4d1:	cd 40                	int    $0x40
 4d3:	c3                   	ret

000004d4 <read>:
SYSCALL(read)
 4d4:	b8 05 00 00 00       	mov    $0x5,%eax
 4d9:	cd 40                	int    $0x40
 4db:	c3                   	ret

000004dc <write>:
SYSCALL(write)
 4dc:	b8 10 00 00 00       	mov    $0x10,%eax
 4e1:	cd 40                	int    $0x40
 4e3:	c3                   	ret

000004e4 <close>:
SYSCALL(close)
 4e4:	b8 15 00 00 00       	mov    $0x15,%eax
 4e9:	cd 40                	int    $0x40
 4eb:	c3                   	ret

000004ec <kill>:
SYSCALL(kill)
 4ec:	b8 06 00 00 00       	mov    $0x6,%eax
 4f1:	cd 40                	int    $0x40
 4f3:	c3                   	ret

000004f4 <exec>:
SYSCALL(exec)
 4f4:	b8 07 00 00 00       	mov    $0x7,%eax
 4f9:	cd 40                	int    $0x40
 4fb:	c3                   	ret

000004fc <open>:
SYSCALL(open)
 4fc:	b8 0f 00 00 00       	mov    $0xf,%eax
 501:	cd 40                	int    $0x40
 503:	c3                   	ret

00000504 <mknod>:
SYSCALL(mknod)
 504:	b8 11 00 00 00       	mov    $0x11,%eax
 509:	cd 40                	int    $0x40
 50b:	c3                   	ret

0000050c <unlink>:
SYSCALL(unlink)
 50c:	b8 12 00 00 00       	mov    $0x12,%eax
 511:	cd 40                	int    $0x40
 513:	c3                   	ret

00000514 <fstat>:
SYSCALL(fstat)
 514:	b8 08 00 00 00       	mov    $0x8,%eax
 519:	cd 40                	int    $0x40
 51b:	c3                   	ret

0000051c <link>:
SYSCALL(link)
 51c:	b8 13 00 00 00       	mov    $0x13,%eax
 521:	cd 40                	int    $0x40
 523:	c3                   	ret

00000524 <mkdir>:
SYSCALL(mkdir)
 524:	b8 14 00 00 00       	mov    $0x14,%eax
 529:	cd 40                	int    $0x40
 52b:	c3                   	ret

0000052c <chdir>:
SYSCALL(chdir)
 52c:	b8 09 00 00 00       	mov    $0x9,%eax
 531:	cd 40                	int    $0x40
 533:	c3                   	ret

00000534 <dup>:
SYSCALL(dup)
 534:	b8 0a 00 00 00       	mov    $0xa,%eax
 539:	cd 40                	int    $0x40
 53b:	c3                   	ret

0000053c <getpid>:
SYSCALL(getpid)
 53c:	b8 0b 00 00 00       	mov    $0xb,%eax
 541:	cd 40                	int    $0x40
 543:	c3                   	ret

00000544 <sbrk>:
SYSCALL(sbrk)
 544:	b8 0c 00 00 00       	mov    $0xc,%eax
 549:	cd 40                	int    $0x40
 54b:	c3                   	ret

0000054c <sleep>:
SYSCALL(sleep)
 54c:	b8 0d 00 00 00       	mov    $0xd,%eax
 551:	cd 40                	int    $0x40
 553:	c3                   	ret

00000554 <uptime>:
SYSCALL(uptime)
 554:	b8 0e 00 00 00       	mov    $0xe,%eax
 559:	cd 40                	int    $0x40
 55b:	c3                   	ret

0000055c <uthread_init>:
//LAB2 추가
SYSCALL(uthread_init)
 55c:	b8 16 00 00 00       	mov    $0x16,%eax
 561:	cd 40                	int    $0x40
 563:	c3                   	ret

00000564 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 564:	55                   	push   %ebp
 565:	89 e5                	mov    %esp,%ebp
 567:	83 ec 18             	sub    $0x18,%esp
 56a:	8b 45 0c             	mov    0xc(%ebp),%eax
 56d:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 570:	83 ec 04             	sub    $0x4,%esp
 573:	6a 01                	push   $0x1
 575:	8d 45 f4             	lea    -0xc(%ebp),%eax
 578:	50                   	push   %eax
 579:	ff 75 08             	push   0x8(%ebp)
 57c:	e8 5b ff ff ff       	call   4dc <write>
 581:	83 c4 10             	add    $0x10,%esp
}
 584:	90                   	nop
 585:	c9                   	leave
 586:	c3                   	ret

00000587 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 587:	55                   	push   %ebp
 588:	89 e5                	mov    %esp,%ebp
 58a:	83 ec 28             	sub    $0x28,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 58d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 594:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 598:	74 17                	je     5b1 <printint+0x2a>
 59a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 59e:	79 11                	jns    5b1 <printint+0x2a>
    neg = 1;
 5a0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 5a7:	8b 45 0c             	mov    0xc(%ebp),%eax
 5aa:	f7 d8                	neg    %eax
 5ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5af:	eb 06                	jmp    5b7 <printint+0x30>
  } else {
    x = xx;
 5b1:	8b 45 0c             	mov    0xc(%ebp),%eax
 5b4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 5b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 5be:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5c4:	ba 00 00 00 00       	mov    $0x0,%edx
 5c9:	f7 f1                	div    %ecx
 5cb:	89 d1                	mov    %edx,%ecx
 5cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 5d0:	8d 50 01             	lea    0x1(%eax),%edx
 5d3:	89 55 f4             	mov    %edx,-0xc(%ebp)
 5d6:	0f b6 91 20 0d 00 00 	movzbl 0xd20(%ecx),%edx
 5dd:	88 54 05 dc          	mov    %dl,-0x24(%ebp,%eax,1)
  }while((x /= base) != 0);
 5e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
 5e4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 5e7:	ba 00 00 00 00       	mov    $0x0,%edx
 5ec:	f7 f1                	div    %ecx
 5ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
 5f1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 5f5:	75 c7                	jne    5be <printint+0x37>
  if(neg)
 5f7:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 5fb:	74 2d                	je     62a <printint+0xa3>
    buf[i++] = '-';
 5fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
 600:	8d 50 01             	lea    0x1(%eax),%edx
 603:	89 55 f4             	mov    %edx,-0xc(%ebp)
 606:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 60b:	eb 1d                	jmp    62a <printint+0xa3>
    putc(fd, buf[i]);
 60d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 610:	8b 45 f4             	mov    -0xc(%ebp),%eax
 613:	01 d0                	add    %edx,%eax
 615:	0f b6 00             	movzbl (%eax),%eax
 618:	0f be c0             	movsbl %al,%eax
 61b:	83 ec 08             	sub    $0x8,%esp
 61e:	50                   	push   %eax
 61f:	ff 75 08             	push   0x8(%ebp)
 622:	e8 3d ff ff ff       	call   564 <putc>
 627:	83 c4 10             	add    $0x10,%esp
  while(--i >= 0)
 62a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 62e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 632:	79 d9                	jns    60d <printint+0x86>
}
 634:	90                   	nop
 635:	90                   	nop
 636:	c9                   	leave
 637:	c3                   	ret

00000638 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 638:	55                   	push   %ebp
 639:	89 e5                	mov    %esp,%ebp
 63b:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 63e:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 645:	8d 45 0c             	lea    0xc(%ebp),%eax
 648:	83 c0 04             	add    $0x4,%eax
 64b:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 64e:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 655:	e9 59 01 00 00       	jmp    7b3 <printf+0x17b>
    c = fmt[i] & 0xff;
 65a:	8b 55 0c             	mov    0xc(%ebp),%edx
 65d:	8b 45 f0             	mov    -0x10(%ebp),%eax
 660:	01 d0                	add    %edx,%eax
 662:	0f b6 00             	movzbl (%eax),%eax
 665:	0f be c0             	movsbl %al,%eax
 668:	25 ff 00 00 00       	and    $0xff,%eax
 66d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 670:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 674:	75 2c                	jne    6a2 <printf+0x6a>
      if(c == '%'){
 676:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 67a:	75 0c                	jne    688 <printf+0x50>
        state = '%';
 67c:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 683:	e9 27 01 00 00       	jmp    7af <printf+0x177>
      } else {
        putc(fd, c);
 688:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 68b:	0f be c0             	movsbl %al,%eax
 68e:	83 ec 08             	sub    $0x8,%esp
 691:	50                   	push   %eax
 692:	ff 75 08             	push   0x8(%ebp)
 695:	e8 ca fe ff ff       	call   564 <putc>
 69a:	83 c4 10             	add    $0x10,%esp
 69d:	e9 0d 01 00 00       	jmp    7af <printf+0x177>
      }
    } else if(state == '%'){
 6a2:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 6a6:	0f 85 03 01 00 00    	jne    7af <printf+0x177>
      if(c == 'd'){
 6ac:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 6b0:	75 1e                	jne    6d0 <printf+0x98>
        printint(fd, *ap, 10, 1);
 6b2:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6b5:	8b 00                	mov    (%eax),%eax
 6b7:	6a 01                	push   $0x1
 6b9:	6a 0a                	push   $0xa
 6bb:	50                   	push   %eax
 6bc:	ff 75 08             	push   0x8(%ebp)
 6bf:	e8 c3 fe ff ff       	call   587 <printint>
 6c4:	83 c4 10             	add    $0x10,%esp
        ap++;
 6c7:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6cb:	e9 d8 00 00 00       	jmp    7a8 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 6d0:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 6d4:	74 06                	je     6dc <printf+0xa4>
 6d6:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 6da:	75 1e                	jne    6fa <printf+0xc2>
        printint(fd, *ap, 16, 0);
 6dc:	8b 45 e8             	mov    -0x18(%ebp),%eax
 6df:	8b 00                	mov    (%eax),%eax
 6e1:	6a 00                	push   $0x0
 6e3:	6a 10                	push   $0x10
 6e5:	50                   	push   %eax
 6e6:	ff 75 08             	push   0x8(%ebp)
 6e9:	e8 99 fe ff ff       	call   587 <printint>
 6ee:	83 c4 10             	add    $0x10,%esp
        ap++;
 6f1:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 6f5:	e9 ae 00 00 00       	jmp    7a8 <printf+0x170>
      } else if(c == 's'){
 6fa:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 6fe:	75 43                	jne    743 <printf+0x10b>
        s = (char*)*ap;
 700:	8b 45 e8             	mov    -0x18(%ebp),%eax
 703:	8b 00                	mov    (%eax),%eax
 705:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 708:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 70c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 710:	75 25                	jne    737 <printf+0xff>
          s = "(null)";
 712:	c7 45 f4 4d 0a 00 00 	movl   $0xa4d,-0xc(%ebp)
        while(*s != 0){
 719:	eb 1c                	jmp    737 <printf+0xff>
          putc(fd, *s);
 71b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 71e:	0f b6 00             	movzbl (%eax),%eax
 721:	0f be c0             	movsbl %al,%eax
 724:	83 ec 08             	sub    $0x8,%esp
 727:	50                   	push   %eax
 728:	ff 75 08             	push   0x8(%ebp)
 72b:	e8 34 fe ff ff       	call   564 <putc>
 730:	83 c4 10             	add    $0x10,%esp
          s++;
 733:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
        while(*s != 0){
 737:	8b 45 f4             	mov    -0xc(%ebp),%eax
 73a:	0f b6 00             	movzbl (%eax),%eax
 73d:	84 c0                	test   %al,%al
 73f:	75 da                	jne    71b <printf+0xe3>
 741:	eb 65                	jmp    7a8 <printf+0x170>
        }
      } else if(c == 'c'){
 743:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 747:	75 1d                	jne    766 <printf+0x12e>
        putc(fd, *ap);
 749:	8b 45 e8             	mov    -0x18(%ebp),%eax
 74c:	8b 00                	mov    (%eax),%eax
 74e:	0f be c0             	movsbl %al,%eax
 751:	83 ec 08             	sub    $0x8,%esp
 754:	50                   	push   %eax
 755:	ff 75 08             	push   0x8(%ebp)
 758:	e8 07 fe ff ff       	call   564 <putc>
 75d:	83 c4 10             	add    $0x10,%esp
        ap++;
 760:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 764:	eb 42                	jmp    7a8 <printf+0x170>
      } else if(c == '%'){
 766:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 76a:	75 17                	jne    783 <printf+0x14b>
        putc(fd, c);
 76c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 76f:	0f be c0             	movsbl %al,%eax
 772:	83 ec 08             	sub    $0x8,%esp
 775:	50                   	push   %eax
 776:	ff 75 08             	push   0x8(%ebp)
 779:	e8 e6 fd ff ff       	call   564 <putc>
 77e:	83 c4 10             	add    $0x10,%esp
 781:	eb 25                	jmp    7a8 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 783:	83 ec 08             	sub    $0x8,%esp
 786:	6a 25                	push   $0x25
 788:	ff 75 08             	push   0x8(%ebp)
 78b:	e8 d4 fd ff ff       	call   564 <putc>
 790:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 793:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 796:	0f be c0             	movsbl %al,%eax
 799:	83 ec 08             	sub    $0x8,%esp
 79c:	50                   	push   %eax
 79d:	ff 75 08             	push   0x8(%ebp)
 7a0:	e8 bf fd ff ff       	call   564 <putc>
 7a5:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 7a8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(i = 0; fmt[i]; i++){
 7af:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 7b3:	8b 55 0c             	mov    0xc(%ebp),%edx
 7b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b9:	01 d0                	add    %edx,%eax
 7bb:	0f b6 00             	movzbl (%eax),%eax
 7be:	84 c0                	test   %al,%al
 7c0:	0f 85 94 fe ff ff    	jne    65a <printf+0x22>
    }
  }
}
 7c6:	90                   	nop
 7c7:	90                   	nop
 7c8:	c9                   	leave
 7c9:	c3                   	ret

000007ca <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ca:	55                   	push   %ebp
 7cb:	89 e5                	mov    %esp,%ebp
 7cd:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7d0:	8b 45 08             	mov    0x8(%ebp),%eax
 7d3:	83 e8 08             	sub    $0x8,%eax
 7d6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7d9:	a1 88 8d 00 00       	mov    0x8d88,%eax
 7de:	89 45 fc             	mov    %eax,-0x4(%ebp)
 7e1:	eb 24                	jmp    807 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7e6:	8b 00                	mov    (%eax),%eax
 7e8:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7eb:	72 12                	jb     7ff <free+0x35>
 7ed:	8b 45 f8             	mov    -0x8(%ebp),%eax
 7f0:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 7f3:	72 24                	jb     819 <free+0x4f>
 7f5:	8b 45 fc             	mov    -0x4(%ebp),%eax
 7f8:	8b 00                	mov    (%eax),%eax
 7fa:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 7fd:	72 1a                	jb     819 <free+0x4f>
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ff:	8b 45 fc             	mov    -0x4(%ebp),%eax
 802:	8b 00                	mov    (%eax),%eax
 804:	89 45 fc             	mov    %eax,-0x4(%ebp)
 807:	8b 45 f8             	mov    -0x8(%ebp),%eax
 80a:	39 45 fc             	cmp    %eax,-0x4(%ebp)
 80d:	73 d4                	jae    7e3 <free+0x19>
 80f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 812:	8b 00                	mov    (%eax),%eax
 814:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 817:	73 ca                	jae    7e3 <free+0x19>
      break;
  if(bp + bp->s.size == p->s.ptr){
 819:	8b 45 f8             	mov    -0x8(%ebp),%eax
 81c:	8b 40 04             	mov    0x4(%eax),%eax
 81f:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 826:	8b 45 f8             	mov    -0x8(%ebp),%eax
 829:	01 c2                	add    %eax,%edx
 82b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 82e:	8b 00                	mov    (%eax),%eax
 830:	39 c2                	cmp    %eax,%edx
 832:	75 24                	jne    858 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 834:	8b 45 f8             	mov    -0x8(%ebp),%eax
 837:	8b 50 04             	mov    0x4(%eax),%edx
 83a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 83d:	8b 00                	mov    (%eax),%eax
 83f:	8b 40 04             	mov    0x4(%eax),%eax
 842:	01 c2                	add    %eax,%edx
 844:	8b 45 f8             	mov    -0x8(%ebp),%eax
 847:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 84a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 84d:	8b 00                	mov    (%eax),%eax
 84f:	8b 10                	mov    (%eax),%edx
 851:	8b 45 f8             	mov    -0x8(%ebp),%eax
 854:	89 10                	mov    %edx,(%eax)
 856:	eb 0a                	jmp    862 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 858:	8b 45 fc             	mov    -0x4(%ebp),%eax
 85b:	8b 10                	mov    (%eax),%edx
 85d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 860:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 862:	8b 45 fc             	mov    -0x4(%ebp),%eax
 865:	8b 40 04             	mov    0x4(%eax),%eax
 868:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 86f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 872:	01 d0                	add    %edx,%eax
 874:	39 45 f8             	cmp    %eax,-0x8(%ebp)
 877:	75 20                	jne    899 <free+0xcf>
    p->s.size += bp->s.size;
 879:	8b 45 fc             	mov    -0x4(%ebp),%eax
 87c:	8b 50 04             	mov    0x4(%eax),%edx
 87f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 882:	8b 40 04             	mov    0x4(%eax),%eax
 885:	01 c2                	add    %eax,%edx
 887:	8b 45 fc             	mov    -0x4(%ebp),%eax
 88a:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 88d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 890:	8b 10                	mov    (%eax),%edx
 892:	8b 45 fc             	mov    -0x4(%ebp),%eax
 895:	89 10                	mov    %edx,(%eax)
 897:	eb 08                	jmp    8a1 <free+0xd7>
  } else
    p->s.ptr = bp;
 899:	8b 45 fc             	mov    -0x4(%ebp),%eax
 89c:	8b 55 f8             	mov    -0x8(%ebp),%edx
 89f:	89 10                	mov    %edx,(%eax)
  freep = p;
 8a1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 8a4:	a3 88 8d 00 00       	mov    %eax,0x8d88
}
 8a9:	90                   	nop
 8aa:	c9                   	leave
 8ab:	c3                   	ret

000008ac <morecore>:

static Header*
morecore(uint nu)
{
 8ac:	55                   	push   %ebp
 8ad:	89 e5                	mov    %esp,%ebp
 8af:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 8b2:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 8b9:	77 07                	ja     8c2 <morecore+0x16>
    nu = 4096;
 8bb:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 8c2:	8b 45 08             	mov    0x8(%ebp),%eax
 8c5:	c1 e0 03             	shl    $0x3,%eax
 8c8:	83 ec 0c             	sub    $0xc,%esp
 8cb:	50                   	push   %eax
 8cc:	e8 73 fc ff ff       	call   544 <sbrk>
 8d1:	83 c4 10             	add    $0x10,%esp
 8d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 8d7:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 8db:	75 07                	jne    8e4 <morecore+0x38>
    return 0;
 8dd:	b8 00 00 00 00       	mov    $0x0,%eax
 8e2:	eb 26                	jmp    90a <morecore+0x5e>
  hp = (Header*)p;
 8e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 8e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 8ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8ed:	8b 55 08             	mov    0x8(%ebp),%edx
 8f0:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 8f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 8f6:	83 c0 08             	add    $0x8,%eax
 8f9:	83 ec 0c             	sub    $0xc,%esp
 8fc:	50                   	push   %eax
 8fd:	e8 c8 fe ff ff       	call   7ca <free>
 902:	83 c4 10             	add    $0x10,%esp
  return freep;
 905:	a1 88 8d 00 00       	mov    0x8d88,%eax
}
 90a:	c9                   	leave
 90b:	c3                   	ret

0000090c <malloc>:

void*
malloc(uint nbytes)
{
 90c:	55                   	push   %ebp
 90d:	89 e5                	mov    %esp,%ebp
 90f:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 912:	8b 45 08             	mov    0x8(%ebp),%eax
 915:	83 c0 07             	add    $0x7,%eax
 918:	c1 e8 03             	shr    $0x3,%eax
 91b:	83 c0 01             	add    $0x1,%eax
 91e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 921:	a1 88 8d 00 00       	mov    0x8d88,%eax
 926:	89 45 f0             	mov    %eax,-0x10(%ebp)
 929:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 92d:	75 23                	jne    952 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 92f:	c7 45 f0 80 8d 00 00 	movl   $0x8d80,-0x10(%ebp)
 936:	8b 45 f0             	mov    -0x10(%ebp),%eax
 939:	a3 88 8d 00 00       	mov    %eax,0x8d88
 93e:	a1 88 8d 00 00       	mov    0x8d88,%eax
 943:	a3 80 8d 00 00       	mov    %eax,0x8d80
    base.s.size = 0;
 948:	c7 05 84 8d 00 00 00 	movl   $0x0,0x8d84
 94f:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 952:	8b 45 f0             	mov    -0x10(%ebp),%eax
 955:	8b 00                	mov    (%eax),%eax
 957:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 95a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 95d:	8b 40 04             	mov    0x4(%eax),%eax
 960:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 963:	72 4d                	jb     9b2 <malloc+0xa6>
      if(p->s.size == nunits)
 965:	8b 45 f4             	mov    -0xc(%ebp),%eax
 968:	8b 40 04             	mov    0x4(%eax),%eax
 96b:	39 45 ec             	cmp    %eax,-0x14(%ebp)
 96e:	75 0c                	jne    97c <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 970:	8b 45 f4             	mov    -0xc(%ebp),%eax
 973:	8b 10                	mov    (%eax),%edx
 975:	8b 45 f0             	mov    -0x10(%ebp),%eax
 978:	89 10                	mov    %edx,(%eax)
 97a:	eb 26                	jmp    9a2 <malloc+0x96>
      else {
        p->s.size -= nunits;
 97c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 97f:	8b 40 04             	mov    0x4(%eax),%eax
 982:	2b 45 ec             	sub    -0x14(%ebp),%eax
 985:	89 c2                	mov    %eax,%edx
 987:	8b 45 f4             	mov    -0xc(%ebp),%eax
 98a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 98d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 990:	8b 40 04             	mov    0x4(%eax),%eax
 993:	c1 e0 03             	shl    $0x3,%eax
 996:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 999:	8b 45 f4             	mov    -0xc(%ebp),%eax
 99c:	8b 55 ec             	mov    -0x14(%ebp),%edx
 99f:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 9a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 9a5:	a3 88 8d 00 00       	mov    %eax,0x8d88
      return (void*)(p + 1);
 9aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9ad:	83 c0 08             	add    $0x8,%eax
 9b0:	eb 3b                	jmp    9ed <malloc+0xe1>
    }
    if(p == freep)
 9b2:	a1 88 8d 00 00       	mov    0x8d88,%eax
 9b7:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 9ba:	75 1e                	jne    9da <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 9bc:	83 ec 0c             	sub    $0xc,%esp
 9bf:	ff 75 ec             	push   -0x14(%ebp)
 9c2:	e8 e5 fe ff ff       	call   8ac <morecore>
 9c7:	83 c4 10             	add    $0x10,%esp
 9ca:	89 45 f4             	mov    %eax,-0xc(%ebp)
 9cd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 9d1:	75 07                	jne    9da <malloc+0xce>
        return 0;
 9d3:	b8 00 00 00 00       	mov    $0x0,%eax
 9d8:	eb 13                	jmp    9ed <malloc+0xe1>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 9da:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
 9e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 9e3:	8b 00                	mov    (%eax),%eax
 9e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 9e8:	e9 6d ff ff ff       	jmp    95a <malloc+0x4e>
  }
}
 9ed:	c9                   	leave
 9ee:	c3                   	ret
