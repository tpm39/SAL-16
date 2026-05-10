
;-----------------------------------------------------------
; Perform the int calculation of 2 unsigned numbers entered
; via the keyboard & show the result on the display
;-----------------------------------------------------------

.RAM

; BIOS Defines
.equ os_read_str   0x10a0
.equ os_print_str  0x10e0
.equ os_read_uint  0x1230
.equ os_print_uint 0x1280

; Maths Library Define
.equ math_mod 0x2730

; String Library Defines
.equ str_len   0x4000
.equ str_upper 0x4140

; Error Code
.equ DIV_BY_0 0x0100

; ASCII Chars
.equ CHAR_MOD 0x25
.equ CHAR_MUL 0x2a
.equ CHAR_ADD 0x2b
.equ CHAR_SUB 0x2d
.equ CHAR_DIV 0x2f
.equ CHAR_Q   0x51

.code

;---------
; Program
;---------
main:
   ldi r0,title         ; Display Title
   call os_print_str

	call do_lf				; New line

   ldi r0,uline			; Display underline
   call os_print_str

	call do_lf				; 2 new lines
	call do_lf

   ldi r0,ops				; Display valid ops
   call os_print_str

	call do_lf				; 2 new lines
	call do_lf

   ldi r0,quit				; Display quit
   call os_print_str

next_calc:
	call do_lf				; 2 new lines
	call do_lf

   ldi r0,x					; Display x prompt
   call os_print_str

	call os_read_uint		; Get, display & store x
	ldi r2,xval
	st r0,[r2]

	call do_lf				; New line

   ldi r0,op				; Display op prompt
   call os_print_str

	call read_op			; Get, display & store op

	call do_lf				; New line

   ldi r0,y					; Display y prompt
   call os_print_str

	call os_read_uint		; Get, display & store y
	ldi r2,yval
	st r0,[r2]

	call do_lf				; 2 new lines
	call do_lf

   ldi r0,ans				; Display result prompt
   call os_print_str

	ldi r2,xval				; Perform the calculation
	ld r0,[r2]
	ldi r2,yval
	ld r1,[r2]
	call do_calc      	; r0 = x op y

	call os_print_uint	; Display the result

	jmp next_calc

;-------------------------------------
; Read the operator from the keyboard
;-------------------------------------
read_op:
	push lr 					; Save return address

	ldi r0,val				; Get the op
	call os_read_str

	ldi r1,1					; Is len(op) = 1 ?
	call str_len
	cmp r0,r1
	jne read_inv_op		; It's invalid if it's not

	ldi r0,val				; Store upper case op
	call str_upper
	ld r1,[r0]
	ldi r2,opval
	st r1,[r2]

	ldi r2,CHAR_Q			; if op = 'Q' we're done
	cmp r1,r2
	jne read_chk_add
	call say_bye

read_chk_add:
	ldi r2,CHAR_ADD		; if op = '+' we're OK
	cmp r1,r2
	jne read_chk_sub
	jmp read_op_done

read_chk_sub:
	ldi r2,CHAR_SUB		; if op = '-' we're OK
	cmp r1,r2
	jne read_chk_mul
	jmp read_op_done

read_chk_mul:
	ldi r2,CHAR_MUL		; if op = '*' we're OK
	cmp r1,r2
	jne read_chk_div
	jmp read_op_done

read_chk_div:
	ldi r2,CHAR_DIV		; if op = '/' we're OK
	cmp r1,r2
	jne read_chk_mod
	jmp read_op_done

read_chk_mod:
	ldi r2,CHAR_MOD		; if op = '%' we're OK
	cmp r1,r2
	jne read_inv_op
	
read_op_done:
	pop lr					; Retrieve return address
	ret

read_inv_op:
	call do_lf				; Display 'Invalid Op'
	call do_lf
	ldi r0,inv_op
	call os_print_str
	pop lr					; No longer need return address
	jmp next_calc

;---------------------
; Do the Calculation
; 
; Inputs: R0 - x
;         R1 - y
; Output: R0 - x op y
;---------------------
do_calc:
	push lr 					; Save return address

	ldi r2,opval			; Get the op
	ld r2,[r2]

	ldi r3,CHAR_ADD		; op = '+' ?
	cmp r2,r3
	jne calc_sub

	add r0,r1,r0			; Do the addition & return
	jmp calc_done

calc_sub:
	ldi r3,CHAR_SUB		; op = '-' ?
	cmp r2,r3
	jne calc_mul

	sub r0,r1,r0			; Do the subtraction & return
	jmp calc_done

calc_mul:
	ldi r3,CHAR_MUL		; op = '*' ?
	cmp r2,r3
	jne calc_div

	mul r0,r1,r0			; Do the multiplication
	jmp calc_done

calc_div:
	ldi r3,CHAR_DIV		; op = '/' ?
	cmp r2,r3
	jne calc_mod

   clr r2               ; Test for division by 0
   cmp r1,r2
   jne calc_div_ok

   jmp DIV_BY_0         ; Division by 0 - Display error code

calc_div_ok:
	udiv r0,r1,r0			; Do the division
	jmp calc_done

calc_mod:
	ldi r3,CHAR_MOD		; op = '%' ?
	cmp r2,r3
	jne calc_inv_op

   clr r2               ; Test for division by 0
   cmp r1,r2
   jne calc_mod_ok

   jmp DIV_BY_0         ; Division by 0 - Display error code

calc_mod_ok:
	call math_mod			; Do the modulus

calc_done:
	jc carry					; Check for carry
	pop lr					; Retrieve return address
	ret

carry:
	call do_lf				; Display 'Out of Range'
	ldi r0,out_range
	call os_print_str
	pop lr					; No longer need return address
	jmp next_calc

calc_inv_op:				; A bad op: Shouldn't get here ... But if so: We're done
	end

;----------------
; Do a Line Feed
;----------------
do_lf:
	push lr 					; Save return address & used register
	push r0

   ldi r0,LF				; Do the LF
	call os_print_str
	
	pop r0					; Retrieve used register & return address	
	pop lr
	ret

;-----------
; Say 'Bye'
;-----------
say_bye:
	call do_lf				; A couple of new lines
	call do_lf
   ldi r0,bye				; Display bye
	call os_print_str
	call do_lf				; Another couple of new lines
	call do_lf
	end						; We're done

;------
; Data
;------
.data

title:     str "Unsigned Int Calc"
uline:     str "================="
ops:       str "Valid Ops: + - * / %"
quit:      str "Enter 'Q' for 'Op' to Quit"
x:         str "X: "
y:         str "Y: "
op:        str "Op: "
inv_op:    str "Invalid Op ..."
ans:       str "Result: "
out_range: str "??? - Out of Range"
bye:       str "Bye Now :)"

LF: array [0x0a, 0x00]

xval: word 0
yval: word 0
opval: word 0
val: str 16

