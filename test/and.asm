%define SYS_WRITE 1    
%define SYS_EXIT 60     
%define STDOUT 1        

section .data         
msg: db '¡Hola Mundo!', 10   
len equ $ - msg             

global _start           
section .text           
_start:         
    push rbp
    mov rbp, rsp
    mov rdi, 0xffffffff1fffffff     
    OR rdi, 0xffffffffffffffff                                           
    AND edi, 0xffffffff
    pop rbp