

.DEF TEMP = R16

.CSEG

UI_TEXT: .DB "Gepetto", 0


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
	
	LDI TEMP, 0x0C ;Display on, cursor off, blink off
	CALL LCD_SEND_BYTE
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x01 ;Display clear
	CALL LCD_SEND_BYTE
	
	RCALL UI_WAIT_LCD_READY
	
	LDI TEMP, 0x06 ;Increment, No display shift
	CALL LCD_SEND_BYTE
	

	LDI ZL, LOW(UI_TEXT<<1)
	LDI ZH, HIGH(UI_TEXT<<1)
	CALL UI_WRITE_P_STRING

	RET


;Subrutina que espera a que el LCD este listo

.DEF READ_REG = R16
	
UI_WAIT_LCD_READY:
	
	CBI LCD_PORT, LCD_RS ;Leer de registro de intrucciones
	
	CALL LCD_READ_BYTE
	ANDI READ_REG, (1<<LCD_BF) ;Verificar el Busy Flag
	BRNE UI_WAIT_LCD_READY

	RET


;Subrutina para enviar un caracter al LCD	

.DEF CHAR_REG = R16
	
UI_WRITE_CHAR:
	
	PUSH CHAR_REG
	RCALL UI_WAIT_LCD_READY ;Esperar a que este listo
	POP CHAR_REG
	
	SBI LCD_PORT, LCD_RS ;Escribir en registro de datos
	
	CALL LCD_SEND_BYTE
	
	RET

;Subrutina para enviar un String al LCD. El string es apuntado por Z y termina en 0

.DEF CHAR_REG = R16

UI_WRITE_P_STRING:
	PUSH ZL
	PUSH ZH

	UI_WRITE_P_STRING_LOOP:
		LPM CHAR_REG, Z+
		TST CHAR_REG
		BREQ UI_WRITE_P_STRING_LOOP_BREAK

		RCALL UI_WRITE_CHAR
		
		RJMP UI_WRITE_P_STRING

	UI_WRITE_P_STRING_LOOP_BREAK:

	POP ZH
	POP ZL
	RET
	