IR_VECTORS_RAM EQU 0FFE0H
STACK          EQU IR_VECTORS_RAM-1

		include "../common/definitions.asm"

        ORG  0000H    
START:  LD   SP, STACK                   ;*** COLD START ***
        LD   A, 0FFH
        JP  INIT


		include "../common/cf_z180.asm"
		;include "keyboard.asm"
		include "../common/utils_z180.asm"
		include "../common/hexdump_z80.asm"

        ;Set SYSTICK, RTCTICK and KBDDATA to 0x00
INIT:   LD   HL, 0000H
        LD   (SYSTICK), HL
        LD   (RTCTICK), HL
        XOR A
        LD  (KBDDATA), A
        
        ; Turn on LED
        LD A, 10H
        OUT0 (SYSCFG), A

        ; Setup stack to top of mapped RAM
        LD SP, 0FFDFH       ; Stack top
        
        NOP
        NOP
        NOP

;------------------------------------------------------------
; 1. Configure ASCI0 for 8 data bits, 1 stop, no parity
;------------------------------------------------------------
        LD      A, 34H              ; CNTLA0: TE=1; RTS=1 ;8 bits, 1 stop, no parity (0b00110100)
        OUT0     (CNTLA0), A

        LD      A, 20H              ; CNTLB0: enable TX/RX, use internal timer clock
        OUT0     (CNTLB0), A


        ; Wait before initializing CF card
		LD  C, 255
		CALL DELAY
        LD  C, 255
		CALL DELAY
		LD  C, 255
		CALL DELAY
		LD  C, 255
		CALL DELAY
        
		CALL IPUTS
		DB 'CF CARD: '
		DB 00H
		CALL CFINIT
		OR A								; Check if CF_WAIT during initialization timeouted
		JP Z, GET_CFINFO
		CALL IPUTS
		DB 'missing'
		DB 00H
		CALL NEWLINE
		JP $
GET_CFINFO:
        CALL CFINFO
        CALL IPUTS
        DB 'Received MBR: '
        DB 00H
        CALL CFGETMBR
        ; HEXDUMP MBR - START
        ;LD DE, LOAD_BASE
        ;LD B, 128
        ;CALL HEXDUMP
        ;LD DE, LOAD_BASE+128
        ;LD B, 128
        ;CALL HEXDUMP
        ;LD DE, LOAD_BASE+256
        ;LD B, 128
        ;CALL HEXDUMP
        ;LD DE, LOAD_BASE+384
        ;LD B, 128
        ;CALL HEXDUMP
        ;CALL NEWLINE
        ; HEXDUMP MBR - END
        ; Check if MBR is proper
        LD DE, LOAD_BASE+510
        LD A, (DE)
        CP 55H
        JP NZ, LOG_FAULTY_MBR
        INC DE
        LD A, (DE)
        CP 0AAH
        JP NZ, LOG_FAULTY_MBR
        JP LOG_PARTITION_TABLE
LOG_FAULTY_MBR:
		CALL IPUTS
		DB 'ERROR: faulty MBR'
		DB 00H
		CALL NEWLINE
        JP $
LOG_PARTITION_TABLE:
		CALL IPUTS
		DB 'Partition table'
		DB 00H
        CALL NEWLINE
        CALL PRN_PARTITION_TABLE
        CALL NEWLINE
        ; Check if partition 1 is present
        LD DE, LOAD_BASE+446+8		; Address of first partition
        CALL ISZERO32BIT
        JP NZ, CHECK_PARTITION1_SIZE
        CALL IPUTS
		DB 'ERROR: partition 1 missing'
		DB 00H
        CALL NEWLINE
        JP $
CHECK_PARTITION1_SIZE:
		; Check if partition 1 is larger than 16kB (32 sectors)
		LD DE, LOAD_BASE+446+12		; First partition size
		LD A, (DE)
		CP 32						; Check least significant byte
		JP Z, BOOT_CPM ;PRINT_BOOT_OPTIONS		; It is equal. Good enough.
		JP NC, BOOT_CPM ;PRINT_BOOT_OPTIONS		; It is bigger
		INC DE
		LD A, (DE)
		OR A
		JP NZ, BOOT_CPM ;PRINT_BOOT_OPTIONS
		INC DE
		LD A, (DE)
		OR A
		JP NZ, BOOT_CPM ;PRINT_BOOT_OPTIONS
		INC DE
		LD A, (DE)
		OR A
		JP NZ, BOOT_CPM ;PRINT_BOOT_OPTIONS
		CALL IPUTS
		DB 'ERROR: partition 1 < 16kB'
		DB 00H
		CALL NEWLINE
		JP $
        
BOOT_CPM:
		DI
        CALL LOAD_PARTITION1
        OR A
        JP Z, JUMP_TO_CPM
        CALL IPUTS
        DB 'CP/M load error. Reset.'
        DB 00H
        CALL ENDLESS_LOOP
JUMP_TO_CPM:
        CALL NEWLINE
        CALL IPUTS
        DB 'Load successfull.'
        DB 00H
        CALL NEWLINE
        JP BIOS_ADDR

;		include "fonts1.asm"
;		include "ps2_scancodes.asm"

		ORG	 0FBDFH
SYSTEM_VARIABLES:
BLKDAT: DS   512                        ;BUFFER FOR SECTOR TRANSFER
BLKENDL DS   1 ;0                          ;BUFFER ENDS
CFLBA3	DS	 1
CFLBA2	DS	 1
CFLBA1	DS	 1
CFLBA0	DS	 1                          
SYSTICK DS   2                          ;Systick timer
RTCTICK DS   2							;RTC tick timer/uptime
KBDDATA DS   1                          ;Keyboard last received code
KBDKRFL DS	 1							;Keyboard key release flag
KBDSFFL DS	 1							;Keyboard Shift flag
KBDOLD	DS	 1							;Keyboard old data
KBDNEW	DS	 1							;Keyboard new data
STKLMT: DS   1                          ;TOP LIMIT FOR STACK

        END
