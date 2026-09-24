# Time Calculator (x86 Assembly)

A console-based time calculator written in 32-bit x86 assembly (MASM), built with Kip Irvine's *Assembly Language for x86 Processors* as the course text. The program prompts the user for hours, minutes, and seconds, validates the input character-by-character using a finite state machine, then computes and displays the total number of minutes and seconds.

## Features

- Sequentially prompts for hours, minutes, and seconds
- Validates input in real time as each character is typed, rejecting non-numeric and negative values with a clear error message and re-prompt
- Echoes the original inputs back to the user with labeled output
- Computes and displays total minutes and total seconds
- Offers a case-insensitive "try again" option to repeat the program
- No magic numbers — all constants (60, 3600, etc.) are named in the `.data` section

## Example output
Enter the number of hours: 5
Enter the number of minutes: 4
Enter the number of seconds: 3

The number of hours entered was 5.
The number of minutes entered was 4.
The number of seconds entered was 3.

The total number of minutes is 304 minutes.
The total number of seconds is 18243 seconds.

Try again (y/n)? y

<img width="796" height="291" alt="image" src="https://github.com/user-attachments/assets/69b711ba-25fc-49c9-985a-58b6261d4261" />

<img width="936" height="593" alt="image" src="https://github.com/user-attachments/assets/1b3fe875-bb27-4e93-923c-91384b9b4732" />




## How it works

Each input field (hours, minutes, seconds) is validated using its own **finite state machine**:

- **State A** — validates the first character typed. It must be a digit; any non-digit (including a leading `-`) is rejected immediately, which is what rules out negative numbers.
- **State C** — validates every character after the first. Each one must be another digit or the Enter key, which signals the value is complete.

As each digit is confirmed valid, it's converted from its ASCII character code to a numeric value and accumulated into the running total using standard positional-value math (`value = value * 10 + newDigit`).

This approach is based on the finite-state-machine input-validation technique from Irvine's text (Ch. 6), extended here to run independently across three separate input fields in sequence.

## Tools used

- MASM (Microsoft Macro Assembler), via Visual Studio
- [Irvine32 library](https://asmirvine.com/) for console I/O (`WriteString`, `ReadChar`, `WriteDec`, etc.)

## Build & run

1. Open the project in Visual Studio (Desktop development with C++ workload required)
2. Build the solution
3. Run with Debug > Start Without Debugging (Ctrl+F5)
