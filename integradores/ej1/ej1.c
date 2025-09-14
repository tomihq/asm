#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej1.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - es_indice_ordenado
 */
bool EJERCICIO_1A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - indice_a_inventario
 */
bool EJERCICIO_1B_HECHO = true;

/**
 * OPCIONAL: implementar en C
 */
bool es_indice_ordenado(item_t** inventario, uint16_t* indice, uint16_t tamanio, comparador_t comparador) {
	item_t* item1 = NULL;
	item_t* item2 = NULL; 
	for(int i=0; i+1<tamanio; i++){
		item1 = inventario[indice[i]];
		//item1 = *(inventario + (*(indice + i))); // *(indice + i * 2) -> cada indice, llamemosle indice ->  *(inventario + indice * 8) 8 es el tamaño de los punteros. En C no hace falta xq los tamaños de los items te lo resuelve el compilador
		item2 = inventario[indice[i+1]];
		//item2 = *(inventario + (*(indice + (i+1)))) //*(indice + (i+1) * 2) -> indice (i+1), llamemosle indice 2 -> *(inventario + indice2 *8) 8 es el tamaño de los punteros. En C no hace falta xq los tamaños de los items te lo resuelve el compilador
		if(comparador(item1, item2) == false) return false; 
	}
	return true;
}

/**
 * OPCIONAL: implementar en C
 */
item_t** indice_a_inventario(item_t** inventario, uint16_t* indice, uint16_t tamanio) {
	item_t** resultado = malloc(sizeof(item_t) * tamanio); //voy a guardar tamanio elementos que pesan item_t
	for(int i = 0; i<tamanio; i++){
		item_t* item = inventario[indice[i]]; //agarro la direccion de memoria del puntero al item.
		item_t* copiaItem = malloc(sizeof(item_t)); //reservo memoria para el nuevo puntero
		copiaItem = item; //copio el puntero de item a copiaItem
		resultado[i] = copiaItem; 
	}
	return resultado;
}
