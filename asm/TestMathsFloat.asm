
;--------------------------------
; Test the 'float' Maths Library
;--------------------------------

.RAM

; Maths Library Defines
.equ fmath_abs          0x26f0
.equ fmath_pow          0x2700
.equ fmath_sqrt         0x2740
.equ fmath_sin          0x2750
.equ fmath_cos          0x27a0
.equ fmath_tan          0x27f0

.equ fmath_vec_add      0x2840
.equ fmath_vec_sub      0x2880
.equ fmath_vec_sc_mul   0x28c0
.equ fmath_vec_dot_prod 0x28f0

.equ fmath_mat_add      0x2930
.equ fmath_mat_sub      0x2970
.equ fmath_mat_sc_mul   0x29b0
.equ fmath_mat_mul      0x29e0
.equ fmath_mat_trans    0x2bf0
.equ fmath_mat_det_2    0x2c10
.equ fmath_mat_det_3    0x2c50

.equ fmath_cmplx_re     0x2ce0
.equ fmath_cmplx_im     0x2cf0
.equ fmath_cmplx_conj   0x2d00
.equ fmath_cmplx_add    0x2d20
.equ fmath_cmplx_sub    0x2d50
.equ fmath_cmplx_sc_mul 0x2d80
.equ fmath_cmplx_mul    0x2da0

.equ fmath_exp          0x2dd0
.equ fmath_ln           0x2e10

.code

;------------
; Test Cases
;------------
main:
   jmp test_1

test_1:
   ldi r0,-10.0         ; r0 -> abs(-10.0) = 10.0 = 0x4900
   call fmath_abs
   end

test_2:
   ldi r0,4.0           ; r0 -> 4.0^3 = 64.0 = 0x5400
   ldi r1,3
   call fmath_pow
   end

test_3:
   ldi r0,-4.0          ; r0 -> -4.0^-3 = -0.015625 = 0xa400
   ldi r1,-3
   call fmath_pow
   end

test_4:
   ldi r0,72.0          ; r0 -> sqrt(72.0) = 8.485 = 0x483e
   call fmath_sqrt
   end

test_5:
   ldi r0,37.14         ; r0 -> sin(37.14) = 0.6038 = 0x38d5
   call fmath_sin
   end

test_6:
   ldi r0,37.14         ; r0 -> cos(37.14) = 0.7972 = 0x3a61
   call fmath_cos
   end

test_7:
   ldi r0,37.14         ; r0 -> tan(37.14) = 0.7574 = 0x3a0f
   call fmath_tan
   end

test_8:
   ldi r0,r             ; t = r + s = (-5.0, 4.0, 9.0) - (Mem: 0xc00a)
   ldi r1,s             ; (0xc500, 0x4400, 0x4880)
   ldi r2,t
   call fmath_vec_add
   end

test_9:
   ldi r0,u             ; w = u - v = (12.0, -4.0, -7.0, 8.0, -4.0) - (Mem: 0xc01e)
   ldi r1,v             ; (0x4a00, 0xc400, 0xc700, 0x4800, 0xc400)
   ldi r2,w 
   call fmath_vec_sub
   end

test_10:
   ldi r0,r             ; t = 4.0 * r = (20.0, -12.0, 12.0) - (Mem: 0xc00a)
   ldi r1,4.0           ; (0x4d00, 0xca00, 0x4a00)
   ldi r2,t
   call fmath_vec_sc_mul
   end

test_11:
   ldi r0,u             ; r0 = u.v = -54.0 = 0xd2c0
   ldi r1,v
   call fmath_vec_dot_prod
   end

test_12:
   ldi r0,A             ; C = A + B = | 8.0  2.0| - (Mem: 0xc03c)
   ldi r1,B             ;             |-4.0 14.0| 
   ldi r2,C             ; |0x4800 0x4000|
   call fmath_mat_add   ; |0xc400 0x4b00|
   end

test_13:
   ldi r0,G             ; I = G - H = | 2.0 -6.0  4.0  7.0| - (Mem: 0xc0a4)
   ldi r1,H             ;             | 2.0  2.0 -4.0 -2.0|
   ldi r2,I             ;             |-2.0  4.0  6.0 -2.0|
   call fmath_mat_sub   ;             |-5.0  8.0  8.0 -1.0|
   end                  ; |0x4000 0xc600 0x4400 0x4700|
                        ; |0x4000 0x4000 0xc400 0xc000|
                        ; |0xc000 0x4400 0x4600 0xc000|
                        ; |0xc500 0x4800 0x4800 0xbc00|

test_14:
   ldi r0,D             ; F = 3 * D = |15.0 -6.0  9.0| - (Mem: 0xc066)
   ldi r1,3.0           ;             |-3.0 24.0 -6.0|
   ldi r2,F             ;             |12.0  0.0 21.0|
   call fmath_mat_sc_mul; |0x4b80 0xc600 0x4880|
   end                  ; |0xc200 0x4e00 0xc600|
                        ; |0x4a00 0x0000 0x4d40|

test_15:
   ldi r0,D             ; F = D * E = | 39.0  -4.0 -6.0| - (Mem: 0xc066)
   ldi r1,E             ;             |-39.0  52.0 15.0|
   ldi r2,F             ;             | 54.0 -12.0  3.0| 
   call fmath_mat_mul   ; |0x50e0 0xc400 0xc600|
   end                  ; |0xd0e0 0x5280 0x4b80|
                        ; |0x52c0 0xca00 0x4200|

test_16:
   ldi r0,J             ; L = J * K = | 9.0 12.0 15.0| - (Mem: 0xc0d2)
   ldi r1,K             ;             |19.0 26.0 33.0|
   ldi r2,L             ;             |29.0 40.0 51.0| 
   call fmath_mat_mul   ;             |39.0 54.0 69.0|
   end                  ; |0x4880 0x4a00 0x4b80|
                        ; |0x4cc0 0x4e80 0x5020|
                        ; |0x4f40 0x5100 0x5260|
                        ; |0x50e0 0x52c0 0x5450|

test_17:
   ldi r0,K             ; Invalid dims -> Error: 0x0150
   ldi r1,J
   ldi r2,L
   call fmath_mat_mul

test_18:
   ldi r0,M             ; M = N * O = |1.0 2.0 3.0| - (Mem: 0xc0fa)
   ldi r1,N             ;             |2.0 4.0 6.0|
   ldi r2,O             ;             |3.0 6.0 9.0| 
   call fmath_mat_mul   ; |0x3c00 0x4000 0x4200|
   end                  ; |0x4000 0x4400 0x4600|
                        ; |0x4200 0x4600 0x4880|

test_19:
   ldi r0,G             ; I = trans(G) = | 5.0 -1.0 4.0 -3.0| - (Mem: 0xc0a4)
   ldi r1,I             ;                |-2.0  8.0 0.0  4.0|
   call fmath_mat_trans ;                | 3.0 -2.0 7.0  2.0|
   end                  ;                | 9.0 -3.0 1.0  0.0|
                        ; |0x4500 0xbc00 0x4400 0xc200|
                        ; |0xc000 0x4800 0x0000 0x4400|
                        ; |0x4200 0xc000 0x4700 0x4000|
                        ; |0x4880 0xc200 0x3c00 0x0000|

test_20:
   ldi r0,A             ; r0 = det(A) = 38.0 = 0x50c0
   call fmath_mat_det_2
   end

test_21:
   ldi r0,D             ; r0 = det(D) = 186.0 = 0x59d0
   call fmath_mat_det_3
   end

test_22:
   ldi r0,x_r           ; r1 = Im(x) = -3.0 = 0xc200
   call fmath_cmplx_im   
   mov r0,r1
   ldi r0,x_r           ; r0 = Re(x) = 7.0 = 0x4700
   call fmath_cmplx_re
   end

test_23:
   ldi r0,x_r           ; z = conj(x) = 7.0 + 3.0i (Mem: 0xc130)
   ldi r1,z_r           ; (0x4700, 0x4200)
   call fmath_cmplx_conj
   end

test_24:
   ldi r0,x_r           ; z = x + y = 1.0 + 1.0i (Mem: 0xc130)
   ldi r1,y_r           ; (0x3c00, 0x3c00)
   ldi r2,z_r
   call fmath_cmplx_add
   end

test_25:
   ldi r0,x_r           ; z = x - y = 13.0 - 7.0i (Mem: 0xc130)
   ldi r1,y_r           ; (0x4a80, 0xc700)
   ldi r2,z_r
   call fmath_cmplx_sub
   end

test_26:
   ldi r0,x_r           ; z = 4.0 * x = 28.0 - 12.0i (Mem: 0xc130)
   ldi r1,4.0           ; (0x4f00, 0xca00)
   ldi r2,z_r
   call fmath_cmplx_sc_mul
   end

test_27:
   ldi r0,x_r           ; z = x * y = -30.0 + 46.0i (Mem: 0xc130)
   ldi r1,y_r           ; (0xcf80, 0x51c0)
   ldi r2,z_r
   call fmath_cmplx_mul
   end

test_28:
   ldi r0,-0.25         ; r0 -> 0.7788 (0x3a3b)
   call fmath_exp
   end

test_29:
   ldi r0,2.5           ; r0 -> 0.9163 (0x3b55)
   call fmath_ln
   end

;------
; Data
;------
.data

.= 0xc000

r: array [5.0, -3.0, 3.0] 
s: array [-10.0, 7.0, 6.0]
t: array 5

.= 0xc010

u: array [7.0, -2.0, 0.0, 6.0, -3.0] 
v: array [-5.0, 2.0, 7.0, -2.0, 1.0]
w: array 7

.= 0xc030

; A = | 5.0  -2.0|
;     |-1.0   8.0|

A: array [5.0, -2.0 : -1.0, 8.0]

; B = | 3.0  4.0|
;     |-3.0  6.0|

B: array [3.0, 4.0 : -3.0, 6.0]

C: array 6

.= 0xc050

; D = | 5.0 -2.0  3.0|
;     |-1.0  8.0 -2.0|
;     | 4.0  0.0  7.0|

D: array [5.0, -2.0, 3.0 : -1.0, 8.0, -2.0 : 4.0, 0.0, 7.0]

; E = | 3.0  4.0 -1.0|
;     |-3.0  6.0  2.0|
;     | 6.0 -4.0  1.0|

E: array [3.0, 4.0, -1.0 : -3.0, 6.0, 2.0 : 6.0, -4.0, 1.0]

F: array 11

.= 0xc080

; G = | 5.0 -2.0  3.0  9.0|
;     |-1.0  8.0 -2.0 -3.0|
;     | 4.0  0.0  7.0  1.0|
;     |-3.0  4.0  2.0  0.0|

G: array [5.0, -2.0, 3.0, 9.0 : -1.0, 8.0, -2.0, -3.0 : 4.0, 0.0, 7.0, 1.0 : -3.0, 4.0, 2.0, 0.0]

; H = | 3.0  4.0 -1.0  2.0|
;     |-3.0  6.0  2.0 -1.0|
;     | 6.0 -4.0  1.0  3.0|
;     | 2.0 -4.0 -6.0  1.0|

H: array [3.0, 4.0, -1.0, 2.0 : -3.0, 6.0, 2.0, -1.0 : 6.0, -4.0, 1.0, 3.0 : 2.0, -4.0, -6.0, 1.0]

I: array 18

.= 0xc0c0

; J = |1.0 2.0|
;     |3.0 4.0|
;     |5.0 6.0|
;     |7.0 8.0|

J: array [1.0, 2.0 : 3.0, 4.0 : 5.0, 6.0 : 7.0, 8.0]

; K = |1.0 2.0 3.0|
;     |4.0 5.0 6.0|

K: array [1.0, 2.0, 3.0 : 4.0, 5.0, 6.0]

L: array 14

.= 0xc0f0

; M = |1.0|
;     |2.0|
;     |3.0|

M: array [1.0 : 2.0 : 3.0]

; N = |1.0 2.0 3.0|

N: array [1.0, 2.0, 3.0]

O: array 11

.= 0xc110

x_r: word 7.0     ; x = 7 - 3i
x_i: word -3.0

.= 0xc120

y_r: word -6.0    ; y = -6 + 4i
y_i: word 4.0

.= 0xc130

z_r: word 0
z_i: word 0

