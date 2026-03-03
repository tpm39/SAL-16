
;------------------------------
; Test the 'int' Maths Library
;------------------------------

.RAM

; Maths Library Defines
.equ imath_abs          0x2000
.equ imath_pow          0x2010
.equ imath_mod          0x2040
.equ imath_fact         0x2050
.equ imath_sqrt         0x2070

.equ imath_vec_add      0x21b0
.equ imath_vec_sub      0x21f0
.equ imath_vec_sc_mul   0x2230
.equ imath_vec_dot_prod 0x2260

.equ imath_mat_add      0x22a0
.equ imath_mat_sub      0x22e0
.equ imath_mat_sc_mul   0x2320
.equ imath_mat_mul      0x2350
.equ imath_mat_trans    0x2510
.equ imath_mat_det_2    0x2550
.equ imath_mat_det_3    0x2590

.equ imath_cmplx_re     0x2620
.equ imath_cmplx_im     0x2630
.equ imath_cmplx_conj   0x2640
.equ imath_cmplx_add    0x2660
.equ imath_cmplx_sub    0x2680
.equ imath_cmplx_sc_mul 0x26a0
.equ imath_cmplx_mul    0x26c0

.code

;------------
; Test Cases
;------------
main:
   jmp test_1

test_1:
   ldi r0,-10           ; r0 -> abs(-10) = 10 = 0x000a
   call imath_abs
   end

test_2:
   ldi r0,4             ; r0 -> 4^3 = 64 = 0x0040
   ldi r1,3
   call imath_pow
   end

test_3:
   ldi r0,4             ; r0 -> -4^-3 = 0 = 0x0000
   ldi r1,3
   call imath_pow
   end

test_4:
   ldi r0,25
   ldi r1,19
   call imath_mod        ; r0 = 25 % 19 = 6 = 0x0006
   end

test_5:
   ldi r0,4             ; r0 -> 4! = 24 = 0x0018
   call imath_fact
   end

test_6:
   ldi r0,72            ; r0 -> isqrt(72) = 8 = 0x0008
   call imath_sqrt
   end

test_7:
   ldi r0,r             ; t = r + s = (-5, 4, 9) - (Mem: 0xc00a)
   ldi r1,s             ; (0xfffb, 0x0004, 0x0009)
   ldi r2,t
   call imath_vec_add
   end

test_8:
   ldi r0,u             ; w = u - v = (12, -4, -7, 8, -4) - (Mem: 0xc01e)
   ldi r1,v             ; (0x000c, 0xfffc, 0xfff9, 0x0008, 0xfffc)
   ldi r2,w
   call imath_vec_sub
   end

test_9:
   ldi r0,r             ; t = 4 * r = (20, -12, 12) - (Mem: 0xc00a)
   ldi r1,4             ; (0x0014, 0xfff4, 0x000c)
   ldi r2,t
   call imath_vec_sc_mul
   end

test_10:
   ldi r0,u             ; r0 = u.v = -54 = 0xffca
   ldi r1,v
   call imath_vec_dot_prod
   end

test_11:
   ldi r0,A             ; C = A + B = | 8  2| - (Mem: 0xc03c)
   ldi r1,B             ;             |-4 14| 
   ldi r2,C             ; |0x0008 0x0002|
   call imath_mat_add   ; |0xfffc 0x000e| 
   end

test_12:
   ldi r0,G             ; I = G - H = | 2 -6  4  7| - (Mem: 0xc0a4)
   ldi r1,H             ;             | 2  2 -4 -2|
   ldi r2,I             ;             |-2  4  6 -2|
   call imath_mat_sub   ;             |-5  8  8 -1|
   end                  ; |0x0002 0xfffa 0x0004 0x0007|
                        ; |0x0002 0x0002 0xfffc 0xfffe|
                        ; |0xfffe 0x0004 0x0006 0xfffe|
                        ; |0xfffb 0x0008 0x0008 0xffff|

test_13:
   ldi r0,D             ; F = 3 * D = |15 -6  9| - (Mem: 0xc066)
   ldi r1,3             ;             |-3 24 -6|
   ldi r2,F             ;             |12  0 21|
   call imath_mat_sc_mul; |0x000f 0xfffa 0x0009|
   end                  ; |0xfffd 0x0018 0xfffa|
                        ; |0x000c 0x0000 0x0015|

test_14:
   ldi r0,D             ; F = D * E = | 39  -4 -6| - (Mem: 0xc066)
   ldi r1,E             ;             |-39  52 15|
   ldi r2,F             ;             | 54 -12  3| 
   call imath_mat_mul   ; |0x0027 0xfffc 0xfffa|
   end                  ; |0xffd9 0x0034 0x000f|
                        ; |0x0036 0xfff4 0x0003|

test_15:
   ldi r0,J             ; L = J * K = | 9 12 15| - (Mem: 0xc0d2)
   ldi r1,K             ;             |19 26 33|
   ldi r2,L             ;             |29 40 51| 
   call imath_mat_mul   ;             |39 54 69|
   end                  ; |0x0009 0x000c 0x000f|
                        ; |0x0013 0x001a 0x0021|
                        ; |0x001d 0x0028 0x0033|
                        ; |0x0027 0x0036 0x0045|

test_16:
   ldi r0,K             ; Invalid dims -> Error: 0x0150
   ldi r1,J
   ldi r2,L
   call imath_mat_mul

test_17:
   ldi r0,M             ; M = N * O = |1 2 3| - (Mem: 0xc0fa)
   ldi r1,N             ;             |2 4 6|
   ldi r2,O             ;             |3 6 9| 
   call imath_mat_mul   ; |0x0001 0x0002 0x0003|
   end                  ; |0x0002 0x0004 0x0006|
                        ; |0x0003 0x0006 0x0009|

test_18:
   ldi r0,G             ; I = trans(G) = | 5 -1 4 -3| - (Mem: 0xc0a4)
   ldi r1,I             ;                |-2  8 0  4|
   call imath_mat_trans ;                | 3 -2 7  2|
   end                  ;                | 9 -3 1  0|
                        ; |0x0005 0xffff 0x0004 0xfffd|
                        ; |0xfffe 0x0008 0x0000 0x0004|
                        ; |0x0003 0xfffe 0x0007 0x0002|
                        ; |0x0009 0xfffd 0x0001 0x0000|

test_19:
   ldi r0,A             ; r0 = det(A) = 38 = 0x0026
   call imath_mat_det_2
   end

test_20:
   ldi r0,D             ; r0 = det(D) = 186 = 0x00ba
   call imath_mat_det_3
   end

test_21:
   ldi r0,x_r           ; r1 = Im(x) = -3 = 0xfffd
   call imath_cmplx_im   
   mov r0,r1
   ldi r0,x_r           ; r0 = Re(x) = 7 = 0x0007
   call imath_cmplx_re
   end

test_22:
   ldi r0,x_r           ; z = conj(x) = 7 + 3i (Mem: 0xc130)
   ldi r1,z_r           ; (0x0007, 0x0003)
   call imath_cmplx_conj
   end

test_23:
   ldi r0,x_r           ; z = x + y = 1 + i (Mem: 0xc130)
   ldi r1,y_r           ; (0x0001, 0x0001)
   ldi r2,z_r
   call imath_cmplx_add
   end

test_24:
   ldi r0,x_r           ; z = x - y = 13 - 7i (Mem: 0xc130)
   ldi r1,y_r           ; (0x000d, 0xfff9)
   ldi r2,z_r
   call imath_cmplx_sub
   end

test_25:
   ldi r0,x_r           ; z = 4 * x = 28 - 12i (Mem: 0xc130)
   ldi r1,4             ; (0x001c, 0xfff4)
   ldi r2,z_r
   call imath_cmplx_sc_mul
   end

test_26:
   ldi r0,x_r           ; z = x * y = -30 + 46i (Mem: 0xc130)
   ldi r1,y_r           ; (0xffe2, 0x002e)
   ldi r2,z_r
   call imath_cmplx_mul
   end

;------
; Data
;------
.data

.= 0xc000

r: array [5, -3, 3] 
s: array [-10, 7, 6]
t: array 5

.= 0xc010

u: array [7, -2, 0, 6, -3] 
v: array [-5, 2, 7, -2, 1]
w: array 7

.= 0xc030

; A = | 5  -2|
;     |-1   8|

A: array [5, -2 : -1, 8]

; B = | 3  4|
;     |-3  6|

B: array [3, 4 : -3, 6]

C: array 6

.= 0xc050

; D = | 5 -2  3|
;     |-1  8 -2|
;     | 4  0  7|

D: array [5, -2, 3 : -1, 8, -2 : 4, 0, 7]

; E = | 3  4 -1|
;     |-3  6  2|
;     | 6 -4  1|

E: array [3, 4, -1 : -3, 6, 2 : 6, -4, 1]

F: array 11

.= 0xc080

; G = | 5 -2  3  9|
;     |-1  8 -2 -3|
;     | 4  0  7  1|
;     |-3  4  2  0|

G: array [5, -2, 3, 9 : -1, 8, -2, -3 : 4, 0, 7, 1 : -3, 4, 2, 0]

; H = | 3  4 -1  2|
;     |-3  6  2 -1|
;     | 6 -4  1  3|
;     | 2 -4 -6  1|

H: array [3, 4, -1, 2 : -3, 6, 2, -1 : 6, -4, 1, 3 : 2, -4, -6, 1]

I: array 18

.= 0xc0c0

; J = |1 2|
;     |3 4|
;     |5 6|
;     |7 8|

J: array [1, 2 : 3, 4 : 5, 6 : 7, 8]

; K = |1 2 3|
;     |4 5 6|

K: array [1, 2, 3 : 4, 5, 6]

L: array 14

.= 0xc0f0

; M = |1|
;     |2|
;     |3|

M: array [1 : 2 : 3]

; N = |1 2 3|

N: array [1, 2, 3]

O: array 11

.= 0xc110

x_r: word 7       ; x = 7 - 3i
x_i: word 0xfffd

.= 0xc120

y_r: word 0xfffa  ; y = -6 + 4i
y_i: word 4

.= 0xc130

z_r: word 0
z_i: word 0

