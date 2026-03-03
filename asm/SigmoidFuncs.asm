
;-------------------------------
; A couple of Sigmod Functions:
;
;   sigmoid(x)
;   d/dx sigmoid(x)
;
; For use with Neural Networks
;-------------------------------

;---------------------------------------------------
; Defines for use in programs using the 'Sigmoids':
;
; .equ sigmoid            0xa000
; .equ sigmoid_derivative 0xa050
;---------------------------------------------------

.RAM

; Maths Library Define
.equ fmath_exp 0x2dd0

.code

;----------------------------------
; Sigmoid
;
; Location: ROM addr 0xa000
;
; Inputs: R0 = x
; Output: R0 = sigmoid(x)
;
; To account for errors in exp(x):
;    if x > 6.25 return 1.0
;    if x < -2.0 return 0.0
;----------------------------------

.= 0xa000

sigmoid:
   push lr
   push r1
   push r2
   
   ldi r1,6.25       ; x > 6.25 ?
   fcmp r0,r1
   jle sig_x_pos

   ldi r0,1.0        ; x > 6.25 - return 1.0
   jmp sig_done

sig_x_pos:
   clr r1            ; x >= 0.0 ?
   fcmp r0,r1
   jge sig_x_ok

   ldi r1,-6.0       ; x > -6.0 ?
   fcmp r0,r1
   jgt sig_x_neg1

   clr r0            ; x <= -6.0 - return 0.0
   jmp sig_done

sig_x_neg1:
   ldi r1,-3.0       ; x > -3.0 ?
   fcmp r0,r1
   jgt sig_x_neg2

   ; x <= -3.0 - return: 0.011667 * x + 0.070002
   ldi r1,0.011667
   fmul r0,r1,r0
   ldi r1,0.070002
   fadd r0,r1,r0
   jmp sig_done

sig_x_neg2:
   ldi r1,-1.5       ; x > -1.5 ?
   fcmp r0,r1
   jgt sig_x_ok

   ; x <= -1.5 - return: 0.098284 * x + 0.329852
   ldi r1,0.098284
   fmul r0,r1,r0
   ldi r1,0.329852
   fadd r0,r1,r0
   jmp sig_done

sig_x_ok:
   call fmath_exp    ; r0 = exp(x)
   ldi r1,1.0        ; r1 = 1.0 + exp(x)
   fadd r1,r0,r1
   fdiv r0,r1,r0     ; r0 = exp(x) / (1.0 + exp(x))

sig_done:
   pop r2
   pop r1
   pop lr
   ret

;------------------------------
; Sigmoid Derivative
;
; Location: ROM addr 0xa050
;
; Inputs: R0 = x
; Output: R0 = d/dx sigmoid(x)
;
; To account for errors in exp(x):
;    if x > 6.25 return 0.0
;    if x < -2.0 return 0.0
;----------------------------------

.= 0xa050

sigmoid_derivative:
   push lr
   push r1
   push r2

   clr r1            ; x >= 0.0 ?
   fcmp r0,r1
   jge sigd_x_ok

   ldi r1,-6.25      ; x > -6.25 ?
   fcmp r0,r1
   jgt sigd_x_neg1

   clr r0            ; x <= -6.25 - return 0.0
   jmp sigd_done

sigd_x_neg1:
   ldi r1,-3.25      ; x > -3.25 ?
   fcmp r0,r1
   jgt sigd_x_neg2

   ; x <= -3.25 - return: 0.009 * x + 0.05625
   ldi r1,0.009
   fmul r0,r1,r0
   ldi r1,0.05625
   fadd r0,r1,r0
   jmp sigd_done

sigd_x_neg2:
   ldi r1,-1.5       ; x > -1.5 ?
   fcmp r0,r1
   jgt sigd_x_ok

   ; x <= -1.5 - return: 0.069798 * x + 0.253843
   ldi r1,0.069798
   fmul r0,r1,r0
   ldi r1,0.253843
   fadd r0,r1,r0
   jmp sig_done

sigd_x_ok:
   call fmath_exp    ; r0 = exp(x)
   ldi r1,1.0        ; r0 = exp(-x)
   fdiv r1,r0,r0
   fadd r1,r0,r1     ; r1 = 1.0 + exp(-x)
   fmul r1,r1,r1     ; r1 = (1.0 + exp(-x))^2
   fdiv r0,r1,r0     ; r0 = exp(-x) / ((1.0 + exp(-x))^2)

sigd_done:
   pop r2
   pop r1
   pop lr
   ret

