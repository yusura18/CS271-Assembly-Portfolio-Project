TITLE Project_6    (Proj6_moorbrea.asm)

; Author: Breanna Moore
; Last Modified: 11/30/2020
; OSU email address: moorbrea@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/6/2020
; Description: This program uses macros and procedures to collect 10 user inputted string and
; converts them into signed integers that fit into a 32-bit register. The total sum and rounded
; average are calculated. The program then converts the validated user input's back into strings,
; as well as converting the calculated sum and rounded average into strings and displays the results.

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; This macro displays a prompt to get a user input of a signed integer. The user's
; input must match count. The size of the string is stored.
;
; Preconditions: strings to be displayed and read must be type BYTE. 
;
; Postconditions: None
;
; Receives: prompt = address of string to be displayed
;			userInput = address of where user input to be stored
;			count = MAXSIZE
;			userInput_size = size of user input's string
; Returns: Returns user's input and user input's size.
; ---------------------------------------------------------------------------------
mGetString   MACRO   prompt, userInput, count, userInput_size
	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	mDisplayString prompt
	MOV		EDX, userInput
	MOV		ECX, count
	CALL	ReadString
	MOV		userInput_size, EAX

	POP		EAX
	POP		ECX
	POP		EDX

ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; The description of the macro should be like a section comment, summarizing
; the overall goal of the blocks of code within the macro.
;
; Preconditions: string must be type BYTE and passed by reference.
;
; Postconditions: None
;
; Receives: Address of a string
;
; Returns: Displays the string passed to macro.
; ---------------------------------------------------------------------------------
mDisplayString   MACRO    someMsg_address
	PUSH	EDX
	MOV		EDX, someMsg_address
	CALL	WriteString
	POP		EDX
ENDM

; ---------------------------------------------------------------------------------
; Name: mTempString
;
; This macro receives the address of a string and stores null values up to the
; specified length.
;
; Preconditions: string must be type BYTE.
;
; Postconditions: None
;
; Receives: string_address = string to be changed
;			length = size of string to be changed
; Returns: Fills a string with a given length with null values.
; ---------------------------------------------------------------------------------
mTempString		MACRO	string_address, length
	LOCAL	L1
	PUSH	EAX
	PUSH	ECX
	PUSH	EDI

	MOV		EDI, string_address
	MOV		ECX, length
	MOV		AL, 0
	CLD
L1:
	STOSB
	LOOP	L1

	POP		EDI
	POP		ECX
	POP		EAX
ENDM

; (insert constant definitions here)
ARRAYSIZE = 10
MAXSIZE = 12

.data

; (insert variable definitions here)
intro1			BYTE		"Project 6: String Primitives and Macros",13,10,"Programmed by: Breanna Moore",13,10,13,10,0
intro2			BYTE		"Welcome to my program!",13,10,13,10,
							"Please provide 10 signed decimal integers.",13,10,
							"Each integer must be small enough to fit inside a 32-bit register. After you have inputted 10 integers,",13,10,
							"this program will display a list of the integers, their sum, and their average.",13,10,13,10,0
prompt1			BYTE		"Please enter a signed integer: ",0
errorMsg		BYTE		"ERROR: You did not enter an integer or the integer does not fit in a 32-bit register!",13,10,0
inputRetry		BYTE		"Please try again: ",0
byeMsg			BYTE		"Thank you for using my program! Goodbye!",13,10,0
userNumString	BYTE		MAXSIZE DUP(?)
userNumSize		BYTE		?		
sum				SDWORD		?
roundAvg		SDWORD		?
intArray		SDWORD		ARRAYSIZE DUP(?)
counter			DWORD		0
prompt2			BYTE		13,10,"You entered the following integers:",13,10,0
sumMsg			BYTE		13,10,"The sum of your integers is: ",0
space			BYTE		" ",0
avgMsg			BYTE		13,10,"The rounded average is: ",0


.code
main PROC

; Greet user and display instructions
	PUSH	OFFSET intro1
	PUSH	OFFSET intro2
	CALL	Introduction

; Get user input, validate inputs, & store in array
	PUSH	counter
	PUSH	OFFSET intArray
	PUSH	ARRAYSIZE
	PUSH	OFFSET inputRetry
	PUSH	OFFSET prompt1
	PUSH	OFFSET errorMsg
	PUSH	MAXSIZE
	PUSH	OFFSET userNumString
	PUSH	OFFSET userNumSize
	CALL	ReadVal

; Display user's validated numbers
	PUSH	OFFSET intArray
	PUSH	ARRAYSIZE
	PUSH	OFFSET space
	PUSH	OFFSET prompt2
	CALL	DisplayArray
; Calculate Sum
	PUSH	OFFSET intArray
	PUSH	ARRAYSIZE
	PUSH	OFFSET sum
	CALL	CalculateSum	

; Display sum
	PUSH	sum
	PUSH	OFFSET sumMsg
	CALL	DisplaySum
; Calculate rounded average
	PUSH	OFFSET roundAvg
	PUSH	ARRAYSIZE
	PUSH	sum
	CALL	RoundedAverage	

; Display rounded average
	PUSH	roundAvg
	PUSH	OFFSET avgMsg
	CALL	DisplayAvg

; Say goodbye to user
	PUSH	OFFSET byeMsg
	CALL	Goodbye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ---------------------------------------------------------------------------------
; Name: Introduction
;
; Introduces the program and programmer. Describes what user must enter and what
; the program will display.
; Preconditions: intro1 and intro2 type BYTE.
; Postconditions: EDX changed by WriteString
; Receives: [EBP+12] = reference to intro1, [EBP+8] = reference to intro2
; Returns:  None
; ---------------------------------------------------------------------------------
Introduction PROC
	PUSH	EBP
	MOV		EBP, ESP
	mDisplayString [EBP+12]
	mDisplayString [EBP+8]

	POP		EBP
	RET		8
Introduction ENDP

; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; This procedure prompts user to input 10 valid signed integers. The input is
; converted from type byte to SDWORD and then stored in the array. If the user 
; enters invalud input, an error message is displayed and user is prompted
; again for a new input.
;
; Preconditions: Prompts must be type BYTE, size of user input must be type
; BYTE, intArray must be type SDWORD and match ARRAYSIZE.
;
; Postconditions: None
;
; Receives: [EBP+40] = counter to track sign
;			[EBP+36] = address of intArray
;			[EBP+32] = ARRAYSIZE
;			[EBP+28] = address of inputRetry
;			[EBP+24] = address of prompt1
;			[EBP+20] = address of error message
;			[EBP+16] = MAXSIZE
;			[EBP+12] = address of user's string input
;			[EBP+8] = Size of user's string
; Returns: Changes the values in the intArray to validated user inputs.
; ---------------------------------------------------------------------------------
ReadVal PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	ECX
	PUSH	EAX
	PUSH	EBX
	PUSH	EDX

; Set EDI to point to intArray
	MOV		EDI, [EBP+36]
	MOV		ECX, [EBP+32]
	PUSH	ECX
	JMP		_getString

_nextInput:
	; ECX tracks number of elements for array
	PUSH	ECX
_getString:
; Prompt user and get user's input	
	mGetString [EBP+24], [EBP+12], [EBP+16], [EBP+8]
	JMP		_start

_updateArray:
	; Move finalized number
	MOV		[EDI], ECX
	ADD		EDI, 4
	POP		ECX
	LOOP	_nextInput
	JMP		_end

_start:
; Check user input's size: Zero indicates no input
	MOV		EAX, [EBP+8]
	CMP		EAX, 0
	JE		_inputError

	MOV		ESI, [EBP+12]
	CLD
	; Set ECX to number total
	MOV		ECX, 0

_validate:
	MOV		EAX, 0
	LODSB

	; check if byte is zero: Indicates end of string 
	CMP		AL, 0
	JE		_finalize

	CMP		AL, 48
	JB		_checkSign
	CMP		AL, 57
	JA		_inputError

	; Convert to digit and store
	SUB		AL, 48
	PUSH	EAX

	; Multiply number total by 10
	MOV		EAX, ECX
	MOV		EBX, 10
	IMUL	EBX

	; Add current number
	POP		EBX
	ADD		EAX, EBX

	; Check carry flag
	JO		_inputError

	; Update number total
	MOV		ECX, EAX

	; Update sign counter
	MOV		EBX, [EBP+40]
	MOV		EBX, 1
	MOV		[EBP+40], EBX
	
	JMP		_validate

_inputError:
	; Reset sign counter
	MOV		EBX, [EBP+40]
	MOV		EBX, 0
	MOV		[EBP+40], EBX

	; Prompt user with error message & get new user input
	mDisplayString [EBP+20]
	mGetString [EBP+28], [EBP+12], [EBP+16], [EBP+8]
	JMP		_start

_checkSign:
	MOV		EBX, [EBP+40]
	CMP		EBX, 1
	JE		_inputError
	CMP		AL, 43
	JB		_inputError
	CMP		AL, 44
	JE		_inputError
	CMP		AL, 45
	JA		_inputError
	JMP		_validate

_finalize:
	; Reset sign counter
	MOV		EBX, [EBP+40]
	MOV		EBX, 0
	MOV		[EBP+40], EBX

	; Grab first character again to check for negative sign
	MOV		ESI, [EBP+12]
	CLD
	LODSB
	CMP		AL, 45
	JE		_Negate
	JMP		_updateArray

_Negate:
	NEG		ECX
	JMP		_updateArray

_end:
	POP		EDX
	POP		EBX
	POP		EAX
	POP		ECX
	POP		EDI
	POP		ESI
	POP		EBP

	RET		36
ReadVal ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; This procedure receives a signed integer value and converts into a string.
;
; Preconditions: Preconditions are conditions that need to be true for the
; procedure to work, like the type of the input provided or the state a
; certain register need to be in.
;
; Postconditions: None
;
; Receives: Signed integer value to be converted into a string.
;			[EBP-4] = local variable to track whether value is negative
;			[EBP-24] = Local string to store converted characters
;			[EBP-44] = Local string to store reversed order of converted string
; Returns: Displays converted string.
; ---------------------------------------------------------------------------------
WriteVal PROC
	PUSH	EBP
	MOV		EBP, ESP

	; Procedure local variables
	SUB		ESP, 4		; Track sign
	SUB		ESP, 20		; String to be converted
	SUB		ESP, 20		; String used to reverse
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	; Create temp strings 
	LEA		EDI, [EBP-24]
	mTempString EDI, 20
	LEA		EDI, [EBP-44]
	mTempString EDI, 20

	; Check sign of integer, Negate if negative
	MOV		EAX, [EBP+8]
	TEST	EAX, -1
	JNS		_CheckZero
	MOV		DWORD PTR [EBP-4], 1		; change local track sign variable
	NEG		EAX

; Check if value is zero
_CheckZero:
	CMP		EAX, 0
	JNE		_Start
	LEA		EDI, [EBP-44]
	CLD
	MOV		AL, 48
	STOSB
	JMP		_display

; Convert integer into string
_Start:
	LEA		EDI, [EBP-24]
	MOV		ECX, 0
	CLD
_GetNumLoop:
	CMP		EAX, 0		; When end of string reached, check sign
	JNA		_Sign
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX
	PUSH	EAX
	MOV		EAX, EDX
	
	ADD		AL, 48
	STOSB
	POP		EAX
	ADD		ECX, 1
	JMP		_GetNumLoop

_Sign:
	; Check for sign, add negative sign if needed
	MOV		EBX, DWORD PTR [EBP-4]
	CMP		EBX, 1
	JNE		_Reverse
	MOV		AL, 45
	STOSB
	ADD		ECX, 1

; Pass converted string to local reverse string to correct
; the order of characters.
_Reverse:
	LEA		ESI, [EBP-24]
	LEA		EDI, [EBP-44]
	ADD		ESI, ECX
	DEC		ESI
_RevLoop:
	STD
	LODSB
	CLD
	STOSB
	loop	_RevLoop

; Pass local converted string to display Macro
_display:
	LEA		ESI, [EBP-44]
	mDisplayString ESI

	POP		ESI
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX
	MOV		ESP, EBP
	POP		EBP
	RET		4

WriteVal ENDP

; ---------------------------------------------------------------------------------
; Name: DisplayArray
;
; This procedure displays the validated user inputted values in intArray. The
; elements from the array are passed to WriteVal to convert the signed integer
; into a string.
;
; Preconditions: intArray must be type SDWORD and contain validated values.
; ARRAYSIZE must match the number of elements of intArray. Displays must be
; type BYTE.
;
; Postconditions: None
;
; Receives: [EBP+20] = address of intArray
;			[EBP+16] = ARRAYSIZE
;			[EBP+12] = address of space string
;			[EBP+8] = address of prompt2
; Returns: Displays the values of intArray as strings.
; ---------------------------------------------------------------------------------
DisplayArray PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ECX
	PUSH	ESI

	; Print prompt message
	mDisplayString [EBP+8]

	; ESI points to first element in array. ECX is the ARRAYSIZE
	MOV		ESI, [EBP+20]
	MOV		ECX, [EBP+16]
_displayLoop:
	PUSH	[ESI]
	CALL	WriteVal
	mDisplayString [EBP+12]
	ADD		ESI, 4
	LOOP	_displayLoop
	CALL	CrLf

	POP		ESI
	POP		ECX
	POP		EBP
	RET		16
DisplayArray ENDP

; ---------------------------------------------------------------------------------
; Name: CalculateSum
;
; This procedure is passed the user's valid inputs stored in intArray and
; calculates the total sum of all the integers.
;
; Preconditions: The intArray must be type SDWORD and filled with validated
; inputs. ARRAYSIZE must match the number of elements in the array.
;
; Postconditions: None
;
; Receives: [EBP+16] = address of intArray
;			[EBP+12] = ARRAYSIZE
;			[EBP+8] = sum
;
; Returns: Changes the variable sum.
; ---------------------------------------------------------------------------------
CalculateSum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	EAX
	PUSH	ECX
	PUSH	EBX

; EAX tracks the running sum total
	MOV		EAX, 0
	MOV		ESI, [EBP+16]
	MOV		ECX, [EBP+12]

_StartSum:
	; Move array element into EBX
	MOV		EBX, [ESI]
	ADD		EAX, EBX
	ADD		ESI, 4
	LOOP	_StartSum
	
	; Store total sum to variable
	MOV		EDI, [EBP+8]
	MOV		[EDI], EAX

	POP		EBX
	POP		ECX
	POP		EAX
	POP		EDI
	POP		ESI
	POP		EBP

	RET		12
CalculateSum ENDP

; ---------------------------------------------------------------------------------
; Name: DisplaySum
;
; This procedure displays the calculated sum. The signed integer value of the
; sum is passed to the WriteVal procedure to convert it into a string.
; 
; Preconditions: prompts to be displayed must be type BYTE. The sum is type SDWORD.
; 
; Postconditions: None
; Receives: [EBP+12] = sum
;			[EBP+8] = address for sumMsg
; Returns: None
; ---------------------------------------------------------------------------------
DisplaySum PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	MOV		ESI, [EBP+12]

	; Display Prompt
	mDisplayString [EBP+8]
	PUSH	ESI
	CALL	WriteVal
	CALL	CrLf

	POP		ESI
	POP		EBP
	RET		8
DisplaySum ENDP

; ---------------------------------------------------------------------------------
; Name: RoundedAverage
;
; This procedure calculates the rounded average by dividing the total sum by the
; ARRAYSIZE global variable. The quotient is stored in the roundAvg data variable.
;
; Preconditions: The sum must be calculated and type SDWORD. The ARRAYSIZE
; needs to match the number of elements totaled from the intArray.
;
; Postconditions: None
; 
; Receives: [EBP+16] = roundAvg
;			[EBP+12] = ARRAYSIZE
;			[EBP+8] = sum
;
; Returns: Changes the roundAvg variable.
; ---------------------------------------------------------------------------------
RoundedAverage PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EDX
	PUSH	EBX
	PUSH	ESI

	; Move sum to EAX, ARRAYSIZE to EBX
	MOV		EAX, SDWORD PTR [EBP+8]
	CDQ
	MOV		EBX, [EBP+12]
	IDIV	EBX

	; Store quotient in rounded average
	MOV		ESI, [EBP+16]
	MOV		[ESI], EAX

	POP		ESI
	POP		EBX
	POP		EDX
	POP		EAX
	POP		EBP

	RET		12
RoundedAverage ENDP

; ---------------------------------------------------------------------------------
; Name: DisplayAvg
;
; This procedure displays the rounded average. The signed integer value of the
; average is passed to the WriteVal procedure to convert it into a string.
; 
; Preconditions: prompts to be displayed must be type BYTE. The rounded average
; is type SDWORD.
; 
; Postconditions: None
; Receives: [EBP+12] = roundAvg
;			[EBP+8] = address for avgMsg
; Returns: None
; ---------------------------------------------------------------------------------
DisplayAvg PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI

	MOV		ESI, [EBP+12]

	; Display Prompt
	mDisplayString [EBP+8]
	PUSH	ESI
	CALL	WriteVal
	CALL	CrLf

	POP		ESI
	POP		EBP
	RET		8
DisplayAvg ENDP
; ---------------------------------------------------------------------------------
; Name: Goodbye
;
; Displays a goodbye message to the user.
; Preconditions: byeMsg type BYTE.
; Postconditions: EDX changed by WriteString
; Receives: [EBP+8] = reference to byeMsg
; Returns:  None
; ---------------------------------------------------------------------------------
Goodbye PROC
	PUSH	EBP
	MOV		EBP, ESP

	CALL	CrLf
	mDisplayString [EBP+8]
	
	POP		EBP
	RET		4
Goodbye ENDP

END main
