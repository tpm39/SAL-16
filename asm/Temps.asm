
;----------------------------------------------------------
; A Temperature Converter
;
; It's based on the following C-like code:
;
; const IN_1  = 0xfff3;
; const IN_2  = 0xfff7;
; const OUT_1 = 0xfff6;
; const OUT_2 = 0xfffa;
;
; const A = 9;
; const B = 5;
; const C = 32;
;
; int C_to_F(int cel)
; {
;    int faren;
;    faren = ((A/B) * cel) + C;
;    return faren;
; }
;
; int F_to_C(int faren)
; {
;    int cel;
;    cel = (B/A) * (faren - C);
;    return cel;
; }
;
; void main()
; {
;    int C1, F1, C2, F2;
;
;    C1 = input(IN_1);  
;    F1 = C_to_F(C1);
;    OUT_1 = output(F1);
;
;    F2 = input(IN_2);  
;    C2 = C_to_F(F2);
;    OUT_2 = output(C2);
; }
;
; So the assembly code will:
;   Set C1 & F2 from IN_1 & IN_2
;   Perform the conversions
;   Store C1, F1, C2 & F2 in memory locations 0x80 -> 0x83
;   Set F1 & C2 to OUT_1 & OUT_2
;
; Some test vals:
;   10C (0x0A) -> 50F (0x32)
;   90F (0x5A) -> 32C (0x20)
;----------------------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x1000
.equ os_disp_out 0x1030

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

.code

   jmp main

;------
; Data
;------
.data

; Define constants
A: word 9
B: word 5
C: word 32

;---------
; Program
;---------
.code

main:
   ldi r0,IN_1          ; C1 = IN_1
   call os_get_in
   ldi r1,C1 
   st r0,[r1]

   call C_to_F          ; F1 = C_to_F(C1) 
   ldi r1,F1 
   st r0,[r1]

   mov r0,r1            ; OUT_1 = F1
   ldi r0,OUT_1
   call os_disp_out

   ldi r0,IN_2          ; F2 = IN_2
   call os_get_in
   ldi r1,F2
   st r0,[r1]

   call F_to_C          ; C2 = F_to_C(F2)
   ldi r1,C2
   st r0,[r1]

   mov r0,r1            ; OUT_2 = C2
   ldi r0,OUT_2
   call os_disp_out

   end

;-----------------------------------------
; Perform Celsius to Farenheit conversion
;-----------------------------------------
C_to_F:
   push lr

   ldi r1,A             ; r0 = 9 * r0
   ld r1,[r1]
   mul r0,r1,r0

   ldi r1,B             ; r0 = r0 / 5
   ld r1,[r1]
   sdiv r0,r1,r0

   ldi r1,C             ; r0 = r0 + 32
   ld r1,[r1]
   add r0,r1,r0

   pop lr
   ret

;-----------------------------------------
; Perform Farenheit to Celsius conversion
;-----------------------------------------
F_to_C:
   push lr

   ldi r1,C             ; r1 = -32
   ld r1,[r1]
   not r1,r1            ; r1 = -r1
   inc r1
   add r0,r1,r0         ; r0 = r0 - 32

   ldi r1,B             ; r0 = 5 * r0
   ld r1,[r1]
   mul r0,r1,r0

   ldi r1,A             ; r0 = r0 / 9
   ld r1,[r1]
   sdiv r0,r1,r0

   pop lr
   ret

;------
; Data
;------
.data

C1: word 0
F1: word 0
C2: word 0
F2: word 0

