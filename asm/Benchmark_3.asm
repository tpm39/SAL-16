
;------------------------------------------------
; Graphics Benchmark - Draw a circle in a square
;------------------------------------------------

.RAM

; Graphics Library Defines:
.equ gr_rect   0x33f0
.equ gr_circle 0x34c0

.equ GR_RED  0xf800
.equ GR_BLUE 0x001f

.code

; Program
main:
   ldi r0,118
   ldi r1,118
   ldi r2,138
   ldi r3,138
   ldi r4,GR_RED
   call gr_rect

   ldi r0,128
   ldi r1,128
   ldi r2,7
   ldi r3,GR_BLUE
   call gr_circle

   end

