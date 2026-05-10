
;---------------------------------------------------------
; Using the CORDIC hardware unit in the FPU to produce
; the Sin, Cos & Tan of angles in the range 0 <= x <= 90.
;
; The results are in memory:
;   Sin's from addr 0x9000
;   Cos's from addr 0x9100
;   Tan's from addr 0x9200
;
; The numbers are in 16 bit floating point format.
;---------------------------------------------------------

.RAM

.equ NUM_ANGS 19

.equ F5 5.0

.code

;---------
; Program
;---------
main:
   clr r1            ; r1 = Current angle
   ldi r2,F5         ; r2 = Angle increment (5.0 degs)
   ldi r3,NUM_ANGS   ; r3 = Number of angles to be calculated
   clr idx           ; idx = Loop count

next:
   cmp idx,r3        ; Calculated all angles ?
   jeq done

   mov r1,r0         ; Calculate & store sin(current angle)
   fsin r0,r0
   ldi r4,sins
   stx r0,[r4,idx]

   mov r1,r0         ; Calculate & store cos(current angle)
   fcos r0,r0
   ldi r4,coses
   stx r0,[r4,idx]

   mov r1,r0         ; Calculate & store tan(current angle)
   ftan r0,r0
   ldi r4,tans
   stx r0,[r4,idx]

   fadd r1,r2,r1     ; Get the next angle
   inc idx

   jmp next

done:
   end

;------
; Data
;------
.data

.= 0x9000

sins: array 19

.= 0x9100

coses: array 19

.= 0x9200

tans: array 19

