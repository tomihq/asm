#include <stdio.h>
#include <stdint.h>
extern uint32_t alternate_sum_4_using_c(uint32_t x1, uint32_t x2, uint32_t x3, uint32_t x4);

int main() {
    uint32_t x1 = 10, x2 = 5, x3 = 3, x4 = 2;

    uint32_t resultado = alternate_sum_4_using_c(x1, x2, x3, x4);

    printf("Resultado: %d\n", resultado);

    return 0;
}