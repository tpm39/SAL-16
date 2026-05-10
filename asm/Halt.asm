
;-------------------------------
; Test the 'Halt' functionality
;-------------------------------

.RAM

.code

main:
   ldi r0,0b0111
   halt

   ldi r1,0b1110
   halt

   and r0,r1,r2

   end

