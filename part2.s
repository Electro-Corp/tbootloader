[BITS 16]
[ORG 0x7E00]
; Part 2 of the bootloader
; the first was so good, they had to make
; a sequel. 
; =============================
MOV SI, Part2Welcome ; Tell user Part 2 is loaded
CALL Print ; Print the message
; Prompt begin
XOR CL, CL
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
CALL CompStr
JC .BootFromMedium
; nothing else to check!
MOV SI, NoCommandFound
CALL Print
CALL ShowPrompt

; ====== COMMANDS =======
.BootFromMedium:
MOV SI, BootString
CALL Print
JMP ShowPrompt

ShowPrompt:
XOR DI, DI
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


Main:
MOV AH, 0
INT 0x16
INC CL
; If its enter we're done
CMP AL, 0x0D
JE Parrot
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


CompStr:
.loop:
MOV AL, [SI]
MOV BL, [DI]
CMP AL, BL
JNE .strnotequal
CMP AL, 0
JE .done
INC DI
INC SI
JMP .loop

.strnotequal:
CLC
MOV SI, StrNot
CALL Print
RET

.done:
STC
MOV SI, StrIs
CALL Print
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
XOR BX, BX 
MOV ES, BX
INT 0x13
RET



NewLine db '', 0x0D, 0xA, 0
Part2Welcome db '====================================', 0x0D, 0xA,"T54 Bootloader has loaded.", 0x0D, 0xA,"Enter 'boot' at the prompt to boot, or type 'help' for help.",0x0D, 0xA, "====================================", 0x0D, 0xA, 0
Prompt db 'TBoot>', 0
BootString db 0x0D, 0xA,'Booting from selected medium', 0x0D, 0xA, 0
NoCommandFound db 0x0D, 0xA,'Command not found.' , 0x0D, 0xA, 0
; Buffer
buffer times 256 db 0

; Commands
BootCommand db 'boot', 0

; DEBUG
StrNot db 'not equal.', 0x0D, 0xA, 0
StrIs db 'equal.', 0x0D, 0xA, 0
