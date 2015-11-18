
.CSEG

;Subrutina para comparar el inicio de un string con uno en memoria de programa.El string a comparar es apuntado por X y el string de programa por Z
;En R16 se devuelve si es igual o no
.DEF RESULT = R16
.DEF TEMP_1 = R10
.DEF TEMP_2 = R11

STRING_COMPARE_P:
	
	PUSH ZL ;Guardar puntero Z
	PUSH ZH
	MOV YL, XL ;Utilizar puntero Y
	MOV YH, XH

	LDI RESULT, 0x01 ;Setear resultado verdadero

	STRING_P_COMPARE_LOOP:
	
		LPM TEMP_2, Z+ ;Cargar caracter de string de programa
		TST TEMP_2 ;Si es cero terminar
		BREQ STRING_P_COMPARE_BREAK

		LD TEMP_1, Y+ ;Cargar caracter de string de datos

		CP TEMP_1, TEMP_2 ;Comparar caracteres
		BREQ STRING_P_COMPARE_LOOP
		
		CLR RESULT ;Setear resultado falso

	STRING_P_COMPARE_BREAK:

	TST RESULT

	POP ZH ;Cargar puntero Z
	POP ZL

	RET 