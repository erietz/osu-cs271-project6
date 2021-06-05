TITLE FIXME     (FIXME.asm)

; Author                : Ethan Rietz
; Last Modified         : 2021-06-03
; OSU email address     : rietze@oregonstate.edu
; Course number/section : CS271 Section 400
; Project Number        : 6
; Due Date              : 2021-06-6
; Description           : \
;   FIXME

INCLUDE Irvine32.inc

; (insert macro definitions here)

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

; (insert constant definitions here)
;
; An SDWORD is 32 bits and can hold numbers in the range from -2^31 to 2^31 - 1.
; This is equivilent to -2147483648 to +2147483647
;
; ReadString seems to only read 10 so adding 1 plus an extra to check if too
; long
MAX_LENGTH = 11 + 2     
; Read 10 ints from user
NUM_INTS = 3

.data

; Note: lines are limited to 512 characters in MASM and this string is really
; close to that limit
introTitle      byte    "String Primitives and Macros",13,10,"Written by: Ethan",
                        " Rietz",13,10,13,10,"Please provide 10 signed decimal",
                        " integers.",13,10,"Each number needs to be small enough",
                        " to fit inside a 32 bit register. After you have finished",
                        " inputting the raw numbers, I will display a list of",
                        " the integers, their sum, and their average value.",13,10,13,10,0

promptInput     byte    "Please enter a signed number: ",0
userInput       byte    MAX_LENGTH dup(?)
byteCount       dword   ?

userValues      sdword  NUM_INTS dup(?)
userValue       sdword  ?

sum             sdword  ?
average         sdword  ?

strYouEntered   byte    "You entered the following numbers:",13,10,0
strTheSumIs     byte    "The sum of these numbers is: ",0
strTheAvgIs     byte    "The rounded average is:      ",0
strClosing      byte    "Thanks for playing!!!",0

strInvalid      byte    "Number Invalid... Try again",13,10,0

.code
main PROC

    ; Print the program title, introduction, and instructions to user.----------
    mov     edx, offset introTitle
    call    WriteString


    ; Get values from the user--------------------------------------------------
    mov     ecx, NUM_INTS
    mov     edi, offset userValues
    _getNumbers:
        ; reads users string into userValue
        push    offset promptInput  ; +16
        push    offset userInput    ; +12
        push    offset byteCount    ; +8
        push    offset userValue    ; +4
        call    ReadVal             ; should return 4*4 = 16
        ; fill position in userValues with userValue
        mov     ebx, userValue
        mov     [edi], ebx
        add     edi, type userValues

        ;mov     edx, offset userInput
        ;call    WriteString
        ;call    CrLf
        ;mov     eax, byteCount
        ;call    WriteDec
        ;call    CrLf
        ;mov     eax, userValue
        ;call    WriteInt

        loop    _getNumbers

    ; Calculate sum, average, and display results-------------------------------
    mDisplayString  offset strYouEntered

    mov     esi, offset userValues
    mov     ecx, NUM_INTS
    _calculateSum:
        mov     ebx, [esi]
        add     sum, ebx
        add     esi, type userValues

        mov     eax, ebx
        call    WriteInt
        call    CrLf

        loop    _calculateSum

    _calculateAvg:
        mov     eax, sum
        mov     ebx, NUM_INTS
        cdq     ;TODO: what does this do?
        idiv    ebx
        mov     average, eax

    mDisplayString  offset strTheSumIs
    mov     eax, sum
    call    WriteInt
    call    CrLf

    mDisplayString  offset strTheAvgIs
    mov     eax, average
    call    WriteInt
    call    CrLf

    mDisplayString  offset strClosing


    ;mGetString  offset promptInput, offset userInput, offset byteCount
    ;mDisplayString  offset userInput
    ;mov     eax, byteCount
    ;call    WriteDec

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

ReadVal     proc
    ;[ebp+20] = promptInput
    ;[ebp+16] = userInput
    ;[ebp+12] = byteCount
    ;[ebp+8]  = userValue (output)
    push    ebp
    mov     ebp, esp
    pushad


    ; The number 3945 = 3E3 + 9E2 + 4E1 + 5E0
    _promptForInput:
        mGetString  [ebp+20], [ebp+16], [ebp+12]

    mov     ebx, 0  ; set to False for number being negative
    mov     eax, 0  ; initialize eax for string processing
    mov     edx, 0  ; sum of digits
    mov     esi, [ebp+16]
    mov     ecx, byteCount
    ; for looping throug in reverse
    ;add     esi, ecx
    ;dec     esi
    cld     ; clear direction flag

    _checkDigit:
        ;std     ; set direction flag to decrement ESI and EDI for string instructions 
        lodsb
        cmp     ecx, byteCount
        je      _firstCharacter
        jmp     _notFirstCharacter

        _firstCharacter:
            cmp     al, 45  ; "-"
            je      _negative
            jmp     _notFirstCharacter

            _negative:
                mov     ebx, 1
                loop     _checkDigit

        _notFirstCharacter:
            cmp     al, 48
            jl      _numberIsInvalid
            cmp     al, 57
            jg      _numberIsInvalid

            _numberIsValid:
                sub     al, 48
                push    eax
                mov     eax, edx
                push    ebx
                mov     ebx, 10
                mul     ebx
                pop     ebx
                mov     edx, eax
                pop     eax
                add     edx, eax
                loop    _checkDigit
                jmp     _storeValue

            _numberIsInvalid:
                push    edx
                mov     edx, offset strInvalid
                call    WriteString
                pop     edx
                jmp     _promptForInput

    _storeValue:
        cmp     ebx, 1
        jne      _storePositive
        neg     edx

        _storePositive:
            mov     edi, [ebp+8]
            mov     [edi], edx

    popad
    pop     ebp
    ret     16
ReadVal     endp

WriteVal    proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
WriteVal     endp

calcAverage     proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
calcAverage     endp

displayResults  proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
displayResults  endp

END main
