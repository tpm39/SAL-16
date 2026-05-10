
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

.equ divisor 0x9040     ; 'divisor()' is in LinkDiv3.asm

.equ x 0x8010           ; x is in LinkDiv1.asm

.code

.= 0x9000

; Program
dividend:
   push lr              ; save ret addr

   ldi r4,num           ; r0 = num
   ld r0,[r4]

   ldi r4,x             ; x = num
   st r0,[r4]

   call divisor         ; get divisor

   pop lr               ; save ret addr
   ret

; Data
.data

.= 0x9020

num: word 56

