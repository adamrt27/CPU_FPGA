// memory for computer

module memory(CLK, reset, program, MemRead, MemWrite, ADDR, Data_in, Data_out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for cpu
    input wire reset;           // reset, active-high
    input wire [1:0] program;   // which program to run
    input wire MemRead, MemWrite;
    input wire [15:0] ADDR;
    input wire [15:0] Data_in;
    output reg [15:0] Data_out;

    integer i;


    reg[15:0] mem[1023:0];
    always @(posedge CLK) begin
        if (reset) begin        // on reset, set all registers to 0
            if (program == 2'b10) begin // if key 2, do lab 2

                mem[25] = 16'd0;
                mem[26] = 16'd6;
                mem[27] = 16'd4;
                mem[28] = 16'd5;
                mem[29] = 16'd6;
                mem[30] = 16'd7;
                mem[31] = 16'd8;

                mem[0] = 16'b0000001100100111;
                mem[1] = 16'b0010000000100111;
                mem[2] = 16'b0100010000010011;
                mem[3] = 16'b0110111101100111;
                mem[4] = 16'b1000110000010011;
                mem[5] = 16'b0100100000101000;
                mem[6] = 16'b0000000111010100;
                mem[7] = 16'b0110110000100111;
                mem[8] = 16'b1010110000010011;
                mem[9] = 16'b1101011000001110;
                mem[10] = 16'b0000000010110100;
                mem[11] = 16'b1001001000000001;
                mem[12] = 16'b1001001010000000;
                mem[13] = 16'b0000000010110001;
                mem[14] = 16'b0000001000010010;
                mem[15] = 16'b1001000000000111;
                mem[16] = 16'b0000000111110001;
            end
            if (program == 2'b01) begin // if key 1, do lab 1
            
                mem[0] = 16'b0010010000100111;
                mem[1] = 16'b0110111110100111;
                mem[2] = 16'b0100100100000001;
                mem[3] = 16'b1001001000000001;
                mem[4] = 16'b0100010100000000;
                mem[5] = 16'b1001000100000000;
                mem[6] = 16'b1010100110001110;
                mem[7] = 16'b0000000010010100;
                mem[8] = 16'b0000000100010001;
            end
        end
        if (MemWrite) begin
            mem[ADDR] <= Data_in;
            end
        if (MemRead) begin
            Data_out <= mem[ADDR];
            end
    end

endmodule