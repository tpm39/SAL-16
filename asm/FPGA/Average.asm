
;-----------------------------------------
; Find the average of N numbers
;
; Enter N via IN
; Enter the numbers to be averaged via IN
;
; OUT displays the average
;
; Pseudo-code:
;   N = IN
;   x = 0
;   i = N
;   while (i > 0)
;     x = x + IN
;     i = i - 1
;   av = x / N
;-----------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

.code

main:
   call os_get_in       ; Get N = IN
   mov r0,r2            ; r2 = N = i (loop count)
   ldi r1,N             ; Store N in memory
   st r2,[r1]
   clr r1               ; Clear running total x (r1)

   cmp r0,r1            ; If N = 0 display '0'
   jeq zero

loop:
   call os_get_in       ; Get next n = IN
   add r0,r1,r1         ; x = x + n

   dec r2               ; Decrement i
   jz done              ; if i = 0 we're done
   jmp loop

done:
   mov r1,r0            ; Get the average: av = x / N
   ldi r2,N
   ld r1,[r2] 
   sdiv r0,r1,r0        ; av (r0) = r0 / r1

zero:
   call os_disp_out     ; Display av on OUT
   end


.data

N: word 0

