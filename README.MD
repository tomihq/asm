# ASM 
Do not include the []! I'm using them to make it easier to read.

## Ensamblado
nasm -f elf64 -g -F DWARF [file].asm

## Link
ld -o [file] [file].o

## Execute
./[file]

## Si te da error de Python aun teniendo las librerías
Borrá la carpeta de venv de test_utils y volvé a hacer make.