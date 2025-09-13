extern strcpy
extern malloc
extern free

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

ITEM_OFFSET_NOMBRE EQU 0
ITEM_OFFSET_ID EQU 12
ITEM_OFFSET_CANTIDAD EQU 16

POINTER_SIZE EQU 4
UINT32_SIZE EQU 8

; Marcar el ejercicio como hecho (`true`) o pendiente (`false`).

global EJERCICIO_1_HECHO
EJERCICIO_1_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_2_HECHO
EJERCICIO_2_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_3_HECHO
EJERCICIO_3_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global EJERCICIO_4_HECHO
EJERCICIO_4_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

global ejercicio1
ejercicio1:
	xor rax, rax
	add rdi, rsi
	add rdi, rdx
    add rdi, rcx
    add rdi, r8
	mov rax, rdi
	ret

global ejercicio2
; item_t* un_item -> RDI
; uint32_t id -> ESI
; uint32_t cantidad -> EDX
; char* nombre -> RCX
ejercicio2:
	push rbp
	mov rbp, rsp 
	push r12
	sub rsp, 8
	
	mov r12, rdi
	mov [r12+ITEM_OFFSET_ID], esi; id
	mov [r12+ITEM_OFFSET_CANTIDAD], edx ;cantidad
	lea rdi, [r12 + ITEM_OFFSET_NOMBRE] ;almaceno en rdi la dirección de memoria donde está el item que le tengo que poner el nombre (destino)
	mov rsi, rcx ;preparo el segundo parámetro source (quiero copiar nombre en el struct) -> (source)
	call strcpy ; primer param por RDI, segundo por RSI. devuelve resultado por RAX.
	
	xor rax, rax 
	mov rax, r12
	add rsp, 8

	pop r12
	pop rbp
	ret


global ejercicio3
; uint32_t* arr -> RDI
; uint32_t size -> RSI
; uint32_t (*fun_ej_3)(uint32_t a, uint32_t b) -> RDX
; esto último tiene un puntero, es decir, si lo desreferencio 
; le tengo que mandar los dos parámetros, al llamarla
; me da el resultado por EAX. 
; IDEA: Blanqueo rax antes de todo. 
; 1. si cmp rsi, 0 salto a devolver 64.
; 2. si cmp rsi, 1 ent, le cargo los parámetros (0, arr[0]) y hago call funcion
; 3. si cmp rsi NO es 1, ent hago llamada recursiva disminuyendo 1 y loopeo
ejercicio3:
	xor rax, rax
	cmp rsi, 0
	je .vacio
	
	mov rcx, rdi ; array
	mov r8, 0 ; sumatoria
	mov r9, 0 ; i

	.loop:
	cmp rsi, 1
	je .uno
	mov rdi, r8
	mov rsi, [rcx + r9*4] ;almacena en rsi el elemento en el indice r9*4 en el array.

	call rdx

	add r8d, eax
	mov eax, r8d

	inc r9
	cmp r9, rsi
	je .end

	jmp .loop

	.vacio:
	mov eax, 64

	.uno 
		mov rdi, 0
		mov rsi, [rcx]
		call rdx 
		jmp .end 
	.end:
	ret

global ejercicio4
;IDEA: Tengo que devolver un puntero a un nuevo array, del mismo largo que el array original de uint32_t** pero con los elementos multiplicados por la constante C: 
; 1. necesito hacer un malloc usando size. Eso me da un puntero a una estructura que va a tener el mismo tamaño que size en otro lugar.
; 2. tomo el elemento que esta en el array, lo almaceno en un registro, lo multiplico por c y lo almaceno en mi nuevo array. 
; 3. Elimino el puntero a ese elemento en el array viejo usando free. 
; 4. Seteo el valor de esa posición a NULL.

ejercicio4:
	mov r12, rdi
	mov r13, rsi
	mov r14, rdx

	xor rdi, rdi
	mov eax, UINT32_SIZE
	mul esi
	mov edi, eax

	call malloc
	mov r15, rax
	
	xor rbx, rbx
	.loop:
	
	cmp rbx, r13
	je .end

	mov r8, [r12+rbx*POINTER_SIZE]
	mov r9d, [r8]
	mov rax, r14
	mul r9d
	mov [r15+rbx*UINT32_SIZE], eax
	
	mov rsi, r8 
	call free

	inc rbx
	jmp .loop

	.end:
	mov rax, r15
	ret
