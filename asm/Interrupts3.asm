
;-----------------------------------------------
; Sit in an endless loop waiting on keyboard 
; interrupts, displaying chars as they come in.
;-----------------------------------------------

.RAM

.equ KBD 0xfff1
.equ TTY 0xfff2

.code

main:
   eni               ; Enable interrupts
   clr r0            ; R0 holds the "char available" flag
   ldi r1,1
   ldi r2,KBD
   ldi r3,TTY

forever:             ; Endless loop waiting on interrupts
   cmp r0,r1         ; Char available ?
   jeq printChr
   jmp forever

printChr:
   ld r4,[r2]        ; Read a char
   st r4,[r3]        ; Display it
   clr r0            ; Clear the "char available" flag
   jmp forever       ; Back to the endless loop

;----------------------------
; Interrupt Service Routine
;----------------------------
.= 0xb200

int_kbd:
   inc r0            ; Set the "char available" flag
   rti

