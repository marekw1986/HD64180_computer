        include "../common/definitions.asm"

        ORG   0000H
START:  
        DI
        
        ; Setup stack to top of mapped RAM
        LD   SP, 0FFDFH       ; Stack top
        
        NOP
        NOP
        NOP

; ----------------------------
; Blink loop on PA
; ----------------------------
LOOP:
        LD   A, 10H
        OUT0  (SYSCFG), A
        
        LD   C, 255
        CALL DELAY

        LD   A, 00H
        OUT0  (SYSCFG), A
        
        LD   C, 255
        CALL DELAY

        JP   LOOP
        
        include "../common/utils_z180.asm"

        END
