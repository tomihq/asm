; AlternateSum.asm
global alternate_sum_4_using_c
extern sumar_c
extern restar_c
; Entrada: x1=x2=x3=x4 en registros (EDI, ESI, EDX, ECX)
; Salida: EAX = resultado final
section .text

alternate_sum_4_using_c:
    ret