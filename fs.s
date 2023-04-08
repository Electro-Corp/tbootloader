[BITS 16]
[ORG 0xA510]

; FILESYSTEM DATA, USE THIS FILE
; FOR FILESYSTEM STUFF


; init
MOV SI, FsInitString
CALL Print
JMP 0x7E00


; Filesystem funcs
Format:
MOV SI, FormatConfirm
CALL Print
MOV AH, 0
INT 0x16
CMP AL, 'y'
JNE .exit
MOV SI, FormatInProg
CALL Print
; Format the drive to all 0s 
RET

.exit:
RET
List:
RET



; print
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


; DATA
FsInitString db 'Filesystem loaded', 0x0D, 0xA, 0

; FORMAT
FormatConfirm db 'Format disk in drive? This action cannot be undone. (Press Y to continue)', 0x0D, 0xA, 0
FormatInProg db 'Formatting disk, please wait.', 0x0D, 0xA, 0
