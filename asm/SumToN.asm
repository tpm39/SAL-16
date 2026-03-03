
;----------------------
; Sum 1 + 2 + ... + N
;
; Put N in IN_1 
; Sum will be in OUT_2
;----------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ OUT_2 10

; Error Code
.equ INV_DATA 0x0130

.code

main:	
   ldi r0,IN_1   			; r2 = N = IN_1
   call os_get_in
	mov r0,r2

   clr r0     				; Is N = 0 ?
	cmp r2,r0 
   jne n_ok

   jmp INV_DATA   		; N = 0 - Display error code

n_ok:
	ldi r1,1					; Initialise current value (r1) to 1
	inc r0					; Initialise total (r0) to 1
	
loop:
	cmp r1,r2				; We're done when r1 = N
	jeq disp

	inc r1					; Increment current value (r1) and add to total (r0)
	add r1,r0,r0
	jmp loop

disp:	
   mov r0,r1      		; Store the total (r0) in OUT_2
   ldi r0,OUT_2
   call os_disp_out
	end

