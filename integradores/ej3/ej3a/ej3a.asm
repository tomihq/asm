extern malloc 
extern memset 
extern memcpy
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

NULL EQU 0

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
/*
segmentar_casos:
    push rbp 
    mov rbp, rsp 
    ; preservo no volatiles
    push r12
    push r13
    push r14
    push r15

    ; preservo arreglo_casos y largo 
    mov r12, rdi 
    mov r13d, esi 

    ; lo uso para preservar el array de cantidades por nivel. 
    xor r14, r14 

    ; createLevelCounterArr: 
        ; aca obtengo contadores[3]
        ; necesito crear un array de longitud 3 inicializado en 0 con numeros que van a ser enteros sin signo. Voy a usar malloc y memset. Va a ocupar 4 bytes por numero y 3 estados (12).
        mov rdi, 12
        call malloc ;tengo en rax el puntero a ese arreglo.
    
    ; initializeLevelCounterArr: 
        ; aca tengo el int contadores[3] = {0, 0, 0}
        mov rdi, rax 
        mov rsi, 12
        mov rdx, 0
        call memset
        mov r14, rax ; almaceno en r14 el puntero a los contadores
    
    ; fillLevelCounterArr: 
        ; aca preparo para llamar contar_casos_por_nivel
        mov rdi, r12
        mov rsi, r13
        mov rdx, r14 ;esto lo mando por referencia por puntero
        call contar_casos_por_nivel         ;me modifica directamente mi puntero. osea que r14 deberia haber cambiado.
    
    ; assignSegmentationTPointer:
        ;malloc para struct gral de rta. Despues de hacer cada malloc para cada struct puedo usar r14 de vuelta y pisarlo.
        mov rdi, SEGMENTACION_SIZE
        call malloc 
        mov r15, rax; en r15 está el struct con los 3 punteros
    ; initializePointersOnSegmentationTPointer
        mov QWORD [r15 + SEGMENTACION_CASOS0_OFFSET], NULL
        mov QWORD [r15 + SEGMENTACION_CASOS1_OFFSET], NULL 
        mov QWORD [r15 + SEGMENTACION_CASOS2_OFFSET], NULL
    
    .saveSpaceForArrPointers:
        cmp DWORD [r14], 0 ;;si el estado 0 tiene 0 no hago nada.
        je .assignFirstLevelArrMem 
        xor r8, r8 ; lo uso para indice 
        mov r8, [r14] ;almaceno la cantidad de structs que tiene el lvl 0
        imul r8, CASO_SIZE; obtengo la cantidad de bytes que necesito para el array de structs
        mov rdi, r8 
        call malloc; obtengo en rax el puntero al lvl 0 
        mov [r15 + SEGMENTACION_CASOS0_OFFSET], rax 

    .assignFirstLevelArrMem:
        cmp DWORD [r14 + 4], 0 ;;si el estado 1 tiene 0 no hago nada
        je .assignSecondLevelArrMem
        xor r8, r8 ; lo uso para indice 
        mov r8, [r14 + 4] ;almaceno la cantidad de structs que tiene el lvl 1
        imul r8, CASO_SIZE; obtengo la cantidad de bytes que necesito para el array de structs
        mov rdi, r8 
        call malloc; obtengo en rax el puntero al lvl 1
        mov [r15 + SEGMENTACION_CASOS1_OFFSET], rax 

    .assignSecondLevelArrMem: 
        cmp DWORD [r14 + 8], 0;; si el estado 2 tiene 0 no hago nada
        je .fillSegmentationPointerCases
        mov r8, [r14 + 8] ;almaceno la cantidad de structs que tiene el lvl 2
        imul r8, CASO_SIZE; obtengo la cantidad de bytes que necesito para el array de structs
        mov rdi, r8 
        call malloc; obtengo en rax el puntero al lvl 2
        mov [r15 + SEGMENTACION_CASOS2_OFFSET], rax 
        
    .fillSegmentationPointerCases: 
        xor r8, r8; indice para barrer el largo
        ; r12 arreglo casos
        ; r13 largo
        ; r15 struct con los 3 punteros
        xor r14, r14; nivelActual
        xor rdi, rdi; indice para cantidad de casos en nivel 0
        xor rcx, rcx; indice para cantidad de casos en nivel 1
        xor rdx, rdx; indice para cantidad de casos en nivel 2 
        xor r9, r9; lo uso para calcular datos intermedios
        xor r10, r10; lo uso para calcular indice del struct
    
    .fillSegmentationPointerCasesLoop:
        cmp r8, r13 
        je .end 
        mov r10, r8
        imul r10, CASO_SIZE
        lea r9, [r12 + r10] ;struct actual = &arreglo_casos[i]. Es obligatorio que me traiga el puntero porque el struct pesa MAS que 64 bits. NO me lo puedo traer entero.
        mov r10, [r9 + CASO_USUARIO_OFFSET] ;usuario actual (usuario_t)
        mov r14, [r10 + USUARIO_NIVEL_OFFSET] ;nivel caso actual 
        cmp r14, 0
        je .fillSegmentationPointerCaseLoopZero
        cmp r14, 1
        je .fillSegmentationPointerCaseLoopOne
        cmp r14, 2
        je .fillSegmentationPointerCaseLoopTwo
        jmp .incCycle
    .fillSegmentationPointerCaseLoopZero:
        mov r10, [r15 + SEGMENTACION_CASOS0_OFFSET] ; puntero al array nivel 0
        cmp r10, 0
        je .incCycle
        imul rsi, rdi, CASO_SIZE                     ; offset dentro del array
        ;preparo memcpy
        push rdi 
        push rdx 
        lea rdi, [r10 + rsi]                         ; destino = &array[i0]
        mov rsi, r9                                   ; origen = &arreglo_casos[i]
        mov rdx, CASO_SIZE                            ; tamaño 16 bytes
        call memcpy
        pop rdx 
        pop rdi
        inc rdi                                    ; incrementar contador de nivel 0
        jmp .incCycle
    .fillSegmentationPointerCaseLoopOne:
        xor r10, r10
        xor r14, r14
        mov r10, [r15 + SEGMENTACION_CASOS1_OFFSET] ; array nivel 1 de structs
        cmp r10, 0
        je .incCycle
        imul rsi, CASO_SIZE
        lea rdi, [r10 + rsi]                         ; destino = &array[i0]
        mov rsi, r9                                   ; origen = &arreglo_casos[i]
        mov rdx, CASO_SIZE 
        call memcpy   
        inc rsi
        jmp .incCycle

    .fillSegmentationPointerCaseLoopTwo:
        xor r10, r10
        xor r14, r14
        mov r10, [r15 + SEGMENTACION_CASOS2_OFFSET] ; array nivel 2 de structs
        cmp r10, 0
        je .incCycle
        mov rsi, rdx
        imul rsi, CASO_SIZE
        lea rdi, [r10 + rsi]                         ; destino = &array[i0]
        mov rsi, r9                                   ; origen = &arreglo_casos[i]
        mov rdx, CASO_SIZE
        call memcpy
        inc rcx
        jmp .incCycle

    .incCycle:
        inc r8
        jmp .fillSegmentationPointerCasesLoop
    .end: 
        mov rax, r15
        pop r15
        pop r14
        pop r13
        pop r12
        pop rbp 
        ret
*/


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

