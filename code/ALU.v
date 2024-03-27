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