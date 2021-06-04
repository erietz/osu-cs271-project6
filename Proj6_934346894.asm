TITLE <FIXME>     (FIXME.asm)

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

mGetString  macro prompt count
    ; macro body
endm

mDisplayString  macro string
    ; macro body
endm

; (insert constant definitions here)

.data

; (insert variable definitions here)

.code
main PROC

; (insert executable instructions here)

    Invoke ExitProcess,0    ; exit to operating system
main ENDP

; (insert additional procedures here)

ReadVal     proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     FIXME
ReadVal     endp

WriteVal    proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     FIXME
WriteVal     endp

introduction    proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     FIXME
introduction    endp

calcAverage     proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     FIXME
calcAverage     endp

displayResults  proc
    push    ebp
    mov     ebp, esp
    pushad

    popad
    pop     ebp
    ret     FIXME
displayResults  endp

END main
