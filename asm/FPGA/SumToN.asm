
;---------------------
; Sum 1 + 2 + ... + N
;
; Put N in IN
; Sum will be in OUT
;---------------------

.RAM

; BIOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

; Error Code
.equ INV_DATA 0x0006

.code

main:	
   call os_get_in			; r2 = N = IN
	mov r0,r2

   clr r0     				
	cmp r2,r0
	jeq disp					; If N = 0 display '0'
	jlt INV_DATA         ; If N < 0 - Display error code
   
	ldi r1,1					; Initialise current value (r1) to 1
	inc r0					; Initialise total (r0) to 1

loop:
	cmp r1,r2				; We're done when r1 = N
	jeq disp

	inc r1					; Increment current value (r1) and add to total (r0)
	add r1,r0,r0
	jmp loop

disp:	
   call os_disp_out		; Display the total (r0) in OUT
	end

