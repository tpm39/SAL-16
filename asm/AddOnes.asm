
;--------------------------------------------------
; A wee recursion test that adds n (R1) to x (R0),
; and stores the result in Mem 0x8100
;
; It is based on the following Python program:
;
;  # Add n to x
;
;  def Add_n_1s(x,n):
;     if n == 0:
;        return x
;     else:
;        return 1 + Add_n_1s(x,n-1)
;
;  x = 18
;  n = 7
;
;  res = Add_n_1s(x,n)
;
;  print(res)
;--------------------------------------------------

.RAM

.code

main:
   ldi r0,18      ; Set x
   ldi r1,7       ; Set n

   call Add_n_1s  ; Call Add_n_1s(x,n)

   ldi r2,0x8100  ; Mem 0x8100 = x + n
   st r0,[r2]

   end

Add_n_1s:
   push lr        ; Store return addr on stack

   clr r2         ; Is n = 0 ? If so we're done - Return x
   cmp r1,r2
   jeq done

   dec r1         ; n = n -1

   call Add_n_1s  ; Call Add_n_1s(x,n-1)

   inc r0         ; Return 1 + Add_n_1s(x,n-1)

done:
   pop lr         ; Retrieve return addr
   ret

