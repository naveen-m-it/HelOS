;------------------------------------------------------------------------------------------------------------
; helOS! 5-11-2024
;------------------------------------------------------------------------------------------------------------
[org 0x7c00]
_start:
    call _clear_screen
    call print_title
    call get_command

;------------------------------------------------------------------------------------------------------------
; title
;------------------------------------------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------------
; get command from user
;------------------------------------------------------------------------------------------------------------
get_command:
    call _print_command_tag
    .loop:
        call _read_char
        cmp al, 0x0d
        je _process_command
        mov si, command_buffer_len
        cmp si, 63
        je get_command.end
        mov [command_buffer + si], al
        inc byte [command_buffer_len]
        call _print_char
        jmp get_command.loop
    .end:
        ret

;------------------------------------------------------------------------------------------------------------
; Command process
;------------------------------------------------------------------------------------------------------------
_process_command:
    mov si, command_buffer
    
    mov di, clear_cmd
    call _compare_command
    je _clear_screen

    mov di, help_cmd
    call _compare_command
    je _help_screen

    mov di, version_cmd
    call _compare_command
    je _version_screen

    mov di, exit_cmd
    call _compare_command
    je _end

    call _clear_buffer
    call _clear_screen
    jmp get_command

_compare_command:
    pusha
    mov cx, 64
    .loop:
        mov al, [si]
        cmp al, [di]
        jne _compare_command.not_equal
        cmp al, 0
        je _compare_command.equal
        inc si
        inc di
        loop _compare_command.loop

    .not_equal:
        xor ax, ax
        popa
        ret

    .equal:
        mov ax, 1
        popa
        ret

;------------------------------------------------------------------------------------------------------------
; printing functions
;------------------------------------------------------------------------------------------------------------
_print_command_tag:
    mov si, command_tag
    .loop:
        mov al, [si]
        cmp al, 0
        je _print_command_tag.end
        call _print_char
        inc si
        jmp _print_command_tag.loop
    .end:
        ret

print_title:
    mov si, title
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp print_title.loop
    .end:
        ret

_print_buffer:
    mov si, command_buffer
    .loop:
        mov al, [si]
        cmp al, 0
        je _print_buffer.end
        call _print_char
        inc si
        jmp _print_buffer.loop
    .end:
        ret

;------------------------------------------------------------------------------------------------------------
; Utility functions
;------------------------------------------------------------------------------------------------------------
_clear_screen:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184f
    int 0x10
    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10
    ret

_help_screen:
    mov si, help_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je _help_screen.end
        call _print_char
        inc si
        jmp _help_screen.loop
    .end:
        ret

_version_screen:
    mov si, version_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je _version_screen.end
        call _print_char
        inc si
        jmp _version_screen.loop
    .end:
        ret

_error_screen: 
    mov si, error_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je _error_screen.end
        call _print_char
        inc si
        jmp _error_screen.loop
    .end:
        ret

_print_char:
    mov ah, 0x0e
    int 0x10
    ret

_read_char:
    mov ah, 0x00
    int 0x16
    ret

_clear_buffer:
    mov cx, 64
    mov di, command_buffer
    mov al, 0
    rep stosb
    mov byte [command_buffer_len], 0
    ret

_end:
    jmp $
;------------------------------------------------------------------------------------------------------------
; data storage for messages and commands
;------------------------------------------------------------------------------------------------------------

;Strings
title db "HelOS!", 0
command_tag db 0xd, 0xa, ">>> ", 0
help_cmd db "help", 0
clear_cmd db "clear", 0
exit_cmd db "exit", 0
version_cmd db "version", 0
error_msg db "unknown command!", 0xd, 0xa, 0
version_msg db "helOS version - 0.01", 0xd, 0xa, 0

help_msg db 0xd, 0xa, "help - help", 0xd, 0xa, "version - version",0xd, 0xa,"clear - clear screen",0xd, 0xa,"exit - exit from terminal",0xd, 0xa, 0

;buffers
command_buffer db 64
command_buffer_len db 0

; fill 512 bytes
times 510-($-$$) db 0
dw 0xaa55