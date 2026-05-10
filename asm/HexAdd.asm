
;---------------------------------------------------
; Perform the hex addition of 2 numbers entered via
; the keyboard & show the result on the display.
;
; NB: The numbers must be 4 digits long, and no CR
;     should be used to enter them.
;---------------------------------------------------

.RAM

; Keyboard & Display addresses
.equ KBD 0xfff1
.equ TTY 0xfff2

.code

;---------
; Program
;---------
main:
   ldi r0,Title         ; Display Title
   call printStr

   ldi r0,LF            ; New line
   call printStr

   ldi r0,Line          ; Display underline
   call printStr

   ldi r0,LF            ; New line
   call printStr

   ldi r0,strX          ; Display "X:   "
   call printStr
   call readNum         ; Get & store X
   ldi r1,x
   st r0,[r1]

   ldi r0,LF            ; New line
   call printStr

   ldi r0,strY          ; Display "Y:   "
   call printStr
   call readNum         ; Get & store Y
   ldi r1,y
   st r0,[r1]

   ldi r0,LF            ; New line
   call printStr

   ldi r0,LF            ; New line
   call printStr

   ldi r0,Sum           ; Display "Sum: "
   call printStr

   ldi r0,x             ; Perform the addition
   ld r1,[r0]
   inc r0
   ld r2,[r0]
   add r1,r2,r0         ; R0 = X + Y

   call NumToStr        ; Convert result to chars

   ldi r0,Res           ; Display result
   call printStr

   ldi r0,LF            ; New line
   call printStr

   end

;---------------------------------------------
; Convert a 4 digit hex number to a string
;
; Input: R0 = Number to convert
; Output: The string is stored from addr Res1
;---------------------------------------------
NumToStr:
   push lr              ; Save return addr
   ldi r2,0x000f        ; Mask for getting 4 lsb's
   ldi r3,4             ; Shift amount & max digit count
   ldi r4,Res           ; Result addr pos
   add r4,r3,r4
   dec r4
   ldi fp,9             ; To test for an alpha char
   clr idx

next_pos:
   mov r0,r1
   lsr r0,r3,r0         ; Shift num right 4 bits
   and r1,r2,r1         ; Get 4 lsb's of num (the next digit)

   cmp r1,fp            ; Check for alpha or numeric
   jgt alpha_rts
   ldi lr,0x30          ; Numeric offset
   jmp store
alpha_rts:
   ldi lr,0x57          ; Alpha offset

store:
   add r1,lr,r1         ; Add offset to digit to get ascii code
   st r1,[r4]           ; Store digit in memory
   dec r4
   inc idx
   cmp idx,r3           ; Done all 4 digits ?
   jeq ret_rts
   jmp next_pos         ; Do next digit

ret_rts:
   pop lr               ; Retrieve return addr
   ret

;-----------------------------
; Print a char on the display
;
; Input: R1 = The char
;-----------------------------
printChr:
   push r0
   ldi r0,TTY
   st r1,[r0]
   pop r0
   ret

;-------------------------------------------
; Print a string from memory on the display
;
; Input: R0 = The string addr
;-------------------------------------------
printStr:
   ldi r1,TTY
   clr idx
   clr r3               ; R3 is used to test for null (end of string)

next_chr:
   ldx r2,[r0,idx]      ; Get the next char from memory
   cmp r2,r3            ; If it's a null we're done
   jeq ret_ps
   st r2,[r1]           ; Print the char
   inc idx
   jmp next_chr

ret_ps:
   ret

;---------------------------------------------
; Read a 4 digit hex number from the keyboard
; 
; Output: R0 = The number
;---------------------------------------------
readNum:
   push lr              ; Save return addr
   clr r0               ; R0 holds the number
   ldi r3,0x30          ; Numeric code offset
   ldi r4,0x57          ; Alpha code offset
   ldi fp,4             ; Max digit count
   clr idx

next_val:
   ldi lr,KBD           ; Read the next char from the keyboard
   ld r1,[lr]
   clr r2               ; Check for a char
   cmp r1,r2
   jeq next_val          ; If nothing read try again     

   call printChr        ; Display the digit

   ldi r2,0x60          ; Check for alpha or numeric
   cmp r1,r2
   jgt alpha_rn
   sub r1,r3,r1         ; Get value from numeric ascii code
   jmp update_val
alpha_rn:
   sub r1,r4,r1         ; Get value from alpha ascii code

update_val:
   mov r0,r2 
   lsl r2,fp,r2         ; Shift number left by 4 & 
   add r2,r1,r0         ; add current digit value

   inc idx              ; Done all 4 digits ?
   cmp idx,fp
   jeq ret_rn
   jmp next_val         ; Do next digit

ret_rn:
   pop lr               ; Retrieve return addr
   ret

;------
; Data
;------
.data

x: word 0
y: word 0

Title: str "Hex Add"
Line:  str "======="
strX:  str "X:   "
strY:  str "Y:   "
Sum:   str "Sum: "

Res: str 5

LF: array [0x0a, 0x00]

