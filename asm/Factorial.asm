
;-----------------------------------------------
; Return Factorial(n), where 0 <= n <= 5.
;
; Enter n using IN_1, with the result on OUT_2.
; 
; Display 0xffff on OUT_1 if n is invalid.
;
; It is based on the following Python program:
;
;  def Fact(n):
;     if n == 0 or n == 1:
;        return 1
;     else:
;        return n * Fact(n-1)
;
;  n = int(input('n: '))
;
;  res = Fact(n)
;
;  print(f'Fact({n}) = {res}')
;-----------------------------------------------

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

   call Fact         ; Call Fact(n)

   mov r0,r1         ; OUT_2 = Fact(n)
   ldi r0,OUT_2
   call os_disp_out

   end

;--------------------
; Test for a valid n
;--------------------
TestN:
   ldi r1,5          ; Is n > 5 ?
   cmp r0,r1
   jgt invalid

   clr r1            ; Is n < 0 ?
   cmp r0,r1
   jlt invalid

   ret

invalid:
   ldi r1,0xffff     ; OUT_1 = 0xffff
   ldi r0,OUT_1
   call os_disp_out

   end

;------------------------
; Calculate Factorial(n)
;------------------------
Fact:
   push lr           ; Store return addr on stack

   ldi r1,2          ; Is n = 0 or n = 1 ? If so return 1
   cmp r0,r1
   jge calc
   
   ldi r0,1          ; Return 1
   jmp return

calc:
   push r0           ; Put n on stack

   dec r0            ; r0 = n - 1

   call Fact         ; r0 = Fact(n-1)

   pop r1            ; r0 = n * Fact(n-1)
   mul r0,r1,r0

return:
   pop lr
   ret

