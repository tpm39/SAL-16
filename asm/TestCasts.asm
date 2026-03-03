
;------------------------
; Test the Casts Library
;------------------------

.RAM

; Casts Library Defines
.equ cast_int   0x5000
.equ cast_float 0x5200

; Maths Library Define
.equ MATH_INF_POS 0x7c00

.code

;------------
; Test Cases
;------------
main:
   jmp test_1

test_1:
   ; Float -> Int
   ldi r0,100.0
   call cast_int
   mov r0,r1         ; r1 -> 0x0064
   
   ; Int -> Float
   ldi r0,100
   call cast_float   ; r0 -> 0x5640
   end

test_2:
   ; Infinity -> Int
   ldi r0,MATH_INF_POS
   call cast_int     ; -> Error: 0x0120

