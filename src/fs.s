[BITS 16]
[ORG 0xA510]

; FILESYSTEM DATA, USE THIS FILE
; FOR FILESYSTEM STUFF


; init
CMP BL, 0
JE Init
; Check if command is Format
CMP BL, 1
JE Format
Init:
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
CLC ; Clear bit
JNE .done
MOV SI, FormatInProg
CALL Print
; get ready
MOV AH, 0x07
MOV AL, 0 ;
MOV CH, 0
MOV CL, 0
MOV DH, 0 
MOV BX, 0
INT 0x13
JE .done
;JNE .formatLoop

.done:
; check for errors
JC .error
; We're done
MOV BL, 99
JMP 0x7E00 ; jump back to the main

.error:
MOV SI, FormatError
CALL Print
CLC
JMP .done

List:
RET

; Params:
; AL = sectors to write
; CH = tracks
; CL = sectors
; dh = heads
WriteSectors:
MOV AH, 0x03
INT 0x13


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
FormatConfirm db 0x0D, 0xA, 'Format disk in drive? This action cannot be undone. (Press Y to continue)', 0x0D, 0xA, 0
FormatInProg db 'Formatting disk, please wait.', 0x0D, 0xA, 0
FormatError db 'Error formatting disk', 0x0D, 0xA, 0

;FormatBuf times 252 db AdMark
