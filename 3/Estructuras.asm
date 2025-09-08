

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
NODO_OFFSET_NEXT EQU 0
NODO_OFFSET_CATEGORIA EQU 8
NODO_OFFSET_ARREGLO EQU 16
NODO_OFFSET_LONGITUD EQU 24
NODO_SIZE EQU 32
PACKED_NODO_OFFSET_NEXT EQU 0
PACKED_NODO_OFFSET_CATEGORIA EQU 8
PACKED_NODO_OFFSET_ARREGLO EQU 9
PACKED_NODO_OFFSET_LONGITUD EQU 17
PACKED_NODO_SIZE EQU 21
LISTA_OFFSET_HEAD EQU 0
LISTA_SIZE EQU 8
PACKED_LISTA_OFFSET_HEAD EQU 0
PACKED_LISTA_SIZE EQU 8

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS
global cantidad_total_de_elementos
global cantidad_total_de_elementos_packed

;########### DEFINICION DE FUNCIONES
;extern uint32_t cantidad_total_de_elementos(lista_t* lista);
;registros: 
;lista -> RDI (es un puntero)
;como el resultado es un uint32_t el resultado lo devuelvo por EAX.
;lo primero que tengo que hacer es pararme en la cabeza de la lista. El puntero es un nodo_t* head, lo cual al ser un puntero ocupa 64 bits. Me basta con pararme en 0 y eso me va a traer el next, la categoria, el arreglo que tiene y la longitud. 
; lo unico que uso son registros volátiles. además, no usé call a otro lugar (no tengo que preservar ninguno)
cantidad_total_de_elementos:
	push rbp
	mov rbp, rsp 
	xor eax, eax ; blanqueo eax para usarlo como acumulador y devolver la respuesta
	mov rcx, [rdi] ; accedo al primer nodo de la lista. rbx apunta a {offset 0 en nodo_t}
	
	.ciclo: 
		cmp rcx, 0
		je .fin
		add eax, DWORD[rcx + NODO_OFFSET_LONGITUD] ;hay un nodo en la lista.
		mov rcx, [rcx] ;desreferencio el proximo nodo (offset 0)
		jmp .ciclo
	
	.fin: 
		pop rbp
		ret

;extern uint32_t cantidad_total_de_elementos_packed(packed_lista_t* lista);
;registros:
; lista -> RDI (es un puntero)
; es igual al anterior pero ahora el offset esta packed.
cantidad_total_de_elementos_packed:
	push rbp
	mov rbp, rsp 
	xor eax, eax
	mov rcx, [rdi]

	.ciclo:
		cmp rcx, 0
		je .fin 
		add eax, DWORD[rcx + PACKED_NODO_OFFSET_LONGITUD]
		mov rcx, [rcx]
		jmp .ciclo 
	
	.fin: 
		pop rbp 
		ret

