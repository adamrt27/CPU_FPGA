module cpu(CLK, reset, program, regDisp, dataDisp);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for cpu
    input wire reset;           // reset, active-high
    input wire [1:0] program;   // which program to run
    input wire [2:0] regDisp;   // choice of register to show
    output [15:0] dataDisp;       // output of CPU to bus

    /////////////////////////////////////////////////////////////////////////////////
    // Opcodes
    /////////////////////////////////////////////////////////////////////////////////

    parameter OP_ADD = 5'b0000;
    parameter OP_SUB = 5'b0001;
    parameter OP_OR = 5'b0010;
    parameter OP_AND = 5'b0011;
    parameter OP_XOR = 5'b0100;
    parameter OP_SL = 5'b0101;
    parameter OP_SR = 5'b0110;
    parameter OP_ADDI = 5'b0111;
    parameter OP_SUBI = 5'b1000;
    parameter OP_ORI = 5'b1001;
    parameter OP_ANDI = 5'b1010;
    parameter OP_XORI = 5'b1011;
    parameter OP_SLI = 5'b1100;
    parameter OP_SRI = 5'b1101;
    parameter OP_GT = 5'b1110;
    parameter OP_LT = 5'b1111;
    parameter OP_EQ = 5'b10000;
    parameter OP_BR = 5'b10001;
    parameter OP_STW = 5'b10010;
    parameter OP_LDW = 5'b10011;
    parameter OP_BRZ = 5'b10100;

    /////////////////////////////////////////////////////////////////////////////////
    // Flags
    /////////////////////////////////////////////////////////////////////////////////

    // parameters to define which bits in FR correspond to which flags

    parameter FLAG_Z = 0;
    parameter FLAG_N = 1;

    /////////////////////////////////////////////////////////////////////////////////
    // Setting up blocks
    /////////////////////////////////////////////////////////////////////////////////

    // wires
    wire [15:0] ALUout;
    wire MemRead, MemWrite;
    wire IR_EN, PC_EN, MDR_EN;
    wire RFwrite;
    wire [15:0] PC;
    wire [15:0] MemOut;
    wire [15:0] IR;
    wire [15:0] MDR;
    wire [3:0] op;
    wire [2:0] regA, regB, regOut;
    wire immed;
    wire [15:0] dataA, dataB, dataW;
    wire [15:0] dataB_immed;
    wire [15:0] ADDR;
    wire LDW_EN;
    wire dataW_MDR;
    wire [15:0] PC_IN;
    wire BR_EN;
    wire [15:0] ImmdZE;
    wire flag_z;

    // FSM
    FSM F0(CLK, reset, IR, flag_z, MemRead, MemWrite, IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite, LDW_EN, dataW_MDR);

    // PC, program counter
    Reg R_PC(CLK, reset, PC_EN, PC_IN, PC);

    // memory
    memory m0(CLK, reset, program, MemRead, MemWrite, ADDR, dataB_immed, MemOut);

    // IR, instruction register
    Reg R_IR(CLK, reset, IR_EN, MemOut, IR);

    // MDR, memory data register
    Reg R_MDR(CLK, reset, MDR_EN, MemOut, MDR);

    // parser
    parser p0(CLK, reset, IR, immed, op, regA, regB, regOut);

    // Register File
    RegisterFile RF(CLK, reset, RFwrite, regA, regB, regOut, regDisp, dataA, dataB, dataW, dataDisp);

    // immed selector MUX
    mux M_immed(CLK, reset, dataB, ImmdZE, immed, dataB_immed);

    // ADDR selector MUX, selects between putting PC in memory and dataA in memory
    mux M_ADDR(CLK, reset, PC, dataA, LDW_EN, ADDR);

    // dataW selector MUX, selects between putting PC in memory and dataA in memory
    mux M_dataW(CLK, reset, ALUout, MDR, dataW_MDR, dataW);

    // PC selector MUX, selects between putting PC + 1 in PC and Immd5 * 16
    mux M_PC(CLK, reset, PC + 1, ImmdZE, BR_EN, PC_IN);

    // ALU
    ALU a0(CLK, reset, op, dataA, dataB_immed, ALUout, flag_z);

    // Zero extend for Immd5
    ZE z0(IR[9:5], ImmdZE);

endmodule

module ZE(in, out);

    // Module to extend Immd5 zeros

    input [4:0] in;
    output [15:0] out;

    assign out = {11'b00000000000, in};
    
endmodule