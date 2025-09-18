#include "ej4b.h"

#include <string.h>

// OPCIONAL: implementar en C
void invocar_habilidad(void* carta_generica, char* habilidad) {
	 if (!carta_generica || !habilidad) return;

    card_t* carta = (card_t*) carta_generica;

    for (int i = 0; i < carta->__dir_entries; i++) {
        directory_entry_t* actual_entry = carta->__dir[i];
        if (!actual_entry) continue;

        if (strcmp(actual_entry->ability_name, habilidad) == 0) {
            ability_function_t* ability_ptr = (ability_function_t*) actual_entry->ability_ptr;
            ability_ptr(carta_generica); 
            return;
        }
    }

    card_t* arquetipo = (card_t*) carta->__archetype;
    if (arquetipo) {
        invocar_habilidad(arquetipo, habilidad);
    }


}
