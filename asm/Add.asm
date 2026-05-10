
;------------------------------------------------------------------
; Add Code - To compare with Compiler generated code (rmg/Add.rmg)
;
; This is:
;   38 lines of assembly code
;   34 bytes of machine code
;------------------------------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

.code

main:
   ldi r0,IN_1          ; x = IN_1
   call os_get_in
   mov r0,r1

   ldi r0,IN_2          ; y = IN_2
   call os_get_in
   mov r0,r2

   add r1,r2,r0         ; z = x + y

   mov r0,r1            ; Display z on OUT_1
   ldi r0,OUT_1
   call os_disp_out

   end

