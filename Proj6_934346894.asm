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

strYouEntered   byte    "You entered the following numbers:",13,10,0
strTheSumIs     byte    "The sum of these numbers is: ",0
strTheAveIs     byte    "The rounded averagea is: ",0
strClosing      byte    "Thanks for playing!!!",0

.code
main PROC

    ; Print the program title, introduction, and instructions to user.----------
    mov     edx, offset introTitle
    call    WriteString


    ; Get values from the user--------------------------------------------------
    mov     ecx, NUM_INTS
    mov     edi, offset userValues
    _getNumbers:
        push    offset promptInput  ; +16
        push    offset userInput    ; +12
        push    offset byteCount    ; +8
        push    offset userValue    ; +4
        call    ReadVal             ; should return 4*4 = 16
        mov     ebx, userValue
        mov     [edi], ebx
        add     edi, type userValues

        mov     edx, offset userInput
        call    WriteString
        call    CrLf

        mov     eax, byteCount
        call    WriteDec
        call    CrLf

        ;mov     eax, userValue
        ;call    WriteInt
        loop    _getNumbers

    ; Display results-----------------------------------------------------------
    mDisplayString  offset strYouEntered

    mov     ecx, NUM_INTS
    mov     edi, offset userValues
    _calculateSum:
        loop    _calculateSum

    mDisplayString  offset strTheSumIs
    call    CrLf

    mDisplayString  offset strTheAveIs
    call    CrLf

    mDisplayString  offset strClosing



    ;mGetString  offset promptInput, offset userInput, offset byteCount
    ;mDisplayString  offset userInput
    ;mov     eax, byteCount
    ;call    WriteDec

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

ReadVal     proc
    push    ebp
    mov     ebp, esp
    pushad

    mGetString  [ebp+20], [ebp+16], [ebp+12]
    ;mov     edi, [ebp+8]
    ;mov     ebx, [ebp+12]
    ;mov     [edi], ebx     ; need to be the same size array elements

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
