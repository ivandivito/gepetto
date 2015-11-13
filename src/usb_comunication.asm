
.EQU UART_UBRR = 103 ; 9600

.EQU UART_CONNECTION_TIMEOUT = 16000 ; ciclos de timer1

.DSEG
USB_BUFFER: .BYTE BUFFER_SIZE
USB_BUFFER_POINTER: .BYTE 1
ULCTL: .BYTE 1 ;USB Last Connection Timestamp Low
ULCTH: .BYTE 1 ;USB Last Connection Timestamp high

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
USB_INTERRUPT:
	PUSH R16
	PUSH R17
	PUSH YL
	PUSH YH
	
	LDS R16, UDR0
	
	BUFFER_INSERT_CHAR USB_BUFFER, USB_BUFFER_POINTER
	
	;Tomar timestap
	LDS R16, TCNT1L
	LDS R17, TCNT1H
	
	;Guardar timestamp
	STS ULCTL ,R16
	STS ULCTH, R17
	
	POP YH
	POP YL
	POP R17
	POP R16
	RETI
	
;Subrutina para verificar si se desconecto el usb. Devuelve 1 en R16 si hay timeout, 0 sino.
	
.DEF TEMP_1 = R14
.DEF TEMP_2 = R15
.DEF TEMP_3 = R16
.DEF TEMP_4 = R17

.DEF RESULT = R16

USB_CHECK_TIMEOUT:
	
	;Tomar timestap
	LDS TEMP_1, TCNT1L
	LDS TEMP_2, TCNT1H
	
	CLI ;Operación atomica
	;Cargar ultima coneccion
	LDS TEMP_3, ULCTL
	LDS TEMP_4, ULCTH
	SEI ;Fin operación atomica
	
	;Restar
	SUB TEMP_1, TEMP_3
	SBC TEMP_2, TEMP_4
	
	;Si el tiempo actual es menor hubo overflow, devolver falso
	BRLO USB_CHECK_TIMEOUT_FALSE
		
		;Cargar timeout
		LDI TEMP_3, LOW(UART_CONNECTION_TIMEOUT)
		LDI TEMP_4, HIGH(UART_CONNECTION_TIMEOUT)
		
		;Comparar tiempo desde ultima coneccion
		CP TEMP_1, TEMP_3
		CPC TEMP_2, TEMP_4
		
		;Si es menor devolver falso
		BRLO USB_CHECK_TIMEOUT_FALSE
			
			LDI RESULT, 0x01
			
			RET
			
	USB_CHECK_TIMEOUT_FALSE:
		
		CLR RESULT
	
	RET
