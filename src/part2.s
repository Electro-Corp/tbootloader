[BITS 16]
[ORG 0x7E00]
; Part 2 of the bootloader
; the first was so good, they had to make
; a sequel. 
; =============================
; Check if a command was just run
CMP BL, 99
JE ShowPrompt
; Check if filesystem is loaded already
CMP BYTE [0xA510] , 0
; if so, lets just go
JNE Intro
; init fs
;MOV SI, FsString
;CALL Print
;MOV AH, 0
;INT 0x16
; Load in filesystem disk
MOV AL, 1 ; sectors to read
MOV CL, 6 ; starting sector
MOV CH, 0 ; cylinder head
MOV DH, 0 ; Head number 
XOR BX, BX
MOV ES, BX
MOV BX, 0xA510 ; 34256
CALL ReadDrive
CMP BYTE [0xA510] , 0 ; check if memory address is empty
JNE 0xA510
JE ReadError

CALL Intro

Intro:
MOV SI, Part2Welcome ; Tell user Part 2 is loaded
CALL Print ; Print the message
; Prompt begin
CALL ShowPrompt
CALL Main



Handle:
MOV CL, 0
MOV AL, 0
STOSB ; null terminated
; Figure out what we need to do, compare it against the limited commands avalible (this is only a bootloader after all!)
; make sure its not empty
MOV SI, buffer
CMP BYTE [SI], 0
JE ShowPrompt
; check against 'boot'
MOV SI, buffer
MOV DI, BootCommand
CALL StrCmp
JC .BootFromMedium
; check against 'help'
MOV SI, buffer
MOV DI, HelpCommand
CALL StrCmp
JC .Help
; Check against 'format'
MOV SI, buffer
MOV DI, FormatCommand
CALL StrCmp
JC .Format
; nothing else to check!
MOV SI, NoCommandFound
CALL Print
CALL ShowPrompt

; ====== COMMANDS =======
.BootFromMedium:
MOV SI, BootString
CALL Print
; Lets try to jump to it
; BX = Adress to dump to
; AL = Sectors
; CL = Sector to start from
; CH = Cylinder
; DH = Head number
MOV AL, 10
MOV CL, 1
MOV CH, 0
MOV DH, 0
MOV BX, 0x8000
CALL ReadDrive
JMP BX
JMP ShowPrompt

.Help:
MOV SI, HelpString
CALL Print
JMP ShowPrompt

.Format:
MOV BL, 1
JMP 0xA510

ShowPrompt:
MOV CL, 0
XOR DI, buffer
MOV DI, buffer
; Done, prompt
MOV SI, NewLine
CALL Print
MOV SI, Prompt
CALL Print
CALL Main

Parrot:
MOV SI, NewLine
CALL Print
MOV SI, buffer
CALL Print
CALL Handle

BackSpace:
; Before we do anything, lets make sure CL is not 0
CMP CL, 0
JE Main
; 
DEC DI
MOV BYTE [DI], 0
DEC CL
; update screen
MOV AH, 0x0E
MOV AL, 0x08
INT 0x10
; Blank it
MOV AL, ' '
INT 0x10
MOV AL, 0x08
INT 0x10
JMP Main

; main loop
Main:
MOV AH, 0
INT 0x16
INC CL
; If its enter we're done
CMP AL, 0x0D
JE Handle
; Is it backspace?
CMP AL, 0x08
JE BackSpace
MOV AH, 0x0E
INT 0x10
STOSB
JMP Main

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
; Compare String
StrCmp:
.loop:
MOV AL, [SI]
MOV BL, [DI]
CMP AL, BL
JNE .StringIsNot
CMP AL, 0
JE .StringIsEqual
INC DI
INC SI
JMP .loop

.StringIsNot:
CLC
RET

.StringIsEqual:
STC
RET
; HARD DRIVE

; Read From drive
; Params:
; BX = Adress to dump to
; AL = Sectors
; CL = Sector to start from
; CH = Cylinder
; DH = Head number
ReadDrive:
MOV AH, 0x02 ; Read
INT 0x13
RET

; ReadError
ReadError:
MOV SI, ERR_C
CALL Print
CALL Intro

NewLine db '', 0x0D, 0xA, 0
Part2Welcome db '====================================', 0x0D, 0xA,"T54 Bootloader has loaded.", 0x0D, 0xA,"Enter 'boot' at the prompt to boot, or type 'help' for help.",0x0D, 0xA, "====================================", 0x0D, 0xA, 0
Prompt db 'TBoot>', 0
BootString db 0x0D, 0xA,'Booting from selected medium', 0x0D, 0xA, 0
HelpString db 0x0D, 0xA,'Commands: ', 0x0D, 0xA, 'boot: boots from the default medium, or the one selected', 0x0D, 0xA,'format: formats the current disk', 0x0D, 0xA, 'help: show this help', 0x0D, 0xA, 0
FsString db 0x0D, 0xA, 'Put Filesystem disk into drive and press any key to continue..', 0x0D, 0xA, 0
NoCommandFound db 0x0D, 0xA,'Command not found.' , 0x0D, 0xA, 0
ERR_C db 0x0D, 0xA, 'ERR_LOAD_FS', 0x0D, 0xA, 0
; Buffer
buffer times 256 db 0

; Commands
BootCommand db 'boot', 0
HelpCommand db 'help', 0
FormatCommand db 'format', 0

