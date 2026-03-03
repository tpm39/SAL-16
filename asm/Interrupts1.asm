
;------------------------------------
; A simple 'Test Interrupts' program
;------------------------------------

.RAM

.code

main:             ; Enable interrupts & set initial value
   eni
   clr r0         ; R0 holds the "interrupt value"

forever:          ; Loop forever waiting on interrupts
   jmp forever

;-----------------------------
; Interrupt Service Routines
;-----------------------------

.=0xb000

int_ent_1:        ; Increment R0 when ENTER_1 is pressed
   inc r0
   rti

.=0xb100

int_ent_2:        ; Decrement R0 when ENTER_2 is pressed
   dec r0
   rti

