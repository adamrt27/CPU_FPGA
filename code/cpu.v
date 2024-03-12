module cpu(CLK, reset, out)

/////////////////////////////////////////////////////////////////////////////////
// I/O
/////////////////////////////////////////////////////////////////////////////////

input wire CLK;             // clock for ALU
input wire reset;           // reset, active-high
output reg[15:0] out;       // output of CPU to bus

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
parameter OP_BRI = 5'b1110;
parameter OP_GT = 5'b1111;
parameter OP_LT = 5'b10000;
parameter OP_EQ = 5'b10001;
parameter OP_STW = 5'b10010;
parameter OP_LDW = 5'b10011;

/////////////////////////////////////////////////////////////////////////////////
// Registers
/////////////////////////////////////////////////////////////////////////////////

// 0 - 7: r0 - r7, 8: PC (program counter), 9: IR (instruction register), 10: FR (flag register)

register[10:0][15:0]
always@(posedge clk or posedge reset) begin
    if (reset) begin        // on reset, set all registers to 0
        integer i;
        integer j;
        initial begin
            for (i = 0; i < 10; i = i + 1) begin
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

