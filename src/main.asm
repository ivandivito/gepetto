.INCLUDE "gepetto.inc"

.EQU UIS = 0

.EQU UII = 1 ;0: Interfaz Valida			1: Refrescar Interfaz
.EQU UC  = 2  ;0: USB desconectado			1: USB conectado
.EQU CSS = 3 ;0: Renviar datos a GRBL		1: Guardar datos en SD
.EQU SFF = 4 ;0: No hay programa guardado	1: Hay programa guardado
.EQU GD = 5 ;0: GRBL disponible , 1: GRBL procesando instruccion
.EQU RSS = 6 ;0: operacion corriendo , 1: operacion pausada

.DSEG
CURRENT_STATE: .BYTE 1
GGR: .BYTE 1; Gepetto General Register (- RSS(Running Substate) GD (GRBL disposable) SFF(Saved File Flag) CSS(Conected Substate) UC(USB Connected) UII(UI Invalidated) UIS(UI State))

.CSEG
.ORG 0x00
	JMP MAIN

.ORG INT1addr
	JMP SOFT_UART_INTERRUPT
	
.ORG OVF1addr
	JMP TIMER_OVERFLOW_INTERRUPT
	
.ORG URXCaddr
	JMP USB_INTERRUPT
	
.ORG INT_VECTORS_SIZE
SOFT_UART_RX_INT:
	JMP GRBL_INTERRUPT

MAIN:
	
	;INICIALIZACION
	
	;Inicilizacion Sistema (stack pointer, timers, etc)
	
	CLR ZERO_REG
	
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
 	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	CALL TIMER_INIT
	
	LDI R16, STATE_IDLE
	STS CURRENT_STATE, R16

	CALL BUTTONS_INIT

	;Inicializacion SOFTUART (Micro interprete)
	
	CALL GRBL_COM_INIT
	
	;Inicializacion USART (PC)
	
	CALL USB_INIT
	
	;Inicializacion SPI (SD)

	CALL SD_INIT
	
	;lo comente porque sino no puedo correrlo en mi placa
	;Incializar LCD
	
	CALL UI_INIT


	LDI R16, (1<<UII)
	STS GGR, R16

	SEI

	;Verificar programa guardado
	
	;Configurar e inicializar GRBL

.DEF STATE_REG = R16
	
MAIN_LOOP:

	;Cargar estado
	LDS STATE_REG, CURRENT_STATE
	
	CPI STATE_REG, STATE_IDLE
	BREQ MAIN_IDLE
	
	CPI STATE_REG, STATE_CONNECTED
	BREQ MAIN_CONNECTED
	
	CPI STATE_REG, STATE_RUNNING
	BREQ MAIN_RUNNING
	
	RJMP MAIN_ERROR
	
	MAIN_IDLE:
		CALL IDLE_RUN
		RJMP MAIN_LOOP
		
	MAIN_CONNECTED:
		CALL CONNECTED_RUN
		RJMP MAIN_LOOP
		
	MAIN_RUNNING:
		CALL RUNNING_RUN
		RJMP MAIN_LOOP
		
	MAIN_ERROR:
		CALL ERROR_RUN
		RJMP MAIN_LOOP

.INCLUDE "timer.asm"

.INCLUDE "buffer.inc"

.INCLUDE "string.asm"

.INCLUDE "parser.asm"

.INCLUDE "state.inc"

.INCLUDE "buttons.asm"

.INCLUDE "soft_uart.asm"
.INCLUDE "grbl_comunication.asm"

.INCLUDE "usb_comunication.asm"

.INCLUDE "spi.asm"
.INCLUDE "sd_card_comunication.asm"

.INCLUDE "delay.asm"
.INCLUDE "lcd.asm"
.INCLUDE "ui.asm"

.INCLUDE "idle.asm"
.INCLUDE "connected.asm"
.INCLUDE "running.asm"
.INCLUDE "error.asm"


.INCLUDE "constants.asm"

.INCLUDE "debug.asm"

