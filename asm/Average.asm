
;---------------------------------------------
; Find the average of N numbers
;
; Enter N via IN_1
; Enter the numbers to be averaged via IN_2
;
; OUT_1 displays the running total
; OUT_2 displays the average
;
; Pseudo-code:
;   N = IN_1
;   x = 0
;   i = N
;   while (i > 0)
;     x = x + IN_2
;     i = i - 1
;   av = x / N
;---------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

; Error Code
.equ DIV_BY_0 0x0100

.code

main:
   ldi r0,IN_1       ; Get N = IN_1
   call os_get_in
   mov r0,r3         ; r3 = N = i (loop count)
   ldi r2,N          ; Store N in memory
   st r3,[r2]
   clr r2            ; Clear running total x (r2)

   cmp r0,r2         ; Is N = 0 ?
   jne loop

   jmp DIV_BY_0      ; N = 0 - Display error code

loop:
   ldi r0,IN_2       ; Get next n = IN_2
   call os_get_in
   add r0,r2,r2      ; x = x + n

   ldi r0,OUT_1      ; Display x on OUT_1
   mov r2,r1
   call os_disp_out

   dec r3            ; Decrement i
   jz done           ; if i = 0 we're done
   jmp loop

done:
   mov r2,r0         ; Get the average: av = x / N
   ldi r2,N
   ld r1,[r2]
   sdiv r0,r1,r0     ; av (r0) = r0 / r1

   mov r0,r1         ; Display av on OUT_2
   ldi r0,OUT_2
   call os_disp_out

   end


.data

N: word 0

