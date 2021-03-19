# CS271-Assembly-Portfolio-Project
String Primitives and Macros

Program Description
Write and test a MASM program to perform the following tasks (check the Requirements section for specifics on program modularization):

Implement and test two macros for string processing. These macros may use Irvine’s ReadString to get input from the user, and WriteString procedures to display output.
mGetSring:  Display a prompt (input parameter, by reference), then get the user’s keyboard input into a memory location (output parameter, by reference). You may also need to provide a count (input parameter, by value) for the length of input string you can accommodate and a provide a number of bytes read (output parameter, by reference) by the macro.
mDisplayString:  Print the string which is stored in a specified memory location (input parameter, by reference).
Implement and test two procedures for signed integers which use string primitive instructions
ReadVal: 
Invoke the mGetSring macro (see parameter requirements above) to get user input in the form of a string of digits.
Convert (using string primitives) the string of ascii digits to its numeric value representation (SDWORD), validating the user’s input is a valid number (no letters, symbols, etc).
Store this value in a memory variable (output parameter, by reference). 
WriteVal: 
Convert a numeric SDWORD value (input parameter, by value) to a string of ascii digits
Invoke the mDisplayString macro to print the ascii representation of the SDWORD value to the output.
Write a test program (in main) which uses the ReadVal and WriteVal procedures above to:
Get 10 valid integers from the user.
Stores these numeric values in an array.
Display the integers, their sum, and their average.

Program Requirements
User’s numeric input must be validated the hard way:
Read the user's input as a string and convert the string to numeric form.
If the user enters non-digits other than something which will indicate sign (e.g. ‘+’ or ‘-‘), or the number is too large for 32-bit registers, an error message should be displayed and the number should be discarded.
If the user enters nothing (empty input), display an error and re-prompt.
ReadInt, ReadDec, WriteInt, and WriteDec are not allowed in this program.
Conversion routines must appropriately use the LODSB and/or STOSB operators for dealing with strings.
All procedure parameters must be passed on the runtime stack. Strings must be passed by reference
Prompts, identifying strings, and other memory locations must be passed by address to the macros.
Used registers must be saved and restored by the called procedures and macros.
The stack frame must be cleaned up by the called procedure.
Procedures (except main) must not reference data segment variables or constants by name. 
The program must use Register Indirect addressing for integer (SDWORD) array elements, and Base+Offset addressing for accessing parameters on the runtime stack.
Procedures may use local variables when appropriate.
