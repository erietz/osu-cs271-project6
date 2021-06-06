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
; Preconditions: 
;
; Postconditions: 
;
; Receives: 
;   - Address of the prompt string passed on the stack
;   - Address of a byte array to store the result in passed on the stack
;   - Address of a dword variable to store the number of bytes of the string 
;       that has been read in
;   - Global constant MAX_LENGTH
;
; Returns: 
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
; characters but only really 2.  MAX_LENGTH will be set higher than 12 to allow
; leading zeros.
;
MAX_LENGTH = 20
; Read 10 ints from user
; TODO: set to 10
NUM_INTS = 10

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
strDelimeter    byte    ", ",0

.code
main PROC

    ; Print the program title, introduction, and instructions to user.----------
    mov     edx, offset strIntro
    call    WriteString

    ; Get values from the user--------------------------------------------------
    mov     ecx, NUM_INTS
    mov     edi, offset userValues

    _getNumbers:
        ; reads users string into userValue
        push    offset strInvalid   ; +20
        push    offset strPrompt    ; +16
        push    offset userInput    ; +12
        push    offset byteCount    ; +8
        push    offset userValue    ; +4
        call    ReadVal             ; should return 4*4 = 16
        ; fill position in userValues with userValue
        mov     ebx, userValue
        mov     [edi], ebx
        add     edi, type userValues
        loop    _getNumbers

    call    CrLf

    ; Calculate sum and print out users values----------------------------------
    mDisplayString  offset strYouEntered
    call    CrLf

    mov     esi, offset userValues
    mov     ecx, NUM_INTS
    _calculateSum:
        mov     ebx, [esi]
        add     sum, ebx
        add     esi, type userValues
        push    ebx
        push    offset strUserValue
        push    lengthof strUserValue
        call    WriteVal

        cmp     ecx, 1
        je      _endLoop
        mDisplayString  offset strDelimeter
        loop    _calculateSum

        _endLoop:
            call    CrLf
            call    CrLf

    ; Calculate the average-----------------------------------------------------
    _calculateAvg:
        mov     eax, sum
        mov     ebx, NUM_INTS
        cdq     ; sign extend eax into edx for 32 bit signed division
        idiv    ebx
        mov     average, eax

    ; Display the sum of the numbers--------------------------------------------
    mDisplayString  offset strTheSumIs

    push    sum
    push    offset strUserValue
    push    lengthof strUserValue
    call    WriteVal
    call    CrLf

    ; Display the average of the numbers----------------------------------------
    mDisplayString  offset strTheAvgIs

    push    average
    push    offset strUserValue
    push    lengthof strUserValue
    call    WriteVal
    call    CrLf
    call    CrLf

    ; Print a farewell message--------------------------------------------------
    mDisplayString  offset strClosing

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

ReadVal     proc
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
    mov     eax, 0              ; initialize eax for string processing
    mov     ebx, 0              ; sum of digits
    mov     esi, [ebp+16]       ; point lodsb to the start of userInput
    mov     ecx, byteCount
    cld

    _checkDigit:
        lodsb
        cmp     ecx, byteCount
        je      _firstCharacter
        jmp     _notFirstCharacter

        _firstCharacter:
            cmp     al, 45  ; ascii 45 is equal to "-" 
            je      _negative
            cmp     al, 43  ; ascii 43 is equal to "+"
            je      _positive
            jmp     _notFirstCharacter

            _negative:
                mov     userValueSign, 1
                loop     _checkDigit

            _positive:
                loop    _checkDigit

        _notFirstCharacter:
            cmp     al, 48  ; ascii 48 is equal to 0
            jl      _numberIsInvalid
            cmp     al, 57  ; ascii 57 is equal to 9
            jg      _numberIsInvalid

            _numberIsValid:
                sub     al, 48  ; convert ascii [48-57] to digit [0-9]
                push    eax
                mov     eax, ebx
                mul     multiplier
                mov     ebx, eax
                pop     eax
                add     ebx, eax
                loop    _checkDigit
                jmp     _storeValue

            _numberIsInvalid:
                mDisplayString  [ebp+24]
                jmp     _promptForInput

    _storeValue:
        cmp     userValueSign, 1
        jne      _checkTooBig

        _checkTooSmall:
            cmp     ebx, 80000000h
            ja      _magnitudeTooLarge
            neg     ebx
            jmp     _actuallyStoreNum

        _checkTooBig:
            cmp     ebx, 7FFFFFFFh
            ja      _magnitudeTooLarge
            jmp     _actuallyStoreNum

            _magnitudeTooLarge:
                mDisplayString  [ebp+24]
                jmp     _promptForInput

        _actuallyStoreNum:
            mov     edi, [ebp+8]
            mov     [edi], ebx

    popad
    ret     20
ReadVal     endp

WriteVal    proc
    LOCAL userValueSign:dword, divisor:dword
    pushad
    ; ebp+16 = value of sdword
    ; ebp+12 = address of strUserValue
    ; ebp+8  = length of strUserValue


    mov     userValueSign, 0  ; negative
    mov     edi, [ebp+12]
    add     edi, [ebp+8]
    dec     edi
    std
    mov     al, 0
    stosb
    mov     eax, [ebp+16]
    mov     divisor, 10
    mov     edx, 0          ; clear out to store remainder of divisions
    add     eax, 0
    jns     _loop
    mov     userValueSign, 1
    neg     eax

    ; The number 2134 will be stored in memory like "00000856" so we must keep
    ; looping from the right side until we hit a 0. This means we have printed
    ; all of the number
    _loop:
        div    divisor
        add     edx, 48
        push    eax
        mov     al, dl
        stosb
        pop     eax

        mov     edx, 0      ; clear out to store remainder of division
        cmp     eax, 0
        jne    _loop

    cmp     userValueSign, 0

    je     _positive
    ; print out a minus sign
    mov     al, 45  ; ascii 45 is equal to "-"
    stosb

    _positive:
        inc     edi
        mDisplayString  edi

    popad
    ret     12
WriteVal     endp

END main
