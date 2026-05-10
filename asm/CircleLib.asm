
;---------------------------
; A Circle Formulae Library
;---------------------------

;----------------------------------------------
; Defines for use in programs using CircleLib:
;
; .equ circ_circum 0x9000
; .equ circ_area   0x9010
; .equ circ_radius 0x9020
;----------------------------------------------

.RAM

; Maths Library Define
.equ MATH_PI 3.141593

.equ F2 2.0

.code

;---------------------------
; Circle - Circumference
;
; Location: RAM addr 0x9000
;
; Inputs: R0 = r
; Output: R0 = 2 * pi * r
;---------------------------

.= 0x9000

circ_circum:
   push r1              ; Save used register

   ldi r1,MATH_PI       ; r1 = pi
   fmul r0,r1,r0        ; r0 = pi * r

   ldi r1,F2            ; r1 = 2.0
   fmul r0,r1,r0        ; r0 = 2 * pi * r

   pop r1               ; Retrieve register
   ret

;---------------------------
; Circle - Area
;
; Location: RAM addr 0x9010
;
; Inputs: R0 = r
; Output: R0 = pi * r^2
;---------------------------

.= 0x9010

circ_area:
   push r1              ; Save used register

   ldi r1,MATH_PI       ; r1 = pi
   fmul r0,r1,r1        ; r1 = pi * r
   fmul r0,r1,r0        ; r0 = pi * r^2

   pop r1               ; Retrieve register
   ret

;---------------------------
; Circle - Radius
;
; Location: RAM addr 0x9020
;
; Inputs: R0 = A
; Output: R0 = sqrt(A/pi)
;---------------------------

.= 0x9020

circ_radius:
   push r1              ; Save used register

   ldi r1,MATH_PI       ; r1 = pi
   fdiv r0,r1,r1        ; r1 = A/pi
   fsqrt r1,r0          ; r0 = sqrt(A/pi)

   pop r1               ; Retrieve register
   ret

