[BITS 16]
[ORG 0x7C00]
; T54 Bootloader (part 1)
; We load in the second part of the bootloader here.
; Part 2 loads in the filesystem. 

MOV SI, BootString
CALL Print
JMP $


; PRINT FUNCTIONS
PrintChar:
MOV AH, 0x0E ; we need a char
MOV BH, 0x00
MOV BL, 0x07; Light grey on black, the usual
INT 0x10
RET
Print:

next_character:
MOV AL, [SI]
INC SI
OR AL, AL
JZ exit_function
CALL PrintChar
JMP next_character
exit_function:
RET

; lets get our data
BootString db '[T54 Bootloader] Loading kernel from memory..', 0


TIMES 510 - ($ - $$) db 0
DW 0xAA55
