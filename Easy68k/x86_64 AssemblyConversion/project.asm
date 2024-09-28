section .text
global _start

_start:
    ; Output prompt for num1
    mov     rdx,    prompt_length   ; message length
    mov     rsi,    prompt          ; message
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Input num1
    mov     rdi,    0               ; file descriptor (stdin)
    mov     rax,    0               ; system call number (sys_read)
    mov     rsi,    num1            ; address to store input
    mov     rdx,    4               ; length of input
    syscall                         ; call kernel

    ; Output num1
    mov     rdx,    4               ; length of input
    mov     rsi,    num1            ; input to be printed
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Output newline
    call    newLine

    ; Input num2
    mov     rdx,    prompt_length   ; message length
    mov     rsi,    prompt          ; message
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Input num2
    mov     rdi,    0               ; file descriptor (stdin)
    mov     rax,    0               ; system call number (sys_read)
    mov     rsi,    num2            ; address to store input
    mov     rdx,    4               ; length of input
    syscall                         ; call kernel

    ; Output num2
    mov     rdx,    4               ; length of input
    mov     rsi,    num2            ; input to be printed
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Output newline
    call    newLine

    ; Call Adder1
    mov     eax,    dword [num1]    ; load num1 into eax
    add     eax,    dword [num2]    ; add num2 to eax
    mov     dword [sum], eax        ; store sum in sum variable

    ; Output result
    mov     rdx,    12              ; length of result
    mov     rsi,    result          ; message
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Output sum
    mov     rdx,    4               ; length of sum
    mov     rsi,    sum             ; sum to be printed
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdi,    0x01            ; file descriptor (stdout)
    syscall                         ; call kernel

    ; Output newline
    call    newLine

    ; Exit program
    mov     rax,    60              ; system call number (sys_exit)
    xor     rdi,    rdi             ; return status
    syscall                         ; call kernel

prompt_length equ $ - prompt

newLine:
    ; Subroutine to display Carriage Return and Line Feed
    mov     rdi,    0x01            ; file descriptor (stdout)
    mov     rax,    0x01            ; system call number (sys_write)
    mov     rdx,    2               ; length of newline
    mov     rsi,    crlf            ; address of newline
    syscall                         ; call kernel
    ret

Adder1:
    ; Add the number in register eax to the number in register edx.
    ; The sum is returned in register eax.
    add     eax,    edx             ; eax = eax + edx
    ret

Adder2:
    ; Add two numbers passed as parameters in registers eax and edx.
    ; The sum is returned in register eax.
    add     eax,    edx             ; eax = eax + edx
    ret
