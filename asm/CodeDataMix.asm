
;-------------------------------------
; A test of mixing Code & Data blocks
;-------------------------------------

.RAM

.code

main:
	jmp next1


.data
.= 0x8100

val1: word -4.7


.= 0x8200
.code

next1:
	ldi idx,vals
	inc idx
	inc idx
	ld r0,[idx]  		; r0 = 3.3 (0x429a)
	ldi r1,val2
	jmp next2



.= 0x8300
.data

val2: word 7.2


.code
.= 0x8400

next2:
	ld r1,[r1]    		; r1 = 7.2 (0x4733)
	ldi r2,val1
	ld r2,[r2]    		; r2 = -4.7 (0xc4b3)

	fadd r0,r1,r3
	fadd r3,r2,r3  	; r3 = 3.3 + 7.2 - 4.7 = 5.8 (0x45cd)

	end


.data
.= 0x8500

vals: array [-1.1, 2.2, 3.3]

