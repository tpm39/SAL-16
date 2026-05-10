
'''
This class keeps track of the current state of the
computer & deals with executing the program instructions.

The computer's memory is divided as:
   ROM: 0x0000 - 0x7fff
   RAM: 0x8000 - 0xffef
   I/O: 0xfff0 - 0xffff

'''

from EmulFPU import FPU

class Computer():
   # Memory
   MEM_SIZE = 0xffff + 1

   # RAM address extents
   ROM_START = 0x0000
   RAM_START = 0x8000
   IO_START  = 0xfff0

   # I/O Addresses
   ERR = 0xfff0

   KBD = 0xfff1
   TTY = 0xfff2

   IN_1   = 0xfff3
   WAIT_1 = 0xfff4
   ENT_1  = 0xfff5
   OUT_1  = 0xfff6

   IN_2   = 0xfff7
   WAIT_2 = 0xfff8
   ENT_2  = 0xfff9
   OUT_2  = 0xfffa

   # Registers
   NUM_REGS = 8
   IDX = 0x05
   FP  = 0x06
   LR  = 0x07

   # Flags
   NUM_FLAGS = 6
   C = 0
   A = 1
   E = 2
   Z = 3
   N = 4
   V = 5

   # Masks/Shifts
   OPCODE_MASK = 0xf800
   REGA_MASK   = 0x0700
   REGB_MASK   = 0x00e0
   REGC_MASK   = 0x001c
   COND_MASK   = 0x000f
   REGA_SHIFT  = 8
   REGB_SHIFT  = 5
   REGC_SHIFT  = 2

   # Conditional Jumps
   JEQ = 0
   JNE = 1
   JZ  = 2
   JNZ = 3
   JC  = 4
   JNC = 5
   JGT = 6
   JGE = 7
   JLT = 8
   JLE = 9
   JPL = 10
   JMI = 11
   JV  = 12
   JNV = 13

   # Computer execution states
   ST_READY   = 0
   ST_RUNNING = 1
   ST_HALT    = 2 
   ST_END     = 3

   # Command codes
   CMD_LDI    = 0
   CMD_JMP    = 1
   CMD_CALL   = 2
   CMD_JCOND  = 3
   CMD_LD     = 4
   CMD_LDX    = 5
   CMD_ST     = 6
   CMD_STX    = 7
   CMD_MOV    = 8
   CMD_MOVSP  = 9
   CMD_SETPX  = 10
   CMD_FSETPX = 11
   CMD_DSI    = 12
   CMD_ENI    = 13
   CMD_RTI    = 14
   CMD_JMPR   = 15
   CMD_RET    = 16
   CMD_POP    = 17
   CMD_PUSH   = 18
   CMD_ADD    = 19
   CMD_LSL    = 20
   CMD_LSR    = 21
   CMD_ASR    = 22
   CMD_INC    = 23
   CMD_DEC    = 24
   CMD_NOT    = 25
   CMD_AND    = 26
   CMD_OR     = 27
   CMD_XOR    = 28
   CMD_CMP    = 29
   CMD_FCMP   = 30
   CMD_HALT   = 31
   CMD_SUB    = 32
   CMD_MUL    = 33
   CMD_SDIV   = 34
   CMD_UDIV   = 35
   CMD_FADD   = 36
   CMD_FSUB   = 37
   CMD_FMUL   = 38
   CMD_FDIV   = 39
   CMD_FSQRT  = 40
   CMD_FSIN   = 41
   CMD_FCOS   = 42
   CMD_FTAN   = 43
   CMD_END    = 44

   # Signed Integer Limits
   INT_HIGH = 2**15 - 1
   INT_LOW = -(2**15)

   # Reset everything on initialisation
   def __init__(self):
      self.mem = [0x0000] * Computer.MEM_SIZE     # The memory
      self.gr_mem = [0xffd7] * Computer.MEM_SIZE  # The graphics memory (Initialise with background colour)
      self.regs = [0x0000] * Computer.NUM_REGS    # Registers R0 - R4, IDX, FP, LR
      self.flags = [False] * Computer.NUM_FLAGS   # The C, A, E, Z, N, V flags
      self.sp = 0xffef                            # Stack pointer
      self.pc = 0x0000                            # Program counter
      self.cmd = 0x00                             # The current instruction type
      self.instr = 0x0000                         # The current instruction
      self.cond = 0x0000                          # The conditional jump
      self.two_byte_instr = False                 # Is it a 2 byte instruction
      self.ints = False                           # Interrupts enabled ?
      self.rti_addr = 0x0000                      # An interrupt's return address
      self.rega = 0                               # The A register
      self.regb = 0                               # The B register
      self.regc = 0                               # The C register
      self.byte_2 = 0x0000                        # Used for the 2nd byte of 2 byte instructions
      self.asm_code = ''                          # Used when displaying the instruction
      self.state = Computer.ST_READY              # The computer's current execution state
      self.breakpoints = []                       # List of current breakpoints
      self.InitialRAM = None                      # Store RAM machine code for reloading at resets
      self.fpu = FPU()                            # Floating Point Unit

   # Return the string representation of a register
   def strReg(reg):
      if reg <= 4:
         return f'R{reg}'
      elif reg == Computer.IDX:
         return 'IDX'
      elif reg == Computer.FP:
         return 'FP'
      elif reg == Computer.LR:
         return 'LR'
      else:
         return 'Invalid Register'

   # Get valid hex or decimal user input
   def GetInput(self, text, hex=True, char=False):
      valid = False
      while not valid:
         try:
            if hex:
               val = int(input(text),16) & 0xffff
            elif not char:
               val = int(input(text))
            else:
               val = input(text)
               if len(val) == 0:
                  return 0x0a  # Return LF
               if len(val) != 1:
                  raise ValueError
               else:
                  val = ord(val)
            valid = True
         except ValueError:
            print('Invalid Value ...')
            valid = False
         except:
            exit()
      return val

   # Convert a 'float' Graphics Screen co-ord to a 'decimal' co-ord
   def FPToDec(val):
      # Values < 0.5 equate to 0
      if val < 0x3800:
         return 0x0000

      # Extract the sign bit, exponent & (1 + mantissa)
      sign = (val & 0x8000) >> 15
      exp = (val & 0x7c00) >> 10
      mant1 = 0x0400 + (val & 0x03ff)

      if (exp > 25) or (exp < 14):
         # Outwith a valid range for the Graphics Screen: [-127,127]
         return 0x00ff
      
      dec = mant1 >> (25 - exp)
      round = (mant1 << (exp - 14)) & 0x7fff

      if round > 0x3ff:
         # Round up
         dec += 1

      if sign == 1:
         dec *= -1

      return (dec & 0x00ff)

   # Get a Graphics Screen position from floating point co-ords
   def GetScreenPos(x, y):
      x_pos = Computer.FPToDec(x)
      y_pos = Computer.FPToDec(y)

      x_pos = (x_pos + 0x007f) & 0x00ff
      y_pos = (0x007f - y_pos) << 8
      pos = x_pos + y_pos

      # Is the point within the Graphics Screen bounds ?
      on_scr = False
      x &= 0x7fff
      y &= 0x7fff
      if (x < 0x57f8) and (y < 0x57f8):
         on_scr = True

      return (pos, on_scr)

   # The following set/report the current execution state
   def Run(self):
      self.state = Computer.ST_RUNNING

   def Ready(self):
      return self.state == Computer.ST_READY

   def Running(self):
      return self.state == Computer.ST_RUNNING

   def Halted(self):
      return self.state == Computer.ST_HALT

   def Stopped(self):
      return self.state == Computer.ST_END

   # Get code into memory
   def LoadMemory(self, fileIn, RAM=False):
      if RAM:
         addr = Computer.RAM_START
         if self.InitialRAM == None:
            self.InitialRAM = fileIn
      else:
         addr = Computer.ROM_START

      with open(fileIn,'r') as mc:
         for line in mc:
            line = line.strip()

            # Ignore header line
            if line.startswith('v3.0 hex words plain'):
                  continue

            codes = line.split(' ')
            for code in codes:
               if code == '':
                  continue

               if RAM and addr >= Computer.MEM_SIZE:
                  print("\n*** CRASH ***\nProgram too big for RAM\n")
                  exit()
               elif not RAM and addr >= Computer.RAM_START:
                  print("\n*** CRASH ***\nProgram too big for ROM\n")
                  exit()

               self.mem[addr] = int(code, 16)
               addr += 1

   # Reset everything bar the ROM
   def Reset(self):
      for i in range(Computer.RAM_START, Computer.MEM_SIZE):
         self.mem[i] = 0
      Computer.LoadMemory(self, self.InitialRAM, RAM=True)
      for i in range(Computer.NUM_REGS):
         self.regs[i] = 0
      for i in range(Computer.NUM_FLAGS):
         self.flags[i] = False
      self.pc = 0
      self.sp = 0xffef
      self.state = Computer.ST_READY

   # Show the next instruction to be executed & the contents of registers/flags
   def DisplayState(self):
      if self.state == Computer.ST_READY:
         print('Waiting to run - Perform Run (R) or Step (S) to start')
         return

      print(f'R0:  0x{self.regs[0]:04x}, R1: 0x{self.regs[1]:04x}, R2: 0x{self.regs[2]:04x}, R3: 0x{self.regs[3]:04x}, R4: 0x{self.regs[4]:04x}')
      print(f'IDX: 0x{self.regs[Computer.IDX]:04x}, FP: 0x{self.regs[Computer.FP]:04x}, LR: 0x{self.regs[Computer.LR]:04x}, SP: 0x{self.sp:04x}, ', end='')
      if self.two_byte_instr:
         print(f'PC: 0x{self.pc-1:04x}')
      else:
         print(f'PC: 0x{self.pc:04x}')
      print(f'\nFlags - C: {self.flags[Computer.C]}, A: {self.flags[Computer.A]}, E: {self.flags[Computer.E]}, Z: {self.flags[Computer.Z]}, N: {self.flags[Computer.N]}, V: {self.flags[Computer.V]}')
      unf,ovf,inf,nan = self.fpu.get_flags()
      print(f'FPU - UNF: {unf}, OVF: {ovf}, INF: {inf}, NaN: {nan}')
      print(f'Interrupts Enabled: {self.ints}')
      print(f'\nIN_1: 0x{self.mem[Computer.IN_1]:04x}, WAIT_1: 0x{self.mem[Computer.WAIT_1]:04x}, ENTER_1: 0x{self.mem[Computer.ENT_1]:04x}, OUT_1: 0x{self.mem[Computer.OUT_1]:04x}')
      print(f'IN_2: 0x{self.mem[Computer.IN_2]:04x}, WAIT_2: 0x{self.mem[Computer.WAIT_2]:04x}, ENTER_2: 0x{self.mem[Computer.ENT_2]:04x}, OUT_2: 0x{self.mem[Computer.OUT_2]:04x}\n')

      if self.state == Computer.ST_END:
         print(f'Program has completed - Perform Reset (RS) to re-run')
      else:
         print(f'Next Instr: {self.asm_code} (0x{self.instr:04x}', end='')
         if self.two_byte_instr:
            print(f', 0x{self.byte_2:04x})')
         else:
            print(f')')

   # Show the current breakpoints
   def DisplayBreakpoints(self):
      if len(self.breakpoints) == 0:
         print('There are no breakpoints set')
         return

      print(f'Current breakpoints: ', end='')
      for bp in self.breakpoints:
         print(f'0x{bp:04x} ', end='')
      print()

   # Add a breakpoint
   def SetBreakpoint(self):
      bp = Computer.GetInput(self, 'Add a breakpoint at PC = 0x')
      if bp not in self.breakpoints:
         self.breakpoints.append(bp)

   # Delete a breakpoint
   def DeleteBreakpoint(self):
      bp = Computer.GetInput(self, 'Remove breakpoint at PC = 0x')
      if bp in self.breakpoints:
         self.breakpoints.remove(bp)
      else:
         print("\nBreakpoint doesn't exist")

   # Display a memory region/location
   def DisplayMemory(self):
      addr = Computer.GetInput(self, 'Starting Address: 0x')
      num_words = Computer.GetInput(self, 'How many words: ', hex=False)

      if num_words == 0:
         print()

      # A single address has been requested
      elif num_words == 1:
         val = self.mem[addr]
         print(f'\nMemory 0x{addr:04x}: {val:04x}')

      # # A range of addresses has been requested
      elif num_words > 1:
         for i in range(num_words):
            if i % 16 == 0:
               print(f'\nMemory 0x{addr+i:04x}:', end='')
            elif i % 8 == 0:
               print(' ', end='')
            print(f' {self.mem[addr+i]:04x}', end='')
         print()

   # Set a single memory location
   def SetMemory(self):
      addr = Computer.GetInput(self, 'Address: 0x')
      val = Computer.GetInput(self, 'Val: 0x')
      self.mem[addr] = val

   # Deal with an interrupt
   def Interrupt(self):
      int = Computer.GetInput(self, 'Interrupt Number: ', hex=False)
      if self.ints:
         # Interrupts enabled
         if int < 1 or int > 3:
            print('\nInterrupt Ignored - That is an invalid Interrupt Number\n')
         else:
            self.rti_addr = self.pc
            if int == 1:
               self.pc = 0x0010
            elif int == 2:
               self.pc = 0x0012
            elif int == 3:
               self.pc = 0x0014
            print()
      else:
         # Interrupts disabled
         print('\nInterrupt Ignored - Interrupts are currently disabled\n')

   # Dump the graphics memory
   def GraphicsDump(self):
      with open('Graphics.dat','w') as mc:
         mc.write('v3.0 hex words plain\n')
         for addr in range(Computer.MEM_SIZE):
            count = addr + 1
            word = hex(self.gr_mem[addr])[2:]
            if (count % 16) == 0:
               sep = '\n'
            elif (count % 8) == 0:
               sep = '  '
            else:
               sep = ' '
            while len(word) < 4:
               word = '0' + word
            mc.write(word + sep)
      print("Graphics dumped to 'Graphics.dat'")

   # Set the C, A, E, Z & V flags
   # NB: The A & E flags may not agree with SAL-16 for the single argument 
   #     commands INC/DEC/NOT as SAL-16 makes no comparison with RB in those
   #     cases - So the A & E flags are meaningless for those commands.
   def SetFlags(self, res):
      ra = self.regs[self.rega]
      rb = self.regs[self.regb]

      # Carry Flag
      self.flags[Computer.C] = False
      if res > 0xffff:
         self.flags[Computer.C] = True
         
      # Greater Than Flag
      self.flags[Computer.A] = False
      a_neg = False
      if (ra & 0x8000) == 0x8000:
         a_neg = True
      b_neg = False
      if (rb & 0x8000) == 0x8000:
         b_neg = True

      if a_neg and b_neg:
         if self.cmd == Computer.CMD_FCMP:
            if ra < rb:
               self.flags[Computer.A] = True
         elif ra > rb:
            self.flags[Computer.A] = True
      elif a_neg and not b_neg:
         self.flags[Computer.A] = False
      elif not a_neg and b_neg:
         self.flags[Computer.A] = True
      elif ra > rb:
         self.flags[Computer.A] = True

      # Equals Flag
      self.flags[Computer.E] = False
      if ra == rb:
         self.flags[Computer.E] = True

      # Zero Flag
      self.flags[Computer.Z] = False
      if res & 0xffff == 0:
         self.flags[Computer.Z] = True

      # Negative Flag
      self.flags[Computer.N] = False
      if res & 0x8000 == 0x8000:
         self.flags[Computer.N] = True

      # Overflow Flag
      self.flags[Computer.V] = False
      if self.cmd == Computer.CMD_ADD:
         res &= 0xffff
         if ra < 0x8000 and rb < 0x8000 and res > 0x7fff:
            # pos + pos = neg
            self.flags[Computer.V] = True
         elif ra > 0x7fff and rb > 0x7fff and res < 0x8000:
            # neg + neg = pos
            self.flags[Computer.V] = True

      elif self.cmd == Computer.CMD_SUB:
         res &= 0xffff
         if ra < 0x8000 and rb > 0x7fff and res > 0x7fff:
            # pos - neg = neg
            self.flags[Computer.V] = True
         elif ra > 0x7fff and rb < 0x8000 and res < 0x8000:
            # neg - pos = pos
            self.flags[Computer.V] = True

      elif self.cmd == Computer.CMD_MUL:
         if res < Computer.INT_LOW or res > Computer.INT_HIGH:
            self.flags[Computer.V] = True

   # Fetch the next instruction to be computed
   def FetchInstr(self):
      self.two_byte_instr = False

      # Is the instruction at a breakpoint ?
      if self.pc in self.breakpoints:
         self.state = Computer.ST_HALT
         print(f'Hit breakpoint at PC = 0x{self.pc:04x}\n')

      # The instruction is pointed to by the PC
      self.instr = self.mem[self.pc]

      # Now prepare for function execution:
      #   Get source/destination registers
      #   Set the 'Display State' info
      #   Get the 2nd byte for 2 byte commands

      # LDI RC,data 
      if self.instr & Computer.OPCODE_MASK == 0x0000:
         self.cmd = Computer.CMD_LDI
         self.two_byte_instr = True
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.pc += 1
         self.byte_2 = self.mem[self.pc]
         self.asm_code = f'LDI {Computer.strReg(self.regc)},0x{self.byte_2:04x}'

      # JMP addr
      elif self.instr & Computer.OPCODE_MASK == 0x0800:
         self.cmd = Computer.CMD_JMP
         self.two_byte_instr = True
         self.pc += 1
         self.byte_2 = self.mem[self.pc]
         self.asm_code = f'JMP 0x{self.byte_2:04x}'

      # CALL addr
      elif self.instr & Computer.OPCODE_MASK == 0x1000:
         self.cmd = Computer.CMD_CALL
         self.two_byte_instr = True
         self.pc += 1
         self.byte_2 = self.mem[self.pc]
         self.asm_code = f'CALL 0x{self.byte_2:04x}'

      # JCOND addr
      elif self.instr & Computer.OPCODE_MASK == 0x1800:
         self.cmd = Computer.CMD_JCOND
         self.cond = self.instr & Computer.COND_MASK
         if self.cond == Computer.JEQ:
             str_cond = 'JEQ'
         elif self.cond == Computer.JNE:
             str_cond = 'JNE'
         elif self.cond == Computer.JZ:
             str_cond = 'JZ'
         elif self.cond == Computer.JNZ:
             str_cond = 'JNZ'
         elif self.cond == Computer.JC:
             str_cond = 'JC'
         elif self.cond == Computer.JNC:
             str_cond = 'JNC'
         elif self.cond == Computer.JGT:
             str_cond = 'JGT'
         elif self.cond == Computer.JGE:
             str_cond = 'JGE'
         elif self.cond == Computer.JLT:
             str_cond = 'JLT'
         elif self.cond == Computer.JLE:
             str_cond = 'JLE'
         elif self.cond == Computer.JPL:
             str_cond = 'JPL'
         elif self.cond == Computer.JMI:
             str_cond = 'JMI'
         elif self.cond == Computer.JV:
             str_cond = 'JV'
         elif self.cond == Computer.JNV:
             str_cond = 'JNV'
         self.two_byte_instr = True
         self.pc += 1
         self.byte_2 = self.mem[self.pc]
         self.asm_code = f'{str_cond} 0x{self.byte_2:04x}'

      # LD RC,[RA]
      elif self.instr & Computer.OPCODE_MASK == 0x2000:
         self.cmd = Computer.CMD_LD
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'LD {Computer.strReg(self.regc)},[{Computer.strReg(self.rega)}]'

      # LDX RC,[RA,RB]
      elif self.instr & Computer.OPCODE_MASK == 0x2800:
         self.cmd = Computer.CMD_LDX
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'LDX {Computer.strReg(self.regc)},[{Computer.strReg(self.rega)},{Computer.strReg(self.regb)}]'

      # ST RA,[RC]
      elif self.instr & Computer.OPCODE_MASK == 0x3000:
         self.cmd = Computer.CMD_ST
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'ST {Computer.strReg(self.rega)},[{Computer.strReg(self.regc)}]'

      # STX RA,[RC,RB]
      elif self.instr & Computer.OPCODE_MASK == 0x3800:
         self.cmd = Computer.CMD_STX
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'STX {Computer.strReg(self.rega)},[{Computer.strReg(self.regc)},{Computer.strReg(self.regb)}]'

      # MOV RA,RC
      elif self.instr & Computer.OPCODE_MASK == 0x4000:
         self.cmd = Computer.CMD_MOV
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'MOV {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

      # MOVSP RC
      elif self.instr & Computer.OPCODE_MASK == 0x4800:
         self.cmd = Computer.CMD_MOVSP
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'MOVSP {Computer.strReg(self.regc)}'

      # SETPX RA,RB
      elif self.instr & Computer.OPCODE_MASK == 0x5000:
         self.cmd = Computer.CMD_SETPX
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.asm_code = f'SETPX {Computer.strReg(self.rega)},{Computer.strReg(self.regb)}'

      # FSETPX RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0x5800:
         self.cmd = Computer.CMD_FSETPX
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'FSETPX {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # DSI / ENI
      elif self.instr & Computer.OPCODE_MASK == 0x6000:
         if self.instr & 0b1 == 0b0:
            self.cmd = Computer.CMD_DSI
            self.asm_code = f'DSI'
         else:
            self.cmd = Computer.CMD_ENI
            self.asm_code = f'ENI'

      # RTI
      elif self.instr & Computer.OPCODE_MASK == 0x6800:
         self.cmd = Computer.CMD_RTI
         self.asm_code = f'RTI'

      # JMPR RA / RET
      elif self.instr & Computer.OPCODE_MASK == 0x7000:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         if self.rega == Computer.LR:
            self.cmd = Computer.CMD_RET
            self.asm_code = f'RET'
         else:
            self.cmd = Computer.CMD_JMPR
            self.asm_code = f'JMPR {Computer.strReg(self.rega)}'

      # POP RC
      elif self.instr & Computer.OPCODE_MASK == 0x7800:
         self.cmd = Computer.CMD_POP
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'POP {Computer.strReg(self.regc)}'

      # PUSH RA
      elif self.instr & Computer.OPCODE_MASK == 0x8000:
         self.cmd = Computer.CMD_PUSH
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.asm_code = f'PUSH {Computer.strReg(self.rega)}'

      # ADD RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0x8800:
         self.cmd = Computer.CMD_ADD
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'ADD {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # LSL RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0x9000:
         self.cmd = Computer.CMD_LSL
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'LSL {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # LSR RA,RB,RC / ASR RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0x9800:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         if self.instr & 0b1 == 0b0:
            self.cmd = Computer.CMD_LSR
            self.asm_code = f'LSR {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'
         else:
            self.cmd = Computer.CMD_ASR
            self.asm_code = f'ASR {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # INC RA
      elif self.instr & Computer.OPCODE_MASK == 0xa000:
         self.cmd = Computer.CMD_INC
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.asm_code = f'INC {Computer.strReg(self.rega)}'

      # DEC RA
      elif self.instr & Computer.OPCODE_MASK == 0xa800:
         self.cmd = Computer.CMD_DEC
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.asm_code = f'DEC {Computer.strReg(self.rega)}'

      # NOT RA,RC
      elif self.instr & Computer.OPCODE_MASK == 0xb000:
         self.cmd = Computer.CMD_NOT
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'NOT {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

      # AND RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0xb800:
         self.cmd = Computer.CMD_AND
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'AND {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # OR RA,RB,RC
      elif self.instr & Computer.OPCODE_MASK == 0xc000:
         self.cmd = Computer.CMD_OR
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         self.asm_code = f'OR {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # XOR RA,RB,RC / CLR RA
      elif self.instr & Computer.OPCODE_MASK == 0xc800:
         self.cmd = Computer.CMD_XOR
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         if self.rega == self.regb == self.regc:
            self.asm_code = f'CLR {Computer.strReg(self.rega)}'
         else:
            self.asm_code = f'XOR {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      # CMP RA,RB / FCMP RA,RB
      elif self.instr & Computer.OPCODE_MASK == 0xd000:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         if self.instr & 0b11 == 0b00:
            self.cmd = Computer.CMD_CMP
            self.asm_code = f'CMP {Computer.strReg(self.rega)},{Computer.strReg(self.regb)}'
         elif self.instr & 0b11 == 0b01:
            self.cmd = Computer.CMD_FCMP
            self.asm_code = f'FCMP {Computer.strReg(self.rega)},{Computer.strReg(self.regb)}'

      # HALT
      elif self.instr & Computer.OPCODE_MASK == 0xd800:
         self.cmd = Computer.CMD_HALT
         self.asm_code = 'HALT'

      elif self.instr & Computer.OPCODE_MASK == 0xe000:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT

         # SUB RA,RB,RC
         if self.instr & 0b11 == 0b00:
            self.cmd = Computer.CMD_SUB
            self.asm_code = f'SUB {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # MUL RA,RB,RC
         elif self.instr & 0b11 == 0b01:
            self.cmd = Computer.CMD_MUL
            self.asm_code = f'MUL {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # SDIV RA,RB,RC
         elif self.instr & 0b11 == 0b10:
            self.cmd = Computer.CMD_SDIV
            self.asm_code = f'SDIV {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # UDIV RA,RB,RC
         elif self.instr & 0b11 == 0b11:
            self.cmd = Computer.CMD_UDIV
            self.asm_code = f'UDIV {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      elif self.instr & Computer.OPCODE_MASK == 0xe800:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regb = (self.instr & Computer.REGB_MASK) >> Computer.REGB_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT

         # FADD RA,RB,RC
         if self.instr & 0b11 == 0b00:
            self.cmd = Computer.CMD_FADD
            self.asm_code = f'FADD {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # FSUB RA,RB,RC
         if self.instr & 0b11 == 0b01:
            self.cmd = Computer.CMD_FSUB
            self.asm_code = f'FSUB {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # FMUL RA,RB,RC
         elif self.instr & 0b11 == 0b10:
            self.cmd = Computer.CMD_FMUL
            self.asm_code = f'FMUL {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

         # FDIV RA,RB,RC
         elif self.instr & 0b11 == 0b11:
            self.cmd = Computer.CMD_FDIV
            self.asm_code = f'FDIV {Computer.strReg(self.rega)},{Computer.strReg(self.regb)},{Computer.strReg(self.regc)}'

      elif self.instr & Computer.OPCODE_MASK == 0xf000:
         self.rega = (self.instr & Computer.REGA_MASK) >> Computer.REGA_SHIFT
         self.regc = (self.instr & Computer.REGC_MASK) >> Computer.REGC_SHIFT
         
         # FSQRT RA,RC
         if self.instr & 0b11 == 0b00:
            self.cmd = Computer.CMD_FSQRT
            self.asm_code = f'FSQRT {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

         # FSIN RA,RC
         if self.instr & 0b11 == 0b01:
            self.cmd = Computer.CMD_FSIN
            self.asm_code = f'FSIN {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

         # FCOS RA,RC
         elif self.instr & 0b11 == 0b10:
            self.cmd = Computer.CMD_FCOS
            self.asm_code = f'FCOS {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

         # FTAN RA,RC
         elif self.instr & 0b11 == 0b11:
            self.cmd = Computer.CMD_FTAN
            self.asm_code = f'FTAN {Computer.strReg(self.rega)},{Computer.strReg(self.regc)}'

      # END
      elif self.instr == 0xf800:
         self.cmd = Computer.CMD_END
         self.asm_code = f'END'

      else:
         print(f'Invalid Instruction - Code: 0x{self.instr:04x} at PC: 0x{self.pc:04x} ...\n')
         exit()

   # Execute the current instruction:
   #   Perform the required calculation
   #   Update the flags
   #   Adjust the PC

   def ExecInstr(self):
      # LDI RC,data
      if self.cmd == Computer.CMD_LDI:
         self.regs[self.regc] = self.mem[self.pc]
         self.pc += 1

      # JMP addr
      elif self.cmd == Computer.CMD_JMP:
         self.pc = self.byte_2

      # CALL addr
      elif self.cmd == Computer.CMD_CALL:
         self.regs[Computer.LR] = self.pc + 1
         self.pc = self.byte_2

      # JCOND addr
      elif self.cmd == Computer.CMD_JCOND:
         jump = False 
         if (self.cond == Computer.JEQ) and self.flags[Computer.E]:
               jump = True
         if (self.cond == Computer.JNE) and not self.flags[Computer.E]:
               jump = True
         if (self.cond == Computer.JZ) and self.flags[Computer.Z]:
               jump = True
         if (self.cond == Computer.JNZ) and not self.flags[Computer.Z]:
               jump = True
         if (self.cond == Computer.JC) and self.flags[Computer.C]:
               jump = True
         if (self.cond == Computer.JNC) and not self.flags[Computer.C]:
               jump = True
         if (self.cond == Computer.JGT) and self.flags[Computer.A]:
               jump = True
         if (self.cond == Computer.JGE):
               if (self.flags[Computer.A] or self.flags[Computer.E]):
                  jump = True
         if (self.cond == Computer.JLT):
               if not self.flags[Computer.A] and not self.flags[Computer.E]:
                  jump = True
         if (self.cond == Computer.JLE) and not self.flags[Computer.A]:
               jump = True
         if (self.cond == Computer.JPL) and not self.flags[Computer.N]:
               jump = True
         if (self.cond == Computer.JMI) and self.flags[Computer.N]:
               jump = True
         if (self.cond == Computer.JV) and self.flags[Computer.V]:
               jump = True
         if (self.cond == Computer.JNV) and not self.flags[Computer.V]:
               jump = True
         if jump:
            self.pc = self.byte_2
         else:
            self.pc += 1

      # LD RC,[RA]
      if self.cmd == Computer.CMD_LD:
         # Perform any required user entry
         if self.regs[self.rega] == Computer.KBD:
            self.mem[Computer.KBD]  = Computer.GetInput(self, 'Enter KBD Char: ', hex=False, char=True)
            print()
         elif self.regs[self.rega] == Computer.IN_1:
            self.mem[Computer.IN_1]  = Computer.GetInput(self, 'Enter IN_1: 0x')
            print()
         elif self.regs[self.rega] == Computer.ENT_1:
            # ENTER_1 should be '0' or '1'
            ent_1 = Computer.GetInput(self, 'Enter ENTER_1: 0x')
            while ent_1 > 1:
               ent_1 = Computer.GetInput(self, 'Enter ENTER_1: 0x')
            self.mem[Computer.ENT_1] = ent_1
            print()
         elif self.regs[self.rega] == Computer.IN_2:
            self.mem[Computer.IN_2]  = Computer.GetInput(self, 'Enter IN_2: 0x')
            print()
         elif self.regs[self.rega] == Computer.ENT_2:
            # ENTER_2 should be '0' or '1'
            ent_2 = Computer.GetInput(self, 'Enter ENTER_2: 0x')
            while ent_2 > 1:
               ent_2 = Computer.GetInput(self, 'Enter ENTER_2: 0x')
            self.mem[Computer.ENT_2] = ent_2
            print()

         self.regs[self.regc] = self.mem[self.regs[self.rega]]
         self.pc += 1

      # LDX RC,[RA,RB]
      elif self.cmd == Computer.CMD_LDX:
         addr = self.regs[self.rega] + self.regs[self.regb]
         if addr > 0xffff:
            # To deal with negative offsets
            addr -= 0x10000
         self.regs[self.regc] = self.mem[addr]
         self.pc += 1

      # ST RA,[RC]
      elif self.cmd == Computer.CMD_ST:
         # Display any TTY data
         if self.regs[self.regc] == Computer.TTY:
            print(f'Displayed TTY Char: {chr(self.regs[self.rega])}\n')
         # Reset ENT_x if WAIT_x goes low
         elif self.regs[self.regc] == Computer.WAIT_1 and self.regs[self.rega] == 0x0000:
            self.mem[Computer.ENT_1] = 0x0000
         elif self.regs[self.regc] == Computer.WAIT_2 and self.regs[self.rega] == 0x0000:
            self.mem[Computer.ENT_2] = 0x0000
         elif self.regs[self.regc] == Computer.ERR:
            print('*****\nERROR - See OUT_1 for the Error Code\n*****\n')
         self.mem[self.regs[self.regc]] = self.regs[self.rega]
         self.pc += 1

      # STX RA,[RC,RB]
      elif self.cmd == Computer.CMD_STX:
         addr = self.regs[self.regc] + self.regs[self.regb]
         if addr > 0xffff:
            # To deal with negative offsets
            addr -= 0x10000
         self.mem[addr] = self.regs[self.rega]
         self.pc += 1

      # MOV RA,RC
      elif self.cmd == Computer.CMD_MOV:
         self.regs[self.regc] = self.regs[self.rega]
         self.pc += 1

      # MOVSP RC
      elif self.cmd == Computer.CMD_MOVSP:
         self.regs[self.regc] = self.sp
         self.pc += 1

      # SETPX RA,RB
      elif self.cmd == Computer.CMD_SETPX:
         addr = self.regs[self.rega]
         self.gr_mem[addr] = self.regs[self.regb]
         self.pc += 1

      # FSETPX RA,RB,RC
      elif self.cmd == Computer.CMD_FSETPX:
         pos,on_scr = Computer.GetScreenPos(self.regs[self.rega], self.regs[self.regb]) 
         if on_scr:
            self.gr_mem[pos] = self.regs[self.regc]
         self.pc += 1

      # DSI
      elif self.cmd == Computer.CMD_DSI:
         self.ints = False
         self.pc += 1

      # ENI
      elif self.cmd == Computer.CMD_ENI:
         self.ints = True
         self.pc += 1

      # RTI
      elif self.cmd == Computer.CMD_RTI:
         self.pc = self.rti_addr

      # JMPR RA
      elif self.cmd == Computer.CMD_JMPR:
         self.pc = self.regs[self.rega]

      # RET
      elif self.cmd == Computer.CMD_RET:
         self.pc = self.regs[Computer.LR]

      # POP RC
      elif self.cmd == Computer.CMD_POP:
         self.sp += 1
         if self.sp >= Computer.IO_START:
            print('*** CRASH ***\nStack Underflow - Stack Pointer now points to I/O memory\n')
            exit()
         self.regs[self.regc] = self.mem[self.sp]
         self.pc += 1

      # PUSH RA
      elif self.cmd == Computer.CMD_PUSH:
         self.mem[self.sp] = self.regs[self.rega]
         self.sp -= 1
         if self.sp < Computer.RAM_START:
            print('*** CRASH ***\nStack Overflow - Stack Pointer now points to ROM\n')
            exit()
         self.pc += 1

      # ADD RA,RB,RC
      elif self.cmd == Computer.CMD_ADD:
         res = self.regs[self.rega] + self.regs[self.regb]
         Computer.SetFlags(self, res)
         if res > 0xffff:
            res &= 0xffff
         self.regs[self.regc] = res
         self.pc += 1

      # LSL RA,RB,RC
      elif self.cmd == Computer.CMD_LSL:
         res = self.regs[self.rega] << self.regs[self.regb]
         Computer.SetFlags(self, res)
         if res > 0xffff:
            res &= 0xffff
         self.regs[self.regc] = res
         self.pc += 1

      # LSR RA,RB,RC
      elif self.cmd == Computer.CMD_LSR:
         res = self.regs[self.rega] >> self.regs[self.regb]
         carry = self.regs[self.rega] & (1 << (self.regs[self.regb] - 1))
         Computer.SetFlags(self, res)
         self.flags[Computer.C] = False            
         if carry >= 1:
            self.flags[Computer.C] = True
         self.regs[self.regc] = res
         self.pc += 1

      # ASR RA,RB,RC
      elif self.cmd == Computer.CMD_ASR:
         msb = self.regs[self.rega] & 0x8000
         res = self.regs[self.rega]
         carry = self.regs[self.rega] & (1 << (self.regs[self.regb] - 1))
         for _ in range(self.regs[self.regb]):
            res = res >> 1
            res |= msb
         Computer.SetFlags(self, res)
         self.flags[Computer.C] = False            
         if carry >= 1:
            self.flags[Computer.C] = True
         self.regs[self.regc] = res
         self.pc += 1

      # INC RA
      elif self.cmd == Computer.CMD_INC:
         res = self.regs[self.rega] + 1
         Computer.SetFlags(self, res)
         if res > 0xffff:
            res = 0x0000
         self.regs[self.rega] = res
         self.pc += 1

      # DEC RA
      elif self.cmd == Computer.CMD_DEC:
         res = self.regs[self.rega] - 1
         Computer.SetFlags(self, res)
         if res < 0:
            res = 0xffff
         else:
            # SAL-16 decrements by adding 0xffff so (except for 0) there's a carry
            self.flags[Computer.C] = True
         self.regs[self.rega] = res
         self.pc += 1

      # NOT RA,RC
      elif self.cmd == Computer.CMD_NOT:
         res = (~self.regs[self.rega]) & 0xffff
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # AND RA,RB,RC
      elif self.cmd == Computer.CMD_AND:
         res = self.regs[self.rega] & self.regs[self.regb]
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # OR RA,RB,RC
      elif self.cmd == Computer.CMD_OR:
         res = self.regs[self.rega] | self.regs[self.regb]
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # XOR RA,RB,RC / CLR RA
      elif self.cmd == Computer.CMD_XOR:
         res = self.regs[self.rega] ^ self.regs[self.regb]
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # CMP RA,RB / FCMP RA,RB
      elif self.cmd == Computer.CMD_CMP or self.cmd == Computer.CMD_FCMP:
         res = 0x0001
         Computer.SetFlags(self, res)
         self.pc += 1

      # HALT
      elif self.cmd == Computer.CMD_HALT:
         cont = 0
         while (cont != ord('c')):
            cont = Computer.GetInput(self, "Enter 'c' to continue: ", hex=False, char=True)
         print()
         self.pc += 1

      # SUB RA,RB,RC
      elif self.cmd == Computer.CMD_SUB:
         res = self.regs[self.rega] - self.regs[self.regb]
         Computer.SetFlags(self, res)
         if res < 0:
            self.flags[Computer.C] = True
            res += 0x10000
         self.regs[self.regc] = res
         self.pc += 1

      # MUL RA,RB,RC
      elif self.cmd == Computer.CMD_MUL:
         res = self.regs[self.rega] * self.regs[self.regb]
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res & 0xffff
         self.pc += 1

      # SDIV RA,RB,RC
      elif self.cmd == Computer.CMD_SDIV:
         x = self.regs[self.rega]
         if x > 0x7fff:
            x -= 0x10000
         y = self.regs[self.regb]
         if y > 0x7fff:
            y -= 0x10000
         if y == 0:
            # Logisim Divider gives: x / 0 = x
            res = x
         else:
            res = int(x/y)
            if res < 0:
               res += 0x10000
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # UDIV RA,RB,RC
      elif self.cmd == Computer.CMD_UDIV:
         x = self.regs[self.rega]
         y = self.regs[self.regb]
         if y == 0:
            # Logisim Divider gives: x % 0 = 0
            res = 0
         else:
            res = int(x/y)
         Computer.SetFlags(self, res)
         self.regs[self.regc] = res
         self.pc += 1

      # FADD RA,RB,RC
      elif self.cmd == Computer.CMD_FADD:
         res = self.fpu.calculate(FPU.ADD, self.regs[self.rega], self.regs[self.regb])
         self.regs[self.regc] = res
         self.pc += 1

      # FSUB RA,RB,RC
      elif self.cmd == Computer.CMD_FSUB:
         res = self.fpu.calculate(FPU.SUBTRACT, self.regs[self.rega], self.regs[self.regb])
         self.regs[self.regc] = res
         self.pc += 1

      # FMUL RA,RB,RC
      elif self.cmd == Computer.CMD_FMUL:
         res = self.fpu.calculate(FPU.MULTIPLY, self.regs[self.rega], self.regs[self.regb])
         self.regs[self.regc] = res
         self.pc += 1

      # FDIV RA,RB,RC
      elif self.cmd == Computer.CMD_FDIV:
         res = self.fpu.calculate(FPU.DIVIDE, self.regs[self.rega], self.regs[self.regb])
         self.regs[self.regc] = res
         self.pc += 1

      # FSQRT RA,RC
      elif self.cmd == Computer.CMD_FSQRT:
         res = self.fpu.calculate(FPU.SQRT, self.regs[self.rega])
         self.regs[self.regc] = res
         self.pc += 1

      # FSIN RA,RC
      elif self.cmd == Computer.CMD_FSIN:
         res = self.fpu.calculate(FPU.SIN, self.regs[self.rega])
         self.regs[self.regc] = res
         self.pc += 1

      # FCOS RA,RC
      elif self.cmd == Computer.CMD_FCOS:
         res = self.fpu.calculate(FPU.COS, self.regs[self.rega])
         self.regs[self.regc] = res
         self.pc += 1

      # FTAN RA,RC
      elif self.cmd == Computer.CMD_FTAN:
         res = self.fpu.calculate(FPU.TAN, self.regs[self.rega])
         self.regs[self.regc] = res
         self.pc += 1

      # END
      elif self.cmd == Computer.CMD_END:
         self.state = Computer.ST_END
         self.pc += 1

