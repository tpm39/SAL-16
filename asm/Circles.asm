
;-----------------------------------------------------------------------------------------------
; Test the Misc & Circle Libraries
;
; The machine code files are are linked together to form CircsCode.mc:
;
; python3 ./Tools/Linker.py ./mc/CircsCode.mc ./mc/Circles.mc ./mc/CircleLib.mc ./mc/MiscLib.mc
;-----------------------------------------------------------------------------------------------

.RAM

; Circle Library Defines
.equ circ_circum 0x9000
.equ circ_area   0x9010
.equ circ_radius 0x9020

; Misc Library Define
.equ misc_end 0xa000

; Floating Point Constants
.equ F10 10.0
.equ F20 20.0
.equ F30 30.0

.code

main:
   ; Calculate a circumference
   ldi r0,F10
   call circ_circum
   ldi r1,circum
   st r0,[r1]

   ; Calculate an area
   ldi r0,F20
   call circ_area
   ldi r1,area
   st r0,[r1]

   ; Calculate a radius
   ldi r0,F30
   call circ_radius
   ldi r1,radius
   st r0,[r1]

   ; Display "Baseball Cool"
   call misc_end


.data

.= 0x8100

circum: word 0    ; -> 0x53db (62.832)
area:   word 0    ; -> 0x64e9 (1256.637)
radius: word 0    ; -> 0x422e (3.090)

