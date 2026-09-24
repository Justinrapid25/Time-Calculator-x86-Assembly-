
INCLUDE Irvine32.inc ; grabs the Irvine32 prototypes and macros such as WriteString and exit that are used in the program

ENTER_KEY = 13 ; A constant for the Enter key ACII code to avoid magic numbers

.data ; sector that holds data for variables

	; --- Prompt strings that are displayed for the user before each input ---
	hoursPrompt BYTE "Enter the number of hours: ",0 ; prompt the user for number of hours, null-terminated
	minutesPrompt BYTE "Enter the number of minutes: ",0 ; prompt user for number of minutes, null-terminated
	secondsPrompt BYTE "Enter the number of seconds: ",0 ; prompt user for number of seconds, null-terminated
	errorMsg BYTE " Invalid input. Please enter a non-negative whole number.",13,10,0 ; displays error msg, incldes CR/LF for a new line after it

	; --- The labels used when returning the users original input and displays it back to the console ---
	hoursLabel BYTE "The number of hours entered was: ",0 ; label text preceding the returning hours value
	minutesLabel BYTE "The number of minutes entered was: ",0 ; label text preceding the returning minutes value
	secondsLabel BYTE "The number of seconds entered was: ",0 ; label text preceding the returning seconds value
	periodStr BYTE ".",0 ; a period that is printed out when displayed to console after each number is returned

	; --- The labels used when displaying the total for minutes and seconds ---
	totalMinutesLabel BYTE "The total number of minutes is ",0 ; label text preceding the total minutes value
	totalSecondsLabel BYTE "The total number of seconds is ",0 ; label text preceding the total seconds value
	minSuffix BYTE " minutes.",0 ; text printed after the total minutes value 
	secSuffix BYTE " seconds.",0 ; text printed after tht total seconds value

	repeatPrompt BYTE "Try again (Y/N)? ",0 ; a prompt to user asking if they would like to continue using the program

	inputBuffer BYTE 12 DUP(0) ; a reserved buffer space

	; --- The variables that will hold the users validated numeric inputs ---
	hours DWORD ? ; stores a validated hours value entered by the user
	minutes DWORD ? ; stores a validated minutes value entered by the user
	seconds DWORD ? ; stores a validated seconds value entered by the user
	totalMinutes DWORD ? ; stores the total number of minutes
	totalSeconds DWORD ? ; stores the total number of seconds

	; --- Constants used instead of magic numbers for calculations ---
	MIN_PER_HR = 60 ; number of minutes in an hour
	SEC_PER_MIN = 60 ; number of seconds in a minute
	SEC_PER_HR = 3600 ; number of seconds in an hour
	CASE_BIT = 00100000b ; a bit that forces an ASCII letter to lowercase

;---------------------------------------------------
; main
; Prompts for hours, minutes, and seconds; validates
; each input; echoes the values back; computes and
; displays total minutes and total seconds; then offers
; to repeat.
; Input: CLI from user 
; Output:  nothing (interactive console program)
; Memory usage: hours, minutes, seconds, totalMinutes,
;   totalSeconds (write); all prompt/label strings (read)
; Register usage: EAX, EBX, ECX, EDX
;---------------------------------------------------

.code ; sector that contains the main logic of the program
main PROC ; entry point that contains the main procedures for the program
MainLoop: ; the entry point for the main program loop
	
; --- Read and validate hours ---
HoursPromptLoop: ; re-entry point if hours input in invalid
	mov edx,OFFSET hoursPrompt ; edx = the address of the hours prompt string
	call WriteString ; display the hours prompt
	mov ebx,0 ; ebx = accumulator for the hours value and rests to 0

HoursStateA: ; the state the expects the first character of hours input
	call Getnext ; read one keystrong into al, returning it to the console
	call IsDigit ; check if al is a digit, sets zero flag if true
	jz HoursDigitA ; if it's a digit, process it
	call DisplayErrorMsg ; otherwise if it's not a digit, display the error message
	jmp HoursPromptLoop ; restart the hours prompt from the beginning if it's not a digit after dispaying error message

HoursDigitA: ; handles a valid first digit of hours
	movzx eax,al ; zero extended character into eax, which clears upper bits and keeps als value
	sub eax,'0' ; convert the ASCII digit character to its actual numerical value
	imul ecx,10 ; shift the accumulated value up one decimal place
	add ebx,eax ; add in this new digit
	jmp HoursStateC ; move on to reading subsequent characters

HoursStateC: ; statement expecting the second and later character of hours input
	call Getnext ; reade the next keystroke into al, returning it
	cmp al,ENTER_KEY ; check if it's the enter key 
	je HoursDone ; if it is, then the hours value is done

	call IsDigit ; otherwise check if it's a digit
	jz HoursDigitC ; if it is a digit, process it
	call DisplayErrorMsg ; otherwise, display the error message
	jmp HoursPromptLoop ; and then restart the hours prompt from the beginning

HoursDigitC: ; will handle a valid subsequent digit of hours
	movzx eax,al ; zero-extend the character into eax
	sub eax,'0' ; convert ASCII digit to its numeric value
	imul ebx,10 ; shift the accumulated value up one decimal place
	add ebx,eax ; add in the new digit
	jmp HoursStateC ; go back and then read the next character

HoursDone: ; hours input is complete and valid at this point
	call Crlf ; move the cursor to a new line
	mov hours,ebx ; store the final accumulated value into the hours variable

; --- Read and validate minutes ---
MinutesPromptLoop: ; re entry point if minutes input is invalid
	mov edx,OFFSET minutesPrompt ; edx = address of the minutes prompt string
	call WriteString ; display the minutes prompt
	mov ebx,0 ; ebx = accumulator for the minutes value and reset it to 0

MinutesStateA: ; state that expects the first character of minutes input
	call Getnext ; read one keystroke into al, returning it
	call IsDigit ; check if al is a digit
	jz MinutesDigitA ; if it is a digit, process it
	call DisplayErrorMsg ; otherwise if it's not, display the error message
	jmp minutesPromptLoop ; and then restart the minutes prompt

MinutesDigitA: ; handles a valid first digit of minutes
	movzx eax,al ; zero-extend the character into eax
	sub eax,'0' ; convert ASCII digit to its numeric value
	imul ebx,10 ; shift the accumulated value up one decimal
	add ebx,eax ; add in this new digit
	jmp MinutesStateC ; move on to reading the subsequent characters

MinutesStateC: ; the state expecting the second and other characters for minutes
	call Getnext ; read the next keystroke into al, returning it
	cmp al,ENTER_KEY ; is it the enter key?
	je MinutesDone ; if it is, then the minutes value is now complete

	call IsDigit ; if its not the enter key, is it a digit?
	jz MinutesDigitC ; if it is a digit, process it
	call DisplayErrorMsg ; if its no a digit, then display the error message
	jmp MinutesPromptLoop ; now restart the minutes prompt

MinutesDigitC: ; handles any subsequent digits of minutes
	movzx eax,al ; zer0-extend the character into eax
	sub eax,'0' ; convert ASCII digit to its numeric value
	imul ebx,10 ; shift the accumulated value up one decimal place
	add ebx,eax ; add in the new digit
	jmp MinutesStateC ; go back and read the next character

MinutesDone: ; the minutes input is compelte and valid
	call Crlf ; move the cursor to a new line
	mov minutes,ebx ; store the final accumulated value into the minutes variable

; -- Read and validate seconds ---
SecondsPromptLoop: ; re entry point if seconds input is invalid
	mov edx,OFFSET secondsPrompt ; edx = address of the seconds prompt string
	call WriteString ; display the seconds prompt
	mov ebx,0 ; ebx = accumulator for the seconds value and reset it to 0

SecondsStateA: ; state that expects the first character of seconds input
	call Getnext ; read one keystroke into al, returning it
	call Isdigit ; check if al is a digit
	jz SecondsDigitA ; if its a digit, then process it
	call DisplayErrorMsg ; if it is not, then display the error message
	jmp SecondsPromptLoop ; then restart the seconds prompt

SecondsDigitA: ; handles a valid first digit of seconds
	movzx eax,al ; zero extend the character into eax
	sub eax,'0' ; convert ASCII digit to its numeric value
	imul ebx,10 ; shift the accumulated value up one decimal
	add ebx,eax ; add in the new digit
	jmp SecondsStateC ; move on to reading the subsequent characters

SecondsStateC: ; state expecting the second or more characters for seconds
	call Getnext ; read the next keystroke into al, returning it
	cmp al,ENTER_KEY ; is it the enter key?
	je SecondsDone ; if it is, then the seconds value is done

	call IsDigit ; if its not the enter key, check if its a digit
	jz SecondsDigitC ; if its a digit, process it
	call DisplayErrorMsg ; if not, display the error message
	jmp SecondsPromptLoop ; then restart the seconds prompt

SecondsDigitC: ; handles any subsequent digits for seconds
    movzx eax,al ; zero extend the character into eax
    sub eax,'0' ; convert ASCII digit to its numeric value
    imul ebx,10 ; shift the accumulated value up one decimal 
    add ebx,eax ; add in the new digit
    jmp SecondsStateC ; go back and read the next character

SecondsDone: ; the seconds input is complete and valid
	call Crlf ; move the cursor to a new line
	mov seconds,ebx ; store the final accumulated value into the seconds variable

	call Crlf ; blank line before returning the inputs, for readability

	; --- Return the original inputs back to the user through the console ---

	mov edx,OFFSET hoursLabel ; edx = address of the hours returned label
	call WriteString ; display "The number of hours entered was: "
	mov eax,hours ; eax = the stored hours value
	call WriteDec ; display is as a decimal number
	mov edx,OFFSET periodStr ; edx = address of the period string
	call WriteString ; display the trailing period
	call Crlf ; move to a new line

	mov edx,OFFSET minutesLabel ; edx = address of the minutes returned label
	call WriteString ; display "The number of minutes entered was: "
	mov eax,minutes ; eax = the stored minutes value
	call WriteDec ; display is as a decimal number
	mov edx,OFFSET periodStr ; edx = address of the period string
	call WriteString  ; display the trailing period declared earlier in .data
	call Crlf ; move to a new line

	mov edx,OFFSET secondsLabel ; edx = address of the seconds returned label
	call WriteString ; display "The number of seconds entered was: "
	mov eax,seconds ; eax = the stored seconds value
	call WriteDec ; display it as a decimal number
	mov edx,OFFSET periodStr ; edx = address of the period string
	call WriteString ; display the trailing period declared earlier
	call Crlf ; move to a new line
	call Crlf ; blank line before displaying the totals for readability 

	; --- Computation for total minutes ---
	mov eax,hours ; eax = hours
	mov ecx,MIN_PER_HR ; ecx = 60 which is minutes per hour
	mul ecx ; eax = hours * 60 an unsigned multiply result in eax
	add eax,minutes ; eax now = hours * 60 + minutes
	mov totalMinutes,eax ; store the result in the totalMinutes variable

	; --- Computation for total seconds ---
	mov eax,hours ; eax = hours
	mov ecx,SEC_PER_HR ; ecx = 3600 which is seconds per hour
	mul ecx ; eax = hours * 3600
	mov esi,eax ; esi = running total which is currently hours * 3600

	mov eax,minutes ; eax = minutes
	mov ecx,SEC_PER_MIN ; ecx = 60 which is seconds per minute
	mul ecx ; eax = minutes * 60
	add esi,eax ; esi += minutes * 60
	add esi,seconds ; edx += seconds
	mov totalSeconds,esi ; store the final result in totalSeconds variable

	; --- Display the totals to the console ---
	mov edx,OFFSET totalMinutesLabel ; edx = address of the total minutes label
	call WriteString ; display "The total number of minutes is "
	mov eax,totalMinutes ; eax = the computed total minutes
	call WriteDec ; display it as a decimal number
	mov edx,OFFSET minSuffix ; edx = address of the " minutes." suffix
	call WriteString ; display the sffix
	call Crlf ; move to a new line

	mov edx,OFFSET totalSecondsLabel ; edx = address of the total seconds label
	call WriteString ; display "The total number of seconds is "
	mov eax,totalSeconds ; eax = the computed total seconds
	call WriteDec ; display it as a decimal number
	mov edx,OFFSET secSuffix ; edx = address of the "seconds" suffix
	call WriteString ; display the suffix
	call Crlf ; move to a new line
	call Crlf ; have a blank line before the repeat prompt is displayed for readability

	; --- Ask user if they would like to repeat ---
	mov edx,OFFSET repeatPrompt ; edx = address of the repeat prompt string
	call WriteString ; display "Try again (Y/N)?"
	call ReadChar ; read a single keystroke into al (will not need an Enter)
	call WriteChar ; return the keystroke to the screen
	call Crlf ; move to a new line
	call Crlf ; have a blank line before the repeat prompt display for readability

	or al,CASE_BIT ; force the character to lowercase, refardless
	cmp al,'y' ; compare against the lowercase 'y'
	je MainLoop ; if it matches, then restart the entire program from the very top

	exit ;  if N is entered, terminate the program
main ENDP ; end main procedure

; --- Reads a character from standard input and returns it ---
Getnext PROC ; entry point for the Getnext procedure
	call ReadChar ; read one keystroke from the keyboard into al
	call WriteChar ; return that character to the console screen to display it
	ret ; return to the caller
Getnext ENDP ; end the procedure

; --- Display the error message letting the user know to enter a valid input ---
DisplayErrorMsg PROC ; entry point for the error message procedure
	push edx ; save the callers edc value, since WriteString will be overwritten
	mov edx,OFFSET errorMsg ; edx = address of the error message string
	call WriteString ; display the error message
	pop edx ; restore the callers original edx value
	ret ; return to the caller
DisplayErrorMsg ENDP ; end the error message procedure

END main ; FINALLY, this marks the end of the source file and identitfies main as the entry point for the program

;phew


