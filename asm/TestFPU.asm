
; FPU Tests - Register/Register

.RAM

.code

main:
	; R0 - R5 should have these vals before & after each operation
	ldi r0,3.762	; 3.762  (0x4386)
	ldi r1,-2.0		; -2.0   (0xc000)
	ldi r2,0x3ecd	; 1.7 	(0x3ecd)
	ldi r3,10.0		; 10.0 	(0x4900)
	ldi r4,6.0e-2	; 0.06 	(0x2bae)
	ldi idx,-2.5e1	; -25.0 	(0xce40)

	; FPU Add: 3.762 + (-2.0) = 1.762
	push r1
	fadd r0,r1,r1
	ldi fp,res_add
	st r1,[fp]
	pop r1

	; FPU Sub: -2.0 - 1.7 = -3.7
	push r2
	fsub r1,r2,r2
	inc fp
	st r2,[fp]
	pop r2

	; FPU Mult: 1.7 * 10.0 = 17.0
	push r3
	fmul r2,r3,r3
	inc fp
	st r3,[fp]
	pop r3

	; FPU Div: 10.0 / 0.06 = 166.667
	push r4
	fdiv r3,r4,r4
	inc fp
	st r4,[fp]
	pop r4

	; FPU Sqrt: sqrt(0.06) = 0.245
	push idx
	fsqrt r4,idx
	inc fp
	st idx,[fp]
	pop idx

	end


.data 

.= 0xc000

; The results are in 0xc000 - 0xc004

res_add:  word 0		; -> 1.762	(0x3f0c)
res_sub:  word 0		; -> -3.7	(0xc366)
res_mult: word 0		; -> 17.0	(0x4c40)
res_div:  word 0		; -> 166.67	(0x5935)
res_sqrt: word 0		; -> 0.245	(0x33d7)

