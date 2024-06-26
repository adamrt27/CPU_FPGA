module RegisterFile(CLK, reset, RFwrite, regA, regB, regW, regDisp, dataA, dataB, dataW, dataDisp);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire RFwrite;                 // if 1, regW = dataW
    input wire [2:0] regA, regB, regW, regDisp;        // the number of the register 
    input wire [15:0] dataW;            // data to be put into regW
    output reg [15:0] dataA, dataB, dataDisp;    // data to be put into regA/B

    integer i;


    /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization and setting regW
    /////////////////////////////////////////////////////////////////////////////////

    // 0 - 7: r0 - r7

    reg [15:0]register[7:0];
    always@(posedge CLK) begin
        if (reset) begin        // on reset, set all registers to 0
            for (i = 0; i < 8; i = i + 1) begin
                register[i] <= 16'b0;
            end
        end

        if (RFwrite) begin
            register[regW] <= dataW;
        end
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Retrieving dataA and dataB
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge CLK) begin
        dataA <= register[regA];
        dataB <= register[regB];
        dataDisp <= register[regDisp];
    end

endmodule

