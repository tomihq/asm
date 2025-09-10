extern malloc
extern free
extern fprintf

section .data
	null_str db "NULL", 0
    null_len equ $ - null_str
section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
; char* a -> rdi
; char* b -> rsi 
; int32_t -> eax
; idea: tengo que comparar en orden lexicografico. como el char en realidad es un numero me basta con mover ambos punteros a la vez y comparar letra a letra.
strCmp:
	push rbp
	mov rbp, rsp
	mov r8, rdi ;char 1
	mov r9, rsi ;char 2
	xor eax, eax 
	.loop_chars:
		mov r10b, BYTE[r8]
		mov r11b, BYTE[r9]

		; caso base
		; si el char a = '\0' me fijo si b también está vacío, si sucede son iguales.
		; si el char a = '\0' y b no es vacío entonces a < b
		cmp r10b, 0
		je .check_ends

		;como a no está vacío, me fijo si b está vacío. Si es vacio, entonces a > b.
		cmp r11b, 0
		je .higher
		; fin caso base

		; comparo el caracter de a con el de b. si a>b entonces -1. si a<b entonces 1.
		cmp r10b, r11b 
		jl .smaller ;si a < b entonces devuelvo 1.
		jg .higher ;si a > b entonces devuelvo -1.

		;si son iguales, incremento los punteros.

		add r8, 1 ;paso al siguiente char de a
		add r9, 1 ;paso al siguiente char de b
		jmp .loop_chars
	.smaller: 
		mov eax, 1
		jmp .return
	.higher:
		mov eax, -1
		jmp .return
		
	.check_ends
		cmp r11b, 0 ;a y b terminaron en el mismo lugar (son el mismo string)
		je .equals ; salto si son iguales
		jmp .smaller  ;si a terminó pero b no, entonces a < b.
	.equals
		mov eax, 0
	.return: 
		pop rbp 
		ret

; char* strClone(char* a)
strClone:
	ret

; void strDelete(char* a)
; char* a - RDI 
; preguntar: ¿acá no tengo que preservar el valor de RDI? ¿qué registros son volatiles/no volatiles en 64?
strDelete:
	push rbp
	mov rbp, rsp 
	call free
	pop rbp
	ret

; void strPrint(char* a, FILE* pFile)
; char* a - RDI 
; FILE* pFile - RSI
; escribir el string en pFile.
; si el string es vacio se escribe NULL.
strPrint:
	push rbp
	mov rbp, rsp 

	call strLen ;eax = longitud
	mov rdi, rsi ;preparo el file como primer argumento 
	
	cmp eax, 0
	je .writeNull
	
	;longitud mayor a 0 escribo en el file el string en en vez de NULL.
	xor rax, rax
	mov rsi, rdi
	call fprintf
	jmp .end

	.writeNull:
		xor rax, rax ;fprint es variádico
		lea rsi, [rel null_str] ;puntero al string "NULL" en data.
		call fprintf
	.end: 
		pop rbp
		ret

; uint32_t strLen(char* a)
; Idea: puedo ir moviendo el puntero hacia adelante, si veo que la letra actual es '\0' al desreferenciar el puntero hago un jmp a fin. 
; como el resultado es un uint32_t me basta con devolver el acum en eax. Y como es volátil lo puedo usar de acumulador.
; El parámetro al ser un puntero me lo mandan por los mismos registros que entraría un puntero. En este caso, cada char ocupa 1 byte así que tendría que desreferenciar el valor desde el registro más grande pero tomar solo de memoria la parte del CHAR (BYTE).
; Una vez que haya hecho el ADD eax, 1 tengo que "mover el puntero", para eso puedo hacer aritmética de punteros y sumarle 1 unidad (en este caso 1 byte más) al registro que uso para almacenar el puntero de entrada. 
; char* a - RDI 
; res - EAX
strLen:
	push rbp
	mov rbp, rsp
	mov r8, rdi; ;guardo rdi en r8 para no modificarle su valor. rdi es no-volatil, eso quiere decir que debo devolverlo como viene. 
	xor eax, eax ;inicializo acumulador en 0.

	.ciclo: 
		mov r9b, BYTE [r8] ;tomo el char de r8 y lo almaceno en r9b. Esto falla ¿por qué? gdb me devuelve void cuando printeo r9b como char. Pero si printeo r8 desreferenciando me da bien la 'h'
		;movzx r9, BYTE [r8]
		cmp r9b, 0
		je .fin
		add eax, 1
		add r8, 1 ;me muevo al proximo byte.
		jmp .ciclo 

	.fin
	pop rbp
	ret


