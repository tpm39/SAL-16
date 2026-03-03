#!/usr/bin/env zsh

echo "Assembling 'BIOS.asm' ..."
python3 ./Tools/Assembler.py ./asm/BIOS.asm ./mc/BIOS.mc

if [ $? -eq 0 ]; then
   echo "Assembling 'MathsLib.asm' ..."
   python3 ./Tools/Assembler.py ./asm/MathsLib.asm ./mc/MathsLib.mc
else
   exit 1
fi

if [ $? -eq 0 ]; then
   echo "Assembling 'GraphicsLib.asm' ..."
   python3 ./Tools/Assembler.py ./asm/GraphicsLib.asm ./mc/GraphicsLib.mc
else
   exit 1
fi

if [ $? -eq 0 ]; then
   echo "Assembling 'StringsLib.asm' ..."
   python3 ./Tools/Assembler.py ./asm/StringsLib.asm ./mc/StringsLib.mc
else
   exit 1
fi

if [ $? -eq 0 ]; then
   echo "Assembling 'CastsLib.asm' ..."
   python3 ./Tools/Assembler.py ./asm/CastsLib.asm ./mc/CastsLib.mc
else
   exit 1
fi

if [ $? -eq 0 ]; then
   echo "Linking ..."
   python3 ./Tools/Linker.py ./mc/TimmiOS.mc ./mc/BIOS.mc ./mc/MathsLib.mc ./mc/GraphicsLib.mc ./mc/StringsLib.mc ./mc/CastsLib.mc
fi

