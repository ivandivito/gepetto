.EQU BUTTONS_THRESHOLD = 400 ;Umbral de tiempo para reconocer un boton. El valor es BUTTONS_THRESHOLD*prescaler/f_clock

.EQU BUTTONS_DDR = DDRD
.EQU BUTTONS_PORT = PORTD
.EQU BUTTONS_PIN = PIND

.EQU BUTTONS_SELECT = 6
.EQU BUTTONS_CHANGE = 7

.DSEG
;Buttons last measurement register
BLMR: .BYTE 1
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
	
	IN TEMP, BUTTONS_PORT
	ORI TEMP, (1<<BUTTONS_SELECT) | (1<<BUTTONS_CHANGE) ;Configurar resistencias de pull up
	OUT BUTTONS_PORT, TEMP

	RET


;Subrutina para leer botones, devuelve los botones activos en RESULT_REG

.DEF ACTIVE_REG = R10
.DEF TEMP_1 = R11
.DEF TEMP_2 = R12
.DEF TEMP_3 = R18
.DEF TEMP_4 = R19

.DEF RESULT_REG = R16
	
BUTTONS_READ:
	PUSH TEMP_3
	PUSH TEMP_4

	CLR RESULT_REG ;Limpiar resultado
	
	LDS ACTIVE_REG, BAR; Verifica si hay botones activos
	TST ACTIVE_REG
	BRNE BUTTONS_CHECK_TIME ;Si los hay verificar el tiempo que paso
		
		LDS TEMP_2, BLMR ;Obtener ultima medicion
		COM TEMP_2 ;Complementar

		IN TEMP_3, BUTTONS_PIN ;Leer los pines de los botones
		COM TEMP_3 ;Complementar (normal alto)
		ANDI TEMP_3, (1<<BUTTONS_SELECT) | (1<<BUTTONS_CHANGE) ;Enmascarar botones
		
		STS BLMR, TEMP_3 ;Guardar como ultima medicion

		AND TEMP_3, TEMP_2 ;Verifcar botones que no estaban apretados y ahora si
		
		BREQ BUTTONS_EXIT ;Si se da, guardar como activos
		
			STS BAR, TEMP_3 ;  Guardar como botones activos
			
			;Tomar timestap
			LDS TEMP_1, TCNT1L
			LDS TEMP_2, TCNT1H
			
			;Guardar timestamp
			STS BTRL ,TEMP_1
			STS BTRH, TEMP_2
		
		BUTTONS_EXIT:
		POP TEMP_4
		POP TEMP_3
		RET
	
	BUTTONS_CHECK_TIME:

		;Tomar tiempo
		LDS TEMP_1, TCNT1L
		LDS TEMP_2, TCNT1H
		
		
		CLI ;Operación atomica
		;Cargar timestamp
		LDS TEMP_3, BTRL
		LDS TEMP_4, BTRH
		
		SEI ;Fin operación atomica
		
		;Restar tiempo y timestamp
		SUB TEMP_1, TEMP_3
		SBC TEMP_2, TEMP_4
		
		;Cargar umbral
		LDI TEMP_3, LOW(BUTTONS_THRESHOLD)
		LDI TEMP_4, HIGH(BUTTONS_THRESHOLD)
		
		;Comparar tiempo desde que se apreto el boton con el umbral
		CP TEMP_1, TEMP_3
		CPC TEMP_2, TEMP_4
		
		BRLO BUTTONS_TIME_NOT_COMPLETED; Si es menor continuar
			
			STS BAR, ZERO_REG ; Limpiar botones activos
			
			IN TEMP_3, BUTTONS_PIN ;Leer los pines de los botones
			COM TEMP_3 ;Complementar (normal alto)
			ANDI TEMP_3, (1<<BUTTONS_SELECT) | (1<<BUTTONS_CHANGE) ;Enmascarar botones
		
			STS BLMR, TEMP_3 ;Guardar como ultima medicion

			AND ACTIVE_REG, TEMP_3 ;Condicionar con los leidos inicialmente
			MOV RESULT_REG, ACTIVE_REG ;Mover al registro de resultado
			
		BUTTONS_TIME_NOT_COMPLETED:
		POP TEMP_4
		POP TEMP_3
		RET
	