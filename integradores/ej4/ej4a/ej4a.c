#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej4a.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - init_fantastruco_dir
 */
bool EJERCICIO_1A_HECHO = true;

// OPCIONAL: implementar en C
//Idea: necesito inicializar de la carta que me envian como parametro los campos de __dir y __dir_entries.
//en __dir tengo que meter dos  directory_entry_t:  
// una que tenga nombre sleep y el ability_ptr está en fantastruco.c
// una que tenga nombre wakeup y el ability_ptr está en fantastruco.c
void init_fantastruco_dir(fantastruco_t* card) {
    //desde ya, necesito reservar bastante memoria para __dir.
    //como por ahora ¿son dos habilidades? reservo memoria para el struct más grande de __dir que sería memoria para 2 * cantidadDePunteros.
    //Luego, tengo que reservar memoria para cada habilidad en particular. Y estos punteros que obtuve, los tengo que poner en __dir. 
    //Por último creo el struct más grande.

    //Creo directories. 
    directory_entry_t* sleepEntry = create_dir_entry("sleep", sleep);
    directory_entry_t* wakeupEntry = create_dir_entry("wakeup", wakeup);

    //Creo espacio para directory_t y meto los directories.
    directory_t dir = malloc(2 * 8);
    dir[0] = sleepEntry; //puntero dir a puntero de sleep
    dir[1] = wakeupEntry; //puntero dir a puntero de wakeup

    //piso en card lo que necesito
    card -> __dir = dir;
    card -> __dir_entries = 2; 

}

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - summon_fantastruco
 */
bool EJERCICIO_1B_HECHO = true;

// OPCIONAL: implementar en C
fantastruco_t* summon_fantastruco() {

    //necesito reusar lo mismo que antes creo. Porque me piden crear ahora un puntero a fantastruco_t* inicializado apropidamente con face_up = 1 yel atributo __archetype = null. Asumo que la anterior de sleep y wakeup ya era genérica.
    fantastruco_t* fantastruco = malloc(sizeof(fantastruco_t));
    fantastruco -> face_up = 1;
    fantastruco -> __archetype = NULL; 
    init_fantastruco_dir(fantastruco);

    return fantastruco;
}
