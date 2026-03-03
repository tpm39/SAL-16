
'''
Assembler for the 'SAL-16x' Computer

Takes in an assembly code file (eg: Prog.asm) and produces the
machine code (Prog.mc) to load into the 'SAL-16x' computer's memory.

Usage: python3 <Path>Assembler.py [-h] <Path>Prog.asm <Path>Prog.mc

Commands List:

ooooo aaa bbb ccc nn - Opcode RA RB RC nn

Double Word Commands:
00000 000 000 ccc 00 - LDI RC,data     : Load RC with data
00001 000 000 000 00 - JMP addr        : Jump to mem addr
00010 000 000 111 00 - CALL addr       : Call the subroutine at mem addr

00011 000 000 0 0000 - JEQ addr        : Conditional jumps to mem addr
00011 000 000 0 0001 - JNE addr
00011 000 000 0 0010 - JZ  addr
00011 000 000 0 0011 - JNZ addr
00011 000 000 0 0100 - JC  addr
00011 000 000 0 0101 - JNC addr
00011 000 000 0 0110 - JGT addr
00011 000 000 0 0111 - JGE addr
00011 000 000 0 1000 - JLT addr
00011 000 000 0 1001 - JLE addr
00011 000 000 0 1010 - JPL addr
00011 000 000 0 1011 - JMI addr
00011 000 000 0 1100 - JV  addr
00011 000 000 0 1101 - JNV addr

Single Word Commands:
00100 aaa 000 ccc 00 - LD RC,[RA]      : Load RC from the mem addr in RA
00101 aaa bbb ccc 00 - LDX RC,[RA,RB]  : Load RC from the mem addr given by (RA + RB)
00110 aaa 000 ccc 00 - ST RA,[RC]      : Store RA to the mem addr in RC
00111 aaa bbb ccc 00 - STX RA,[RC,RB]  : Store RA to the mem addr given by (RC + RB)
01000 aaa 000 ccc 00 - MOV RA,RC       : Copy the contents of RA to RC
01001 000 000 ccc 00 - MOVSP RC        : Copy the SP to RC
01010 aaa bbb 000 00 - SETPX RA,RB     : Set the pixel at position in RA to the colour in RB
01011 aaa bbb ccc 00 - FSETPX RA,RB,RC : Set the pixel at position (RA, RB) (floating pt) to the colour in RC
01100 000 000 000 00 - DSI             : Disable interrupts
01100 000 000 000 01 - ENI             : Enable interrupts
01101 000 000 000 00 - RTI             : Return from interrupt
01110 aaa 000 000 00 - JMPR RA         : Jump to the mem addr in RA
01110 111 000 000 00 - RET             : Return from subroutine (JMPR LR)
01111 000 000 ccc 00 - POP RC          : Pop the contents of the SP to RC
10000 aaa 000 000 00 - PUSH RA         : Push the contents of RA to the stack
10001 aaa bbb ccc 00 - ADD RA,RB,RC    : RC = RA + RB
10010 aaa bbb ccc 00 - LSL RA,RB,RC    : RC = RA << RB
10011 aaa bbb ccc 00 - LSR RA,RB,RC    : RC = RA >> RB
10011 aaa bbb ccc 01 - ASR RA,RB,RC    : RC = RA >> RB (keeping the msb the same)
10100 aaa 000 000 00 - INC RA          : RA = RA + 1
10101 aaa 000 000 00 - DEC RA          : RA = RA - 1
10110 aaa 000 ccc 00 - NOT RA,RC       : RC = !RA
10111 aaa bbb ccc 00 - AND RA,RB,RC    : RC = RA & RB
11000 aaa bbb ccc 00 - OR RA,RB,RC     : RC = RA | RB
11001 aaa bbb ccc 00 - XOR RA,RB,RC    : RC = RA ^ RB
11001 aaa aaa aaa 00 - CLR RA          : RA = 0 (XOR RA,RA,RA)
11010 aaa bbb 000 00 - CMP RA,RB       : Calculate (RA-RB) and set the resulting flags
11010 aaa bbb 000 01 - FCMP RA,RB      : Calculate (RA-RB) and set the resulting flags
11011 000 000 000 00 - HALT            : Halt the program
11100 aaa bbb ccc 00 - SUB RA,RB,RC    : RC = RA - RB
11100 aaa bbb ccc 01 - MUL RA,RB,RC    : RC = RA * RB
11100 aaa bbb ccc 10 - SDIV RA,RB,RC   : RC = RA / RB (signed)
11100 aaa bbb ccc 11 - UDIV RA,RB,RC   : RC = RA / RB (unsigned)
11101 aaa bbb ccc 00 - FADD RA,RB,RC   : RC = RA + RB
11101 aaa bbb ccc 01 - FSUB RA,RB,RC   : RC = RA - RB
11101 aaa bbb ccc 10 - FMUL RA,RB,RC   : RC = RA * RB
11101 aaa bbb ccc 11 - FDIV RA,RB,RC   : RC = RA / RB
11110 aaa 000 ccc 00 - FSQRT RA,RC     : RC = SQRT(RA)
11110 aaa 000 ccc 01 - FSIN RA,RC      : RC = SIN(RA) : RA in range [0,90]
11110 aaa 000 ccc 10 - FCOS RA,RC      : RC = COS(RA) : RA in range [0,90]
11110 aaa 000 ccc 11 - FTAN RA,RC      : RC = TAN(RA) : RA in range [0,90]
11111 000 000 000 00 - END             : Stop the program

Note: All commands starting with 'F' are floating point commands

'''

import argparse
import os

# Memory Regions
ROM_START = 0x0000
ROM_SIZE  = 0x8000
IO_SIZE   = 0x0010
RAM_START = 0x8000
RAM_SIZE  = 0x8000 - IO_SIZE
MC_SIZE   = 0x8000
start_addr = 0

# Commands Table
cmds = {'LDI'    : 0b00000,
        'JMP'    : 0b00001,
        'CALL'   : 0b00010,
        'JMPIF'  : 0b00011,
        'LD'     : 0b00100,
        'LDX'    : 0b00101,        
        'ST'     : 0b00110,
        'STX'    : 0b00111,
        'MOV'    : 0b01000,
        'MOVSP'  : 0b01001,
        'SETPX'  : 0b01010,
        'FSETPX' : 0b01011,
        'ENI'    : 0b01100,
        'DSI'    : 0b01100,
        'RTI'    : 0b01101,
        'JMPR'   : 0b01110,
        'RET'    : 0b01110,
        'POP'    : 0b01111,
        'PUSH'   : 0b10000,
        'ADD'    : 0b10001,
        'LSL'    : 0b10010,
        'LSR'    : 0b10011,
        'ASR'    : 0b10011,
        'INC'    : 0b10100,
        'DEC'    : 0b10101,
        'NOT'    : 0b10110,
        'AND'    : 0b10111,
        'OR'     : 0b11000,
        'XOR'    : 0b11001,
        'CLR'    : 0b11001,
        'CMP'    : 0b11010,
        'FCMP'   : 0b11010,
        'HALT'   : 0b11011,
        'SUB'    : 0b11100,
        'MUL'    : 0b11100,
        'SDIV'   : 0b11100,
        'UDIV'   : 0b11100,
        'FADD'   : 0b11101,
        'FSUB'   : 0b11101,
        'FMUL'   : 0b11101,
        'FDIV'   : 0b11101,
        'FSQRT'  : 0b11110,
        'FSIN'   : 0b11110,
        'FCOS'   : 0b11110,
        'FTAN'   : 0b11110,
        'END'    : 0b11111}

# Registers Table
regs = {'R0'  : 0b000,
        'R1'  : 0b001,
        'R2'  : 0b010,
        'R3'  : 0b011,
        'R4'  : 0b100,
        'IDX' : 0b101,
        'FP'  : 0b110,
        'LR'  : 0b111}

# Coditional Jump Commands
condJumps = {'JEQ' : 0b0000,
             'JNE' : 0b0001,
             'JZ'  : 0b0010,
             'JNZ' : 0b0011,
             'JC'  : 0b0100,
             'JNC' : 0b0101,
             'JGT' : 0b0110,
             'JGE' : 0b0111,
             'JLT' : 0b1000,
             'JLE' : 0b1001,
             'JPL' : 0b1010,
             'JMI' : 0b1011,
             'JV'  : 0b1100,
             'JNV' : 0b1101}

# Maths Commands
maths = {'SUB'  : 0b00,
         'MUL'  : 0b01,
         'SDIV' : 0b10,
         'UDIV' : 0b11}

# FPU Commands
fpu = {'FADD'  : 0b00,
       'FSUB'  : 0b01,
       'FMUL'  : 0b10,
       'FDIV'  : 0b11,
       'FSQRT' : 0b00,
       'FSIN'  : 0b01,
       'FCOS'  : 0b10,
       'FTAN'  : 0b11}

# Positions for code parts
POS_OPCODE = 11
POS_REG_A  = 8
POS_REG_B  = 5
POS_REG_C  = 2

# Floating Point NaN & Inf's
FP_NAN     = 0x7e00
FP_POS_INF = 0x7c00
FP_NEG_INF = 0xfc00

# Labels Table
labels = {}

#------------------
# Helper Functions
#------------------

# Check whether or not a label is valid
def ValidLabel(lbl):
    if lbl in labels:
        return False

    elif lbl[0].isdigit():
        return False

    for c in lbl:
        if not c.isdigit() and not c.isalpha() and c != '_':
            return False

    return True

# Get the integer value of a string
def GetNum(str):
    if '.' in str:
        val = dec_to_hex(str)
    elif str.startswith('0B'):
        val = int(str[2:], base=2)
    elif str.startswith('0X'):
        val = int(str[2:], base=16)
    else:
        val = int(str)
    return val

# Convert a decimal string to a hex floating point number
def dec_to_hex(str):
    # Get the decimal value
    val = float(str)

    # Get the sign bit
    if val < 0:
        val = abs(val)
        sign = '1'
    else:
        sign = '0'
    
    # Get the exponent
    exp = 15
    
    # If the number's 2 or above keep dividing by 2 until it's not.
    # While doing this the exponent must be incremented for each division,
    # so that val * (2**exp) remains equal to the initial number.
    while val >= 2:
        val /= 2
        exp += 1

    # Numbers beyond the normal range are infinite
    if exp > 30:
        if sign == '0':
            return FP_POS_INF
        else:
            return FP_NEG_INF

    # If the number's below 1 keep multiplying by 2 until it's not.
    # While doing this the exponent must be decremented for each multiplication,
    # so that val * (2**exp) remains equal to the initial number.
    while val < 1:
        val *= 2
        exp -= 1
        if exp == 0:
            # It's a subnormal number - exponent can't be lowered further
            val /= 2
            break

    # Get the mantissa
    mant = ''
    
    # Get rid of the leading '1' for normal numbers
    if exp != 0:
        val -= 1
        
    for _ in range(21):
        val = 2 * val
        if val >= 1:
            val -= 1
            mant += '1'
        else:
            mant += '0'

    # Perform rounding if necessary
    if (mant[9] == '0' and mant[10] == '1' and '1' in mant[11:]) or \
        (mant[9] == '1' and mant[10] == '1'):
        mant = mant[:10]
        mantInt = int(mant, 2) + 1
        if hex(mantInt) == '0x400':
            mant = '0' * 10
            exp += 1
        else:
            mant = f'{mantInt:010b}'
    else:
        mant = mant[:10]

    bin_str = sign + f'{exp:05b}' + mant
    return int(bin_str, 2)

# Check for a double word command
def double_word_cmd(cmd):
    if cmd in ['LDI', 'JMP', 'CALL']:
        return True
    elif cmd.startswith('J') and cmd != 'JMPR':
        return True
    else:
        return False

# Get the length of an array
def array_len(arr):
    if arr.startswith('[') and arr.endswith(']'):
        arr = arr.replace(':', ',')
        arr = arr.split(',')
        # Adjust for the 2 'dimension headers'
        return len(arr) + 2
    else:
        return int(arr)

# Get the length of a string
def str_len(str):
    if str.startswith('"') and str.endswith('"'):
        str = str[1:-1]
        # Adjust for the null terminator
        return len(str) + 1
    else:
        return int(str)

# Remove any whitespace before/after any 'chr' in 'line'
def rem_whitspace(line, chr):
    cs_line = line.split(chr)
    line = ''
    for i in range(len(cs_line)):
        line = line + cs_line[i].strip() + chr
    return line[:-1]

# Wite a word to the machine code file
def WriteWord(word, region_addr=0):
    global mc, wordcount

    if region_addr > 0:
        words = region_addr - wordcount
        if words < 0:
            raise MemoryError('The given address is in existing code')
        for _ in range(words):
            WriteWord(word)
        return
    elif region_addr == 0:
        wordcount += 1
    else:
        raise MemoryError('The given address is in existing code')

    if (wordcount % 16) == 0:
        sep = '\n'
    elif (wordcount % 8) == 0:
        sep = '  '
    else:
        sep = ' '
    while len(word) < 4:
        word = '0' + word
    mc.write(word + sep)

# Check that a file's OK
def ProcessFile(file, type):
    file = os.path.normpath(file)
    # Create the output directory if it doesn't exist
    if type == 'mc':
        dirOut = os.path.dirname(file)
        if dirOut != '' and not os.path.exists(dirOut):
            os.mkdir(dirOut)

    # Check its type
    file_ext = os.path.splitext(file)[1][1:]
    if file_ext != type:
        if type == 'asm':
            print("\nInvalid filename - You should use an 'asm' file as the input file\n")
        elif type == 'mc':
            print("\nInvalid filename - You should use an 'mc' file as the output file\n")
        exit(1)

    return file

# Delete an invalid machine code file
def DeleteFile(file):
    if os.path.exists(file):
        os.remove(file)

#--------------
# Main Program
#--------------

# Process the arguments
parser = argparse.ArgumentParser(
    prog='python3 Assembler.py',
    description='Assemble an assembly code program',
    epilog='Good Luck :)')
parser.add_argument('fileIn', help='The input assembly code file')
parser.add_argument('fileOut', help='The output machine code file')
args = parser.parse_args()

# Get the 'asm' file to be assembled
fileIn = ProcessFile(args.fileIn, 'asm')

# Set the 'mc' output file to be generated
fileOut = ProcessFile(args.fileOut, 'mc')

try:
    # 1st pass through the assembly code - Add all labels to the labels table
    lineNo = 0
    addr = -1

    with open(fileIn,'r') as asm:
        for line in asm:
            lineNo += 1
            line = line.strip()
            line = line.upper()

            # Adjust for memory regions
            if line.startswith('.ROM'):
                start_addr = ROM_START
                addr = start_addr - 1
                continue

            elif line.startswith('.RAM'):
                start_addr = RAM_START
                addr = start_addr - 1
                continue

            # Deal with'.equ' directives
            elif line.startswith('.EQU'):
                # Remove any comments 
                line = line.split(';')
                line = line[0].strip()

                line = line[4:].strip()
                line = line.split(' ')
                lbl = line[0].strip()
                val = GetNum(line[-1].strip())
                if val < 0:
                    val += 2**16

                # Add to label table if valid
                if ValidLabel(lbl):
                    labels[lbl] = val
                else:
                    if lbl in labels:
                        raise NameError(f'Duplicate Label at line {lineNo}: {lbl}')
                    else:
                        raise NameError(f'Invalid Label at line {lineNo}: {lbl}')
                continue

            # Adjust addr to that given in the '.=' directive
            elif line.startswith('.='):
                line = line.split('=')
                if '.' in line[1]:
                    raise MemoryError("'.=' can't be a floating point number")
                addr = GetNum(line[1].strip()) - 1
                continue

            # Ignore section directives
            elif line.startswith('.CODE') or line.startswith('.DATA'):
                continue

            # Ignore comment lines
            elif line.startswith(';'):
                continue

            # Ignore blank lines
            if len(line) > 0:
                addr += 1

                # Remove comments
                line = line.split(';')
                line = line[0].strip()

                # Labels are defined as 'LABEL:'
                if ':' in line:
                    if line.endswith(':'):
                        lbl = line[:-1]
                        cmd = 'none'
                    else:
                        line = line.split(':')
                        lbl = line[0]
                        cmd = line[1].strip()
                        if (cmd.startswith('STR') or cmd.startswith('ARRAY'))and len(line) > 2:
                            # Deal with ':'s within strings & matrices
                            cmd = ':'.join(line[1:])
                            cmd = cmd.strip()

                    # Add to label table if valid
                    if ValidLabel(lbl):
                        labels[lbl] = addr
                        if cmd == 'none':
                            addr -= 1
                    else:
                        if lbl in labels:
                            raise NameError(f'Duplicate Label at line {lineNo}: {lbl}')
                        else:
                            raise NameError(f'Invalid Label at line {lineNo}: {lbl}')

                    # Adjust for ARRAY command
                    if cmd.startswith('ARRAY'):
                        addr += (array_len(cmd[5:].strip()) - 1)

                    # Adjust for STR command
                    elif cmd.startswith('STR'):
                        addr += (str_len(cmd[3:].strip()) - 1)

                    # Adjust for double word commands
                    else:
                        cmd = cmd.split(' ')
                        if double_word_cmd(cmd[0]):
                            addr += 1

                else:
                    # Adjust for double word commands
                    line = line.split(' ')
                    if double_word_cmd(line[0]):
                        addr += 1

    # 2nd pass through the assembly code - Produce the machine code
    lineNo = 0
    wordcount = 0
    section = 'CODE'
    with open(fileIn,'r') as asm:
        with open(fileOut,'w') as mc:
            mc.write('v3.0 hex words plain\n')
            for line in asm:
                lineNo += 1
                line = line.strip()
                if section == 'DATA' and '"' in line:
                    # Don't convert chars in STR's to upper case
                    items = line.split('"')
                    line = items[0].upper() + '"' + str(items[1]) + '"'
                else:
                    line = line.upper()

                # Ignore memory region directives
                if line.startswith('.ROM') or line.startswith('.RAM'):
                    continue

                # Ignore '.equ' directives'
                elif line.startswith('.EQU'):
                    continue

                # Ignore comments
                elif line.startswith(';'):
                    continue

                # Keep a note of which section we're in
                elif line.startswith('.CODE'):
                   section = 'CODE'
                   continue 

                elif line.startswith('.DATA'):
                    section = 'DATA'
                    continue

                # Fill memory with 0's upto the addr given in the '.=' directive
                elif line.startswith('.='):
                    line = line.split('=')
                    if '.' in line[1]:
                        raise MemoryError("'.=' can't be a floating point number")
                    region_addr = GetNum(line[1].strip()) - start_addr
                    if region_addr == 0:
                        if wordcount > 0:
                            # If we're at 'start_addr' nothing should be written yet
                            raise MemoryError('The given address is in existing code')
                    else:
                        WriteWord('0000', region_addr)
                    continue

                # Ignore inline comments
                line = line.split(';')
                line = line[0].strip()

                # Ignore blank lines and labels
                if len(line) != 0 and not line.endswith(':'):
                    # Remove label
                    if ':' in line:
                        line_parts = line.split(':')
                        label = line_parts[0].strip()
                        line = line_parts[1].strip()
                        if line.startswith('STR') or line.startswith('ARRAY'):
                            # Deal with any ':'s within strings & matrices
                            line = ':'.join(line_parts[1:])
                            line = line.strip()
                                        
                    # Get the command & args 
                    if line.startswith('STR'):
                        # Don't want to be removing any whitespace from strings
                        cmd = 'STR'
                        args = line[3:].strip()
                    else:
                        # Remove any whitespace before/after any commas
                        line = rem_whitspace(line, ',')

                        # Remove any whitespace before/after any opening brackets
                        line = rem_whitspace(line, '[')

                        # Remove any whitespace before/after any closing brackets
                        line = rem_whitspace(line, ']')

                        # Remove any whitespace before/after any colons
                        line = rem_whitspace(line, ':')

                        # However: We do need a space between 'ARRAY' and '['
                        if line.startswith('ARRAY'):
                            line = 'ARRAY ' + line[5:]

                        line = line.split(' ')
                        cmd = line[0].strip()
                        if len(line) > 1:
                            args = line[-1].strip()

                    # Deal with WORD command - Only applies to the '.data' section
                    if cmd == 'WORD': 
                        if section == 'CODE':
                            raise SyntaxError()
                        val = GetNum(args)
                        if val < 0:
                            val += 2**16

                        WriteWord(hex(val)[2:])

                    # Deal with ARRAY command - Only applies to the '.data' section
                    elif cmd == 'ARRAY': 
                        if section == 'CODE':
                            raise SyntaxError()
                        
                        if not isinstance(args, str):
                            raise SyntaxError()
                        
                        if args.startswith('[') and args.endswith(']'):
                            args = args[1:-1]

                            # Write the array/vector/matrix dimensions header: rows, cols
                            rows = len(args.split(':'))
                            WriteWord(hex(rows)[2:])
                            args = args.replace(':', ',')
                            args = args.split(',')
                            if len(args) % rows != 0:
                                # The array/vector/matrix size must be a multiple of 'rows'
                                raise SyntaxError()
                            cols = len(args) // rows
                            WriteWord(hex(cols)[2:])

                            # Write the array/vector/matrix
                            for arg in args:
                                val = GetNum(arg)
                                if val < 0:
                                    val += 2**16
                                WriteWord(hex(val)[2:])
                        else:
                            for _ in range(int(args)):
                                WriteWord('0000')

                    # Deal with STR command - Only applies to the '.data' section
                    elif cmd == 'STR': 
                        if section == 'CODE':
                            raise SyntaxError()

                        if not isinstance(args, str):
                            raise SyntaxError()

                        if args.startswith('"') and args.endswith('"'):
                            args = args[1:-1]
                            for chr in args:
                                WriteWord(hex(ord(chr))[2:])
                            # Add string terminator
                            WriteWord('0')                
                        else:
                            for _ in range(int(args)):
                                WriteWord('0000')

                    # Deal with the LDI command
                    elif cmd == 'LDI':
                        if not isinstance(args, str):
                            raise SyntaxError()

                        args = args.split(',')
                        if len(args) != 2:
                            raise SyntaxError()

                        rc = args[0]
                        if rc not in regs:
                            raise SyntaxError()

                        code = (cmds[cmd] << POS_OPCODE) + (regs[rc] << POS_REG_C)
                        WriteWord(hex(code)[2:])

                        # Deal with the data word
                        dw = args[1]
                        if dw in labels:
                            code = labels[dw]
                        else:
                            code = GetNum(dw)
                            if code < 0:
                                code += 2**16

                        WriteWord(hex(code)[2:])

                    # Deal with the JMP, JMPIF & CALL commands
                    elif (cmd.startswith('J') and cmd != 'JMPR') or cmd == 'CALL':
                        cond = None
                        if cmd != 'JMP' and cmd != 'CALL':
                            if cmd not in condJumps:
                                raise SyntaxError()
                            cond = cmd
                            cmd = 'JMPIF'

                        code = cmds[cmd] << POS_OPCODE

                        # Set the conditional jump
                        if cond != None:
                            code += condJumps[cond]

                        # Use LR to store the CALL return address
                        elif cmd == 'CALL':
                            code += (regs['LR'] << POS_REG_C)

                        WriteWord(hex(code)[2:])

                        # Deal with the address word
                        if args in labels:
                            code = labels[args]
                        else:
                            if '.' in args:
                                raise MemoryError("'Call' or 'Jump' can't be to a floating point number")
                            code = GetNum(args)

                        WriteWord(hex(code)[2:])

                    # Deal with all other commands
                    elif cmd in cmds:
                        if cmd in ['DSI', 'ENI', 'RTI', 'HALT', 'END']:
                            code = cmds[cmd] << POS_OPCODE

                        elif cmd == 'RET':
                            code = (cmds['JMPR'] << POS_OPCODE) + (regs['LR'] << POS_REG_A)                            

                        elif cmd in ['LD', 'LDX']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            args = args.split(',')
                            if len(args) != 2 and len(args) != 3:
                                raise SyntaxError()

                            # Set the registers
                            rc = args[0]
                            if cmd == 'LD':
                                ra = args[1][1:-1]
                                rb = 'R0'
                            else:
                                ra = args[1][1:]
                                rb = args[2][:-1]

                            if ra not in regs or rb not in regs or rc not in regs:
                                raise SyntaxError()

                            code = (cmds[cmd] << POS_OPCODE) + (regs[ra] << POS_REG_A) + (regs[rb] << POS_REG_B) + (regs[rc] << POS_REG_C)

                        elif cmd in ['ST', 'STX']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            args = args.split(',')
                            if len(args) != 2 and len(args) != 3:
                                raise SyntaxError()

                            # Set the registers
                            ra = args[0]
                            if cmd == 'ST':
                                rc = args[1][1:-1]
                                rb = 'R0'
                            else:
                                rc = args[1][1:]
                                rb = args[2][:-1]

                            if ra not in regs or rb not in regs or rc not in regs:
                                raise SyntaxError()

                            code = (cmds[cmd] << POS_OPCODE) + (regs[ra] << POS_REG_A) + (regs[rb] << POS_REG_B) + (regs[rc] << POS_REG_C)

                        elif cmd in ['JMPR', 'PUSH', 'INC', 'DEC']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            if args not in regs:
                                raise SyntaxError()
                            code = (cmds[cmd] << POS_OPCODE) + (regs[args] << POS_REG_A)

                        elif cmd in ['MOVSP', 'POP']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            if args not in regs:
                                raise SyntaxError()
                            code = (cmds[cmd] << POS_OPCODE) + (regs[args] << POS_REG_C)

                        elif cmd == 'CLR':
                            if not isinstance(args, str):
                                raise SyntaxError()

                            if args not in regs:
                                raise SyntaxError()
                            code = (cmds[cmd] << POS_OPCODE) + (regs[args] << POS_REG_A) + (regs[args] << POS_REG_B) + (regs[args] << POS_REG_C)

                        elif cmd in ['MOV', 'NOT', 'FSQRT', 'FSIN', 'FCOS', 'FTAN']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            args = args.split(',')
                            if len(args) != 2:
                                raise SyntaxError()
                            
                            ra = args[0]
                            rc = args[1]

                            if ra not in regs or rc not in regs:
                                raise SyntaxError()
                            
                            code = (cmds[cmd] << POS_OPCODE) + (regs[ra] << POS_REG_A) + (regs[rc] << POS_REG_C)

                        elif cmd in ['SETPX', 'CMP', 'FCMP']:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            args = args.split(',')
                            if len(args) != 2:
                                raise SyntaxError()
                            
                            ra = args[0]
                            rb = args[1]
                            if ra not in regs or rb not in regs:
                                raise SyntaxError()
                            
                            code = (cmds[cmd] << POS_OPCODE) + (regs[ra] << POS_REG_A) + (regs[rb] << POS_REG_B)

                            if cmd == 'FCMP':
                                code |= 0x0001

                        else:
                            if not isinstance(args, str):
                                raise SyntaxError()

                            args = args.split(',')
                            if len(args) != 3:
                                raise SyntaxError()

                            # Set the registers
                            ra = args[0]
                            rb = args[1]
                            rc = args[2]
                            if ra not in regs or rb not in regs or rc not in regs:
                                raise SyntaxError()

                            code = (cmds[cmd] << POS_OPCODE) + (regs[ra] << POS_REG_A) + (regs[rb] << POS_REG_B)  + (regs[rc] << POS_REG_C)

                        if cmd in ['ENI', 'ASR']:
                            code += 0b01

                        elif cmd in maths:
                            code += maths[cmd]

                        elif cmd in fpu:
                            code += fpu[cmd]

                        WriteWord(hex(code)[2:])

                    else:
                        raise SyntaxError()

            # Check we've not exceeded the memory size
            max_size = RAM_SIZE
            if start_addr < RAM_START:
                max_size = ROM_SIZE

            if wordcount > max_size:
                raise Exception('\nAssembly Failed - Memory size exceeded\n')
            else:
                # Fill remaining space with '0000's
                while wordcount < MC_SIZE:
                    WriteWord('0000')
                print('\nAssembly Successful\n')

except FileNotFoundError:
    print(f'File not found: {fileIn}')
    exit(1)

except SyntaxError:
    DeleteFile(fileOut)
    print(f'Syntax error at line: {lineNo}')
    exit(1)

except MemoryError as me:
    DeleteFile(fileOut)
    print(f'Error at line: {lineNo} - {me.args[0]}')
    exit(1)

except Exception as e:
    DeleteFile(fileOut)
    print(e)
    exit(1)

