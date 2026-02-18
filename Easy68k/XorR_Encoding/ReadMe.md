# XorR_Encoded.asm

## Author Name
Your Name Here

## Student Number
Your Student Number Here

## Licence Details (GPL recommended)
(Leave this section blank — to be filled in later)

## Project Description
This project is a 64-bit Linux assembly program written using NASM.  
The program:
- Prompts the user to enter text (maximum 23 characters).  
- Reads the user input from standard input.  
- Encodes the input using a repeating XOR key ("ABC").  
- Displays the XOR-encoded result to standard output.  

The XOR encoding preserves null bytes and cycles through the key repeatedly until the entire input string has been processed.  

The program uses Linux system calls directly:
- sys_read  
- sys_write  
- sys_exit  

It does not rely on the C standard library.

## Instructions on Producing an Executable
This program is intended for a 64-bit Linux environment.

### Step 1 – Assemble the source file

nasm -f elf64 XorR_Encoded.asm

This generates:
XorR_Encoded.o

Step 2 – Link the object file
bash
ld XorR_Encoded.o
This produces the default executable:
a.out

Step 3 – Run the program
bash
./a.out
Issues / Notes
The program reads up to 24 bytes (23 characters plus newline).

The newline character entered by pressing Enter is also XOR-encoded.

The XOR key is currently set to "ABC" and can be modified in the .data section.

If the source file is modified, it must be reassembled and relinked before running again.

The program is written for Linux (ELF64) and will not run natively on Windows without WSL or a Linux environment.

