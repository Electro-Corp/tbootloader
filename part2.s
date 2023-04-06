[BITS 16]
; Part 2 of the bootloader
; the first was so good, they had to make
; a sequel. 

MOV SI, Part2Welcome ; Tell user Part 2 is loaded
CALL Print ; Print the messagw
JMP $ ; Hang

; UTILS
; PRINT FUNCTIONS
; i could just reload them from memory from part 1 but im not going to

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

Part2Welcome db 'Part 2 has loaded', 0


TIMES 510 - ($ - $$) db 0
DW 0xAA55