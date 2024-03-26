module mux(CLK, reset, a, b, sel, out);
    
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
            0: out <= a;
            1: out <= b;
        endcase
    end

endmodule