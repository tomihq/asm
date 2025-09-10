#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../test-utils.h"
#include "Memoria.h"

int main() {
	char s[] = "hola";
	char* p = &s[0];
	assert(strLen(p) == 4);
	char s2[]= "";
	char *p2 = &s2[0];
	assert(strLen(p2) == 0);
	return 0;
}
