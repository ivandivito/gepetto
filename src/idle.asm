
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
	
		;Procesar linea de GRBL
	
	IDLE_GRBL_CONTINUE:
	
	;Verificar connección PC
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER USB_BUFFER, USB_BUFFER_POINTER
	
	LD TEMP_1, Y
	
	CPI TEMP_1, '\n'
	BRNE IDLE_USB_CONTINUE
	
		;Procesar linea de USB
	
	IDLE_USB_CONTINUE:
	
	;Procesar botones
	CALL BUTTONS_READ
	MOV R10, R16
	MOV R11, R16
	
	ANDI R16, (1<<BUTTONS_CHANGE) ; Si es el boton de cambiar
	BREQ IDLE_TEST_CONFIRM
	
		LDS R11, GGR
		LDI R16, (1<<UIS)
		EOR R11, R16 ;Invertir estado de UI
		STS GGR, R11 ;Guardar
		
		RJMP IDLE_BUTTONS_CONTINUE
	IDLE_TEST_CONFIRM:
		
		;Logica de cambio de estado
		
	IDLE_BUTTONS_CONTINUE:
	
	;Actualizar UI
	
	RET
