module ZE(in, out);

    input [4:0] in;
    output [15:0] out;

    assign out = {00000000000, in};
    
endmodule