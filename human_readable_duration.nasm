%ifndef FMTDURATION_ASM
%define FMTDURATION_ASM

global fmtduration
extern malloc

; -------------------------------------------------------------
section .text

; Takes nonnegative integer and converts it to human-readable format:
;   rdi = 62 -> "1 minute and 2 seconds"
; variables:
; rax - remaining seconds
; rbx - table addr
; rcx - index to buffer
; rdx - remainder
; rsi - min value of (secs, mins etc) 
; rdi - temp index to buffer
; rbp - itoa divisor
; r8  - temp storage
; r9  - temp storage
; r10 - temp storage
fmtduration:
  push rbx
  push rbp
 
  mov rax, rdi
  mov rbx, date_table
  xor rcx, rcx
  mov rbp, 10

.measure_get:
  mov rsi, qword [rbx]

  cmp rax, rsi              ; not enough secs for current date measure
  jl .measure_next

  cmp rsi, 0                ; 'now' measure does not require divide, union and itoa, just write it
  je .measurestr_get

.measure_divide:
  xor rdx, rdx
  idiv rsi

  cmp rcx, 0                ; no need for comma or 'and' if nothing was written yet
  je .pre_itoa

.conjunction_get:                 
  cmp rdx, 0                
  jg .conjunction_comma

  mov r8, andstr            ; last member - use ' and '
  mov r9, qword [andstrl]
  jmp .conjunction_write

.conjunction_comma:
  mov r8, commastr          ; some secs left - use ', '
  mov r9, qword [commastrl]

.conjunction_write:
  mov r10b, byte [r8]
  mov byte [buf + rcx], r10b

  inc rcx
  inc r8
  dec r9b
  jnz .conjunction_write

.pre_itoa:
  mov r8, rax               ; store number
  mov r9, rdx               ; store remainder
  mov rdi, rcx              ; store old index (will be used for reversing)

.itoa:
  xor rdx, rdx
  idiv rbp

  add dl, '0'
  mov byte [buf + rcx], dl
  inc rcx

  cmp rax, 0
  jnz .itoa

  push rcx                  ; remember old index
.itoa_reverse:
  dec rcx
  cmp rcx, rdi
  jle .post_reverse

  mov  r10b, byte [buf + rcx]
  xchg r10b, byte [buf + rdi]
  mov  byte [buf + rcx], r10b

  inc rdi
  jmp .itoa_reverse

.post_reverse:
  pop rcx                   ; recall old index
  mov rax, r8               ; restore number
  mov rdx, r9               ; restore remainder

  mov byte [buf + rcx], ' '
  inc rcx

.measurestr_get:
  mov r8, qword [rbx + 8]   ; get string representing value
  mov r9, qword [rbx + 16]  ; get length of said string
  mov r9b, byte [r9]
  dec r9b

  cmp rsi, 0                ; 'now' check
  je .measurestr_write

  cmp rax, 1                ; singular check
  je .measurestr_next

.measurestr_write:
  mov r10b, byte [r8]
  mov byte [buf + rcx], r10b

  inc rcx
  inc r8
.measurestr_next:
  dec r9b
  jns .measurestr_write

  mov rax, rdx              ; use remainder as next term
  cmp rax, 0
  je .allocate

.measure_next:
  add rbx, 24
  cmp rbx, date_table_end
  jl .measure_get

.allocate:
  push rcx                  ; remember last index

  inc rcx
  mov rdi, rcx
  call malloc

  pop rcx                   ; recall index

  cmp rax, 0
  je .end

  xor rdi, rdi
.strcpy:
  dec rcx
  js .put_null

  mov r10b, byte [buf + rdi]
  mov byte [rax + rdi], r10b

  inc rdi
  jmp .strcpy

.put_null:
  mov byte [rax + rdi], 0

.end:
  pop rbp
  pop rbx
  ret

; -------------------------------------------------------------
section .rodata

ystr:       db 'years'
ystrl:      db $ - ystr
dstr:       db 'days'
dstrl:      db $ - dstr
hstr:       db 'hours'
hstrl:      db $ - hstr
mstr:       db 'minutes'
mstrl:      db $ - mstr
sstr:       db 'seconds'
sstrl:      db $ - sstr
nstr:       db 'now'
nstrl:      db $ - nstr

commastr:   db ', '
commastrl:  db $ - commastr
andstr:     db ' and '
andstrl:    db $ - andstr

date_table:
dq  60 * 60 * 24 * 365
dq  ystr
dq  ystrl

dq  60 * 60 * 24
dq  dstr
dq  dstrl

dq  60 * 60
dq  hstr
dq  hstrl

dq  60
dq  mstr
dq  mstrl

dq  1
dq  sstr
dq  sstrl

dq  0
dq  nstr
dq  nstrl
date_table_end:

; -------------------------------------------------------------
section .bss
buf:    resb 1024

%endif
