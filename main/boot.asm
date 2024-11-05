; Set origin memory location for bootloader
[org 0x7c00]

start:
    call _clear_screen
    call print_title
    call print_prompt_text
    jmp get_command

print_title:
    mov si, title
    .loop:
        mov al, [si]
        cmp al, 0
        je print_title.end
        call _print_char
        inc si
        jmp print_title.loop
    .end:
        ret

print_prompt_text:
    mov si, prompt_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je print_prompt_text.end
        call _print_char
        inc si
        jmp print_prompt_text.loop
    .end:
        ret

print_prompt_tag:
    mov si, prompt_tag
    .loop:
        mov al, [si]
        cmp al, 0
        je print_prompt_tag.end
        call _print_char
        inc si
        jmp print_prompt_tag.loop
    .end:
        ret

get_command:
    call print_prompt_tag
    .loop:
        call _read_char
        cmp al, 0x0d
        je process_command
        mov si, buffer_length
        cmp si, 63
        je get_command.end
        mov [buffer + si], al
        inc byte [buffer_length]
        call _print_char
        jmp get_command.loop
    .end:
        ret

_help:
    mov si, help_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je _help.end
        call _print_char
        inc si
        jmp _help.loop
    .end:
        ret

_read_char:
    mov ah, 0x00
    int 0x16
    ret

_print_char:
    mov ah, 0x0e
    int 0x10
    ret

_clear_screen:
    mov ax, 0x0003
    int 0x10
    jmp get_command

process_command:
    mov si, buffer
    mov di, help_cmd
    call _compare_command
    je _help
    mov di, clear_cmd
    call _compare_command
    je _clear_screen
    mov di, exit_cmd
    call _compare_command
    je _exit_command

    call _clear_buffer
    call print_prompt_tag
    jmp get_command

_compare_command:
    pusha
    mov cx, 64
    .loop:
        mov al, [si]
        cmp al, [di]
        jne .not_equal
        cmp al, 0
        je .equal
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

_clear_buffer:
    mov cx, 64
    mov di, buffer
    mov al, 0
    rep stosb                           ; Clear buffer
    mov byte [buffer_length], 0
    ret
; jump to halt mode
_exit_command:
    jmp $
; strings to print
title db "HelOS!",0xa, 0xd, 0
prompt_tag db ">>> ", 0
prompt_msg db "press h to help.",0xa,0xd, 0
help_msg db 0xa, 0xd, "help - help", 0xa, 0xd, "version - version",0xa, 0xd,"clear - clear screen",0xa, 0xd,"exit - exit from terminal",0xa, 0xd, 0

help_cmd db "help", 0
clear_cmd db "clear", 0
version_cmd db "version", 0
exit_cmd db "exit", 0

; buffers
buffer db 64
buffer_length db 0
times 510-($-$$) db 0
dw 0xaa55
