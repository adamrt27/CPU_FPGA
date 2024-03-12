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
    // Registers
    /////////////////////////////////////////////////////////////////////////////////

    // 0 - 7: r0 - r7, 8: PC (program counter), 9: IR (instruction register), 10: FR (flag register)

    reg [15:0]register[3:0];
    always@(posedge clk or posedge reset) begin
        if (reset) begin        // on reset, set all registers to 0
            integer i;
            integer j;
            initial begin
                for (i = 0; i < 5; i = i + 1) begin
                    for (j = 0; j < 16; j = j + 1) begin
                        register[i][j] <= 0;
                    end
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

endmodule

module FSM(CLK, reset, opcode, op);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input reg[15:0] opcode;     // OPCODE in IR
    input reg [15:0]register[3:0];
    output reg[3:0] op;         // op parameter for ALU
    output reg[15:0] in_a;       // value of register a for input to ALU
    output reg[15:0] in_b;       // value of register b for input to ALU


    reg immd;                   // if 1, put immed in in_b
    
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
    localparam start = 0, load_op = 1, load_a = 2, load_b = 3;

    always@(*)
    begin: state_table
        case ( cur_state )
            start: begin // starting state, when reset
                if (note_in) next_state = load_note;
                else next_state = start;
            end
            load_note: begin // state to load in note to waveform
                next_state = play_note;
            end
            play_note: begin // state to play note
                if (note_in) next_state = load_note;
                else next_state = play_note;
            end  
        endcase

    end

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

    reg [3:0] reg_a;
    reg [3:0] reg_b;

    always@(*)
    begin
        if(immed == 0) begin
            reg_a = opcode[15:13];
            reg_b = opcode[8:5];
        end 
        else begin
            reg_a = opcode[15:13];
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Retrieving Value from Registers
    /////////////////////////////////////////////////////////////////////////////////

    always@(*)
    begin
        if(immed == 0) begin
            in_a = registers[reg_a];
            in_b = registers[reg_b];
        end
        else begin
            in_a = registers[reg_a];
            in_b = opcode[12:5];
        end
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