#include "../ejs.h"

// Función auxiliar para contar casos por nivel. 
void contar_casos_por_nivel(caso_t* arreglo_casos, int largo, int* contadores) {
    for(int i = 0; i<largo; i++){
        uint32_t nivel = arreglo_casos[i].usuario -> nivel;
        if(nivel > 2) continue;
        contadores[nivel]++;  //lo hago así porque como son nivel 0, 1, 2 se matchean con los indices del array. 
    }
}


segmentacion_t* segmentar_casos(caso_t* arreglo_casos, int largo) {
    int contadores[3] = {0, 0, 0}; //siempre son 3 niveles.
    contar_casos_por_nivel(arreglo_casos, largo, contadores);

    segmentacion_t* seg = malloc(sizeof(segmentacion_t)); //almaceno 3 punteros de 8 bytes cada uno. 

    //me piden caso_t* algo: osea que sería un array de caso_t. NO es un array de punteros, sino sería caso_t** 
    caso_t* casos_nivel_0 = contadores[0] ? malloc(contadores[0] * sizeof(caso_t)) : NULL;
    caso_t* casos_nivel_1 = contadores[1] ? malloc(contadores[1] * sizeof(caso_t)) : NULL;
    caso_t* casos_nivel_2 = contadores[2] ? malloc(contadores[2] * sizeof(caso_t)) : NULL;

    seg->casos_nivel_0 = casos_nivel_0;
    seg->casos_nivel_1 = casos_nivel_1;
    seg->casos_nivel_2 = casos_nivel_2;

    int i0=0,i1=0,i2=0;
    for (int i=0; i<largo; i++) {
        uint32_t nivel = arreglo_casos[i].usuario->nivel;
        if (nivel > 2) continue;

        switch (nivel) {
            case 0:
                seg->casos_nivel_0[i0++] = arreglo_casos[i]; // copia struct completo
                break;
            case 1:
                seg->casos_nivel_1[i1++] = arreglo_casos[i];
                break;
            case 2:
                seg->casos_nivel_2[i2++] = arreglo_casos[i];
                break;
        }
    }

    return seg; 
}

