# CPU_FPGA
Final Project for ECE243 where I created a Computer with a CPU, Memory and I/O on the DE1-SOC FPGA using Verilog.

## Assembly
Description of the assembly language used for this processor. It is similar to NIOS II.
### Arithmetic
Arithmetic instructions follow this format: **_XXX Rout Ra Rb_**
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
Comparison instructions follow this format: **_XXX Rout Ra Rb_**
You can do the following operations:
* GT (Ra > Rb)
* LT (Ra < Rb)
* EQ (Ra == Rb)

## Branch
Branch instructions follow this format: **_XXX Immed5_**
You can do the following operations:
* BR (normal branch)
* BRZ (branch if Z flag is 1, meaning last operations in ALU was equal to 0)
