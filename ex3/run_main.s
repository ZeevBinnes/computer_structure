    # 205866163 Ze'ev Binnes

.section .rodata
    .align 8
formatScanfNum: .string "%d"    # format for scanning a number
formatScanfStr: .string " %s"   # format for scanning a string

.text

    .globl run_main
    .type run_main @function
# in main I'll make room in the stack for 2 pstrings and a number.
# I'll call scanf ot get the strings tnd an option for func_select,
# and then I'll call fun_select, and return.
# in all the parts of this task, there is a lot of repeted code.
# I thought it's more efficiant than jumping back and fourth between labels.
run_main:
    # no arguments
    # base of stack for function:
    pushq   %rbp
    movq    %rsp, %rbp
    subq    $528, %rsp  # make room for 2 pstrings and for a number (and align to 16)

    # get the length of pstring1
    movq    $formatScanfNum, %rdi   # format argument
    leaq    -256(%rbp), %rsi        # scan to the beggining of the first pstring
    xorq    %rax, %rax              # %rax = 0
    call    scanf

    # get pstring1
    movq    $formatScanfStr, %rdi
    leaq    -255(%rbp), %rsi        # save it 1 place after the length.
    xorq    %rax, %rax
    call    scanf

    # add a \0 to the end of the string
    leaq    -256(%rbp), %rax
    movzbq  (%rax), %rdx            # %rdx is the length L
    leaq    -255(%rbp, %rdx), %rax  # %rax = &p1[L]
    movb    $0, (%rax)              # p1[L] = \0

    # get the length of pstring2
    movq    $formatScanfNum, %rdi
    leaq    -512(%rbp), %rsi
    xorq    %rax, %rax
    call    scanf

    # get pstring2
    movq    $formatScanfStr, %rdi
    leaq    -511(%rbp), %rsi
    xorq    %rax, %rax
    call    scanf

    # add a \0 to the end of the string
    leaq    -512(%rbp), %rax
    movzbq  (%rax), %rdx
    leaq    -511(%rbp, %rdx), %rax
    movb    $0, (%rax)

    # get the option for run_func
    movq    $formatScanfNum, %rdi
    leaq    (%rsp), %rsi            # save it on the bottom of the stack
    xorq    %rax, %rax
    call    scanf

    # arguments for run_func(opt, &pstr1, &pstr2)
    movzbq  (%rsp), %rdi        # the option number in %rdi
    leaq    -256(%rbp), %rsi    # pointer to pstr1 in %rsi
    leaq    -512(%rbp), %rdx    # pointer to pstr2 in %rdx
    call    run_func

    # end the function:
    movq    %rbp, %rsp
    popq    %rbp
    ret
