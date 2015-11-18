
.EQU RXD = 0
.EQU TXD = 1

.EQU UART_UBRR = 103 ; 9600

.EQU UART_CONNECTION_TIMEOUT = 16000 ; ciclos de timer1

.DSEG
USB_BUFFER: .BYTE BUFFER_SIZE
USB_BUFFER_POINTER: .BYTE 1
ULCT: .BYTE 4 ;USB Last Connection Timestamp

.CSEG

;Constantes
USB_TICK:
.DB "TICK\n", 0x00

;Subrutina para inicializar el UART para conectar el USB
.DEF  TEMP = R16

USB_INIT:

	BUFFER_CLEAR USB_BUFFER_POINTER

	;Configurar pines

	CBI DDRD,RXD
	SBI DDRD,TXD
	
	;Setear baud rate
	LDI TEMP, LOW(UART_UBRR)
	STS UBRR0L, TEMP
	LDI TEMP, HIGH(UART_UBRR)
	STS UBRR0H, TEMP
	
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
	
USB_SEND_CHAR:
	;Esperar a que el buffer este listo
	LDS TEMP, UCSR0A
	ANDI TEMP, (1<<UDRE0)
	BREQ USB_SEND_CHAR
	
	STS UDR0, CHAR_REG
	
	RET
	
;Subrutina para enviar una linea en memoria de datos. El string es apuntado por X y temina en '\n'
.DEF CHAR_REG = R16

USB_SEND_D_LINE:
	PUSH XL
	PUSH XH
	
	USB_SEND_D_STRING_LOOP:
		LD CHAR_REG, X+
		RCALL USB_SEND_CHAR
		CPI CHAR_REG, '\n'
		BRNE USB_SEND_D_STRING_LOOP
	
	POP XH
	POP XL
	
	RET
	
;Subrutina para enviar una linea en memoria de programa. El string es apuntado por Z y temina en '\n'
.DEF CHAR_REG = R16

USB_SEND_P_LINE:
	PUSH ZL
	PUSH ZH
	
	USB_SEND_P_STRING_LOOP:
		LPM CHAR_REG, Z+
		RCALL USB_SEND_CHAR
		CPI CHAR_REG, '\n'
		BRNE USB_SEND_P_STRING_LOOP
	
	POP ZH
	POP ZL
	
	RET
	
;Interrupcion de arribo de un dato. Se guardan en stack todos los registros usados por la macro BUFFER_INSERT_CHAR

.DEF SREG_REG = R10

USB_INTERRUPT:
	PUSH SREG_REG
	PUSH R16
	PUSH R17
	PUSH R18
	PUSH R19
	PUSH YL
	PUSH YH
	
	IN SREG_REG, SREG
	
	LDS R16, UDR0
	
	BUFFER_INSERT_CHAR USB_BUFFER, USB_BUFFER_POINTER
	
	;Tomar timestap
	LDS R16, TCNT1L
	LDS R17, TCNT1H
	LDS R18, ETCNT1L
	LDS R19, ETCNT1H
	
	;Guardar timestamp

	STS ULCT , R16
	STS ULCT+1, R17
	STS ULCT+2, R18
	STS ULCT+3, R19

	SBI DDRC,2
	CBI PORTC,2

	LDI R16,'Z'
	CALL USB_SEND_CHAR
	
	OUT SREG, SREG_REG
	
	POP YH
	POP YL
	POP R19
	POP R18
	POP R17
	POP R16
	POP SREG_REG
	RETI
	
;Subrutina para verificar si se desconecto el usb. Devuelve 1 en R16 si hay timeout, 0 sino.
	
.DEF A1 = R12
.DEF A2 = R13
.DEF A3 = R14
.DEF A4 = R15
.DEF B1 = R16
.DEF B2 = R17
.DEF B3 = R18
.DEF B4 = R19

.DEF RESULT = R16

USB_CHECK_TIMEOUT:
	PUSH B3
	PUSH B4
	
	CLI ;Operación atomica
	
	;Tomar timestap
	LDS A1, TCNT1L
	LDS A2, TCNT1H
	LDS A3, ETCNT1L
	LDS A4, ETCNT1H
	
	;Cargar ultima coneccion
	LDS B1, ULCT
	LDS B2, ULCT+1
	LDS B3, ULCT+2
	LDS B4, ULCT+3
	
	SEI ;Fin operación atomica
	
	;Restar
	SUB A1, B1
	SBC A2, B2
	SBC A3, B3
	SBC A4, B4
	
	;Si el tiempo actual es menor hubo overflow, devolver falso
	BRLO USB_CHECK_TIMEOUT_FALSE
		
		;Cargar timeout
		LDI B1, LOW(UART_CONNECTION_TIMEOUT)
		LDI B2, BYTE2(UART_CONNECTION_TIMEOUT)
		LDI B3, BYTE3(UART_CONNECTION_TIMEOUT)
		LDI B4, BYTE4(UART_CONNECTION_TIMEOUT)
		
		;Comparar tiempo desde ultima coneccion
		CP A1, B1
		CPC A2, B2
		CPC A3, B3
		CPC A4, B4
		
		;Si es menor devolver falso
		BRLO USB_CHECK_TIMEOUT_FALSE
			
			LDI RESULT, 0x01
			
			RJMP USB_CHECK_TIMEOUT_END
			
	USB_CHECK_TIMEOUT_FALSE:
		
		CLR RESULT
	
	USB_CHECK_TIMEOUT_END:
	POP B4
	POP B3
	
	RET
