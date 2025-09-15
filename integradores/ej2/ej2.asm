extern malloc
extern free

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
EJERCICIO_2B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1C como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - modificarUnidad
global EJERCICIO_2C_HECHO
EJERCICIO_2C_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

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
		mov r8, [r12 + r15 * 8] ; mapa[i][j]

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

		;decremento las references de unit_mapa
		dec BYTE [r8 + ATTACKUNIT_REFERENCES]
		mov al, BYTE[r8 + ATTACKUNIT_REFERENCES]

		;si no hay mas referencias a esa referencia, lo borrás de memoria
		cmp al, 0
		jne .incloop

		sub rsp, 8
		mov rdi, r8
		call free
		add rsp, 8


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
; mapa_t mapa -> RDI 
; uint16_t (*fun_combustible)(char) -> RSI
; IDEA: Como voy a llamar a fun_combustible necesito si o si guardarme el mapa y la función, así que voy a usar dos registros no volátiles, por lo cual, los preservo antes de usarlos.
; Necesito un contador que preserve su valor, otro registro no volatil.
; RTA por EAX
contarCombustibleAsignado:
	push rbp ;alineado
	push r12 ;desalineado
	push r13 ;alineado
	push r14 ;desalineado
	push r15 ;alineado. mapa 
	push rbx ;desalineado 

	mov r12, rdi ;preservo mapa. no blanqueo porque piso 64 
	mov r13, rsi ;preservo fun. no blanqueo porque piso 64 
	
	;blanqueo xq no voy a usar 64.
	xor r14, r14 ; contador
	xor r15, r15
	xor rax, rax ; rta
	xor rbx, rbx ;acum combustible

	.loop: 
		cmp r14, MAPA_SIZE
		jae .fin
		mov r15, [r12 + r14 * 8] ;me muevo en el mapa. obtengo el struct.
		
		cmp r15, 0; si es null hago continue
		je .incloop

		lea r8, [r15]; obtengo la ref a item -> clase
		mov rdi, r8; preparo el parametro de item -> clase para fun_combustible
		
		;preparo llamada
		sub rsp, 8
		call r13 ; la respuesta viene en rax. Es un entero de 32 bits. 
		add rsp, 8

		mov r9w, WORD[r15 + ATTACKUNIT_COMBUSTIBLE] ;obtengo combustible de la clase.
		sub r9w, ax; combustibleMapa - combustibleClase
		add bx, r9w; almaceno en 32 bits la suma de los numeros de 16. 
	.incloop:
		inc r14 
		jmp .loop

	.fin: 
		mov eax, ebx 
		pop rbx
		pop r15
		pop r14 
		pop r13
		pop r12
		pop rbp
		ret

global modificarUnidad
; como voy a llamar a strcpy, malloc y fun modificar necesito preservar todos los registros.
; mapa_t mapa -> RDI
; uint8_t x -> RSI
; uint8_t y -> RDX
; void fun_modificar(attackunit_t*) -> RCX

; necesito preservar mapa[x][y] (item) en los llamados así que necesito un registro no-volatil. Lo guardo antes.
; necesito preservar item2 en los llamados así que necesito otro registro no-volatil. lo guardo antes.
; no me alcanzan los registros no-volatiles asi que tengo que usar el stack.  
modificarUnidad:
	push rbp ; alineado
	mov rbp, rsp 
	push r12 ; desalineado
	push r13 ; alineado
	push r14 ; desalineado
	push r15 ; alineado
	push rbx ; desalineado

	;preservo volátiles
	mov r12, rdi ; mapa
	mov r13, rcx ; fun_modificar

	;blanqueo registros grandes para no ensuciar los 8 bits
	movzx r14, si ;x
	movzx r15, dx ;y  PUEDO usar r15 en otro lado. Ya no me hace falta.

	;desplazamiento en memoria para matriz
	add r14, r15; x+y
	
	mov rbx, [r12 + r14 * 8]; obtengo mapa[x][y]
	cmp rbx, 0
	je .fin

	
	


	.fin: 

		pop rbx 
		pop r15
		pop r14
		pop r13
		pop r12
		pop rbp
		ret
