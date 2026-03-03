
.RAM

.code

main:
   ldi r0,1
   ldi r1,-1
   ldi r2,0xffff

   cmp r0,r1
   jgt done

   clr r2   ; Shouldn't be cleared

done:
   end


.data

.= 0xc000

