.INCLUDE "m328pdef.inc"



.DEF ZERO_REG = R1

.DSEG

.CSEG
.ORG 0x00
	JMP MAIN

.ORG INT0addr
	JMP SOFT_UART_INTERRUPT

	
.ORG INT_VECTORS_SIZE
MAIN:
	
	;INICIALIZACION
	
	;Inicilizacion Sistema (stack pointer, timers, etc)
	
	CLR ZERO_REG
	
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16
	
	CALL BUTTONS_TIMER_INIT
	
	;Inicializacion SOFTUART (Micro interprete)
	
	LDI R16, SOFT_UART_DEF_SUBR
	STS SUBR, R16

	CALL SOFT_UART_INIT
	
	;Inicializacion USART (PC)
	
	;Inicializacion SPI (SD)
	
	;Verificar programa guardado
	
	;Configurar e inicializar GRBL
	
	SEI

STATE_IDLE:
	
	;Procesar buffer GRBL
	
	;Verificar connección PC
	
	;Procesar botones
	
	;Actualizar UI
	RJMP STATE_IDLE
	
STATE_CONNECTED:
	
	;Procesar botones
	
	;Procesar buffer USB (guardar o ejecutar)
	
	;Procesar buffer GRBL
	
	;Actualizar UI
	RJMP STATE_CONNECTED
	
STATE_RUNNING:
	
	;Procesar botones
	
	;Procesar buffer SPI
	
	;Procesar buffer GRBL
	
	;Actualizar UI
	RJMP STATE_RUNNING
	
STATE_ERROR:
	
	;Procesar Botones
	
	;Actualizar UI
	
	RJMP STATE_ERROR
	