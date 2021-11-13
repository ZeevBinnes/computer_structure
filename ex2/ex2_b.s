# Ze'ev Binnes 205866163

    .globl even
    .type even, @function
even:
    # num in %rdi, i in %rsi
    movq %rdi, %rax     # move num to the return value %rax
    movq %rsi, %rcx     # move i to %rcx, becuse salq only works on %cl.
    salq %cl, %rax      # num << i
    ret

    .globl go
    .type go @function
go:
    # start
    pushq %rbp
    movq %rsp, %rbp
    # save 4 callee-saved registers
    pushq %rbx      # for a pointer to A
    pushq %r12      # for sum
    pushq %r13      # for i
    pushq %r14      # for each A[i]

    movq %rdi, %rbx     # copy to pointer to the array A
    xorq %r12, %r12     # set sum to 0
    xorq %r13, %r13     # set i to 0
.WhileLoop:
    leaq (%rbx, %r13, 4), %r10      # %r10 = &A[i]
    movl (%r10), %r14d       # %r14 = *(%r10) = A[i]
    movq $1, %rcx
    testl %ecx, %r14d       # check if the last bit is 0
    jne .IfNotEven      # if it isn't zero, goto not even
    
    # set parameters for even
    movl %r14d, %edi        # num = A[i]
    movl %r13d, %esi        # even.i = i
    call even
    
    addl %eax, %r12d        # sum += even(A[i], i)
    jmp .Cont
.IfNotEven:
    addl %r14d, %r12d       # sum += A[i]
.Cont:
    incq %r13       # i++
    movq $10, %rcx
    cmpq %r13, %rcx
    jne .WhileLoop      # continue while i < 10

    # end the function
    movq %r12, %rax     # put sum to return value
    # restore the registers:
    popq %r14
    popq %r13
    popq %r12
    popq %rbx
    movq %rbp, %rsp
    popq %rbp
    ret

