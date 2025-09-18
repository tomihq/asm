extern malloc
extern sleep
extern wakeup
extern create_dir_entry

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio
sleep_name: DB "sleep", 0
wakeup_name: DB "wakeup", 0

section .text
; Marca un ejercicio como aún no completado (esto hace que no corran sus tests)
FALSE EQU 0
; Marca un ejercicio como hecho
TRUE  EQU 1

NULL EQU 0

; Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - init_fantastruco_dir
global EJERCICIO_1A_HECHO
EJERCICIO_1A_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

; Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
;
; Funciones a implementar:
;   - summon_fantastruco
global EJERCICIO_1B_HECHO
EJERCICIO_1B_HECHO: db TRUE ; Cambiar por `TRUE` para correr los tests.

;########### ESTOS SON LOS OFFSETS Y TAMAÑO DE LOS STRUCTS
; Completar las definiciones (serán revisadas por ABI enforcer):
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

; void init_fantastruco_dir(fantastruco_t* card);
global init_fantastruco_dir
; fantastruco_t* card -> RDI 64 bits.
;idea basada en C: 
;necesito registro no volatil para preservar card.
;necesito registro no volatil para preservar sleepEntry, wakeupEntry. 
;necesito registro no volatil para preservar directory_t dir.
;para hacer dir[0] = sleepEntry puedo hacer mov [dir + (indice * tamañoPuntero)], sleepEntry
;para hacer dir[1] = wakeupEntry puedo hacer mov [dir + (indice * tamañoPuntero)], wakeupEntry. El mov vale porque le estoy moviendo un puntero. Entra sí o sí. 
;para hacer card -> __dir y pisarle dir puedo hacer mov [card + DIR_OFFSET], dir
;para hacer card -> __dir_entries y pisarle el 2 puedo hacer mov WORD[ card + DIR_ENTRIES], 2. Notar que es un 2 pero el campo es de 2 bytes (16 bits).
; Ojo: chequear cosas que no estoy seguro: 
; ¿asumo que es simil a mandarsela así nomas en C? mov rsi, wakeup será igual a create_dir_entry(wakeup)?
init_fantastruco_dir:
	push rbp ;alineado
	mov rbp, rsp 
	push r12 ;desalineado
	push r13 ;alineado
	push r14 ;desalineado
	push r15 ;alineado

	;preservo fantastruco_t* card
	mov r12, rdi; r12 tiene fantastruco_t* card

	;preparo el call a create_dir_entry (sleep). me devuelve por rax directory_entry_t*. Un char y un puntero. (ambos son considerados enteros o punteros)
	mov rdi, sleep_name ;string sleep
	mov rsi, sleep ;funcion sleep
	call create_dir_entry
	mov r13, rax ;directory_entry_t* sleepEntry

	;preparo el call a create_dir_entry (wakeup). me devuelve por rax directory_entry_t*. Un char y un puntero. (ambos son considerados enteros o punteros)
	mov rdi, wakeup_name ;string wakeup
	mov rsi, wakeup ;funcion wakeup. 
	call create_dir_entry 
	mov r14, rax ;directory_entry_t* wakeupEntry

	;preparo el call para crear directory_t dir 
	mov rdi, 16 ;necesito solo espacio para dos punteros
	call malloc
	mov r15, rax ; directory_t dir

	mov QWORD[r15], r13
	mov QWORD[r15 + 8], r14 ;revisar esto. Mi idea es moverme al siguiente indice del array. EL array es de punteros. 

	mov QWORD[r12 + FANTASTRUCO_DIR_OFFSET], r15 ;paso a fantastruco_t* el directory_t dir
	mov WORD[r12 + FANTASTRUCO_ENTRIES_OFFSET], 2


	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret ;No te olvides el ret!

; fantastruco_t* summon_fantastruco();
; idea basada en c: necesito si o si un registro no volatil para almacenar fantastruco_t* fantastruco apenas use malloc.
; despues necesito setear con BYTE [fantastruco +OFFSET_FACEUP], 1 y [fantastruco + OFFSET_ARCHETYPE], NULL / 0 segun quiera.
; por ultimo llamo a init_fantastruco_dir
global summon_fantastruco
summon_fantastruco:
	; Esta función no recibe parámetros
	push rbp
	mov rbp, rsp
	push r12
	sub rsp, 8

	;; llamo malloc
	mov rdi, FANTASTRUCO_SIZE
	call malloc 
	mov r12, rax; fantastruco_t* fantastruco

	mov BYTE[r12 + FANTASTRUCO_FACEUP_OFFSET], 1
	mov BYTE [r12 + FANTASTRUCO_ARCHETYPE_OFFSET], NULL
	
	;preparo llamada 
	mov rdi, r12 
	call init_fantastruco_dir

	;muevo rta a rax
	mov rax, r12

	add rsp, 8
	pop r12
	pop rbp
	ret ;No te olvides el ret!
