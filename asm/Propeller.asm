
;-------------------------------------------------------------
; Draw a 'Propeller' on the Graphics Screen
;
; Translated from RTM-16 code: 'FTI_complex.asm'
;
; NB: Remember to set the Graphics Screen Background as Black
;-------------------------------------------------------------

.RAM

; Maths Library Defines
.equ fmath_sin 0x2750
.equ fmath_cos 0x27a0

; Graphics Library Define
.equ GR_WHITE 0xffff

.code

main:
    ldi r0,0.0          ; theta = 0.0
    ldi r1,theta
    st r0,[r1]

loop:
    ldi r0,theta
    ld r0,[r0]          ; r0 = theta
    ldi r1,360.0
    fcmp r0,r1
    jge finished

    ; Compute k * theta
    ldi r1,3.0
    fmul r0,r1,r0       ; r0 = 3*theta
    call fmath_sin      ; r0 = sin(3*theta)
    ldi r1,120.0
    fmul r0,r1,r4       ; r4 = 120 * sin(3*theta) = r

    ; Calculate x = r * cos(theta)
    ldi r0,theta
    ld r0,[r0]          ; r0 = theta
    call fmath_cos      ; r0 = cos(theta)
    fmul r0,r4,r3       ; r3 = x = r * cos(theta)

    ; Calculate y = r * sin(θ)
    ldi r0,theta
    ld r0,[r0]          ; r0 = theta
    call fmath_sin      ; r0 = sin(theta)
    fmul r0,r4,r4       ; r4 = y = r * sin(theta)

    ; Plot
    ldi r2,GR_WHITE
    fsetpx r3,r4,r2

    ; Increment theta
    ldi r0,theta
    ld r0,[r0]          ; r0 = theta
    ldi r1,5.729578
    fadd r0,r1,r0
    ldi r1,theta
    st r0,[r1]

    jmp loop

finished:
    end


.data

.= 0xc000

theta: word 0

