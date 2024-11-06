;===============================================
; helOS! 6-11-24
;===============================================
[org 0x7c00]                        ; set origin to position 0x7c00
start:
    ;call _clear                     ; Clear screen
    call print_title                ; print title text
    call get_command                ; call get_command function
    ;call _print_debug_msg
    jmp end                         ; jump to end

;===============================================
; Print functions
;===============================================

; Title text
print_title:
    mov si, msg                     ; load msg memory address to si register
    .loop:
        mov al, [si]                ; load si memory content to al register
        cmp al, 0                   ; compare al to 0
        je .end                     ; if equal jump to local end label
        call _print_char            
        inc si                      ; increase si by 1
        jmp .loop                   ; jump to local loop label
    .end:
        ret                         ; return control to caller and executes next instruction

print_command_tag:
    mov si, command_tag
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        ret

;===============================================
; Command process
;===============================================

; Getting command
get_command:
    call print_command_tag
    .loop:
        call _read_char
        cmp al, 0xd
        je _process_command
        mov si, command_buffer_len
        cmp si, 63
        je .end
        mov byte [command_buffer + si], al
        inc byte [command_buffer_len]
        call _print_char
        jmp .loop
    .end:
        jmp .loop

; Processing command
_process_command:

    mov si, command_buffer
    mov di, exit_cmd
    call _compare_command
    cmp ax, 1
    je _exit
        
    mov si, command_buffer
    mov di, clear_cmd
    call _compare_command
    cmp ax, 1
    je _clear

    mov si, command_buffer
    mov di, help_cmd
    call _compare_command
    cmp ax, 1
    je _help

    jmp _invalid_command

_end_process:
    call _clear_command_buffer
    jmp get_command

; Compares commands 
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
        loop .loop
    .equal:
        mov ax, 1
        popa
        ret
    .not_equal:
        xor ax, ax
        popa
        ret

;===============================================
; Util functions
;===============================================

; Clear function
_clear:
    mov ax, 0x0600
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x0184f
    int 0x10

    mov ah, 0x02
    mov bh, 0
    mov dh, 0
    mov dl, 0
    int 0x10
    
    mov ah, 0x0003
    int 0x10
    
    jmp _end_process

; Help function 
_help:
    mov si, help_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        jmp _end_process

; Exit function
_exit:
    mov si, exit_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        jmp end                     ; jump to end of the function

; invalid handle
_invalid_command:
    mov si, error_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        jmp _end_process

; Clears command buffer and reset length to 0
_clear_command_buffer:
    mov cx, 64
    mov di, command_buffer
    mov al, 0
    rep stosb
    mov byte [command_buffer_len], 0
    ret

; Print character
_print_char:
    mov ah, 0x0e
    int 0x10
    ret

; Read character from keyboard input
_read_char:
    mov ah, 0x00
    int 0x16
    ret

;===============================================
; Debugging
;===============================================

_print_debug_msg:
    mov si, debug_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        ret

_print_equal_msg:
    mov si, equal_msg
    .loop:
        mov al, [si]
        cmp al, 0
        je .end
        call _print_char
        inc si
        jmp .loop
    .end:
        ret

;++++++++++++++++++++++++++++++++++++++++++++++++
; End of program
;++++++++++++++++++++++++++++++++++++++++++++++++
end:
    jmp $

;===============================================
; Messages and buffers
;===============================================

msg db "helOS!", 0xd, 0xa, 0
command_tag db ">>> ", 0

clear_cmd db "clear", 0
help_cmd db "help", 0
exit_cmd db "exit", 0

help_msg db "Help: Type 'clear' to clear screen.", 0xd, 0xa, "Type 'help' for this message.", 0xd, 0xa, 0
error_msg db 0xd, 0xa, "Invalid command.", 0xd, 0xa, 0
exit_msg db "Exited!", 0xd, 0xa, 0
debug_msg db "Reached!", 0xd, 0xa, 0
equal_msg db "Equal reached!", 0xd, 0xa, 0

command_buffer db 64
command_buffer_len db 0

; fill remaining empty memory to 0
times 510-($-$$) db 0
dw 0xaa55
