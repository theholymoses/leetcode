global snail
extern calloc

; -------------------------------------------------------------
section .text

; Convert matrix to array, moving through matrix in a "snail fashion"
; arg:
;   rdi - resulting size
;   rsi - matrix
;   rdx - row n
;   rcx - col n
; ret:
;   rax - heap allocated int array
;   rdi - addr to size of heap allocated array
snail:
    cmp rdi, 0
    je err
    cmp rsi, 0
    je err
    cmp rdx, 0
    je err
    cmp rcx, 0
    je err

    push rdi
    push rsi
    push rdx
    push rcx

    mov rax, rcx
    mul rdx
    mov qword [rdi], rax

    mov rdi, rax
    mov rsi, 4
    call calloc

    pop rcx
    pop rdx
    pop rsi
    pop rdi

    cmp rax, 0
    je err

    push rax
    push rbx
    push rbp
    push r12
    push r13

    xor r13, r13
    xor r10, r10
    xor r11, r11
    dec rdx
    dec rcx

    test rdx, 1
    setz r12b

    ; r10 - rdx (row idx range)
    ; r11 - rcx (col idx range)
    snail_loop:
        mov r8, r10
        mov r9, r11
        mov rbx, [rsi + r8 * 8]

        align 16
        uppermost_row:
            cmp r9, rcx
            jg .end
            mov ebp, [rbx + r9 * 4]
            mov dword [rax], ebp
            add rax, 4
            inc r13
            cmp r13, qword [rdi]
            je end
            inc r9
            jmp uppermost_row
    .end:
        inc r10                 ; forget uppermost row

        mov r8, r10
        mov r9, rcx

        align 16
        rightmost_col:
            cmp r8, rdx
            jg .end
            mov rbx, [rsi + r8 * 8]
            mov ebp, [rbx + r9 * 4]
            mov dword [rax], ebp
            add rax, 4
            inc r8
            jmp rightmost_col
    .end:
        dec rcx                ; forget rightmost col

        mov r8, rdx
        mov r9, rcx
        mov rbx, [rsi + r8 * 8]

        align 16
        downmost_row:
            cmp r9, r11
            jl .end
            mov ebp, [rbx + r9 * 4]
            mov dword [rax], ebp
            add rax, 4
            inc r13
            cmp r13, qword [rdi]
            je end
            dec r9
            jmp downmost_row
    .end:
        dec rdx               ; forget downmost row

        mov r8, rdx
        mov r9, r11

        align 16
        leftmost_col:
            cmp r8, r10
            jl .end
            mov rbx, [rsi + r8 * 8]
            mov ebp, [rbx + r9 * 4]
            mov dword [rax], ebp
            add rax, 4
            inc r13
            cmp r13, qword [rdi]
            je end
            dec r8
            jmp leftmost_col
    .end:
        inc r11               ; forget leftmost col

        mov r8, rdx
        sub r8, r10
        mov r9, rcx
        sub r9, r11
        add r8, r9
        cmp r8, 0
        jle end
        jmp snail_loop

end:
    cmp r12b, 0
    je .ret
    mov rbx, [rsi + rdx * 8]
    mov ebp, dword [rbx + rcx * 4]
    mov dword [rax], ebp

.ret:
    pop r13
    pop r12
    pop rbp
    pop rbx
    pop rax
    ret
err:
    mov qword [rdi], 0
    ret

