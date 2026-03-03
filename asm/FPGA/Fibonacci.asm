
;------------------------------------------------------------------
; Fibonacci Series
;
; Step through the Fibonacci numbers < 10,0000 on a button press
;
; The displayed Fibonacci numbers are:
;
;   0    1    1     2     3     5     8 
;  13   21   34    55    89   144   233
; 377  610  987  1597  2584  4181  6765
;
; and in hex:
;
; 0x0000  0x0001  0x0001  0x0002  0x0003  0x0005  0x0008
; 0x000d  0x0015  0x0022  0x0037  0x0059  0x0090  0x00e9
; 0x0179  0x0262  0x03db  0x063d  0x0a18  0x1055  0x1a6d
;
; Set 'DISP_SW = 0' in 'SAL_16_UI.v' so that the numbers are shown
;------------------------------------------------------------------

.RAM 

; TimmiOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

.code

;---------------
; Main Program
;---------------
start:
	ldi r4,9999				; Can only display upto 9,999

	clr r1					; Display the 1st number
	mov r1,r2
	call dispWait

	ldi r1,1					; Display the 2nd number
	mov r1,r3
	call dispWait

loop:	
	add r2,r3,r2			; Calculate the next number
	cmp r2,r4
	jgt done					; We're done - Next number > 9,9999
	mov r2,r1				; Display the number
	call dispWait

	add r2,r3,r3			; Calculate the next number
	cmp r3,r4
	jgt done					; We're done - Next number > 9,9999
	mov r3,r1				; Display the number
	call dispWait

	jmp loop

done:
	end

;---------------------------------------------
; Display a number & Wait for a button press
;---------------------------------------------
dispWait:
	push lr
	
   mov r1,r0  				; Display the number
	call os_disp_out

	call os_get_in			; Wait for button press

	pop lr
	ret

