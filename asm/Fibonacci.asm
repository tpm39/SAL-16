
;-----------------------------------------------
; Fibonacci Series
;
; Store the 1st 25 Fibonacci numbers in memory,
; starting at Mem 0x8100
;
; The 1st 25 Fibonacci numbers are:
;
; 0x0000  0x0001  0x0001  0x0002  0x0003
; 0x0005  0x0008  0x000d  0x0015  0x0022
; 0x0037  0x0059  0x0090  0x00e9  0x0179
; 0x0262  0x03db  0x063d  0x0a18  0x1055
; 0x1a6d  0x2ac2  0x452f  0x6ff1  0xb520
;-----------------------------------------------

.RAM

.code

main:	
	clr r0				; The 1st number
	ldi r1,1				; The 2nd number
	ldi r2,0x8100		; The 1st storage address
	clr idx

	stx r0,[r2,idx]	; Store the 1st two numbers
	inc idx
	stx r1,[r2,idx]
	inc idx

loop:	
	add r1,r0,r0		; Calculate the next number & store it
	jc done				; Stop when we've passed 0xffff
	stx r0,[r2,idx]
	inc idx				; Increment the storage address

	add r0,r1,r1		; Calculate the next number & store it
	jc done				; Stop when we've passed 0xffff
	stx r1,[r2,idx]
	inc idx				; Increment the storage address

	jmp loop

done:	
	end

