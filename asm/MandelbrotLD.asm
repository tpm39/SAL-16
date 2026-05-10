
;------------------------------------------------------------------------
; Display the Mandelbrot Set
;
; The code is based on the following pseudo-code:
;
; for each pixel (xp,yp) on the screen do
;   x0 = scaled x coordinate of pixel (to be in the range (-2.50, 0.50))
;   y0 = scaled y coordinate of pixel (to be in the range (-1.50, 1.50))
;    
;   x = 0.0
;   y = 0.0
;   iter = 0
;   max_iters = 15
;    
;   while (x^2 + y^2 <= 4) and (iter < max_iters) do
;      xtemp = x^2 - y^2 + x0
;      y = 2xy + y0
;      x = xtemp
;      iter += 1
;
;   if (iter = max_iters) do
;      plot(xp,xy,colour)
;------------------------------------------------------------------------

.RAM

; Graphics Library Defines
.equ gr_pixel 0x3000

.equ GR_BLUE 0x001f

; Grid constants
.equ PTS_PER_ROW 64
.equ PTS_PER_COL 64
.equ PTS_DIST     4

; Distance between points (for PTS_PER_COL = 64)
.equ DIST 0x2a18     ; 3.0(screen width) / 63(PTS_PER_ROW - 1) = 0.047619

; Top left co-ords
.equ Y_MAX  1.5
.equ X_MIN -2.5

; Misc constants
.equ MAX_ITERS 15

.equ F2 2.0
.equ F4 4.0

.code

;----------------------------------------------------------
; Program
;
; 'lower' plots all the points on the 'y = 0' axis & below
; 'upper' plots all the points above the 'y = 0' axis
;----------------------------------------------------------
lower:
   clr r1               ; y = 0 - Go to the 'y = 0' axis'
   ldi r2,PTS_PER_COL   ; yp = 31 (for PTS_PER_COL = 64)
   ldi lr,1
   asr r2,lr,r2
   dec r2

next_lower_row:
   ldi lr,PTS_PER_COL   ; while yp < PTS_PER_COL
   dec lr
   cmp r2,lr
   jeq upper

   call plot_row        ; Plot the row

   ldi lr,DIST          ; Do the points in the next row down
   fsub r1,lr,r1
   inc r2               ; yp += 1
   jmp next_lower_row

upper:
   ldi r1,DIST          ; y = DIST - Go to the 1st row above the 'y = 0' axis
   ldi r2,PTS_PER_COL   ; yp = 30 (for PTS_PER_COL = 64)
   ldi lr,1
   asr r2,lr,r2
   dec r2
   dec r2

next_upper_row:
   ldi lr,-1            ; while yp > 0
   cmp r2,lr
   jeq done

   call plot_row        ; Plot the row

   ldi lr,DIST          ; Do the points in the next row up
   fadd r1,lr,r1
   dec r2               ; yp -= 1
   jmp next_upper_row

done:
   end

;-----------------------------------
; Plot a row on the Graphics Screen
;-----------------------------------
plot_row:
   push lr              ; Save return address

   ldi r3,X_MIN         ; x = X_MIN - Go to the 1st coloumn
   clr r4               ; xp = 0

next_col:
   ldi lr,PTS_PER_ROW   ; while xp < PTS_PER_ROW
   cmp r4,lr
   jeq row_done

   call mand_pix        ; Is the point in the Mandelbrot Set ?
   clr lr         
   cmp r0,lr
   jeq no_plot

   call plot            ; If the point's in the Mandelbrot Set plot it

no_plot:
   ldi lr,DIST          ; Do the point in the next column
   fadd r3,lr,r3
   inc r4               ; xp += 1
   jmp next_col

row_done:
   pop lr               ; Retrieve return address
   ret

;----------------------------------------------
; Determine if a point's in the Mandelbrot Set
; Return 1 in R0 if it is, and 0 if it's not
;----------------------------------------------
mand_pix:
   push lr              ; Save used registers
   push r1              ; yc
   push r2
   push r3              ; xc
   push r4
   movsp fp

   clr r0               ; r0 = y = 0
   clr r2               ; r2 = x = 0
   clr r4               ; r4 = z_sqr = 0
   clr idx

next_iter:
   ldi lr,MAX_ITERS     ; Iterations exhausted ?
   cmp idx,lr
   jeq ret_1

   fmul r2,r2,r3        ; r3 = x^2
   fmul r0,r0,r1        ; r1 = y^2
   fadd r1,r3,r4        ; r4 = z^2

   ldi lr,F4            ; Test if z^2 > 4 - if so return 0
   fsub r4,lr,r4        ; r4 = z_sqr - 4
   clr lr
   add r4,lr,r4         ; Get the sign of r4
   jpl ret_0            ; Return 0 if r4 (z_sqr - 4) > 0

   fsub r3,r1,r3        ; r3 = x_tmp = x^2 - y^2
   ldi lr,2
   ldx lr,[fp,lr]       ; lr = cx
   fadd r3,lr,r3        ; x_tmp = x^2 - y^2 + cx

   fmul r2,r0,r0        ; r0 = xy
   ldi lr,F2
   fmul lr,r0,r0        ; r0 = 2xy
   ldi lr,4
   ldx lr,[fp,lr]       ; lr = cy
   fadd r0,lr,r0        ; y = 2xy + cy

   mov r3,r2            ; x = x_tmp

   inc idx
   jmp next_iter

ret_1:
   ldi r0,1             ; Return 1
   jmp mand_done

ret_0:
   clr r0               ; Return 0

mand_done:
   pop r4               ; Restore used registers
   pop r3
   pop r2
   pop r1
   pop lr
   ret

;-------------------------------------
; Plot a point on the Graphics Screen
;-------------------------------------
plot:
   push lr              ; Save used registers
   push r1
   push r2

   ldi lr,PTS_DIST      ; Set the Graphics x coord = PTS_DIST * xp
   mov r4,r0
   mul r0,lr,r0
   mov r2,r1            ; Set the Graphics y coord = PTS_DIST * yp
   mul r1,lr,r1
   ldi r2,GR_BLUE       ; Use a blue pixel
   call gr_pixel        ; Set the pixel

   pop r2               ; Restore used registers
   pop r1
   pop lr
   ret

