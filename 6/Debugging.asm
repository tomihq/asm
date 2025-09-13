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
ejercicio3:
	cmp rsi, 0
	je .vacio
	
	mov rcx, rdi ; array
	mov r8, 0 ; sumatoria
	mov r9, 0 ; i

	.loop:
	mov rdi, r8
	mov rsi, [rcx + r9*4]

	call rdx

	add r8, rax
	mov rax, r8

	inc r9
	cmp r9, rsi
	je .end

	jmp .loop

	.vacio:
	mov rax, 64

	.end:
	ret

global ejercicio4
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
