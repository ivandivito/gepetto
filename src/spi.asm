
.INCLUDE "gepetto.inc"

.EQU SPI_DDR = DDRB
.EQU SPI_PORT = PORTB
.EQU MOSI_PIN = 3
.EQU MISO_PIN = 4
.EQU SS_PIN = 2
.EQU SCK_PIN = 5

.EQU SPI_RX_BUFFER_SIZE = 257 ; 1 + por /0

.DSEG
SPI_RX_BUFFER_POINTER_1: .BYTE 1
SPI_RX_BUFFER_POINTER_2: .BYTE 1
SPI_RX_BUFFER_1: .BYTE SPI_RX_BUFFER_SIZE
SPI_RX_BUFFER_2: .BYTE SPI_RX_BUFFER_SIZE

.CSEG
SPI_INIT:
	
		IN SPI_INC_TEMP, SPI_DDR
		ORI SPI_INC_TEMP, ((1<<MOSI_PIN)|(1<<SCK_PIN)|(1<<SS_PIN)) ;mosi, clk y ss como salida
		ANDI SPI_INC_TEMP, ~(1<<MISO_PIN) ;miso como entrada
		OUT SPI_DDR, SPI_INC_TEMP

		LDI SPI_INC_TEMP,((1<<SPE)|(1<<MSTR)) ;SPI sin interrupciones, habilitado en master, envio primero MSB, clk/4
		OUT SPCR,SPI_INC_TEMP

		LDI SPI_INC_TEMP,0 ;clk/4
		OUT SPSR,SPI_INC_TEMP
	
		RET

SPI_TX:

		OUT SPDR,SPI_IN_OUT_REG
		 
	SPI_TX_WAIT:
		IN SPI_INC_TEMP,SPSR
		ANDI SPI_INC_TEMP,(1<<SPIF) ; reviso flag de completa
		BREQ SPI_TX_WAIT

		IN SPI_IN_OUT_REG,SPDR
		RET

SPI_RX:
		
		LDI SPI_IN_OUT_REG,0xFF
		CALL SPI_TX

		RET


SPI_SD_INIT:

		CALL SPI_SD_SELECT

		SPI_SD_TX_CMD_REP_MACRO GO_IDLE_STATE, 0x00000000, SD_CMD_RSP_IDLE
		SPI_SD_TX_CMD_REP_MACRO SEND_IF_COND, 0x000001AA, SD_CMD_RSP_IDLE

	SPI_SD_INIT_TX_APP:
		SPI_SD_TX_CMD_MACRO APP_CMD, 0x00000000
		MOV SPI_INC_TEMP, SPI_SD_CMD_RSP_REG
		SPI_SD_TX_CMD_MACRO SD_SEND_OP_COND, 0x40000000
		AND SPI_INC_TEMP,SPI_SD_CMD_RSP_REG
		BRNE SPI_SD_INIT_TX_APP ; si luego de estas 2 instrucciones la respuesta de ambas no es 0 repetir

		SPI_SD_TX_CMD_REP_MACRO READ_OCR, 0x00000000, SD_CMD_RSP_NOT_IDLE
		CALL SPI_SD_DESELECT

		;pasar a velocidad rapida

		RET

SPI_SD_SELECT:
		
		IN SPI_INC_TEMP,PORTB
		ANDI SPI_INC_TEMP,~(1<<SS_PIN) 
		OUT PORTB,SPI_INC_TEMP ;pongo el ss en alto
		RET

SPI_SD_DESELECT:
		
		IN SPI_INC_TEMP,PORTB
		ORI SPI_INC_TEMP,(1<<SS_PIN)
		OUT PORTB,SPI_INC_TEMP ;pongo el ss en bajo
		RET

SPI_SD_TX_CMD:

		LDI SPI_INC_TEMP,SD_CMD_MASK
		OR SPI_SD_CMD_REG,SPI_INC_TEMP
		MOV SPI_IN_OUT_REG,SPI_SD_CMD_REG
		CALL SPI_TX ;mando el comando y sus argumentos

		MOV SPI_IN_OUT_REG,SPI_SD_CMD_ARG_REG_1
		CALL SPI_TX

		MOV SPI_IN_OUT_REG,SPI_SD_CMD_ARG_REG_2
		CALL SPI_TX

		MOV SPI_IN_OUT_REG,SPI_SD_CMD_ARG_REG_3
		CALL SPI_TX

		MOV SPI_IN_OUT_REG,SPI_SD_CMD_ARG_REG_4
		CALL SPI_TX

		LDI SPI_INC_TEMP,SEND_IF_COND
		CP SPI_SD_CMD_REG,SPI_INC_TEMP
		BREQ SPI_TX_SD_CMD_IF_END
		LDI SPI_IN_OUT_REG, SD_CMD_END
		RJMP SPI_TX_SD_CMD_END ;si la el comando es un if tengo que poner un final distinto

	SPI_TX_SD_CMD_IF_END:
		LDI SPI_IN_OUT_REG, SD_CMD_IF_END

	SPI_TX_SD_CMD_END:
		CALL SPI_TX

	SPI_TX_SD_CMD_WAIT:
		CALL SPI_RX

		CPI SPI_IN_OUT_REG,SD_CMD_RSP_WAIT  ;si la respuesta es FF tengo que esperara a que responda
		BREQ SPI_TX_SD_CMD_WAIT

		MOV SPI_SD_CMD_RSP_REG,SPI_IN_OUT_REG
		RET

SPI_SD_RX_BLOCK: ; SPI_SD_RX_BLOCK_INDEX_REG tiene que tener el indice del bloque y el puntero X el BUFFER a escribir

		PUSH XL
		PUSH XH
		
		CALL SPI_SD_SELECT

	SPI_SD_READ_BLOCK_DIREC_LOOP: ; tengo que mandar el comando READ_SINGLE_BLOCK con argumento la direccion a empezar a leer
		LDI SPI_INC_TEMP,READ_SINGLE_BLOCK
		MOV SPI_SD_CMD_REG,SPI_INC_TEMP
		MOV SPI_SD_CMD_ARG_REG_1,ZERO_REG 
		MOV SPI_SD_CMD_ARG_REG_2,ZERO_REG
		LSL SPI_SD_RX_BLOCK_INDEX_REG 
		MOV SPI_SD_CMD_ARG_REG_3,SPI_SD_RX_BLOCK_INDEX_REG
		MOV SPI_SD_CMD_ARG_REG_4,ZERO_REG
		CALL SPI_SD_TX_CMD

		CPI SPI_SD_CMD_RSP_REG,SD_CMD_RSP_NOT_IDLE
		BRNE SPI_SD_READ_BLOCK_DIREC_LOOP

	SPI_SD_READ_BLOCK_START_LOOP: ;espero a que empieze a mandar datos
		LDI SPI_INC_TEMP,SD_CMD_RSP_START
		CALL SPI_RX
		CP SPI_SD_RX_BLOCK_INDEX_REG,SPI_INC_TEMP
		BRNE SPI_SD_READ_BLOCK_START_LOOP

		LDI SPI_INC_TEMP, 0xFF

	SPI_SD_READ_BLOCK_LOOP:
		CALL SPI_RX
		MOV CHAR_REG,SPI_IN_OUT_REG
		BUFFER_INSERT_CHAR SPI_RX_BUFFER_1, SPI_RX_BUFFER_POINTER_1
		DEC SPI_INC_TEMP
		BRNE SPI_SD_READ_BLOCK_LOOP

		LDI SPI_INC_TEMP, 0xFF

	SPI_SD_READ_BLOCK_EMPTY_LOOP: ; ver si usamos 2 buffer, uno solo con puntero grando o ignoramos la segunda mitad
		CALL SPI_RX
		MOV CHAR_REG,SPI_IN_OUT_REG
		BUFFER_INSERT_CHAR SPI_RX_BUFFER_2, SPI_RX_BUFFER_POINTER_2
		DEC SPI_INC_TEMP
		BRNE SPI_SD_READ_BLOCK_EMPTY_LOOP
		
		CALL SPI_RX ;ignoro bloques CRC
		CALL SPI_RX

		CALL SPI_SD_DESELECT

		POP XH
		POP XL
		RET

SPI_SD_TX_BLOCK: ; SPI_SD_TX_BLOCK_INDEX_REG tiene que tener el indice del bloque y el puntero X el BUFFER a leer

		PUSH XL
		PUSH XH
		
		CALL SPI_SD_SELECT

	SPI_SD_TX_BLOCK_DIREC_LOOP: ; tengo que mandar el comando READ_SINGLE_BLOCK con argumento la direccion a empezar a leer
		LDI SPI_INC_TEMP,READ_SINGLE_BLOCK
		MOV SPI_SD_CMD_REG,SPI_INC_TEMP
		MOV SPI_SD_CMD_ARG_REG_1,ZERO_REG ;mando la direccion desplazada 9 bits a izquierda
		MOV SPI_SD_CMD_ARG_REG_2,ZERO_REG
		LSL SPI_SD_RX_BLOCK_INDEX_REG 
		MOV SPI_SD_CMD_ARG_REG_3,SPI_SD_RX_BLOCK_INDEX_REG
		MOV SPI_SD_CMD_ARG_REG_4,ZERO_REG
		CALL SPI_SD_TX_CMD

		CPI SPI_SD_CMD_RSP_REG,SD_CMD_RSP_NOT_IDLE
		BRNE SPI_SD_TX_BLOCK_DIREC_LOOP

		LDI SPI_IN_OUT_REG,SD_CMD_RSP_START
		CALL SPI_TX ;mando bloque inicial

		LDI SPI_INC_TEMP, 0xFF

	SPI_SD_TX_BLOCK_LOOP_1:
		LD SPI_IN_OUT_REG,X+
		CALL SPI_TX
		DEC SPI_INC_TEMP
		BRNE SPI_SD_TX_BLOCK_LOOP_1

		LDI SPI_INC_TEMP, 0xFF

	SPI_SD_TX_BLOCK_LOOP_2:
		LD SPI_IN_OUT_REG,X+
		CALL SPI_TX
		DEC SPI_INC_TEMP
		BRNE SPI_SD_TX_BLOCK_LOOP_2

		LDI SPI_IN_OUT_REG,0xFF ;escribo 2 CRC truchos
		CALL SPI_TX
		LDI SPI_IN_OUT_REG,0xFF
		CALL SPI_TX 

		CALL SPI_RX
		ANDI SPI_IN_OUT_REG,SD_CMD_RSP_WRITE_OK_MASK
		CPI SPI_IN_OUT_REG,SD_CMD_RSP_WRITE_OK
		BRNE SPI_SD_TX_BLOCK_ERROR

	SPI_SD_TX_BLOCK_WAIT_END:
		CALL SPI_RX
		CPI SPI_IN_OUT_REG,SD_CMD_RSP_WAIT
		BRNE SPI_SD_TX_BLOCK_WAIT_END

		;aca poray hay que revisar que la tarjeta no este ocupada

	SPI_SD_TX_BLOCK_END:
		CALL SPI_SD_DESELECT

		POP XH
		POP XL
		RET

	SPI_SD_TX_BLOCK_ERROR:
		;TODO
		RJMP SPI_SD_TX_BLOCK_END
		




	