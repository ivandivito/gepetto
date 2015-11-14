EQU LCD_DDR_E = DDRB
.EQU LCD_PORT_E = PORTB
.EQU LCD_DDR = DDRC
.EQU LCD_PORT = PORTC
.EQU LCD_PIN = PINC

.EQU LCD_E = 0 ;Enable
.EQU LCD_RW = 4 ;Read/Write
.EQU LCD_RS = 5 ;Register Select
.EQU LCD_DATA_MASK = 0x0F ;Data pins

.EQU LCD_BF = 7 ;Busy Flag

.DEF TEMP = R16

LCD_INIT:
	
	SBI LCD_DDR_E, LCD_E ;Setear enable como salida
	
	IN TEMP, LCD_DDR 
	ORI TEMP, (1<<LCD_RW)|(1<<LCD_RS) ;Setear RW y RS como salida
	ANDI TEMP, ~LCD_DATA_MASK ;Setear pines de datos en entrada
	OUT LCD_DDR, TEMP
	
	RET
	
LCD_ENABLE_PULSE:
	
	SBI LCD_PORT_E, LCD_E
	
	;Delay de ancho de pulso
	CALL LCD_DELAY_2MICRO
	
	CBI LCD_PORT_E, LCD_E ;Flanco descendente
	
	RET

;Subrutina para enviar un nibble al LCD (solo para inicialización). El nibble esta en el registro R16 en el nibble alto

.DEF BYTE_REG = R16
.DEF TEMP = R17
.DEF PORT_REG = R18
	
LCD_SEND_NIBBLE:	
	PUSH PORT_REG
	
	IN TEMP, LCD_DDR
	ORI TEMP, LCD_DATA_MASK
	OUT LCD_DDR, TEMP ;Configurar pines de datos como salida
	
	CBI LCD_PORT, LCD_RW ;Setear para escribir
	
	MOV TEMP, BYTE_REG
	SWAP TEMP
	ANDI TEMP, 0x0F ;Nibble alto
	
	IN PORT_REG, LCD_PORT ;Obtener valores previos del puerto
	ANDI PORT_REG, 0xF0 
	
	OR TEMP, PORT_REG
	
	OUT LCD_PORT, TEMP ;Escribir valores en el puerto
	
	RCALL LCD_ENABLE_PULSE ;Enviar flanco de enable
	
	IN TEMP, LCD_DDR
	ANDI TEMP, ~LCD_DATA_MASK
	OUT LCD_DDR, TEMP ;Configurar pines de datos como entrada
	
	POP PORT_REG
	RET
	
;Subrutina para enviar un byte al LCD. El byte esta en el registro R16

.DEF BYTE_REG = R16
.DEF TEMP = R17
.DEF PORT_REG = R18
	
LCD_SEND_BYTE:	
	PUSH PORT_REG
	
	IN TEMP, LCD_DDR
	ORI TEMP, LCD_DATA_MASK
	OUT LCD_DDR, TEMP ;Configurar pines de datos como salida
	
	CBI LCD_PORT, LCD_RW ;Setear para escribir
	
	MOV TEMP, BYTE_REG
	SWAP TEMP
	ANDI TEMP, 0x0F ;Nibble alto
	
	IN PORT_REG, LCD_PORT ;Obtener valores previos del puerto
	ANDI PORT_REG, 0xF0 
	
	OR TEMP, PORT_REG
	
	OUT LCD_PORT, TEMP ;Escribir valores en el puerto
	
	RCALL LCD_ENABLE_PULSE ;Enviar flanco de enable
	
	;Delay para no causar overhead en el LCD
	
	MOV TEMP, BYTE_REG
	ANDI TEMP, 0x0F ;Nibble bajo
	
	OR TEMP, PORT_REG
	
	OUT LCD_PORT, TEMP ;Escribir valores en el puerto
	
	RCALL LCD_ENABLE_PULSE ;Enviar flanco de enable
	
	IN TEMP, LCD_DDR
	ANDI TEMP, ~LCD_DATA_MASK
	OUT LCD_DDR, TEMP ;Configurar pines de datos como entrada
	
	POP PORT_REG
	RET

;Subrutina para leer un byte al LCD. El byte esta en el registro R16

.DEF BYTE_REG = R16
.DEF TEMP = R17
.DEF PORT_REG = R18
	
LCD_READ_BYTE:
	
	IN TEMP, LCD_DDR
	ANDI TEMP, ~LCD_DATA_MASK
	OUT LCD_DDR, TEMP ;Configurar pines de datos como entrada
	
	SBI LCD_PORT, LCD_RW ;Setear para leer
	
	SBI LCD_PORT_E, LCD_E
	
	;Delay para que el LCD escriba
	CALL LCD_DELAY_2MICRO
	
	IN TEMP, LCD_PIN ;Leer pines
	ANDI TEMP, LCD_DATA_MASK ;Obtener bits de datos
	SWAP TEMP ;Mover a bits altos
	MOV BYTE_REG, TEMP
	
	CBI LCD_PORT_E, LCD_E
	
	;Delay entre Nibbles
	CALL LCD_DELAY_2MICRO
	
	SBI LCD_PORT_E, LCD_E
	
	;Delay para que el LCD escriba
	CALL LCD_DELAY_2MICRO
	
	IN TEMP, LCD_PIN ;Leer pines
	ANDI TEMP, LCD_DATA_MASK ;Obtener bits de datos
	OR BYTE_REG, TEMP ;Agregar al resultados bits bajos
	
	CBI LCD_PORT_E, LCD_E
	
	RET
	
LCD_DELAY_2MICRO: ;100 us
	PUSH R18
	PUSH R19

	LDI R18, 21
	LDI R19, 3
	LCD_ENABLE_LOOP:
	DEC R18
	BRNE LCD_ENABLE_LOOP
	DEC R19
	BRNE LCD_ENABLE_LOOP


	POP R19
	POP R18
	RET