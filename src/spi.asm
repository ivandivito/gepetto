
.EQU SPI_DDR = DDRB
.EQU SPI_PORT = PORTB
.EQU MOSI_PIN = 3
.EQU MISO_PIN = 4
.EQU SS_PIN = 2
.EQU SCK_PIN = 5

.CSEG

;inicializacion de los pines y circuito spi
.DEF TEMP = R16
SPI_INIT:

	;mosi, clk y ss como salida y miso como entrada
	SBI SPI_DDR,MOSI_PIN
	SBI SPI_DDR,SCK_PIN
	SBI SPI_DDR,SS_PIN
	CBI SPI_DDR,MISO_PIN
	
	LDI TEMP,((1<<SPE)|(1<<MSTR)|(1<<SPR1)) ;SPI sin interrupciones, habilitado en master, envio primero MSB, clk/64
	OUT SPCR,TEMP

	OUT SPSR,ZERO_REG
	
	RET

;transmicion de byte por spi
.DEF TEMP = R16
.DEF SPI_IN_OUT_REG = R16
SPI_TX:

	OUT SPDR,SPI_IN_OUT_REG

	SPI_TX_WAIT:
	IN TEMP,SPSR
	ANDI TEMP,(1<<SPIF) ; reviso flag de completa
	BREQ SPI_TX_WAIT

	IN SPI_IN_OUT_REG,SPDR

	RET

;recepcion de byte por spi
.DEF SPI_IN_OUT_REG = R16
SPI_RX:
		
	LDI SPI_IN_OUT_REG,0xFF
	CALL SPI_TX
	
	RET
