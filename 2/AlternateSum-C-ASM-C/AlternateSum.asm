; AlternateSum.asm
global alternate_sum_4_using_c
extern sumar_c
extern restar_c
; Entrada: x1=x2=x3=x4 en registros (EDI, ESI, EDX, ECX). Como me llaman desde C, los registros volátiles que tengo que preservar son RDI y RSI
; Salida: EAX = resultado final
; Siempre que llego estoy desalineado porque me alineo a 16 antes de saltar. Tons despues de saltar estoy a 8.
section .text

alternate_sum_4_using_c:
    ;prologo
    push rbp ;aca me alinee a 16 de vuelta.
    mov rbp, rsp; seteo el base pointer
    push r12 ;voy a usar este no-volatil para almacenar EDI. +16
    push r13 ;voy a usar este no-volatil para almacenar ESI. +24

    mov r12d, edx; preservo edx para no perderlo (es no-volatil)
    mov r13d, ecx; preservo ecx para no perderlo (es no-volatil)
    call sumar_c; recibe los parametros por EDI y ESI.

    mov edi, eax
    mov esi, r12d
    call restar_c

    mov edi, eax
    mov esi, r13d
    call sumar_c

    ;epilogo
    
    pop r13
    pop r12
    pop rbp 
    ret

