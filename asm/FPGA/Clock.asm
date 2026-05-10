
;--------------------------------------------
; A Clock
;
; Enter the current 'hours' followed by the 
; current 'minutes' to initialise the clock. 
;
; Use the 'Time Display' in 'SAL_16_UI.v'
;--------------------------------------------

.RAM

; TimmiOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050
.equ os_delay_ms 0x0d30

.equ DELAY_MIN 60000    ; 1 min = 60,000 ms

.equ MIDNIGHT 1440      ; 1440 = 24 * 60 = 24:00

.code

;---------------
; Main Program
;---------------
main:
   ldi r4,MIDNIGHT      ; r4 = midnight 'minutes count'

   call os_get_in       ; Get hours = in(IN_1)

   mov r0,idx           ; idx = 60 * hours
   ldi r1,60
   mul r0,r1,r0
   mov r0,idx

   call os_get_in       ; Get minutes = in(IN_1)

   add idx,r0,idx       ; idx = (60 * hours) + minutes

   jmp disp_time        ; Display initial time

next_min:
   ldi r0,DELAY_MIN     ; Wait 1 min
   call os_delay_ms

   inc idx              ; Update 'minutes count'
   cmp idx,r4
   jne disp_time

   clr idx              ; Set time = 00:00 at midnight

disp_time:
   mov idx,r0           ; Display time
   call os_disp_out

   jmp next_min

	end

