2300 // Per-CPU state
2301 struct cpu {
2302   uchar apicid;                // Local APIC ID
2303   struct context *scheduler;   // swtch() here to enter scheduler
2304   struct taskstate ts;         // Used by x86 to find stack for interrupt
2305   struct segdesc gdt[NSEGS];   // x86 global descriptor table
2306   volatile uint started;       // Has the CPU started?
2307   int ncli;                    // Depth of pushcli nesting.
2308   int intena;                  // Were interrupts enabled before pushcli?
2309   struct proc *proc;
2310            // The process running on this cpu or null
2311 };
2312 
2313 extern struct cpu cpus[NCPU];
2314 extern int ncpu;
2315 
2316 
2317 // Saved registers for kernel context switches.
2318 // Don't need to save all the segment registers (%cs, etc),
2319 // because they are constant across kernel contexts.
2320 // Don't need to save %eax, %ecx, %edx, because the
2321 // x86 convention is that the caller has saved them.
2322 // Contexts are stored at the bottom of the stack they
2323 // describe; the stack pointer is the address of the context.
2324 // The layout of the context matches the layout of the stack in swtch.S
2325 // at the "Switch stacks" comment. Switch doesn't save eip explicitly,
2326 // but it is on the stack and allocproc() manipulates it.
2327 struct context {
2328   uint edi;
2329   uint esi;
2330   uint ebx;
2331   uint ebp;
2332   uint eip;
2333 };
2334 
2335 enum procstate { UNUSED, EMBRYO, SLEEPING, RUNNABLE, RUNNING, ZOMBIE };
2336 
2337 // Per-process state
2338 struct proc {
2339   uint sz;                     // Size of process memory (bytes)
2340   pde_t* pgdir;                // Page table
2341   char *kstack;                // Bottom of kernel stack for this process
2342   enum procstate state;        // Process state
2343   int pid;                     // Process ID
2344   struct proc *parent;         // Parent process
2345   struct trapframe *tf;        // Trap frame for current syscall
2346   struct context *context;     // swtch() here to run process
2347   void *chan;                  // If non-zero, sleeping on chan
2348   int killed;                  // If non-zero, have been killed
2349   struct file *ofile[NOFILE];  // Open files
2350   struct inode *cwd;           // Current directory
2351   char name[16];               // Process name (debugging)
2352   //LAB2 추가
2353   uint scheduler;
2354 };
2355 
2356 // Process memory is laid out contiguously, low addresses first:
2357 //   text
2358 //   original data and bss
2359 //   fixed-size stack
2360 //   expandable heap
2361 
2362 
2363 
2364 
2365 
2366 
2367 
2368 
2369 
2370 
2371 
2372 
2373 
2374 
2375 
2376 
2377 
2378 
2379 
2380 
2381 
2382 
2383 
2384 
2385 
2386 
2387 
2388 
2389 
2390 
2391 
2392 
2393 
2394 
2395 
2396 
2397 
2398 
2399 
