
;----------------------------------------------------------
; Implementation of the Taylor Series algorithm to produce
; the Sin, Cos & Tan of angles in the range 0 <= x <= 90
;
; The results are in memory:
;   Sin's from addr 0x9000
;   Cos's from addr 0x9100
;   Tan's from addr 0x9200
;
; The numbers are in 16 bit floating point format
;----------------------------------------------------------

.RAM

; Maths Library Define
.equ MATH_DEG_RAD 0.017453

.equ NUM_ANGS 19        ; To compute 19 angles

.equ F1     1.0
.equ F2     2.0
.equ F3     3.0
.equ F5     5.0
.equ F15   15.0
.equ F17   17.0
.equ F315 315.0

.equ FACT_2    2.0
.equ FACT_3    6.0
.equ FACT_4   24.0
.equ FACT_5  120.0
.equ FACT_6  720.0
.equ FACT_7 5040.0

.code

;---------
; Program
;---------
main:
   clr r1               ; r1 = Current angle
   ldi r2,F5            ; r2 = Angle increment (5 degs)
   ldi r3,NUM_ANGS      ; r3 = Number of angles to be calculated
   clr idx              ; idx = Loop count

next:
   cmp idx,r3           ; Calculated all angles ?
   jeq done

   mov r1,r0            ; Calculate & store sin(current angle)
   call math_sin
   ldi r4,sins
   stx r0,[r4,idx]

   mov r1,r0            ; Calculate & store cos(current angle)
   call math_cos
   ldi r4,coses
   stx r0,[r4,idx]

   mov r1,r0            ; Calculate & store tan(current angle)
   call math_tan
   ldi r4,tans
   stx r0,[r4,idx]

   fadd r1,r2,r1        ; Get the next angle
   inc idx

   jmp next

done:
   end

;------------------------------------------
; Calculate Sin(x) using the Taylor Series
;
; Input:  r0 = x (degs)
; Output: r0 = sin(x)
;------------------------------------------
math_sin:
	push r4			      ; Store used registers
   push r3			
   push r2			
   push r1			

   ldi r1,MATH_DEG_RAD
   fmul r0,r1,r0 	      ; x in rads

   mov r0,r1  		      ; r1 = res = x
   mov r0,r2
   fmul r0,r2,r2
   fmul r0,r2,r2 	      ; r2 = x^3
   mov r2,r3
   ldi r4,FACT_3        ; r4 = factorial(3)
   fdiv r3,r4,r3
   fsub r1,r3,r1        ; res -= (x^3 / factorial(3))

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^5
   mov r2,r3
   ldi r4,FACT_5        ; r4 = factorial(5)
   fdiv r3,r4,r3
   fadd r1,r3,r1        ; res += (x^5 / factorial(5))

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^7
   mov r2,r3
   ldi r4,FACT_7        ; r4 = factorial(7)
   fdiv r3,r4,r3
   fsub r1,r3,r0        ; res -= (x^7 / factorial(7))

   pop r1			      ; Retrieve registers
	pop r2
	pop r3
	pop r4
   ret

;------------------------------------------
; Calculate Cos(x) using the Taylor Series
;
; Input:  r0 = x (degs)
; Output: r0 = cos(x)
;------------------------------------------
math_cos:
	push r4			      ; Store used registers
   push r3			
   push r2			
   push r1			

   ldi r1,MATH_DEG_RAD
   fmul r0,r1,r0 	      ; r0 = x in rads

   ldi r1,F1            ; r1 = res = 1.0
   mov r0,r2
   fmul r0,r2,r2 	      ; r2 = x^2
   mov r2,r3
   ldi r4,FACT_2        ; r4 = factorial(2)
   fdiv r3,r4,r3
   fsub r1,r3,r1        ; res -= (x^2 / factorial(2))

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^4
   mov r2,r3
   ldi r4,FACT_4        ; r4 = factorial(4)
   fdiv r3,r4,r3
   fadd r1,r3,r1        ; res+-= (x^4 / factorial(4))

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^6
   mov r2,r3
   ldi r4,FACT_6        ; r4 = factorial(6)
   fdiv r3,r4,r3
   fsub r1,r3,r0        ; res -= (x^6 / factorial(6))

   pop r1			      ; Retrieve used registers
	pop r2
	pop r3
	pop r4
   ret

;------------------------------------------
; Calculate Tan(x) using the Taylor Series
;
; Input:  r0 = x (degs)
; Output: r0 = cos(x)
;------------------------------------------
math_tan:
	push r4			      ; Store used registers
   push r3			
   push r2			
   push r1			

   ldi r1,MATH_DEG_RAD
   fmul r0,r1,r0 	      ; x in rads

   mov r0,r1  		      ; r1 = res = x
   mov r0,r2
   fmul r0,r2,r2
   fmul r0,r2,r2 	      ; r2 = x^3
   mov r2,r3
   ldi r4,F3            ; r4 = 3.0
   fdiv r3,r4,r3
   fadd r1,r3,r1        ; res += (x^3 / 3)

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^5
   mov r2,r3
   ldi r4,F2            ; r4 = 2
   fmul r3,r4,r3        ; r3 = 2 * x^5
   ldi r4,F15           ; r4 = 15
   fdiv r3,r4,r3
   fadd r1,r3,r1        ; res += (2 * x^5 / 15)

   fmul r0,r2,r2
   fmul r0,r2,r2        ; r2 = x^7
   mov r2,r3
   ldi r4,F17           ; r4 = 17
   fmul r3,r4,r3        ; r3 = 17 * x^7
   ldi r4,F315          ; r4 = 315
   fdiv r3,r4,r3
   fadd r1,r3,r0        ; res += (17 * x^7 / 315)

   pop r1			      ; Retrieve registers
	pop r2
	pop r3
	pop r4
   ret

;------
; Data
;------
.data

.= 0x9000

sins: array 19

.= 0x9100

coses: array 19

.= 0x9200

tans: array 19

