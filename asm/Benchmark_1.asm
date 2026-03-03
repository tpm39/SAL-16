
;-----------------------------------------------
; Arithmetic Benchmark - Sum: 1 + 2 + ... + 250
;-----------------------------------------------

.RAM

.equ MAX 250

.code

main:
   clr r0
   clr idx
   ldi r1,MAX

loop:
   add r0,idx,r0
   inc idx
   cmp idx,r1
   jle loop

   end

