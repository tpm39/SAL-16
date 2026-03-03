
;-------------------------------------------------------
; Return the n-th Fibonnaci number, where 1 <= n <= 10.
;
; Enter n using IN_1, with the result on OUT_1.
; 
; Display 0xFFFF on OUT_2 if n is invalid.
;
; It is based on the following Python program:
;
;  def Fib(n):
;     if n == 1 or n == 2:
;        return n-1
;     else:
;        return Fib(n-1) + Fib(n-2)
;
;  n = int(input('n: '))
;
;  res = Fib(n)
;
;  print(f'Fib({n}) = {res}')
;-------------------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

.code

;---------
; Program
;---------
main:
   ldi r0,IN_1       ; Get N = in(IN_1)
   call os_get_in

   call TestN        ; Check that n is valid

   call Fib          ; Call Fib(n)

   mov r0,r1         ; OUT_1 = Fib(n)
   ldi r0,OUT_1
   call os_disp_out

   end

;--------------------
; Test for a valid n
;--------------------
TestN:
   clr r1            ; Is n = 0 ?
   cmp r0,r1
   jeq invalid

   ldi r1,10         ; Is n > 10 ?
   cmp r0,r1
   jgt invalid
   ret

invalid:
   ldi r1,0xffff     ; Display 0xFFFF on OUT_2 if n is invalid
   ldi r0,OUT_2
   call os_disp_out
   end

;-------------------------------------
; Calculate the n-th Fibonnaci number
;-------------------------------------
Fib:
   push lr           ; Store return addr on stack

   ldi r1,1          ; Is n = 1 ? If so return 0
   cmp r0,r1
   jeq ret01

   ldi r1,2          ; Is n = 2 ? If so return 1
   cmp r0,r1
   jeq ret01

   dec r0            ; r0 = n - 1

   mov r0,r1         ; Put r1 = n - 2 on stack
   dec r1
   push r1

   call Fib          ; Put Fib(n-1) on stack
   pop r1
   push r0

   mov r1,r0         ; r0 = Fib(n-2)
   call Fib

   pop r1
   add r1,r0,r0      ; r0 = Fib(n-1) + Fib(n-2)

   jmp return

ret01:
   dec r0            ; Return n-1

return:
   pop lr            ; Retrieve return addr
   ret

