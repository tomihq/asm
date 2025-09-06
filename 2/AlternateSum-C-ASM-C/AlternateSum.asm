; AlternateSum.asm
global alternate_sum_4_using_c
extern sumar_c
extern restar_c
; Entrada: x1=x2=x3=x4 en registros (EDI, ESI, EDX, ECX).
; Salida: EAX = resultado final
; Siempre que llego estoy desalineado porque me alineo a 16 antes de saltar. Tons despues de saltar estoy a 8.
section .text

alternate_sum_4_using_c:
    ;prologo
    ;aca estoy en (+8)
    push rbp ;aca me alinee a 16 de vuelta (+16).
    mov rbp, rsp; seteo el base pointer
    push r12 ;voy a usar este no-volatil para almacenar EDI. (+24)
    push r13 ;voy a usar este no-volatil para almacenar ESI. (+32)

    mov r12d, edx; preservo edx para no perderlo, voy usar una copia xq edx es volatil
    mov r13d, ecx; preservo ecx para no perderlo, voy a usar una copia xq ecx es volatil
    call sumar_c; recibe los parametros por EDI y ESI. (ya vinieron preparados)

    mov edi, eax; pongo como primer param el resultado de la funcion anterior (acum)
    mov esi, r12d; pongo como segundo param el tercer parámetro que me mandaron, pero utilizo su copia r12 porque edx es no-volátil. 
    call restar_c

    mov edi, eax; pongo como primer para el resultado de la funcion anterior (acum)
    mov esi, r13d; pongo como segundo param el cuarto parámetro que me mandaron, pero utilizo su copia r13 porque ecx es no-volátil.
    call sumar_c

    ;epilogo
    
    pop r13 ;remuevo r13 de la pila (+24)
    pop r12 ;remuevo r12 de la pila (+16)
    pop rbp ;restablezco (+8)
    ret ;(+0)

