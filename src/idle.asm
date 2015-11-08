.INCLUDE "gepetto.inc"
.INCLUDE "buffer.inc"

.CSEG

.DEF TEMP1 = R16
.DEF TEMP2 = R17

IDLE_RUN:
	
	;Procesar buffer GRBL
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER GRBL_BUFFER, GRBL_BUFFER_POINTER
	
	LD TEMP1, Y
	
	CPI TEMP1, '\n'
	BRNE IDLE_GRBL_CONTINUE
	
		;Procesar linea de GRBL
	
	IDLE_GRBL_CONTINUE:
	
	;Verificar connección PC
	
	;Verificar si termina en \n
	POINT_Y_TO_END_OF_BUFFER USB_BUFFER, USB_BUFFER_POINTER
	
	LD TEMP1, Y
	
	CPI TEMP1, '\n'
	BRNE IDLE_USB_CONTINUE
	
		;Procesar linea de USB
	
	IDLE_USB_CONTINUE:
	
	;Procesar botones
	CALL BUTTONS_READ
	
	
	;Actualizar UI
	
	RET
