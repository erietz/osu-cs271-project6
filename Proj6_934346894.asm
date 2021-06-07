TITLE FIXME     (FIXME.asm)

; Author                : Ethan Rietz
; Last Modified         : 2021-06-03
; OSU email address     : rietze@oregonstate.edu
; Course number/section : CS271 Section 400
; Project Number        : 6
; Due Date              : 2021-06-6
; Description           : \
;   Prompts a user to enter 10 signed integers and prints the numbers, their
;   sum, and their average. If the user inputs a numbers that is too large or
;   too small to fit in a 32 bit register, or the user enters characters that
;   are not 0-9, they are repeatedly prompted to enter valid numbers. This
;   program uses Irvines ReadString and WriteString to get the user input, but
;   uses custom procedures to store the ascii strings as signed integers
;   internally. To print out the signed integers, the program internally
;   converts the signed integers back to ascii strings.

INCLUDE Irvine32.inc

; -----------------------------------------------------------------------------
; Name: mGetString
;
; This macro prompts the user using Irvine's WriteString procedure to input a
; string and then reads a string of length MAX_LENGTH from the user using
; Irvines ReadString procedure and stores the result.
;
; Receives: 
;   - promptAddr    = Address of the prompt string passed on the stack
;   - userInputAddr = Address of a byte array to store the result in passed on 
;                     the stack
;   - byteCountAddr = Address of a dword variable to store the number of bytes 
;                     of the string that has been read in
;   - Global constant MAX_LENGTH
;
; Returns: 
;   - userInputAddr points to the start of the string that has been read
;   - byteCountAddr points to the number of bytes read
; -----------------------------------------------------------------------------
mGetString  macro promptAddr, userInputAddr, byteCountAddr
    push    edx
    push    ecx
    push    eax
    push    edi

    mov     edx, promptAddr
    call    WriteString


    mov     edx, userInputAddr
    mov     ecx, MAX_LENGTH
    call    ReadString
    mov     edi, byteCountAddr
    mov     [edi], eax

    pop     edi
    pop     eax
    pop     ecx
    pop     edx
endm

; -----------------------------------------------------------------------------
; Name: mDisplayString
;
; Takes an address of a byte string and prints it to the console using Irvine's
; WriteString procedure
;
; Receives: 
;   - stringAddr = the address of the string to print
;
; Returns: None
; -----------------------------------------------------------------------------
mDisplayString  macro stringAddr
    push    edx
    mov     edx, stringAddr
    call    WriteString
    pop     edx
endm

; An SDWORD is 32 bits and can hold numbers in the range from -2^31 to 2^31 - 1.
;
; This is equivilent to -2147483648 (8000 0001h) to +2147483647 (7FFF FFFFh) or
; 10 characters + sign + null terminator = 12 characters.. However, the user
; could enter a number with leading zeros like 000002 which would be 6
; characters but only really 2. MAX_LENGTH will be set higher than 12 to allow
; leading zeros.
;
MAX_LENGTH = 20
NUM_INTS = 10   ; Read 10 ints from user

.data

; Note: lines are limited to 512 characters in MASM and this string is really
; close to that limit
strIntro        byte    "String Primitives and Macros",13,10,"Written by: Ethan",
                        " Rietz",13,10,13,10,"Please provide 10 signed decimal",
                        " integers.",13,10,"Each number needs to be small enough",
                        " to fit inside a 32 bit register. After you have finished",
                        " inputting the raw numbers, I will display a list of",
                        " the integers, their sum, and their average value.",13,10,13,10,0

strPrompt       byte    "Please enter a signed number (of this form [+-]\d+): ",0
userInput       byte    MAX_LENGTH dup(?)
byteCount       dword   ?

userValues      sdword  NUM_INTS dup(?)
userValue       sdword  ?
strUserValue    byte    MAX_LENGTH dup(?)

sum             sdword  ?
average         sdword  ?

strYouEntered   byte    "You entered the following numbers:",13,10,0
strTheSumIs     byte    "The sum of these numbers is: ",0
strTheAvgIs     byte    "The rounded average is:      ",0
strClosing      byte    "Thanks for playing!!!",0

strInvalid      byte    "ERROR: You did not enter a signed number or your",
                        " number was too big or too small.",13,10,0
strDelimeter    byte    ", ",0  ; used to print the numbers in a line

.code
main PROC

    ; Print the program title, introduction, and instructions to user.----------
    mDisplayString  offset strIntro

    ; Get values from the user--------------------------------------------------
    mov     ecx, NUM_INTS           ; fill the array userValues of length NUM_INTS
    mov     edi, offset userValues

    _getNumbers:
        ; reads users string into userValue
        push    offset strInvalid   ; +20
        push    offset strPrompt    ; +16
        push    offset userInput    ; +12
        push    offset byteCount    ; +8
        push    offset userValue    ; +4
        call    ReadVal             ; should return 4*5 = 20
        ; fill position in userValues with userValue
        mov     ebx, userValue
        mov     [edi], ebx
        add     edi, type userValues    ; prepare to fill next index
        loop    _getNumbers

    call    CrLf

    ; Calculate sum and print out users values----------------------------------
    mDisplayString  offset strYouEntered
    call    CrLf

    ; loop through userValues, print value, and add to sum
    mov     esi, offset userValues  ; loop through each of userValues
    mov     ecx, NUM_INTS
    _calculateSum:
        ; add to the sum and prepare for next iteration
        mov     ebx, [esi]
        add     sum, ebx
        add     esi, type userValues
        ; actually print the value
        push    ebx                     ; send value to WriteVal
        push    offset strUserValue     ; string version will be written to strUserValue
        push    lengthof strUserValue   ; need to know length of string
        call    WriteVal

        cmp     ecx, 1                  ; don't print delimiter on last iteration
        je      _endLoop
        mDisplayString  offset strDelimeter
        loop    _calculateSum

        _endLoop:
            call    CrLf
            call    CrLf

    ; Calculate the average-----------------------------------------------------
    _calculateAvg:
        mov     eax, sum        ; average is sum/NUM_INTS
        mov     ebx, NUM_INTS
        cdq     ; sign extend eax into edx for 32 bit signed division
        idiv    ebx
        mov     average, eax

    ; Display the sum of the numbers--------------------------------------------
    mDisplayString  offset strTheSumIs

    push    sum                     ; display value of sum
    push    offset strUserValue     ; store string version of sum in strUserValue
    push    lengthof strUserValue
    call    WriteVal
    call    CrLf

    ; Display the average of the numbers----------------------------------------
    mDisplayString  offset strTheAvgIs

    push    average                 ; display value of average
    push    offset strUserValue     ; store average as string in strUserValue
    push    lengthof strUserValue
    call    WriteVal
    call    CrLf
    call    CrLf

    ; Print a farewell message--------------------------------------------------
    mDisplayString  offset strClosing

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

; -----------------------------------------------------------------------------
; Name: ReadVal
;
; Reads a signed integer from the user and stores the results in one of the
; passed variable as a SDWORD. If the integer is too large to fit in a 32 bit
; register, the user is prompted again. The string version of the user input is
; also stored in a passed variable in addition to the length of the passed
; string.
;
; Preconditions: The macro mGetString needs to be defined to get a string 
;                and length of the string from the user.
;
; Receives:
;   1) address of string to display an invalid message if number is out of range
;   2) address of string to prompt the user to enter a number
;   3) address of string to store the string version of the user input
;   4) address of a dword variable to store the length of users entered string
;   5) address of a sdword variable to store the validated signed value
;
; Returns:
;   - ascii representation of string is stored in (3)
;   - number of bytes read from the user's string stored in (4)
;   - signed integer stored in (5)
; -----------------------------------------------------------------------------
ReadVal     proc
    ;userValueSign set to 1 if number is negative, otherwise 0
    ;multiplier is set to 10
    LOCAL userValueSign:dword, multiplier:dword
    pushad
    ;[ebp+24] = strInvalid (input)
    ;[ebp+20] = strPrompt (input)
    ;[ebp+16] = userInput (output)
    ;[ebp+12] = byteCount (output)
    ;[ebp+8]  = userValue (output)

    ; The number 3945 = 3E3 + 9E2 + 4E1 + 5E0
    ; Here we are storing 3945 as string by taking each digit, multiping by 10,
    ; and adding it to a sum.
    _promptForInput:
        mGetString  [ebp+20], [ebp+16], [ebp+12]

    mov     userValueSign, 0    ; set to False for number being negative
    mov     multiplier, 10      ; repeatedly multiply by 10 in loop
    mov     ebx, 0              ; sum of digits stored in ebx through loop
    mov     esi, [ebp+16]       ; point lodsb to the start of userInput
    mov     eax, [ebp+12]       ; store value of byteCount
    mov     ecx, [eax]          ; loop through length of passed string
    cmp     ecx, 12
    ja      _numberIsInvalid
    mov     eax, 0              ; initialize eax for string processing
    cld                         ; clear direction flag for string primitive

    _checkDigit:
        lodsb                   ; load digit into al
        push    eax             ; save value of eax
        mov     eax, [ebp+12]   ; load into eax byteCount
        cmp     ecx, [eax]      ; first digit could be either "+" or "-"
        pop     eax             ; return saved value of eax
        je      _firstCharacter
        jmp     _notFirstCharacter

        _firstCharacter:
            cmp     al, 45      ; ascii 45 is equal to "-" 
            je      _negative
            cmp     al, 43      ; ascii 43 is equal to "+"
            je      _positive
            jmp     _notFirstCharacter  ; need to check if char is between 0-9

            _negative:
                mov     userValueSign, 1    ; set local flag to negative
                loop     _checkDigit        ; continue

            _positive:
                loop    _checkDigit         ; continue

        _notFirstCharacter:
            cmp     al, 48  ; ascii 48 is equal to 0
            jl      _numberIsInvalid
            cmp     al, 57  ; ascii 57 is equal to 9
            jg      _numberIsInvalid

            _numberIsValid:
                sub     al, 48          ; convert ascii [48-57] to digit [0-9]
                push    eax             ; multiplication requires eax also
                mov     eax, ebx        ; multiply sum by 10 and add digit
                mul     multiplier
                mov     ebx, eax
                pop     eax
                add     ebx, eax
                loop    _checkDigit         ; check next digit
                jmp     _storeValue         ; skip next stuff at end of loop

            _numberIsInvalid:
                mDisplayString  [ebp+24]    ; print string is invalid
                jmp     _promptForInput

    _storeValue:
        cmp     userValueSign, 1
        jne      _checkTooBig

        _checkTooSmall:                 ; if negative, compare to -2147483648
            cmp     ebx, 80000000h      ; do unsigned comparison, then convert to signed
            ja      _magnitudeTooLarge
            neg     ebx
            jmp     _actuallyStoreNum

        _checkTooBig:
            cmp     ebx, 7FFFFFFFh          ; if positive compare to +2147483647
            ja      _magnitudeTooLarge
            jmp     _actuallyStoreNum

            _magnitudeTooLarge:             ; num can't fit in 32 bit register
                mDisplayString  [ebp+24]    ; inform user
                jmp     _promptForInput     ; ask for another number

        _actuallyStoreNum:
            mov     edi, [ebp+8]            ; move index to userValue
            mov     [edi], ebx              ; store number at index

    popad
    ret     20
ReadVal     endp

; -----------------------------------------------------------------------------
; Name: WriteVal
;
; Loads an SDWORD from memory, converts to a string and displays the string to
; the console.
;
; Preconditions: The macro mDisplayString need to be defined to display a
;                string passed by address.
;
; Receives:
;   1) value of sdword
;   2) address of start of byte array to store ascii representation of SDWORD
;      into
;   3) value of the length of the byte array in (2)
;
; Returns:
;   - byte array (2) will be overwritten with the string representation of the
;     passed SDWORD
; -----------------------------------------------------------------------------
WriteVal    proc
    ; userValueSign is a flag set to 1 if number is negative, otherwise 0
    ; divisor is set to 10 for repeated divisions in algorithm
    LOCAL userValueSign:dword, divisor:dword
    pushad
    ; ebp+16 = value of sdword
    ; ebp+12 = address of strUserValue
    ; ebp+8  = length of strUserValue

    mov     userValueSign, 0    ; set flag to initially be positive
    mov     edi, [ebp+12]       ; start address of array where string is stored
    add     edi, [ebp+8]        ; move index to end of array
    dec     edi                 ; index is index - 1
    std                         ; set direction flag to loop backwards
    mov     al, 0               ; string primitives stored in al
    stosb                       ; copy value in edi to al and increment edi
    mov     eax, [ebp+16]       ; load value of val
    mov     divisor, 10
    mov     edx, 0              ; clear out to store remainder of divisions
    add     eax, 0              ; check to see if val is negative
    jns     _loop
    mov     userValueSign, 1    ; if we didn't jump, val is negative
    neg     eax

    ; The number 2134 will be stored in memory like "00000856" so we must keep
    ; looping from the right side until we hit a 0. This means we have printed
    ; all of the number
    _loop:
        div    divisor          ; eax holds val
        add     edx, 48         ; convert digit to ascii
        push    eax             ; division uses eax
        mov     al, dl
        stosb
        pop     eax

        mov     edx, 0          ; clear out to store remainder of next division
        cmp     eax, 0          ; when we get to 0/10, we are done
        jne    _loop

    cmp     userValueSign, 0

    je     _positive
    ; store a minus sign
    mov     al, 45  ; ascii 45 is equal to "-"
    stosb

    _positive:
        inc     edi
        mDisplayString  edi

    popad
    ret     12
WriteVal     endp

END main
