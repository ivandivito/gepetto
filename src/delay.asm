
.CSEG

DELAY_2_REG: 

	DELAY_2_REG_LOOP:
	DEC R16
	BRNE DELAY_2_REG_LOOP
	DEC R17
	BRNE DELAY_2_REG_LOOP

	RET


DELAY_3_REG:

	DELAY_3_REG_LOOP:
	DEC R16
	BRNE DELAY_3_REG_LOOP
	DEC R17
	BRNE DELAY_3_REG_LOOP
	DEC R18
	BRNE DELAY_3_REG_LOOP

	RET
