8000 // Console input and output.
8001 // Input is from the keyboard or serial port.
8002 // Output is written to the screen and serial port.
8003 
8004 #include "types.h"
8005 #include "defs.h"
8006 #include "param.h"
8007 #include "traps.h"
8008 #include "spinlock.h"
8009 #include "sleeplock.h"
8010 #include "fs.h"
8011 #include "file.h"
8012 #include "memlayout.h"
8013 #include "mmu.h"
8014 #include "proc.h"
8015 #include "x86.h"
8016 #include "font.h"
8017 #include "graphic.h"
8018 
8019 static void consputc(int);
8020 
8021 static int panicked = 0;
8022 
8023 static struct {
8024   struct spinlock lock;
8025   int locking;
8026 } cons;
8027 
8028 static void
8029 printint(int xx, int base, int sign)
8030 {
8031   static char digits[] = "0123456789abcdef";
8032   char buf[16];
8033   int i;
8034   uint x;
8035 
8036   if(sign && (sign = xx < 0))
8037     x = -xx;
8038   else
8039     x = xx;
8040 
8041   i = 0;
8042   do{
8043     buf[i++] = digits[x % base];
8044   }while((x /= base) != 0);
8045 
8046   if(sign)
8047     buf[i++] = '-';
8048 
8049 
8050   while(--i >= 0)
8051     consputc(buf[i]);
8052 }
8053 
8054 
8055 
8056 
8057 
8058 
8059 
8060 
8061 
8062 
8063 
8064 
8065 
8066 
8067 
8068 
8069 
8070 
8071 
8072 
8073 
8074 
8075 
8076 
8077 
8078 
8079 
8080 
8081 
8082 
8083 
8084 
8085 
8086 
8087 
8088 
8089 
8090 
8091 
8092 
8093 
8094 
8095 
8096 
8097 
8098 
8099 
8100 // Print to the console. only understands %d, %x, %p, %s.
8101 void
8102 cprintf(char *fmt, ...)
8103 {
8104   int i, c, locking;
8105   uint *argp;
8106   char *s;
8107 
8108   locking = cons.locking;
8109   if(locking)
8110     acquire(&cons.lock);
8111 
8112   if (fmt == 0)
8113     panic("null fmt");
8114 
8115 
8116   argp = (uint*)(void*)(&fmt + 1);
8117   for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8118     if(c != '%'){
8119       consputc(c);
8120       continue;
8121     }
8122     c = fmt[++i] & 0xff;
8123     if(c == 0)
8124       break;
8125     switch(c){
8126     case 'd':
8127       printint(*argp++, 10, 1);
8128       break;
8129     case 'x':
8130     case 'p':
8131       printint(*argp++, 16, 0);
8132       break;
8133     case 's':
8134       if((s = (char*)*argp++) == 0)
8135         s = "(null)";
8136       for(; *s; s++)
8137         consputc(*s);
8138       break;
8139     case '%':
8140       consputc('%');
8141       break;
8142     default:
8143       // Print unknown % sequence to draw attention.
8144       consputc('%');
8145       consputc(c);
8146       break;
8147     }
8148   }
8149 
8150   if(locking)
8151     release(&cons.lock);
8152 }
8153 
8154 void
8155 panic(char *s)
8156 {
8157   int i;
8158   uint pcs[10];
8159 
8160   cli();
8161   cons.locking = 0;
8162   // use lapiccpunum so that we can call panic from mycpu()
8163   cprintf("lapicid %d: panic: ", lapicid());
8164   cprintf(s);
8165   cprintf("\n");
8166   getcallerpcs(&s, pcs);
8167   for(i=0; i<10; i++)
8168     cprintf(" %p", pcs[i]);
8169   panicked = 1; // freeze other CPU
8170   for(;;)
8171     ;
8172 }
8173 
8174 
8175 
8176 
8177 
8178 
8179 
8180 
8181 
8182 
8183 
8184 
8185 
8186 
8187 
8188 
8189 
8190 
8191 
8192 
8193 
8194 
8195 
8196 
8197 
8198 
8199 
8200 #define BACKSPACE 0x100
8201 #define CRTPORT 0x3d4
8202 /*static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory
8203 
8204 static void
8205 cgaputc(int c)
8206 {
8207   int pos;
8208 
8209   // Cursor position: col + 80*row.
8210   outb(CRTPORT, 14);
8211   pos = inb(CRTPORT+1) << 8;
8212   outb(CRTPORT, 15);
8213   pos |= inb(CRTPORT+1);
8214 
8215   if(c == '\n')
8216     pos += 80 - pos%80;
8217   else if(c == BACKSPACE){
8218     if(pos > 0) --pos;
8219   } else
8220     crt[pos++] = (c&0xff) | 0x0700;  // black on white
8221 
8222   if(pos < 0 || pos > 25*80)
8223     panic("pos under/overflow");
8224 
8225   if((pos/80) >= 24){  // Scroll up.
8226     memmove(crt, crt+80, sizeof(crt[0])*23*80);
8227     pos -= 80;
8228     memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
8229   }
8230 
8231   outb(CRTPORT, 14);
8232   outb(CRTPORT+1, pos>>8);
8233   outb(CRTPORT, 15);
8234   outb(CRTPORT+1, pos);
8235   crt[pos] = ' ' | 0x0700;
8236 }*/
8237 
8238 
8239 #define CONSOLE_HORIZONTAL_MAX 53
8240 #define CONSOLE_VERTICAL_MAX 20
8241 int console_pos = CONSOLE_HORIZONTAL_MAX*(CONSOLE_VERTICAL_MAX);
8242 //int console_pos = 0;
8243 void graphic_putc(int c){
8244   if(c == '\n'){
8245     console_pos += CONSOLE_HORIZONTAL_MAX - console_pos%CONSOLE_HORIZONTAL_MAX;
8246     if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8247       console_pos -= CONSOLE_HORIZONTAL_MAX;
8248       graphic_scroll_up(30);
8249     }
8250   }else if(c == BACKSPACE){
8251     if(console_pos>0) --console_pos;
8252   }else{
8253     if(console_pos >= CONSOLE_VERTICAL_MAX * CONSOLE_HORIZONTAL_MAX){
8254       console_pos -= CONSOLE_HORIZONTAL_MAX;
8255       graphic_scroll_up(30);
8256     }
8257     int x = (console_pos%CONSOLE_HORIZONTAL_MAX)*FONT_WIDTH + 2;
8258     int y = (console_pos/CONSOLE_HORIZONTAL_MAX)*FONT_HEIGHT;
8259     font_render(x,y,c);
8260     console_pos++;
8261   }
8262 }
8263 
8264 
8265 void
8266 consputc(int c)
8267 {
8268   if(panicked){
8269     cli();
8270     for(;;)
8271       ;
8272   }
8273 
8274   if(c == BACKSPACE){
8275     uartputc('\b'); uartputc(' '); uartputc('\b');
8276   } else {
8277     uartputc(c);
8278   }
8279   graphic_putc(c);
8280 }
8281 
8282 #define INPUT_BUF 128
8283 struct {
8284   char buf[INPUT_BUF];
8285   uint r;  // Read index
8286   uint w;  // Write index
8287   uint e;  // Edit index
8288 } input;
8289 
8290 #define C(x)  ((x)-'@')  // Control-x
8291 
8292 void
8293 consoleintr(int (*getc)(void))
8294 {
8295   int c, doprocdump = 0;
8296 
8297   acquire(&cons.lock);
8298   while((c = getc()) >= 0){
8299     switch(c){
8300     case C('P'):  // Process listing.
8301       // procdump() locks cons.lock indirectly; invoke later
8302       doprocdump = 1;
8303       break;
8304     case C('U'):  // Kill line.
8305       while(input.e != input.w &&
8306             input.buf[(input.e-1) % INPUT_BUF] != '\n'){
8307         input.e--;
8308         consputc(BACKSPACE);
8309       }
8310       break;
8311     case C('H'): case '\x7f':  // Backspace
8312       if(input.e != input.w){
8313         input.e--;
8314         consputc(BACKSPACE);
8315       }
8316       break;
8317     default:
8318       if(c != 0 && input.e-input.r < INPUT_BUF){
8319         c = (c == '\r') ? '\n' : c;
8320         input.buf[input.e++ % INPUT_BUF] = c;
8321         consputc(c);
8322         if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
8323           input.w = input.e;
8324           wakeup(&input.r);
8325         }
8326       }
8327       break;
8328     }
8329   }
8330   release(&cons.lock);
8331   if(doprocdump) {
8332     procdump();  // now call procdump() wo. cons.lock held
8333   }
8334 }
8335 
8336 
8337 
8338 
8339 
8340 
8341 
8342 
8343 
8344 
8345 
8346 
8347 
8348 
8349 
8350 int
8351 consoleread(struct inode *ip, char *dst, int n)
8352 {
8353   uint target;
8354   int c;
8355 
8356   iunlock(ip);
8357   target = n;
8358   acquire(&cons.lock);
8359   while(n > 0){
8360     while(input.r == input.w){
8361       if(myproc()->killed){
8362         release(&cons.lock);
8363         ilock(ip);
8364         return -1;
8365       }
8366       sleep(&input.r, &cons.lock);
8367     }
8368     c = input.buf[input.r++ % INPUT_BUF];
8369     if(c == C('D')){  // EOF
8370       if(n < target){
8371         // Save ^D for next time, to make sure
8372         // caller gets a 0-byte result.
8373         input.r--;
8374       }
8375       break;
8376     }
8377     *dst++ = c;
8378     --n;
8379     if(c == '\n')
8380       break;
8381   }
8382   release(&cons.lock);
8383   ilock(ip);
8384 
8385   return target - n;
8386 }
8387 
8388 
8389 
8390 
8391 
8392 
8393 
8394 
8395 
8396 
8397 
8398 
8399 
8400 int
8401 consolewrite(struct inode *ip, char *buf, int n)
8402 {
8403   int i;
8404 
8405   iunlock(ip);
8406   acquire(&cons.lock);
8407   for(i = 0; i < n; i++)
8408     consputc(buf[i] & 0xff);
8409   release(&cons.lock);
8410   ilock(ip);
8411 
8412   return n;
8413 }
8414 
8415 void
8416 consoleinit(void)
8417 {
8418   panicked = 0;
8419   initlock(&cons.lock, "console");
8420 
8421   devsw[CONSOLE].write = consolewrite;
8422   devsw[CONSOLE].read = consoleread;
8423 
8424   char *p;
8425   for(p="Starting XV6_UEFI...\n"; *p; p++)
8426     graphic_putc(*p);
8427 
8428   cons.locking = 1;
8429 
8430   ioapicenable(IRQ_KBD, 0);
8431 }
8432 
8433 
8434 
8435 
8436 
8437 
8438 
8439 
8440 
8441 
8442 
8443 
8444 
8445 
8446 
8447 
8448 
8449 
