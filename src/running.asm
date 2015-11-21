.EQU SFR_HREAD = 0 ;Header Read
.EQU SFR_LCREAD = 1 ;Line Count Read

.DSEG
SFR: .BYTE 1 ; Save file Register (- - - - - - LCREAD HREAD)
SFL: .BYTE 4 ; Save file lenght (lines)

.CSEG
.DEF TEMP_1 = R16
RUNNING_INIT:
	STS SFR,ZERO_REG
	STS SFL,ZERO_REG
	STS SFL+1,ZERO_REG
	STS SFL+2,ZERO_REG
	STS SFL+3,ZERO_REG
	RET

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
RUNNING_RUN:
	
	;Procesar buffer GRBL

	;Si esta vacio el buffer continuar
	LDS TEMP_2, GRBL_BUFFER_POINTER
	TST TEMP_2
	BREQ RUNNING_GRBL_CONTINUE
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER GRBL_BUFFER, GRBL_BUFFER_POINTER
	
	LD TEMP_1, -Y
	
	CPI TEMP_1, '\n'
	BRNE RUNNING_GRBL_CONTINUE
		
		RCALL RUNNING_GRBL_PROCESS_LINE
	
	RUNNING_GRBL_CONTINUE:

	;Si hay cambio de estado terminar
	LDS TEMP_1, CURRENT_STATE
	CPI TEMP_1, STATE_RUNNING
	BRNE RUNNING_END

	;Procesar buffer SD

	LDS GGR_REG, GGR
	ANDI GGR_REG, (1<<GD)
	BRNE RUNNING_SD_CONTINUE

		RCALL RUNNING_SD_PROCESS_LINE

	RUNNING_SD_CONTINUE:

	;Si hay cambio de estado terminar
	LDS TEMP_1, CURRENT_STATE
	CPI TEMP_1, STATE_RUNNING
	BRNE RUNNING_END
	
	;procesar botones
	LDS GGR_REG, GGR

	RCALL RUNNING_PROCESS_BUTTONS

	LDS TEMP_1, CURRENT_STATE
	CPI TEMP_1, STATE_RUNNING
	BRNE RUNNING_END	

	RUNNING_BUTTONS_CONTINUE:

	;Actualizar UI
	LDS TEMP_1, GGR
	ANDI TEMP_1, (1<<UII)
	BREQ RUNNING_END ;Verificar si la interfaz esta invalida
		RCALL RUNNING_REFRESH_UI

	RUNNING_END:

	RET

;Subrutina para procesar una linea de GRBL

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
RUNNING_GRBL_PROCESS_LINE:

	PUSH XL
	PUSH XH
	PUSH GGR_REG

	

	LDI XL, LOW(GRBL_BUFFER)
	LDI XH, HIGH(GRBL_BUFFER)

	LDI ZL, LOW(GRBL_OK<<1)
	LDI ZH, HIGH(GRBL_OK<<1)

	CALL STRING_COMPARE_P
	BREQ RUNNING_GRBL_PROCESS_LINE_TST_ERROR
		
		;si llega un ok habilitar el envio de un dato
		LDS GGR_REG, GGR
		ANDI GGR_REG,~(1<<GD)
		STS GGR,GGR_REG
		RJMP RUNNING_GRBL_PROCESS_LINE_END

	RUNNING_GRBL_PROCESS_LINE_TST_ERROR:
	LDI ZL, LOW(GRBL_ERROR<<1)
	LDI ZH, HIGH(GRBL_ERROR<<1)

	CALL STRING_COMPARE_P
	BREQ RUNNING_GRBL_PROCESS_LINE_TST_ALARM

		;si llega un error saltar a error
		CHANGE_STATE STATE_ERROR
		RJMP RUNNING_GRBL_PROCESS_LINE_END

	RUNNING_GRBL_PROCESS_LINE_TST_ALARM:
	LDI ZL, LOW(GRBL_ALARM<<1)
	LDI ZH, HIGH(GRBL_ALARM<<1)

	CALL STRING_COMPARE_P
	BREQ RUNNING_GRBL_PROCESS_LINE_END

		;si llega un error saltar a error
		CHANGE_STATE STATE_ERROR
		RJMP RUNNING_GRBL_PROCESS_LINE_END
	
	RUNNING_GRBL_PROCESS_LINE_END:
	
	BUFFER_CLEAR GRBL_BUFFER_POINTER

	POP GGR_REG
	POP XH
	POP XL

	RET

;Subrutina para obtener y procesar una linea de la SD

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
.DEF SFR_REG = R19
.DEF SFL_REG_0 = R20 ;LS
.DEF SFL_REG_1 = R21
.DEF SFL_REG_2 = R22
.DEF SFL_REG_3 = R23 ;MS
RUNNING_SD_PROCESS_LINE:
	
	PUSH XL
	PUSH XH
	PUSH GGR_REG
	PUSH SFR_REG
	PUSH SFL_REG_0
	PUSH SFL_REG_1
	PUSH SFL_REG_2
	PUSH SFL_REG_3

	LDS GGR_REG, GGR
	LDS SFR_REG, SFR

	MOV TEMP_1, SFR_REG
	ANDI TEMP_1, (1<<SFR_HREAD) ;Verificar si se leyo el encabezado
	BREQ RUNNING_SD_PROCESS_LINE_READ_HEADER

	MOV TEMP_1, SFR_REG
	ANDI TEMP_1, (1<<SFR_LCREAD) ;Verificar si se leyo la cantidad de lineas
	BREQ RUNNING_SD_PROCESS_LINE_READ_LINE_COUNT

	RJMP RUNNING_SD_PROCESS_LINE_CONTINUE	

	RUNNING_SD_PROCESS_LINE_READ_HEADER:

	RCALL RUNNING_SD_READ_HEADER
	RJMP RUNNING_SD_PROCESS_LINE_END

	RUNNING_SD_PROCESS_LINE_READ_LINE_COUNT:

	RCALL RUNNING_SD_READ_LINE_COUNT
	RJMP RUNNING_SD_PROCESS_LINE_END

	RUNNING_SD_PROCESS_LINE_CONTINUE:

	LDS SFL_REG_0, SFL
	LDS SFL_REG_1, SFL + 1
	LDS SFL_REG_2, SFL + 2
	LDS SFL_REG_3, SFL + 3
	
	;si no faltan mas lineas ir a IDLE
	TST SFL_REG_3
	BRNE RUNNING_SD_PROCESS_LINE_SEND
	TST SFL_REG_2
	BRNE RUNNING_SD_PROCESS_LINE_SEND
	TST SFL_REG_1
	BRNE RUNNING_SD_PROCESS_LINE_SEND
	TST SFL_REG_0
	BRNE RUNNING_SD_PROCESS_LINE_SEND

	;si se termino el archivo pasar a ejecutar
	CALL DEBUG_USB
	CHANGE_STATE STATE_IDLE 

	RJMP RUNNING_SD_PROCESS_LINE_END
	
	RUNNING_SD_PROCESS_LINE_SEND:

	CALL SD_RX_LINE

	LDI XL, LOW(SD_BUFFER)
	LDI XH, HIGH(SD_BUFFER)
			
	CALL GRBL_SEND_D_LINE
	
	LDI TEMP_1, 1
	SUB SFL_REG_0, TEMP_1
	SBC SFL_REG_1, ZERO_REG
	SBC SFL_REG_2, ZERO_REG
	SBC SFL_REG_3, ZERO_REG

	LDS GGR_REG, GGR
	ORI GGR_REG,(1<<GD)
	STS GGR,GGR_REG

	RUNNING_SD_PROCESS_LINE_END_SAVE:

	STS SFL, SFL_REG_0
	STS SFL + 1, SFL_REG_1
	STS SFL + 2, SFL_REG_2
	STS SFL + 3 ,SFL_REG_3

	RUNNING_SD_PROCESS_LINE_END:
	
		
	
	POP SFL_REG_3
	POP SFL_REG_2
	POP SFL_REG_1
	POP SFL_REG_0
	POP SFR_REG
	POP GGR_REG
	POP XH
	POP XL

	RET

;subrutina que lee el encabezado del archivo

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF SFR_REG = R18
RUNNING_SD_READ_HEADER:

	PUSH SFR_REG

	LDS SFR_REG, SFR

	CALL SD_RX_LINE

	LDI XL, LOW(SD_BUFFER)
	LDI XH, HIGH(SD_BUFFER)

	LDI ZL, LOW(FILE_HEADER<<1)
	LDI ZH, HIGH(FILE_HEADER<<1)

	CALL STRING_COMPARE_P ;Comparar con el encabezado
	BREQ RUNNING_SD_READ_HEADER_ERROR

		MOV TEMP_1, SFR_REG
		ORI TEMP_1, (1<<SFR_HREAD) ;Marcar encabezado como leido
		STS SFR, TEMP_1

		RJMP RUNNING_SD_READ_HEADER_END
	RUNNING_SD_READ_HEADER_ERROR:
		
		CHANGE_STATE STATE_ERROR

	RUNNING_SD_READ_HEADER_END:
	POP SFR_REG

	RET

;subrutina que lee el largo del archivo

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF SFR_REG = R18
RUNNING_SD_READ_LINE_COUNT:

	PUSH XL
	PUSH XH
	PUSH SFR_REG

	LDS SFR_REG, SFR

	CALL SD_RX_LINE

	LDI XL, LOW(SD_BUFFER)
	LDI XH, HIGH(SD_BUFFER)

	CALL USB_SEND_D_LINE

	LDS R21, SD_BUFFER_POINTER

	CALL PARSE_U32_FROM_LINE

	CPI R16, 0xFF ;Comparar con mensaje de error
	BREQ RUNNING_SD_READ_LINE_COUNT_ERROR
			
		;Guardar numero parseado
		STS SFL, R2
		STS SFL+1, R3
		STS SFL+2, R4
		STS SFL+3, R5

		MOV TEMP_1, SFR_REG
		ORI TEMP_1, (1<<SFR_LCREAD) ;Marcar cantidad de lineas como leido
		STS SFR, TEMP_1

		RJMP RUNNING_SD_READ_LINE_COUNT_END

	RUNNING_SD_READ_LINE_COUNT_ERROR:
	
		CHANGE_STATE STATE_ERROR

	RUNNING_SD_READ_LINE_COUNT_END:
	POP SFR_REG
	POP XH
	POP XL

	RET

;subrutina que procesa los botones

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
.DEF BUTTON_REG = R19
RUNNING_PROCESS_BUTTONS:

	PUSH GGR_REG
	PUSH BUTTON_REG

	CALL BUTTONS_READ
	MOV BUTTON_REG, TEMP_1
	ANDI TEMP_1, (1<<BUTTONS_CHANGE) ; Si es el boton de CONFIRMAR
	BREQ RUNNING_PROCESS_BUTTONS_TST_SELECT
	
		
		LDS GGR_REG, GGR
		LDI TEMP_1, (1<<UIS)
		EOR GGR_REG, TEMP_1 ;Invertir estado de UI
		LDI TEMP_1, (1<<UII)
		OR GGR_REG, TEMP_1 ;Invalidar UI
		STS GGR, GGR_REG ;Guardar

		RJMP RUNNING_SD_PROCESS_BUTTONS_END

	RUNNING_PROCESS_BUTTONS_TST_SELECT:
	MOV TEMP_1, BUTTON_REG
	ANDI TEMP_1, (1<<BUTTONS_SELECT) ; Si es el boton de select
	BREQ RUNNING_SD_PROCESS_BUTTONS_END

		
		LDS GGR_REG, GGR
		MOV TEMP_2, GGR_REG
		ANDI TEMP_2, (1<<UIS) ;Verificar estado
		BREQ RUNNING_CANCEL

			LDS GGR_REG, GGR
			MOV TEMP_2, GGR_REG
			ANDI TEMP_2, (1<<RSS) ;Verificar estado
			BREQ RUNNING_PAUSE

				RCALL RUNNING_CONTINUE_GRBL

				LDS GGR_REG, GGR
				LDI TEMP_1, ~(1<<RSS)
				AND GGR_REG, TEMP_1 ;pasar a estado operando
				LDI TEMP_1, (1<<UII)
				OR GGR_REG, TEMP_1 ;Invalidar UI
				STS GGR, GGR_REG ;Guardar
			
				RJMP RUNNING_SD_PROCESS_BUTTONS_END

			RUNNING_PAUSE:
				RCALL RUNNING_PAUSE_GRBL

				LDS GGR_REG, GGR
				LDI TEMP_1, (1<<RSS)
				OR GGR_REG, TEMP_1 ;pasar a estado corriendo
				LDI TEMP_1, (1<<UII)
				OR GGR_REG, TEMP_1 ;Invalidar UI
				STS GGR, GGR_REG ;Guardar

				RJMP RUNNING_SD_PROCESS_BUTTONS_END
			
		RUNNING_CANCEL:
			RCALL RUNNING_CANCEL_GRBL

			CHANGE_STATE STATE_IDLE
	
	RUNNING_SD_PROCESS_BUTTONS_END:

	POP BUTTON_REG
	POP GGR_REG
	RET



	
;Subrutina para reanudar operacion de GRBL

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
RUNNING_CONTINUE_GRBL:
	
	PUSH ZL
	PUSH ZH

	LDI ZL, LOW(GRBL_CONTINUE_CMD<<1)
	LDI ZH, HIGH(GRBL_CONTINUE_CMD<<1)
			
	CALL GRBL_SEND_P_LINE

	POP ZH
	POP ZL

	RET

;Subrutina para pausar operacion de GRBL

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
RUNNING_PAUSE_GRBL:
	
	PUSH ZL
	PUSH ZH

	LDI ZL, LOW(GRBL_PAUSE_CMD<<1)
	LDI ZH, HIGH(GRBL_PAUSE_CMD<<1)
			
	CALL GRBL_SEND_P_LINE

	POP ZH
	POP ZL

	RET

;Subrutina para cancelar operacion de GRBL

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
RUNNING_CANCEL_GRBL:
	
	PUSH ZL
	PUSH ZH

	RCALL RUNNING_PAUSE_GRBL ; hace falta estar en estado de pausa para realizar un reinicio de GRBL �se pueden mandar las 2 instrucciones juntas?

	LDI ZL, LOW(GRBL_CANCEL_CMD<<1)
	LDI ZH, HIGH(GRBL_CANCEL_CMD<<1)
			
	CALL GRBL_SEND_P_LINE

	POP ZH
	POP ZL

	RET

;Subrutina para actualizar interfaz

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18
RUNNING_REFRESH_UI:
	
	;UIS 0 es pausar (RSS = 0)/reanudar (RSS = 1) y 1 es cancelar

	PUSH GGR_REG
	PUSH ZL
	PUSH ZH

	LDI ZL, LOW(CONSTANT_RUNNING_TITLE<<1)
	LDI ZH, HIGH(CONSTANT_RUNNING_TITLE<<1)
	
	CALL UI_WRITE_FIRST_LINE_P_STRING ;Escribir titulo

	LDS GGR_REG, GGR ;Cargar registro de flags

	MOV TEMP_1, GGR_REG
	ANDI TEMP_1, (1<<UIS) ;Verificar estado de interfaz
	BREQ RUNNING_UI_CANCEL
		
		MOV TEMP_1, GGR_REG
		ANDI TEMP_1, (1<<RSS) ;Verificar subestado de running
		BREQ RUNNING_UI_CONTINUE

			LDI ZL, LOW(CONSTANT_RUNNING_PAUSE<<1)
			LDI ZH, HIGH(CONSTANT_RUNNING_PAUSE<<1)
			CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea

			RJMP RUNNING_UI_END

		RUNNING_UI_CONTINUE:
			
			LDI ZL, LOW(CONSTANT_RUNNING_CONTINUE<<1)
			LDI ZH, HIGH(CONSTANT_RUNNING_CONTINUE<<1)
			CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea
		
			RJMP RUNNING_UI_END
	RUNNING_UI_CANCEL:

		LDI ZL, LOW(CONSTANT_RUNNING_CANCEL<<1)
		LDI ZH, HIGH(CONSTANT_RUNNING_CANCEL<<1)
		CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea
		
	RUNNING_UI_END:

	ANDI GGR_REG, ~(1<<UII) ;Limpiar flag de invalido
	STS GGR, GGR_REG

	POP ZH
	POP ZL
	POP GGR_REG
	RET

