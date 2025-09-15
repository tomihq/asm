#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ej2.h"

/**
 * Marca el ejercicio 1A como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - optimizar
 */
bool EJERCICIO_2A_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contarCombustibleAsignado
 */
bool EJERCICIO_2B_HECHO = true;

/**
 * Marca el ejercicio 1B como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - modificarUnidad
 */
bool EJERCICIO_2C_HECHO = false;

/**
 * OPCIONAL: implementar en C
 */
void optimizar(mapa_t mapa, attackunit_t* compartida, uint32_t (*fun_hash)(attackunit_t*)) {
    for(int i = 0; i<255; i++){
        for(int j = 0; j<255; j++){
            attackunit_t* unit_mapa = mapa[i][j]; //*(mapa + i * 8) te parás en el puntero. 

            if(unit_mapa == NULL) continue;
            if(unit_mapa == compartida) continue;
            if(fun_hash(unit_mapa) == fun_hash(compartida)){ //no tengo que incrementar si la que me pasan ya esta en el mapa. Error de enunciado.
                                mapa[i][j] = compartida;
                                compartida -> references += 1;
                                unit_mapa -> references -= 1; 
                                if(unit_mapa -> references == 0){
                                    free(unit_mapa);
                                }

                }
           
        }
    }
}

/**
 * OPCIONAL: implementar en C
 * Tengo garantizado el mapa optimizado asumo.
 * IDEA: Por cada attackunit_t != NULL, calculo la resta entre combustibleActual (mapa[i][j] -> combustible - fun_combustible(mapa[i][j] -> clase)).
 Hago ABS para tenerlo positivo, I guess? Ojo con los tamaños. La RTA es de 32 pero las cuentas las hago con 16.  Podría tener basura.
 */
uint32_t contarCombustibleAsignado(mapa_t mapa, uint16_t (*fun_combustible)(char*)) {
    uint32_t cantidadCombustibleAsignado = 0;
    for(int i = 0 ; i < 255 ; i++){
        for (int j = 0; j<255; j++){
            attackunit_t* item = mapa[i][j];
            if(item == NULL) continue;
            uint32_t combustibleClase = fun_combustible(item -> clase);
            uint32_t combustibleMapa =item -> combustible;
            cantidadCombustibleAsignado += combustibleMapa - combustibleClase;
        }
    }
    return cantidadCombustibleAsignado;
}

/**
 * OPCIONAL: implementar en C
 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
}
