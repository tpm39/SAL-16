
;---------------------------------------------------
; A Stopwatch
;
; Press the 'Enter' button to start the stopwatch,
; then press the 'Enter' button again to stop it.
;
; Use the 'Time Display' in 'SAL_16_UI.v', and also
; set 'DISP_SW = 0' so that the count is shown.
;---------------------------------------------------

.RAM

; TimmiOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050
.equ os_delay_ms 0x0d30

.equ DELAY_SEC 1000     ; 1s = 1000ms

.equ WAIT  0xfff4       ; Wait LED address
.equ ENTER 0xfff5       ; Enter button address

.code

;---------------
; Main Program
;---------------
main:
   ldi r2,WAIT          ; r2 = Wait LED address
   ldi r3,ENTER         ; r3 = Enter button address 
   clr idx              ; Reset count
   clr r4               ; r4 is used to check for 'stop count'

	call os_get_in 	   ; Wait for button press to start

   ldi r0,1             ; Turn the LED on - this allows button press detection
   st r0,[r2]

next_sec:
   ldi r0,DELAY_SEC     ; Wait 1s
   call os_delay_ms

   ld r0,[r3]           ; Button pressed ?
   cmp r0,r4            ; If so stop counting
   jne done

   inc idx              ; Update count & display
   mov idx,r0
   call os_disp_out

   jmp next_sec

done:
	end

