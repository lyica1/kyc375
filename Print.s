; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 

    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
ZERO	EQU	0
    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
	PUSH{R0, LR}
	CMP R0, #10
	BLO Done
	MOV R2, #10
	UDIV R3, R0, R2
	MLS R1, R3, R2, R0
	MOV R0, R3
	STR R1, [SP, #ZERO]
	BL LCD_OutDec
	LDR R0, [SP, #ZERO]
Done
	ADD R0, #'0'
	BL ST7735_OutChar
	POP{R0, LR}


      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix
	MOV R1, #4
LCD_OutFix1
	PUSH {R0, R1, R4, LR}
	CMP R1, #0
	BEQ FINISH
	MOV R3, #10
	UDIV R2, R0, R3
	MLS R4, R2, R3, R0
	MOV R0, R2
	STR R4, [SP]
	STR R1, [SP, #4]
	SUB R1, #1
	BL LCD_OutFix1
	LDR R0, [SP]
	ADD R0, #'0'
	BL ST7735_OutChar
	LDR R1, [SP, #4]
	CMP R1, #1
	BNE FINISH
	MOV R0, #'.'
	BL ST7735_OutChar
	B FINISH
FINISH
	POP {R0, R1, R4, LR}
    BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
