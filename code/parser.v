module parser(CLK, reset, opcode, immed, op, regA, regB, regOut);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input wire[15:0] opcode;     // OPCODE in IR
    output reg immed;           // 1 if we need to take immed value, 0 othersie
    output reg[3:0] op;         // op parameter for ALU
    output reg[2:0] regA;       // value of rA
    output reg[2:0] regB;       // value of rB
    output reg[2:0] regOut;     // value of rOut

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

    parameter IDLE = 4'd0;
    parameter ADD = 4'd1;
    parameter SUB = 4'd2;
    parameter OR = 4'd3;
    parameter AND = 4'd4;
    parameter XOR = 4'd5;
    parameter SL = 4'd6;
    parameter SR = 4'd7;
    parameter GT = 4'd8;
    parameter LT = 4'd9;
    parameter EQ = 4'd10;

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