# CPU_FPGA
Final Project for ECE243 where I created a Computer with a CPU, Memory and I/O on the DE1-SOC FPGA using Verilog.


The given code, when compiled using [code/IO.v](https://github.com/adamrt27/CPU_FPGA/blob/main/code/IO.v) will run the program [lab1.txt](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler/lab1.txt) and [lab2_big.txt](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler/lab2_big.txt) when either KEY1 or KEY2 is pressed in combination with KEY0 (reset). 
* lab1
  * Adds up numbers from 1 to 30 and places result in R4
* lab2
  * Search through list and place biggest element in R4
 
 
You can then use SW[2:0] to set which register you want to look at, in the RegisterFile, and the output will be displayed on HEX0-3 in hexadecimal.


If you want to run other programs on the FPGA, update [code/memory.v](https://github.com/adamrt27/CPU_FPGA/blob/main/code/memory.v) with the output of [compiler/output.txt](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler/output.txt) after running the [compiler/compiler.py](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler/compiler.py) script on your input file.

## RTL Design
![Datapath](https://github.com/adamrt27/CPU_FPGA/blob/main/readme/Project-7.jpg)
![Finite State Machine](https://github.com/adamrt27/CPU_FPGA/blob/main/readme/Project-8.jpg)
![Opcodes](https://github.com/adamrt27/CPU_FPGA/blob/main/readme/Project-9.jpg)

## Compiler.py Details
The compiler.py file allows for easy compilation of your assembly code into machine code. 

To use it:
1) Create a new ".txt" file in the compiler folder and write your code in there
2) Go to [compiler.py](compiler/compiler.py) and change *input_file* in line 1 to the name of your ".txt" file
3) Run the script. Your machine code will be found in [output.txt](compiler/output.txt)
4) Copy code from [output.txt](compiler/output.txt) to [memory.v](code/memory.v) in line 24

The compiler allows for:
* a "data" section
  * can put stuff into memory to start
* a "code" section
  * write your code here
* comments
  * use # to write comments
* empty lines
  * parser automatically skips empty lines
 
for more details go to [example.txt](compiler/example.txt).

## Assembly
Description of the assembly language used for this processor. It is similar to NIOS II.
### Arithmetic
Arithmetic instructions follow this format: **_XXX Rout Ra Rb_**.
You can do the following operations:
* ADD
* SUB
* OR
* AND
* XOR
* SL (shift left logic)
* SR (shift right logic)

### Arithmetic Immediate
Arithmetic Immediate instructions follow this format: **_XXX Rout Ra Immed5_**. **Immed5** can be a decimal or binary, but for binary, must write "0b" before number (i.e. 0b11, 0b11011).
You can do the following operations:
* ADDI
* SUBI
* ORI
* ANDI
* XORI
* SLI (shift left logic)
* SRI (shift right logic)

### Comparison
Comparison instructions follow this format: **_XXX Rout Ra Rb_**.
You can do the following operations:
* GT (Ra > Rb)
* LT (Ra < Rb)
* EQ (Ra == Rb)

### Branch
Branch instructions follow this format: **_XXX Immed5_**.
You can do the following operations:
* BR (normal branch)
* BRZ (branch if Z flag is 1, meaning last operations in ALU was equal to 0)
