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
;   - es_indice_ordenado
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - indice_a_inventario
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db FALSE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
ITEM_NOMBRE EQU 0
ITEM_FUERZA EQU 20
ITEM_DURABILIDAD EQU 24
ITEM_SIZE EQU 28

;; La funcion debe verificar si una vista del inventario está correctamente 
;; ordenada de acuerdo a un criterio (comparador)

;; bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador);

;; Dónde:
;; - `inventario`: Un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice`: El arreglo de índices en el inventario que representa la vista.
;; - `tamanio`: El tamaño del inventario (y de la vista).
;; - `comparador`: La función de comparación que a utilizar para verificar el
;;   orden.
;; 
;; Tenga en consideración:
;; - `tamanio` es un valor de 16 bits. La parte alta del registro en dónde viene
;;   como parámetro podría tener basura.
;; - `comparador` es una dirección de memoria a la que se debe saltar (vía `jmp` o
;;   `call`) para comenzar la ejecución de la subrutina en cuestión.
;; - Los tamaños de los arrays `inventario` e `indice` son ambos `tamanio`.
;; - `false` es el valor `0` y `true` es todo valor distinto de `0`.
;; - Importa que los ítems estén ordenados según el comparador. No hay necesidad
;;   de verificar que el orden sea estable.

global es_indice_ordenado
; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	; RDI = item_t**     inventario
	; RSI = uint16_t*    indice
	; RDX = uint16_t     tamanio -> la parte que me interesa esta en dx (16 bits)
	; RCX = comparador_t comparador
	; la respuesta por default es true, es decir, devuelvo un por RAX un bool. BLANQUEO rax antes de devolver
es_indice_ordenado:
		push rbp 
		mov rbp, rsp 
		push r12 ;desalineado. preservo r12 porque es no volatil y lo necesito siempre para el tamaño. no quiero perderlo
		push r13 ;alineado. lo uso de acumulador
		push r14 ;desalineado. lo voy a usar para guardar la lista de indice.
		push r15 ;alineado lo voy a usar para obtener guardar el inventario.
		push rbx ;desalineado. lo uso para almacenar la funcion de comparación.
		
		;blanqueos
		xor r12, r12 ;blanqueo un registro de 16 bits
		xor rax, rax ;blanqueo la RTA
		xor r13, r13 ;blanqueo el acumulador
		xor r14, r14 ;blanqueo el registro que voy a usar para la lista de indices
		xor r15, r15 ;blanqueo el registro que voy a usar para el inventario
		xor rbx, rbx ;blanqueo el registro que voy a usar para almacenar la función de comparación

		;tamanio/inventario/indice/comparador
		mov r12w, dx ;muevo el tamaño del array inventario/indice de 16 bits limpio a r12 para no tener basura. me va a servir para comparar en el ciclo con r13.
		mov r14, rsi ;son 64 bits la lista de indices así que esta ok
		mov r15, rdi ;son 64 bits el inventario asi que está ok
		mov rbx, rcx ;almaceno la función de comparación

		
		.ciclo: 
			movzx r9, r12w      ; r9 = tamanio  (64 bits)
			movzx r10, r13w     ; r10 = i      (64 bits)
			lea r11, [r10 + 1]  ; r11 = i + 1
			cmp r11, r9
			jp .success ;si el indice llegó al tamaño del array significa que todo funcó ok. salto a success.
			; agarro indice r13w e indice r13w+1, los guardo en dos registros.
			; ese indice es el que voy usar para ingresar al inventario. 

			;cargar inventario[indice[i]]
			movzx r8, WORD [r14 + r13*2]   ; r8 = indice[i] extendido a 64 bits
			mov rdx, [r15 + r8*8]          ; rdx = inventario[indice[i]]  (item_t*)
			mov rdi, rdx 
			
			 ; --- cargar inventario[indice[i+1]] ---
			movzx r8, WORD [r14 + r11*2]   ; r8 = indice[i+1]
			mov rdx, [r15 + r8*8]          ; rdx = inventario[indice[i+1]] (item_t*)
			mov rsi, rdx                   ; segundo arg para el comparador
			
			sub rsp, 8
			call rbx ; la respuesta está en rax. es un booleano (1/0)
			add rsp, 8

			cmp rax, FALSE 
			je .fail ; si es FALSE (0), entonces falla porque la comparación no es esperada. 
			inc r13 
			jmp .ciclo
			
		.fail: 
			mov rax, FALSE
			jmp .fin
		.success:
			mov rax, TRUE
		.fin: 
			pop rbx
			pop r15	
			pop r14
			pop r13
			pop r12
			pop rbp
		ret

;; Dado un inventario y una vista, crear un nuevo inventario que mantenga el
;; orden descrito por la misma.

;; La memoria a solicitar para el nuevo inventario debe poder ser liberada
;; utilizando `free(ptr)`.

;; item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio);

;; Donde:
;; - `inventario` un array de punteros a ítems que representa el inventario a
;;   procesar.
;; - `indice` es el arreglo de índices en el inventario que representa la vista
;;   que vamos a usar para reorganizar el inventario.
;; - `tamanio` es el tamaño del inventario.
;; 
;; Tenga en consideración:
;; - Tanto los elementos de `inventario` como los del resultado son punteros a
;;   `ítems`. Se pide *copiar* estos punteros, **no se deben crear ni clonar
;;   ítems**

global indice_a_inventario
indice_a_inventario:
	; Te recomendamos llenar una tablita acá con cada parámetro y su
	; ubicación según la convención de llamada. Prestá atención a qué
	; valores son de 64 bits y qué valores son de 32 bits o 8 bits.
	;
	; r/m64 = item_t**  inventario
	; r/m64 = uint16_t* indice
	; r/m16 = uint16_t  tamanio
	ret
