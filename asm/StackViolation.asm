
; Stack Violation Tests

.RAM

.code

main:
   pop r4                  ; POP into the I/O region
   ldi idx,0x20
   clr r0

loop:
   push r0                 ; Keep PUSHing onto the stack
   inc r0
   mov r0,r4
   cmp r0,idx
   jlt loop
   end


.data

.= 0xc000

heap_size: word 0x3fde     ; Set this so that we PUSH into the heap

