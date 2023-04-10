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
; Create FS
CMP BL, 2
JE CreateFS
Init:
MOV SI, FsInitString
CALL Print
JMP 0x7E00

CreateFS:
MOV SI, CreateConfirm
CALL Print
MOV AH, 0
INT 0x16
CMP AL, 'y'
JNE .done
CALL Format
MOV SI, CreatingFS
CALL Print
JMP .done

.done:
MOV BL, 99
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
CALL .formatInit
.formatInit:
MOV AH, 0x05 ; format
MOV DH, 1 ; head
MOV CH, 0 ; Track
MOV AL, 1 ; sector
MOV BX, buffer

.formatHead:
MOV CH, 0
MOV [buffer + 2], DH
CALL .formatTrack
CMP DH, 2
JE .done
INC DH
JMP .formatHead

.formatTrack:
MOV AL, 18
MOV [buffer + 1], CH
MOV BX, buffer
CALL .formatSector
CMP CH, 80
JE .retC
INC CH
JMP .formatTrack

.formatSector:
;CMP AL, 18
;JE .retC
INT 0x13
INC AL
;JMP .formatSector
RET
.retC:
RET

;JMP .done

.done:
; check for errors
JC .error
; We're done
CMP BL, 2
JE .exit
MOV BL, 99 ; tell the main part we're done
JMP 0x7E00 ; jump back to the main
.exit:
RET
.error:
MOV SI, FormatError
CALL Print
CLC
MOV AH, 0x00
INT 0x13
;JMP .testF
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
; Create FS
CreateConfirm db 0x0D, 0xA, 'Create FS on current disk? (y)', 0x0D, 0xA, 0
CreatingFS db 'Creating FS, please wait.', 0x0D, 0xA, 0

buffer:
db 0 ; track num
db 1 ; head num
db 1 ; sector num
db 2 ; byte per sector