.INCLUDE "gepetto.inc"

.EQU SOFT_UART_TX_PORT = PORTD
.EQU SOFT_UART_TX_DDR = DDRD
.EQU SOFT_UART_RX_PIN = PIND
.EQU SOFT_UART_RX_DDR = DDRD

.EQU SOFT_UART_ISC0 = ISC10
.EQU SOFT_UART_ISC1 = ISC11

.EQU SOFT_UART_INT = INT1

.EQU SOFT_UART_TX = 4
.EQU SOFT_UART_RX = 3

.EQU SOFT_UART_CS = 1 ; Clock selector, configura el prescaler

.EQU SOFT_UART_TCNT = TCNT0
.EQU SOFT_UART_TCCRA = TCCR0A
.EQU SOFT_UART_TCCRB = TCCR0B
.EQU SOFT_UART_OCR = OCR0A
.EQU SOFT_UART_OCF = OCF0A
.EQU SOFT_UART_TIFR = TIFR0

.EQU SOFT_UART_DEF_SUBR = 34 ; Fclk / (4 * Pre * Baud rate) - 1

.EQU SOFT_UART_FE = 4 ; Fclk / (4 * Pre * Baud rate) - 1

.DSEG
;Soft UART Baud Register
SUBR: .BYTE 1
;Soft UART Output Data Register
SUODR: .BYTE 1
;Soft UART Input Data Register
SUIDR: .BYTE 1
;Soft UART Control and State Register
SUCSR: .BYTE 1
/*

Ejemplo de uso

.ORG 0x00
	JMP MAIN

.ORG INT0addr
	JMP SOFT_UART_INTERRUPT

.ORG INT_VECTORS_SIZE
MAIN:
	
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R16, HIGH(RAMEND)
	OUT SPH, R16

	LDI R16, SOFT_UART_DEF_SUBR
	STS SUBR, R16

	CALL SOFT_UART_INIT

	SEI

	CALL SOFT_UART_INTERRUPT

	LDI R16, 0b01010101
	STS SUODR, R16

	CALL SOFT_UART_SEND_BYTE

HERE: RJMP HERE
*/

.CSEG

;Subrutina que configura los pines de salida y entrada y el timer

.DEF  TEMP = R16

SOFT_UART_INIT:

	SBI SOFT_UART_TX_DDR, SOFT_UART_TX ;Configurar TX como salida
	CBI SOFT_UART_RX_DDR, SOFT_UART_RX ;Configurar RX como entrada

	LDS TEMP, EICRA
	ANDI TEMP, ~((1<<SOFT_UART_ISC0)|(1<<SOFT_UART_ISC1))
	STS EICRA, TEMP ;Habilitar interrupcion en nivel bajo

	SBI SOFT_UART_TX_PORT, SOFT_UART_TX ;Poner en alto la salida

	OUT SOFT_UART_TCNT, ZERO_REG ;Limpia el timer

	LDS TEMP, SUBR
	OUT SOFT_UART_OCR, TEMP ;Configura tiempo de muestreo en el timer

	IN TEMP, EIMSK
	ORI TEMP, 1<<SOFT_UART_INT
	OUT EIMSK, TEMP ;Habilitar interrupcion

	RET

;Subrutina que envia el byte en R16 por el SOFT UART

.DEF BYTE_REG = R16
.DEF BITS_MISSING = R17
.DEF TEMP = R18

SOFT_UART_SEND_BYTE:
	PUSH TEMP

	CLI ;Inhabilita interrupciones

	LDS BYTE_REG, SUODR

	LDI BITS_MISSING, 8

	LDI TEMP, (1<<COM0A1)|(1<<WGM01)
	OUT SOFT_UART_TCCRA, TEMP
	LDI TEMP, SOFT_UART_CS
	OUT SOFT_UART_TCCRB, TEMP ;Timer en modo comparar y limpiar, comenzar a contar

	;Aca se puede agregar un retardo para compensar el overhead de los seteos posteriores

	;Enviar bit de start
	CBI SOFT_UART_TX_PORT, SOFT_UART_TX

	CALL BIT_TRANSFER_DELAY

	SEND_BYTE:
		ROR BYTE_REG ;Rotar byte

		;Enviar carry
		BRCC SEND_LOW
			SBI SOFT_UART_TX_PORT, SOFT_UART_TX
			RJMP SEND_CONTINUE
		SEND_LOW:
			CBI SOFT_UART_TX_PORT, SOFT_UART_TX
		SEND_CONTINUE:
		
		CALL BIT_TRANSFER_DELAY

		DEC BITS_MISSING
		BRNE SEND_BYTE

	;Enviar bit de stop
	SBI SOFT_UART_TX_PORT, SOFT_UART_TX

	RCALL BIT_TRANSFER_DELAY

	OUT SOFT_UART_TCCRB, ZERO_REG ;Detiene el timer

	OUT SOFT_UART_TCNT, ZERO_REG ;Limpia el timer

	SEI ;Habilita interrupciones

	POP TEMP
	RET

;Subrutina de retardo de un bit
.DEF BIT_SAMPLES = R18
.DEF TEMP = R20

BIT_TRANSFER_DELAY:
	PUSH BIT_SAMPLES
	PUSH TEMP

	LDI BIT_SAMPLES, 4
	SAMPLE_LOOP:
		IN TEMP, SOFT_UART_TIFR
		SBRS TEMP, SOFT_UART_OCF ;Esperar a que el timer cuente
			RJMP SAMPLE_LOOP

		IN TEMP, SOFT_UART_TIFR
		ORI TEMP, 1<<SOFT_UART_OCF
		OUT SOFT_UART_TIFR, TEMP ;Limpiar flag

		DEC BIT_SAMPLES
		BRNE SAMPLE_LOOP

	POP TEMP
	POP BIT_SAMPLES
	RET

;Subrutina de interripción para la lectura de datos

.DEF RESULT = R16
.DEF SAMPLES = R17
.DEF SAMPLE_COUNT = R18
.DEF TEMP = R20
.DEF BITS_READ = R21

SOFT_UART_INTERRUPT:
	PUSH TEMP

	LDI TEMP, (1<<COM0A1)|(1<<WGM01)
	OUT SOFT_UART_TCCRA, TEMP
	LDI TEMP, SOFT_UART_CS
	OUT SOFT_UART_TCCRB, TEMP ;Timer en modo comparar y limpiar, comenzar a contar

	PUSH SAMPLES
	PUSH SAMPLE_COUNT
	PUSH RESULT
	PUSH BITS_READ

	RCALL SOFT_UART_READ_BIT
	
	BRCC SOFT_UART_READ_EXIT ;Si el bit de start no es zero, salir
		
		LDI BITS_READ, 8
		CLR RESULT

		READ_BIT:
			RCALL SOFT_UART_READ_BIT ;Leer bit
			ROR RESULT
			DEC BITS_READ
			BRNE READ_BIT

		RCALL SOFT_UART_READ_BIT
		
		BRCC FRAMING_ERROR ;Si el ultimo bit leido es bajo informar error

			LDS TEMP, SUCSR
			ANDI TEMP, ~(1<<SOFT_UART_FE)
			
			RJMP SOFT_UART_POST_READ
		FRAMING_ERROR:
		
			LDS TEMP, SUCSR
			ORI TEMP, 1<<SOFT_UART_FE
			
		SOFT_UART_POST_READ:
		
		STS SUCSR, TEMP
		
		STS SUIDR, RESULT
		
		OUT SOFT_UART_TCCRB, ZERO_REG ;Detiene el timer
		OUT SOFT_UART_TCNT, ZERO_REG ;Limpia el timer
		
		CALL INT_VECTORS_SIZE
		
		RJMP SOFT_UART_READ_END
	SOFT_UART_READ_EXIT:
	
		OUT SOFT_UART_TCCRB, ZERO_REG ;Detiene el timer
		OUT SOFT_UART_TCNT, ZERO_REG ;Limpia el timer
		
	SOFT_UART_READ_END:
	
	POP BITS_READ
	POP RESULT
	POP SAMPLE_COUNT
	POP SAMPLES
	POP TEMP
	RETI

;Subrutina para leer un bit
SOFT_UART_READ_BIT:
	
	CLR SAMPLES
	LDI SAMPLE_COUNT, 3

	TIMER_LOOP:
		IN TEMP, SOFT_UART_TIFR
		SBRS TEMP, SOFT_UART_OCF ;Esperar a que el timer cuente
		RJMP TIMER_LOOP

		SBIC SOFT_UART_RX_PIN, SOFT_UART_RX ;Contar si el pin esta en alto
			INC SAMPLES

		IN TEMP, SOFT_UART_TIFR
		ORI TEMP, 1<<SOFT_UART_OCF
		OUT SOFT_UART_TIFR, TEMP ;Limpiar flag

		DEC SAMPLE_COUNT
		BRNE TIMER_LOOP

	TIMER_LOOP_LAST:
		IN TEMP, SOFT_UART_TIFR
		SBRS TEMP, SOFT_UART_OCF ;Esperar a que el timer cuente una vez mas
		RJMP TIMER_LOOP_LAST

	IN TEMP, SOFT_UART_TIFR
	ORI TEMP, 1<<SOFT_UART_OCF
	OUT SOFT_UART_TIFR, TEMP ;Limpiar flag

	CPI SAMPLES, 2 ;Comparar muestras en alto con 2
	BRSH SET_CARRY_HIGH ;Si son 2 o 3 setear carry
		CLC
	RJMP READ_CONTINUE
	SET_CARRY_HIGH:
		SEC
	READ_CONTINUE:

	RET
	