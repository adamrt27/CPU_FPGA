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

            // the following code adds numbers from 1 to 30 and places result in r4
            mem[0] = 16'b0010010000100111; 
            mem[1] = 16'b0110111110100111;
            mem[2] = 16'b0100100100000001;
            mem[3] = 16'b1001001000000001;
            mem[4] = 16'b0100010100000000;
            mem[5] = 16'b1001000100000000;
            mem[6] = 16'b1010100110001110;
            mem[7] = 16'b0000000010010100;
            mem[8] = 16'b0001000100010001; // add in extra 1 at 12th bit to show r4 (does effect BR)

            /* equivalent code:

            _start:
                movi r1, 1 /* put 1 in r1 
                movi r3, 29
                movi r2, 0
                movi r12, 0
                
            LOOP:
                add r2, r1, r2 /* store current value of loop in r2 
                add r12, r12, r2 /* add r2 to r12 
                ble r2, r3, LOOP /* loops back to start of loop if current counter value less than 30 
                
            done: br done
            */

            /*mem[0] = 16'b0010011111100111; // set first thing to be R1 = R1 + 1111 (binary)
            mem[1] = 16'b0010011111100111; // R1 = 1111 + 1111 = 011110
            mem[2] = 16'b0010010001101100; // R1 = 11110 << 11 = 11110000
            mem[3] = 16'b0100100010000001; // R2 = R2 - R1 = 0 - 11110000

            mem[4] = 16'b0110111111000111;// R3 = R3 + 30 = 0 + 30 = 30
            mem[5] = 16'b1111111111100111;     // r7 = r7 + 31 = 31
            mem[6] = 16'b0000111110010010;     // stw r7, (r3)
            //mem[30] = 16'd69;  // set Mem[30] = 69
            mem[7] = 16'b1000110000010011; // load r4, (r3) R4 = Mem[R3 (== 30)]
            mem[8] = 16'b1001000000001010; // R4 = R4 + 0 = R4 // just to see r4 value

            mem[9] = 16'b1001001000000001; // R4 = R4 - R4 = 0
            mem[10] = 16'b0000001111110100; // BRZ 11111

            // add iloop: BR 7
            mem[31] = 16'b00000011111110001; 
            mem[12] = 0;
            mem[13] = 0; */

            /*
            Nios II equiv:
            main:
                addi r1, r1, 0b1111
                addi r1, r1, 0b1111
                sub r2, r2, r1
                addi r3, r3, data
                addi r7, r7, 0b1111
                stw r7, (r3)
                ldw r4, (r3)
                addi r4, r4, 0
            
            iloop:
                br iloop
            */
        end
        if (MemWrite) begin
            mem[ADDR] <= Data_in;
            end
        if (MemRead) begin
            Data_out <= mem[ADDR];
            end
    end

endmodule