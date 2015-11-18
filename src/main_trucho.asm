.INCLUDE "gepetto.inc"

.DSEG

TEST: .BYTE 16

 .CSEG
.ORG 0x00
	JMP MAIN

.ORG URXCaddr
	JMP USB_INTERRUPT

.ORG INT_VECTORS_SIZE
	MAIN:
	
	;INICIALIZACION
	
	;Inicilizacion Sistema (stack pointer, timers, etc)
	
	CLR ZERO_REG
	
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16	

	CALL USB_INIT

	CALL SD_INIT

	SEI
	
	;Verificar programa guardado
	
	;Configurar e inicializar GRBL

MAIN_LOOP:

	JMP MAIN_LOOP
	
	DELAY: ;1 seg delay

		LDI R16, 3
		LDI R17, 44
		LDI R18, 82

		DELAY_LOOP:

		DEC R16
		BRNE DELAY_LOOP
		DEC R17
		BRNE DELAY_LOOP
		DEC R18
		BRNE DELAY_LOOP

		RET
	
.INCLUDE "timer.asm"

.INCLUDE "buffer.inc"

.INCLUDE "string.asm"

.INCLUDE "usb_comunication.asm"

.INCLUDE "spi.asm"

.INCLUDE "sd_card_comunication.asm"
