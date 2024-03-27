module Reg(CLK, reset, EN, in, out);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                     // clock for cpu
    input wire reset;                   // reset, active-high
    input wire EN;                      // enable signals
    input wire [15:0] in;                      // input value
    output reg [15:0] out;              // current value of Reg

     /////////////////////////////////////////////////////////////////////////////////
    // Register Initialization
    /////////////////////////////////////////////////////////////////////////////////

    always@(posedge CLK) begin
        if (reset) begin        // on reset, set all registers to 0
            out <= 0;
        end
        if (EN) begin
            out <= in;
        end
    end

endmodule


