
;--------------------------
; Test the Strings Library
;--------------------------

.RAM

; Strings Library Defines
.equ str_len    0x4000
.equ str_cat    0x4030
.equ str_cpy    0x4060
.equ str_cmp    0x4090
.equ str_substr 0x40c0
.equ str_lower  0x4100
.equ str_upper  0x4140

; BIOS Defines
.equ os_print_char 0x1080
.equ os_print_str  0x10e0

.code

;------------
; Test Cases
;------------
main:
   jmp test_1

test_1:
   ; String length
   ldi r0,HiYa
   call str_len         ; r0 = Length of "Hi Ya Timmi !!" = 14
   end
   
test_2:
   ; String concatenation
   ldi r0,Nums1
   ldi r1,Nums2
   ldi r2,Nums5
   call str_cat
   ldi r0,Nums5
   jmp display          ; Display Nums5 = "12" + "3456" = "123456"

test_3:
   ; String copy
   ldi r0,Nums3
   ldi r1,Nums5
   call str_cpy
   ldi r0,Nums5
   jmp display          ; Display Nums5 = Nums3 = "3456"

test_4:
   ; String comparison
   ldi r0,Nums1
   ldi r1,Nums2
   call str_cmp 
   mov r0,r4            ; "12" & "3456" are different so r4 -> 0x0000

   ldi r0,Nums2
   ldi r1,Nums3
   call str_cmp         ; "3456" & "3456" are the same so r0 -> 0xffff
   end

test_5:
   ; Get a substring
   ldi r0,Nums4
   ldi r1,Nums5
   ldi r2,2
   ldi r3,5
   call str_substr 
   ldi r0,Nums5
   jmp display          ; Display Nums5 = Nums4[2:6] = "23456"

test_6:
   ; Convert to upper case
   ldi r0,HiYa
   call str_upper
   jmp display          ; Display HiYa = "HI YA TIMMI !!"

test_7:
   ; Convert to lower case
   ldi r0,GDay
   call str_lower       ; Display GDay = "g'day sal :)"

display:
   call os_print_str    ; Display on the TTY
   ldi r0,0x0a
   call os_print_char
   end

;------
; Data
;------
.data

.= 0x9000

HiYa: str "Hi Ya Timmi !!"
GDay: str "G'Day Sal :)"

Nums1: str "12"
Nums2: str "3456"
Nums3: str "3456"
Nums4: str "0123456789"
Nums5: str 10

