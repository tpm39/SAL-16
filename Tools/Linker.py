
'''

Linker for the 'SAL-16x' Computer

Takes in an machine code files and produces the linked
machine code to load into the 'SAL-16x' computer's memory.

Usage: python3 <Path>Linker.py [-h] <Path>Out.mc <Path>File1.mc <Path>File2.mc ... <Path>Filen.mc

'''

import argparse
import os

# File Types
INPUT_FILE  = 0
OUTPUT_FILE = 1

# The Assembler produces lines of 16 two byte words & a 'null' line is:
NULL_LINE = '0000 0000 0000 0000 0000 0000 0000 0000  0000 0000 0000 0000 0000 0000 0000 0000\n'

#----------------
# Helper Fuction
#----------------

# Check that a file's OK
def ProcessFile(file, type):
    # Create the output directory if it doesn't exist
    if type == OUTPUT_FILE:
        dirOut = os.path.dirname(file)
        if dirOut != '' and not os.path.exists(dirOut):
            os.mkdir(dirOut)

    # Check its extension
    file_ext = os.path.splitext(file)[1][1:]
    if file_ext != 'mc':
        if type == INPUT_FILE:
            print(f"\nLink Failed - Invalid Input: {file} - Only 'mc' files can linked.\n")
        else:
            print(f"\nLink Failed - Invalid Output: {file} - It must be an 'mc' file.\n")
        exit()

    return file

#--------------
# Main Program
#--------------

# Process the arguments
parser = argparse.ArgumentParser(
    prog='python3 Linker.py',
    description='Link machine code files into a single file',
    epilog='Good Luck :)')
parser.add_argument('fileOut', help='The resulting machine code file')
parser.add_argument('filesIn', nargs='+', help='The machine code files to be linked')
args = parser.parse_args()

# Get the files to be linked
filesIn = []
num_in = len(args.filesIn)
for i in range(num_in):
    filesIn.append(ProcessFile(args.filesIn[i], INPUT_FILE))

# Get the output file
fileOut = ProcessFile(args.fileOut, OUTPUT_FILE)

# Initialise the output file data (header line & 2048 lines of 16 two byte words = 32 kB)
outLines = 2049 * [NULL_LINE]

try:
    # Add the data from each input file to the 'output data'
    for i in range(num_in):
        with open(filesIn[i], 'r') as mc:
            lineNo = 0
            for line in mc:
                # Only add 'non-null' lines ...
                if line != NULL_LINE:
                    # ... but only if the 'output data' line is 'null'
                    if outLines[lineNo] == NULL_LINE:
                        outLines[lineNo] = line
                    elif lineNo > 0:
                        # If a 'non-header' line is already 'non-null' there's a conflict
                        addr = 16 * (lineNo-1)
                        print(f'\nLink Failed - Memory conflict detected in: {filesIn[i]}')
                        print('Files may not overlap in the following ranges:')
                        print(f'ROM: {addr:#06x} - {addr+15:#06x}, or RAM: {0x8000+addr:#06x} - {0x8000+addr+15:#06x}\n')
                        exit()
                lineNo += 1

    # Create the output file
    with open(fileOut, 'w') as mc:
        mc.writelines(outLines)

    # We're done :)
    print(f'\nLinker Successfully Generated: {fileOut}\n')

except FileNotFoundError:
    print(f'\nLink Failed - File not found: {filesIn[i]}\n')

