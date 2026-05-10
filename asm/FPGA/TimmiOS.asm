
;----------------------------------------------------------
; TimmiOS - The SAL-16 FPGA Operating System
;
; It does the following:
;
; a) Jumps to the start of the program in RAM at start up.
;
; b) Contains the BIOS routines.
;
; c) Contains the Graphics Library.
;
; d) Contains the Maths Library.
;
; e) Contains the String Library.
;
;----------------------------------------------------------

;------------------------------------------------
; Defines for use in programs using the TimmiOS:
;
; BIOS:
;   .equ os_get_in     0x0020
;   .equ os_disp_out   0x0050
;   .equ os_read_char  0x0070
;   .equ os_print_char 0x00a0
;   .equ os_read_str   0x00c0
;   .equ os_print_str  0x0100
;   .equ os_read_int   0x0130
;   .equ os_print_int  0x0190
;   .equ os_read_uint  0x01f0
;   .equ os_print_uint 0x0240
;   .equ os_delay_ms   0x0d30
;   .equ os_exit       0x0d50
;
; Graphics Routines:
;   .equ gr_pixel       0x0290
;   .equ gr_line        0x0440
;   .equ gr_rect        0x0670
;   .equ gr_rect_fill   0x06d0
;   .equ gr_circle      0x0790
;   .equ gr_circle_fill 0x0a70
;
; Graphics Colours:
;   .equ GR_RED       0xf800
;   .equ GR_BLUE      0x001f
;   .equ GR_GREEN     0x07e0
;   .equ GR_DK_GREEN  0x0560
;   .equ GR_BLACK     0x0000
;   .equ GR_WHITE     0xffff
;   .equ GR_BROWN     0x9260
;   .equ GR_GOLD      0xfea0
;   .equ GR_SILVER    0xbdf7
;   .equ GR_ORANGE    0xfcc0
;   .equ GR_TURQUOISE 0x273a
;   .equ GR_PURPLE    0xa01f
;   .equ GR_PINK      0xebda
;   .equ GR_FUCHSIA   0xf81f
;   .equ GR_CYAN      0x07ff
;   .equ GR_BKGRD     0xffd7
;
; Maths Routine:
;   .equ math_mod 0x0ca0
;
; String Routines:
;   .equ str_len   0x0cc0
;   .equ str_upper 0x0cf0
;
;------------------------------------------------

.ROM

; Memory Map
.equ PROG_START 0x8000

; IO Devices
.equ ERR   0xfff0
.equ KBD   0xfff1
.equ TTY   0xfff2
.equ IN    0xfff3
.equ WAIT  0xfff4
.equ ENTER 0xfff5
.equ OUT   0xfff6

; ASCII Chars
.equ CHR_ENT   0x0a
.equ CHR_MINUS 0x2d
.equ CHR_ZERO  0x30

; Error Codes
.equ DIV_BY_0 0x0002
.equ INV_DATA 0x0006

; Misc
.equ TRUE  1
.equ FALSE 0

.equ GET_INT_NUM 4         ; To show up to 5 digits when displayed integers on the text screen
.equ MAX_SIGN_INT 0x7fff   ; The maximum signed integer

.equ DELAY_MS 79           ; The 1ms delay count for 'os_delay_ms'

.code

;-------------------------------
; Goto the start of the program
;-------------------------------

jmp PROG_START

;----------------
; Error Handling
;----------------

; Display error code on OUT, turn on ERR LED & stop

; Division by 0
.= 0x0002
   ldi r0,DIV_BY_0
   jmp os_exit

; Invalid input data
.= 0x0006
   ldi r0,INV_DATA
   jmp os_exit

;----------------------------
; BIOS - Get a word from IN
;
; Location: ROM addr 0x0020
;
; Output - R0 = Entered word
;----------------------------

.= 0x0020

os_get_in:
   push r4              ; Save used registers
   push r3
   push r2
   push r1

   ldi r1,WAIT          ; r1 -> WAIT
   ldi r2,ENTER         ; r2 -> ENTER
   ldi r3,IN            ; r3 -> IN

   ldi r0,1             ; Turn the WAIT LED on
   st r0,[r1]

in_chk_ent:
   ld r4,[r2]           ; Put the button state in r1
   cmp r0,r4
   jgt in_chk_ent       ; Stay in the 'check_enter loop' until the button is pressed

   clr r0               ; Turn off the WAIT LED
   st r0,[r1]
   ld r0,[r3]           ; r0 = IN

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   ret

;------------------------------------
; BIOS - Display a word on OUT
;
; Location: ROM addr 0x0050
;
; Input - R0 = Value to be displayed
;------------------------------------

.= 0x0050

os_disp_out:
   push r1              ; Save used register

   ldi r1,OUT           ; r1 -> OUT
   st r0,[r1]           ; OUT = r0

   pop r1               ; Retrieve register
   ret

;-------------------------------------------
; BIOS - Read a character from the keyboard
;
; Location: ROM addr 0x0070
;
; Output - R0 = The character read
;-------------------------------------------

.= 0x0070

os_read_char:
   push r3              ; Save used registers
   push r2
   push r1

   ldi r2,KBD
   ldi r3,TTY
   clr r1               ; r1 is used to test for an available char

gc_rd_val:
   ld r0,[r2]           ; Read a char from the keyboard
   cmp r0,r1            ; Got a char ?
   jeq gc_rd_val        ; No char - try another read     

   st r0,[r3]           ; Display the char

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   ret

;--------------------------------------------
; BIOS - Print a character on the display
;
; Location: ROM addr 0x00a0
;
; Input - R0 = The character to be displayed
;--------------------------------------------

.= 0x00a0

os_print_char:
   push r1              ; Save used register

   ldi r1,TTY
   st r0,[r1]           ; Display the char

   pop r1               ; Retrieve register
   ret

;-----------------------------------------
; BIOS - Read a string from the keyboard
;
; Location: ROM addr 0x00c0
;
; Input - R0 = Address of the string read
;-----------------------------------------

.= 0x00c0

os_read_str:
   push fp             ; Save used registers
   push idx
   push r3
   push r2
   push r1
   push r0

   mov r0,r1
   ldi r2,0x0a          ; 'LF'
   ldi r3,TTY
   ldi r4,KBD
   clr idx
   clr fp               ; fp is used to test for an available char

gs_next:
   ld r0,[r4]           ; Read a char from the keyboard
   cmp r0,fp            ; Got a char ?
   jeq gs_next          ; No char - try another read     

   cmp r0,r2            ; We're done if it's a LF
   jeq gs_done
   st r0,[r3]           ; Display the char
   stx r0,[r1,idx]      ; Store the char
   inc idx
   jmp gs_next

gs_done:
   clr r2
   stx r2,[r1,idx]      ; Store null (string terminator)

   pop r0               ; Retrieve registers
   pop r1
   pop r2
   pop r3
   pop idx
   pop fp
   ret

;--------------------------------------------------------
; BIOS - Print a string on the display
;
; Location: ROM addr 0x0100
;
; Input - R0 = The address of the string to be displayed
;--------------------------------------------------------

.= 0x0100

os_print_str:
   push idx             ; Save used registers
   push r3
   push r2
   push r1

   ldi r1,TTY
   clr idx
   clr r3               ; r3 is used to test for null (end of string)

ps_next:
   ldx r2,[r0,idx]      ; Get the next char from memory
   cmp r2,r3            ; If it's a null we're done
   jeq ps_done
   st r2,[r1]           ; Print the char
   inc idx
   jmp ps_next

ps_done:
   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop idx
   ret

;------------------------------------------------
; BIOS - Read a signed integer from the keyboard
;
; Location: ROM addr 0x0130
;
; Output - R0 = The signed integer read
;------------------------------------------------

.= 0x0130

os_read_int:
   push lr              ; Save used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1

   clr r2               ; number (r2) = 0
   ldi r4,FALSE         ; Clear 'minus flag' (r4)
   clr idx              ; char count (idx) = 0
   ldi r1,10            ; r1 is used to store 10 for digit multiplication & to test digit limit

gi_next_char:
   ldi fp,KBD           ; Read a char from the keyboard
   ld r0,[fp]
   clr lr               ; Got a char ?
   cmp r0,lr
   jeq gi_next_char     ; No char - try another read     

   inc idx              ; char count += 1

   ldi r3,CHR_ENT       ; Is it the 'Enter' key ? 
   cmp r0,r3
   jeq gi_done

   ldi fp,TTY           ; Display char on text screen
   st r0,[fp]

   ldi r3,CHR_MINUS     ; Is it the '-' key ? 
   cmp r0,r3
   jne gi_read_next
   ldi lr,1             ; '-' only allowed as the 1st char
   cmp idx,lr
   jne gi_bad_char
   ldi r4,TRUE          ; Set 'minus' flag
   jmp gi_next_char

gi_read_next:
   ldi r3,CHR_ZERO      ; r0 is the next digit (char - CHR_ZERO)
   sub r0,r3,r0
   jmi gi_bad_char      ; digit < 0 ? - If so it's invalid
   cmp r0,r1            ; digit > 9 ? - If so it's invalid
   jge gi_bad_char

   mul r2,r1,r2         ; Update the number with the digit 
   add r2,r0,r2

   ldi r3,MAX_SIGN_INT  ; Check it's a valid number (-32,767 -> 32,767)
   cmp r2,r3
   jle gi_next_char

	end                  ; The number's out of range - Just END ...

gi_done:
   ldi lr,FALSE
   cmp r4,lr            ; Is it a negative number ?
   jeq gi_pos
   not r2,r2            ; Negate number
   inc r2

gi_pos:
   mov r2,r0            ; r0 = number
   pop r1               ; Restore registers & return
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
	ret

gi_bad_char:
   clr r2               ; Just set number = 0 on an invalid char
   jmp gi_done

;-------------------------------------------------
; BIOS - Print a signed integer on the display
;
; Location: ROM addr 0x0190
;
; Input - R0 = The signed integer to be displayed
;-------------------------------------------------

.= 0x0190

os_print_int:
   push lr              ; Save used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1
   push r0

   ldi r4,TTY           ; r4 = Display address
   ldi fp,CHR_ZERO      ; fp = ASCII '0'

   clr r1               ; Determine if number < 0, = 0 or > 0 ?
   add r0,r1,r0
   jeq pi_zero
   jpl pi_pos

   ldi r1,CHR_MINUS     ; Display '-'
   st r1,[r4]
   not r0,r0            ; r0 = abs(number)
   inc r0

pi_pos:
   ldi idx,GET_INT_NUM  ; Initialise digit count
   ldi r2,10            ; Divisor (r2) = 10
   ldi r3,TRUE          ; Set 'leading zero' flag

pi_next_dig:
   udiv r0,r2,r1        ; Remainder (r1) is the next decimal digit - this is doing: r1 = r0 % r2
   mul r1,r2,r1
   sub r0,r1,r1

   add r1,fp,r1         ; r1 = ASCII value for the digit
   push r1              ; Save the digit char on the stack
   udiv r0,r2,r0        ; Divide r0 by 10
   dec idx
   jmi pi_disp          ; Done all digits ?
   jmp pi_next_dig

pi_disp:                ; Display the decimal digits 
   ldi idx,GET_INT_NUM
   ldi lr,TRUE

pi_next_char:
   pop r0   	         ; Get the next char

   cmp r0,fp            ; Is the char a leading zero ?
   jne pi_disp_char
   cmp r3,lr
   jeq pi_lead_zero     ; Don't display leading zeros

pi_disp_char:
   ldi r3,FALSE         ; Clear 'leading zero' flag
   st r0,[r4]           ; Display the char

pi_lead_zero:
   dec idx
   jmi pi_done          ; Displayed all chars ?
   jmp pi_next_char

pi_zero:
   ldi r0,CHR_ZERO      ; Display '0'
   st r0,[r4]
   
pi_done:
   pop r0               ; Restore registers & return
   pop r1
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

;---------------------------------------------------
; BIOS - Read an unsigned integer from the keyboard
;
; Location: ROM addr 0x01f0
;
; Output - R0 = The unsigned integer read
;---------------------------------------------------

.= 0x01f0

os_read_uint:
   push lr              ; Save used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1

   clr r2               ; number (r2) = 0
   ldi r1,10            ; r1 is used to store 10 for digit multiplication & to test digit limit
   ldi r3,CHR_ENT
   ldi r4,CHR_ZERO
   ldi idx,KBD
   ldi fp,TTY
   clr lr               ; lr is used for char detection

gu_next_char:
   ld r0,[idx]          ; Read a char from the keyboard
   cmp r0,lr            ; Got a char ?
   jeq gu_next_char     ; No char - try another read     

   cmp r0,r3            ; Is it the 'Enter' key ? 
   jeq gu_done

   st r0,[fp]           ; Display char on text screen

   sub r0,r4,r0         ; r0 is the next digit (char - CHR_ZERO)
   jmi gu_err           ; digit < 0 ? - If so it's invalid
   cmp r0,r1            ; digit > 9 ? - If so it's invalid
   jge gu_err

   mul r2,r1,r2         ; Update the number with the digit
   jc gu_err            ; Checking it's not out of range
   add r2,r0,r2
   jc gu_err

   jmp gu_next_char

gu_err:
	end                  ; An invalid char or the number's out of range - Just END ...

gu_done:
   mov r2,r0            ; r0 = number
   pop r1               ; Restore registers & return
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
	ret

;---------------------------------------------------
; BIOS - Print an unsigned integer on the display
;
; Location: ROM addr 0x0240
;
; Input - R0 = The unsigned integer to be displayed
;---------------------------------------------------

.= 0x0240

os_print_uint:
   push lr              ; Save used registers
   push fp
   push idx
   push r4
   push r3
   push r2
   push r1
   push r0

   clr r1               ; Is number = 0 ?
   add r0,r1,r0
   jeq pu_zero

   ldi idx,GET_INT_NUM  ; Initialise digit count
   ldi fp,CHR_ZERO      ; fp = ASCII '0'
   ldi r2,10

pu_next_dig:
   udiv r0,r2,r1        ; Remainder (r1) is the next decimal digit - this is doing: r1 = r0 % r2
   mul r1,r2,r1
   sub r0,r1,r1

   add r1,fp,r1         ; r1 = ASCII value for the digit
   push r1              ; Save the digit char on the stack
   udiv r0,r2,r0        ; Divide r0 by 10
   dec idx
   jmi pu_disp          ; Done all digits ?
   jmp pu_next_dig

pu_disp:                ; Display the decimal digits
   ldi r4,TTY           ; r4 = Display address
   ldi idx,GET_INT_NUM  ; Initialise digit count
   ldi r3,TRUE          ; Set 'leading zero' flag
   ldi lr,TRUE          

pu_next_char:
   pop r0   	         ; Get the next char

   cmp r0,fp            ; Is the char a leading zero ?
   jne pu_disp_char
   cmp r3,lr
   jeq pu_lead_zero     ; Don't display leading zeros

pu_disp_char:
   ldi r3,FALSE         ; Clear 'leading zero' flag
   st r0,[r4]           ; Display the char

pu_lead_zero:
   dec idx
   jmi pu_done          ; Displayed all chars ?
   jmp pu_next_char

pu_zero:
   ldi r0,CHR_ZERO      ; Display '0'
   st r0,[r4]
   
pu_done:
   pop r0               ; Restore registers & return
   pop r1
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   pop lr
   ret

;---------------------------------------------------
; Graphics - Set a pixel with colour 'col' at (x,y)
;
; Location: ROM addr 0x0290
;
; Inputs: R0 = x
;         R1 = y
;         R2 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;---------------------------------------------------

.= 0x0290

gr_pixel:
   push lr
   push fp
   push r2
   push r1
   push r0
   movsp fp
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,256
   mul r0,r1,r0
   ldi idx,1
   ldx r1,[fp,idx]
   add r0,r1,r0 
   ldi idx,3
   ldx r1,[fp,idx]
   setpx r0,r1
   clr r0
ret_gr_pixel:
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   ret

;--------------------------------------------------------------------------
; Graphics - Draw a horizontal line with colour 'col' from (x1,y) to (x2,y)
;
; Location: ROM addr 0x02c0
;
; Inputs: R0 = x1
;         R1 = y2
;         R2 = y
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;--------------------------------------------------------------------------

.= 0x02c0

gr_h_line:
   push lr
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
   not r1,r1
   inc r1
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_gr_h_line_3
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
for_gr_h_line_4:
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
   jge cond_gr_h_line_7
   clr r2
cond_gr_h_line_7:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_h_line_6
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
for_gr_h_line_5:
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
   jmp for_gr_h_line_4
for_gr_h_line_6:
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
   ret

;------------------------------------------------------------------------
; Graphics - Draw a vertical line with colour 'col' from (x,y1) to (x,y2)
;
; Location: ROM addr 0x0380
;
; Inputs: R0 = x
;         R1 = y1
;         R2 = y2
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;------------------------------------------------------------------------

.= 0x0380

gr_v_line:
   push lr
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
   not r1,r1
   inc r1
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_gr_v_line_10
   clr r2
cond_gr_v_line_10:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_v_line_8
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
if_gr_v_line_8:
   ldi r0,0
   ldi idx,-2
   stx r0,[fp,idx]
for_gr_v_line_11:
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
   jge cond_gr_v_line_14
   clr r2
cond_gr_v_line_14:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_v_line_13
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
for_gr_v_line_12:
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
   jmp for_gr_v_line_11
for_gr_v_line_13:
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
   ret

;------------------------------------------------------------------
; Graphics - Draw a line with colour 'col' from (x1,y1) to (x2, y2)
;
; Location: ROM addr 0x0440
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;------------------------------------------------------------------

.= 0x0440

gr_line:
   push lr
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
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
   add r0,r1,r0
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
   jeq cond_gr_line_17
   clr r2
cond_gr_line_17:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_15
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
if_gr_line_15:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_gr_line_20
   clr r2
cond_gr_line_20:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_18
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
if_gr_line_18:
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
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_gr_line_23
   clr r2
cond_gr_line_23:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_21
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
if_gr_line_21:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_gr_line_26
   clr r2
cond_gr_line_26:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_24
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
if_gr_line_24:
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
   jgt cond_gr_line_29
   clr r2
cond_gr_line_29:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_27
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
if_gr_line_27:
   ldi idx,-1
   ldx r0,[fp,idx]
   ldi r1,1
   lsl r0,r1,r0
   ldi idx,-10
   stx r0,[fp,idx]
   clr idx
   ldx r1,[fp,idx]
   sub r0,r1,r0
   ldi idx,-9
   stx r0,[fp,idx]
   sub r0,r1,r0
   ldi idx,-11
   stx r0,[fp,idx]
   ldi r0,0
   ldi idx,-7
   stx r0,[fp,idx]
for_gr_line_30:
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
   jgt cond_gr_line_33
   clr r2
cond_gr_line_33:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_line_32
   ldi idx,-9
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_gr_line_36
   clr r2
cond_gr_line_36:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_34
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_gr_line_39
   clr r2
cond_gr_line_39:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_line_37
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
   jmp if_gr_line_38
if_gr_line_37:
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
if_gr_line_38:
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
   jmp if_gr_line_35
if_gr_line_34:
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
if_gr_line_35:
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,-3
   ldx r1,[fp,idx]
   ldi idx,5
   ldx r2,[fp,idx]
   call gr_pixel
for_gr_line_31:
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
   jmp for_gr_line_30
for_gr_line_32:
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
   ret

;----------------------------------------------------------------------------
; Graphics - Draw a rectangle with colour 'col' and corners (x1,y1) & (x2,y2)
;
; Location: ROM addr 0x0670
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;----------------------------------------------------------------------------

.= 0x0670

gr_rect:
   push lr
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
   ret

;-----------------------------------------------------------------------------------
; Graphics - Draw a filled rectangle with colour 'col' and corners (x1,y1) & (x2,y2)
;
; Location: ROM addr 0x06d0
;
; Inputs: R0 = x1
;         R1 = y1
;         R2 = x2
;         R3 = y2
;         R4 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;-----------------------------------------------------------------------------------

.= 0x06d0

gr_rect_fill:
   push lr
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
for_gr_rect_fill_37:
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
   jge cond_gr_rect_fill_40
   clr r2
cond_gr_rect_fill_40:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq for_gr_rect_fill_39
   ldi idx,1
   ldx r0,[fp,idx]
   ldi idx,3
   ldx r1,[fp,idx]
   ldi idx,0
   ldx r2,[fp,idx]
   ldi idx,5
   ldx r3,[fp,idx]
   call gr_h_line
for_gr_rect_fill_38:
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
   jmp for_gr_rect_fill_37
for_gr_rect_fill_39:
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
   ret

;--------------------------------------------------
; Graphics - calc1(P,y) : A circle helper function
;
; Location: ROM addr 0x0730
;
; Inputs: R0 = P
;         R1 = y
; Output: R0 = P + 2*y + 1
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;--------------------------------------------------

.= 0x0730

gr_calc1:
   push lr
   push fp
   push r1
   push r0
   movsp fp
   ldi idx,2
   ldx r0,[fp,idx]
   ldi r1,1
   lsl r0,r1,r0
   ldi idx,1
   ldx r1,[fp,idx]
   add r0,r1,r0
   inc r0
ret_gr_calc1:
   pop idx
   pop idx
   pop fp
   pop lr
   ret

;----------------------------------------------------
; Graphics - calc2(P,x,y) : A circle helper function
;
; Location: ROM addr 0x0760
;
; Inputs: R0 = P
;         R1 = x
;         R2 = y
; Output: R0 = P - 2*x + 2*y + 1
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;----------------------------------------------------

.= 0x0760

gr_calc2:
   push lr
   push fp
   push r2
   push r1
   push r0
   movsp fp
   ldi idx,3
   ldx r0,[fp,idx]
   ldi r2,1
   lsl r0,r2,r0
   ldi idx,2
   ldx r1,[fp,idx]
   lsl r1,r2,r1
   not r1,r1
   inc r1
   add r0,r1,r0
   ldi idx,1
   ldx r1,[fp,idx]
   add r0,r1,r0
   inc r0
ret_gr_calc2:
   pop idx
   pop idx
   pop idx
   pop fp
   pop lr
   ret

;--------------------------------------------------------------------------
; Graphics - Draw a circle with colour 'col', centre '(x,y)' & radius 'r'
;
; Location: ROM addr 0x0790
;
; Inputs: R0 = x
;         R1 = y
;         R2 = r
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;--------------------------------------------------------------------------

.= 0x0790

gr_circle:
   push lr
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
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
while_gr_circle_41:
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
   jgt cond_gr_circle_43
   clr r2
cond_gr_circle_43:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_gr_circle_42
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
   jeq cond_None_46
   clr r2
cond_None_46:
   mov r2,r0
   push r0
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jge cond_None_47
   clr r2
cond_None_47:
   mov r2,r0
   push r0
   pop r1
   pop r0
   ldi r2,1
   clr r3
   cmp r0,r3
   jgt cond_gr_circle_48
   cmp r1,r3
   jgt cond_gr_circle_48
   clr r2
cond_gr_circle_48:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_44
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,-1
   ldx r1,[fp,idx]
   call gr_calc1
   ldi idx,-2
   stx r0,[fp,idx]
   jmp if_gr_circle_45
if_gr_circle_44:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   not r1,r1
   inc r1
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,0
   ldx r1,[fp,idx]
   ldi idx,-1
   ldx r2,[fp,idx]
   call gr_calc2
   ldi idx,-2
   stx r0,[fp,idx]
if_gr_circle_45:
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
   jgt cond_gr_circle_51
   clr r2
cond_gr_circle_51:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_49
   clr r0
   jmp ret_gr_circle
if_gr_circle_49:
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
   jeq cond_gr_circle_54
   inc r2
cond_gr_circle_54:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_52
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
   not r1,r1
   inc r1
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
if_gr_circle_52:
   jmp while_gr_circle_41
while_gr_circle_42:
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
   ret

;---------------------------------------------------------------------------------
; Graphics - Draw a filled circle with colour 'col', centre '(x,y)' & radius 'r'
;
; Location: ROM addr 0x0a70
;
; Inputs: R0 = x
;         R1 = y
;         R2 = r
;         R3 = col
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'Graphics.rmg'
;---------------------------------------------------------------------------------

.= 0x0a70

gr_circle_fill:
   push lr
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
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
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
while_gr_circle_fill_55:
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
   jgt cond_gr_circle_fill_57
   clr r2
cond_gr_circle_fill_57:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_gr_circle_fill_56
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
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
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
   jgt cond_gr_circle_fill_62
   cmp r1,r3
   jgt cond_gr_circle_fill_62
   clr r2
cond_gr_circle_fill_62:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_58
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,-1
   ldx r1,[fp,idx]
   call gr_calc1
   ldi idx,-2
   stx r0,[fp,idx]
   jmp if_gr_circle_fill_59
if_gr_circle_fill_58:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   not r1,r1
   inc r1
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,0
   stx r0,[fp,idx]
   ldi idx,-2
   ldx r0,[fp,idx]
   ldi idx,0
   ldx r1,[fp,idx]
   ldi idx,-1
   ldx r2,[fp,idx]
   call gr_calc2
   ldi idx,-2
   stx r0,[fp,idx]
if_gr_circle_fill_59:
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
   jgt cond_gr_circle_fill_65
   clr r2
cond_gr_circle_fill_65:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_63
   clr r0
   jmp ret_gr_circle_fill
if_gr_circle_fill_63:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
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
   jeq cond_gr_circle_fill_68
   inc r2
cond_gr_circle_fill_68:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_gr_circle_fill_66
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   not r1,r1
   inc r1
   add r0,r1,r0
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
   not r1,r1
   inc r1
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
if_gr_circle_fill_66:
   jmp while_gr_circle_fill_55
while_gr_circle_fill_56:
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
   ret

;---------------------------
; Maths - Modulus (int)
;
; Location: ROM addr 0x0ca0
;
; Inputs: R0 = x
;         R1 = y
;
; Output: R0 = x % y
;---------------------------

.= 0x0ca0

math_mod:
   push r2              ; Save used register

   clr r2               ; Test for division by 0
   cmp r1,r2
   jne mod_calc

   jmp DIV_BY_0         ; Division by 0 - Display error code

mod_calc:
   udiv r0,r1,r2        ; mod = x - y*(x/y)
   mul r2,r1,r2
   sub r0,r2,r0

   pop r2               ; Retrieve register
   ret

;-----------------------------------------
; Strings - Get a string length
;
; Location: ROM addr 0x0cc0
;
; Input  - R0 = The address of the string
; Output - R0 = The string length
;-----------------------------------------

.= 0x0cc0

str_len:
   push idx             ; Save used registers
   push r3
   push r2
   push r1

   clr r2               ; r2 = char count
   clr r3               ; r3 is used to test for null (end of string)
   clr idx

len_loop:
   ldx r1,[r0,idx]      ; r1 = next char
   cmp r1,r3            ; Is char null ?
   jeq len_done
   inc r2               ; Increment char count
   inc idx
   jmp len_loop

len_done:
   mov r2,r0            ; r0 = string length

   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop idx
   ret

;------------------------------------------
; Strings - Convert a string to upper case
;
; Location: ROM addr 0x0cf0
;
; Input - R0 = The address of the string
;------------------------------------------

.= 0x0cf0

str_upper:
   push fp              ; Save used registers
   push idx
   push r4
   push r3
   push r2
   push r1

   ldi r2,0x61          ; 'a'
   ldi r3,0x7a          ; 'z'
   ldi r4,0x20          ; Lower to Upper difference
   clr fp               ; fp is used to test for null (end of string)
   clr idx

up_next:
   ldx r1,[r0,idx]      ; Get char
   cmp r1,fp            ; End of string ?
   jeq up_done

   cmp r1,r2            ; Less than 'a' ?
   jlt up_no_change

   cmp r1,r3            ; Greater than 'z' ?
   jgt up_no_change

   sub r1,r4,r1         ; Change case & store
   stx r1,[r0,idx]

up_no_change:
   inc idx              ; Do next char
   jmp up_next

up_done:
   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   ret

;------------------------------------
; BIOS - Delay (in ms)
;
; Location: ROM addr 0x0d30
;
; Input - R0 = Number of ms to delay
;------------------------------------

.= 0x0d30

os_delay_ms:
   push r1              ; Save used register

dms_outer:
   ldi r1,DELAY_MS      ; r1 = 1ms delay

dms_inner:
   dec r1
   jnz dms_inner        ; stay in 'inner loop' for 1ms

   dec r0
   jnz dms_outer        ; stay in 'outer loop' for r0 ms

   pop r1               ; Retrieve register
   ret


;----------------------------------------------------------------
; BIOS - Terminate a program, and if the error code is non-zero:
;          Display an Error Code on OUT
;          Turn on the ERR LED
;
; Location: ROM addr 0x0d50
;
; Input - R0 = Error Code
;----------------------------------------------------------------

.= 0x0d50

os_exit:
   clr r1               ; Error Code = 0 ?
   cmp r0,r1
   jne disp_err
   end                  ; No error - Just stop the program

disp_err:
   call os_disp_out     ; Display the Error Code
   ldi r0,1             ; Turn the ERR LED on
   ldi r1,ERR
   st r0,[r1]
   end                  ; Stop the program

