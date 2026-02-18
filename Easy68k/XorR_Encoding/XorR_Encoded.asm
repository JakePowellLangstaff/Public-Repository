;;; Turn into an executable with the following two commands
;;; 1. nasm -f elf64 <filename>.asm
;;; 2. ld <filename>.o
;;; -------------------------------------------------------
;;; This program:
;;; 1. Prompts user for input (max 23 chars + newline)
;;; 2. XOR-encodes the input using a repeating key ("ABC")
;;; 3. Prints the encoded result
;;; -------------------------------------------------------

    SYS_READ   equ     0          ; Linux syscall number for sys_read
    SYS_WRITE  equ     1          ; Linux syscall number for sys_write
    SYS_EXIT   equ     60         ; Linux syscall number for sys_exit
    STDIN      equ     0          ; File descriptor for standard input
    STDOUT     equ     1          ; File descriptor for standard output

; --------------------------------
section .bss                     ; Uninitialized data section
                                 ; Memory reserved here does NOT increase file size

    MaxLength equ     24         ; Maximum bytes to read (23 chars + newline)
    UserInput     resb    MaxLength
                                 ; Reserve 24 bytes for user input buffer
                                 ; resb = reserve bytes
; --------------------------------
section .data                    ; Initialized data section

    prompt     db      "Please input some text (max 23 characters): "
                                 ; Prompt string shown to user

    prompt_len equ     $ - prompt
                                 ; Compute length of prompt string

    text       db      10, "When XOR encoded you get: "   ; REPLACED (message changed)
                                 ; 10 = newline character
                                 ; Message printed before encoded output

    text_len   equ     $ - text
                                 ; Compute length of result message

    key        db      "ABC"          ; <<< ADDED
                                 ; XOR key used for encoding

    keyLen     equ     $ - key        ; <<< ADDED
                                 ; Length of XOR key (3 bytes)
; --------------------------------
section .text                    ; Code section
    global _start                ; Entry point for linker
    global swapcase              ; Make swapcase visible externally

_start:
    ;; Output a prompt to user
                                 ; sys_write(STDOUT, prompt, prompt_len)

    mov     rdx, prompt_len      ; rdx = number of bytes to write
    mov     rsi, prompt          ; rsi = address of prompt string
    mov     rdi, STDOUT          ; rdi = file descriptor (stdout)
    mov     rax, SYS_WRITE       ; rax = syscall number (write)
    syscall                      ; invoke kernel

    ;; Read a string from console into UserInput
                                 ; sys_read(STDIN, UserInput, MaxLength)

    mov     rdx, MaxLength       ; rdx = max bytes to read
    mov     rsi, UserInput       ; rsi = buffer address
    mov     rdi, STDIN           ; rdi = file descriptor (stdin)
    mov     rax, SYS_READ        ; rax = syscall number (read)
    syscall                      ; returns number of bytes read in rax

    push    rax                  ; save length
                                 ; We save the byte count for:
                                 ; 1. Passing to XOR function
                                 ; 2. Printing correct length later

    ;; Call XOR encoding procedure

    pop     rsi                  ; <<< ADDED (length → RSI)
                                 ; rsi = length parameter

    push    rsi                  ; <<< ADDED (save again for printing)
                                 ; Save length again for later output

    mov     rdi, UserInput       ; <<< ADDED (string → RDI)
                                 ; rdi = pointer to input buffer

    call    swapcase             ; REPLACED (now does XOR, not swapcase)
                                 ; swapcase(buffer, length)

;;; Sample rot47 call
;   mov rdi,UserInput            ; REMOVED
;   mov rsi,MaxLength            ; REMOVED
;   call rot47                   ; REMOVED

    ;; Write out result message
                                 ; sys_write(STDOUT, text, text_len)

    mov     rdx, text_len
    mov     rsi, text
    mov     rdi, STDOUT
    mov     rax, SYS_WRITE
    syscall

    ;; Write out encoded string
                                 ; sys_write(STDOUT, UserInput, original_length)

    pop     rdx                  ; restore length
                                 ; rdx = number of bytes to print

    mov     rsi, UserInput       ; rsi = encoded buffer
    mov     rdi, STDOUT          ; stdout
    mov     rax, SYS_WRITE       ; write syscall
    syscall

    ;; Exit
                                 ; sys_exit(0)

    xor     edi, edi             ; edi = 0 (exit status)
    mov     rax, SYS_EXIT        ; syscall number for exit
    syscall

; ==========================================================
; XOR Encoding Procedure (Null Preserving)
; ==========================================================

swapcase:        ; REPLACED ENTIRE FUNCTION
                 ; Parameters:
                 ;   rdi = pointer to buffer
                 ;   rsi = buffer length
                 ; Returns:
                 ;   rax = 1 (success)

    push rbp                     ; <<< ADDED
                                 ; Save caller base pointer

    mov rbp, rsp                 ; <<< ADDED
                                 ; Create new stack frame

    mov rcx, 0                   ; <<< ADDED (string index)
                                 ; rcx = index into buffer

    mov r8, 0                    ; <<< ADDED (key index)
                                 ; r8 = index into XOR key

encode_loop:

    cmp rcx, rsi                 ; <<< ADDED (end of string?)
                                 ; If rcx >= length, stop

    jge done                     ; <<< ADDED

    mov al, [rdi + rcx]          ; <<< ADDED (load char)
                                 ; Load current character

    cmp al, 0                    ; <<< ADDED (null preserve)
                                 ; If byte is NULL (0x00)

    je skip_xor                  ; <<< ADDED
                                 ; Skip XOR so null bytes remain unchanged

    mov bl, [key + r8]           ; <<< ADDED (load key char)
                                 ; Load current key character

    xor al, bl                   ; <<< ADDED
                                 ; XOR data byte with key byte

    mov [rdi + rcx], al          ; <<< ADDED (store result)
                                 ; Store encoded byte back

skip_xor:

    inc rcx                      ; <<< ADDED
                                 ; Move to next buffer byte

    inc r8                       ; <<< ADDED
                                 ; Move to next key byte

    cmp r8, keyLen               ; <<< ADDED (key reset check)
                                 ; If key index reached end

    jl continue_loop             ; <<< ADDED
                                 ; If not, continue

    mov r8, 0                    ; <<< ADDED (reset key index)
                                 ; Reset key index (repeat key)

continue_loop:
    jmp encode_loop              ; <<< ADDED
                                 ; Loop back

done:
    mov rax, 1                   ; <<< ADDED (return success)

    mov rsp, rbp                 ; <<< ADDED
                                 ; Restore stack pointer

    pop rbp                      ; <<< ADDED
                                 ; Restore base pointer

    ret                          ; Return to caller


;;; ROT47 procedure remains below unchanged
;;; (kept only because it was in template)

rot47:
    push rbp                     ; Save caller base pointer
    mov rbp,rsp                  ; Establish stack frame

loop:
    mov al,[rdi]                 ; Load current character

    cmp al,32                    ; If ASCII <= 32 (non-printable)
    jle next

    cmp al,127                   ; If ASCII >= 127
    jge next

    cmp al,80                    ; Midpoint check
    jl add

    sub al,47                    ; Rotate backward
    jmp next

add:
    add al,47                    ; Rotate forward

next:
    mov [rdi],al                 ; Store modified char
    add rdi,1                    ; Move to next char
    sub rsi,1                    ; Decrement remaining count
    cmp rsi,0                    ; Done?
    je end
    jmp loop

end:
    xor rax,rax                  ; Return 0
    mov rsp,rbp                  ; Restore stack
    pop rbp                      ; Restore base pointer
    ret

