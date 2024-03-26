module MUX_2_to_1_SE(CLK, reset, a, b, sel, out);

    // 16 bit, 2-1 mux with sign extension to be used for immediates
    
    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;             // clock for ALU
    input wire reset;           // reset, active-high
    input wire [15:0] a, b;      // inputs a,b
    input wire sel;             // selector bit
    output reg [15:0] out;       // output of MUX

    always@(*) begin
        case(sel) 
            0: out <= $signed(a);
            1: out <= $signed(b);
        endcase
    end

endmodule