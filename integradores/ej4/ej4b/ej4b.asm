extern strcmp
global invocar_habilidad

; Completar las definiciones o borrarlas (en este ejercicio NO serán revisadas por el ABI enforcer)
DIRENTRY_NAME_OFFSET EQU 0
DIRENTRY_PTR_OFFSET EQU 16
DIRENTRY_SIZE EQU 24

FANTASTRUCO_DIR_OFFSET EQU 0
FANTASTRUCO_ENTRIES_OFFSET EQU 8
FANTASTRUCO_ARCHETYPE_OFFSET EQU 16
FANTASTRUCO_FACEUP_OFFSET EQU 24
FANTASTRUCO_SIZE EQU 32

section .rodata
; Acá se pueden poner todas las máscaras y datos que necesiten para el ejercicio

section .text

; void invocar_habilidad(void* carta, char* habilidad);
invocar_habilidad:
    push rbp
    mov rbp, rsp
	sub rsp, 8
    push rbx        ; no volátil
    push r12        ; carta actual
    push r13        ; __dir
    push r14        ; cantidad de entries
    push r15        ; índice i

    ; RDI = carta_generica
    ; RSI = habilidad

    test rdi, rdi
    jz .done

    mov r12, rdi   ; r12 = carta actual

.loop_carta:
    test r12, r12
    jz .done

    mov r13, QWORD [r12 + FANTASTRUCO_DIR_OFFSET]        ; r13 = __dir
    movzx r14, WORD [r12 + FANTASTRUCO_ENTRIES_OFFSET]  ; r14 = __dir_entries
    xor r15, r15                                        ; i = 0

.loop_dir:
    cmp r15, r14
    jae .next_archetype

    mov rbx, QWORD [r13 + r15*8]   ; rbx = dir[i]
    test rbx, rbx
    jz .next_entry
    lea rdi, [rbx + DIRENTRY_NAME_OFFSET] ; puntero a ability_name
    mov rsi, rsi                           ; habilidad
    call strcmp
    test eax, eax
    jnz .next_entry

    ; Coincide → llamar a la función
    mov rax, QWORD [rbx + DIRENTRY_PTR_OFFSET] ; ability_ptr
    mov rdi, r12                               ; argumento = carta donde se encuentra la habilidad
    call rax
    jmp .done

.next_entry:
    inc r15
    jmp .loop_dir

.next_archetype:
    mov r12, QWORD [r12 + FANTASTRUCO_ARCHETYPE_OFFSET] ; siguiente arquetipo
    jmp .loop_carta

.done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
	add rsp, 8
    pop rbp
    ret