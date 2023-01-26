; Name:     binToDec.asm
; Assemble: nasm -f elf binToDec.asm
; Link:     ld -m elf_i386 -s -o binToDec binToDec.o
; Run:      ./binToDec

section .data
    line_feed dw 10
    nullstr db '(null)', 10 , 0
    binary db '1111011', 0
    decimal db '', 10, 0

section .text
    global _start

_start:
    call binary_to_decimal

    ; exit program
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

; convert a binary number to its decimal value
; it use a string stored in .data section that contain the binary number
; it display the result on screen
binary_to_decimal:
    ; get index of last bit in string
    mov esi, binary
    call get_string_length
    dec edx
    mov esi, edx
    mov edi, edx

    xor edx, edx

    ; convertion loop
    .do:
        xor ebx, ebx

        ; get first bit
        mov al, [binary + esi]
        cmp al, 0
        je .print
        sub al, '0'

        ; convert the bit value to its decimal value
        cmp al, 0
        jz .continue

        ; check if we want to do a pow 0
        mov ebx, 1
        cmp esi, edx
        je .continue

        mov ebx, 2
        mov ecx, edi
        .pow:
            cmp ecx, 1      ; ecx = 0 ?
            je .continue    ; if yes, we don't want to double ebx anymore
            add ebx, ebx
            dec ecx
            jmp .pow
        
        .continue:
            add edx, ebx

        dec esi
        cmp esi, binary
        jnl .do
    
    ret
