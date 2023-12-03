[section .text]

; (ptr)
; Does not include the new line char in the length.
find_line_length:
    mov rsi, rdi
    xor rax, rax
    vpbroadcastb ymm0, [NEW_LINE]

    .loop_start:
        vmovdqu ymm1, [rsi]         ; ymm1              = Next 32 bytes of data
        vpcmpeqb ymm2, ymm1, ymm0   ; ymm2[byte]        = (ymm0[byte] == ymm1[byte]) ? 0xFF : 0
        vpmovmskb eax, ymm2         ; eax[byte as bit]  = (ymm2[byte] > 0) ? 1 : 0
        add rsi, 32
        cmp eax, 0                  ; If not equal, at least one byte was a new line.
        je .loop_start

    sub rsi, rdi                ; Find how many bytes we've read in so far.
    sub rsi, 32                 ; (undoes an extra + 32).
    bsf eax, eax                ; Find the index of the most significant bit that is set.
    add rax, rsi                ; Add the two together to get the final length.
    ret