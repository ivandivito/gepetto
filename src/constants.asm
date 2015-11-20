;Archivo con constantes de texto. Los String deben tener 16 caracteres y terminar en cero

.CSEG

CONSTANT_EMPTY:				.DB "                ", 0

CONSTANT_IDLE_TITLE:		.DB "Gepetto         ", 0
CONSTANT_IDLE_CONNECT:		.DB "Conectar        ", 0
CONSTANT_IDLE_RUN:			.DB "Ejecutar        ", 0

CONSTANT_CONNECTED_TITLE:	.DB "Conectado       ", 0
CONSTANT_CONNECTED_CANCEL:	.DB "Cancelar        ", 0

CONSTANT_RUNNING_TITLE:		.DB "Conectado       ", 0
CONSTANT_RUNNING_PAUSE:		.DB "Pausar          ", 0
CONSTANT_RUNNING_CONTINUE:	.DB "Reanudar        ", 0
CONSTANT_RUNNING_CANCEL:	.DB "Cancelar        ", 0

CONSTANT_ERROR_TITLE:		.DB "Error           ", 0
CONSTANT_ERROR_ACCEPT:		.DB "Aceptar         ", 0

FILE_HEADER: .DB "GEPETTO", '\n', 0

