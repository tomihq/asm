extern malloc
extern free
extern fprintf

section .data

section .text

global strCmp
global strClone
global strDelete
global strPrint
global strLen

; ** String **

; int32_t strCmp(char* a, char* b)
strCmp:
	ret

; char* strClone(char* a)
strClone:
	ret

; void strDelete(char* a)
strDelete:
	ret

; void strPrint(char* a, FILE* pFile)
strPrint:
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


