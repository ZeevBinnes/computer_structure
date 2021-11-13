# Ze'ev Binnes 205866163

    .globl even
    .type even, @function
even:
    # num in %rdi, i in %rsi
    movq %rdi, %rax     # move num to the return value %rax
    movq %rsi, %rcx     # move i to %rcx, becuse salq only works on %cl.
    salq %cl, %rax      # num << i
    ret

# in the "go" function, I'll use only caller saved registers.
# Thats why I dont have to save anything on the stack for this function.
# I can do that because I know that "go" calls only "even", that uses only 3 registers.
    .globl go
    .type go @function
go:
    # pointer to array A in %rdi
    movq %rdi, %rdx     # copy the pointer to A
    xorq %r8, %r8     # set sum to 0
    xorq %r9, %r9     # set i to 0

.WhileLoop:
    leaq (%rdx, %r9, 4), %r10      # %r10 = &A[i]
    movl (%r10), %r10d       # %r10d = *(%r10) = A[i]
    movq $1, %rcx
    testl %ecx, %r10d       # check if the last bit is 0
    jne .IfNotEven      # if it isn't zero, goto not even
    
    # set parameters for even
    movl %r10d, %edi        # num = A[i]
    movl %r9d, %esi        # even.i = i
    call even
    
    addl %eax, %r8d        # sum += even(A[i], i)
    jmp .Cont

.IfNotEven:
    addl %r10d, %r8d       # sum += A[i]

.Cont:
    incq %r9       # i++
    movq $10, %rcx
    cmpq %r9, %rcx      # check if i < 10
    jne .WhileLoop      # continue while i < 10

    # end the function
    movq %r8, %rax     # put sum to return value
    ret
