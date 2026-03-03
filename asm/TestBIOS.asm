
;---------------
; Test the BIOS
;---------------

.RAM

; BIOS Defines
.equ os_get_in      0x1000
.equ os_disp_out    0x1030
.equ os_read_char   0x1050
.equ os_print_char  0x1080
.equ os_read_str    0x10a0
.equ os_print_str   0x10e0
.equ os_mem_set     0x1110
.equ os_mem_setn    0x1130
.equ os_mem_read    0x1150
.equ os_read_int    0x1170
.equ os_print_int   0x11d0
.equ os_read_uint   0x1230
.equ os_print_uint  0x1280
.equ os_read_float  0x1330
.equ os_print_float 0x16b0
.equ os_exit        0x1a90

.equ IN_1  3
.equ IN_2  7
.equ OUT_1 6
.equ OUT_2 10

.code

;------------
; Test Cases
;------------
main:
   jmp test_1

test_1:
   ; Transfer IN_1 -> OUT_2
   ldi r0,IN_1
   call os_get_in
   mov r0,r1
   ldi r0,OUT_2
   call os_disp_out
   end

test_2:
   ; Transfer a char from KBD to TTY
   call os_read_char
   push r0                 ; Save char on stack
   ldi r0,0x0a             ; Line feed
   call os_print_char
   pop r0                  ; Retrieve char
   call os_print_char
   ldi r0,0x0a             ; Line feed
   call os_print_char
   end

test_3:
   ; Transfer a string from KBD to TTY via Mem 0xc000
   ldi r0,0xc000
   call os_read_str
   ldi r0,0x0a             ; Line feed
   call os_print_char
   ldi r0,0xc000
   call os_print_str
   ldi r0,0x0a             ; Line feed
   call os_print_char
   end

test_4:
   ; Set Mem 0xc000 = 0x1234 & then read it back into r0
   ldi r0,0xc000
   ldi r1,0x1234
   call os_mem_set
   call os_mem_read
   end

test_5:
   ; Set Mem region 0xc000 to 0xc00f = 0xffff
   ldi r0,0xc000
   ldi r1,16
   ldi r2,0xffff
   call os_mem_setn
   end

test_6:
   ; Transfer an integer from KBD to TTY via r4
   call os_read_int
   mov r0,r4
   ldi r0,0x0a             ; Line feed
   call os_print_char
   mov r4,r0
   call os_print_int
   ldi r0,0x0a             ; Line feed
   call os_print_char
   end

test_7:
   ; Transfer an unsigned integer from KBD to TTY via r4
   call os_read_uint
   mov r0,r4
   ldi r0,0x0a             ; Line feed
   call os_print_char
   mov r4,r0
   call os_print_uint
   ldi r0,0x0a             ; Line feed
   call os_print_char
   end

test_8:
   ; Transfer a float from KBD to TTY via r4 & stack
   call os_read_float
   mov r0,r4
   push r4
   mov r4,r0
   call os_print_float
   ldi r0,0x0a             ; Line feed
   call os_print_char
   pop r4
   end

test_9:
   ; Exit with Error Code: 0x1066
   ldi r0,0x1066
   call os_exit

