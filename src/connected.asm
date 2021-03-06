
.EQU HREAD = 0 ;Header Read
.EQU LCREAD = 1 ;Line Count Read

.DSEG
FTR: .BYTE 1 ; File Transfer Register (- - - - - - LCREAD HREAD)
LINE_COUNT: .BYTE 4 ; Cantidad de lineas
LINE_TRANSFERED: .BYTE 4 ; Lineas transferidas


.CSEG

CONNECTED_CLEAN:

	STS FTR, ZERO_REG
	STS LINE_COUNT, ZERO_REG
	STS LINE_COUNT + 1, ZERO_REG
	STS LINE_COUNT + 2, ZERO_REG
	STS LINE_COUNT + 3, ZERO_REG
	STS LINE_TRANSFERED, ZERO_REG
	STS LINE_TRANSFERED + 1, ZERO_REG
	STS LINE_TRANSFERED + 2, ZERO_REG
	STS LINE_TRANSFERED + 3, ZERO_REG
	RET

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF GGR_REG = R18

CONNECTED_RUN:
	
	;Procesar buffer GRBL

	;Si esta vacio el buffer continuar
	LDS TEMP_2, GRBL_BUFFER_POINTER
	TST TEMP_2
	BREQ CONNECTED_GRBL_CONTINUE
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER GRBL_BUFFER, GRBL_BUFFER_POINTER
	
	LD TEMP_1, -Y
	
	CPI TEMP_1, '\n'
	BRNE CONNECTED_GRBL_CONTINUE
		
		RCALL CONNECTED_GRBL_PROCESS_LINE
	
	CONNECTED_GRBL_CONTINUE:
	


	;A definir
	/*
	;Verificar si hay timeout
	CALL USB_CHECK_TIMEOUT

	BREQ CONNECTED_USB_NO_TIMEOUT
		
		;Setear flag de conección
		LDS GGR_REG, GGR
		MOV TEMP, GGR_REG
		ANDI TEMP, ~(1<<UC)
		STS GGR, TEMP
		
		;Ir a IDLE
		LDI TEMP, STATE_IDLE
		STS CURRENT_STATE, TEMP

		ORI GGR_REG, (1<<UII) ;Invalidar UI
		STS GGR, GGR_REG ;Guardar
		
	CONNECTED_USB_NO_TIMEOUT:

	;Si hay cambio de estado terminar
	LDS TEMP_1, CURRENT_STATE
	CPI TEMP_1, STATE_CONNECTED
	BRNE CONNECTED_END
	*/
	;Procesar buffer USB (guardar o ejecutar)
	
	;Si esta vacio el buffer continuar
	LDS TEMP_2, USB_BUFFER_POINTER
	TST TEMP_2
	BREQ CONNECTED_USB_CONTINUE

	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER USB_BUFFER, USB_BUFFER_POINTER
	
	LD TEMP_1, -Y
	
	CPI TEMP_1, '\n'
	BRNE CONNECTED_USB_CONTINUE

		RCALL CONNECTED_USB_PROCESS_LINE
	
	CONNECTED_USB_CONTINUE:
	




	;Procesar botones
	
	CALL BUTTONS_READ
	
	ANDI TEMP_1, (1<<BUTTONS_SELECT) ; Si es el boton de CONFIRMAR
	BREQ CONNECTED_BUTTONS_CONTINUE
		
		LDS TEMP_1, GGR
		ANDI TEMP_1, ~(1<<CSS) ;Salir de modo transferir archivo
		STS GGR, TEMP_1

		CHANGE_STATE STATE_IDLE
		RJMP CONNECTED_END

	CONNECTED_BUTTONS_CONTINUE:
	
	;Actualizar UI
	LDS TEMP_1, GGR
	ANDI TEMP_1, (1<<UII)
	BREQ CONNECTED_END ;Verificar si la interfaz esta invalida
		RCALL CONNECTED_REFRESH_UI
	CONNECTED_END:
	
	RET

	
;Subrutina para procesar una linea de GRBL
;Que hacer cuando hay un error aca? enviar a la PC? Cancelar coneccion? Ir a STATE_ERROR?

.DEF TEMP_1 = R16
.DEF TEMP_2 = R17

CONNECTED_GRBL_PROCESS_LINE:
	
	LDS TEMP_1, GGR
	ANDI TEMP_1, (1<<CSS) ;Verificar sub estado
	BRNE CONNECTED_GRBL_SAVING
	
		PUSH XL
		PUSH XH
		
		LDI XL, LOW(GRBL_BUFFER)
		LDI XH, HIGH(GRBL_BUFFER)
		
		CALL USB_SEND_D_LINE
		
		POP XH
		POP XL
	
		RJMP CONNECTED_GRBL_PROCESS_LINE_END
	CONNECTED_GRBL_SAVING: 
	
		;A definir
	
	CONNECTED_GRBL_PROCESS_LINE_END:
	
	BUFFER_CLEAR GRBL_BUFFER_POINTER

	RET
	
;Subrutina para procesar una linea de GRBL

COMMAND_SAVE_MODE: .DB "$save", '\n', 0
COMMAND_DELETE: .DB "$delete", '\n', 0

.DEF TEMP = R16

CONNECTED_USB_PROCESS_LINE:
	
	LDS TEMP, GGR

	ANDI TEMP, (1<<CSS) ;Verificar sub estado
	BRNE CONNECTED_USB_SAVING
		
		RCALL CONNECTED_USB_BYPASS

		RJMP CONNECTED_USB_PROCESS_LINE_END
	CONNECTED_USB_SAVING: 
		
		RCALL CONNECTED_USB_SAVE_LINE

	CONNECTED_USB_PROCESS_LINE_END:
	
	BUFFER_CLEAR USB_BUFFER_POINTER

	RET


.DEF TEMP = R16

CONNECTED_USB_BYPASS:
	PUSH XL
	PUSH XH
	PUSH ZL
	PUSH ZH

	LDI XL, LOW(USB_BUFFER)
	LDI XH, HIGH(USB_BUFFER)

	LDI ZL, LOW(COMMAND_SAVE_MODE<<1)
	LDI ZH, HIGH(COMMAND_SAVE_MODE<<1)

	CALL STRING_COMPARE_P ;Comparar con instruccion de guardar

	BREQ CONNECTED_USB_TST_DELETE

		LDS TEMP, GGR
		ORI TEMP, (1<<CSS) ;Pasar a modo transferir archivo
		STS GGR, TEMP

		CALL SD_END_OP ; Reiniciar SD

		CALL CONNECTED_CLEAN

		LDI ZL, LOW(FILE_TRANSFER_ACKNOWLEDGE<<1)
		LDI ZH, HIGH(FILE_TRANSFER_ACKNOWLEDGE<<1)

		CALL USB_SEND_P_LINE ;Comunicar ok

		RJMP CONNECTED_USB_SEND_LINE_CONTINUE

	CONNECTED_USB_TST_DELETE:

		LDI ZL, LOW(COMMAND_DELETE<<1)
		LDI ZH, HIGH(COMMAND_DELETE<<1)

		CALL STRING_COMPARE_P ;Comparar con instruccion de borrar

		BREQ CONNECTED_USB_SEND_LINE

		CALL CONNECTED_DELETE_FILE

		RJMP CONNECTED_USB_SEND_LINE_CONTINUE
		

	CONNECTED_USB_SEND_LINE: ;Reenviar linea a GRBL
			
		LDI XL, LOW(USB_BUFFER)
		LDI XH, HIGH(USB_BUFFER)
			
		CALL GRBL_SEND_D_LINE

	CONNECTED_USB_SEND_LINE_CONTINUE:

	POP ZH
	POP ZL
	POP XH
	POP XL
	RET




.DEF A1 = R3
.DEF A2 = R4
.DEF A3 = R5
.DEF A4 = R6
.DEF B1 = R11
.DEF B2 = R12
.DEF B3 = R13
.DEF B4 = R14
.DEF TEMP_1 = R16
.DEF TEMP_2 = R17
.DEF FTR_REG = R18

FILE_TRANSFER_ERROR: .DB "error: file transfer", '\n', 0
FILE_TRANSFER_ACKNOWLEDGE: .DB "ack", '\n', 0

CONNECTED_USB_SAVE_LINE:
	PUSH XL
	PUSH XH
	PUSH ZL
	PUSH ZH
	PUSH FTR_REG

	LDS FTR_REG, FTR

	MOV TEMP_1, FTR_REG
	ANDI TEMP_1, (1<<HREAD) ;Verificar si se leyo el encabezado
	BREQ CONNECTED_USB_SAVE_LINE_READ_HEADER

	MOV TEMP_1, FTR_REG
	ANDI TEMP_1, (1<<LCREAD) ;Verificar si se leyo la cantidad de lineas
	BREQ CONNECTED_USB_SAVE_LINE_READ_LINE_COUNT

	RJMP CONNECTED_USB_SAVE_LINE_READ_LINE
	
	CONNECTED_USB_SAVE_LINE_READ_HEADER:
		
		LDI XL, LOW(USB_BUFFER)
		LDI XH, HIGH(USB_BUFFER)

		LDI ZL, LOW(FILE_HEADER<<1)
		LDI ZH, HIGH(FILE_HEADER<<1)

		CALL STRING_COMPARE_P ;Comparar con el encabezado
		BREQ CONNECTED_USB_SAVE_ERROR_HEADER

			MOV TEMP_1, FTR_REG
			ORI TEMP_1, (1<<HREAD) ;Marcar encabezado como leido
			STS FTR, TEMP_1

			LDI XL, LOW(USB_BUFFER)
			LDI XH, HIGH(USB_BUFFER)

			CALL SD_TX_LINE

			LDI ZL, LOW(FILE_TRANSFER_ACKNOWLEDGE<<1)
			LDI ZH, HIGH(FILE_TRANSFER_ACKNOWLEDGE<<1)

			CALL USB_SEND_P_LINE ;Comunicar ok

			RJMP CONNECTED_USB_SAVE_LINE_END
		CONNECTED_USB_SAVE_ERROR_HEADER:
			
			LDI ZL, LOW(FILE_TRANSFER_ERROR<<1)
			LDI ZH, HIGH(FILE_TRANSFER_ERROR<<1)

			CALL USB_SEND_P_LINE ;Comunicar error

			;Analizar si saltar a estado de error o salir de subestado de guardar archivo
			LDS TEMP_1, GGR
			ANDI TEMP_1, ~(1<<CSS) ;Salir de modo transferir archivo
			STS GGR, TEMP_1

			RJMP CONNECTED_USB_SAVE_LINE_END


	CONNECTED_USB_SAVE_LINE_READ_LINE_COUNT:
		
		LDI XL, LOW(USB_BUFFER)
		LDI XH, HIGH(USB_BUFFER)

		LDS R21, USB_BUFFER_POINTER

		CALL PARSE_U32_FROM_LINE

		CPI R16, 0xFF ;Comparar con mensaje de error
		BREQ CONNECTED_USB_SAVE_LINE_READ_LINE_COUNT_ERROR
			
			;Guardar numero parseado
			STS LINE_COUNT, R2
			STS LINE_COUNT+1, R3
			STS LINE_COUNT+2, R4
			STS LINE_COUNT+3, R5
			
			MOV TEMP_1, FTR_REG
			ORI TEMP_1, (1<<LCREAD) ;Marcar cantidad de lineas como leido
			STS FTR, TEMP_1

			;Guardar linea en SD
			LDI XL, LOW(USB_BUFFER)
			LDI XH, HIGH(USB_BUFFER)

			CALL SD_TX_LINE

			LDI ZL, LOW(FILE_TRANSFER_ACKNOWLEDGE<<1)
			LDI ZH, HIGH(FILE_TRANSFER_ACKNOWLEDGE<<1)

			CALL USB_SEND_P_LINE ;Comunicar ok

			RJMP CONNECTED_USB_SAVE_LINE_END
		CONNECTED_USB_SAVE_LINE_READ_LINE_COUNT_ERROR:
			
			LDI ZL, LOW(FILE_TRANSFER_ERROR<<1)
			LDI ZH, HIGH(FILE_TRANSFER_ERROR<<1)

			CALL USB_SEND_P_LINE ;Comunicar error

			;Analizar si saltar a estado de error o salir de subestado de guardar archivo
			LDS TEMP_1, GGR
			ANDI TEMP_1, ~(1<<CSS) ;Salir de modo transferir archivo
			STS GGR, TEMP_1

			RJMP CONNECTED_USB_SAVE_LINE_END


	CONNECTED_USB_SAVE_LINE_READ_LINE:
		
		LDI XL, LOW(USB_BUFFER)
		LDI XH, HIGH(USB_BUFFER)

		CALL SD_TX_LINE

		LDS A1, LINE_TRANSFERED
		LDS A2, LINE_TRANSFERED+1
		LDS A3, LINE_TRANSFERED+2
		LDS A4, LINE_TRANSFERED+3

		LDI TEMP_1, 1 ;Incrementar en 1 lineas transferidas
		ADD A1, TEMP_1
		ADC A2, ZERO_REG
		ADC A3, ZERO_REG
		ADC A4, ZERO_REG

		STS LINE_TRANSFERED, A1 ;Guardar lineas transferidas
		STS LINE_TRANSFERED+1, A2
		STS LINE_TRANSFERED+2, A3
		STS LINE_TRANSFERED+3, A4

		LDS B1, LINE_COUNT
		LDS B2, LINE_COUNT+1
		LDS B3, LINE_COUNT+2
		LDS B4, LINE_COUNT+3

		CP B1, A1 ;Comparar lineas transferidas con lineas totales
		CPC B2, A2
		CPC B3, A3
		CPC B4, A4
		BRNE CONNECTED_USB_SAVE_LINE_NOT_FINAL
			
			LDS TEMP_1, GGR
			ORI TEMP_1,(1<<SFF)
			ANDI TEMP_1, ~(1<<CSS) ;Salir de modo transferir archivo
			STS GGR, TEMP_1

			CALL SD_END_OP ; Reiniciar SD

		CONNECTED_USB_SAVE_LINE_NOT_FINAL:

		LDI ZL, LOW(FILE_TRANSFER_ACKNOWLEDGE<<1)
		LDI ZH, HIGH(FILE_TRANSFER_ACKNOWLEDGE<<1)

		CALL USB_SEND_P_LINE ;Comunicar ok


	CONNECTED_USB_SAVE_LINE_END:
	
	POP FTR_REG
	POP ZH
	POP ZL
	POP XH
	POP XL
	RET

;Subrutina para borrar el archivo en memoria
.DEF TEMP = R16
.DEF GGR_REG = R18
CONNECTED_DELETE_FILE:

	CALL SD_END_OP

	LDI ZL, LOW(FILE_HEADER_DELETED<<1)
	LDI ZH, HIGH(FILE_HEADER_DELETED<<1)
	
	CALL SD_TX_P_LINE

	LDS TEMP,GGR
	ANDI TEMP, ~(1<<SFF)
	STS GGR, TEMP

	CALL SD_END_OP

	LDI ZL, LOW(FILE_TRANSFER_ACKNOWLEDGE<<1)
	LDI ZH, HIGH(FILE_TRANSFER_ACKNOWLEDGE<<1)

	CALL USB_SEND_P_LINE ;Comunicar ok

	RET


;Subrutina para refrescar la interfaz a partir del estado del sistema

.DEF TEMP = R16
.DEF GGR_REG = R18


CONNECTED_REFRESH_UI:
	PUSH GGR_REG
	PUSH ZL
	PUSH ZH

	LDI ZL, LOW(CONSTANT_CONNECTED_TITLE<<1)
	LDI ZH, HIGH(CONSTANT_CONNECTED_TITLE<<1)
	CALL UI_WRITE_FIRST_LINE_P_STRING ;Escribir titulo

	LDI ZL, LOW(CONSTANT_CONNECTED_CANCEL<<1)
	LDI ZH, HIGH(CONSTANT_CONNECTED_CANCEL<<1)
	CALL UI_WRITE_SECOND_LINE_P_STRING ;Escribir primera linea

	LDS GGR_REG, GGR ;Cargar registro de flags
	ANDI GGR_REG, ~(1<<UII) ;Limpiar flag de invalido
	STS GGR, GGR_REG

	POP ZH
	POP ZL
	POP GGR_REG
	RET


