    # 205866163 Ze'ev Binnes

.section .rodata
    .align 8
# the switch menu:
# all the options are between 50-60.
# the options that are not allowed send to default,
# there they print an error and return.
# otherwise, jump to the label that will call the right function.
.Lswitch_menu:
    .quad .Llen     # case 50: pstrlen
    .quad .Ldef     # case 51: default
    .quad .Lreplace # case 52: replaceChar
    .quad .Lcpy     # case 53: pstrijcpy
    .quad .Lswap    # case 54: swapCase
    .quad .Lcmp     # case 55: pstrijcmp
    .quad .Ldef     # case 56: default
    .quad .Ldef     # case 57: default
    .quad .Ldef     # case 58: default
    .quad .Ldef     # case 59: default
    .quad .Llen     # case 60: pstrlen

# formats for printing and scanning.
# 50 is also good for 60, and 53 is also good for 54.
format50: .string "first pstring length: %d, second pstring length: %d\n"
formatdef: .string "invalid option!\n"
format52: .string "old char: %c, new char: %c, first string: %s, second string: %s\n"
format53: .string "length: %d, string: %s\n"
format55: .string "compare result: %d\n"
formatScanfChar: .string " %c"
formatScanfNum: .string "%d"

    .text

    .globl run_func
    .type run_func @function
run_func:
    # opt in %rdi, &p1 in %rsi, &p2 in %rdx.
    # I'm not making place on the stack yet,
    # because calling pstrlen function doesn't requier saving anything on the stack.

    # prepare to the switch menu
    leaq    -50(%rdi), %rdi             # opt = opt - 50
    cmpq    $10, %rdi                   # compare opt:10 (opt - 10)
    ja      .Ldef                       # above 60, or negative numbers, unvalid input
    jmp     *.Lswitch_menu(,%rdi,8)     # goto right place in switch-menu

.Llen:
    # pstlen uses only %rdi and %rax, so I don't need to save anything on the stack.
    # I'll call pstrlen, and each time save the return value straight to the register
    # that will give it as parameter to printf.

    movq    %rsi, %rdi      # send first str as parameter to pstrlen
    call    pstrlen    
    movq    %rax, %rsi      # save the length as second parameter to printf

    movq    %rdx, %rdi      # send second str as parameter to pstrlen
    call    pstrlen
    movq    %rax, %rdx      # save the length as third parameter to printf

    movq    $format50, %rdi # pass the print format to printf
    xorq    %rax, %rax      # %rax = 0, needed for calling printf
    call    printf
    
    ret

.Lreplace:
    # save registers on the stack,
    # call scanf twice to get oldChar and newChar,
    # call replaceChar for each of the pstrings,
    # and print the report.

    # use the stack to save the pointers:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rsi
    pushq   %rdx
    subq    $16, %rsp       # make room for the chars from scanf
    # scanf needs to be at %16=0 addresses, so 16 bytes are needed
    
    # arguments for scanf:
    leaq    (%rsp), %rsi            # dest is the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfChar, %rdi  # format " %c"
    call    scanf

    # arguments for scanf:
    leaq    8(%rsp), %rsi           # dest is 8 bytes above the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfChar, %rdi  # format " %c"
    call    scanf

    # arguments for replaceChar(pstr,oldChar,newChar):
    movzbq  (%rsp), %rsi        # oldChar is at the bottom of the stack
    movzbq  8(%rsp), %rdx       # newChar is 8 bytes above
    movq    -8(%rbp), %rdi      # string1 is in the beggining of the stacks frame
    call    replaceChar

    # again, for string2:
    movzbq  (%rsp), %rsi
    movzbq  8(%rsp), %rdx
    movq    -16(%rbp), %rdi     # string2 is 8 bytes under the beggining of the stacks frame
    call    replaceChar

    # printf arguments:
    movq    $format52, %rdi # print format
    popq    %rsi            # oldChar
    popq    %rdx            # newChar
    popq    %r8             # string2
    leaq    1(%r8), %r8     # the string begins 1 place after the struct
    popq    %rcx            # string 1
    leaq    1(%rcx), %rcx   # the string begins 1 place after the struct
    xorq    %rax, %rax      # %rax = 0
    call    printf

    # end the function:
    movq    %rbp, %rsp
    popq    %rbp
    ret


.Lcpy:
    # save registers on the stack,
    # call scanf twice to get i and j,
    # call pstrijcpy for the two pstrings,
    # and print the report.

    # use the stack to save the pointers:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rsi
    pushq   %rdx
    subq    $16, %rsp       # make room for i, j from scanf
    # scanf needs to be at %16=0 addresses, so 16 bytes are needed
    
    # arguments for scanf:
    leaq    (%rsp), %rsi            # i is the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfNum, %rdi   # format "%d"
    call    scanf

    # arguments for scanf:
    leaq    8(%rsp), %rsi           # j is 8 bytes above the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfNum, %rdi   # format "%d"
    call    scanf

    # arguments for pstrijcpy(dst, src, i, j)
    movl    (%rsp), %edx        # i - send only the fist 4 bytes, for int
    movl    8(%rsp), %ecx       # j - send only the fist 4 bytes, for int
    movq    -8(%rbp), %rdi      # dst
    movq    -16(%rbp), %rsi     # src
    call    pstrijcpy

    # arguments for printf:
    movq    $format53, %rdi
    movq    -8(%rbp), %rdx      # pointer to dst (won't be sent as is)
    movzbq  (%rdx), %rsi        # dst->len
    leaq    1(%rdx), %rdx       # dst->str
    xorq    %rax, %rax          # %rax = 0
    call    printf

    # arguments for printf:
    movq    $format53, %rdi
    movq    -16(%rbp), %rdx     # pointer to src
    movzbq  (%rdx), %rsi        # src->len
    leaq    1(%rdx), %rdx       # src->str
    xorq    %rax, %rax          # %rax = 0
    call    printf

    # end the function:
    movq    %rbp, %rsp
    popq    %rbp
    ret

.Lswap:
    # save registers on the stack (because of the double cll to printf),
    # call swapCase for the two pstrings,
    # and print the report.

    # use the stack to save the pointers:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rsi
    pushq   %rdx

    # call swapCase (furst time from register, socind tine better to use the stack)
    movq    %rsi, %rdi
    call swapCase
    movq    (%rsp), %rdi        # the second string is at the bottom of the stack
    call swapCase

    # arguments for printf:
    movq    $format53, %rdi
    movq    -8(%rbp), %rdx      # pointer to pstr1
    movzbq  (%rdx), %rsi        # pstr1->len
    leaq    1(%rdx), %rdx       # pstr1->str
    xorq    %rax, %rax          # %rax = 0
    call    printf

    # arguments for printf:
    movq    $format53, %rdi
    movq    -16(%rbp), %rdx     # pointer to pstr2
    movzbq  (%rdx), %rsi        # pstr2->len
    leaq    1(%rdx), %rdx       # pstr2->str
    xorq    %rax, %rax          # %rax = 0
    call    printf

    # end the function:
    movq    %rbp, %rsp
    popq    %rbp
    ret

.Lcmp:
    # save registers on the stack,
    # call scanf twice to get i and j,
    # call pstrijcmp for the two pstrings,
    # and print the report.

    # this part is extremly simmilar to .Lcpy.
    # I decided to copy all this code again,
    # because I didn't want the program to jump between labels.

    # use the stack to save the pointers:
    pushq   %rbp
    movq    %rsp, %rbp
    pushq   %rsi
    pushq   %rdx
    subq    $16, %rsp       # make room for i, j from scanf
    # scanf needs to be at %16=0 addresses, so 16 bytes are needed
    
    # arguments for scanf:
    leaq    (%rsp), %rsi            # i is the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfNum, %rdi   # format "%d"
    call    scanf

    # arguments for scanf:
    leaq    8(%rsp), %rsi           # j is 8 bytes above the bottom of the stack
    xorq    %rax, %rax              # %rax = 0
    movq    $formatScanfNum, %rdi   # format "%d"
    call    scanf

    # arguments for pstrijcmp(dst, src, i, j)
    movl    (%rsp), %edx        # i
    movl    8(%rsp), %ecx       # j
    movq    -8(%rbp), %rdi      # dst
    movq    -16(%rbp), %rsi     # src
    call    pstrijcmp

    # arguments for printf:
    movq    $format55, %rdi
    movq    %rax, %rsi          # print the int that pstijcmp returned.
    xorq    %rax, %rax          # %rax = 0
    call    printf

    # end the function:
    movq    %rbp, %rsp
    popq    %rbp
    ret

.Ldef:
    # I wrote "default", but actually this is the place for un recognized options.
    # here we print an error and return.
    movq    $formatdef, %rdi    # passing the format as a parameter to printf.
    movq    $0, %rax
    call    printf
    ret
