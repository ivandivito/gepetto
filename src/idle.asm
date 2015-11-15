
.CSEG

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17

IDLE_RUN:
	
	;Procesar buffer GRBL
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER GRBL_BUFFER, GRBL_BUFFER_POINTER
	
	LD TEMP_1, Y
	
	CPI TEMP_1, '\n'
	BRNE IDLE_GRBL_CONTINUE
		
		RCALL IDLE_GRBL_PROCESS_LINE
	
	IDLE_GRBL_CONTINUE:
	
	;Si hay cambio de estado terminar
	LDS TEMP_1, CURRENT_STATE
	CPI TEMP_1, STATE_IDLE
	BRNE IDLE_END

	;Verificar connecci�n PC
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER USB_BUFFER, USB_BUFFER_POINTER
	
	LD TEMP_1, Y
	
	CPI TEMP_1, '\n'
	BRNE IDLE_USB_CONTINUE
	
		RCALL IDLE_USB_PROCESS_LINE
	
	IDLE_USB_CONTINUE:
	

	;Procesar botones
	.DEF GGR_REG = R11
	.DEF BUTTONS_REG = R10
	
	CALL BUTTONS_READ
	MOV BUTTONS_REG, TEMP_1
	
	LDS GGR_REG, GGR
	
	ANDI TEMP_1, (1<<BUTTONS_CHANGE) ; Si es el boton de cambiar
	BREQ IDLE_TEST_CONFIRM
	;MOV TEMP_2, GGR_REG
	;ANDI TEMP_2, (1<<UC) ;Si hay conneccion
	;BREQ IDLE_TEST_CONFIRM
	
		LDI TEMP_1, (1<<UIS)
		EOR GGR_REG, TEMP_1 ;Invertir estado de UI
		LDI TEMP_1, (1<<UII)
		OR GGR_REG, TEMP_1 ;Invalidar UI
		STS GGR, GGR_REG ;Guardar
		
		RJMP IDLE_BUTTONS_CONTINUE
	IDLE_TEST_CONFIRM:
	
	MOV TEMP_1, BUTTONS_REG
	ANDI TEMP_1, (1<<BUTTONS_CHANGE) ; Si es el boton de confirmar
	BREQ IDLE_BUTTONS_CONTINUE
		
		MOV TEMP_2, GGR_REG
		ANDI TEMP_2, (1<<UIS) ;Verificar estado
		BREQ IDLE_GO_TO_RUNNING
			/*
			LDI TEMP_2, STATE_CONNECTED ;Ir a STATE_CONNECTED
			STS CURRENT_STATE, R17
			LDI TEMP_1, (1<<UII)
			OR GGR_REG, TEMP_1 ;Invalidar UI
			STS GGR, GGR_REG ;Guardar
			*/
			RJMP IDLE_END
			
		IDLE_GO_TO_RUNNING:
		
		
	IDLE_BUTTONS_CONTINUE:
	
	;Actualizar UI
	LDS TEMP_1, GGR
	ANDI TEMP_1, (1<<UII)
	BREQ IDLE_END ;Verificar si la interfaz esta invalida
		RCALL IDLE_REFRESH_UI
	IDLE_END:

	RET


;Subrutina para procesar una linea de GRBL

IDLE_GRBL_PROCESS_LINE:
	
	;Comparar con error

	LDI XL, LOW(GRBL_BUFFER)
	LDI XH, HIGH(GRBL_BUFFER)

	LDI ZL, LOW(GRBL_ERROR<<1)
	LDI ZH, HIGH(GRBL_ERROR<<1)

	CALL STRING_COMPARE_P

	BREQ IDLE_GRBL_PROCESS_CONTINUE

		LDI TEMP_1, STATE_ERROR
		STS CURRENT_STATE, TEMP_1

	IDLE_GRBL_PROCESS_CONTINUE:

	BUFFER_CLEAR GRBL_BUFFER_POINTER

	RET


;Subrutina para procesar una linea de GRBL

.DEF TEMP = R16

IDLE_USB_PROCESS_LINE:
	
	;Comparar con tick

	LDI XL, LOW(USB_BUFFER)
	LDI XH, HIGH(USB_BUFFER)

	LDI ZL, LOW(USB_TICK<<1)
	LDI ZH, HIGH(USB_TICK<<1)

	CALL STRING_COMPARE_P

	BREQ IDLE_USB_PROCESS_CONTINUE
		
		;Setear flag de conecci�n
		LDS TEMP, GGR
		ORI TEMP, (1<<UC)
		STS GGR, TEMP

	IDLE_USB_PROCESS_CONTINUE:
	
	CALL USB_CHECK_TIMEOUT
	
	BREQ IDLE_USB_NO_TIMEOUT
		
		;Setear flag de conecci�n
		LDS TEMP, GGR
		ANDI TEMP, ~(1<<UC)
		STS GGR, TEMP
		
	IDLE_USB_NO_TIMEOUT:
	
	BUFFER_CLEAR USB_BUFFER_POINTER

	RET


;Subrutina para refrescar la interfaz a partir del estado del sistema

.DEF TEMP = R16
.DEF GGR_REG = R18

IDLE_REFRESH_UI:
	PUSH GGR_REG
	PUSH ZL
	PUSH ZH

	LDI ZL, LOW(CONSTANT_IDLE_TITLE<<1)
	LDI ZH, HIGH(CONSTANT_IDLE_TITLE<<1)
	CALL UI_WRITE_FIRST_LINE_P_STRING ;Escribir titulo

	LDS GGR_REG, GGR ;Cargar registro de flags

	MOV TEMP, GGR_REG
	ANDI TEMP, (1<<UIS) ;Verificar estado de interfaz
	BREQ IDLE_UI_RUNNING
		
		LDI ZL, LOW(CONSTANT_IDLE_CONNECT<<1)
		LDI ZH, HIGH(CONSTANT_IDLE_CONNECT<<1)
		CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea
		
		RJMP IDLE_UI_END
	IDLE_UI_RUNNING:

		LDI ZL, LOW(CONSTANT_IDLE_RUN<<1)
		LDI ZH, HIGH(CONSTANT_IDLE_RUN<<1)
		CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea
		
	IDLE_UI_END:

	ANDI GGR_REG, ~(1<<UII) ;Limpiar flag de invalido
	STS GGR, GGR_REG

	POP ZH
	POP ZL
	POP GGR_REG
	RET
