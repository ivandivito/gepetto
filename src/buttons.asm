.INCLUDE "m328pdef.inc"

.EQU BUTTONS_THRESHOLD = 400 ;Umbral de tiempo para reconocer un boton. El valor es BUTTONS_THRESHOLD*prescaler/f_clock

.EQU BUTTONS_DDR = DDRD
.EQU BUTTONS_PIN = PIND

.EQU BUTTONS_SELECT = 6
.EQU BUTTONS_CHANGE = 7

.EQU TIMER_PRESCALER = 0b00000101

.DEF ZERO_REG = R1

.DSEG
;Buttons active register
BAR: .BYTE 1
;Buttons timestamp register
BTRL: .BYTE 1
BTRH: .BYTE 1

.CSEG

.DEF TEMP = R16

BUTTONS_INIT:
	
	IN TEMP, BUTTONS_DDR
	ANDI TEMP, ~((1<<BUTTONS_SELECT) | (1<<BUTTONS_CHANGE)) ;Configurar como entrada los botones
	OUT BUTTONS_DDR, TEMP
	
	RET

	

.DEF TEMP = R16
	
BUTTONS_TIMER_INIT:
	
	OUT TCCR1A, ZERO_REG
	LDI TEMP, TIMER_PRESCALER ; Configurar prescaler y comenzar a contar
	OUT TCCR1B, TEMP
	
	RET

;Subrutina para leer botones, devuelve los botones activos en RESULT_REG

.DEF ACTIVE_REG = R10
.DEF TEMP_1 = R11
.DEF TEMP_2 = R12
.DEF TEMP_3 = R13
.DEF TEMP_4 = R14

.DEF RESULT_REG = R16
	
BUTTONS_READ:
	
	CLR RESULT_REG ;Limpiar resultado
	
	LDS ACTIVE_REG, BAR; Verifica si hay botones activos
	TST ACTIVE_REG
	BRNE BUTTONS_CHECK_TIME ;Si los hay verificar el tiempo que paso
	
		IN TEMP_1, BUTTONS_PIN ;Leer los pines de los botones
		ANDI TEMP_1, (1<<BUTTONS_SELECT) | (1<<BUTTONS_CHANGE) ;Enmascarar botones
		OUT BAR, TEMP_1 ;  Guardar como botones activos
		
		;Tomar timestap
		IN TEMP_1, TCNT1L
		IN TEMP_2, TCNT1H
		
		;Guardar timestamp
		STS TEMP_1, BTRL
		STS TEMP_2, BTRH
		
		RET
	
	BUTTONS_CHECK_TIME:
	
		;Tomar tiempo
		IN TEMP_1, TCNT1L
		IN TEMP_2, TCNT1H
		
		;Cargar timestamp
		LDS TEMP_3, BTRL
		LDS TEMP_4, BTRH
		
		;Restar tiempo y timestamp
		SUB TEMP_1, TEMP_3
		SBC TEMP_2, TEMP_4
		
		;Cargar umbral
		LDI TEMP_3, LOW(BUTTONS_THRESHOLD)
		LDI TEMP_4, HIGH(BUTTONS_THRESHOLD)
		
		;Comparar tiempo desde que se apreto el boton con el umbral
		CP TEMP_1, TEMP_3
		CPC TEMP_2, TEMP_4
		
		BRLO BUTTONS_TIME_NOT_COMPLETED:; Si es menor continuar
			
			STS BAR, ZERO_REG ; Limpiar botones activos
			
			IN TEMP_1, BUTTONS_PIN ;Leer pines
			AND ACTIVE_REG, TEMP_1 ;Condicionar con los leidos inicialmente
			MOV RESULT_REG, ACTIVE_REG ;Mover al registro de resultado
			
		BUTTONS_TIME_NOT_COMPLETED:
		RET
	