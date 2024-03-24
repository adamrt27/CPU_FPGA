module cpu(CLK, reset, out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for cpu
    input wire reset;           // reset, active-high
    output [15:0] out;       // output of CPU to bus

    /////////////////////////////////////////////////////////////////////////////////
    // Opcodes
    /////////////////////////////////////////////////////////////////////////////////

    // parameters to define which bit code corresponds to which command

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
    parameter OP_BR = 5'b1110;
    parameter OP_GT = 5'b1111;
    parameter OP_LT = 5'b10000;
    parameter OP_EQ = 5'b10001;
    parameter OP_STW = 5'b10010;
    parameter OP_LDW = 5'b10011;

    /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    // 0 - 7: r0 - r7, 8: PC (program counter), 9: IR (instruction register), 10: FR (flag register)

    reg [15:0]register[3:0];
    always@(posedge clk or posedge reset) begin
        if (reset) begin        // on reset, set all registers to 0
            integer i;
            integer j;
            initial begin
                for (i = 0; i < 15; i = i + 1) begin
                        register[i] <= 0;
                end
            end
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Flags
    /////////////////////////////////////////////////////////////////////////////////

    // parameters to define which bits in FR correspond to which flags

    parameter FLAG_Z = 0;
    parameter FLAG_N = 1;

    /////////////////////////////////////////////////////////////////////////////////
    // Setting up blocks
    /////////////////////////////////////////////////////////////////////////////////

    // PC
    wire [15:0] PC;
    wire PC_incr;
    wire PC_EN;
    Reg PC(CLK, reset, PC_EN, PC + PC_incr, PC);

    // IR
    wire [15:0] IR;
    wire IR_EN;
    Reg IR(CLK, reset, IR_EN, , IR);

    // Register File
    wire RFwrite;
    wire [3:0] regA, regB, regW;
    wire [15:0] dataA, dataB, dataW;
    RegisterFile RF(CLK, reset, RFwrite, regA, regB, regW, dataA, dataB, dataW);

    // memory
    
    memory m0(CLK, reset, MemRead, MemWrite, PC, Data_in, Data_out);

    // ALU
    wire [3:0] op;
    wire [15:0] in_a, in_b;
    parser p0(CLK, reset, IR, op, in_a, in_b);
    ALU a0(CLK, reset, op, in_a, in_b, out);

endmodule

module Reg(CLK, reset, EN, in, out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire EN;                      // enable signals
    input wire in;                      // input value
    output reg [15:0] out;              // current value of Reg

     /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    reg [15:0] R;
    always@(posedge clk or posedge reset) begin
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

    always@(posedge clk) begin
        out <= PC;
    end

endmodule

module RegisterFile(CLK, reset, RFwrite, regA, regB, regW, dataA, dataB, dataW);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire RFwrite;                 // if 1, regW = dataW
    input reg regA, regB, regW;        // the number of the register 
    input reg [15:0] dataW;            // data to be put into regW
    output reg [15:0] dataA, dataB;    // data to be put into regA/B

    /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    // 0 - 7: r0 - r7, 8: PC (program counter), 9: IR (instruction register), 10: FR (flag register)

    reg [15:0]register[3:0];
    always@(posedge clk or posedge reset) begin
        if (reset) begin        // on reset, set all registers to 0
            integer i;
            integer j;
            initial begin
                for (i = 0; i < 15; i = i + 1) begin
                        register[i] <= 0;
                end
            end
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Retrieving dataA and dataB
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge clk) begin
        dataA <= register[regA];
        dataB <= register[regB];
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Setting regW
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge clk) begin
        if (RFwrite) begin
            register[regW] <= dataW;
        end
    end

endmodule

module FSM(CLK, reset, MemRead, MemWrite);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                 // clock for cpu
    input wire reset;               // reset, active-high
    output reg MemRead, MemWrite;  // read and write signals for memory

    /////////////////////////////////////////////////////////////////////////////////
    // State Initialization
    /////////////////////////////////////////////////////////////////////////////////

    reg [1:0] cur_state;
    reg [1:0] next_state;

    always@(posedge CLK) begin
        if (reset) begin
            cur_state <= start;
        end
        else begin
            cur_state <= next_state;
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // State Table
    /////////////////////////////////////////////////////////////////////////////////

    // state params
    localparam fetch = 0, parse = 1, ALU_op = 2, Fin_ar = 3;

    always@(*)
    begin: state_table
        case ( cur_state )
            fetch: begin // starting state, when reset
                if (op_in) next_state = parse;
                else next_state = fetch;
            end
            parse: begin // state to load in note to waveform
                if (arith) next_state = ALU_op;
            end
            ALU_op: begin // state to play note
                next_state = Fin_ar;
            end
            Fin_ar: begin
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

        case (cur_state)
          fetch: begin
            MemRead = 1;
          end
          play_note: begin
            ld_play = 1;
          end
        endcase
    end // enable_signals

    /////////////////////////////////////////////////////////////////////////////////
    // Updating States
    /////////////////////////////////////////////////////////////////////////////////

    always @(posedge clk)
    begin: state_FFs
        if(!reset) begin
            cur_state <=  start; // Should set reset state to state A
        end
        else begin 
            // fill in
            cur_state <= next_state;
        end
    end // state_FFS
endmodule

module parser(CLK, reset, opcode, immed, op, regA, regB, regOut);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input reg[15:0] opcode;     // OPCODE in IR
    output reg immed;           // 1 if we need to take immed value, 0 othersie
    output reg[3:0] op;         // op parameter for ALU
    output reg[3:0] regA;       // value of rA
    output reg[r:0] regB;       // value of rB
    output reg[r:0] regOut;     // value of rOut

    /////////////////////////////////////////////////////////////////////////////////
    // Parsing Op-Code
    /////////////////////////////////////////////////////////////////////////////////

    always@(*)
    begin:
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
    input reg[3:0] op;          // which operation to do
    input reg[15:0] in_a;       // value of register a for input to ALU
    input reg[15:0] in_b;       // value of register b for input to ALU
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
                out <= in_a == in_b;
            end
        end
    end

endmodule