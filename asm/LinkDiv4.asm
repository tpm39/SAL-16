
;---------------------------------------------------------------------------------------------------------------
; Test the Linker
;
; A long winded divider !!
;
; LinkDiv1.asm calls code in LinkDiv2.asm, then
; LinkDiv2.asm calls code in LinkDiv3.asm, then
; LinkDiv3.asm calls code in LinkDiv4.asm.
;
; Their machine code files are are linked together to form LinkDiv.mc:
;
; python3 ./Tools/Linker.py ./mc/LinkDiv.mc ./mc/LinkDiv1.mc ./mc/LinkDiv2.mc ./mc/LinkDiv3.mc ./mc/LinkDiv4.mc
;
; When run: 0x8010 = 56 (0x38) - x
;           0x8011 = 10 (0x0a) - y
;           0x8012 =  5 (0x05) - x / y
;           0x8013 =  6 (0x06) - x % y
;---------------------------------------------------------------------------------------------------------------

.RAM

; Maths Library Define
.equ math_mod 0x2030

.equ quot 0x8012        ; quot is in LinkDiv1.asm
.equ rem  0x8013        ; rem  is in LinkDiv1.asm

.code

.= 0x9080

; Program
division:
   push lr              ; save ret addr

   sdiv r0,r1,r2        ; get & store quot
   ldi r4,quot
   st r2,[r4]

   call math_mod        ; get & store rem
   ldi r4,rem
   st r0,[r4]

   pop lr               ; get ret addr
   ret

