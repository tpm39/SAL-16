
;------------------------------------------------------------
; Graphics Library for TimmiOS - The SAL-16 Operating System
;------------------------------------------------------------

;--------------------------------------------
; Defines for use in programs using TimmiOS:
;
; .equ gr_pixel       0x3000
; .equ gr_line        0x31a0
; .equ gr_rect        0x33f0
; .equ gr_rect_fill   0x3450
; .equ gr_circle      0x34c0
; .equ gr_circle_fill 0x37d0
; .equ gr_fp_pixel    0x3a40
;
; .equ GR_RED       0xf800
; .equ GR_BLUE      0x001f
; .equ GR_GREEN     0x07e0
; .equ GR_DK_GREEN  0x0560
; .equ GR_BLACK     0x0000
; .equ GR_WHITE     0xffff
; .equ GR_BROWN     0x9260
; .equ GR_LT_BROWN  0xdd0d
; .equ GR_GOLD      0xfea0
; .equ GR_SILVER    0xbdf7
; .equ GR_ORANGE    0xfcc0
; .equ GR_TURQUOISE 0x273a
; .equ GR_PURPLE    0xa01f
; .equ GR_PINK      0xebda
; .equ GR_FUCHSIA   0xf81f
; .equ GR_CYAN      0x07ff
; .equ GR_BKGRD     0xffd7
;--------------------------------------------

.ROM

.code

;---------------------------------------------------
; Graphics - Set a pixel with colour 'col' at (x,y)
;
; Location: ROM addr 0x3000
;
; Inputs: R0 = x
;         R1 = y
;         R2 = col
;---------------------------------------------------

.= 0x3000

gr_pixel:
   push r3           ; Save used register

   ldi r3,256
   mul r1,r3,r1      ; r1 = 256*y
   add r0,r1,r0      ; r0 = pos = x + 256*y
   mov r2,r1         ; r1 = col = r2
   setpx r0,r1

   pop r3            ; Restore used register
   ret

;--------------------------------------------------------------------------
; Graphics - Draw a horizontal line with colour 'col' from (x1,y) to (x2,y)
;
; Location: ROM addr 0x3020
;
; Inputs: R0 = x1
;         R1 = x2
;         R2 = y
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;--------------------------------------------------------------------------

.= 0x3020

gr_h_line:
   push r4     ; Save registers
   push idx
   push lr     ; Auto-generated code
   push fp
   push r3
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
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_h_line_3
   clr r2
cond_gr_h_line_3:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_h_line_1
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,1
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,2
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,-1
   stx r0,[fp,idx]
if_gr_h_line_1:
   ldi r0,0
   ldi idx,-2
   stx r0,[fp,idx]
for_gr_h_line_5:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_gr_h_line_8
   clr r2
cond_gr_h_line_8:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_h_line_7
   ldi idx,1
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
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
for_gr_h_line_6:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   jmp for_gr_h_line_5
for_gr_h_line_7:
   clr r0
ret_gr_h_line:
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
   pop idx     ; Restore registers
   pop r4
   ret

;------------------------------------------------------------------------
; Graphics - Draw a vertical line with colour 'col' from (x,y1) to (x,y2)
;
; Location: ROM addr 0x30e0
;
; Inputs: R0 = x
;         R1 = y1
;         R2 = y2
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;------------------------------------------------------------------------

.= 0x30e0

gr_v_line:
   push r4     ; Save registers
   push idx
   push lr     ; Auto-generated code
   push fp
   push r3
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
   ldi idx,3
   ldx r0,[fp,idx]
   push r0
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_v_line_12
   clr r2
cond_gr_v_line_12:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_v_line_10
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,3
   ldx r0,[fp,idx]
   ldi idx,2
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,3
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,-1
   stx r0,[fp,idx]
if_gr_v_line_10:
   ldi r0,0
   ldi idx,-2
   stx r0,[fp,idx]
for_gr_v_line_14:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_gr_v_line_17
   clr r2
cond_gr_v_line_17:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_v_line_16
   ldi idx,2
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
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,0
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
for_gr_v_line_15:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   jmp for_gr_v_line_14
for_gr_v_line_16:
   clr r0
ret_gr_v_line:
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
   pop idx     ; Restore registers
   pop r4
   ret

;------------------------------------------------------------------
; Graphics - Draw a line with colour 'col' from (x1,y1) to (x2, y2)
;
; Location: ROM addr 0x31a0
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;------------------------------------------------------------------

.= 0x31a0

gr_line:
   push idx    ; Save register
   push lr     ; Auto-generated code
   push fp
   push r4
   push r3
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
   ldi idx,3
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,4
   ldx r0,[fp,idx]
   push r0
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_gr_line_21
   clr r2
cond_gr_line_21:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_19
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,2
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_v_line
   clr r0
   jmp ret_gr_line
if_gr_line_19:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_gr_line_24
   clr r2
cond_gr_line_24:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_22
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,2
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_h_line
   clr r0
   jmp ret_gr_line
if_gr_line_22:
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,-3
   ldx r1,[fp,idx]
   ldi idx,5
   ldx r2,[fp,idx]
   call gr_pixel
   ldi r0,1
   ldi idx,-4
   stx r0,[fp,idx]
   ldi r0,1
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_line_27
   clr r2
cond_gr_line_27:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_25
   ldi idx,0
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi r0,1
   not r0,r0
   inc r0
   ldi idx,-4
   stx r0,[fp,idx]
if_gr_line_25:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_line_31
   clr r2
cond_gr_line_31:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_29
   ldi idx,-1
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi r0,1
   not r0,r0
   inc r0
   ldi idx,-5
   stx r0,[fp,idx]
if_gr_line_29:
   ldi r0,0
   ldi idx,-8
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_gr_line_35
   clr r2
cond_gr_line_35:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_33
   ldi idx,0
   ldx r0,[fp,idx]
   ldi idx,-6
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,-6
   ldx r0,[fp,idx]
   ldi idx,-1
   stx r0,[fp,idx]
   ldi r0,1
   ldi idx,-8
   stx r0,[fp,idx]
if_gr_line_33:
   ldi r0,2
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r0
   ldi idx,-10
   stx r0,[fp,idx]
   ldi idx,-10
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-9
   stx r0,[fp,idx]
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-7
   stx r0,[fp,idx]
for_gr_line_37:
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
   jgt cond_gr_line_40
   clr r2
cond_gr_line_40:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_line_39
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_line_44
   clr r2
cond_gr_line_44:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_42
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_gr_line_48
   clr r2
cond_gr_line_48:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_46
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   jmp if_gr_line_47
if_gr_line_46:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
if_gr_line_47:
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi idx,-10
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-9
   stx r0,[fp,idx]
   jmp if_gr_line_43
if_gr_line_42:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi idx,-11
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-9
   stx r0,[fp,idx]
if_gr_line_43:
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,-3
   ldx r1,[fp,idx]
   ldi idx,5
   ldx r2,[fp,idx]
   call gr_pixel
for_gr_line_38:
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
   jmp for_gr_line_37
for_gr_line_39:
ret_gr_line:
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
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Restore register
   ret

;----------------------------------------------------------------------------
; Graphics - Draw a rectangle with colour 'col' and corners (x1,y1) & (x2,y2)
;
; Location: ROM addr 0x33f0
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;----------------------------------------------------------------------------

.= 0x33f0

gr_rect:
   push idx    ; Save register
   push lr     ; Auto-generated code
   push fp
   push r4
   push r3
   push r2
   push r1
   push r0
   movsp fp
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,2
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_h_line
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,2
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_v_line
   ldi idx,3
   ldx r0,[fp,idx]
   ldi idx,2
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_v_line
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_h_line
   clr r0
ret_gr_rect:
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Restore register
   ret

;-----------------------------------------------------------------------------------
; Graphics - Draw a filled rectangle with colour 'col' and corners (x1,y1) & (x2,y2)
;
; Location: ROM addr 0x3450
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;-----------------------------------------------------------------------------------

.= 0x3450

gr_rect_fill:
   push idx    ; Save register
   push lr     ; Auto-generated code
   push fp
   push r4
   push r3
   push r2
   push r1
   push r0
   movsp fp
   clr r0
   push r0
   ldi idx,2
   ldx r0,[fp,idx]
   ldi idx,0
   stx r0,[fp,idx]
for_gr_rect_fill_49:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,4
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_gr_rect_fill_52
   clr r2
cond_gr_rect_fill_52:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_rect_fill_51
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,0
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_h_line
for_gr_rect_fill_50:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   jmp for_gr_rect_fill_49
for_gr_rect_fill_51:
   clr r0
ret_gr_rect_fill:
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   pop idx     ; Restore register
   ret

;--------------------------------------------------------------------------
; Graphics - Draw a circle with colour 'col', centre '(x,y)' & radius 'r'
;
; Location: ROM addr 0x34c0
;
; Inputs: R0 = x
;         R1 = y
;         R2 = r
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;--------------------------------------------------------------------------

.= 0x34c0

gr_circle:
   push r4     ; Save registers
   push idx
   push lr     ; Auto-generated code
   push fp
   push r3
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
   ldi idx,3
   ldx r0,[fp,idx]
   ldi idx,0
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi r0,1
   push r0
   ldi idx,3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,2
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,2
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
while_gr_circle_54:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_gr_circle_56
   clr r2
cond_gr_circle_56:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_gr_circle_55
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
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_None_60
   clr r2
cond_None_60:
   mov r2,r0
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_None_61
   clr r2
cond_None_61:
   mov r2,r0
   push r0
   pop r1
   pop r0
   ldi r2,1
   clr r3
   cmp r0,r3
   jgt cond_gr_circle_63
   cmp r1,r3
   jgt cond_gr_circle_63
   clr r2
cond_gr_circle_63:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_58
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
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
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   jmp if_gr_circle_59
if_gr_circle_58:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
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
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
if_gr_circle_59:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_circle_66
   clr r2
cond_gr_circle_66:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_64
   clr r0
   jmp ret_gr_circle
if_gr_circle_64:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   clr r2
   cmp r0,r1
   jeq cond_gr_circle_70
   inc r2
cond_gr_circle_70:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_68
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
if_gr_circle_68:
   jmp while_gr_circle_54
while_gr_circle_55:
ret_gr_circle:
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
   pop idx     ; Restore registers
   pop r4
   ret

;---------------------------------------------------------------------------------
; Graphics - Draw a filled circle with colour 'col', centre '(x,y)' & radius 'r'
;
; Location: ROM addr 0x37d0
;
; Inputs: R0 = x
;         R1 = y
;         R2 = r
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Graphics.rmg'
;---------------------------------------------------------------------------------

.= 0x37d0

gr_circle_fill:
   push r4     ; Save registers
   push idx
   push lr     ; Auto-generated code
   push fp
   push r3
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
   ldi idx,3
   ldx r0,[fp,idx]
   ldi idx,0
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi r0,1
   push r0
   ldi idx,3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,2
   ldx r2,[fp,idx]
   ldi idx,4
   ldx r3,[fp,idx]
   call gr_h_line
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-5
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,-5
   ldx r1,[fp,idx]
   ldi idx,4
   ldx r2,[fp,idx]
   call gr_pixel
while_gr_circle_fill_71:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_gr_circle_fill_73
   clr r2
cond_gr_circle_fill_73:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_gr_circle_fill_72
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
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_None_77
   clr r2
cond_None_77:
   mov r2,r0
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_None_78
   clr r2
cond_None_78:
   mov r2,r0
   push r0
   pop r1
   pop r0
   ldi r2,1
   clr r3
   cmp r0,r3
   jgt cond_gr_circle_fill_80
   cmp r1,r3
   jgt cond_gr_circle_fill_80
   clr r2
cond_gr_circle_fill_80:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_75
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
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
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   jmp if_gr_circle_fill_76
if_gr_circle_fill_75:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   mul r0,r1,r0
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
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
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
if_gr_circle_fill_76:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_gr_circle_fill_83
   clr r2
cond_gr_circle_fill_83:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_81
   clr r0
   jmp ret_gr_circle_fill
if_gr_circle_fill_81:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,-5
   ldx r2,[fp,idx]
   ldi idx,4
   ldx r3,[fp,idx]
   call gr_h_line
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,-5
   ldx r2,[fp,idx]
   ldi idx,4
   ldx r3,[fp,idx]
   call gr_h_line
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   clr r2
   cmp r0,r1
   jeq cond_gr_circle_fill_87
   inc r2
cond_gr_circle_fill_87:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_85
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,-5
   ldx r2,[fp,idx]
   ldi idx,4
   ldx r3,[fp,idx]
   call gr_h_line
   ldi idx,2
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   ldi idx,-4
   ldx r1,[fp,idx]
   ldi idx,-5
   ldx r2,[fp,idx]
   ldi idx,4
   ldx r3,[fp,idx]
   call gr_h_line
if_gr_circle_fill_85:
   jmp while_gr_circle_fill_71
while_gr_circle_fill_72:
ret_gr_circle_fill:
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
   pop idx     ; Restore registers
   pop r4
   ret

;----------------------------------------------------
; Graphics - Set a pixel with colour 'col' at (x,y),
;            where x & y are floating point numbers.
;
; Location: ROM addr 0x3a40
;
; Inputs: R0 = x
;         R1 = y
;         R2 = col
;----------------------------------------------------

.= 0x3a40

gr_fp_pixel:
   fsetpx r0,r1,r2
   ret

