
;-----------------------------------------------------------------------
; A program to test interrupts
;
; OUT_1 displays numbers continuously counting up.
;
; OUT_2 displays a number (starting at 0) that is incremented
; when ENTER_1 is pressed, and decremented when ENTER_2 is pressed.
;
; Once OUT_2 reaches a threshold value further interrupts are disabled,
; and OUT_2 remains at that value, while OUT_1 continues counting up.
;-----------------------------------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

.equ THRESH 3

.code

main:                ; Enable interrupts & set initial values
   eni
   ldi r2,THRESH     ; R2 holds the "threshold value"
   clr r3            ; R3 holds the "continuous count"
   clr r4            ; R4 holds the "interrupt value"

loop:
   call inc_counter
   call disp_val

   cmp r4,r2         ; Check for "threshold" beiing reached
   jeq dis_int
   jmp loop

dis_int:             ; Disable interrupts as threshold reached
   dsi
   call disp_val

forever:             ; Carry on with the "continuous counter"
   call inc_counter
   jmp forever

inc_counter:         ; Increment & display the "continuous counter"
   push lr
   inc r3
   ldi r0,OUT_1
   mov r3,r1
   call os_disp_out
   pop lr
   ret

disp_val:            ; Display "interrupt value"
   push lr
   ldi r0,OUT_2
   mov r4,r1
   call os_disp_out
   pop lr
   ret

;-----------------------------
; Interrupt Service Routines
;-----------------------------

.=0xb000

int_ent_1:           ; Increment R4
   inc r4
   rti

.=0xb100

int_ent_2:           ; Decrement R4
   dec r4
   rti

