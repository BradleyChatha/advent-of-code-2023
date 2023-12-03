%include "part1.asm"
%include "part2.asm"
%include "common.asm"

[section .data]

INPUT_FILE:      db "../day3/input.txt", 0x00
INPUT_FILE_MODE: db "r"
ERROR_INPUT:     db "failed to open input file", 0x0A, 0x00
ERROR_INPUT_MEM: db "failed to allocate memory for file", 0x0A, 0x00
ERROR_FREAD:     db "failed to read data from file", 0x0A, 0x00
DBG_HEX:         db "0X%X", 0x0A, 0x00
PART_1:          db "Part 1: %d", 0x0A, 0x00
NEW_LINE:        db 0x0A
TRUE_WORD:       dw 1

[section .text]

global main
extern printf
extern fopen
extern fread
extern fseek
extern ftell
extern close
extern malloc
extern exit

main:
    push rsp
    mov rbp, rsp
    push r12 ; Must be preserved under SysV ABI
    push r13 ; Must be preserved under SysV ABI
    push r14 ; Must be preserved under SysV ABI
    sub rsp, 8

    ; Open the file and PERM store the FILE* into r12
    lea rdi, [INPUT_FILE]
    lea rsi, [INPUT_FILE_MODE]
    call fopen

    cmp rax, 0
    jne .fopen_success
        lea rdi, [ERROR_INPUT]
        call printf
        mov rax, 1
        jmp .leave
    .fopen_success:
    mov r12, rax

    ; Find out how long the file is and PERM store it into r14
    mov rdi, r12
    mov rsi, 0
    mov rdx, 2 ; SEEK_END
    call fseek

    mov rdi, r12
    call ftell
    mov r14, rax

    mov rdi, r12
    mov rsi, 0
    mov rdx, 0 ; SEEK_START
    call fseek

    ; Allocate the memory we need to read it in and PERM store the pointer into r13
    mov rdi, r14
    call malloc

    cmp rax, 0
    jne .malloc_success
        lea rdi, [ERROR_INPUT_MEM]
        call printf
        mov rax, 1
        jmp .leave
    .malloc_success:
    mov r13, rax

    ; Read in the file
    mov rdi, r13
    mov rsi, 1
    mov rdx, r14
    mov rcx, r12
    call fread

    cmp rax, r14
    je .fread_success
        lea rdi, [ERROR_FREAD]
        call printf
        mov rax, 1
        jmp .leave
    .fread_success:

    ; Perform solution
    mov rdi, r13
    mov rsi, r14
    call part1

    mov rdi, r13
    mov rsi, r14
    call part2

    xor rax, rax ; Go into .leave with a successful return code

    ; Should _technically_ do resource cleanup here as well, but for AoC this isn't a big deal.
    .leave:
    add rsp, 8
    pop r14
    pop r13
    pop r12
    leave
    ret