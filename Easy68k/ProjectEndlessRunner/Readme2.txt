#Purpose: x86_64 Assembly Conversion from 68000 Assembly
#Jake Powell 19/01/2001
#Created: April 2024

## Overview
This project involves converting 68000 assembly code to x86_64 assembly code while maintaining functionality and correctness. 
The provided 68000 assembly code performs arithmetic operations on two numbers, input by the user, and displays the result. The 
x86_64 assembly code replicates this behavior.

##Changes made to code      
1. **System Calls**:
   - We replaced 68000 assembly's trap instructions with x86_64 assembly's system calls (sys_write and sys_read) for input/output operations.
   - The x86_64 assembly code interacts with the kernel using the commonly used`syscall` instruction to perform input/output and program exit operations 
   - Since were cool

2. **Subroutines**:
   - We implemented subroutines (`Adder1`, `Adder2`, `newLine`) to simplifie common operations and to improve code readability                
   - `Adder1` and `Adder2` perform addition operations, directly or indirectly, on input numbers.
   - The `newLine` subroutine outputs a newline character sequence to enhance output formatting.

3. **Data Section**:
   - We defined strings for prompts and results in the `.data` section and reserved space for input and output variables in the `.bss` section.

4. **Modular Programming**:
   - The code follows modular programming principles by organizing functionality into separate subroutines and sections.
   - Comments are used extensively to explain the purpose and functionality of each section of the code.

## Usage
To assemble and run the x86_64 assembly code:
1. Install NASM (Netwide Assembler).
2. Assemble the code using the command: `nasm -f elf64 -o program.o program.asm`.
3. Link the object file using the command: `ld -o program program.o`.
4. Execute the program: `./program  

# Conclusion
The conversion process from 68000 assembly to x86_64 assembly involved understanding the original code's functionality and translating it to a different 
assembly language paradigm. By maintaining functionality, adhering to coding standards, and introducing modularity, 
the x86_64 assembly code preserves the original program's behavior while enabling execution on modern x86_64  systems.
All be it there are still errors in loading up of the file, attempts were made in futility to fix.

