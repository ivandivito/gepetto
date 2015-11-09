/*
 * main_trucho.asm
 *
 *  Created: 09/11/2015 12:23:24 a.m.
 *   Author: ivan
 */ 
 .CSEG
.ORG 0x00
	JMP MAIN

.ORG INT_VECTORS_SIZE
	MAIN:
	
	;INICIALIZACION
	
	;Inicilizacion Sistema (stack pointer, timers, etc)
	
	CLR ZERO_REG
	
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	
	;Inicializacion SPI (SD)

	CALL SPI_INIT

	;creo que aca se nesesita un delay de 10ms

	CALL SPI_SD_INIT
	
	SEI
	
	;Verificar programa guardado
	
	;Configurar e inicializar GRBL

HERE: JMP HERE

.INCLUDE "gepetto.inc"
