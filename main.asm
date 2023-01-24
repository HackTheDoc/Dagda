section .data
    decimal db 32 dup(0)
    binary db 32 dup(0)
    error_msg db 'Error: enter ONE decimal number!', 10, 0
    error_msg_len equ $-error_msg

section .text
    global _start

error:
    ;print error msg
    mov edx, error_msg_len
    mov ecx, error_msg
    mov ebx, 1
    mov eax, 4
    int 0x80

    ;exit with error
    mov eax, 1
    mov ebx, 1
    int 0x80

_start:
    ;get args
    mov eax, [esp]
    cmp eax, 2 ; check if only one argument is present
    jne error ; if not, jump to error section

    ;exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

