	.file	"main2.c"
	.text
	.globl	even
	.type	even, @function
even:
.LFB23:
	.cfi_startproc
	endbr64
	movl	%edi, %eax
	movl	%esi, %ecx
	sall	%cl, %eax
	ret
	.cfi_endproc
.LFE23:
	.size	even, .-even
	.globl	go
	.type	go, @function
go:
.LFB24:
	.cfi_startproc
	endbr64
	pushq	%r12
	.cfi_def_cfa_offset 16
	.cfi_offset 12, -16
	pushq	%rbp
	.cfi_def_cfa_offset 24
	.cfi_offset 6, -24
	pushq	%rbx
	.cfi_def_cfa_offset 32
	.cfi_offset 3, -32
	movq	%rdi, %r12
	movl	$0, %ebx
	movl	$0, %ebp
	jmp	.L3
.L4:
	addl	%edi, %ebp
.L5:
	addl	$1, %ebx
.L3:
	cmpl	$9, %ebx
	jg	.L8
	movslq	%ebx, %rax
	movl	(%r12,%rax,4), %edi
	testb	$1, %dil
	jne	.L4
	movl	%ebx, %esi
	call	even
	addl	%eax, %ebp
	jmp	.L5
.L8:
	movl	%ebp, %eax
	popq	%rbx
	.cfi_def_cfa_offset 24
	popq	%rbp
	.cfi_def_cfa_offset 16
	popq	%r12
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE24:
	.size	go, .-go
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"this is you answer: %d"
	.text
	.globl	main
	.type	main, @function
main:
.LFB25:
	.cfi_startproc
	endbr64
	pushq	%rbx
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	subq	$48, %rsp
	.cfi_def_cfa_offset 64
	movl	$40, %ebx
	movq	%fs:(%rbx), %rax
	movq	%rax, 40(%rsp)
	xorl	%eax, %eax
	movl	$2, (%rsp)
	movl	$1, 4(%rsp)
	movl	$2, 8(%rsp)
	movl	$1, 12(%rsp)
	movl	$1, 16(%rsp)
	movl	$1, 20(%rsp)
	movl	$1, 24(%rsp)
	movl	$1, 28(%rsp)
	movl	$1, 32(%rsp)
	movl	$1, 36(%rsp)
	movq	%rsp, %rdi
	call	go
	movl	%eax, %edx
	leaq	.LC0(%rip), %rsi
	movl	$1, %edi
	movl	$0, %eax
	call	__printf_chk@PLT
	movq	40(%rsp), %rax
	xorq	%fs:(%rbx), %rax
	jne	.L12
	movl	$0, %eax
	addq	$48, %rsp
	.cfi_remember_state
	.cfi_def_cfa_offset 16
	popq	%rbx
	.cfi_def_cfa_offset 8
	ret
.L12:
	.cfi_restore_state
	call	__stack_chk_fail@PLT
	.cfi_endproc
.LFE25:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
