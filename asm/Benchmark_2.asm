
;-----------------------------------------------------------------------------
; Floating Point Benchmark - Sum: 1.0 + 2.0 + ... + 250.0 = 31,375.0 = 0x77a9
;-----------------------------------------------------------------------------

.RAM

.equ MAX 250.0

.code

main:
   clr r0            ; r0 = 0.0 (tot)
   clr idx           ; idx = 0.0
   ldi r1,MAX
   ldi r2,0.5
   fadd r1,r2,r1     ; r1 = MAX + 0.5
   ldi r2,1.0        ; r2 = 1.0

loop:
   fadd r0,idx,r0    ; tot += idx
   fadd idx,r2,idx   ; inc idx
   fcmp idx,r1       ; Done ?
   jlt loop

   end

