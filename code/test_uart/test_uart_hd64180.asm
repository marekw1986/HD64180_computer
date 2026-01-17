        include "../common/definitions.asm"

        ORG   00000H
START:
        DI

        ; Setup stack to top of mapped RAM
        LD SP, 0FFDFH       ; Stack top
        

;------------------------------------------------------------
; 1. Configure Timer 1 as baud rate generator
;------------------------------------------------------------
        LD      A, 40H              ; TCR: enable Timer 1, internal clock, no external gate
        OUT     (TCR), A

        LD      A, 25                ; Reload value = 25 (≈9600 bps at 4 MHz)
        OUT     (RLDR1L), A
        XOR     A
        OUT     (RLDR1H), A          ; High byte = 0

;------------------------------------------------------------
; 2. Configure ASCI0 for 8 data bits, 1 stop, no parity
;------------------------------------------------------------
        LD      A, 15H              ; CNTLA0: 8 bits, 1 stop, no parity
        OUT     (CNTLA0), A

        LD      A, 80H              ; CNTLB0: enable TX/RX, use internal timer clock
        OUT     (CNTLB0), A



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
