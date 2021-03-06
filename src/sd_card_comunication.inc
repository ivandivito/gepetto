.IFNDEF SD_CARD_COMUNICATION
.EQU SD_CARD_COMUNICATION = 0
 
	.DEF SD_CMD_REG = R2
	.DEF SD_CMD_ARG_REG_0 = R3 ;MS
	.DEF SD_CMD_ARG_REG_1 = R4
	.DEF SD_CMD_ARG_REG_2 = R5
	.DEF SD_CMD_ARG_REG_3 = R6 ;LS
	
	.EQU SD_CMD_MASK				 = 0x40

	.EQU GO_IDLE_STATE				 = (0 | SD_CMD_MASK)
	.EQU SEND_OP_COND				 = (1 | SD_CMD_MASK)
	.EQU SEND_IF_COND				 = (8 | SD_CMD_MASK)
	.EQU SEND_CSD					 = (9 | SD_CMD_MASK)
	.EQU STOP_TRANSMISSION			 = (12 | SD_CMD_MASK)
	.EQU SEND_STATUS				 = (13 | SD_CMD_MASK)
	.EQU SET_BLOCK_LEN				 = (16 | SD_CMD_MASK)
	.EQU READ_SINGLE_BLOCK			 = (17 | SD_CMD_MASK)
	.EQU READ_MULTIPLE_BLOCKS		 = (18 | SD_CMD_MASK)
	.EQU WRITE_SINGLE_BLOCK			 = (24 | SD_CMD_MASK)
	.EQU WRITE_MULTIPLE_BLOCKS		 = (25 | SD_CMD_MASK)
	.EQU ERASE_BLOCK_START_ADDR		 = (32 | SD_CMD_MASK)
	.EQU ERASE_BLOCK_END_ADDR		 = (33 | SD_CMD_MASK)
	.EQU ERASE_SELECTED_BLOCKS		 = (38 | SD_CMD_MASK)
	.EQU SD_SEND_OP_COND			 = (41 | SD_CMD_MASK)
	.EQU APP_CMD					 = (55 | SD_CMD_MASK)
	.EQU READ_OCR					 = (58 | SD_CMD_MASK)
	.EQU CRC_ON_OFF					 = (59 | SD_CMD_MASK)

	.EQU SD_CMD_IF_END				 = 0x87
	.EQU SD_CMD_OCR_END				 = 0x75
	.EQU SD_CMD_END					 = 0x95

	.EQU SD_CMD_RSP_WAIT			 = 0xff
	.EQU SD_CMD_RSP_IDLE			 = 0x01
	.EQU SD_CMD_RSP_NOT_IDLE		 = 0x00
	.EQU SD_CMD_RSP_INVALID_CMD		 = 0x05

	.EQU SD_CMD_RSP_START			 = 0xfe


	;carga de registro para la llama a la subrutina de envio de comando
	.DEF TEMP = R16
	.DEF SD_TX_CMD_RSP = R16
	.MACRO SD_TX_CMD_MACRO  ; 0 es el comando (1 byte) y 1 es el argumento (4 bytes)

			LDI TEMP,LOW(@0)
			MOV SD_CMD_REG,TEMP
			LDI TEMP,LOW(@1)
			MOV SD_CMD_ARG_REG_3,TEMP
			LDI TEMP,BYTE2(@1)
			MOV SD_CMD_ARG_REG_2,TEMP
			LDI TEMP,BYTE3(@1)
			MOV SD_CMD_ARG_REG_1,TEMP
			LDI TEMP,BYTE4(@1)
			MOV SD_CMD_ARG_REG_0,TEMP
			CALL SD_TX_CMD
	
	.ENDMACRO

	;llama a la funcion enviar comando repetidamente hasta que se obtiene respuesta esperada
	.DEF TEMP = R16
	.DEF SD_TX_CMD_RSP = R16
	.MACRO SD_TX_CMD_REP_MACRO ; 0 es el comando (1 byte) , 1 es el argumento (4 bytes) y 2 es la respuesta esperada (1 byte)

		SD_TX_CMD_RSP_LOOP:
			SD_TX_CMD_MACRO (@0), (@1)

			CPI SD_TX_CMD_RSP,(@2)
			BRNE SD_TX_CMD_RSP_LOOP
	
	.ENDMACRO
.ENDIF