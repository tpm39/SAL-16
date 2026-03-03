
; Test the CORDIC unit

; Perform Sin/Cos/Tan using all the addressing modes

; Total the results for Sin/Cos/Tan of 0/30/45/60/90 Degrees
; Once done the total in IDX should be: 0x48ba

.RAM

.code

main:
   ldi r0,0.0
   fsin r0,r0           ; r0 = sin(0)  = 0.000 - 0x0000
   ldi r1,30.0
   fsin r1,r1           ; r1 = sin(30) = 0.500 - 0x3800
   ldi r2,45.0
   fsin r2,r2           ; r2 = sin(45) = 0.707 - 0x39a8
   ldi r3,60.0
   fsin r3,r3           ; r3 = sin(60) = 0.866 - 0x3aee
   ldi r4,90.0
   fsin r4,r4           ; r4 = sin(90) = 1.000 - 0x3c00

   clr idx              ; idx = 0.000 - 0x0000
   fadd r0,idx,idx      ; idx = 0.000 - 0x0000
   fadd r1,idx,idx      ; idx = 0.500 - 0x3800
   fadd r2,idx,idx      ; idx = 1.207 - 0x3cd4
   fadd r3,idx,idx      ; idx = 2.073 - 0x4025
   fadd r4,idx,idx      ; idx = 3.073 - 0x4225

   ldi r0,0.0
   fcos r0,r0           ; r0 = cos(0)  = 1.000 - 0x3c00
   ldi r1,30.0
   fcos r1,r1           ; r1 = cos(30) = 0.866 - 0x3aee
   ldi r2,45.0
   fcos r2,r2           ; r2 = cos(45) = 0.707 - 0x39a8
   ldi r3,60.0
   fcos r3,r3           ; r3 = cos(60) = 0.500 - 0x3800
   ldi r4,90.0
   fcos r4,r4           ; r4 = cos(90) = 0.000 - 0x0000

   fadd r0,idx,idx      ; idx = 4.073 - 0x4413
   fadd r1,idx,idx      ; idx = 4.939 - 0x44f0
   fadd r2,idx,idx      ; idx = 5.646 - 0x45a5
   fadd r3,idx,idx      ; idx = 6.146 - 0x4625
   fadd r4,idx,idx      ; idx = 6.146 - 0x4625

   ldi r0,0.0
   ftan r0,r0           ; r0 = tan(0)  = 0.000 - 0x0000
   ldi r1,30.0
   ftan r1,r1           ; r1 = tan(30) = 0.577 - 0x389e
   ldi r2,45.0
   ftan r2,r2           ; r2 = tan(45) = 1.000 - 0x3c00
   ldi r3,60.0
   ftan r3,r3           ; r3 = tan(60) = 1.732 - 0x3eee
   ldi r4,90.0
   ftan r4,r4           ; r4 = tan(90) = Inf   - 0x7c00

   fadd r0,idx,idx      ; idx = 6.146 - 0x4625
   fadd r1,idx,idx      ; idx = 6.723 - 0x46b9
   fadd r2,idx,idx      ; idx = 7,723 - 0x47b9
   fadd r3,idx,idx      ; idx = 9.455 - 0x48ba
                        ; Don't bother with the Inf in r4
   end

