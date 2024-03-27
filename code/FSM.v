module FSM(CLK, reset, opcode, MemRead, MemWrite, IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite, LDW_EN, dataW_MDR);

    /////////////////////////////////////////////////////////////////////////////////
    // module I/O
    /////////////////////////////////////////////////////////////////////////////////

    input wire CLK;                                 // clock for cpu
    input wire reset;                               // reset, active-high
    input wire [15:0] opcode;                            // opcode
    output reg MemRead, MemWrite;                   // read and write signals for memory
    output reg IR_EN, PC_EN, MDR_EN, BR_EN, RFwrite;// enable signals for PC, IR, MDR and RF
    output reg LDW_EN, dataW_MDR;                   // selectors for muxes to control input to memory ADDR 
                                                    // and input to dataW

    /////////////////////////////////////////////////////////////////////////////////
    // Opcodes
    /////////////////////////////////////////////////////////////////////////////////

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
    parameter OP_GT = 5'b1110;
    parameter OP_LT = 5'b1111;
    parameter OP_EQ = 5'b10000;
    parameter OP_BR = 5'b10001;
    parameter OP_STW = 5'b10010;
    parameter OP_LDW = 5'b10011;

    /////////////////////////////////////////////////////////////////////////////////
    // State Initialization
    /////////////////////////////////////////////////////////////////////////////////

    reg [2:0] cur_state;
    reg [2:0] next_state;

    /////////////////////////////////////////////////////////////////////////////////
    // State Table
    /////////////////////////////////////////////////////////////////////////////////

    // state params
    localparam idle = 0, fetch = 1, parse = 2, AR_ALU = 3, AR_ROut = 4, LDW_MDR = 5, LDW_ROut = 6, STW = 7, BR = 8;

    always@(*)
    begin: state_table
        case ( cur_state )
            idle: begin
                if (!reset) next_state = fetch;
            end
            fetch: begin // starting state, when reset
                next_state = parse;
            end
            parse: begin // state to load in note to waveform
                if (opcode[4:0] <= OP_EQ) next_state = AR_ALU; // if op < 8, it is arithmetic
                else if (opcode[4:0] == OP_LDW) next_state = LDW_MDR;        // if op == 8,
                else if (opcode[4:0] == OP_STW) next_state = STW;
                else if (opcode[4:0] == OP_BR) next_state = BR;
            end
            AR_ALU: begin // state to play note
                next_state = AR_ROut;
            end
            AR_ROut: begin
                next_state = fetch;
            end
            LDW_MDR: begin
                next_state = LDW_ROut;
            end
            LDW_ROut: begin
                next_state = fetch;
            end
            STW: begin
                next_state = fetch;
            end
            BR: begin
                next_state = fetch;
            end
        endcase
    end

    /////////////////////////////////////////////////////////////////////////////////
    // Enable Signals
    /////////////////////////////////////////////////////////////////////////////////

    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        MemRead = 0;
        MemWrite = 0;
        PC_EN = 0;
        IR_EN = 0;
        RFwrite = 0;
        LDW_EN = 0;
        MDR_EN = 0;
        BR_EN = 0;
        dataW_MDR = 0;

        case (cur_state)
          fetch: begin
            MemRead = 1;
            PC_EN = 1;
            IR_EN = 1;
          end
          AR_ROut: begin
            RFwrite = 1;
          end
          LDW_MDR: begin
            LDW_EN = 1;
            MDR_EN = 1;
            MemRead = 1;
          end
          LDW_ROut: begin
            dataW_MDR = 1;
            RFwrite = 1;
          end
          STW: begin
            LDW_EN = 1;
            MemWrite = 1;
          end
          BR: begin
            BR_EN = 1;
          end
        endcase
    end // enable_signals

    /////////////////////////////////////////////////////////////////////////////////
    // Updating States
    /////////////////////////////////////////////////////////////////////////////////

    always @(posedge CLK)
    begin: state_FFs
        if(reset) begin
            cur_state <= idle; // Should set reset state to state A
        end
        else begin 
            // fill in
            cur_state <= next_state;
        end
    end // state_FFS
endmodule