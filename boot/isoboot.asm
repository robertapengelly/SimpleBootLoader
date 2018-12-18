bits    16
org     0

boot:

    cli
    jmp     Mem.Stage1.Segment : start
    times   8 - ($ - $$)    nop

iso_boot_info:

    .bi_pvd:                    dd      16
    .bi_file:                   dd      0
    .bi_length:                 dd      0xdeadbeef
    .bi_csum:                   dd      0xdeadbeef
    .bi_reserved:               times   10  dd  0xdeadbeef
    .bi_end:

start:

    ;----------------------------------------------------------------------
    ; setup our segment registers and the stack
    ;----------------------------------------------------------------------
    mov     ax,     cs
    mov     ds,     ax
    mov     es,     ax
    mov     fs,     ax
    mov     gs,     ax
    
    xor     ax,     ax
    mov     ss,     ax
    mov     sp,     Mem.Stack.Top
    
    ;----------------------------------------------------------------------
    ; restore interrupts
    ;----------------------------------------------------------------------
    sti
    
    ;----------------------------------------------------------------------
    ; print a our hello message
    ;----------------------------------------------------------------------
    mov     si,     String.Hello
    call    PrintString
    
    ;----------------------------------------------------------------------
    ; print a our hexadecimal string
    ;----------------------------------------------------------------------
    mov     si,     String.Hexadecimal
    call    PrintString
    
    ;----------------------------------------------------------------------
    ; print binary as hexadecimal
    ; ouput: 1BADB002
    ;----------------------------------------------------------------------
    mov     eax,    00011011101011011011000000000010b
    call    PrintHex8
    
    ;----------------------------------------------------------------------
    ; print a new line
    ;----------------------------------------------------------------------
    mov     si,     String.CRLF
    call    PrintString
    
    ;----------------------------------------------------------------------
    ; print our decimal string
    ;----------------------------------------------------------------------
    mov     si,     String.Decimal
    call    PrintString
    
    ;----------------------------------------------------------------------
    ; print the above binary as decimal
    ; ouput: 464367618
    ;----------------------------------------------------------------------
    call    PrintDec32
    
    ;----------------------------------------------------------------------
    ; wait for keypress then restart
    ;----------------------------------------------------------------------
    xor     ax,     ax
    int     0x16
    jmp     Reboot

;==============================================================================
; @function             PrintChar
; @details              Prints a character to the console.
;==============================================================================
PrintChar:

    ;--------------------------------------------------------------------------
    ; both ax and bx registers get clobbered when printing a character
    ; so save them both to the stack first
    ;--------------------------------------------------------------------------
    push    ax
    push    bx
    
    mov     ah,     0eh                                 ; teletype output
    xor     bx,     bx                                  ; page number
    int     0x10                                        ; invoke
    
    ;--------------------------------------------------------------------------
    ; restore the original ax and bx values and return
    ;--------------------------------------------------------------------------
    pop     bx
    pop     ax
    ret

;==============================================================================
; @function             PrintDec8
; @details              Prints a decimal number store in al.
;==============================================================================
PrintDec8:

    push    eax
    movzx   eax,    al
    jmp     short   PrintDecCommon

;==============================================================================
; @function             PrintDec16
; @details              Prints a decimal number store in ax.
;==============================================================================
PrintDec16:

    push    eax
    movzx   eax,    ax
    jmp     short   PrintDecCommon

;==============================================================================
; @function             PrintDec32
; @details              Prints a decimal number store in eax.
;==============================================================================
PrintDec32:

    push    eax

;==============================================================================
; @function             PrintDecCommon
; @details              Prints a decimal number to the console.
;==============================================================================
PrintDecCommon:

    push    ebx
    push    ecx
    push    edx
    
    mov     ebx,    10
    xor     cx,     cx
    
    .cloop:
    
        mov     edx,    0
        div     ebx
        inc     cx
        push    dx
        and     eax,    eax
        jnz     .cloop
    
    .dloop:
    
        pop     ax
        add     al,     '0'
        call    PrintChar
        loop    .dloop
    
    .done:
    
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
        ret

;==============================================================================
; @function             PrintHex2
; @details              Prints a hex number stored in al.
;==============================================================================
PrintHex2:

    push    eax
    push    ecx
    
    rol     eax,    24
    mov     cx,     2
    jmp     short   PrintHexCommon

;==============================================================================
; @function             PrintHex4
; @details              Prints a hex number stored in ax.
;==============================================================================
PrintHex4:

    push    eax
    push    ecx
    
    rol     eax,    16
    mov     cx,     4
    jmp     short   PrintHexCommon

;==============================================================================
; @function             PrintHex8
; @details              Prints a hex number stored in eax.
;==============================================================================
PrintHex8:

    push    eax
    push    ecx
    
    mov     cx,     8

;==============================================================================
; @function             PrintHexCommon
; @details              Prints a hex number to the console.
;==============================================================================
PrintHexCommon:

    .loop:
    
        rol     eax,    4
        push    eax
        
        and     al,     0x0F
        cmp     al,     10
        jae     .high
    
    .low:
    
        add     al,     '0'
        jmp     short   .is_char
    
    .high:
    
        add     al,     'A' - 10
    
    .is_char:
    
        call    PrintChar
        pop     eax
        loop    .loop
    
    .done:
    
        pop     ecx
        pop     eax
        ret

;==============================================================================
; @function             PrintString
; @details              Prints a string to the console.
;==============================================================================
PrintString:

    ;--------------------------------------------------------------------------
    ; both ax and bx registers get clobbered when printing a character
    ; so save them both to the stack first
    ;--------------------------------------------------------------------------
    push    ax
    push    bx
    
    mov     ah,     0eh                                 ; teletype output
    xor     bx,     bx                                  ; page number
    
    .loop:
    
        lodsb                                           ; load the character into al
        
        or      al,     al                              ; is al = 0?
        jz     .done                                    ; yep, we're finished
        
        int     0x10                                    ; nope, print the character
        jmp     short   .loop                           ; repeat the loop
    
    .done:
    
        ;----------------------------------------------------------------------
        ; restore the original ax and bx values and return
        ;----------------------------------------------------------------------
        pop     bx
        pop     ax
        ret

;==============================================================================
; @function     Reboot
; @brief        Reboots the machine
;==============================================================================
Reboot:

    ;--------------------------------------------------------------------------
    ; Try reboot through keyboard I/O port using Basic's OUT statement.
    ;--------------------------------------------------------------------------
    mov     al,     0xFE
    out     0x64,   al

    ;--------------------------------------------------------------------------
    ; Fallback to BIOS warm reboot.
    ;--------------------------------------------------------------------------
    xor     ax,     ax
    int     0x19

;==============================================================================
; Display strings
;==============================================================================
String.CRLF                     db      0x0D,   0x0A,   0x00
String.Hello                    db      "Hello, world!",    0x0D,   0x0A,    0x00
String.Hexadecimal              db      "Hexadecimal: 0x",  0x00
String.Decimal                  db      "Decimal: ",    0x00

;==============================================================================
; Memory layout
;==============================================================================
Mem.Stage1                      equ     0x00007C00
Mem.Stage1.Segment              equ     Mem.Stage1 >> 4

Mem.Stack.Top                   equ     0x00007C00