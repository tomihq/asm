#include <stdio.h>

int alternate_sum_4_using_c(int x1, int x2, int x3, int x4);

int main() {
    int x1 = 10, x2 = 5, x3 = 3, x4 = 2;

    int resultado = alternate_sum_4_using_c(x1, x2, x3, x4);

    printf("Resultado: %d\n", resultado);

    return 0;
}