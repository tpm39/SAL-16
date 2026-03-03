
'''
Compiler for the 'SAL-16x' Computer

Takes in a pseudo C file (eg: Prog.rmg) and produces an
assembly code file (Prog.asm) that can be assembled into 
machine code prior to loading into the computer's memory.

Usage: python3 <Path>Compiler.py [-h] [-m MEM] [-p PRINT_OPT] <Path>Prog.rmg <Path>Prog.asm
       where: MEM = ROM | RAM
              PRINT_OPT = NONE | TOKENS | NODES | ALL
              
See 'Compiler Guide.pdf' for further details.

'''

import argparse
import os
import Tokenizer
import Parser
import Generator

# Process the arguments
parser = argparse.ArgumentParser(
    prog='python3 Compiler.py',
    description="Compile an 'RMG' program",
    epilog='Good Luck :)')
parser.add_argument('fileIn', help="The input 'RMG' file")
parser.add_argument('fileOut', help='The output assembly code file')
parser.add_argument('-m', '--mem', action='store', default='RAM',
                    help='The target memory: ROM|RAM')
parser.add_argument('-p', '--print', action='store', default='NONE',
                    help='Print Tokens and/or Nodes: NONE|TOKENS|NODES|ALL')
args = parser.parse_args()

# Check target memory
target_mem = args.mem.upper()
if target_mem not in ['ROM', 'RAM']:
    print(f"Invalid target memory: '{target_mem}' - Using default: 'RAM'\n")
    target_mem = 'RAM'

# Check print option
print_opt = args.print.upper()
if print_opt not in ['NONE', 'TOKENS', 'NODES', 'ALL']:
    print(f"Invalid print option: '{print_opt}' - Using default: 'NONE'\n")
    print_opt = 'NONE'

# Get & check the input file
fileIn = os.path.normpath(args.fileIn)
if os.path.splitext(fileIn)[1] != '.rmg':
    print("\nInvalid Input File - You should use an 'rmg' file\n")
    exit(1)

# Get & check the output file
fileOut = os.path.normpath(args.fileOut)
if os.path.splitext(fileOut)[1] != '.asm':
    print("\nInvalid Output File - You should use an 'asm' file\n")
    exit(1)

# Delete an already existing output file
if os.path.exists(fileOut):
    os.remove(fileOut)

try:
    # Tokenize the RMG code
    print("Tokenizing 'rmg' file ...")
    tokens, include_files = Tokenizer.tokenize(fileIn)
    if print_opt in ['TOKENS', 'ALL']:
        Tokenizer.printTokens(tokens)

    # Parse the RMG code
    print("Parsing 'rmg' code ...")
    nodes = Parser.parse(tokens, fileIn, include_files)
    if print_opt in ['NODES', 'ALL']:
        Parser.printNodes(nodes)

    # Generate the assembly code
    print("Generating 'asm' file ...")
    Generator.generate(nodes, fileIn, fileOut, include_files, target_mem)

    print('\nCompilation Successful\n')

except SyntaxError as se:
    print(f'\nCompilation Failed:\n{se.msg} (line: {str(se.args[1][1])})\n')
    exit(1)

except Exception as e:
    print(e)
    exit(1)

