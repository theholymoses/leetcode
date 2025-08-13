global parseint

; -------------------------------------------------------------
section .rodata

; s - string
; l - length
; v - value

s00: db 'zero'
l00 equ $ - s00
v00 equ 0
s01: db 'one'
l01 equ $ - s01
v01 equ 1
s02: db 'two'
l02 equ $ - s02
v02 equ 2
s03: db 'three'
l03 equ $ - s03
v03 equ 3
s04: db 'four'
l04 equ $ - s04
v04 equ 4
s05: db 'five'
l05 equ $ - s05
v05 equ 5
s06: db 'six'
l06 equ $ - s06
v06 equ 6
s07: db 'seven'
l07 equ $ - s07
v07 equ 7
s08: db 'eight'
l08 equ $ - s08
v08 equ 8
s09: db 'nine'
l09 equ $ - s09
v09 equ 9
s10: db 'ten'
l10 equ $ - s10
v10 equ 10
s11: db 'eleven'
l11 equ $ - s11
v11 equ 11
s12: db 'twelve'
l12 equ $ - s12
v12 equ 12
s13: db 'thirteen'
l13 equ $ - s13
v13 equ 13
s14: db 'fourteen'
l14 equ $ - s14
v14 equ 14
s15: db 'fifteen'
l15 equ $ - s15
v15 equ 15
s16: db 'sixteen'
l16 equ $ - s16
v16 equ 16
s17: db 'seventeen'
l17 equ $ - s17
v17 equ 17
s18: db 'eighteen'
l18 equ $ - s18
v18 equ 18
s19: db 'nineteen'
l19 equ $ - s19
v19 equ 19
s20: db 'twenty'
l20 equ $ - s20
v20 equ 20
s30: db 'thirty'
l30 equ $ - s30
v30 equ 30
s40: db 'forty'
l40 equ $ - s40
v40 equ 40
s50: db 'fifty'
l50 equ $ - s50
v50 equ 50
s60: db 'sixty'
l60 equ $ - s60
v60 equ 60
s70: db 'seventy'
l70 equ $ - s70
v70 equ 70
s80: db 'eighty'
l80 equ $ - s80
v80 equ 80
s90: db 'ninety'
l90 equ $ - s90
v90 equ 90

sb: db 'billion'
lb equ $ - sb
vb equ 1000000000
sm: db 'million'
lm equ $ - sm
vm equ 1000000
st: db 'thousand'
lt equ $ - st
vt equ 1000
sh: db 'hundred'
lh equ $ - sh
vh equ 100

sand: db 'and'
land  equ $ - sand

%define NUMBER_RECORD_LEN 16
; 4 bytes - len
; 4 bytes - value
; 8 bytes - addr
NUMBERS:
dd l00, v00
dq s00

ONES:
dd l01, v01
dq s01
dd l02, v02
dq s02
dd l03, v03
dq s03
dd l04, v04
dq s04
dd l05, v05
dq s05
dd l06, v06
dq s06
dd l07, v07
dq s07
dd l08, v08
dq s08
dd l09, v09
dq s09

TENS:
dd l10, v10
dq s10
dd l11, v11
dq s11
dd l12, v12
dq s12
dd l13, v13
dq s13
dd l14, v14
dq s14
dd l15, v15
dq s15
dd l16, v16
dq s16
dd l17, v17
dq s17
dd l18, v18
dq s18
dd l19, v19
dq s19
dd l20, v20
dq s20
dd l30, v30
dq s30
dd l40, v40
dq s40
dd l50, v50
dq s50
dd l60, v60
dq s60
dd l70, v70
dq s70
dd l80, v80
dq s80
dd l90, v90
dq s90
NUMBERS_END:

%define MAGNITUDE_RECORD_LEN 16
; 4 bytes - len
; 4 bytes - value
; 8 bytes - addr
MAGNITUDE:
b: dd lb, vb
   dq sb
m: dd lm, vm
   dq sm
t: dd lt, vt
   dq st
h: dd lh, vh
   dq sh
MAGNITUDE_END:

; parsing stage
NUM_REQ equ 0
MAG_REQ equ 1
AND_OPT equ 2

; -------------------------------------------------------------
section .text

; Convert string to number:
;   one -> 1
;   one hundred and three -> 103
;
; rax - current number value
; rbx - string table start addr
; rcx - length of string for cmpsb
; rdi - input addr
; rsi - compared string addr
; rbp - parsing stage
; r8  - helper function status
; r9  - temp storage
; r11 - temp storage
parseint:
  push rbx
  push rbp

  mov rbp, NUM_REQ
  xor rax, rax

  push rax

next_word:
  cmp byte [rdi], ' '
  jne .check_end
  inc rdi

.check_end:
  cmp byte [rdi], 0
  je end
  mov rcx, rdi

.seek_word_end:
  cmp byte [rcx], 0
  je .word_len
  
  cmp byte [rcx], ' '
  je .word_len
  
  cmp byte [rcx], '-'
  je .word_len

  inc rcx
  jmp .seek_word_end

.word_len:
  sub rcx, rdi
  jz end

parse_word:
  cmp rbp, NUM_REQ
  je .number
  cmp rbp, MAG_REQ
  je .magnitude

.and:
  call parse_and
  mov rbp, NUM_REQ
  jmp next_word

.magnitude:
  call parse_magnitude
  cmp r8, 1
  je end

  mov rbp, AND_OPT
  jmp next_word

.number:
  call parse_number

  cmp byte [rdi], '-' ; if "-", then the next string is a number, set state accordingly
  je .another_number
 
  mov rbp, MAG_REQ
  jmp next_word

  .another_number:
    mov rbp, NUM_REQ
    inc rdi
    jmp next_word

next_state:
  cmp r8, 0
  jne .fail
.success:
  cmp rbp, AND_OPT
  je .reset
  inc rbp
  jmp next_word
.fail:
  cmp rbp, AND_OPT
  jne end
.reset:
  xor rbp, rbp
  jmp next_word
    
end:
  cmp rax, 0
  je .ret
  add qword [rsp], rax
.ret:
  pop rax
  pop rbp
  pop rbx
  ret

; -------------------------------------------------------------
; Tries to parse 'and' starting at rdi
; always returns 0
parse_and:
  xor r8, r8

  cmp rcx, land
  jne .end

  mov rsi, sand
  mov r9, rdi

  repe cmpsb
  jz .end

  mov rdi, r9

.end:
  ret

; -------------------------------------------------------------
; Searches magnitude string at rdi
; r8 = 0 if success, 1 if not found
parse_magnitude:
  xor r8, r8
  mov rbx, MAGNITUDE
.loop:
  cmp ecx, dword [rbx]
  je .cmp
.next:
  add rbx, MAGNITUDE_RECORD_LEN
  cmp rbx, MAGNITUDE_END
  jl .loop
  mov r8, 1
  ret

.cmp:
  mov rsi, qword [rbx+8]
  mov edx, ecx
  mov r9, rdi

  repe cmpsb
  jz .found

  mov ecx, edx
  mov rdi, r9
  jmp .next

.found:
  mov r9d, dword [rbx+4]
  xor rdx, rdx
  mul r9d

  cmp r9d, vh        ; if magnitude > 100: add value with stack value and nullify rax
  je .ret

  add qword [rsp+8], rax
  xor rax, rax
.ret:
  ret

; -------------------------------------------------------------
; Searches number string at rdi
; r8 = 0 if success, 1 if not found
parse_number:
  xor r8, r8
  mov rbx, NUMBERS
.loop:
  cmp ecx, dword [rbx]
  je .cmp
.next:
  add rbx, NUMBER_RECORD_LEN
  cmp rbx, NUMBERS_END
  jl .loop
  mov r8, 1
  ret

.cmp:
  mov rsi, qword [rbx+8]
  mov edx, ecx
  mov r9, rdi

  repe cmpsb
  jz .found

  mov rdi, r9
  mov ecx, edx
  jmp .next

.found:
  movsx rdx, dword [rbx+4]
  add rax, rdx
  ret

