
;--------------------------------------------
; A Wee Hardware/Software Sanity Check !! :)
;--------------------------------------------

.RAM

.code

main:
   ldi r0,0x7fff
   ldi r1,0b01

   add r0,r1,r2         ; r2 = 0x8000 - Flags set: A,N & V

   jv ovrfl             ; Check for overflow (there is)

   ldi r4,0x1111        ; Ignored
   end

ovrfl:
   ldi r4,65535         ; r4 = 65,535 = 0xffff (we get here)
   end

