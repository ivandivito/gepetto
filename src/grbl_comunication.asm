.INCLUDE "gepetto.inc"

.INCLUDE "buffer.inc"

.EQU RXD = 0
.EQU TXD = 1

.EQU UART_UBRR = 103 ; 9600

.DSEG
GRBL_BUFFER: .BYTE BUFFER_SIZE
GRBL_BUFFER_POINTER: .BYTE 1

.CSEG

;Constantes

GRBL_OK:
.DB "ok",'\n' , 0x00

GRBL_ERROR:
.DB "error", 0x00

GRBL_ALARM:
.DB "ALARM" , 0x00

GRBL_PAUSE_CMD:
.DB "!",'\n' , 0x00

GRBL_CONTINUE_CMD:
.DB "~",'\n' , 0x00

GRBL_HOME_CMD:
.DB "$H",'\n' , 0x00

GRBL_CANCEL_CMD:
.DB 0x18,'\n' , 0x00 ; caracter CAN (cancelar) control - X


;Subrutina para inicializar el soft UART para conectar con GRBL
.DEF TEMP = R16

GRBL_COM_INIT:
	
	BUFFER_CLEAR GRBL_BUFFER_POINTER

	;Configurar pines

	CBI DDRD,RXD
	SBI DDRD,TXD
	
	;Setear baud rate
	LDI TEMP, LOW(UART_UBRR)
	STS UBRR0L, TEMP
	LDI TEMP, HIGH(UART_UBRR)
	STS UBRR0H, TEMP
	
	STS UCSR0A, ZERO_REG

	;Configurar 8 bits de transferencia, sin paridad, 1 stop bit
	LDI TEMP, (1<<UCSZ01)| (1<<UCSZ00)
	STS UCSR0C, TEMP

	;Habilitar envio, recepcion e interrupciones
	LDI TEMP, (1<<RXCIE0)|(1<<RXEN0)|(1<<TXEN0)
	STS UCSR0B, TEMP
	
	RET
	
;Subrutina para enviar un caracter por USB
.DEF CHAR_REG = R16
.DEF TEMP = R17
	
GRBL_SEND_CHAR:

	;Esperar a que el buffer este listo
	LDS TEMP, UCSR0A
	ANDI TEMP, (1<<UDRE0)
	BREQ USB_SEND_CHAR
	
	STS UDR0, CHAR_REG

	RET

;Subrutina para enviar una linea en memoria de datos. El string es apuntado por X y temina en '\n'
.DEF CHAR_REG = R16

GRBL_SEND_D_LINE:

	PUSH XL
	PUSH XH
	
	GRBL_SEND_D_STRING_LOOP:
		LD CHAR_REG, X+
		RCALL GRBL_SEND_CHAR
		CPI CHAR_REG, '\n'
		BRNE GRBL_SEND_D_STRING_LOOP
	
	POP XH
	POP XL
	
	RET
	
;Subrutina para enviar una linea en memoria de programa. El string es apuntado por Z y temina en '\n'
.DEF CHAR_REG = R16

GRBL_SEND_P_LINE:
	
	PUSH ZL
	PUSH ZH
	
	GRBL_SEND_P_STRING_LOOP:
		LPM CHAR_REG, Z+
		RCALL GRBL_SEND_CHAR
		CPI CHAR_REG, '\n'
		BRNE GRBL_SEND_P_STRING_LOOP
	
	POP ZH
	POP ZL
	
	RET

;Interrupcion de arribo de un dato. Se guardan en stack todos los registros usados por la macro BUFFER_INSERT_CHAR

.DEF SREG_REG = R10

GRBL_INTERRUPT:

	PUSH SREG_REG
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH YL
	PUSH YH
	
	IN SREG_REG, SREG

	LDS R16, UDR0
	BUFFER_INSERT_CHAR GRBL_BUFFER, GRBL_BUFFER_POINTER

	OUT SREG, SREG_REG
	
	POP YH
	POP YL
	POP R19
	POP R18
	POP R17
	POP R16
	POP SREG_REG
	RETI
	