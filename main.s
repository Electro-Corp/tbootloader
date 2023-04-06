[BITS 16]
[ORG 0x7C00]
XOR AX, AX ; make sure ds is set to 0
MOV DS, AX
CLD
; T54 Bootloader (part 1)
; We load in the second part of the bootloader here.
; Part 2 loads in the filesystem. 

MOV SI, BootString
CALL Print
; Read from hard drive
MOV AL, 1 ; Sectors to read
MOV CL, 2 ; Sector
CALL ReadDrive
; Part 2 is ready
MOV SI, ReadyString
CALL Print
JMP 0x7E00
; HARD DRIVE FUNCTIONS

; Read From drive
; Params:
; BX = Adress to dump to
; AL = Sectors
; CL = Sector to start from
ReadDrive:
MOV CH, 0 ; Cylinder 
MOV AH, 0x02 ; Read
MOV DH, 0 ; Head number 
XOR BX, BX 
MOV ES, BX
MOV BX, 0x7E00
INT 0x13
RET

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
BootString db 'tBootLoader is loading...', 0
ReadString db 'Reading from boot medium', 0
ReadyString db 'Done, jumping.', 0
TIMES 510 - ($ - $$) db 0
DW 0xAA55