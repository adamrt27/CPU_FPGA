module cpu(CLK, reset);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for cpu
    input wire reset;           // reset, active-high
    //output [15:0] out;       // output of CPU to bus

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
    wire [3:0] op, regA, regB, regOut;
    wire immed;
    wire [15:0] dataA, dataB, dataW;
    wire [15:0] dataB_immed;
    wire [15:0] ADDR;
    wire LDW_EN;
    wire dataW_MDR;
    wire [15:0] PC_IN;
    wire BR_EN;

    // FSM
    FSM F0(CLK, reset, IR, MemRead, MemWrite, IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite, LDW_EN, dataW_MDR);

    // PC, program counter
    Reg R_PC(CLK, reset, PC_EN, PC_IN, PC);

    // memory
    memory m0(CLK, reset, MemRead, MemWrite, ADDR, dataB_immed, MemOut);

    // IR, instruction register
    Reg R_IR(CLK, reset, IR_EN, MemOut, IR);

    // MDR, memory data register
    Reg R_MDR(CLK, reset, MDR_EN, MemOut, MDR);

    // parser
    parser p0(CLK, reset, IR, immed, op, regA, regB, regOut);

    // Register File
    RegisterFile RF(CLK, reset, RFwrite, regA, regB, regOut, dataA, dataB, dataW);

    // immed selector MUX
    MUX_2_to_1_SE M_immed(CLK, reset, dataB, IR[9:5], immed, dataB_immed);

    // ADDR selector MUX, selects between putting PC in memory and dataA in memory
    MUX_2_to_1_SE M_ADDR(CLK, reset, PC, dataA, LDW_EN, ADDR);

    // dataW selector MUX, selects between putting PC in memory and dataA in memory
    MUX_2_to_1_SE M_dataW(CLK, reset, ALUout, MDR, dataW_MDR, dataW);

    // PC selector MUX, selects between putting PC + 1 in PC and Immd5 * 16
    MUX_2_to_1_SE M_PC(CLK, reset, PC + 1, IR[9:5] * 16, BR_EN, PC_IN);

    // ALU
    ALU a0(CLK, reset, op, dataA, dataB_immed, ALUout);

endmodule

module FSM(CLK, reset, opcode, MemRead, MemWrite, IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite, LDW_EN, dataW_MDR);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                                 // clock for cpu
    input wire reset;                               // reset, active-high
    input wire [15:0] opcode;                            // opcode
    output reg MemRead, MemWrite;                   // read and write signals for memory
    output reg IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite;// enable signals for PC, IR, MDR and RF
    output reg LDW_EN, dataW_MDR;                   // selectors for muxes to control input to memory ADDR 
                                                    // and input to dataW

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

    /////////////////////////////////////////////////////////////////////////////////
    // State Initialization
    /////////////////////////////////////////////////////////////////////////////////

    reg [1:0] cur_state;
    reg [1:0] next_state;

    /////////////////////////////////////////////////////////////////////////////////
    // State Table
    /////////////////////////////////////////////////////////////////////////////////

    // state params
    localparam fetch = 0, parse = 1, AR_ALU = 2, AR_ROut = 3, LDW_MDR = 4, LDW_ROut = 5, STW = 6, BR = 7;

    always@(*)
    begin: state_table
        case ( cur_state )
            fetch: begin // starting state, when reset
                next_state = parse;
            end
            parse: begin // state to load in note to waveform
                if (opcode[4:0] <= OP_EQ) next_state = AR_ALU; // if op < 8, it is arithmetic
                else if (opcode[4:0] == OP_LDW) next_state = LDW_MDR;        // if op == 8,
                else if (opcode[4:0] == OP_STW) next_state = STW;
                else if (opcode[4:0] == OP_BR) next_state = BR;
            end
            AR_ALU: begin // state to play note
                next_state = AR_ROut;
            end
            AR_ROut: begin
                next_state = fetch;
            end
            LDW_MDR: begin
                next_state = LDW_ROut;
            end
            LDW_ROut: begin
                next_state = fetch;
            end
            STW: begin
                next_state = fetch;
            end
            BR: begin
                next_state = fetch;
            end
        endcase
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Enable Signals
    /////////////////////////////////////////////////////////////////////////////////

    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        MemRead = 0;
        MemWrite = 0;
        PC_EN = 0;
        IR_EN = 0;
        RFwrite = 0;
        LDW_EN = 0;
        MDR_EN = 0;
        BR_EN = 0;
        dataW_MDR = 0;

        case (cur_state)
          fetch: begin
            MemRead = 1;
            PC_EN = 1;
            IR_EN = 1;
          end
          AR_ROut: begin
            RFwrite = 1;
          end
          LDW_MDR: begin
            LDW_EN = 1;
            MDR_EN = 1;
            MemRead = 1;
          end
          LDW_ROut: begin
            dataW_MDR = 1;
            RFwrite = 1;
          end
          STW: begin
            LDW_EN = 1;
            MemWrite = 1;
          end
          BR: begin
            BR_EN = 1;
          end
        endcase
    end // enable_signals

    /////////////////////////////////////////////////////////////////////////////////
    // Updating States
    /////////////////////////////////////////////////////////////////////////////////

    always @(posedge CLK)
    begin: state_FFs
        if(reset) begin
            cur_state <=  fetch; // Should set reset state to state A
        end
        else begin 
            // fill in
            cur_state <= next_state;
        end
    end // state_FFS
endmodule

module Reg(CLK, reset, EN, in, out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire EN;                      // enable signals
    input wire [15:0] in;                      // input value
    output reg [15:0] out;              // current value of Reg

     /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    reg [15:0] R;
    always@(posedge CLK or posedge reset) begin
        if (reset) begin        // on reset, set all registers to 0
            R <= 0;
        end
        if (EN) begin
            R <= in;
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // setting output
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge CLK) begin
        out <= in;
    end

endmodule

module RegisterFile(CLK, reset, RFwrite, regA, regB, regW, dataA, dataB, dataW);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire RFwrite;                 // if 1, regW = dataW
    input wire [3:0] regA, regB, regW;        // the number of the register 
    input wire [15:0] dataW;            // data to be put into regW
    output reg [15:0] dataA, dataB;    // data to be put into regA/B

    integer i;


    /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    // 0 - 7: r0 - r7

    reg [15:0]register[2:0];
    always@(posedge CLK or posedge reset) begin
        if (reset) begin        // on reset, set all registers to 0
            for (i = 0; i < 8; i = i + 1) begin
                    register[i] <= 0;
            end
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Retrieving dataA and dataB
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge CLK) begin
        dataA <= register[regA];
        dataB <= register[regB];
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Setting regW
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge CLK) begin
        if (RFwrite) begin
            register[regW] <= dataW;
        end
    end

endmodule

module parser(CLK, reset, opcode, immed, op, regA, regB, regOut);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input wire[15:0] opcode;     // OPCODE in IR
    output reg immed;           // 1 if we need to take immed value, 0 othersie
    output reg[3:0] op;         // op parameter for ALU
    output reg[3:0] regA;       // value of rA
    output reg[3:0] regB;       // value of rB
    output reg[3:0] regOut;     // value of rOut

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

    /////////////////////////////////////////////////////////////////////////////////
    // Operations
    /////////////////////////////////////////////////////////////////////////////////

    // operations go: out = (in_a) op (in_b)
    // parameters to 

    parameter IDLE = 0;
    parameter ADD = 1;
    parameter SUB = 2;
    parameter OR = 3;
    parameter AND = 4;
    parameter XOR = 5;
    parameter SL = 6;
    parameter SR = 7;
    parameter GT = 8;
    parameter LT = 9;
    parameter EQ = 10;

    /////////////////////////////////////////////////////////////////////////////////
    // Parsing Op-Code
    /////////////////////////////////////////////////////////////////////////////////

    always@(*)
    begin
        op = 0;
        immed = 0;
        case(opcode[4:0])
            OP_ADD: begin
                op = ADD;
            end
            OP_SUB: begin
                op = SUB;
            end
            OP_OR: begin
                op = OR;
            end
            OP_AND: begin
                op = AND;
            end
            OP_XOR: begin
                op = XOR;
            end
            OP_SL: begin
                op = SL;
            end
            OP_SR: begin
                op = SR;
            end
            OP_ADDI: begin
                op = ADD;
                immed = 1;
            end
            OP_SUBI: begin
                op = SUB;
                immed = 1;
            end
            OP_ORI: begin
                op = OR;
                immed = 1;
            end
            OP_ANDI: begin
                op = AND;
                immed = 1;
            end
            OP_XORI: begin
                op = XOR;
                immed = 1;
            end
            OP_SLI: begin
                op = SL;
                immed = 1;
            end
            OP_SRI: begin
                op = SR;
                immed = 1;
            end
            OP_BR: begin
                op = IDLE;
            end
            OP_GT: begin
                op = GT;
            end
            OP_LT: begin
                op = LT;
            end
            OP_EQ: begin
                op = EQ;
            end
            OP_STW: begin
                op = IDLE;
            end
            OP_LDW: begin
                op = IDLE;
            end
        endcase
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Parsing Registers
    /////////////////////////////////////////////////////////////////////////////////


    always@(*)
    begin
        if(immed == 0) begin
            regOut = opcode[15:13];
            regA = opcode[12:10];
            regB = opcode[9:7];
        end 
        else begin
            regOut = opcode[15:13];
            regA = opcode[12:10];
        end
    end

endmodule

module MUX_2_to_1_SE(CLK, reset, a, b, sel, out);

    // 16 bit, 2-1 mux with sign extension to be used for immediates
    
    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input wire [15:0] a, b;      // inputs a,b
    input wire sel;             // selector bit
    output reg [15:0] out;       // output of MUX

    always@(*) begin
        case(sel) 
            0: out <= $signed(a);
            1: out <= $signed(b);
        endcase
    end

endmodule


module ALU(CLK, reset, op, in_a, in_b, out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input wire[3:0] op;          // which operation to do
    input wire[15:0] in_a;       // value of register a for input to ALU
    input wire[15:0] in_b;       // value of register b for input to ALU
    output reg[15:0] out;       // value of register for output of ALU

    /////////////////////////////////////////////////////////////////////////////////
    // Operations
    /////////////////////////////////////////////////////////////////////////////////

    // operations go: out = (in_a) op (in_b)
    // parameters to 

    parameter IDLE = 0;
    parameter ADD = 1;
    parameter SUB = 2;
    parameter OR = 3;
    parameter AND = 4;
    parameter XOR = 5;
    parameter SL = 6;
    parameter SR = 7;
    parameter GT = 8;
    parameter LT = 9;
    parameter EQ = 10;

    always@(posedge CLK or posedge reset) begin
        if (reset) begin
            out <= 0;
        end 
        else begin
            if (op == ADD) begin
                out <= in_a + in_b;
            end
            if (op == SUB) begin
                out <= in_a - in_b;
            end
            if (op == OR) begin
                out <= in_a || in_b;
            end
            if (op == AND) begin
                out <= in_a && in_b;
            end
            if (op == XOR) begin
                out <= (in_a || !(in_b)) && (!(in_a) || in_b);
            end
            if (op == SL) begin
                out <= in_a << in_b;
            end
            if (op == SR) begin
                out <= in_a >> in_b;
            end
            if (op == GT) begin
                out <= in_a > in_b;
            end
            if (op == LT) begin
                out <= in_a < in_b;
            end
            if (op == EQ) begin
                out <= (in_a == in_b);
            end
        end
    end

endmodule