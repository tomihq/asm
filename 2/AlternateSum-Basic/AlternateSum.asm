section .text
global _start 

_start:
    mov edi, 1
    mov esi, 2
    mov edx, 3
    mov ecx, 4

    call alternate_sum4
    mov ebx, eax
    mov eax, 1     ; syscall exit
    int 0x80       ; llamada al kernel

; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
; EDI + ESI - EDX + ECX o EDI - ESI + EDX - ECX (depende como lo veas, a mi me gusta más la primera)
; Para la suma nos va a servir ADD r32, r/m32 - Add r/m32 to r32. La m significa que puede ser un operando sacado de memoria o un registro. 
; Para la resta nos va a servir SUB r32, r/m32 - Subtract r/m32 from r32
alternate_sum4: 
    add edi, esi ;(x1+x2)
    sub edi, edx ;(acum-x3)
    add edi, ecx ;(acum+x4)
    mov eax, edi ;eax almacena el resultado
    ret