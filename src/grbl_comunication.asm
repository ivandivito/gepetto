.INCLUDE "gepetto.inc"

.INCLUDE "buffer.inc"

.EQU SOFT_UART_SUBR = 34 ; Fclk / (4 * Pre * Baud rate) - 1

.DSEG
GRBL_BUFFER: .BYTE BUFFER_SIZE
GRBL_BUFFER_POINTER: .BYTE 1

.CSEG

;Constantes

GRBL_OK:
.DB "ok", 0x00

GRBL_ERROR:
.DB "error", 0x00

;Subrutina para inicializar el soft UART para conectar con GRBL
.DEF TEMP = R16

GRBL_COM_INIT:
	
	BUFFER_CLEAR GRBL_BUFFER_POINTER
	
	LDI TEMP, SOFT_UART_SUBR
	STS SUBR, TEMP

	CALL SOFT_UART_INIT
	
	RET
	
;Subrutina para enviar un caracter por USB
.DEF CHAR_REG = R16
	
GRBL_SEND_CHAR:
	STS SUODR, CHAR_REG
	CALL SOFT_UART_SEND_BYTE
	RET

;Subrutina para enviar una linea en memoria de datos. El string es apuntado por X y temina en '\n'
.DEF CHAR_REG = R16

GRBL_SEND_D_LINE:
	PUSH XL
	PUSH XH
	
	GRBL_SEND_D_STRING_LOOP:
		LD CHAR_REG, X+
		STS SUODR, CHAR_REG
		CALL SOFT_UART_SEND_BYTE
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
		STS SUODR, CHAR_REG
		CALL SOFT_UART_SEND_BYTE
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
	PUSH YL
	PUSH YH
	
	IN SREG_REG, SREG
	
	LDS R16, SUIDR
	
	BUFFER_INSERT_CHAR USB_BUFFER, USB_BUFFER_POINTER
	
	OUT SREG, SREG_REG
	
	POP YH
	POP YL
	POP R17
	POP R16
	POP SREG_REG
	RET
	