#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../test-utils.h"
#include "Debugging.h"

int main(int argc, char* argv[]) {

	uint32_t* array_inicial[1];

	uint32_t* punteroUint = malloc(sizeof(uint32_t));
	*punteroUint = 10;
	array_inicial[0] = punteroUint;
	
	uint32_t array_res[] = {80};
	uint32_t* array = ejercicio4(array_inicial, 1, 8);
	free(array);
	
}