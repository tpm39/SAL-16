
;-----------------------
; Draw a Christmas Tree
;-----------------------

.RAM

; Graphics Library Defines
.equ gr_pixel       0x3000
.equ gr_line        0x3300
.equ gr_rect        0x3600
.equ gr_rect_fill   0x3700
.equ gr_circle      0x3a00
.equ gr_circle_fill 0x3d00

.equ GR_RED       0xf800
.equ GR_BLUE      0x001f
.equ GR_GREEN     0x07e0
.equ GR_DK_GREEN  0x0560
.equ GR_BLACK     0x0000
.equ GR_WHITE     0xffff
.equ GR_BROWN     0x9260
.equ GR_GOLD      0xfea0
.equ GR_SILVER    0xbdf7
.equ GR_ORANGE    0xfcc0
.equ GR_TURQUOISE 0x273a
.equ GR_PURPLE    0xa01f
.equ GR_PINK      0xebda
.equ GR_FUCHSIA   0xf81f
.equ GR_BKGRD     0xffd7

.code

main:
   ; Trunk
   ldi R0,125   
   ldi R1,179
   ldi R2,131
   ldi R3,192
   ldi R4,GR_BROWN
   call gr_rect_fill

   ; Bucket
   ldi R0,113   
   ldi R1,193
   ldi R2,143
   ldi R3,208
   ldi R4,GR_RED
   call gr_rect_fill

   ; 'Bottom' Branches
   ldi R0,88
   ldi R1,178
   ldi R2,168
   ldi R3,178
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,168
   ldi R1,178
   ldi R2,128
   ldi R3,103
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,128
   ldi R1,103
   ldi R2,88
   ldi R3,178
   ldi R4,GR_DK_GREEN
   call gr_line

   ; 'Middle' Branches
   ldi R0,98
   ldi R1,123
   ldi R2,158
   ldi R3,123
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,158
   ldi R1,123
   ldi R2,128
   ldi R3,73
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,128
   ldi R1,73
   ldi R2,98
   ldi R3,123
   ldi R4,GR_DK_GREEN
   call gr_line

   ; 'Top' Branches
   ldi R0,113
   ldi R1,83
   ldi R2,143
   ldi R3,83
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,143
   ldi R1,83
   ldi R2,128
   ldi R3,58
   ldi R4,GR_DK_GREEN
   call gr_line

   ldi R0,128
   ldi R1,58
   ldi R2,113
   ldi R3,83
   ldi R4,GR_DK_GREEN
   call gr_line

	; Erase 'Top' overlap
   ldi R0,122
   ldi R1,83
   ldi R2,134
   ldi R3,83
   ldi R4,GR_BKGRD
   call gr_line

   ldi R0,134
   ldi R1,83
   ldi R2,128
   ldi R3,73
   ldi R4,GR_BKGRD
   call gr_line

   ldi R0,128
   ldi R1,73
   ldi R2,122
   ldi R3,83
   ldi R4,GR_BKGRD
   call gr_line

	; Erase 'Middle' overlap
   ldi R0,117
   ldi R1,123
   ldi R2,139
   ldi R3,123
   ldi R4,GR_BKGRD
   call gr_line

   ldi R0,139
   ldi R1,123
   ldi R2,128
   ldi R3,103
   ldi R4,GR_BKGRD
   call gr_line

   ldi R0,128
   ldi R1,103
   ldi R2,117
   ldi R3,123
   ldi R4,GR_BKGRD
   call gr_line

	; Touch up a few missed points
   ldi R0,121
   ldi R1,117
   ldi R2,GR_BKGRD
   call gr_pixel

   ldi R0,122
   ldi R1,115
   ldi R2,GR_BKGRD
   call gr_pixel

   ldi R0,123
   ldi R1,113
   ldi R2,GR_BKGRD
   call gr_pixel

   ldi R0,135
   ldi R1,117
   ldi R2,GR_BKGRD
   call gr_pixel

   ldi R0,134
   ldi R1,115
   ldi R2,GR_BKGRD
   call gr_pixel

   ldi R0,117
   ldi R1,123
   ldi R2,GR_DK_GREEN
   call gr_pixel

   ldi R0,139
   ldi R1,123
   ldi R2,GR_DK_GREEN
   call gr_pixel

   ; Star
   ldi R0,128
   ldi R1,48
   ldi R2,128
   ldi R3,68
   ldi R4,GR_FUCHSIA
   call gr_line

   ldi R0,118
   ldi R1,58
   ldi R2,138
   ldi R3,58
   ldi R4,GR_FUCHSIA
   call gr_line

   ldi R0,121
   ldi R1,51
   ldi R2,135
   ldi R3,65
   ldi R4,GR_FUCHSIA
   call gr_line

   ldi R0,121
   ldi R1,65
   ldi R2,135
   ldi R3,51
   ldi R4,GR_FUCHSIA
   call gr_line

   ; 'Bottom' Baubles
   ldi R0,103
   ldi R1,168
   ldi R2,3
   ldi R3,GR_PURPLE
   call gr_circle_fill

   ldi R0,118
   ldi R1,148
   ldi R2,3
   ldi R3,GR_TURQUOISE
   call gr_circle_fill

   ldi R0,123
   ldi R1,163
   ldi R2,3
   ldi R3,GR_BLUE
   call gr_circle_fill

   ldi R0,133
   ldi R1,133
   ldi R2,3
   ldi R3,GR_ORANGE
   call gr_circle_fill

   ldi R0,143
   ldi R1,153
   ldi R2,3
   ldi R3,GR_PINK
   call gr_circle_fill

   ldi R0,146
   ldi R1,166
   ldi R2,3
   ldi R3,GR_SILVER
   call gr_circle_fill

   ; 'Middle' Baubles
   ldi R0,118
   ldi R1,111
   ldi R2,3
   ldi R3,GR_SILVER
   call gr_circle_fill

   ldi R0,140
   ldi R1,115
   ldi R2,3
   ldi R3,GR_TURQUOISE
   call gr_circle_fill

   ldi R0,131
   ldi R1,98
   ldi R2,3
   ldi R3,GR_PURPLE
   call gr_circle_fill

   ; 'Top' Bauble
   ldi R0,126
   ldi R1,78
   ldi R2,3
   ldi R3,GR_ORANGE
   call gr_circle_fill

   end

