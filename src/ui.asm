

.DEF TEMP = R16

.CSEG

UI_INIT:
	
	;Delay 20ms
	LDI R16, 150
	LDI R17, 160
	LDI R18, 2
	CALL DELAY_3_REG
	
	CALL LCD_INIT
	
	RCALL UI_WAIT_LCD_READY
	
	CBI LCD_PORT, LCD_RS ;Enviar a registro de intrucciones
	
	LDI TEMP, 0x0F ;Display on, cursor on, blink on
	CALL LCD_SEND_BYTE
	
	RET

UI_FULL_INIT:
	
	CALL LCD_INIT
	
	;Delay 15ms
	LDI R16, 177
	LDI R17, 56
	LDI R18, 2
	CALL DELAY_3_REG
	
	CBI LCD_PORT, LCD_RS ;Enviar a registro de intrucciones

	LDI TEMP, 0x30
	CALL LCD_SEND_NIBBLE ;Interfaz 8bit
	
	;Delay 4.1ms
	LDI R16, 51
	LDI R17, 86
	CALL DELAY_2_REG
	
	LDI TEMP, 0x30
	CALL LCD_SEND_NIBBLE ;Interfaz 8bit
	
	;Delay 100us
	LDI R16, 21
	LDI R17, 3
	CALL DELAY_2_REG
	
	LDI TEMP, 0x30
	CALL LCD_SEND_NIBBLE ;Interfaz 8bit
	
	;Verificar delay entre instrucciones
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x20
	CALL LCD_SEND_NIBBLE ;Interfaz 4bit
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x28 ;Interfaz 4bit, 2 lineas, font 5x8
	CALL LCD_SEND_BYTE
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x0F ;Display on, cursor on, blink on
	CALL LCD_SEND_BYTE
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x01 ;Display clear
	CALL LCD_SEND_BYTE
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x06 ;Increment, No display shift
	CALL LCD_SEND_BYTE
	

	LDI R16, 'I'
	CALL UI_WRITE_CHAR

	LDI R16, 'V'
	CALL UI_WRITE_CHAR

	LDI R16, 'A'
	CALL UI_WRITE_CHAR

	LDI R16, 'N'
	CALL UI_WRITE_CHAR

	LDI R16, ' '
	CALL UI_WRITE_CHAR

	LDI R16, 'P'
	CALL UI_WRITE_CHAR

	LDI R16, 'U'
	CALL UI_WRITE_CHAR

	LDI R16, 'T'
	CALL UI_WRITE_CHAR

	LDI R16, 'O'
	CALL UI_WRITE_CHAR


	RET


;Esperar a que el LCD este listo

.DEF READ_REG = R16
	
UI_WAIT_LCD_READY:
	
	CBI LCD_PORT, LCD_RS ;Leer de registro de intrucciones
	
	CALL LCD_READ_BYTE
	ANDI READ_REG, (1<<LCD_BF) ;Verificar el Busy Flag
	BRNE UI_WAIT_LCD_READY

	RET

	
	
.DEF CHAR_REG = R16
	
UI_WRITE_CHAR:
	
	PUSH CHAR_REG
	RCALL UI_WAIT_LCD_READY ;Esperar a que este listo
	POP CHAR_REG
	
	SBI LCD_PORT, LCD_RS ;Escribir en registro de datos
	
	CALL LCD_SEND_BYTE
	
	RET

	