// memory for computer

module memory(CLK, reset, MemRead, MemWrite, ADDR, Data_in, Data_out);

    reg[15:0] mem[16];
    always @(*) begin
        if (reset) begin        // on reset, set all registers to 0
            integer i;
            initial begin
                for (i = 0; i < 15; i = i + 1) begin
                        mem[i] <= 0;
                end
            end

            mem[0] = 16'b001001111110111; // set first thing to be R1 = R1 + 1111 (binary)
        end
        if (MemWrite)
            mem[ADDR] <= Data_in;
        if (MemRead)
            Data_out <= mem[ADDR];
    end

endmodule