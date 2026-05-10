	.text

	/*
         * save the old thread's registers,
         * restore the new thread's registers.
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */

	pushal 							//레지스터를 current_thread의 스택에 저장

	movl current_thread, %eax 		//current_thread의 스택 포인터 저장
	movl %esp, (%eax)
	movl next_thread, %eax			//next_thread의 스택으로 전환
	movl (%eax), %esp

	movl %eax, current_thread  		//current_thread를 next_thread로 설정
	popal 							//next_thread의 레지스터 상태를 복원

	movl $0, next_thread 
	
	ret    /* return to ra */
