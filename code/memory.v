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


    reg[15:0] mem[15:0];
    always @(posedge CLK) begin
        if (reset) begin        // on reset, set all registers to 0
            for (i = 0; i < 15; i = i + 1) begin
                    mem[i] <= 0;
            end

            mem[0] = 16'b0010011111100111; // set first thing to be R1 = R1 + 1111 (binary)
        end
        if (MemWrite) begin
            mem[ADDR] <= Data_in;
            end
        if (MemRead) begin
            Data_out <= mem[ADDR];
            end
    end

endmodule