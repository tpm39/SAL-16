
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

.equ dividend 0x9000    ; 'dividend()' is in LinkDiv2.asm

.code

; RAM Entry
entry:
   jmp main

; Data
.data

.= 0x8010

x:    word 0
y:    word 0
quot: word 0
rem:  word 0

; Program
.code

.= 0x8100

main:
   call dividend        ; get dividend
   end

