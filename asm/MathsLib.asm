
;---------------------------------------------------------
; Maths Library for TimmiOS - The SAL-16 Operating System
;---------------------------------------------------------

;--------------------------------------------
; Defines for use in programs using TimmiOS:
;
; .equ imath_abs          0x2000
; .equ imath_pow          0x2010
; .equ imath_mod          0x2040
; .equ imath_fact         0x2050
; .equ imath_sqrt         0x2070
;
; .equ imath_vec_add      0x21b0
; .equ imath_vec_sub      0x21f0
; .equ imath_vec_sc_mul   0x2230
; .equ imath_vec_dot_prod 0x2260
;
; .equ imath_mat_add      0x22a0
; .equ imath_mat_sub      0x22e0
; .equ imath_mat_sc_mul   0x2320
; .equ imath_mat_mul      0x2350
; .equ imath_mat_trans    0x2510
; .equ imath_mat_det_2    0x2550
; .equ imath_mat_det_3    0x2590
;
; .equ imath_cmplx_re     0x2620
; .equ imath_cmplx_im     0x2630
; .equ imath_cmplx_conj   0x2640
; .equ imath_cmplx_add    0x2660
; .equ imath_cmplx_sub    0x2680
; .equ imath_cmplx_sc_mul 0x26a0
; .equ imath_cmplx_mul    0x26c0
;
; .equ fmath_abs          0x26f0
; .equ fmath_pow          0x2700
; .equ fmath_sqrt         0x2740
; .equ fmath_sin          0x2750
; .equ fmath_cos          0x27a0
; .equ fmath_tan          0x27f0
;
; .equ fmath_vec_add      0x2840
; .equ fmath_vec_sub      0x2880
; .equ fmath_vec_sc_mul   0x28c0
; .equ fmath_vec_dot_prod 0x28f0
;
; .equ fmath_mat_add      0x2930
; .equ fmath_mat_sub      0x2970
; .equ fmath_mat_sc_mul   0x29b0
; .equ fmath_mat_mul      0x29e0
; .equ fmath_mat_trans    0x2bf0
; .equ fmath_mat_det_2    0x2c10
; .equ fmath_mat_det_3    0x2c50
;
; .equ fmath_cmplx_re     0x2ce0
; .equ fmath_cmplx_im     0x2cf0
; .equ fmath_cmplx_conj   0x2d00
; .equ fmath_cmplx_add    0x2d20
; .equ fmath_cmplx_sub    0x2d50
; .equ fmath_cmplx_sc_mul 0x2d80
; .equ fmath_cmplx_mul    0x2da0
;
; .equ fmath_exp          0x2dd0
; .equ fmath_ln           0x2e10
;
; .equ MATH_PI      3.141593
; .equ MATH_E       2.718282
; .equ MATH_DEG_RAD 0.017453 
;
; .equ MATH_NAN     0x7e00
; .equ MATH_INF_POS 0x7c00
; .equ MATH_INF_NEG 0xfc00
;--------------------------------------------

.ROM

; Maths Library Defines
.equ MATH_INF_NEG 0xfc00
.equ MATH_DEG_RAD 0.017453 

; CORDIC Algorithm Defines
.equ ITERS 12
.equ K 1.2051363584464607

; BIOS Defines
.equ os_mem_set 0x1110
.equ os_exit    0x1a90

; Error Codes
.equ DIV_BY_0     0x0100
.equ POW_UNDEF    0x0110
.equ INV_DATA     0x0130
.equ BAD_VEC_DIMS 0x0140
.equ BAD_MAT_DIMS 0x0150
.equ LN_LTE_ZERO  0x0160

.code

;------------------------------
; Maths - Absolute Value (int)
;
; Location: ROM addr 0x2000
;
; Inputs: R0 = val
; Output: R0 = abs(val)
;------------------------------

.= 0x2000

imath_abs:
   push r1              ; Save used register

   clr r1               ; Is val >= 0 ? If so leave as is
   add r0,r1,r0
   jpl iabs_done

   not r0,r0            ; val < 0 - change its sign
   inc r0

iabs_done:
   pop r1               ; Retrieve register
   ret

;------------------------------
; Maths - Exponentiation (int)
;
; Location: ROM addr 0x2010
;
; Inputs: R0 = x
;         R1 = n
; Output: R0 = x^n
;------------------------------

.= 0x2010

imath_pow:
   push r2              ; Save used registers
   push r1

   clr r2               ; Is it 0^0 ? If so it's undefined
   cmp r0,r2
   jne ipow_test_n
   cmp r1,r2
   jne ipow_test_n

   jmp POW_UNDEF        ; If it's 0^0 display the error code

ipow_test_n:
   cmp r1,r2
   jlt ipow_ret_0     ; Is n < 0 ? If so return 0
   jeq ipow_ret_1     ; Is n = 0 ? If so return 1

   mov r0,r2            ; r2 = x

ipow_loop:
   dec r1               ; Multiply x by itself n times
   jz ipow_done   
   mul r0,r2,r0
   jmp ipow_loop

ipow_ret_0:
   clr r0
   jmp ipow_done

ipow_ret_1:
   ldi r0,1

ipow_done:
   pop r1               ; Retrieve registers
   pop r2
   ret

;---------------------------
; Maths - Modulus (int)
;
; Location: ROM addr 0x2040
;
; Inputs: R0 = x
;         R1 = y
;
; Output: R0 = x % y
;---------------------------

.= 0x2040

imath_mod:
   push r2              ; Save used register

   clr r2               ; Test for division by 0
   cmp r1,r2
   jne imod_calc

   jmp DIV_BY_0         ; Division by 0 - Display error code

imod_calc:
   udiv r0,r1,r2        ; mod = x - y*(x/y)
   mul r2,r1,r2
   sub r0,r2,r0

   pop r2               ; Retrieve register
   ret

;---------------------------
; Maths - Factorial (int)
;
; Location: ROM addr 0x2050
;
; Inputs: R0 = n
; Output: R0 = fact(n)
;---------------------------

.= 0x2050

imath_fact:
   push lr              ; Save used registers
   push r1

   ldi r1,2             ; Is n = 0 or n = 1 ? If so return 1
   cmp r1,r0
   jgt ifact_ret_1

   push r0              ; Put n on stack

   dec r0               ; r0 = n - 1

   call imath_fact      ; r0 = Fact(n-1)

   pop r1               ; r0 = n * Fact(n-1)
   mul r0,r1,r0
   jmp ifact_done

ifact_ret_1:
   ldi r0,1
   
ifact_done:
   pop r1               ; Retrieve registers
   pop lr
   ret

;------------------------------------------------
; Maths - Square Root (int)
;
; Location: ROM addr 0x2070
;
; Inputs: R0 = x
; Output: R0 = sqrt(x)
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Maths.rmg'
;------------------------------------------------

.= 0x2070

imath_sqrt:
   push r1     ; Save registers
   push r2
   push r3
   push r4
   push idx
   push lr     ; Auto-generated code
   push fp
   push r0
   movsp fp
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   ldi r0,1
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_imath_sqrt_3
   clr r2
cond_imath_sqrt_3:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_imath_sqrt_1
   ldi r0,304
   call os_exit
if_imath_sqrt_1:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_None_7
   clr r2
cond_None_7:
   mov r2,r0
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_None_8
   clr r2
cond_None_8:
   mov r2,r0
   push r0
   pop r1
   pop r0
   ldi r2,1
   clr r3
   cmp r0,r3
   jgt cond_imath_sqrt_9
   cmp r1,r3
   jgt cond_imath_sqrt_9
   clr r2
cond_imath_sqrt_9:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_imath_sqrt_5
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   pop r0
   jmp ret_imath_sqrt
if_imath_sqrt_5:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
while_imath_sqrt_10:
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_imath_sqrt_12
   clr r2
cond_imath_sqrt_12:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_imath_sqrt_11
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_imath_sqrt_16
   clr r2
cond_imath_sqrt_16:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_imath_sqrt_14
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r0
   jmp ret_imath_sqrt
if_imath_sqrt_14:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_imath_sqrt_19
   clr r2
cond_imath_sqrt_19:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_imath_sqrt_17
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   ldi idx,-3
   stx r0,[fp,idx]
   jmp if_imath_sqrt_18
if_imath_sqrt_17:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
if_imath_sqrt_18:
   jmp while_imath_sqrt_10
while_imath_sqrt_11:
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r0
   jmp ret_imath_sqrt
ret_imath_sqrt:
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Save registers
   pop r4
   pop r3
   pop r2
   pop r1
   ret

;--------------------------------
; Maths - Vector Addition (int)
;
; Location: ROM addr 0x21b0
;
; Inputs: R0 = addr of a
;         R1 = addr of b
;         R2 = addr of c (a + b)
;--------------------------------

.= 0x21b0

imath_vec_add:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows both = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldx r4,[r1,idx]      ; r4 = b rows
   cmp r3,r4
   jeq ivec_add_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

ivec_add_1_row:
   ldi r4,1
   cmp r3,r4
   jeq ivec_add_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

ivec_add_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; c rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   ldx r4,[r1,idx]      ; r4 = b cols
   cmp r3,r4
   jeq ivec_add_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

ivec_add_start:
   stx r3,[r2,idx]      ; c cols = a cols
   mov r3,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx

ivec_add_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   ldx r4,[r1,idx]      ; r4 = b[i]
   add r3,r4,r4         ; r4 = a[i] + b[i]
   stx r4,[r2,idx]      ; c[i] = a[i] + b[i]
   inc idx
   cmp idx,fp           ; Finished ?
   jne ivec_add_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;----------------------------------
; Maths - Vector Subtraction (int)
;
; Location: ROM addr 0x21f0
;
; Inputs: R0 = addr of a
;         R1 = addr of b
;         R2 = addr of c (a - b)
;----------------------------------

.= 0x21f0

imath_vec_sub:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows both = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldx r4,[r1,idx]      ; r4 = b rows
   cmp r3,r4
   jeq ivec_sub_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

ivec_sub_1_row:
   ldi r4,1
   cmp r3,r4
   jeq ivec_sub_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

ivec_sub_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; c rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   ldx r4,[r1,idx]      ; r4 = b cols
   cmp r3,r4
   jeq ivec_sub_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

ivec_sub_start:
   stx r3,[r2,idx]      ; c cols = a cols
   mov r3,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx

ivec_sub_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   ldx r4,[r1,idx]      ; r4 = b[i]
   sub r3,r4,r4         ; r4 = a[i] - b[i]
   stx r4,[r2,idx]      ; c[i] = a[i] - b[i]
   inc idx
   cmp idx,fp           ; Finished ?
   jne ivec_sub_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;--------------------------------------------
; Maths - Vector Scalar Multiplication (int)
;
; Location: ROM addr 0x2230
;
; Inputs: R0 = addr of a
;         R1 = multiplier (m)
;         R2 = addr of b (m * a)
;--------------------------------------------

.= 0x2230

imath_vec_sc_mul:
   push idx             ; Save used registers
   push r4
   push r3
   
   clr idx

   ; Rows = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldi r4,1
   cmp r3,r4
   jeq ivec_sc_mul_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

ivec_sc_mul_cols:
   ; Get cols
   stx r3,[r2,idx]      ; b rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   stx r3,[r2,idx]      ; b cols = a cols
   mov r3,r4            ; r4 = 'a cols' + 2 (vector length)
   inc r4
   inc r4
   inc idx

ivec_sc_mul_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   mul r1,r3,r3         ; r3 = m * a[i]
   stx r3,[r2,idx]      ; b[i] = m * a[i]
   inc idx
   cmp idx,r4           ; Finished ?
   jne ivec_sc_mul_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   ret

;----------------------------
; Maths - Dot Product (int)
;
; Location: ROM addr 0x2260
;
; Inputs: R0 = addr of a
;         R1 = addr of b
; Output: R0 = a.b
;----------------------------

.= 0x2260

imath_vec_dot_prod:
   push fp              ; Save used registers
   push idx
   push r4
   push r3
   push r2

   ; Rows both = 1 ?
   clr idx
   ldx r2,[r0,idx]      ; r2 = a rows
   ldx r3,[r1,idx]      ; r3 = b rows
   cmp r2,r3
   jeq ivec_dp_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

ivec_dp_1_row:
   ldi r4,1
   cmp r2,r4
   jeq ivec_dp_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

ivec_dp_cols:
   ; Cols equal ?
   inc idx
   ldx r2,[r0,idx]      ; r2 = a cols
   ldx r3,[r1,idx]      ; r3 = b cols
   cmp r2,r3
   jeq ivec_dp_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

ivec_dp_start:
   mov r2,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx
   clr r4

ivec_dp_loop:
   ldx r2,[r0,idx]      ; r2 = a[i]
   ldx r3,[r1,idx]      ; r3 = b[i]
   mul r2,r3,r3         ; r3 = a[i] * b[i]
   add r3,r4,r4         ; fp = sum of 'a[i] * b[i]'s
   inc idx
   cmp idx,fp           ; Finished ?
   jne ivec_dp_loop

   mov r4,r0            ; Put the result in r0
   
   pop r2               ; Retrieve registers
   pop r3
   pop r4
   pop idx
   pop fp
   ret

;--------------------------------
; Maths - Matrix Addition (int)
;
; Location: ROM addr 0x22a0
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A + B)
;--------------------------------

.= 0x22a0

imath_mat_add:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows equal ?
   ldx r3,[r0,idx]      ; r3 = A rows
   ldx r4,[r1,idx]      ; r4 = B rows
   cmp r3,r4
   jeq imat_add_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

imat_add_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; C rows = A rows
   mov r3,fp            ; fp = 'A rows'
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   ldx r4,[r1,idx]      ; r4 = B cols
   cmp r3,r4
   jeq imat_add_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

imat_add_start:
   stx r3,[r2,idx]      ; C cols = A cols
   mul r3,fp,fp         ; fp = 'A cols' * 'A rows' + 2 (matrix size)
   inc fp
   inc fp
   inc idx

imat_add_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   ldx r4,[r1,idx]      ; r4 = B[i,j]
   add r3,r4,r4         ; r4 = A[i,j] + B[i,j]
   stx r4,[r2,idx]      ; C[i,j] = A[i,j] + B[i,j]
   inc idx
   cmp idx,fp           ; Finished ?
   jne imat_add_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;----------------------------------
; Maths - Matrix Subtraction (int)
;
; Location: ROM addr 0x22e0
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A - B)
;----------------------------------

.= 0x22e0

imath_mat_sub:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows equal ?
   ldx r3,[r0,idx]      ; r3 = A rows
   ldx r4,[r1,idx]      ; r4 = B rows
   cmp r3,r4
   jeq imat_sub_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

imat_sub_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; C rows = A rows
   mov r3,fp            ; fp = 'A rows'
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   ldx r4,[r1,idx]      ; r4 = B cols
   cmp r3,r4
   jeq imat_sub_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

imat_sub_start:
   stx r3,[r2,idx]      ; C cols = A cols
   mul r3,fp,fp         ; fp = 'A cols' * 'A rows' + 2 (matrix size)
   inc fp
   inc fp
   inc idx

imat_sub_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   ldx r4,[r1,idx]      ; r4 = B[i,j]
   sub r3,r4,r4         ; r4 = A[i,j] - B[i,j]
   stx r4,[r2,idx]      ; C[i,j] = A[i,j] - B[i,j]
   inc idx
   cmp idx,fp           ; Finished ?
   jne imat_sub_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;--------------------------------------------
; Maths - Matrix Scalar Multiplication (int)
;
; Location: ROM addr 0x2320
;
; Inputs: R0 = addr of A
;         R1 = multiplier (m)
;         R2 = addr of B (m * A)
;--------------------------------------------

.= 0x2320

imath_mat_sc_mul:
   push idx             ; Save used registers
   push r4
   push r3

   clr idx

   ; Get rows
   ldx r3,[r0,idx]      ; r3 = A rows
   stx r3,[r2,idx]      ; B rows = A rows
   mov r3,r4            ; r4 = A rows

   ; Get cols
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   stx r3,[r2,idx]      ; B cols = A cols

   mul r3,r4,r4         ; r4 = 'A cols' * 'A rows' + 2 (matrix size)
   inc r4
   inc r4
   inc idx

imat_sc_mul_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   mul r1,r3,r3         ; r3 = m * A[i,j]
   stx r3,[r2,idx]      ; B[i,j] = m * A[i,j]
   inc idx
   cmp idx,r4           ; Finished ?
   jne imat_sc_mul_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   ret

;---------------------------------------------------
; Maths - Matrix Multiplication (int)
;
; Location: ROM addr 0x2350
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A * B)
;
; NB: This code is based on the auto-generated code
;     produced by compiling 'OS_Maths.rmg'
;---------------------------------------------------

.= 0x2350

imath_mat_mul:
   push r0     ; Save registers
   push r1
   push r2
   push r3
   push r4
   push idx
   push lr     ; Auto-generated code
   push fp
   push r2
   push r1
   push r0
   movsp fp
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   ldi r1,0
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi r1,1
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,0
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,1
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   clr r2
   cmp r0,r1
   jeq cond_imath_mat_mul_23
   inc r2
cond_imath_mat_mul_23:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_imath_mat_mul_21
   ldi r0,336
   call os_exit
if_imath_mat_mul_21:
   ldi idx,0
   ldx r0,[fp,idx]
   ldi idx,3
   ldx idx,[fp,idx]
   st r0,[idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,3
   ldx idx,[fp,idx]
   ldi r4,1
   add r4,idx,idx
   st r0,[idx]
   ldi r0,2
   ldi idx,-6
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-7
   stx r0,[fp,idx]
for_imath_mat_mul_24:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_imath_mat_mul_27
   clr r2
cond_imath_mat_mul_27:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_imath_mat_mul_26
   ldi r0,0
   ldi idx,-8
   stx r0,[fp,idx]
for_imath_mat_mul_29:
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_imath_mat_mul_32
   clr r2
cond_imath_mat_mul_32:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_imath_mat_mul_31
   ldi r0,2
   push r0
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi r0,2
   push r0
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-9
   stx r0,[fp,idx]
for_imath_mat_mul_34:
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_imath_mat_mul_37
   clr r2
cond_imath_mat_mul_37:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_imath_mat_mul_36
   ldi idx,-10
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,-5
   ldx r1,[fp,idx]
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
for_imath_mat_mul_35:
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-9
   stx r0,[fp,idx]
   jmp for_imath_mat_mul_34
for_imath_mat_mul_36:
   ldi idx,-10
   ldx r0,[fp,idx]
   ldi idx,3
   ldx idx,[fp,idx]
   push idx
   ldi idx,-6
   ldx r4,[fp,idx]
   pop idx
   add r4,idx,idx
   st r0,[idx]
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
for_imath_mat_mul_30:
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-8
   stx r0,[fp,idx]
   jmp for_imath_mat_mul_29
for_imath_mat_mul_31:
for_imath_mat_mul_25:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   jmp for_imath_mat_mul_24
for_imath_mat_mul_26:
   clr r0
ret_imath_mat_mul:
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Save registers
   pop r4
   pop r3
   pop r2
   pop r1
   pop r0
   ret

;------------------------------------
; Maths - Matrix Transposition (int)
;
; Location: ROM addr 0x2510
;
; Inputs: R0 = addr of A
;         R1 = addr of B (trans(A))
;------------------------------------

.= 0x2510

imath_mat_trans:
   push lr              ; Save used registers
   push fp
   push idx
   push r4
   push r3
   push r2

   ; Get B cols
   clr idx
   ldx r2,[r0,idx]      ; r2 = A rows
   mov r2,fp            ; fp = A rows
   inc idx
   stx r2,[r1,idx]      ; B cols = A rows

   ; Get B rows
   ldx r3,[r0,idx]      ; r3 = A cols
   mov r3,lr            ; lr = A cols
   dec idx
   stx r3,[r1,idx]      ; B rows = A cols

   mul r2,r3,r3         ; r3 = A size
   add r0,r3,r3
   ldi r4,2
   add r3,r4,r3         ; r3 = end addr of A plus 1

   add r0,r4,r0         ; r0 = A[0,0]
   add r1,r4,r1         ; r1 = B[0,0]

   clr idx              ; Initialise offsets
   clr r4

imat_trans_loop:
   ldx r2,[r0,idx]      ; r2 = a[i,j]
   stx r2,[r1,r4]       ; b[j,i] = a[i,j]
   add r4,fp,r4         ; r4 points to next b[j,i]
   inc idx
   cmp idx,lr           ; Finished row of A ?
   jne imat_trans_loop
   add r0,lr,r0         ; Update pointer for next row of A
   cmp r0,r3
   jeq imat_trans_done  ; Done all rows of A ?
   inc r1               ; Update pointer/offsets
   clr idx
   clr r4
   jmp imat_trans_loop

imat_trans_done:
   pop r2               ; Retrieve registers
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

;--------------------------------------
; Maths - Matrix Determinant 2x2 (int)
;
; Location: ROM addr 0x2550
;
; Inputs: R0 = addr of A
; Output: R0 = det(A)
;--------------------------------------

.= 0x2550

imath_mat_det_2:
   push idx             ; Save used registers
   push r4
   push r3
   push r2
   push r1

   ; Rows = 2 ?
   clr idx
   ldi r2,2
   ldx r1,[r0,idx]      ; r1 = A rows
   cmp r1,r2
   jeq imat_det2_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

imat_det2_cols:
   ; Cols = 2 ?
   inc idx
   ldx r1,[r0,idx]      ; r1 = A cols
   cmp r1,r2
   jeq imat_det2_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

imat_det2_start:
   inc idx              ; get 'a'
   add r0,idx,r0
   ld r1,[r0]
   inc r0

   ld r2,[r0]           ; get 'b'
   inc r0
   
   ld r3,[r0]           ; get 'c'
   inc r0
   
   ld r4,[r0]           ; get 'd'
   inc r0

   mul r1,r4,r1         ; r0 = ad - bc
   mul r2,r3,r2
   sub r1,r2,r0

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   ret

;--------------------------------------
; Maths - Matrix Determinant 3x3 (int)
;
; Location: ROM addr 0x2590
;
; Inputs: R0 = addr of A
; Output: R0 = det(A)
;--------------------------------------

.= 0x2590

imath_mat_det_3:
   push fp              ; Save used registers
   push idx
   push r3
   push r2
   push r1

   ; Rows = 3 ?
   clr idx
   ldi r2,3
   ldx r1,[r0,idx]      ; r1 = A rows
   cmp r1,r2
   jeq imat_det3_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

imat_det3_cols:
   ; Cols = 3 ?
   inc idx
   ldx r1,[r0,idx]      ; r1 = A cols
   cmp r1,r2
   jeq imat_det3_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

imat_det3_start:
   ldi r1,11             ; Put the elements on the stack: 'a b c d e f g h i'
   inc idx
imat_det3_load:
   ldx r2,[r0,idx]
   push r2
   inc idx
   cmp idx,r1
   jlt imat_det3_load

   movsp fp             ; Frame ptr points to the next empty stack position

   ldi idx,9            ; r1 = a
   ldx r1,[fp,idx]
   ldi idx,5            ; r2 = e
   ldx r2,[fp,idx]
   ldi idx,1            ; r3 = i
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = ae
   mul r2,r3,r0         ; r0 = aei

   ldi idx,9            ; r1 = a
   ldx r1,[fp,idx]
   ldi idx,4            ; r2 = f
   ldx r2,[fp,idx]
   ldi idx,2            ; r3 = h
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = af
   mul r2,r3,r1         ; r1 = afh
   sub r0,r1,r0         ; r0 = aei - afh

   ldi idx,8            ; r1 = b
   ldx r1,[fp,idx]
   ldi idx,6            ; r2 = d
   ldx r2,[fp,idx]
   ldi idx,1            ; r3 = i
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = bd
   mul r2,r3,r1         ; r1 = bdi
   sub r0,r1,r0         ; r0 = aei - afh - bdi

   ldi idx,8            ; r1 = b
   ldx r1,[fp,idx]
   ldi idx,4            ; r2 = f
   ldx r2,[fp,idx]
   ldi idx,3            ; r3 = g
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = bf
   mul r2,r3,r1         ; r1 = bfg
   add r0,r1,r0         ; r0 = aei - afh - bdi + bfg

   ldi idx,7            ; r1 = c
   ldx r1,[fp,idx]
   ldi idx,6            ; r2 = d
   ldx r2,[fp,idx]
   ldi idx,2            ; r3 = h
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = cd
   mul r2,r3,r1         ; r1 = cdh
   add r0,r1,r0         ; r0 = aei - afh - bdi + bfg + cdh

   ldi idx,7            ; r1 = c
   ldx r1,[fp,idx]
   ldi idx,5            ; r2 = e
   ldx r2,[fp,idx]
   ldi idx,3            ; r3 = g
   ldx r3,[fp,idx]
   mul r1,r2,r2         ; r2 = ce
   mul r2,r3,r1         ; r1 = ceg
   sub r0,r1,r0         ; r0 = aei - afh - bdi + bfg + cdh - ceg

   ldi r1,9             ; Clear the elements from the stack: 'i h g f e d c b a'
   clr idx

imat_det3_empty:
   pop r2
   inc idx
   cmp idx,r1
   jlt imat_det3_empty

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop idx
   pop fp
   ret

;----------------------------------------
; Maths - Complex Number Real Part (int)
;
; Location: ROM addr 0x2620
;
; Inputs: R0 = addr of x
; Output: R0 = Re(x)
;----------------------------------------

.= 0x2620

imath_cmplx_re:
   ld r0,[r0]           ; Get the real part
   ret

;---------------------------------------------
; Maths - Complex Number Imaginary Part (int)
;
; Location: ROM addr 0x2630
;
; Inputs: R0 = addr of x
; Output: R0 = Im(x)
;---------------------------------------------

.= 0x2630

imath_cmplx_im:
   inc r0               ; Get the imaginary part
   ld r0,[r0]
   ret

;----------------------------------------
; Maths - Complex Number Conjugate (int)
;
; Location: ROM addr 0x2640
;
; Inputs: R0 = addr of x (a + bi)
;         R1 = addr of y (a - bi)
;----------------------------------------

.= 0x2640

imath_cmplx_conj:
   push r2              ; Save used register

   ld r2,[r0]           ; Get the real part of x & store in y
   st r2,[r1]

   inc r0               ; Get the imaginary part of x
   ld r2,[r0]
   not r2,r2            ; Negate & store in y
   inc r2
   inc r1
   st r2,[r1]

   dec r0               ; Restore r0 & r1
   dec r1

   pop r2               ; Retrieve register
   ret

;---------------------------------------
; Maths - Complex Number Addition (int)
;
; Location: ROM addr 0x2660
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x + y)
;---------------------------------------

.= 0x2660

imath_cmplx_add:
   push r4              ; Save used registers
   push r3

   ld r3,[r0]           ; Get the real parts of x & y
   ld r4,[r1]
   add r3,r4,r4         ; Add & store in z
   st r4,[r2]

   inc r0               ; Get the imaginary parts of x & y
   ld r3,[r0]
   inc r1
   ld r4,[r1]
   add r3,r4,r4         ; Add & store in z
   inc r2
   st r4,[r2]

   dec r0               ; Restore r0, r1 & r2
   dec r1
   dec r2

   pop r3               ; Retrieve registers
   pop r4
   ret

;------------------------------------------
; Maths - Complex Number Subtraction (int)
;
; Location: ROM addr 0x2680
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x - y)
;------------------------------------------

.= 0x2680

imath_cmplx_sub:
   push r4              ; Save used registers
   push r3

   ld r3,[r0]           ; Get the real parts of x & y
   ld r4,[r1]
   sub r3,r4,r4         ; Subtract & store in z
   st r4,[r2]

   inc r0               ; Get the imaginary parts of x & y
   ld r3,[r0]
   inc r1
   ld r4,[r1]
   sub r3,r4,r4         ; Subtract & store in z
   inc r2
   st r4,[r2]

   dec r0               ; Restore r0, r1 & r2
   dec r1
   dec r2

   pop r3               ; Retrieve registers
   pop r4
   ret

;----------------------------------------------------
; Maths - Complex Number Scalar Multiplication (int)
;
; Location: ROM addr 0x26a0
;
; Inputs: R0 = addr of x
;         R1 = multiplier (m)
;         R2 = addr of y (m * x)
;----------------------------------------------------

.= 0x26a0

imath_cmplx_sc_mul:
   push r3              ; Save used register

   ld r3,[r0]           ; Get the real part of x
   mul r1,r3,r3         ; Multiply & store in y
   st r3,[r2]

   inc r0               ; Get the imaginary part of x
   ld r3,[r0]
   mul r1,r3,r3         ; Multiply & store in y
   inc r2
   st r3,[r2]

   dec r0               ; Restore r0 & r2
   dec r2

   pop r3               ; Retrieve register
   ret

;---------------------------------------------
; Maths - Complex Number Multiplication (int)
;
; Location: ROM addr 0x26c0
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x * y)
;---------------------------------------------

.= 0x26c0

imath_cmplx_mul:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   push r0              ; Save r0, r1 & r2
   push r1
   push r2

   ld r3,[r0]           ; Get the real & imaginary parts of x
   inc r0
   ld r4,[r0]

   ld idx,[r1];         ; Get the real & imaginary parts of y
   inc r1
   ld fp,[r1]

   mul r3,idx,r0        ; Calculate & store the real part of z
   mul r4,fp,r1
   sub r0,r1,r0
   st r0,[r2]

   mul r4,idx,r0        ; Calculate & store the imaginary part of z
   mul r3,fp,r1
   add r0,r1,r0
   inc r2
   st r0,[r2]

   pop r2               ; Restore r0, r1 & r2
   pop r1
   pop r0

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;--------------------------------
; Maths - Absolute Value (float)
;
; Location: ROM addr 0x26f0
;
; Inputs: R0 = val
; Output: R0 = abs(val)
;--------------------------------

.= 0x26f0

fmath_abs:
   push r1              ; Save used register

   ldi r1,0x7fff        ; Clear the sign bit
   and r0,r1,r0

   pop r1               ; Retrieve register
   ret

;--------------------------------
; Maths - Exponentiation (float)
;
; Location: ROM addr 0x2700
;
; Inputs: R0 = x
;         R1 = n
; Output: R0 = x^n
;--------------------------------

.= 0x2700

fmath_pow:
   push r3              ; Save used registers
   push r2
   push r1

   clr r3               ; Clear the division flag

   clr r2               ; Is it 0^0 ? If so it's undefined
   cmp r0,r2
   jne fpow_test_n
   cmp r1,r2
   jne fpow_test_n

   jmp POW_UNDEF        ; If it's 0^0 display the error code

fpow_test_n:
   cmp r1,r2
   jgt fpow_init        ; Is n > 0 ? If so start the multiplication loop
   jeq fpow_ret_1       ; Is n = 0 ? If so return 1.0

   inc r3               ; n < 0: Set the division flag &
   not r1,r1            ;        Neagte n
   inc r1

fpow_init:
   mov r0,r2            ; r2 = x

fpow_loop:
   dec r1               ; Multiply x by itself n times
   jz fpow_div   
   fmul r0,r2,r0
   jmp fpow_loop

fpow_div:
   clr r2               ; Is the division flag set ?
   cmp r2,r3
   jeq fpow_done        ; If not return the 'multiplication result'

   ldi r2,1.0           ; Division flag set - Return the 
   fdiv r2,r0,r0        ; reciprocal of the 'multiplication result'
   jmp fpow_done

fpow_ret_1:
   ldi r0,1.0

fpow_done:
   pop r1               ; Retrieve registers
   pop r2
   pop r3
   ret

;-----------------------------
; Maths - Square Root (float)
;
; Location: ROM addr 0x2740
;
; Inputs: R0 = x
; Output: R0 = sqrt(x)
;-----------------------------

.= 0x2740

fmath_sqrt:
   fsqrt r0,r0
   ret

;-----------------------------
; Maths - Sin (float)
;
; Location: ROM addr 0x2750
;
; Inputs: R0 = x (in degrees)
; Output: R0 = sin(x)
;-----------------------------

.= 0x2750

fmath_sin:
   push r3              ; Save used registers
   push r4

   ldi r3,0x8000
   ldi r4,-360.0
ms_in_range_1:          ; Keep increasing x by 360 until x >= 0
   and r0,r3,r3 
   jz ms_in_range_2     ; If so: x >= 0 
   fsub r0,r4,r0
   jmp ms_in_range_1

ms_in_range_2:
   ldi r4,360.0
ms_in_range_3:          ; Keep decreasing x by 360 until x < 360
   cmp r0,r4
   jlt ms_quad_4        ; If so: 0 <= x < 360  
   fsub r0,r4,r0
   jmp ms_in_range_3

ms_quad_4:      
   ldi r4,270.0         ; Is x in quadrant 4 ?
   cmp r0,r4
   jle ms_quad_3
   ldi r4,360.0         ; In quadrant 4
   fsub r4,r0,r0        ; r0 = 360 - x
   fsin r0,r0           ; r0 = sin(360-x)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -sin(360-x)
   jmp ms_done

ms_quad_3:
   ldi r4,180.0         ; Is x in quadrant 3 ?
   cmp r0,r4
   jle ms_quad_2
   fsub r0,r4,r0        ; In quadrant 3: r0 = x - 180
   fsin r0,r0           ; r0 = sin(x-180)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -sin(x-180)
   jmp ms_done 

ms_quad_2:
   ldi r4,90.0          ; Is x in quadrant 2 ?
   cmp r0,r4
   jle ms_quad_1
   ldi r4,180.0         ; In quadrant 2
   fsub r4,r0,r0        ; r0 = 180 - x
   fsin r0,r0           ; Return: sin(180-x)
   jmp ms_done

ms_quad_1:
   fsin r0,r0           ; In quadrant 1: Return: sin(x)

ms_done:
   pop r4               ; Restore registers & return
   pop r3
   ret

;-----------------------------
; Maths - Cos (float)
;
; Location: ROM addr 0x27a0
;
; Inputs: R0 = x (in degrees)
; Output: R0 = cos(x)
;-----------------------------

.= 0x27a0

fmath_cos:
   push r3              ; Save used registers
   push r4

   ldi r3,0x8000
   ldi r4,-360.0
mc_in_range_1:          ; Keep increasing x by 360 until x >= 0
   and r0,r3,r3 
   jz mc_in_range_2     ; If so: x >= 0 
   fsub r0,r4,r0
   jmp mc_in_range_1

mc_in_range_2:
   ldi r4,360.0
mc_in_range_3:          ; Keep decreasing x by 360 until x < 360
   cmp r0,r4
   jlt mc_quad_4        ; If so: 0 <= x < 360  
   fsub r0,r4,r0
   jmp mc_in_range_3

mc_quad_4:      
   ldi r4,270.0         ; Is x in quadrant 4 ?
   cmp r0,r4
   jle mc_quad_3
   ldi r4,360.0         ; In quadrant 4
   fsub r4,r0,r0        ; r0 = 360 - x
   fcos r0,r0           ; Return: cos(360-x)
   jmp mc_done

mc_quad_3:
   ldi r4,180.0         ; Is x in quadrant 3 ?
   cmp r0,r4
   jle mc_quad_2
   fsub r0,r4,r0        ; In quadrant 3: r0 = x - 180
   fcos r0,r0           ; r0 = cos(x-180)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -cos(x-180)
   jmp mc_done 

mc_quad_2:
   ldi r4,90.0          ; Is x in quadrant 2 ?
   cmp r0,r4
   jle mc_quad_1
   ldi r4,180.0         ; In quadrant 2
   fsub r4,r0,r0        ; r0 = 180 - x
   fcos r0,r0           ; r0 = cos(180-x)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -cos(x-180)
   jmp mc_done

mc_quad_1:
   fcos r0,r0           ; In quadrant 1: Return: cos(x)

mc_done:
   pop r4               ; Restore registers & return
   pop r3
   ret

;-----------------------------
; Maths - Tan (float)
;
; Location: ROM addr 0x27f0
;
; Inputs: R0 = x (in degrees)
; Output: R0 = tan(x)
;-----------------------------

.= 0x27f0

fmath_tan:
   push r3              ; Save used registers
   push r4

   ldi r3,0x8000
   ldi r4,-360.0
mt_in_range_1:          ; Keep increasing x by 360 until x >= 0
   and r0,r3,r3 
   jz mt_in_range_2     ; If so: x >= 0 
   fsub r0,r4,r0
   jmp mt_in_range_1

mt_in_range_2:
   ldi r4,360.0
mt_in_range_3:          ; Keep decreasing x by 360 until x < 360
   cmp r0,r4
   jlt mt_quad_4        ; If so: 0 <= x < 360  
   fsub r0,r4,r0
   jmp mt_in_range_3

mt_quad_4:      
   ldi r4,270.0         ; Is x in quadrant 4 ?
   cmp r0,r4
   jle mt_quad_3
   ldi r4,360.0         ; In quadrant 4
   fsub r4,r0,r0        ; r0 = 360 - x
   ftan r0,r0           ; r0 = tan(360-x)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -tan(x-180)
   jmp mt_done

mt_quad_3:
   ldi r4,180.0         ; Is x in quadrant 3 ?
   cmp r0,r4
   jle mt_quad_2
   fsub r0,r4,r0        ; In quadrant 3: r0 = x - 180
   ftan r0,r0           ; Return: tan(x-180)
   jmp mt_done 

mt_quad_2:
   ldi r4,90.0          ; Is x in quadrant 2 ?
   cmp r0,r4
   jle mt_quad_1
   ldi r4,180.0         ; In quadrant 2
   fsub r4,r0,r0        ; r0 = 180 - x
   ftan r0,r0           ; r0 = tan(180-x)
   ldi r3,0x8000
   or r0,r3,r0          ; Return: -tan(x-180)
   jmp mt_done

mt_quad_1:
   ftan r0,r0           ; In quadrant 1: Return: tan(x)

mt_done:
   pop r4               ; Restore registers & return
   pop r3
   ret

;---------------------------------
; Maths - Vector Addition (float)
;
; Location: ROM addr 0x2840
;
; Inputs: R0 = addr of a
;         R1 = addr of b
;         R2 = addr of c (a + b)
;---------------------------------

.= 0x2840

fmath_vec_add:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows both = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldx r4,[r1,idx]      ; r4 = b rows
   cmp r3,r4
   jeq fvec_add_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

fvec_add_1_row:
   ldi r4,1
   cmp r3,r4
   jeq fvec_add_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

fvec_add_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; c rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   ldx r4,[r1,idx]      ; r4 = b cols
   cmp r3,r4
   jeq fvec_add_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

fvec_add_start:
   stx r3,[r2,idx]      ; c cols = a cols
   mov r3,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx

fvec_add_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   ldx r4,[r1,idx]      ; r4 = b[i]
   fadd r3,r4,r4        ; r4 = a[i] + b[i]
   stx r4,[r2,idx]      ; c[i] = a[i] + b[i]
   inc idx
   cmp idx,fp           ; Finished ?
   jne fvec_add_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;------------------------------------
; Maths - Vector Subtraction (float)
;
; Location: ROM addr 0x2880
;
; Inputs: R0 = addr of a
;         R1 = addr of b
;         R2 = addr of c (a - b)
;------------------------------------

.= 0x2880

fmath_vec_sub:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows both = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldx r4,[r1,idx]      ; r4 = b rows
   cmp r3,r4
   jeq fvec_sub_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

fvec_sub_1_row:
   ldi r4,1
   cmp r3,r4
   jeq fvec_sub_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

fvec_sub_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; c rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   ldx r4,[r1,idx]      ; r4 = b cols
   cmp r3,r4
   jeq fvec_sub_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

fvec_sub_start:
   stx r3,[r2,idx]      ; c cols = a cols
   mov r3,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx

fvec_sub_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   ldx r4,[r1,idx]      ; r4 = b[i]
   fsub r3,r4,r4        ; r4 = a[i] - b[i]
   stx r4,[r2,idx]      ; c[i] = a[i] - b[i]
   inc idx
   cmp idx,fp           ; Finished ?
   jne fvec_sub_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;----------------------------------------------
; Maths - Vector Scalar Multiplication (float)
;
; Location: ROM addr 0x28c0
;
; Inputs: R0 = addr of a
;         R1 = multiplier (m)
;         R2 = addr of b (m * a)
;----------------------------------------------

.= 0x28c0

fmath_vec_sc_mul:
   push idx             ; Save used registers
   push r4
   push r3
   
   clr idx

   ; Rows = 1 ?
   ldx r3,[r0,idx]      ; r3 = a rows
   ldi r4,1
   cmp r3,r4
   jeq fvec_sc_mul_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

fvec_sc_mul_cols:
   ; Get cols
   stx r3,[r2,idx]      ; b rows = a rows
   inc idx
   ldx r3,[r0,idx]      ; r3 = a cols
   stx r3,[r2,idx]      ; b cols = a cols
   mov r3,r4            ; r4 = 'a cols' + 2 (vector length)
   inc r4
   inc r4
   inc idx

fvec_sc_mul_loop:
   ldx r3,[r0,idx]      ; r3 = a[i]
   fmul r1,r3,r3        ; r3 = m * a[i]
   stx r3,[r2,idx]      ; b[i] = m * a[i]
   inc idx
   cmp idx,r4           ; Finished ?
   jne fvec_sc_mul_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   ret

;-----------------------------
; Maths - Dot Product (float)
;
; Location: ROM addr 0x28f0
;
; Inputs: R0 = addr of a
;         R1 = addr of b
; Output: R0 = a.b
;-----------------------------

.= 0x28f0

fmath_vec_dot_prod:
   push fp              ; Save used registers
   push idx
   push r4
   push r3
   push r2

   ; Rows both = 1 ?
   clr idx
   ldx r2,[r0,idx]      ; r2 = a rows
   ldx r3,[r1,idx]      ; r3 = b rows
   cmp r2,r3
   jeq fvec_dp_1_row

   jmp BAD_VEC_DIMS     ; Rows mismatch

fvec_dp_1_row:
   ldi r4,1
   cmp r2,r4
   jeq fvec_dp_cols

   jmp BAD_VEC_DIMS     ; Not 1 row

fvec_dp_cols:
   ; Cols equal ?
   inc idx
   ldx r2,[r0,idx]      ; r2 = a cols
   ldx r3,[r1,idx]      ; r3 = b cols
   cmp r2,r3
   jeq fvec_dp_start

   jmp BAD_VEC_DIMS     ; Cols mismatch

fvec_dp_start:
   mov r2,fp            ; fp = 'a cols' + 2 (vector length)
   inc fp
   inc fp
   inc idx
   clr r4

fvec_dp_loop:
   ldx r2,[r0,idx]      ; r2 = a[i]
   ldx r3,[r1,idx]      ; r3 = b[i]
   fmul r2,r3,r3        ; r3 = a[i] * b[i]
   fadd r3,r4,r4        ; fp = sum of 'a[i] * b[i]'s
   inc idx
   cmp idx,fp           ; Finished ?
   jne fvec_dp_loop

   mov r4,r0            ; Put the result in r0
   
   pop r2               ; Retrieve registers
   pop r3
   pop r4
   pop idx
   pop fp
   ret

;---------------------------------
; Maths - Matrix Addition (float)
;
; Location: ROM addr 0x2930
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A + B)
;---------------------------------

.= 0x2930

fmath_mat_add:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows equal ?
   ldx r3,[r0,idx]      ; r3 = A rows
   ldx r4,[r1,idx]      ; r4 = B rows
   cmp r3,r4
   jeq fmat_add_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

fmat_add_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; C rows = A rows
   mov r3,fp            ; fp = 'A rows'
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   ldx r4,[r1,idx]      ; r4 = B cols
   cmp r3,r4
   jeq fmat_add_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

fmat_add_start:
   stx r3,[r2,idx]      ; C cols = A cols
   mul r3,fp,fp         ; fp = 'A cols' * 'A rows' + 2 (matrix size)
   inc fp
   inc fp
   inc idx

fmat_add_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   ldx r4,[r1,idx]      ; r4 = B[i,j]
   fadd r3,r4,r4        ; r4 = A[i,j] + B[i,j]
   stx r4,[r2,idx]      ; C[i,j] = A[i,j] + B[i,j]
   inc idx
   cmp idx,fp           ; Finished ?
   jne fmat_add_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;------------------------------------
; Maths - Matrix Subtraction (float)
;
; Location: ROM addr 0x2970
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A - B)
;------------------------------------

.= 0x2970

fmath_mat_sub:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx

   ; Rows equal ?
   ldx r3,[r0,idx]      ; r3 = A rows
   ldx r4,[r1,idx]      ; r4 = B rows
   cmp r3,r4
   jeq fmat_sub_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

fmat_sub_cols:
   ; Cols equal ?
   stx r3,[r2,idx]      ; C rows = A rows
   mov r3,fp            ; fp = 'A rows'
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   ldx r4,[r1,idx]      ; r4 = B cols
   cmp r3,r4
   jeq fmat_sub_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

fmat_sub_start:
   stx r3,[r2,idx]      ; C cols = A cols
   mul r3,fp,fp         ; fp = 'A cols' * 'A rows' + 2 (matrix size)
   inc fp
   inc fp
   inc idx

fmat_sub_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   ldx r4,[r1,idx]      ; r4 = B[i,j]
   fsub r3,r4,r4        ; r4 = A[i,j] - B[i,j]
   stx r4,[r2,idx]      ; C[i,j] = A[i,j] - B[i,j]
   inc idx
   cmp idx,fp           ; Finished ?
   jne fmat_sub_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;----------------------------------------------
; Maths - Matrix Scalar Multiplication (float)
;
; Location: ROM addr 0x29b0
;
; Inputs: R0 = addr of A
;         R1 = multiplier (m)
;         R2 = addr of B (m * A)
;----------------------------------------------

.= 0x29b0

fmath_mat_sc_mul:
   push idx             ; Save used registers
   push r4
   push r3

   clr idx

   ; Get rows
   ldx r3,[r0,idx]      ; r3 = A rows
   stx r3,[r2,idx]      ; B rows = A rows
   mov r3,r4            ; r4 = A rows

   ; Get cols
   inc idx
   ldx r3,[r0,idx]      ; r3 = A cols
   stx r3,[r2,idx]      ; B cols = A cols

   mul r3,r4,r4         ; r4 = 'A cols' * 'A rows' + 2 (matrix size)
   inc r4
   inc r4
   inc idx

fmat_sc_mul_loop:
   ldx r3,[r0,idx]      ; r3 = A[i,j]
   fmul r1,r3,r3        ; r3 = m * A[i,j]
   stx r3,[r2,idx]      ; B[i,j] = m * A[i,j]
   inc idx
   cmp idx,r4           ; Finished ?
   jne fmat_sc_mul_loop

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   ret

;---------------------------------------------------
; Maths - Matrix Multiplication (float)
;
; Location: ROM addr 0x29e0
;
; Inputs: R0 = addr of A
;         R1 = addr of B
;         R2 = addr of C (A * B)
;
; NB: This code is based on the auto-generated code
;     produced by compiling 'OS_Maths.rmg'
;---------------------------------------------------

.= 0x29e0

fmath_mat_mul:
   push r0     ; Save registers
   push r1
   push r2
   push r3
   push r4
   push idx
   push lr     ; Auto-generated code
   push fp
   push r2
   push r1
   push r0
   movsp fp
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   clr r0
   push r0
   ldi idx,0
   add fp,idx,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi r1,0
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-10
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-1
   add fp,idx,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi r1,1
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-10
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-2
   add fp,idx,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,0
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-10
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-3
   add fp,idx,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,1
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-10
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   clr r2
   cmp r0,r1
   jeq cond_fmath_mat_mul_41
   inc r2
cond_fmath_mat_mul_41:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_fmath_mat_mul_39
   ldi r0,336
   call os_exit
if_fmath_mat_mul_39:
   ldi idx,3
   ldx r0,[fp,idx]
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-11
   add fp,idx,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-10
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,0
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,-11
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi idx,-11
   ldx r0,[fp,idx]
   ldi idx,-3
   ldx r1,[fp,idx]
   call os_mem_set
   ldi r0,2
   ldi idx,-6
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-7
   stx r0,[fp,idx]
for_fmath_mat_mul_42:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_fmath_mat_mul_45
   clr r2
cond_fmath_mat_mul_45:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_fmath_mat_mul_44
   ldi r0,0
   ldi idx,-8
   stx r0,[fp,idx]
for_fmath_mat_mul_47:
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_fmath_mat_mul_50
   clr r2
cond_fmath_mat_mul_50:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_fmath_mat_mul_49
   ldi r0,2
   push r0
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi r0,2
   push r0
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-9
   stx r0,[fp,idx]
for_fmath_mat_mul_52:
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_fmath_mat_mul_55
   clr r2
cond_fmath_mat_mul_55:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_fmath_mat_mul_54
   ldi idx,-10
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,-5
   ldx r1,[fp,idx]
   add r0,r1,r0
   mov r0,r1
   ld r0,[r1]
   push r0
   pop r1
   pop r0
   fmul r0,r1,r0
   push r0
   pop r1
   pop r0
   fadd r0,r1,r0
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
for_fmath_mat_mul_53:
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-9
   stx r0,[fp,idx]
   jmp for_fmath_mat_mul_52
for_fmath_mat_mul_54:
   ldi idx,-10
   ldx r0,[fp,idx]
   ldi idx,3
   ldx idx,[fp,idx]
   push idx
   ldi idx,-6
   ldx r4,[fp,idx]
   pop idx
   add r4,idx,idx
   st r0,[idx]
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
for_fmath_mat_mul_48:
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-8
   stx r0,[fp,idx]
   jmp for_fmath_mat_mul_47
for_fmath_mat_mul_49:
for_fmath_mat_mul_43:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   jmp for_fmath_mat_mul_42
for_fmath_mat_mul_44:
   clr r0
ret_fmath_mat_mul:
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Save registers
   pop r4
   pop r3
   pop r2
   pop r1
   pop r0
   ret

;--------------------------------------
; Maths - Matrix Transposition (float)
;
; Location: ROM addr 0x2bf0
;
; Inputs: R0 = addr of A
;         R1 = addr of B (trans(A))
;--------------------------------------

.= 0x2bf0

fmath_mat_trans:
   push lr
   call imath_mat_trans
   pop lr
   ret
 
;----------------------------------------
; Maths - Matrix Determinant 2x2 (float)
;
; Location: ROM addr 0x2c10
;
; Inputs: R0 = addr of A
; Output: R0 = det(A)
;----------------------------------------

.= 0x2c10

fmath_mat_det_2:
   push idx             ; Save used registers
   push r4
   push r3
   push r2
   push r1

   ; Rows = 2 ?
   clr idx
   ldi r2,2
   ldx r1,[r0,idx]      ; r1 = A rows
   cmp r1,r2
   jeq fmat_det2_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

fmat_det2_cols:
   ; Cols = 2 ?
   inc idx
   ldx r1,[r0,idx]      ; r1 = A cols
   cmp r1,r2
   jeq fmat_det2_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

fmat_det2_start:
   inc idx              ; get 'a'
   add r0,idx,r0
   ld r1,[r0]
   inc r0

   ld r2,[r0]           ; get 'b'
   inc r0
   
   ld r3,[r0]           ; get 'c'
   inc r0
   
   ld r4,[r0]           ; get 'd'
   inc r0

   fmul r1,r4,r1         ; r0 = ad - bc
   fmul r2,r3,r2
   fsub r1,r2,r0

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   ret

;----------------------------------------
; Maths - Matrix Determinant 3x3 (float)
;
; Location: ROM addr 0x2c50
;
; Inputs: R0 = addr of A
; Output: R0 = det(A)
;----------------------------------------

.= 0x2c50

fmath_mat_det_3:
   push fp              ; Save used registers
   push idx
   push r3
   push r2
   push r1

   ; Rows = 3 ?
   clr idx
   ldi r2,3
   ldx r1,[r0,idx]      ; r1 = A rows
   cmp r1,r2
   jeq fmat_det3_cols

   jmp BAD_MAT_DIMS     ; Rows mismatch

fmat_det3_cols:
   ; Cols = 3 ?
   inc idx
   ldx r1,[r0,idx]      ; r1 = A cols
   cmp r1,r2
   jeq fmat_det3_start

   jmp BAD_MAT_DIMS     ; Cols mismatch

fmat_det3_start:
   ldi r1,11             ; Put the elements on the stack: 'a b c d e f g h i'
   inc idx
fmat_det3_load:
   ldx r2,[r0,idx]
   push r2
   inc idx
   cmp idx,r1
   jlt fmat_det3_load

   movsp fp             ; Frame ptr points to the next empty stack position

   ldi idx,9            ; r1 = a
   ldx r1,[fp,idx]
   ldi idx,5            ; r2 = e
   ldx r2,[fp,idx]
   ldi idx,1            ; r3 = i
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = ae
   fmul r2,r3,r0         ; r0 = aei

   ldi idx,9            ; r1 = a
   ldx r1,[fp,idx]
   ldi idx,4            ; r2 = f
   ldx r2,[fp,idx]
   ldi idx,2            ; r3 = h
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = af
   fmul r2,r3,r1         ; r1 = afh
   fsub r0,r1,r0         ; r0 = aei - afh

   ldi idx,8            ; r1 = b
   ldx r1,[fp,idx]
   ldi idx,6            ; r2 = d
   ldx r2,[fp,idx]
   ldi idx,1            ; r3 = i
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = bd
   fmul r2,r3,r1         ; r1 = bdi
   fsub r0,r1,r0         ; r0 = aei - afh - bdi

   ldi idx,8            ; r1 = b
   ldx r1,[fp,idx]
   ldi idx,4            ; r2 = f
   ldx r2,[fp,idx]
   ldi idx,3            ; r3 = g
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = bf
   fmul r2,r3,r1         ; r1 = bfg
   fadd r0,r1,r0         ; r0 = aei - afh - bdi + bfg

   ldi idx,7            ; r1 = c
   ldx r1,[fp,idx]
   ldi idx,6            ; r2 = d
   ldx r2,[fp,idx]
   ldi idx,2            ; r3 = h
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = cd
   fmul r2,r3,r1         ; r1 = cdh
   fadd r0,r1,r0         ; r0 = aei - afh - bdi + bfg + cdh

   ldi idx,7            ; r1 = c
   ldx r1,[fp,idx]
   ldi idx,5            ; r2 = e
   ldx r2,[fp,idx]
   ldi idx,3            ; r3 = g
   ldx r3,[fp,idx]
   fmul r1,r2,r2         ; r2 = ce
   fmul r2,r3,r1         ; r1 = ceg
   fsub r0,r1,r0         ; r0 = aei - afh - bdi + bfg + cdh - ceg

   ldi r1,9             ; Clear the elements from the stack: 'i h g f e d c b a'
   clr idx

fmat_det3_empty:
   pop r2
   inc idx
   cmp idx,r1
   jlt fmat_det3_empty

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop idx
   pop fp
   ret

;------------------------------------------
; Maths - Complex Number Real Part (float)
;
; Location: ROM addr 0x2ce0
;
; Inputs: R0 = addr of x
; Output: R0 = Re(x)
;------------------------------------------

.= 0x2ce0

fmath_cmplx_re:
   ld r0,[r0]           ; Get the real part
   ret

;-----------------------------------------------
; Maths - Complex Number Imaginary Part (float)
;
; Location: ROM addr 0x2cf0
;
; Inputs: R0 = addr of x
; Output: R0 = Im(x)
;-----------------------------------------------

.= 0x2cf0

fmath_cmplx_im:
   inc r0               ; Get the imaginary part
   ld r0,[r0]
   ret

;------------------------------------------
; Maths - Complex Number Conjugate (float)
;
; Location: ROM addr 0x2d00
;
; Inputs: R0 = addr of x (a + bi)
;         R1 = addr of y (a - bi)
;------------------------------------------

.= 0x2d00

fmath_cmplx_conj:
   push r2              ; Save used registers
   push r3

   ld r2,[r0]           ; Get the real part of x & store in y
   st r2,[r1]

   inc r0               ; Get the imaginary part of x
   ld r2,[r0]
   ldi r3,0x8000        ; Negate & store in y
   xor r2,r3,r2
   inc r1
   st r2,[r1]

   dec r0               ; Restore r0 & r1
   dec r1

   pop r3               ; Retrieve registers
   pop r2
   ret

;-----------------------------------------
; Maths - Complex Number Addition (float)
;
; Location: ROM addr 0x2d20
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x + y)
;-----------------------------------------

.= 0x2d20

fmath_cmplx_add:
   push r4              ; Save used registers
   push r3

   ld r3,[r0]           ; Get the real parts of x & y
   ld r4,[r1]
   fadd r3,r4,r4        ; Add & store in z
   st r4,[r2]

   inc r0               ; Get the imaginary parts of x & y
   ld r3,[r0]
   inc r1
   ld r4,[r1]
   fadd r3,r4,r4        ; Add & store in z
   inc r2
   st r4,[r2]

   dec r0               ; Restore r0, r1 & r2
   dec r1
   dec r2

   pop r3               ; Retrieve registers
   pop r4
   ret

;--------------------------------------------
; Maths - Complex Number Subtraction (float)
;
; Location: ROM addr 0x2d50
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x - y)
;--------------------------------------------

.= 0x2d50

fmath_cmplx_sub:
   push r4              ; Save used registers
   push r3

   ld r3,[r0]           ; Get the real parts of x & y
   ld r4,[r1]
   fsub r3,r4,r4        ; Subtract & store in z
   st r4,[r2]

   inc r0               ; Get the imaginary parts of x & y
   ld r3,[r0]
   inc r1
   ld r4,[r1]
   fsub r3,r4,r4        ; Subtract & store in z
   inc r2
   st r4,[r2]

   dec r0               ; Restore r0, r1 & r2
   dec r1
   dec r2

   pop r3               ; Retrieve registers
   pop r4
   ret

;------------------------------------------------------
; Maths - Complex Number Scalar Multiplication (float)
;
; Location: ROM addr 0x2d80
;
; Inputs: R0 = addr of x
;         R1 = multiplier (m)
;         R2 = addr of y (m * x)
;------------------------------------------------------

.= 0x2d80

fmath_cmplx_sc_mul:
   push r3              ; Save used register

   ld r3,[r0]           ; Get the real part of x
   fmul r1,r3,r3        ; Multiply & store in y
   st r3,[r2]

   inc r0               ; Get the imaginary part of x
   ld r3,[r0]
   fmul r1,r3,r3        ; Multiply & store in y
   inc r2
   st r3,[r2]

   dec r0               ; Restore r0 & r2
   dec r2

   pop r3               ; Retrieve register
   ret

;-----------------------------------------------
; Maths - Complex Number Multiplication (float)
;
; Location: ROM addr 0x2da0
;
; Inputs: R0 = addr of x
;         R1 = addr of y
;         R2 = addr of z (x * y)
;-----------------------------------------------

.= 0x2da0

fmath_cmplx_mul:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   push r0              ; Save r0, r1 & r2
   push r1
   push r2

   ld r3,[r0]           ; Get the real & imaginary parts of x
   inc r0
   ld r4,[r0]

   ld idx,[r1];         ; Get the real & imaginary parts of y
   inc r1
   ld fp,[r1]

   fmul r3,idx,r0       ; Calculate & store the real part of z
   fmul r4,fp,r1
   fsub r0,r1,r0
   st r0,[r2]

   fmul r4,idx,r0       ; Calculate & store the imaginary part of z
   fmul r3,fp,r1
   fadd r0,r1,r0
   inc r2
   st r0,[r2]

   pop r2               ; Restore r0, r1 & r2
   pop r1
   pop r0

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;--------------------------------------------------------
; Maths - Exp (float)
; 
; Location: ROM addr 0x2dd0
;
; Input:  r0 - n
; Output: r0 - Exp(n)
;
; This uses the Taylor Series - See 'Taylor_Exp.py'
;
; NB - Valid results for inputs in range: -2.5 < x < 2.5
;--------------------------------------------------------

.= 0x2dd0

fmath_exp:
   push lr           ; Save the used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1

   ldi  r1,1.0       ; r1 = 1.0 (pow)
   ldi  r2,1.0       ; r2 = 1.0 (fact)
   ldi  r3,1.0       ; r3 = 1.0 (res)
   ldi  r4,1.0       ; r4 = 1.0 (f)

   ldi fp,7          ; Initialise loop counter
   ldi idx,1

exp_loop:
   cmp idx,fp        ; Loop ended ?
   jeq exp_done

   fmul r1,r0,r1     ; pow *= x
   fmul r2,r4,r2     ; fact *= f 
   fdiv r1,r2,lr     ; res += (pow / fact)
   fadd r3,lr,r3
   ldi lr,1.0        ; f += 1.0
   fadd r4,lr,r4
   
   inc idx
   jmp exp_loop

exp_done:
   mov r3,r0         ; r0 = res

   pop r1            ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

;--------------------------------------------------------
; Maths - Ln (float)
; 
; Location: ROM addr 0x2e10
;
; Input:  r0 - n
; Output: r0 - Ln(n)
;
; This uses the Taylor Series - See 'Taylor_Ln.py'
;
; NB - Valid results for inputs in range: 0.05 < x < 5.0
;--------------------------------------------------------

.= 0x2e10

fmath_ln:
   push lr           ; Save the used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1

   clr r1            ; r1 = 0.0 (res)
   ldi r2,1.0        ; r2 = 1.0 (div)

   ldi lr,1.0        ; r3 = (x - 1.0) / (x + 1.0) (mult)
   fsub r0,lr,r3
   fadd r0,lr,r4
   fdiv r3,r4,r3

   mov r3,r4         ; r4 = mult (pow)
   fmul r3,r3,r3     ; r3 = mult * mult (mult2)

   ldi fp,4          ; Initialise loop counter
   ldi idx,1

ln_loop:
   cmp idx,fp        ; Loop ended ?
   jeq ln_done

   fdiv r4,r2,lr     ; res += (pow / div)
   fadd r1,lr,r1
   fmul r4,r3,r4     ; pow *= mult2
   ldi lr,2.0        ; div += 2.0
   fadd r2,lr,r2

   inc idx
   jmp ln_loop

ln_done:
   mov r1,r0         ; r0 = 2.0 * res
   fadd r0,r0,r0

   pop r1            ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

