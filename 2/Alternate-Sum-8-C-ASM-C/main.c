#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>

#include "../../test-utils.h"
#include "ABI.h"

int main() {
	/* Acá pueden realizar sus propias pruebas */
	///assert(alternate_sum_4_using_c(8, 2, 5, 1) == 6);
	assert(alternate_sum_8(1, 2, 3, 4, 5, 6, 7, 0) == 4);
	assert(alternate_sum_8(1, 2, 3, 4, 5, 6, 7, 4) == 0);
	int32_t n = alternate_sum_8(1, 2, 3, 4, 5, 6, 7, 8);
	printf("%d \n", n); //esto funciona porque EAX devuelve un numero de 32 bits. El tema queda en nosotros como interpretarlo (si unsigned/signed).
	assert(alternate_sum_8(1, 2, 3, 4, 5, 6, 7, 8) == -4);

	//assert(alternate_sum_4_using_c_alternative(8, 2, 5, 1) == 6);
	return 0;
}
