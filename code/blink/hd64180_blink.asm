        INCL "../common/definitions.asm"
        INCL "../common/utils_z180.asm"

        ORG   0000H
START:  
        DI

LOOP:
        MVI   A, 08H
        OUT   SYSCFG
        NOP
        MVI   A, 00H
        OUT   SYSCFG
        NOP
        JMP   LOOP

        END
