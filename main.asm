; Name:     main.asm
; Assemble: nasm -f elf main.asm
; Link:     ld -m elf_i386 -s -o dagda main.o
; Run:      ./dragda arg1

section .data
    line_feed dw 10
    decimal db 32 dup(0)
    binary db 32 dup(0)
    nullstr db '(null)', 0
    argcstr db '---------------', 10
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
    push ebp
    mov ebp, esp

    ;get args
    mov eax, [ebp+4]
    cmp eax, 2 ; check if only one argument is present
    jne error ; if not, jump to error section

    ; get the first argument
    mov eax, [esp+4]
    mov edi, argcstr
    call eax_to_decimal

    ; display it
    mov esi, argcstr
    call print_string
    
    mov esi, line_feed
    call print_string

    ;exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_string:
    pusha
    test esi, esi
    jne .J0
    mov esi, nullstr

    .J0:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    xor edx, edx

    .J1:
    cmp byte [esi], 0
    je .J2
    add edx, 1
    add esi, 1
    jmp .J1

    .J2:
    int 80h
    popa
    ret




eax_to_decimal:
    push ebx
    push ecx
    push edx

    mov ebx, 10 ; divisor = 10
    xor ecx, ecx

    .J1:
    xor edx, edx
    div ebx
    push dx
    add cl, 1   ; incr cl (counter)
    or eax, eax ; ax = 0 ?
    jnz .J1

    mov ebx, ecx    ; store count of digits

    .J2:
    pop ax              ; get back pushed digits
    or al, 00110000b    ; to ascii
    mov [edi], al
    add edi, 1
    loop .J2            ; until there is no digits left

    mov byte [edi], 0
    mov eax, ebx

    pop ebx
    pop ecx
    pop edx
    ret
