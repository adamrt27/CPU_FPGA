// memory for computer

module memory(CLK, reset, MemRead, MemWrite, ADDR, Data_in, Data_out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for cpu
    input wire reset;           // reset, active-high
    input wire MemRead, MemWrite;
    input wire [15:0] ADDR;
    input wire [15:0] Data_in;
    output reg [15:0] Data_out;

    integer i;


    reg[15:0] mem[1023:0];
    always @(posedge CLK) begin
        if (reset) begin        // on reset, set all registers to 0
            mem[0] = 16'b0010011111100111; // set first thing to be R1 = R1 + 1111 (binary)
            mem[1] = 16'b0010011111100111; // R1 = 1111 + 1111 = 011110
            mem[2] = 16'b0010010001101100; // R1 = 11110 << 11 = 11110000
            mem[3] = 16'b0100100010000001; // R2 = R2 - R1 = 0 - 11110000
        end
        if (MemWrite) begin
            mem[ADDR] <= Data_in;
            end
        if (MemRead) begin
            Data_out <= mem[ADDR];
            end
    end

endmodule