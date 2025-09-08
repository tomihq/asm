extern sumar_c
extern restar_c
;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

;########### LISTA DE FUNCIONES EXPORTADAS

global alternate_sum_4
global alternate_sum_4_using_c
global alternate_sum_4_using_c_alternative
global alternate_sum_8
global product_2_f
global product_9_f

;########### DEFINICION DE FUNCIONES
; uint32_t alternate_sum_4(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4:
  sub EDI, ESI
  add EDI, EDX
  sub EDI, ECX

  mov EAX, EDI
  ret

; uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);
; parametros: 
; x1 --> EDI
; x2 --> ESI
; x3 --> EDX
; x4 --> ECX
alternate_sum_4_using_c:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  push R12
  push R13	; preservo no volatiles, al ser 2 la pila queda alineada

  mov R12D, EDX ; guardo los parámetros x3 y x4 ya que están en registros volátiles
  mov R13D, ECX ; y tienen que sobrevivir al llamado a función

  call restar_c 
  ;recibe los parámetros por EDI y ESI, de acuerdo a la convención, y resulta que ya tenemos los valores en esos registros
  
  mov EDI, EAX ;tomamos el resultado del llamado anterior y lo pasamos como primer parámetro
  mov ESI, R12D
  call sumar_c

  mov EDI, EAX
  mov ESI, R13D
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  pop R13 ;restauramos los registros no volátiles
  pop R12
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


alternate_sum_4_using_c_alternative:
  ;prologo
  push RBP ;pila alineada
  mov RBP, RSP ;strack frame armado
  sub RSP, 16 ; muevo el tope de la pila 8 bytes para guardar x4, y 8 bytes para que quede alineada

  mov [RBP-8], RCX ; guardo x4 en la pila

  push RDX  ;preservo x3 en la pila, desalineandola
  sub RSP, 8 ;alineo
  call restar_c 
  add RSP, 8 ;restauro tope
  pop RDX ;recupero x3
  
  mov EDI, EAX
  mov ESI, EDX
  call sumar_c

  mov EDI, EAX
  mov ESI, [RBP - 8] ;leo x4 de la pila
  call restar_c

  ;el resultado final ya está en EAX, así que no hay que hacer más nada

  ;epilogo
  add RSP, 16 ;restauro tope de pila
  pop RBP ;pila desalineada, RBP restaurado, RSP apuntando a la dirección de retorno
  ret


; uint32_t alternate_sum_8(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4, uint32_t x5, uint32_t x6, uint32_t x7, uint32_t x8);
; registros y pila: 
; x1 -> EDI (no volatil)
; x2 -> ESI (no volatil)
; x3 -> EDX (volatil)
; x4 -> ECX (volatil)
; x5 -> R8D (volatil)
; x6 -> R9D (volatil)
; x7 -> [RSP + 8]
; x8 -> [RSP + 16]
alternate_sum_8:
	;prologo
  push rbp
  mov rbp, rsp
  sub rsp, 16 ;reservo 16 bytes, mi param x7 va a 16 y x8 va a 24.
  ; guardar parámetros volátiles
  mov r12d, edx
  mov r13d, ecx 
  mov r14d, r8d
  mov r15d, r9d
  ; guardar x7 y x8 en stack
  mov eax, [rbp+16]   
  mov [rsp], eax
  mov eax, [rbp+24]   
  mov [rsp+4], eax

  ; ya esta EDI/ESI cargados de una.
  call restar_c
  mov edi, eax  ;guardo el resultado de eax como primer argumento
  mov esi, r12d ;paso 3er param como 2do
  call sumar_c
  mov edi, eax 
  mov esi, r13d
  call restar_c
  mov edi, eax
  mov esi, r14d
  call sumar_c
  mov edi, eax
  mov esi, r15d
  call restar_c
  mov edi, eax
  mov esi, [rsp]
  call sumar_c
  mov edi, eax
  mov esi, [rsp+4]
  call restar_c

	;epilogo
  add rsp, 16          ; liberar espacio reservado
  pop rbp
  ret


;void product_2_f(uint32_t* destination, uint32_t x1, float f1);
;registros: 
; destination -> RDI //no volatil
; x1 -> ESI //no volatil 
; f1 -> XMM0 //volatil
; IDEA: El resultado es un uint32_t*, tengo un uint32_t y un float. Lo primero que tengo que hacer para no perder el float es pasar el uint32_t a float. 
; Luego, hago la multiplicacion de dos floats.
; Por último paso los floats a enteros.
; Finalmente, pongo el resultado en la posición de memoria a la que apunta el puntero. 
product_2_f:
  ;prologo
  push rbp
  mov rbp, rsp
  ; empiezo
  ; paso 1: convierto Doubleword Integer a Single Precision Floating-Point Value (int de 32 -> float)
  cvtsi2ss xmm1, esi      
  ; paso 2: multiplico dos Single Precision Floating-Point Values (float * float)
  mulss xmm0, xmm1       
  ; paso 3: convierto Single Precision Floating-Point Value a Doubleword Integer (float -> int de 32)
  cvtss2si eax, xmm0     
  ; paso 4: guardar en *destination
  mov [rdi], eax  
  ;epilogo   
  pop rbp
	ret


;extern void product_9_f(double * destination
;, uint32_t x1, float f1, uint32_t x2, float f2, uint32_t x3, float f3, uint32_t x4, float f4
;, uint32_t x5, float f5, uint32_t x6, float f6, uint32_t x7, float f7, uint32_t x8, float f8
;, uint32_t x9, float f9);
;registros y pila: destination[rdi], x1[?], f1[?], x2[?], f2[?], x3[?], f3[?], x4[?], f4[?]
;	, x5[?], f5[?], x6[?], f6[?], x7[?], f7[?], x8[?], f8[?],
;	, x9[?], f9[?]
product_9_f:
	;prologo
	push rbp
	mov rbp, rsp

	;convertimos los flotantes de cada registro xmm en doubles
	; COMPLETAR

	;multiplicamos los doubles en xmm0 <- xmm0 * xmm1, xmmo * xmm2 , ...
	; COMPLETAR

	; convertimos los enteros en doubles y los multiplicamos por xmm0.
	; COMPLETAR

	; epilogo
	pop rbp
	ret

