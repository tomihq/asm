#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Estructuras.h"

int main() {
	
	uint32_t arr[] = {1, 2, 3};
    uint8_t categoria = 1;

    nodo_t* nodo = malloc(sizeof(nodo_t));
    nodo->next = NULL;
    nodo->categoria = categoria;
    nodo->arreglo = arr;
    nodo->longitud = sizeof(arr) / sizeof(arr[0]);

	nodo_t* nodo_2 = malloc(sizeof(nodo_t));
	nodo_2->next = NULL;
    nodo_2->categoria = categoria;
    nodo_2->arreglo = arr;
    nodo_2->longitud = sizeof(arr) / sizeof(arr[0]);

	nodo->next = nodo_2;


    lista_t* lista = malloc(sizeof(lista_t));
    lista->head = nodo;

	cantidad_total_de_elementos(lista);

    free(nodo);
    free(nodo_2);
    free(lista);

	return 0;
}
