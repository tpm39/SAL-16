#!/usr/bin/env zsh

echo "\nCompiling '$1.rmg' ...\n"
python3 ./Tools/Compiler/Compiler.py -m ram -p none ./rmg/$1.rmg ./rmg/$1.asm

if [ $? -eq 0 ]; then
   echo "Assembling '$1.asm' ..."
   python3 ./Tools/Assembler.py ./rmg/$1.asm ./mc/$1.mc
fi

