
;----------------------------------------
; Compare 2 numbers entered via IN
;
; OUT displays if the 1st number 
; is greater than the 2nd or not
;
; This is just a test for the
; ALU's signed comparator
;
; Use the 'Hex Display' in 'SAL_16_UI.v'
;----------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

; Misc defines
.equ TRUE  0x1111
.equ FALSE 0x0000

.code

main:
   call os_get_in       ; Get x = r1 = IN_1
   mov r0,r1

   call os_get_in       ; Get y = r2 = IN_1
   mov r0,r2

   ldi r3,TRUE          ; r3 = TRUE if x > y

   cmp r1,r2
   jgt done

   ldi r3,FALSE         ; r3 = FALSE if x < y

done:
   mov r3,r0            ; Display 'x > y' on OUT_1
   call os_disp_out
   end

