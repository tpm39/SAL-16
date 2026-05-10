
;---------------------------------------
; A library with some random stuff:
;
;  misc_end : Display a parting message
;---------------------------------------

;--------------------------------------------
; Defines for use in programs using MiscLib:
;
; .equ misc_end 0xa000
;--------------------------------------------

.RAM

.code

;-------------------------------------------------------
; Misc - Parting Message
;
; Location: RAM addr 0xa000
;
; Display "Baseball Cool" on the User Panel & then stop
;-------------------------------------------------------

.= 0xa000

misc_end:
   ldi r0,0xba5e
   ldi r1,0xba11
   ldi r2,0xc001
   clr r3
   clr r4
   end

