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
bool EJERCICIO_2C_HECHO = true;

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
 Idea: Si la unidad que está en x,y tiene references > 0 entonces tengo que hacer una copia (malloc). Restar 1 a la referencia de [x][y] original.
 Enviar ese puntero creado con malloc a fun_modificar.  

 */
void modificarUnidad(mapa_t mapa, uint8_t x, uint8_t y, void (*fun_modificar)(attackunit_t*)) {
    attackunit_t* item = mapa[x][y];
    if(item == NULL) return; 
    if(item -> references == 0){
            fun_modificar(item);
            mapa[x][y] = item;
            return; 
    }
    
    attackunit_t* item2 = malloc(sizeof(attackunit_t));
    strcpy((item2 -> clase), (item -> clase));
    item2 -> combustible = item -> combustible;
    item2 -> references = 1; // por default las referencias empiezan en 1.
    item -> references -= 1; 
    fun_modificar(item2);
    if(item -> references == 0){ //si ya no la usa nadie, la borro. 
        free(item);
    }
    mapa[x][y] = item2;
    

}
char clase[11];       //asmdef_offset:ATTACKUNIT_CLASE
	uint16_t combustible; //asmdef_offset:ATTACKUNIT_COMBUSTIBLE
	uint8_t references; 