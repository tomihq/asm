#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../test-utils.h"
#include "Debugging.h"

int main(int argc, char* argv[]) {
    item_t* un_item = malloc(sizeof(item_t));
    ejercicio2(un_item, 1234, 3, "poncho");
    free(un_item);
}