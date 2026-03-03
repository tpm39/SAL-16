
# Rough'n'Ready Microcode Generator

NUM_INSTRS = 32
NUM_CODES  = 128

# Write a word to the machine code file
def WriteWord(file, word):
   global wordcount

   wordcount += 1

   if (wordcount % 16) == 0:
      sep = '\n'
   elif (wordcount % 8) == 0:
      sep = '  '
   else:
      sep = ' '

   while len(word) < 8:
      word = '0' + word
      
   file.write(word + sep)

# Add a microcode
def AddCode(instr, codes):
   global microcode, lookup_table, next_addr

   lookup_table[int(instr[2:], base=2)] = next_addr 

   for i in range(len(codes)):
      microcode[next_addr] = codes[i]
      next_addr += 1


# Main Program

lookup_table = [0] * NUM_INSTRS
microcode = [0] * NUM_CODES
next_addr = 0

# Generate the codes

# LDI
instr = '0b00000'
codes = [0x00600500, 0x00100030, 0x00020200, 0x20000000]
AddCode(instr, codes)

# JMP
instr = '0b00001'
codes = [0x00200400, 0x00100200, 0x20000000]
AddCode(instr, codes)

# CALL
instr = '0b00010'
codes = [0x00600500, 0x00100200, 0x00020030, 0x20000000]
AddCode(instr, codes)

# JCAEZ
instr = '0b00011'
codes = [0x00600500, 0x00020200, 0x00100000, 0x20000000]
AddCode(instr, codes)

# LD
instr = '0b00100'
codes = [0x00040400, 0x00100030, 0x20000000]
AddCode(instr, codes)

# LDX
instr = '0b00101'
codes = [0x00080040, 0x00040100, 0x00020400, 0x00100030, 0x20000000]
AddCode(instr, codes)

# ST
instr = '0b00110'
codes = [0x000c0400, 0x00040080, 0x20000000]
AddCode(instr, codes)

# STX
instr = '0b00111'
codes = [0x00080040, 0x000c0100, 0x00020400, 0x00040080, 0x20000000]
AddCode(instr, codes)

# MOV
instr = '0b01000'
codes = [0x00040030, 0x20000000]
AddCode(instr, codes)

# MOVSP
instr = '0b01001'
codes = [0x00010030, 0x20000000]
AddCode(instr, codes)

# SETPX
instr = '0b01010'
codes = [0x00040400, 0x10080080, 0x20000000]
AddCode(instr, codes)

# FSETPX
# SAL-16F needs an extra 'no op' at codes[0] - Due to the Logisim circuit getting too complex ??
# SAL-16J doesn't need the extra 'no op' though - It has no Registers/Maths Unit/FPU/ALU sub-components.
instr = '0b01011'
codes = [0x00000000, 0x00040040, 0x07080100, 0x00020400, 0x108c0080, 0x20000000]
AddCode(instr, codes)

# ENI/DSI
instr = '0b01100'
codes = [0x20000000]
AddCode(instr, codes)

# RTI
instr = '0b01101'
codes = [0x08000000, 0x20000000]
AddCode(instr, codes)

# JMPR/RET
instr = '0b01110'
codes = [0x00040200, 0x20000000]
AddCode(instr, codes)

# POP
instr = '0b01111'
codes = [0x00000004, 0x00010400, 0x00100030, 0x20000000]
AddCode(instr, codes)

# PUSH
instr = '0b10000'
codes = [0x00010400, 0x00040080, 0x00000006, 0x20000000]
AddCode(instr, codes)

# ADD
instr = '0b10001'
codes = [0x00080040, 0x00040108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# LSL
instr = '0b10010'
codes = [0x00080040, 0x00044108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# LSR/ASR
instr = '0b10011'
codes = [0x00080040, 0x0004c108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# INC
instr = '0b10100'
codes = [0x00042108, 0x00020010, 0x20000000]
AddCode(instr, codes)

# DEC
instr = '0b10101'
codes = [0x0004a108, 0x00020010, 0x20000000]
AddCode(instr, codes)

# NOT
instr = '0b10110'
codes = [0x00046108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# AND
instr = '0b10111'
codes = [0x00080040, 0x00041108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# OR
instr = '0b11000'
codes = [0x00080040, 0x00045108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# XOR/CLR
instr = '0b11001'
codes = [0x00080040, 0x00043108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# CMP/FCMP
instr = '0b11010'
codes = [0x00080040, 0x00047108, 0x20000000]
AddCode(instr, codes)

# HALT
instr = '0b11011'
codes = [0x00000001, 0x20000000]
AddCode(instr, codes)

# SUB/MUL/SDIV/UDIV
instr = '0b11100'
codes = [0x00080040, 0x01040108, 0x00020030, 0x20000000]
AddCode(instr, codes)

# FADD/FSUB/FMUL/FDIV
instr = '0b11101'
codes = [0x00080040, 0x02040100, 0x00020030, 0x20000000]
AddCode(instr, codes)

# FSQRT/FSIN/FCOS/FTAN
instr = '0b11110'
codes = [0x02840100, 0x00020030, 0x20000000]
AddCode(instr, codes)

# END
instr = '0b11111'
codes = [0x00800001]
AddCode(instr, codes)

# Write the look up table file: MicrocodeLUT.uc
wordcount = 0
with open ('MicrocodeLUT.uc', 'w') as lut:
   lut.write('v3.0 hex words plain\n')
   for i in range(NUM_INSTRS):
      WriteWord(lut, hex(lookup_table[i])[2:])

# Write the microcode file: Microcode.uc
wordcount = 0
with open ('Microcode.uc', 'w') as mc:
   mc.write('v3.0 hex words plain\n')
   for i in range(NUM_CODES):
      WriteWord(mc, hex(microcode[i])[2:])

