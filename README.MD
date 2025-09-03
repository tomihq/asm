# ASM 
Do not include the []! I'm using them to make it easier to read.

## Ensamblado
nasm -f elf64 -g -F DWARF [file].asm

## Link
ld -o [file] [file].o

## Execute
./[file]