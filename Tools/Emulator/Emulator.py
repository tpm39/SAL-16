
'''
Emulator for the 'SAL-16x' Computer

Emulates a machine code file (eg: Prog.mc) in RAM so that it can be tested.

There must also be an OS machine code file (eg: TimmiOS.mc) in ROM.

Usage: python3 <Path>Emulator.py [-h] <Path>Prog.mc <Path>TimmiOS.mc

'''

import argparse
import os
from EmulComputer import Computer

# Action codes
ACT_NONE      = 0
ACT_RUN       = 1
ACT_STEP      = 2
ACT_INTERRUPT = 3
ACT_RESET     = 4
ACT_ST_PRINT  = 5
ACT_MEM_SET   = 6
ACT_MEM_PRINT = 7
ACT_BP_SET    = 8
ACT_BP_DEL    = 9
ACT_BP_PRINT  = 10
ACT_GR_DUMP   = 11
ACT_HELP      = 12
ACT_QUIT      = 13

#------------------
# Helper Functions
#------------------

# Display the Help menu
def ShowHelp(startup):
   if startup:
      print()
   print('Available Actions')
   print('-----------------')
   print('  R  - Run')
   print('  S  - Step')
   print('  I  - Interrupt')
   print('  RS - Reset')
   print('  SP - State Print')
   print('  MS - Memory Set')
   print('  MP - Memory Print')
   print('  BS - Breakpoint Set')
   print('  BD - Breakpoint Delete')
   print('  BP - Breakpoint Print')
   print('  GD - Graphics Dump')
   print('  H  - Help')
   print('  Q  - Quit')

# Get the next action to be performed
def GetAction():
   act = ACT_NONE
   while act == ACT_NONE:
      resp = input('\nAction: ').upper()
      if resp == 'R':
         act = ACT_RUN
      elif resp == 'S':
         act = ACT_STEP
      elif resp == 'I':
         act = ACT_INTERRUPT
      elif resp== 'RS':
         act = ACT_RESET
      elif resp == 'SP':
         act = ACT_ST_PRINT
      elif resp == 'MS':
         act = ACT_MEM_SET
      elif resp == 'MP':
         act = ACT_MEM_PRINT
      elif resp == 'BS':
         act = ACT_BP_SET
      elif resp == 'BD':
         act = ACT_BP_DEL
      elif resp == 'BP':
         act = ACT_BP_PRINT
      elif resp == 'GD':
         act = ACT_GR_DUMP
      elif resp == 'H':
         act = ACT_HELP
      elif resp == 'Q':
         act = ACT_QUIT
      if act == ACT_NONE:
         print('\nInvalid Action ...')
   print()
   return act

#--------------
# Main Program
#--------------

# Process the arguments
parser = argparse.ArgumentParser(
    prog='python3 Emulator.py',
    description="Emulate an assembly code program",
    epilog='Good Luck :)')
parser.add_argument('fileProg', help='The program file')
parser.add_argument('fileOS', help='The OS file')
args = parser.parse_args()

# Get the RAM mc file to be emulated
fileRAM = args.fileProg

# Deal with relative paths
if fileRAM.startswith('./'):
    fileRAM = os.getcwd() + '/' + fileRAM[2:]
elif fileRAM.startswith('../'):
    fileRAM = os.path.dirname(os.getcwd()) + '/' + fileRAM[3:]

fileparts = fileRAM.split('.')
if fileparts[-1] != 'mc':
    print("Invalid program input - You should use an 'mc' file")
    exit()

# Get the ROM mc file to be emulated
fileROM = args.fileOS

# Deal with relative paths
if fileROM.startswith('./'):
    fileROM = os.getcwd() + '/' + fileROM[2:]
elif fileROM.startswith('../'):
    fileROM = os.path.dirname(os.getcwd()) + '/' + fileROM[3:]

fileparts = fileROM.split('.')
if fileparts[-1] != 'mc':
    print("Invalid OS input - You should use an 'mc' file")
    exit()

# Get an instance of the computer and load the OS & program
computer = Computer()
computer.LoadMemory(fileROM, RAM=False)
computer.LoadMemory(fileRAM, RAM=True)

ShowHelp(True)
action = ACT_NONE

# Run the emulation until we quit,
# Updating the computer's execution state as required,
# and performing the relevant actions.

got_action = False
in_step_action = False

while True:
   # Don't get any actions if we're running to end/breakpoint 
   if not got_action and (action != ACT_RUN or computer.Halted() or computer.Stopped()):
      action = GetAction()
   else:
      got_action = False

   # For step/run fetch/display/execute the current instruction
   if not computer.Stopped() and (action == ACT_STEP or action == ACT_RUN):
      if computer.Ready():
         computer.Run()

      # Start running again after a breakpoint
      if computer.Halted():
         computer.Run()
         computer.ExecInstr()

      if computer.Running():
         if not in_step_action:
            computer.FetchInstr()

         if computer.Halted():
            computer.DisplayState()
            continue

         if action == ACT_STEP:
            if not in_step_action:
               computer.DisplayState()

            action = GetAction()
            got_action = True
            if action not in [ACT_STEP, ACT_RUN, ACT_INTERRUPT, ACT_RESET, ACT_QUIT]:
               # Don't execute the instuction yet if 'stepping' has
               # been interrupted by any of the following actions:
               if action == ACT_ST_PRINT:
                  computer.DisplayState()
               elif action == ACT_MEM_SET:
                  computer.SetMemory()
               elif action == ACT_MEM_PRINT:
                  computer.DisplayMemory()
               elif action == ACT_BP_SET:
                  computer.SetBreakpoint()
               elif action == ACT_BP_DEL:
                  computer.DeleteBreakpoint()
               elif action == ACT_BP_PRINT:
                  computer.DisplayBreakpoints()
               elif action == ACT_GR_DUMP:
                  computer.GraphicsDump()
               elif action == ACT_HELP:
                  ShowHelp(False)

               action = ACT_STEP
               in_step_action = True
               continue

         in_step_action = False
         computer.ExecInstr()

      # Display the state if we've run to the end
      if computer.Stopped() and action == ACT_RUN:
         computer.DisplayState()

   elif computer.Stopped() and (action == ACT_STEP or action == ACT_RUN):
      computer.DisplayState()

   elif action == ACT_INTERRUPT:
      computer.Interrupt()
      action = ACT_STEP
      got_action = True
      in_step_action = False
      continue

   elif action == ACT_RESET:
      computer.Reset()
      print('Computer Reset - Perform Run (R) or Step (S) to start')

   elif action == ACT_ST_PRINT:
      computer.DisplayState()

   elif action == ACT_MEM_SET:
      computer.SetMemory()

   elif action == ACT_MEM_PRINT:
      computer.DisplayMemory()

   elif action == ACT_BP_SET:
      computer.SetBreakpoint()

   elif action == ACT_BP_DEL:
      computer.DeleteBreakpoint()

   elif action == ACT_BP_PRINT:
      computer.DisplayBreakpoints()

   elif action == ACT_GR_DUMP:
      computer.GraphicsDump()

   elif action == ACT_HELP:
      ShowHelp(False)

   elif action == ACT_QUIT:
      print('Emulation Finished\n')
      break

