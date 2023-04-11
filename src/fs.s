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
; get param
MOV BL, 10
; 
MOV AH, 0x05 ; format
MOV DH, 1 ; head
MOV CH, 0 ; Cylinder
MOV AL, 18 ; sectors
MOV BX, Buffer
MOV ES, BX
CALL .formatHead
.formatHead:
MOV CH, 0
CALL .formatTrack
CMP DH, 2
JE .done
INC DH
JMP .formatHead

.formatTrack:
CLC
INT 0x13
JC .checkErrorQuick
CMP CH, BL
JE .retC
INC CH
JMP .formatTrack

.checkErrorQuick:
MOV SI, FormatError
CALL Print
JMP .formatHead
RET

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
MOV SI, FormatFinish
CALL Print
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
JMP .formatInit
;JMP .done

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
FormatFinish db 'Disk formatted.', 0x0D, 0xA, 0
; Create FS
CreateConfirm db 0x0D, 0xA, 'Create FS on current disk? (y)', 0x0D, 0xA, 0
CreatingFS db 'Creating FS, please wait.', 0x0D, 0xA, 0

buffer:
db 0 ; track num
db 1 ; head num
db 1 ; sector num
db 2 ; byte per sector


Buffer db 0x0, 0x01, 0x01, 0x02, 0x0, 0x01, 0x02, 0x02, 0x0, 0x01, 0x03, 0x02, 0x0, 0x01, 0x04, 0x02, 0x0, 0x01, 0x05, 0x02, 0x0, 0x01, 0x06, 0x02, 0x0, 0x01, 0x07, 0x02, 0x0, 0x01, 0x08, 0x02, 0x0, 0x01, 0x09, 0x02, 0x0, 0x01, 0x10, 0x02, 0x0, 0x01, 0x11, 0x02, 0x0, 0x01, 0x12, 0x02, 0x0, 0x01, 0x13, 0x02, 0x0, 0x01, 0x14, 0x02, 0x0, 0x01, 0x15, 0x02, 0x0, 0x01, 0x16, 0x02, 0x0, 0x01, 0x17, 0x02, 0x0, 0x01, 0x18, 0x02
