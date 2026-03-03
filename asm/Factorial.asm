
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
;        return n
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

   ldi r1,2          ; Is n = 0 or n = 1 ? If so return n
   cmp r1,r0
   jgt return

   push r0           ; Put n on stack

   dec r0            ; r0 = n - 1

   call Fact         ; r0 = Fact(n-1)

   pop r1            ; r0 = n * Fact(n-1)
   call mult

return:
   pop lr
   ret

;------------------------------
; Multiplication: r0 = r0 * r1
;------------------------------
mult:	
   push r2           ; Store registers
   push r3
   push r4

	clr r2	         ; Clear the result (r2 = 0)
	ldi r3,1		      ; r3 tracks the current multiplication bit
   mov r3,r4         ; r4 = 1 - The shift amount

m_loop:
   lsr r0,r4,r0	   ; Get MSB of R0 and
	jc m_add			   ; add r1 to r2 if it's 1
	jmp m_noadd

m_add:
	add r1,r2,r2	   ; Update result

m_noadd:
   lsl r1,r4,r1	   ; Multiply r1 by 2
   lsl r3,r4,r3	   ; Move the current multiplication bit and
	jc m_done		   ; if the MSB of r3 is 1 we've done all 8 bits
	jmp m_loop

m_done:
	add r2,r0,r0	   ; Put the result in r0

   pop r4            ; Restore registers
   pop r3
   pop r2
	ret

