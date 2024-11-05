[org x7c00]
start:
    mov al, 0x0003
    int 0x10

end:
    jmp $
; reserve exactly 51bytes
times 510-($-$$) db 0
dw 0xaa55