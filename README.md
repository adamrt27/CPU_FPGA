# CPU_FPGA
Final Project for ECE243 where I created a Computer with a CPU, Memory and I/O on the DE1-SOC FPGA using Verilog.

## Using the Processor
You can generate machine code for the processor using the [compiler.py](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler.py) script. To use this script, write your assembly code in the [assembly.txt](https://github.com/adamrt27/CPU_FPGA/blob/main/assembly.txt) file, run [compiler.py](https://github.com/adamrt27/CPU_FPGA/blob/main/compiler.py), and copy your terminal output into [memory.v](https://github.com/adamrt27/CPU_FPGA/blob/main/code/memory.v) at line 24. 

This allows the processor to run your code. Hwoever, to check if your code is running properly, you must either run a simulation (can use [test.do](testing/test.do) in ModelSim), or hook up I/O such as LEDS and SW to run on the DE1-SOC.

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

## Branch
Branch instructions follow this format: **_XXX Immed5_**.
You can do the following operations:
* BR (normal branch)
* BRZ (branch if Z flag is 1, meaning last operations in ALU was equal to 0)
