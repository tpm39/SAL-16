
;---------------------------------------------------------
; Implementation of the CORDIC algorithm to
; produce the Sin, Cos & Tan of an angle
;
; Input the angle via IN_1, the outputs are:
;   r0 = Sin(x)
;   r1 = Cos(x)
;   r2 = Tan(x)
;
; The numbers are in 16 bit floating point format
;
; See 'CORDIC_Trig.py' for the Python version of the code
;---------------------------------------------------------

.RAM

; BIOS defines
.equ os_get_in 0x1000

.equ IN_1 3

; Maths Library Define
.equ MATH_DEG_RAD 0.017453

.equ ITERS 12           ; 12 'CORDIC Iterations'

.equ K 0.607253         ; A 'CORDIC constant'

.code

;---------
; Program
;---------
main:
   ldi r0,IN_1          ; r0 (ang) = os_get_in(IN_1)
   call os_get_in

   ; ang < 5 degs ?
   ldi r1,5.0    
   cmp r1,r0
   jgt near_0

   ; ang > 85 degs ?
   ldi r1,85.0
   cmp r0,r1
   jgt near_90

   ; Perform the CORDIC Algorithm
   ldi r1,K             ; r1 (x) = K
   clr r2               ; r2 (y) = 0.0
   clr r3               ; r3 (z) = 0.0
   ldi r4,1.0           ; r4 (p) = 1.0
   clr idx              ; idx (i) = 0

next:
   ldi fp,ITERS         ; Completed the iterations ?
   cmp idx,fp
   jeq done

   mov r1,fp            ; fp = x(i)/p
   fdiv fp,r4,fp
   mov r2,lr            ; lr = y(i)/p
   fdiv lr,r4,lr

   cmp r3,r0            ; z(i) < ang ?
   jlt dplus1

   ; d = -1
   fadd r1,lr,r1        ; x(i+1) = x(i) + (y(i)/p)
   fsub r2,fp,r2        ; y(i+1) = y(i) - (x(i)/p)
   ldi fp,atans         ; z(i+1) = z(i) - atans[i]
   inc fp               ; Move past atans array header
   inc fp
   ldx lr,[fp,idx]
   fsub r3,lr,r3
   jmp updates

dplus1:
   ; d = +1
   fsub r1,lr,r1        ; x(i+1) = x(i) - (y(i)/p)
   fadd r2,fp,r2        ; y(i+1) = y(i) + (x(i)/p)
   ldi fp,atans         ; z(i+1) = z(i) + atans[i]
   inc fp               ; Move past atans array header
   inc fp
   ldx lr,[fp,idx]
   fadd r3,lr,r3

updates:
   fadd r4,r4,r4        ; p *= 2
   inc idx              ; i += 1
   jmp next

done:
   fdiv r2,r1,r3        ; Tan = Sin/Cos
   mov r2,r0            ; r0 = Sin(ang)
                        ; r1 = Cos(ang)
   mov r3,r2            ; r2 = Tan(ang)
   end

near_0:
   ldi r1,MATH_DEG_RAD  ; r0 = Sin(ang) ~ ang (rads)
   fmul r0,r1,r0     
   ldi r1,1.0           ; r1 = Cos(ang) ~ 1.0
   mov r0,r2            ; r2 = Tan(ang) ~ ang (ang)
   end

near_90:
   ldi r1,90.0          ; r1 = Cos(ang) ~ 90 - ang (rads)
   fsub r1,r0,r0
   ldi r1,MATH_DEG_RAD
   fmul r0,r1,r1     
   ldi r0,1.0           ; r0 = Sin(ang) ~ 1.0
   fdiv r0,r1,r2        ; r2 = Tan(ang) = Sin/Cos
   end

;------
; Data
;------
.data

; The CORDIC arctans
atans: array [45.0, 26.565051, 14.036243, 7.125016, 3.576334, 1.789911, 0.895174, 0.447614, 0.223811, 0.111906, 0.055953, 0.027976]

