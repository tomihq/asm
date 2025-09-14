extern malloc

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - optimizar
global EJERCICIO_2A_HECHO
EJERCICIO_2A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - contarCombustibleAsignado
global EJERCICIO_2B_HECHO
EJERCICIO_2B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ATTACKUNIT_CLASE EQU 0
ATTACKUNIT_COMBUSTIBLE EQU 12
ATTACKUNIT_REFERENCES EQU 14
ATTACKUNIT_SIZE EQU 16

MAPA_SIZE EQU 65025

global optimizar
; mapa_t mapa -> RDI
; attackunit_t* compartida -> RSI
; uint32_t (*fun_hash)(attackunit_t*) -> RDX
; Voy a hacer un call a fun hash asi que preservo los datos.
; La respuesta es void así que no necesito garantizar nada. 
optimizar:
	push rbp
	push r12 ;mapa
	push r13 ;attack_unit compartida
	push r14 ;funcion hash
	push r15; lo uso de contador para la matriz
	push rbx; lo uso para almacenar el resultado de fun_hash(compartida)


	;blanqueos. solo los que no son de 64 bits y los voy a pisar.
	xor r15, r15 

	;preservo registros
	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	.ciclo:
		cmp r15, MAPA_SIZE
		jae .fin
		mov r8, [r12 + r15 * 8]

		; caso null
		cmp r8, 0 ;si es null hago continue
		je .incloop

		; caso unit_mapa == compartida
		cmp r8, r13 ;si unit_mapa == compartida hago continue
		je .incloop

		;muevo compartida a rdi para parametro de fun_hash
		mov rdi, r13
		
		;alineo stack y llamo a fun_hash(compartida)
		push r8
		call r14 ;obtengo resultado en rax
		pop r8 ;obtengo r8 de vuelta
		
		; muevo el resultado de fun_hash(compartida)
		mov rbx, rax

		;preparo fun_hash(unit_mapa)
		mov rdi, r8
		
		push r8; preservo unit_mapa
		call r14 ;obtengo el resultado en rax
		pop r8; obtengo unit_mapa
		
		; si fun_hash(compartida) == fun_hash(unit_mapa)
		cmp rax, rbx
		jne .incloop

		;mapa[i][j] = compartida
		mov [r12 + r15 * 8], r13 ;muevo a mapa[i][j] el puntero a compartida.
		; compartida -> references += 1
		inc BYTE [r13 + ATTACKUNIT_REFERENCES]

		.incloop:
			inc r15
			jmp .ciclo

	.fin: 
		pop rbx
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
	ret

global contarCombustibleAsignado
contarCombustibleAsignado:
	; r/m64 = mapa_t           mapa
	; r/m64 = uint16_t*        fun_combustible(char*)
	ret

global modificarUnidad
modificarUnidad:
	; r/m64 = mapa_t           mapa
	; r/m8  = uint8_t          x
	; r/m8  = uint8_t          y
	; r/m64 = void*            fun_modificar(attackunit_t*)
	ret
