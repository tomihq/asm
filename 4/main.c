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

	char s3[] = "hola";
	char* p3 = &s3[0];
	assert(strCmp(p, p3) == 0);
	assert(strCmp(p, p2) == -1);
	assert(strCmp(p2, p) == 1);
	assert(strCmp(p2, p2) == 0);

	char* p4 = strClone(s3);
	assert(*p4== 'h');
	free(p4);
	return 0;
}
