
;----------------------------------------------------------------------------
; Division & 'Square Rooting' using the 'Fast Inverse Square Root' algorithm
;
; See: https://en.m.wikipedia.org/wiki/Fast_inverse_square_root
;----------------------------------------------------------------------------

.RAM

; BIOS Defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

; Algorithm Constant
.equ MAGIC_NUM 0x59e0

.code

main:
   ldi r0,IN_1 			; Get x
   call os_get_in
   mov r0,r2				; r2 = x

   ldi r0,IN_2 			; Get y
   call os_get_in
   mov r0,r1				; r1 = y

	mov r2,r0				; r0 = x
	call fisr_div			; r0 = x/y

   mov r0,r1				; Display x/y
   ldi r0,OUT_1
   call os_disp_out

	mov r2,r0				; r0 = x
	call fisr_sqrt			; r0 = sqrt(x)

   mov r0,r1				; Display sqrt(x)
   ldi r0,OUT_2
   call os_disp_out

	end

;------------------
; Division
;
; Inputs: R0 = x
;         R1 = y
; Output: R0 = x/y
;------------------
fisr_div:
	push lr					; Save used registers
	push r1
	push r2

	mov r0,r2				; r2 = x

	mov r1,r0				; r0 = 1/sqrt(y)
	call fisqrt

	fmul r2,r0,r1 			; r1 = x/sqrt(y)
	fmul r1,r0,r0  		; r0 = x/y

	pop r2					; Restore registers & return
	pop r1
	pop lr
	ret

;----------------------
; Square Root
;
; Input:  R0 = x
; Output: R0 = sqrt(x)
;----------------------
fisr_sqrt:
	push lr					; Save used registers
	push r1

	mov r0,r1				; r1 = x

	call fisqrt				; r0 = 1/sqrt(x)

	fmul r0,r1,r0 			; r0 = sqrt(x)

	pop r1					; Restore registers & return
	pop lr
	ret

;--------------------------
; Algorithm Implementation
;
; Input:  R0 = y
; Output: R0 = 1/sqrt(y)
;--------------------------
fisqrt:
	push lr					; Save used registers
	push r1
	push r2
	push r3

	; Initial estimate
	ldi r1,1 				; r2 = y >> 1
	lsr r0,r1,r2

	ldi r1,MAGIC_NUM 		; r2 = yn = MAGIC_NUM - (y >> 1)
	sub r1,r2,r2

	ldi r1,0.5 				; r0 = y/2 (x2)
	fmul r0,r1,r0

	; Newton's Method - 1st adjustment
	fmul r0,r2,r1 			; r1 = x2 * yn
	fmul r1,r2,r1 			; r1 = (x2 * yn) * yn
	ldi r3,1.5
	fsub r3,r1,r1 			; r1 = 1.5 - (x2 * yn * yn)
	fmul r2,r1,r2 			; r2 = y * (1.5 - (x2 * yn * yn))

	; Newton's Method - 2nd adjustment
	fmul r0,r2,r1 			; r1 = yn * yn
	fmul r1,r2,r1 			; r1 = (x2 * yn) * yn
	ldi r3,1.5
	fsub r3,r1,r1 			; r1 = 1.5 - (x2 * yn * yn)
	fmul r2,r1,r0 			; r0 = y * (1.5 - (x2 * yn * yn))

	pop r3					; Restore registers & return
	pop r2
	pop r1
	pop lr
	ret

