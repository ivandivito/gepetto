.INCLUDE "gepetto.inc"

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
	
	CALL SPI_INIT
	;creo que aca se nesesita un delay de 10ms
	CALL SPI_SD_INIT

	

	SEI
	
	;Verificar programa guardado
	
	;Configurar e inicializar GRBL

	CLR SPI_SD_RX_BLOCK_INDEX_REG
	LDI XL,LOW(SPI_RX_BUFFER_1)
	LDI XH,LOW(SPI_RX_BUFFER_1)

	;debug
	SBI DDRC,2
	CBI PORTC,2
	;debug


	CALL SPI_SD_RX_BLOCK

	
	LDI XL,LOW(SPI_RX_BUFFER_1)
	LDI XH,LOW(SPI_RX_BUFFER_1)

	CALL USB_SEND_D_LINE

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

.INCLUDE "buffer.inc"

.INCLUDE "string.asm"

.INCLUDE "usb_comunication.asm"

.INCLUDE "spi.asm"
