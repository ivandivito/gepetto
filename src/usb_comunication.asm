
.EQU UART_UBRR = 103 ; 9600

.DSEG
USB_BUFFER: .BYTE BUFFER_SIZE
USB_BUFFER_POINTER: .BYTE 1


.CSEG

;Constantes
USB_TICK:
.DB "TICK\n", 0x00

;Subrutina para inicializar el UART para conectar el USB
.DEF  TEMP = R16

USB_INIT:
	
	BUFFER_CLEAR USB_BUFFER_POINTER
	
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
	
;Subrutina para enviar una cadena de caracteres en memoria de datos. El string es apuntado por X y temina en cero
.DEF CHAR_REG = R16

USB_SEND_D_STRING:
	PUSH XL
	PUSH XH
	
	USB_SEND_D_STRING_LOOP:
		LD CHAR_REG, X+
		RCALL USB_SEND_CHAR
		TST CHAR_REG ;Analizar si cambiar a cadena terminada en \n
		BRNE USB_SEND_D_STRING_LOOP
	
	POP XH
	POP XL
	
	RET
	
;Subrutina para enviar una cadena de caracteres en memoria de programa. El string es apuntado por Z y temina en cero
.DEF CHAR_REG = R16

USB_SEND_P_STRING:
	PUSH ZL
	PUSH ZH
	
	USB_SEND_P_STRING_LOOP:
		LPM CHAR_REG, Z+
		RCALL USB_SEND_CHAR
		TST CHAR_REG ;Analizar si cambiar a cadena terminada en \n
		BRNE USB_SEND_P_STRING_LOOP
	
	POP ZH
	POP ZL
	
	RET
	
;Interrupcion de arribo de un dato. Se guardan en stack todos los registros usados por la macro BUFFER_INSERT_CHAR
USB_INTERRUPT:
	PUSH R16
	PUSH R17
	PUSH YL
	PUSH YH
	
	LDS R16, UDR0
	
	BUFFER_INSERT_CHAR USB_BUFFER, USB_BUFFER_POINTER
	
	POP YH
	POP YL
	POP R17
	POP R16
	RETI

