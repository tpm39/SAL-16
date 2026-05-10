
;--------------------------------------------
; A Wee Hardware/Software Sanity Check !! :)
;
; Display 'IN + 1' on OUT
;--------------------------------------------

.RAM

; BIOS defines
.equ os_get_in   0x0020
.equ os_disp_out 0x0050

.code

main:
   call os_get_in       ; r3 = IN
   mov r0,r3

   ldi r4,1             ; r4 will be added to IN

   ldi r0,0x7fff        ; r2 = 0x8000 - Flags set: A,N & V
   ldi r1,0x0001
   add r0,r1,r2

   jv ovrfl             ; Check for overflow (there is)

   clr r4               ; Ignored

ovrfl:
   add r3,r4,r0         ; Display 'IN + 1'
   call os_disp_out
   end

