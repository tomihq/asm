; AlternateSum.asm
global alternate_sum_4_using_c
extern sumar_c
extern restar_c
; Entrada: x1=x2=x3=x4 en registros (EDI, ESI, EDX, ECX). Como me llaman desde C, los registros volátiles que tengo que preservar son RDI y RSI
; Salida: EAX = resultado final
; Siempre que llego estoy desalineado porque me alineo a 16 antes de saltar. Tons despues de saltar estoy a 8.
section .text

alternate_sum_4_using_c:
    push rbp ;aca me alinee a 16 de vuelta.
    mov rbp, rsp; seteo el base pointer
    push rdi
    push rsi 

    pop rsi
    pop rdi
    pop rbp 
    ret