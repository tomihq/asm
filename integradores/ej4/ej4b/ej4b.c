#include "ej4b.h"

#include <string.h>

// OPCIONAL: implementar en C
//idea: 
// 1. me dan carta, busco en __dir si esta la habilidad. 
// 2. Si no está en __dir busco en archetype. 
// 3. Si no está en __dir de archetype. Me fijo en el archetype del archetype (empiezo desde 1 de vuelta)
void invocar_habilidad(void* carta_generica, char* habilidad) {
    if (!carta_generica || !habilidad) return;

    card_t* carta = (card_t*) carta_generica;

    while (carta) {  // Recorremos la carta y sus arquetipos
        for (int i = 0; i < carta->__dir_entries; i++) {
            directory_entry_t* actual_entry = carta->__dir[i];
            if (!actual_entry) continue;

            if (strcmp(actual_entry->ability_name, habilidad) == 0) {
                ability_function_t* ability_ptr = (ability_function_t*) actual_entry->ability_ptr;
                ability_ptr(carta_generica); 
                return;  // Salimos cuando encontramos la habilidad
            }
        }
        carta = (card_t*) carta->__archetype;  // Pasamos al arquetipo siguiente
    }
}
