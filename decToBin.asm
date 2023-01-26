; Name:     decToBin.asm
; Assemble: nasm -f elf decToBin.asm
; Link:     ld -m elf_i386 -s -o decToBin decToBin.o
; Run:      ./decToBin

section .data
    line_feed dw 10
    nullstr db '(null)', 10 , 0
    decimal db '123', 0
    binary db '', 10, 0

section .bss
    number resb 0

section .text
    global _start

_start:
    call decimal_to_binary

    mov eax, 1
    xor ebx, ebx
    int 0x80

; store length in edx register
get_string_length:
    xor edx, edx

    .J1:
    cmp byte [esi], 0
    je .J2
    add edx, 1
    add esi, 1
    jmp .J1

    .J2:
    ret
; print a string stored in esi register
print_string:
    pusha

    .J0:
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    call get_string_length
    int 0x80
    popa
    ret

; convert a string to integer from the esi register to the edx register
string_to_int:
    xor edi, edi
    xor eax, eax

    ; convertion loop
    .S0:
        mov dl, [esi]
        cmp dl, 0       ; are we at the end of the string ?
        je .S1          ; if yes, exit the convertion loop
        sub dl, '0'     ; get integer value
    
        mov ebx, eax    ; multiply by ten
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add ebx, eax
        add eax, ebx

        add eax, edx    ; add unit number

        inc esi         ; increment pointer position in the string
        jmp .S0
    
    ; conversion end
    .S1:
    mov edx, eax
    ret

; convert a decimal number to it's binary value 
; it use the decimal string from .data section
; display the result on screen
decimal_to_binary:
    ; get integer value of the decimal number to convert
    mov esi, decimal
    call string_to_int

    ; init convertion loop
    mov eax, edx
    mov ebx, 2
    mov ecx, 0

    ; convertion loop
    .do:
        xor edx, edx
        div ebx
        add edx, 48
        mov [binary + ecx], edx
        inc ecx
        cmp eax, 0
        jnz .do
    
    ; reverse string
    mov esi, binary
    call get_string_length

    ; init pointers
    xor esi, esi
    mov esi, edx
    shr esi, 1

    xor edi, edi
    mov edi, edx
    dec edi
    sub edi, esi

    .reverse:
        mov al, byte [binary + esi]
        mov ah, byte [binary + edi]
        mov byte [binary + esi], ah
        mov byte [binary + edi], al
        inc edi
        dec esi
        cmp esi, 0
        jnz .reverse
        
    .print:
        mov esi, binary
        call print_string

        mov esi, line_feed
        call print_string

    ret