; Definiciones comunes
TRUE  EQU 1
FALSE EQU 0

; Identificador del jugador rojo
JUGADOR_ROJO EQU 1
; Identificador del jugador azul
JUGADOR_AZUL EQU 2

; Ancho y alto del tablero de juego
tablero.ANCHO EQU 10
tablero.ALTO  EQU 5

; Marca un OFFSET o SIZE como no completado
; Esto no lo chequea el ABI enforcer, sirve para saber a simple vista qué cosas
; quedaron sin completar :)
NO_COMPLETADO EQU -1

extern strcmp

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
carta.en_juego EQU 0
carta.nombre   EQU 1
carta.vida     EQU 14
carta.jugador  EQU 16 
carta.SIZE     EQU 18

tablero.mano_jugador_rojo EQU 0 
tablero.mano_jugador_azul EQU 8
tablero.campo             EQU 16
tablero.SIZE              EQU 416

accion.invocar   EQU 0
accion.destino   EQU 8 
accion.siguiente EQU 16
accion.SIZE      EQU 24

; Variables globales de sólo lectura
section .rodata

; Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - hay_accion_que_toque
global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE

; Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - invocar_acciones
global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE

; Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contar_cartas
global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db TRUE

section .text

; Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
; nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
; parámetro.
;
; El resultado es un valor booleano, la representación de los booleanos de C es
; la siguiente:
;   - El valor `0` es `false`
;   - Cualquier otro valor es `true`
;
; ```c
; bool hay_accion_que_toque(accion_t* accion, char* nombre);
; ```
global hay_accion_que_toque
; accion_t*  -> RDI 
; char* nombre -> RSI 
; el resultado lo devuelvo por RAX. 
hay_accion_que_toque:
	push rbp 
	mov rbp, rsp
	xor rax, rax
	push r12 ;accion_t* accion
	push r13 ;char* nombre

	;;; muevo registros
	mov r12, rdi
	mov r13, rsi

	.ciclo:
		;accion == NULL 
		cmp r12, 0
		je .fin 

		mov r8, [r12 + accion.destino]  ;guardo accion -> destino en r8. Necesito el struct
		lea rdi, [r8 + carta.nombre] ; carta -> nombre. Como es un array de chars necesito la direccion en donde empieza
		mov rsi, r13 ; char* nombre

		call strcmp ;almacena en rax si es 0 o 1. Es un byte
		cmp al, 0
		je .true
		mov r12, [r12 + accion.siguiente]
		mov al, FALSE
		jmp .ciclo
	.true: 
		mov al, TRUE
	.fin:
		pop r13
		pop r12
		pop rbp
		ret

; Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
; primer parámetro.
;
; A la hora de procesar una acción esta sólo se invoca si la carta destino
; sigue en juego.
;
; Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
; se debe marcar ésta como fuera de juego.
;
; Las funciones que implementan acciones de juego tienen la siguiente firma:
; ```c
; void mi_accion(tablero_t* tablero, carta_t* carta);
; ```
; - El tablero a utilizar es el pasado como parámetro
; - La carta a utilizar es la carta destino de la acción (`accion->destino`)
;
; Las acciones se deben invocar en el orden natural de la secuencia (primero la
; primera acción, segundo la segunda acción, etc). Las acciones asumen este
; orden de ejecución.
;
; ```c
; void invocar_acciones(accion_t* accion, tablero_t* tablero);
; ```
global invocar_acciones
; accion_t* accion -> RDI
; tablero_t* tablero -> RSI
; no hay rta.
; IDEA: como necesito llamar a invocar, necesito guardar varias cosas durante los llamados, accion, tablero, carta por lo cual necesito tres registros no-volatiles. El resto uso volatiles porque no me interesan mucho.
invocar_acciones:
	push rbp
	push r12 ;accion
	push r13 ; tabler
	push r14 ;desalineado

	mov r12, rdi ; accion
	mov r13, rsi ; tablero

	.loop: 
		cmp r12, 0 
		je .end 

		mov r14, [r12 + accion.destino] ;struct carta
		cmp BYTE[r14 + carta.en_juego], FALSE ;si es false me muevo y me voy
		je .nextAction
		; agarro la funcion de invocar (la direccion de memoria)
		xor r8, r8
	
	.saveFn:
		mov r8, [r12 + accion.invocar] ; ya tengo la funcion invocar
		mov rdi, r13
		mov rsi, r14

	.call: 
		; llamo a invocar
		sub rsp, 8
		call r8
		add rsp, 8
	
	.checkHealthZero:
		cmp WORD[r14 + carta.vida], 0
		jne .nextAction
		mov BYTE[r14 + carta.en_juego], FALSE


	.nextAction:
		mov r12, [r12 + accion.siguiente]
		jmp .loop
	.end: 
		pop r14
		pop r13
		pop r12
		pop rbp
		ret

; Cuenta la cantidad de cartas rojas y azules en el tablero.
;
; Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
; correspondientes al jugador rojo y al jugador azul. Este conteo incluye tanto
; a las cartas en juego cómo a las fuera de juego (siempre que estén visibles
; en el campo).
;
; Se debe considerar el caso de que el campo contenga cartas que no pertenecenmov
; a ninguno de los dos jugadores.
;
; Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
; una carta.
;
; El resultado debe ser escrito en las posiciones de memoria proporcionadas
; como parámetro.
;
; ```c
; void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules);
; ```
global contar_cartas
; tablero_t* tablero -> RDI
; uint32_t* cant_rojas -> RSI
; uint32_t* cant_azules -> RDX
; IDEA: no necesito ni siquiera usar registros no-volatiles porque no tengo calls. 
; sin embargo, necesito varios registros (ademas de los 3 de parametros), necesito 2 para acumular, 1 para referir a carta.
; necesito un indice para moverme desde 0 a 50. Para acceder a la matriz puedo usar un solo indice. 
contar_cartas:
	push rbp
	mov rbp, rsp

	;limpio 
	xor r8, r8 ; tablero -> campo
	xor r9, r9 ; campo[i][j]
	xor r10, r10 ;carta_t* carta
	xor r11, r11 ;acumulador de indices
	mov DWORD[rsi], 0
	mov DWORD[rdx], 0

	.loop:
		cmp r11, 50 ;tiene 50 posiciones
		je .end
		;(x + desplazamiento + y) * tamañoElems del array
		lea r8, [rdi + tablero.campo] ; tablero -> campo
		mov r9, [r8 + r11 * 8] ; muevo i, j para el tablero

		cmp r9, BYTE 0
		je .inc

		cmp BYTE[r9 + carta.jugador], 1
		je .inc_first_player
		cmp BYTE[r9 + carta.jugador], 2
		je .inc_second_player
		jmp .inc
	.inc_first_player:
		INC DWORD [rsi]
		jmp .inc
	.inc_second_player:
		INC DWORD [rdx]
		jmp .inc
	.inc:
		inc r11
		jmp .loop
	.end: 
		pop rbp
		ret
