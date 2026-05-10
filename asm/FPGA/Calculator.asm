
;----------------------------
; A Calculator
;
; Operation:
;    Enter x via IN
;    Enter op via IN
;    Enter y via IN
;
; OUT displays: x op y
;
; 'op' settings:
;    0x8000 - Addition
;    0x4000 - Subtraction
;    0x2000 - Multiplication
;    0x1000 - Division
;    0x0800 - Modulus
;----------------------------

.RAM

; BIOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

; Error Codes
.equ DIV_BY_0 0x0002
.equ INV_DATA 0x0006

; Maths define
.equ math_mod 0x0ca0

; op define
.equ OP_MASK 0xf800

.code

main:
   ; Get x
   call os_get_in
   mov r0,r2            ; r2 = x

   ; Get op
   call os_get_in
   ldi r3,OP_MASK
   and r0,r3,r3         ; r3 = op

   ; Get y
   call os_get_in
   mov r0,r1            ; r1 = y

   ldi idx,0x8000       ; idx = 0x8000
   cmp r3,idx           ; Addition ?
   jne try_sub

   add r2,r1,r0         ; Do addition
   jmp done

try_sub:
   mov r2,r0            ; r0 = x

   ldi fp,1             ; fp = idx shift amount (1)
   lsr idx,fp,idx       ; idx = 0x4000
   cmp r3,idx           ; Subtraction ?
   jne try_mul

   sub r0,r1,r0         ; Do subtraction
   jmp done

try_mul:
   lsr idx,fp,idx       ; idx = 0x2000
   cmp r3,idx           ; Multiplication ?
   jne try_div

   mul r0,r1,r0         ; Do multiplication
   jmp done

try_div:
   lsr idx,fp,idx       ; idx = 0x1000
   cmp r3,idx           ; Division ?
   jne try_mod

   clr r4               ; Test for division by 0
   cmp r1,r4
   jne div_ok

   jmp DIV_BY_0         ; Division by 0 - Display error code

div_ok:
   sdiv r0,r1,r0        ; Do signed division
   jmp done

try_mod:
   lsr idx,fp,idx       ; idx = 0x0800
   cmp r3,idx           ; Modulus ?
   jne invalid

   call math_mod        ; Do modulus
   jmp done

invalid:
   jmp INV_DATA         ; Invalid op - Display error code

done:
   call os_disp_out     ; Display the result
   end

