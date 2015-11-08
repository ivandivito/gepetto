.IFNDEF BUFFER_INC
.EQU BUFFER_INC = 0

.INCLUDE "gepetto.inc"

/*

Los buffers deben declararse de la siguiente manera:

.DSEG
BUFFER: .BYTE BUFFER_SIZE
BUFFER_POINTER: .BYTE 1


En este archivo se declaran macros para insertar caracteres en los buffers. Para usar las macros hay que llamarlos de la siguiente forma:

BUFFER_CLEAR BUFFER_POINTER
BUFFER_INSERT_CHAR BUFFER, BUFFER_POINTER
BUFFER_INSERT_D_STR BUFFER, BUFFER_POINTER
BUFFER_INSERT_P_STR BUFFER, BUFFER_POINTER

Las macros respetan el uso de los registros como si fueran subrutinas
*/

;Macro para apuntar al final del buffer
.DEF BUFFER_POINTER_REG = R17

.MACRO POINT_Y_TO_END_OF_BUFFER
	;Apuntar Y al buffer
	LDI YL, LOW(@0)
	LDI YH, HIGH(@0)
	;Cargar puntero de buffer
	LDS BUFFER_POINTER_REG, @1
	;Sumar a Y el puntero para apuntar al final
	ADD YL, BUFFER_POINTER_REG
	ADC YH, ZERO_REG
	
.ENDMACRO

;Macro para limpiar un buffer, simplemente limpia el BUFFER_POINTER
.MACRO BUFFER_CLEAR
	STS @0, ZERO_REG
.ENDMACRO

;Macro para insertar el caracter en CHAR_REG al buffer, el BUFFER_POINTER final se devuelve en BUFFER_POINTER_REG para poder verificar si hay Buffer Overflow
.DEF CHAR_REG = R16

.MACRO BUFFER_INSERT_CHAR

	POINT_Y_TO_END_OF_BUFFER @0, @1
	
	;Guardar valor
	ST Y, CHAR_REG
	;Incrementar puntero de buffer y guardar
	INC BUFFER_POINTER_REG
	STS @1, BUFFER_POINTER_REG
.ENDMACRO


;Macro para insertar un string en memoria de datos terminado en zero al buffer. El string es apuntado por X, el BUFFER_POINTER final se devuelve en BUFFER_POINTER_REG para poder verificar si hay Buffer Overflow
.DEF TEMP = R10

.MACRO BUFFER_INSERT_D_STR
	
	PUSH XL
	PUSH XH
	
	POINT_Y_TO_END_OF_BUFFER @0, @1
	
	;Itera agregando lo apuntado por X a lo apuntado po Y, corta si es cero
BUFFER_INSERT_D_STR_LOOP:
	LD TEMP, X+
	ST Y+, TEMP
	INC BUFFER_POINTER_REG
	TST TEMP
	BRNE BUFFER_INSERT_D_STR_LOOP
	
	STS @1, BUFFER_POINTER_REG
	
	POP XH
	POP XL
	
.ENDMACRO


;Macro para insertar un string en memoria de programa terminado en zero al buffer. El string es apuntado por X, el BUFFER_POINTER final se devuelve en BUFFER_POINTER_REG para poder verificar si hay Buffer Overflow
.DEF TEMP = R10

.MACRO BUFFER_INSERT_P_STR
	
	PUSH ZL
	PUSH ZH
	
	POINT_Y_TO_END_OF_BUFFER @0, @1
	
	;Itera agregando lo apuntado por X a lo apuntado po Y, corta si es cero
BUFFER_INSERT_D_STR_LOOP:
	LPM TEMP, Z+
	ST Y+, TEMP
	INC BUFFER_POINTER_REG
	TST TEMP
	BRNE BUFFER_INSERT_D_STR_LOOP
	
	STS @1, BUFFER_POINTER_REG
	
	POP ZH
	POP ZL
	
.ENDMACRO

/*

;Ejemplo de uso:

.EQU BUFFER_SIZE = 256
.EQU STR_VAR_SIZE = 256

.DSEG
BUFFER_POINTER: .BYTE 1
BUFFER: .BYTE BUFFER_SIZE
STR_VAR: .BYTE STR_VAR_SIZE

.CSEG
.ORG 0x00
	
	CLR ZERO_REG

	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	LDI R16, 'H'
	STS STR_VAR, R16
	LDI R16, 'O'
	STS STR_VAR+1, R16
	LDI R16, 'L'
	STS STR_VAR+2, R16
	LDI R16, 'A'
	STS STR_VAR+3, R16
	LDI R16, 0
	STS STR_VAR+4, R16

	BUFFER_CLEAR BUFFER_POINTER

	LDI ZL, LOW(MESSAGE<<1)
	LDI ZH, HIGH(MESSAGE<<1)
	BUFFER_INSERT_P_STR BUFFER, BUFFER_POINTER

	LDI XL, LOW(STR_VAR)
	LDI XH, HIGH(STR_VAR)
	BUFFER_INSERT_D_STR BUFFER, BUFFER_POINTER

	LDI R16, 'Z'
	BUFFER_INSERT_CHAR BUFFER, BUFFER_POINTER

	BUFFER_CLEAR BUFFER_POINTER

HERE: RJMP HERE

MESSAGE: .DB "hola mundo", 0
*/

.ENDIF