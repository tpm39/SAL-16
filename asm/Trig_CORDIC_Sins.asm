
;---------------------------------------------------------
; Implementation of the CORDIC algorithm to
; produce the Sin of angles in the range 0 <= x <= 90
;
; The resulting Sin's are in memory from addr 0xc000
;
; The numbers are in 16 bit floating point format
;
; See 'CORDIC_Trig.py' for the Python version of the code
;---------------------------------------------------------

.RAM

; Maths Library Define
.equ MATH_DEG_RAD 0.017453

.equ NUM_ANGS 19        ; To compute 19 angles
.equ ITERS 12           ; 12 'CORDIC Iterations'

.equ K 0.607253         ; A 'CORDIC constant'

.code

;---------
; Program
;---------
main:
   clr r1               ; r1 = Current angle
   ldi r2,5.0           ; r2 = Angle increment (5.0 degs)
   ldi r3,NUM_ANGS      ; r3 = Number of angles to be calculated
   clr idx              ; idx = Loop count

next_angle:
   cmp idx,r3           ; Calculated all angles ?
   jeq all_done

   mov r1,r0            ; Calculate & store sin(current angle)
   call sin
   ldi r4,sins
   stx r0,[r4,idx]

   fadd r1,r2,r1        ; Get the next angle
   inc idx

   jmp next_angle

all_done:
   end

;---------------------------------------------
; Calculate Sin(x) using the CORDIC algorithm
; 
; Input:  r0 - x
; Output: r0 - sin(x)
;---------------------------------------------
sin:
   push lr              ; Save the used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1

   ; Angle < 5 degs ?
   ldi r1,5.0      
   cmp r1,r0
   jgt near_0

   ; Angle > 85 degs ?
   ldi r1,85.0
   cmp r0,r1
   jgt near_90

   ; Perform the CORDIC Algorithm
   ldi r1,K             ; r1 (x) = K
   clr r2               ; r2 (y) = 0.0
   clr r3               ; r3 (z) = 0.0
   ldi r4,1.0           ; r4 (p) = 1.0
   clr idx              ; idx (i) = 0

next_iter:
   ldi fp,ITERS         ; Completed the iterations ?
   cmp idx,fp
   jeq set_sin

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
   jmp next_iter

set_sin:
   mov r2,r0            ; Sin = y(i)
   jmp done

near_0:
   ldi r1,MATH_DEG_RAD  ; r0 = Sin(ang) ~ ang (rads)
   fmul r0,r1,r0     
   jmp done

near_90:
   ldi r0,1.0           ; r0 = Sin(ang) ~ 1.0

done:
   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

;------
; Data
;------
.data

; The CORDIC arctans
atans: array [45.0, 26.565051, 14.036243, 7.125016, 3.576334, 1.789911, 0.895174, 0.447614, 0.223811, 0.111906, 0.055953, 0.027976]

.= 0xc000

sins: array 19

