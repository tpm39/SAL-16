
;-----------------------------------------------------------
; Strings Library for TimmiOS - The SAL-16 Operating System
;-----------------------------------------------------------

;--------------------------------------------
; Defines for use in programs using TimmiOS:
;
; .equ str_len    0x4000
; .equ str_cat    0x4030
; .equ str_cpy    0x4060
; .equ str_cmp    0x4090
; .equ str_substr 0x40c0
; .equ str_lower  0x4100
; .equ str_upper  0x4140
;--------------------------------------------

.ROM

.code

;-----------------------------------------
; Strings - Get a string length
;
; Location: ROM addr 0x4000
;
; Input  - R0 = The address of the string
; Output - R0 = The string length
;-----------------------------------------

.= 0x4000

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

;---------------------------------------------------
; Strings - Concatenation
;
; Location: ROM addr 0x4030
;
; Inputs - R0 = The address of the first string
;          R1 = The address of the second string
;          R2 = The address of the resulting string
;---------------------------------------------------

.= 0x4030

str_cat:
   push fp              ; Save used registers
   push idx
   push r4
   push r3

   clr idx
   clr r4               ; r4 is used to test for null (end of string)
   clr fp               ; fp is used as index to the 2nd string

cat_loop_1:
   ldx r3,[r0,idx]      ; r3 = next char of the 1st string
   cmp r3,r4            ; Is char null ?
   jeq cat_loop_2
   stx r3,[r2,idx]      ; Copy char to the resulting string
   inc idx
   jmp cat_loop_1

cat_loop_2:
   ldx r3,[r1,fp]       ; r3 = next char of the 2nd string
   cmp r3,r4            ; Is char null ?
   jeq cat_done
   stx r3,[r2,idx]      ; Copy char to the resulting string
   inc idx
   inc fp
   jmp cat_loop_2

cat_done:
   stx r4,[r2,idx]      ; Append null to the resulting string

   pop r3               ; Retrieve registers
   pop r4
   pop idx
   pop fp
   ret

;-----------------------------------------------------
; Strings - Copy a string
;
; Location: ROM addr 0x4060
;
; Inputs - R0 = The address of the source string
;          R1 = The address of the destination string
;-----------------------------------------------------

.= 0x4060

str_cpy:
   push idx             ; Save used registers
   push r3
   push r2

   clr idx
   clr r3               ; r3 is used to test for null (end of string)

cpy_loop:
   ldx r2,[r0,idx]      ; r2 = next char of the source string
   cmp r2,r3            ; Is char null ?
   jeq cpy_done
   stx r2,[r1,idx]      ; Copy char to the destination string
   inc idx
   jmp cpy_loop

cpy_done:
   stx r3,[r1,idx]      ; Append null to the destination string

   pop r2               ; Retrieve registers
   pop r3
   pop idx
   ret

;------------------------------------------------
; Strings - Compare two strings
;
; Location: ROM addr 0x4090
;
; Inputs - R0 = The address of the first string
;          R1 = The address of the second string
; Output - R0 = 0xffff/0x0000 (Same/Different)
;------------------------------------------------

.= 0x4090

str_cmp:
   push idx             ; Save used registers
   push r4
   push r3
   push r2

   clr idx
   clr r4               ; r4 is used to test for null (end of string)

cmp_loop:
   ldx r2,[r0,idx]      ; r2 = next char of the 1st string
   ldx r3,[r1,idx]      ; r3 = next char of the 2nd string
   cmp r2,r3            ; Are they different ?
   jne cmp_diff
   cmp r2,r4            ; Is char null ?
   jeq cmp_same
   inc idx
   jmp cmp_loop

cmp_diff:
   clr r0               ; r0 = 0x0000 (strings are different)
   jmp cmp_done

cmp_same:
   ldi r0,0xffff        ; r0 = 0xffff (strings are the same)

cmp_done:
   pop r2               ; Retrieve registers
   pop r3
   pop r4
   pop idx
   ret

;---------------------------------------------------
; Strings - Get a substring of a string
;
; Location: ROM addr 0x40c0
;
; Inputs - R0 = The address of the string
;          R1 = The address of the substring
;          R2 = 1st char position within the string
;          R3 = Number of chars in the substring
;---------------------------------------------------

.= 0x40c0

str_substr:
   push fp              ; Save used registers
   push idx
   push r4

   clr idx
   clr fp               ; fp is used to test for null (end of string)

   add r2,r3,r4         ; r4 = Last char position within the string

sub_loop_1:
   ldx r3,[r0,idx]      ; r3 = next char of the string
   cmp r3,fp            ; Is char null ?
   jeq sub_done
   cmp idx,r2           ; Reached the 1st position ?
   jeq sub_copy
   inc idx
   jmp sub_loop_1

sub_copy:
   clr r2               ; r2 = index within substring

sub_loop_2:
   ldx r3,[r0,idx]      ; r3 = next char of the string
   cmp r3,fp            ; Is char null ?
   jeq sub_done
   cmp idx,r4           ; Reached the last position ?
   jeq sub_done
   stx r3,[r1,r2]       ; Store the next char in the substring
   inc r2
   inc idx
   jmp sub_loop_2

sub_done:
   stx fp,[r1,r2]       ; Append null to the substring

   pop r4               ; Retrieve registers
   pop idx
   pop fp
   ret

;------------------------------------------
; Strings - Convert a string to lower case
;
; Location: ROM addr 0x4100
;
; Input - R0 = The address of the string
;------------------------------------------

.= 0x4100

str_lower:
   push fp              ; Save used registers
   push idx
   push r4
   push r3
   push r2
   push r1

   ldi r2,0x41          ; 'A'
   ldi r3,0x5a          ; 'Z'
   ldi r4,0x20          ; Lower to Upper difference
   clr fp               ; fp is used to test for null (end of string)
   clr idx

low_next:
   ldx r1,[r0,idx]      ; Get char
   cmp r1,fp            ; End of string ?
   jeq low_done

   cmp r1,r2            ; Less than 'A'
   jlt low_no_change

   cmp r1,r3            ; Greater than 'Z'
   jgt low_no_change

   add r1,r4,r1         ; Change case & store
   stx r1,[r0,idx]

low_no_change:
   inc idx              ; Do next char
   jmp low_next

low_done:
   pop r1               ; Retrieve registers
   pop r2
   pop r3
   pop r4
   pop idx
   pop fp
   ret

;------------------------------------------
; Strings - Convert a string to upper case
;
; Location: ROM addr 0x4140
;
; Input - R0 = The address of the string
;------------------------------------------

.= 0x4140

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

