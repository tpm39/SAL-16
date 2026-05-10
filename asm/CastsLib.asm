
;---------------------------------------------------------
; Casts Library for TimmiOS - The SAL-16 Operating System
;---------------------------------------------------------

;--------------------------------------------
; Defines for use in programs using TimmiOS:
;
; .equ cast_int   0x5000
; .equ cast_float 0x5200
;--------------------------------------------

.ROM

; BIOS Defines
.equ os_mem_set 0x1110
.equ os_exit    0x1a90

.code

;------------------------------------------------
; Casts - Cast from float to int
;
; Location: ROM addr 0x5000
;
; Input  - R0 = The float
; Output - R0 = The int
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Casts.rmg'
;------------------------------------------------

.= 0x5000

cast_int:
   push r1     ; Save registers
   push r2
   push r3
   push r4
   push idx
   push lr     ; Auto-generated code
   push fp
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
   ldi idx,0
   add fp,idx,r0
   ldi idx,-9
   stx r0,[fp,idx]
   ldi idx,-9
   ldx r0,[fp,idx]
   ldi idx,1
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,32767
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,14336
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_cast_int_3
   clr r2
cond_cast_int_3:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_1
   ldi r0,0
   jmp ret_cast_int
if_cast_int_1:
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,15
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,31744
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   ldi r0,1023
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   pop r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   ldi r0,31
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_int_7
   clr r2
cond_cast_int_7:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_5
   ldi r0,288
   call os_exit
if_cast_int_5:
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   ldi r0,15
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi r0,1024
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
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_cast_int_10
   clr r2
cond_cast_int_10:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_8
   ldi r0,10
   push r0
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-5
   stx r0,[fp,idx]
   ldi r0,16
   push r0
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi idx,-5
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   pop r1
   pop r0
   call 8256
   push r0
   pop r0
   ldi idx,-8
   stx r0,[fp,idx]
   ldi idx,-8
   ldx r0,[fp,idx]
   clr r1
   cmp r0,r1
   jeq if_cast_int_12
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_int_16
   clr r2
cond_cast_int_16:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_14
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
if_cast_int_14:
   jmp if_cast_int_13
if_cast_int_12:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_int_19
   clr r2
cond_cast_int_19:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_17
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,32767
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_cast_int_22
   clr r2
cond_cast_int_22:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_20
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
if_cast_int_20:
if_cast_int_17:
if_cast_int_13:
   jmp if_cast_int_9
if_cast_int_8:
   ldi idx,-3
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   push r0
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
if_cast_int_9:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_int_26
   clr r2
cond_cast_int_26:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_int_24
   ldi idx,-1
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,-1
   stx r0,[fp,idx]
if_cast_int_24:
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   pop r0
   jmp ret_cast_int
ret_cast_int:
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
   pop idx     ; Restore registers
   pop r4
   pop r3
   pop r2
   pop r1
   ret

;------------------------------------------------
; Casts - Cast from int to float
;
; Location: ROM addr 0x5200
;
; Input  - R0 = The int
; Output - R0 = The float
;
; NB: This code is taken from the auto-generated
;     code produced by compiling 'OS_Casts.rmg'
;------------------------------------------------

.= 0x5200

cast_float:
   push r1     ; Save registers
   push r2
   push r3
   push r4
   push idx
   push lr     ; Auto-generated code
   push fp
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
   ldi r0,15
   push r0
   clr r0
   push r0
   clr r0
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_float_29
   clr r2
cond_cast_float_29:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_27
   ldi r0,0
   jmp ret_cast_float
if_cast_float_27:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jgt cond_cast_float_32
   clr r2
cond_cast_float_32:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_30
   ldi r0,1
   ldi idx,-5
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   not r0,r0
   inc r0
   ldi idx,1
   stx r0,[fp,idx]
if_cast_float_30:
while_cast_float_34:
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_cast_float_36
   clr r2
cond_cast_float_36:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq while_cast_float_35
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   pop r1
   pop r0
   call 8256
   push r0
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-8
   stx r0,[fp,idx]
   ldi idx,1
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   pop r1
   pop r0
   sdiv r0,r1,r0
   push r0
   pop r0
   ldi idx,1
   stx r0,[fp,idx]
   jmp while_cast_float_34
while_cast_float_35:
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r1,r0
   jge cond_cast_float_40
   clr r2
cond_cast_float_40:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_38
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   jmp if_cast_float_39
if_cast_float_38:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   pop r0
   ldi idx,-2
   stx r0,[fp,idx]
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi idx,-8
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   sub r0,r1,r0
   push r0
   pop r1
   pop r0
   lsr r0,r1,r0
   push r0
   pop r0
   ldi idx,-7
   stx r0,[fp,idx]
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,2
   push r0
   pop r1
   pop r0
   call 8256
   push r0
   pop r0
   ldi idx,-3
   stx r0,[fp,idx]
   ldi idx,-3
   ldx r0,[fp,idx]
   clr r1
   cmp r0,r1
   jeq if_cast_float_42
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_float_46
   clr r2
cond_cast_float_46:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_44
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
if_cast_float_44:
   jmp if_cast_float_43
if_cast_float_42:
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_float_49
   clr r2
cond_cast_float_49:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_47
   ldi idx,-2
   ldx r0,[fp,idx]
   push r0
   ldi r0,32767
   push r0
   pop r1
   pop r0
   and r0,r1,r0
   push r0
   ldi r0,0
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jgt cond_cast_float_52
   clr r2
cond_cast_float_52:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_50
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
if_cast_float_50:
if_cast_float_47:
if_cast_float_43:
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   ldi r0,1024
   push r0
   pop r1
   pop r0
   ldi r2,1
   cmp r0,r1
   jeq cond_cast_float_56
   clr r2
cond_cast_float_56:
   mov r2,r0
   push r0
   pop r0
   clr r1
   cmp r0,r1
   jeq if_cast_float_54
   ldi r0,0
   ldi idx,-7
   stx r0,[fp,idx]
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   ldi r0,1
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-6
   stx r0,[fp,idx]
if_cast_float_54:
if_cast_float_39:
   ldi idx,-6
   ldx r0,[fp,idx]
   push r0
   ldi r0,10
   push r0
   pop r1
   pop r0
   lsl r0,r1,r0
   push r0
   ldi idx,-7
   ldx r0,[fp,idx]
   push r0
   pop r1
   pop r0
   add r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
   ldi idx,-5
   ldx r0,[fp,idx]
   clr r1
   cmp r0,r1
   jeq if_cast_float_57
   ldi idx,-1
   ldx r0,[fp,idx]
   push r0
   ldi r0,32768
   push r0
   pop r1
   pop r0
   or r0,r1,r0
   push r0
   pop r0
   ldi idx,-1
   stx r0,[fp,idx]
if_cast_float_57:
   ldi idx,0
   add fp,idx,r0
   ldi idx,-4
   stx r0,[fp,idx]
   ldi idx,-4
   ldx r0,[fp,idx]
   ldi idx,-1
   ldx r1,[fp,idx]
   call os_mem_set
   ldi idx,0
   ldx r0,[fp,idx]
   push r0
   pop r0
   jmp ret_cast_float
ret_cast_float:
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
   pop idx     ; Restore registers
   pop r4
   pop r3
   pop r2
   pop r1
   ret

