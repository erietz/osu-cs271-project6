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


    mov     edx, offset userInputAddr
    mov     ecx, 30
    call    ReadString
    mov     edi, byteCountAddr
    mov     [edi], eax

    pop     edi
    pop     eax
    pop     ecx
    pop     edx
endm

mDisplayString  macro string
    ; macro body
endm

; (insert constant definitions here)

.data

promptInput     byte    "Please enter a signed number: ",0
userInput       byte    50 dup(?)
byteCount       dword   ?

.code
main PROC

; (insert executable instructions here)
    mGetString  offset promptInput, offset userInput, offset byteCount

    mov     edx, offset userInput
    call    WriteString
    call    CrLf

    mov     eax, byteCount
    call    WriteDec

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal     proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
ReadVal     endp

WriteVal    proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
WriteVal     endp

introduction    proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     
introduction    endp

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
