#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "ejercicio.h"

/**
 * Marca el ejercicio 1 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - hay_accion_que_toque
 */
bool EJERCICIO_1_HECHO = true;

/**
 * Marca el ejercicio 2 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - invocar_acciones
 */
bool EJERCICIO_2_HECHO = true;

/**
 * Marca el ejercicio 3 como hecho (`true`) o pendiente (`false`).
 *
 * Funciones a implementar:
 *   - contar_cartas
 */
bool EJERCICIO_3_HECHO = true;

/**
 * Dada una secuencia de acciones determinar si hay alguna cuya carta tenga un
 * nombre idéntico (mismos contenidos, no mismo puntero) al pasado por
 * parámetro.
 *
 * El resultado es un valor booleano, la representación de los booleanos de C es
 * la siguiente:
 *   - El valor `0` es `false`
 *   - Cualquier otro valor es `true`
 */
bool hay_accion_que_toque(accion_t* accion, char* nombre) {
	while(accion != NULL){
		carta_t* carta = accion -> destino; //*(accion.destino)
		if(strcmp(carta -> nombre, nombre) == 0) return true; 
		accion = accion -> siguiente; 
	}
	return false;
}

/**
 * Invoca las acciones que fueron encoladas en la secuencia proporcionada en el
 * primer parámetro.
 *
 * A la hora de procesar una acción esta sólo se invoca si la carta destino
 * sigue en juego.
 *
 * Luego de invocar una acción, si la carta destino tiene cero puntos de vida,
 * se debe marcar ésta como fuera de juego.
 *
 * Las funciones que implementan acciones de juego tienen la siguiente firma:
 * ```c
 * void mi_accion(tablero_t* tablero, carta_t* carta);
 * ```
 * - El tablero a utilizar es el pasado como parámetro
 * - La carta a utilizar es la carta destino de la acción (`accion->destino`)
 *
 * Las acciones se deben invocar en el orden natural de la secuencia (primero
 * la primera acción, segundo la segunda acción, etc). Las acciones asumen este
 * orden de ejecución.
 Una carta con 0 puntos de vida puede estar en juego antes de invocarse una acción.
 Una carta puede pasar a estar fuera de juego por razones ajenas a sus puntos de vida (tal vez la acción la pone a dormir).
 Una carta que tiene cero puntos de vida después de invocarse su acción sí o sí pasa a estar fuera de juego (independientemente de si antes tenía 0 puntos o no).
 */
void invocar_acciones(accion_t* accion, tablero_t* tablero) {
	//accion -> invocar() sí y solo sí accion -> destino -> en_juego = true
	//despues de accion -> invocar() si accion -> destino -> vida = 0 entonces ahora accion -> destino -> en_juego = false
	//despues de estos chequeos hago accion = accion -> siguiente
	while(accion != NULL){
		carta_t* carta = accion -> destino; //*(accion.destino)
		if(carta -> en_juego == false){
			accion = accion -> siguiente; 
			continue;
		} 

		accion -> invocar(tablero, carta);
		if(carta -> vida == 0){
			carta -> en_juego = false; 
		}

		accion = accion -> siguiente; 
	}


}

/**
 * Cuenta la cantidad de cartas rojas y azules en el tablero.
 *
 * Dado un tablero revisa el campo de juego y cuenta la cantidad de cartas
 * correspondientes al jugador rojo y al jugador azul. Este conteo incluye
 * tanto a las cartas en juego cómo a las fuera de juego (siempre que estén
 * visibles en el campo).
 *
 * Se debe considerar el caso de que el campo contenga cartas que no pertenecen
 * a ninguno de los dos jugadores.
 *
 * Las posiciones libres del campo tienen punteros nulos en lugar de apuntar a
 * una carta.
 *
 * El resultado debe ser escrito en las posiciones de memoria proporcionadas
 * como parámetro.
 */
void contar_cartas(tablero_t* tablero, uint32_t* cant_rojas, uint32_t* cant_azules) {
	//necesito recorrer el tablero e ir contando las cartas. 
	//no me importa que estén en_juego no.
	//tengo que llevar un acumulador para rojas y azules.
	//las rojas tienen 1 byte jugador === 1
	//las azules tienen 1 byte jugador === 2
	//la idea es ir recorriendo el campo, recordar que es de 10 * 5. Cada ítem es una carta. Ahí tengo que hacer lo de arriba.
	//es probable que cuando "quiera una carta" no haya nada. verificar null.
	//puede haber un jugador que no sea ni el 1 ni el 2. lo cual no hay que contar nada ahi. 
	*cant_rojas = *cant_azules = 0;
	uint32_t acum_rojas = 0; 
	uint32_t acum_azules = 0; 
	//5 x 10
	for(int i = 0; i<5; i++){
		for(int j = 0; j<10; j++){
			carta_t* carta = tablero -> campo[i][j]; 
			if(carta == NULL) continue; 
	
			if(carta -> jugador == 1) acum_rojas += 1;
			else if(carta -> jugador == 2) acum_azules+= 1; 
			
			continue;

			
		}
	}

	*cant_rojas = acum_rojas;
	*cant_azules = acum_azules;
	
}
