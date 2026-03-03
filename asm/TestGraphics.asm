
;---------------------------
; Test the Graphics Library
;---------------------------

.RAM

; Graphics Library Defines
.equ gr_pixel       0x3000
.equ gr_line        0x31a0
.equ gr_rect        0x33f0
.equ gr_rect_fill   0x3450
.equ gr_circle      0x34c0
.equ gr_circle_fill 0x37d0
.equ gr_fp_pixel    0x3a40

.equ GR_RED       0xf800
.equ GR_BLUE      0x001f
.equ GR_GREEN     0x07e0
.equ GR_DK_GREEN  0x0560
.equ GR_BLACK     0x0000
.equ GR_WHITE     0xffff
.equ GR_BROWN     0x9260
.equ GR_LT_BROWN  0xdd0d
.equ GR_GOLD      0xfea0
.equ GR_SILVER    0xbdf7
.equ GR_ORANGE    0xfcc0
.equ GR_TURQUOISE 0x273a
.equ GR_PURPLE    0xa01f
.equ GR_PINK      0xebda
.equ GR_FUCHSIA   0xf81f
.equ GR_CYAN      0x07ff
.equ GR_BKGRD     0xffd7

.code

main:
   ; Test Cases

   call test_all

   ;call cube

   ;call lines

   ;call wheel

   ;call shapes
   
   end

; Draw one of each of the points/shapes
test_all:
   push lr

   ; Plot a red pixel at (127,127)
   ldi r0,127  
   ldi r1,127
   ldi r2,GR_RED
   call gr_pixel

   ; Draw a blue line from (50,50) to (55,55)
   ldi r0,50  
   ldi r1,50
   ldi r2,55
   ldi r3,55
   ldi r4,GR_BLUE
   call gr_line

   ; Draw a brown rectangle with corners (55,55) & (60,60)
   ldi r0,55
   ldi r1,55
   ldi r2,60
   ldi r3,60
   ldi r4,GR_BROWN
   call gr_rect

   ; Draw a cyan filled rectangle with corners (60,60) & (65,65)
   ldi r0,60
   ldi r1,60
   ldi r2,65  
   ldi r3,65
   ldi r4,GR_CYAN
   call gr_rect_fill

   ; Draw a pink circle with centre (190,60) & radius 5
   ldi r0,190  
   ldi r1,60
   ldi r2,5
   ldi r3,GR_PINK
   call gr_circle

   ; Draw a green filled circle with centre (190,190) & radius 5
   ldi r0,190  
   ldi r1,190
   ldi r2,5
   ldi r3,GR_GREEN
   call gr_circle_fill

   ; Plot a black pixel at (-60,-60) (On the 'floating point grid')
   ldi r0,-60.0
   ldi r1,-60.0
   ldi r2,GR_BLACK
   call gr_fp_pixel

   pop lr
   ret

; Draw a wireframe cube
cube:
   push lr

   ; Draw a red rectangle
   ldi r0,89   
   ldi r1,89
   ldi r2,141
   ldi r3,141
   ldi r4,GR_RED
   call gr_rect

   ; Draw a blue rectangle
   ldi r0,115
   ldi r1,115
   ldi r2,167
   ldi r3,167
   ldi r4,GR_BLUE
   call gr_rect

   ; Draw 4 green "connecting" lines
   ldi r0,89
   ldi r1,89
   ldi r2,115
   ldi r3,115
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,141
   ldi r1,89
   ldi r2,167
   ldi r3,115
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,89
   ldi r1,141
   ldi r2,115
   ldi r3,167
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,141
   ldi r1,141
   ldi r2,167
   ldi r3,167
   ldi r4,GR_GREEN
   call gr_line

   pop lr
   ret

; Draw a bunch of lines in a box
lines:
   push lr

   ldi r0,98 
   ldi r1,128
   ldi r2,158
   ldi r3,128
   ldi r4,GR_RED
   call gr_line

   ldi r0,98 
   ldi r1,113
   ldi r2,158
   ldi r3,143
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,98 
   ldi r1,98
   ldi r2,158
   ldi r3,158
   ldi r4,GR_RED
   call gr_line

   ldi r0,113 
   ldi r1,98
   ldi r2,143
   ldi r3,158
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,128 
   ldi r1,98
   ldi r2,128
   ldi r3,158
   ldi r4,GR_RED
   call gr_line

   ldi r0,143 
   ldi r1,98
   ldi r2,113
   ldi r3,158
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,158 
   ldi r1,98
   ldi r2,98
   ldi r3,158
   ldi r4,GR_RED
   call gr_line

   ldi r0,158 
   ldi r1,113
   ldi r2,98
   ldi r3,143
   ldi r4,GR_GREEN
   call gr_line

   ldi r0,98 
   ldi r1,98
   ldi r2,158
   ldi r3,158
   ldi r4,GR_BLUE
   call gr_rect

   pop lr
   ret

; Draw a "wheel"
wheel:
   push lr

   ; Draw a purple "tyre"
   ldi r0,128
   ldi r1,128
   ldi r2,50
   ldi r3,GR_PURPLE
   call gr_circle

   ; Draw 8 turquoise "spokes"
   ldi r0,78
   ldi r1,128
   ldi r2,178
   ldi r3,128
   ldi r4,GR_TURQUOISE
   call gr_line

   ldi r0,128
   ldi r1,78
   ldi r2,128
   ldi r3,178
   ldi r4,GR_TURQUOISE
   call gr_line

   ldi r0,93
   ldi r1,163
   ldi r2,163
   ldi r3,93
   ldi r4,GR_TURQUOISE
   call gr_line

   ldi r0,93
   ldi r1,93
   ldi r2,163
   ldi r3,163
   ldi r4,GR_TURQUOISE
   call gr_line

   ; Draw a blue "axle"
   ldi r0,128
   ldi r1,128
   ldi r2,4
   ldi r3,GR_BLUE
   call gr_circle_fill

   pop lr
   ret

; Draw some shapes
shapes:
   push lr

   ldi r0,70
   ldi r1,70
   ldi r2,103
   ldi r3,170
   ldi r4,GR_ORANGE
   call gr_line

   ldi r0,70
   ldi r1,70
   ldi r2,128
   ldi r3,170
   ldi r4,GR_ORANGE
   call gr_line

   ldi r0,128
   ldi r1,170
   ldi r2,186
   ldi r3,70
   ldi r4,GR_ORANGE
   call gr_line

   ldi r0,153
   ldi r1,170
   ldi r2,186
   ldi r3,70
   ldi r4,GR_ORANGE
   call gr_line

   ldi r0,103
   ldi r1,170
   ldi r2,153
   ldi r3,195
   ldi r4,GR_PURPLE
   call gr_rect

   ldi r0,112
   ldi r1,175
   ldi r2,144
   ldi r3,190
   ldi r4,GR_RED
   call gr_rect_fill

   ldi r0,128
   ldi r1,113
   ldi r2,29
   ldi r3,GR_PINK
   call gr_circle

   ldi r0,128
   ldi r1,113
   ldi r2,20
   ldi r3,GR_TURQUOISE
   call gr_circle_fill

   pop lr
   ret

