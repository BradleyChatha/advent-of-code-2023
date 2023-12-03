[section .text]

struc part1_stack
    .input_ptr: resq 1
    .input_len: resq 1
endstruc

; (ptr, len)
part1:
    push rbp
    mov rbp, rsp
    sub rsp, part1_stack_size
    push r12
    push r13

    ; Setup stack
    mov [rbp-part1_stack_size+part1_stack.input_ptr], rdi
    mov [rbp-part1_stack_size+part1_stack.input_len], rsi

    ; Find length of a line and PERM store it into r12, rdi is already input_ptr
    call find_line_length
    inc rax ; Include the new line
    mov r12, rax

    ; We're using string instructions, so setup the registers it uses
    mov rdi, [rbp-part1_stack_size+part1_stack.input_ptr]
    mov rcx, [rbp-part1_stack_size+part1_stack.input_len]

    ; Use r11 as the overall sum
    xor r11, r11

    .loop_start:
        ; Determine what to do based on the next char
        mov ah, [rdi]
            cmp ah, '.'
            je .read_dots
            
            cmp ah, 0x0A
            je .skip
            
            cmp ah, 0
            je .loop_end

            cmp ah, 0x30 ; '0'
            setge dl
            cmp ah, 0x39 ; '9'
            setle dh
            and dl, dh
            jnz .read_number
        jmp .skip

        .read_dots:
            mov al, '.'
            repe scasb
            dec rdi
            inc rcx
            jmp .loop_start

        .read_number:
            xor r8, r8   ; Use r8 as accumulator
            mov r10, rdi ; Use r10 to store the start index
            xor rsi, rsi ; Use rsi to keep track of how many digits we have
            mov r13b, 0x0A
            %rep 3
                ; numbers can only be max of 3 digits in the input
                mov al, [rdi]
                    cmp al, 0x30 ; '0'
                    setge dl
                    cmp al, 0x39 ; '9'
                    setle dh
                    and dl, dh
                    jz .read_number_done_parse

                inc rdi
                dec rcx
                
                ; Multiply accumulator by 10
                mov r9, r8
                shl r9, 3  ; x8
                add r8, r8 ; x2
                add r8, r9 ; x10

                ; Add digit
                and rax, 0xF
                add r8, rax
                inc rsi
            %endrep
            .read_number_done_parse:
        
            xor rdx, rdx ; Use rdx as a flag on whether to use the number or not
            add rsi, 2   ; To include diagonals properly
            mov al, '.'

            ; (NOTE: The input appears to be structured so that no digits can touch, even diagonally)
            ; Check if the char previous to the first digit is a symbol
            cmp r10, [rbp-part1_stack_size+part1_stack.input_ptr]
            je .skip_prefix_char
                dec r10
                cmp r13b, [r10]
                je .skip_prefix_char
                cmp al, [r10]
                cmovne dx, [TRUE_WORD]
            .skip_prefix_char:

            ; Check the char after the last digit
            cmp r13b, [rdi]
            je .skip_suffix_char
            cmp al, [rdi]
            cmovne dx, [TRUE_WORD]
            .skip_suffix_char:

            ; Check the chars above the digits
            push r10
            push rsi
            sub r10, r12
            cmp r10, [rbp-part1_stack_size+part1_stack.input_ptr]
            jl .top_chars_edge_case
                .loop_top_chars:
                    cmp r13b, [r10]
                    je .top_char_next ; Skip new lines (edge case)
                    cmp al, [r10]
                    cmovne dx, [TRUE_WORD]
                    .top_char_next:
                    inc r10
                    dec rsi
                    jnz .loop_top_chars
            .top_chars_edge_case:
                inc r10
                cmp r10, [rbp-part1_stack_size+part1_stack.input_ptr]
                jne .skip_top_chars
                dec rsi
                jmp .loop_top_chars
            .skip_top_chars:
            pop rsi
            pop r10

            ; Check the chars below the digits
            add r10, r12
            mov rax, [rbp-part1_stack_size+part1_stack.input_ptr]
            add rax, [rbp-part1_stack_size+part1_stack.input_len]
            cmp r10, rax
            jg .skip_bot_chars
                mov al, '.'
                .loop_bot_chars:
                    cmp r13b, [r10]
                    je .bot_char_next ; Skip new lines (edge case)
                    cmp al, [r10]
                    cmovne dx, [TRUE_WORD]
                    .bot_char_next:
                    inc r10
                    dec rsi
                    jnz .loop_bot_chars
            .skip_bot_chars:

            cmp dl, 0
            je .loop_start
            add r11, r8
            jmp .loop_start

        .skip:
            scasb
            dec rcx
            jmp .loop_start
    .loop_end:

    lea rdi, [PART_1]
    mov rsi, r11
    call printf

    .leave:
    pop r13
    pop r12
    add rsp, part1_stack_size
    leave
    ret