extern malloc 
extern memset 
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

; Completar las definiciones (serán revisadas por ABI enforcer):
USUARIO_ID_OFFSET EQU 0 ;[0, 4) 
USUARIO_NIVEL_OFFSET EQU 4;[4, 8)
USUARIO_SIZE EQU 8

CASO_CATEGORIA_OFFSET EQU 0 ;[0, 4)
CASO_ESTADO_OFFSET EQU 4 ;[4, 7)
CASO_USUARIO_OFFSET EQU 8 ;padding 1 xq 7 no es multiplo de 8. [8, 16)
CASO_SIZE EQU 16

SEGMENTACION_CASOS0_OFFSET EQU 0 ; [0, 8)
SEGMENTACION_CASOS1_OFFSET EQU 8 ;[8, 16)
SEGMENTACION_CASOS2_OFFSET EQU 16 ;[16, 24)
SEGMENTACION_SIZE EQU 24

ESTADISTICAS_CLT_OFFSET EQU 0
ESTADISTICAS_RBO_OFFSET EQU 1
ESTADISTICAS_KSC_OFFSET EQU 2
ESTADISTICAS_KDT_OFFSET EQU 3
ESTADISTICAS_ESTADO0_OFFSET EQU 4
ESTADISTICAS_ESTADO1_OFFSET EQU 5
ESTADISTICAS_ESTADO2_OFFSET EQU 6
ESTADISTICAS_SIZE EQU 7

;segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo)
global segmentar_casos
segmentar_casos:
    push rbp 
    mov rbp, rsp 

    ; preservo no volatiles
    push r12
    push r13
    push r14
    
    ; preservo arreglo_casos y largo 
    mov r12, rdi 
    mov r13, rsi 

    ;limpio r14 
    xor r14, r14 

    ; aca obtengo contadores[3]
    ; necesito crear un array de longitud 3 inicializado en 0 con numeros que van a ser enteros sin signo. Voy a usar malloc y memset. Va a ocupar 4 bytes por numero y 3 estados (12).
    mov rdi, 12
    sub rsp, 8
    call malloc ;tengo en rax el puntero a ese arreglo.
    add rsp, 8
    
    ; aca tengo el int contadores[3] = {0, 0, 0}
    mov rdi, rax 
    mov rsi, 12
    mov rdx, 0
    sub rsp, 8
    call memset
    add rsp, 8
    mov r14, rax ; almaceno en r14 el puntero a los contadores

    ; aca preparo para llamar contar_casos_por_nivel
    mov rdi, r12
    mov rsi, r13
    mov rdx, r14 ;esto lo mando por referencia por puntero
    sub rsp, 8
    call contar_casos_por_nivel
    add rsp, 8

    ;me modifica directamente mi puntero. osea que r14 deberia haber cambiado

    pop r14
    pop r13
    pop r12
    pop rbp 
    ret


; caso_t* arreglo_casos - RDI
; int largo - RSI - USO ESI por tamaño (sino trae basura)
; int* contadores - RDX
; registros que necesito usar: RDI, RSI, RDX son volatiles asi que los puedo romper como quiera.
; necesito un indice para iterar en el ciclo.
; necesito un registro para acceder al arreglo_casos.
; necesito después obtener el usuario de ese arreglo_casos.
; necesito después el nivel.
; despues hago INC DWORD[contador + offset]
contar_casos_por_nivel:
    push rbp 
    mov rbp, rsp
    
    xor r8, r8; indice
    xor r9, r9; 
    xor r10, r10;

    .loop: 
        cmp r8d, esi 
        je .end

        ; como me muevo en array tengo que hacer INDICE * tamaño objeto que hay adentro.
        mov rax, r8
        imul rax, CASO_SIZE
        
        mov r9, [rdi + rax + CASO_USUARIO_OFFSET] ;obtengo el struct del usuario.
        mov r10d, DWORD[r9 + USUARIO_NIVEL_OFFSET] ; obtengo el nivel
        cmp r10d, 2
        jge .inc ; si es mayor o igual a dos salto.
        ;; como cada contador es un entero de 4 bytes me desplazo esa cantidad
        inc DWORD[rdx + (r10 * 4)]
        jmp .inc

    .inc: 
        add r8, 1
        jmp .loop

    .end: 
        pop rbp 
        ret 

