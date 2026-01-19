        include "../common/definitions.asm"

        ORG   00000H
START:
        DI

        ; Setup stack to top of mapped RAM
        LD SP, 0FFDFH       ; Stack top

;------------------------------------------------------------
; 1. Configure ASCI0 for 8 data bits, 1 stop, no parity
;------------------------------------------------------------
        LD      A, 34H              ; CNTLA0: TE=1; RTS=1 ;8 bits, 1 stop, no parity (0b00110100)
        OUT0     (CNTLA0), A

        LD      A, 20H              ; CNTLB0: enable TX/RX, use internal timer clock
        OUT0     (CNTLB0), A



LOOP:
        LD A, 55H          ; UART to send
        CALL OUT_CHAR             
        
        LD A, 10H
        OUT0 (SYSCFG), A
        
		LD	C, 255
		CALL DELAY
        
        XOR A
        OUT0 (SYSCFG), A
        
        LD   C, 255
        CALL DELAY
		
        JP   LOOP

		include "../common/utils_z180.asm"

        END
