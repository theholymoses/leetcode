global decode_morse

; -------------------------------------------------------------
section .rodata

A:          db ".-",        0,  'A',    0
B:          db "-...",      0,  'B',    0
C:          db "-.-.",      0,  'C',    0
D:          db "-..",       0,  'D',    0
E:          db ".",         0,  'E',    0
F:          db "..-.",      0,  'F',    0
G:          db "--.",       0,  'G',    0
H:          db "....",      0,  'H',    0
I:          db "..",        0,  'I',    0
J:          db ".---",      0,  'J',    0
K:          db "-.-",       0,  'K',    0
L:          db ".-..",      0,  'L',    0
M:          db "--",        0,  'M',    0
N:          db "-.",        0,  'N',    0
O:          db "---",       0,  'O',    0
P:          db ".--.",      0,  'P',    0
Q:          db "--.-",      0,  'Q',    0
R:          db ".-.",       0,  'R',    0
S:          db "...",       0,  'S',    0
T:          db "-",         0,  'T',    0
U:          db "..-",       0,  'U',    0
V:          db "...-",      0,  'V',    0
W:          db ".--",       0,  'W',    0
X:          db "-..-",      0,  'X',    0
Y:          db "-.--",      0,  'Y',    0
Z:          db "--..",      0,  'Z',    0
D0:         db "-----",     0,  '0',    0
D1:         db ".----",     0,  '1',    0
D2:         db "..---",     0,  '2',    0
D3:         db "...--",     0,  '3',    0
D4:         db "....-",     0,  '4',    0
D5:         db ".....",     0,  '5',    0
D6:         db "-....",     0,  '6',    0
D7:         db "--...",     0,  '7',    0
D8:         db "---..",     0,  '8',    0
D9:         db "----.",     0,  '9',    0
DOT:        db ".-.-.-",    0,  '.',    0
COMMA:      db "--..--",    0,  ',',    0
QUEMARK:    db "..--..",    0,  '?',    0
APOSTROPHE: db ".----.",    0,  "'",    0
EXCLMARK:   db "-.-.--",    0,  '!',    0
SLASH:      db "-..-.",     0,  '/',    0
LPARENTH:   db "-.--.",     0,  '(',    0
RPARENTH:   db "-.--.-",    0,  ')',    0
AMPERSAND:  db ".-...",     0,  '&',    0
COLON:      db "---...",    0,  ':',    0
SEMICOLON:  db "-.-.-.",    0,  ';',    0
EQUAL:      db "-...-",     0,  '=',    0
PLUS:       db ".-.-.",     0,  '+',    0
MINUS:      db "-....-",    0,  '-',    0
UNDERSCORE: db "..--.-",    0,  '_',    0
QUOTES:     db ".-..-.",    0,  '"',    0
DOLLARSIGN: db "...-..-",   0,  '$',    0
ATSIGN:     db ".--.-.",    0,  '@',    0
SOS:        db "...---...", 0,  'SOS',  0
NULL:       db 0          , 0,          0

code:
dq  A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z

dq  D0, D1, D2, D3, D4, D5, D6, D7, D8, D9
      
dq  DOT,        COMMA,  QUEMARK,   APOSTROPHE, EXCLMARK,  SLASH, LPARENTH,   RPARENTH
dq  AMPERSAND,  COLON,  SEMICOLON, EQUAL,      PLUS,      MINUS, UNDERSCORE, QUOTES
dq  DOLLARSIGN, ATSIGN, SOS
dq  NULL

; -------------------------------------------------------------
section .text

; Decode morse-code string
; Used registers:
; rax, rcx, rdx, rsi, rdi, r8, r9
; arg:
; rdi - morse code
; rsi - preallocated output buffer
decode_morse:
  mov r8, rsi         ; rsi will be used for comparison of morse-codes
  mov r9, 0           ; signifies that there were no chars decoded yet


; iterate over spaces prefixing next morse-code
.prefix:
  mov rdx, rdi

.prefix_loop:
  mov al, byte [rdx]

  cmp al, 0
  je .end

  cmp al, ' '
  jne .act_on_prefix

  inc rdx
  jmp .prefix_loop


; count prefixing spaces and decide what to do with them
.act_on_prefix:
  mov rcx, rdx                ; count encountered spaces
  sub rcx, rdi
  jz .frame_code_loop         ; 0 spaced encountered

  mov rdi, rdx                ; shift input pointer from prefix

  cmp r9, 0
  je .frame_code_loop         ; no chars were parsed yet, skip spaces

  cmp rcx, 3
  jl .frame_code_loop         ; chars were parsed, but there are not enough spaces to make it a word border
 
  mov byte [r8], ' '          ; word border encountered
  inc r8


; iterate over morse-code chars
.frame_code_loop:
  cmp al, '.'
  je .frame_code_next
  cmp al, '-'
  jne .decode

.frame_code_next:
  inc rdx
  mov al, byte [rdx]
  jmp .frame_code_loop


; count morse-code chars encountered and try to decode them
.decode:
  sub rdx, rdi      ; lenght of a code
  jz .end           ; length is 0

  mov rcx, 0        ; index to morse-code array

.decode_loop:
  mov rsi, [code + rcx * 8]
  cmp byte [rsi], 0
  je .end

  ; rdi - ptr
  ; rsi - compared string
  ; rdx - len of rdi
  call morsecodecmpn
  cmp rax, 0
  je .write_decoded

.decode_next:
  inc rcx
  jmp .decode_loop


; write appropriate character sequence to output buffer in r8
.write_decoded:
  add rdi, rdx      ; shift base pointer rdi to the current position after decoded morse-code
  mov r9, 1         ; make it known for prefix parser that next 3 spaces might be a word border

  add rsi, rdx      ; shift code-pointer so that it points at 0, after which decoded string is located

.write_decoded_loop:
  inc rsi

  mov al, byte [rsi]
  cmp al, 0
  je .prefix

  mov byte [r8], al
  inc r8
  jmp .write_decoded_loop


; morse-code string is parsed
.end:
  mov byte [r8], 0
  ret

; -------------------------------------------------------------
; Check if morse codes are equal
; All arg-registers are restored to their initial state on return
; arg:
; rdi - s1
; rsi - s2
; rdx - len of s1
; ret:
; rax = 0 if equal
morsecodecmpn:
  mov rax, 0

  push rdi
  push rsi
  push rdx

.loop:
  mov al, byte [rdi]
  sub al, byte [rsi]
  jnz .end

  inc rdi
  inc rsi
  dec rdx
  jnz .loop

  cmp byte [rsi], 0
  je .end

  mov rax, 1    ; Codes are equal at first rdx characters, but rsi is longer, so they are not the same

.end:
  pop rdx
  pop rsi
  pop rdi
  ret

