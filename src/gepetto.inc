.IFNDEF GEPETTO_INC
.EQU GEPETTO_INC = 0

.INCLUDE "m328pdef.inc"
.INCLUDE "spi.inc"
.INCLUDE "buffer.inc"

;.INCLUDE "buttons.asm"
;.INCLUDE "connected.asm"
;.INCLUDE "error.asm"
;.INCLUDE "idle.asm"
;.INCLUDE "running.asm"
;.INCLUDE "soft_uart.asm"
.INCLUDE "spi.asm"


.DEF ZERO_REG = R1

.EQU STATE_ERROR_FLAG = 0
.EQU STATE_IDLE_FLAG = 1
.EQU STATE_CONNECTED_FLAG = 2
.EQU STATE_RUNNING_FLAG = 3

.EQU BUFFER_SIZE = 256

.ENDIF

