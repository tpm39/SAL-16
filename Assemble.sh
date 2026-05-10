#!/usr/bin/env zsh

echo "\nAssembling '$1.asm' ...\n"
python3 ./Tools/Assembler.py ./asm/$1.asm ./mc/$1.mc

