    # 205866163 Ze'ev Binnes

.section .rodata
    .align 8
# error printing format for unvalid i,j in pstrijcpy and pstrijcmp.
formatCpyErr: .string "invalid input!\n"

.text
# the functions in this page don't call any other functions (except printf once),
# so I don't need to savr anything on the stack (except that one time).


    .globl pstrlen
    .type pstrlen @function
pstrlen:
    # &pstr in %rdi
    # the first byte in pstr represents the length.
    movzbq    (%rdi), %rax  # %rax = pstr.len
    ret


    .globl replaceChar
    .type replaceChar @function
replaceChar:
    # &pstr in %rdi, oldChar in %rsi, newChar in %rdx
    # I'll copy the pointer to %rcx and work on %rcx,
    # and in the end I'll return the original pointer (to the start).
    leaq    (%rdi), %rcx
    cmpb    $0, (%rcx)      # if the strings size is 0, end
    je      .LEndRep
.LWhileRep:
    # iterate through the chars of the string,
    # and replace them with newChar if they equal to oldChar.
    # I didn't write it as a do-while loop,
    # becuase that would have forced me to send the un changed bytes by two labels,
    # so I think the way I wtore it is more efficient.
    leaq    1(%rcx), %rcx   # check the next byte
    movzbq  (%rcx), %r8     # mooved to a register, for faster checking
    cmpb    $0, %r8b        # continue while the byte isn't \0.
    je      .LEndRep
    cmpb    %sil, %r8b       # check if the byte should be replaced
    jne     .LWhileRep      # if not, go back to the loop
    movb    %dl, (%rcx)     # if it is, replace the byte
    jmp     .LWhileRep      # continue, until the sting ends
.LEndRep:
    movq    %rdi, %rax      # return a pointer to the beggining of the string
    ret


    .globl pstrijcpy
    .type pstrijcpy @function
pstrijcpy:
    # dst in %rdi, src in %rsi, i in %rdx, j in %rcx

    # make sure i,j are valid.
    # then iterate on the indexes by incresing %rdx untill it's bigger than %rcx.
    
    # check validty:
    cmpb    $0, %dl
    jb      .LcpyErr    # Error if i < 0
    cmpl    $256, %ecx
    jae     .LcpyErr    # Error if j is more than a byte long
    cmpb    (%rdi), %cl
    jae     .LcpyErr    # Error if j >= dst.len
    cmpb    (%rsi), %cl
    jae     .LcpyErr    # Error if j >= src.len

    # make the indexes match the represention
    # the indexes start from 0, but the first char in the string is at pstr+1.
    incq    %rdx
    incq    %rcx
    cmpb    %cl, %dl    # if i > j, don't copy anything
    ja      .LcpyEnd
    movzbq  %dl, %rdx   # only fo make sure ther'e no redundant bits
.LcpyLoop:
    # increse i in each iteration, and while i <= j, copy the byte in src[i].
    leaq    (%rdi, %rdx), %rax  # %rax is the address of the byte that might be changed
    leaq    (%rsi, %rdx), %r8
    movzbq  (%r8), %r8          # %r8 = src[i]
    movb    %r8b, (%rax)        # dst[i] = src[i]
    incq    %rdx                # continue the loop
    cmpb    %cl, %dl            # if i <= j, repeat
    jbe     .LcpyLoop
.LcpyEnd:
    movq    %rdi, %rax          # return pointer to dst
    ret

.LcpyErr:
    pushq   %rdi                # save a pointer to dst
    # set argument for printf, to print error message:
    movq    $formatCpyErr, %rdi
    xorq    %rax, %rax          # %rax = 0
    call printf
    popq    %rax                # return pointer to dst
    ret


    .globl swapCase
    .type swapCase @function
swapCase:
    # iterate through the pstring, and swap upper and lower case in English letters.

    # pstr in %rdi
    leaq    1(%rdi), %rsi
    cmpb    $0, (%rsi)      # check the first char in the string
    je      .LendSwap
    movb    (%rsi), %dl     # make it faster by saving the memmory on the register.
.LwhileSwap:
    cmpb    $65, %dl        # A = 65, below A ther'e no swapable chars
    jae     .LcheckSwap     # above that, check if a swap in needed
# switch to next char and continue the loop
.LcontSwap:
    leaq    1(%rsi), %rsi   # increse the index by 1
    movb    (%rsi), %dl     # copy to register, for fast checkes
    cmpb    $0, %dl         # if it is \0, end. otherwise, continue loop.
    jne     .LwhileSwap
.LendSwap:
    movq    %rdi, %rax      # return a pointer to str
    ret
# check the swping in tow parts.
# in the first part, if the char is between A-Z, swap to lowercasc.
# in the second part, if the char is between a-z, swap to UpperCase.
.LcheckSwap:
    cmpb    $122, %dl       # z = 122, above z ther'e no swapable chars 
    ja      .LcontSwap      # so if it's above, contione loop.
    cmpb    $90, %dl        # Z = 90
    ja      .LcheckSwap2    # between Z and z, go to another check.
    addb    $32, %dl        # a - A = 32, so add 32 to swap to lowerCase
    movb    %dl, (%rsi)     # %rsi points to the current char in the memmory.
    jmp     .LcontSwap
.LcheckSwap2:
    cmpb    $97, %dl        # a = 97, so between 90 to 97 ther'e no swapable chars
    jb      .LcontSwap      # so if it's under, continue the loop
    subb    $32, %dl        # a - A = 32, so sub 32 to swap to upperCase
    movb    %dl, (%rsi)     # %rsi points to the current char in the memmory.
    jmp     .LcontSwap


    .globl pstrijcmp
    .type pstrijcmp @function
pstrijcmp:
    # pstr1 in %rdi, pstr2 in %rsi, i in %rdx, j in %rcx

    # check validty:
    cmpb    $0, %dl
    jb      .LcmpErr    # Error if i < 0
    cmpl    $256, %ecx
    jae     .LcmpErr    # Error if j is more than a byte long
    cmpb    (%rdi), %cl
    jae     .LcmpErr    # Error if j >= psr1.len
    cmpb    (%rsi), %cl
    jae     .LcmpErr    # Error if j >= pstr2.len
    
    # make the indexes match the represention
    # the indexes start from 0, but the first char in the string is at pstr+1.
    incq    %rdx
    incq    %rcx
    cmpb    %cl, %dl    # if i > j, send a Error
    ja      .LcmpErr
    movzbq  %dl, %rdx   # only fo make sure ther'e no redundant bits
.LcmpLoop:
    # increse i in each iteration, and while i <= j,
    # so if pstr1[i] > pstr2[i] return 1,
    # and if pstr1[i] < pstr2[i] return -1,
    # and if they are equal, go on to check the next byte.
    leaq    (%rdi, %rdx), %rax  # %rax is the address of the current byte in pstr1
    leaq    (%rsi, %rdx), %r8
    movzbq  (%r8), %r8          # %r8 = pstr2[i]
    cmpb    %r8b, (%rax)
    ja      .Lstr1Big           # if pstr1[i] > pstr2[i]
    jb      .Lstr1Small         # if pstr1[i] < pstr2[i]
    incq    %rdx                # else, they are equal: continue the loop
    cmpb    %cl, %dl            # if i <= j, repeat the loop again
    jbe     .LcmpLoop
    xorq    %rax, %rax          # loop is finished and they are equal: retun 0
    ret
.Lstr1Big:
    movq    $1, %rax            # if pstr1[i] > pstr2[i], return 1
    ret
.Lstr1Small:
    movq    $-1, %rax           # if pstr1[i] < pstr2[i] return -1
    ret    
.LcmpErr:
    # set argument for printf, to print error message:
    movq    $formatCpyErr, %rdi
    xorq    %rax, %rax          # %rax = 0
    call printf
    movq    $-2, %rax
    ret
