op = {
    "ADD": "00000",
    "SUB": "00001",
    "OR": "00010",
    "AND": "00011",
    "XOR": "00100",
    "SL": "00101",
    "SR": "00110",
    "ADDI": "00111",
    "SUBI": "01000",
    "ORI": "01001",
    "ANDI": "01010",
    "XORI": "01011",
    "SLI": "01100",
    "SRI": "01101",
    "GT": "01110",
    "LT": "01111",
    "EQ": "10000",
    "BR": "10001",
    "STW": "10010",
    "LDW": "10011",
    "BRZ": "10100"
}

arith = ["ADD", "SUB", "OR", "AND", "XOR", "SL", "SR", "GT", "LT", "EQ"]
arith_im = ["ADDI", "SUBI", "ORI", "ANDI", "XORI", "SLI", "SRI"]

def parse_instr(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is
    temp = instr.split(" ")
    if temp[0] in arith:
        return parse_arith(instr)
    elif temp[0] in arith_im:
        return parse_arith_im(instr)
    elif temp[0] in ["BR", "BRZ"]:
        return parse_br_brz(instr)
    elif temp[0] == "STW":
        return parse_stw(instr)
    elif temp[0] == "LDW":
        return parse_ldw(instr)
    else:
        return "Invalid Instruction"

def dec_to_bin(num):
    return str(format(num, '016b'))

def zero_extend_5_bit(num):
    if(len(num) < 5):
        return "0"*(5-len(num)) + num
    return num

def check_reg(num):
    if(num < 0 or num > 7):
        print("Invalid Register")
        return False
    return True
    

# takes instruction like ADD Ro Ra Rb and converts to opcode
def parse_arith(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is Rout, temp[2] is Ra, temp[3] is Rb
    temp = instr.split(" ")
    opcode = op[temp[0]]
    # convert registers to binary
    # check if registers are valid
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][1:])) and check_reg(int(temp[3][1:]))):
        return
    rout = dec_to_bin(int(temp[1][1:]))[-3:]
    ra = dec_to_bin(int(temp[2][1:]))[-3:]
    rb = dec_to_bin(int(temp[3][1:]))[-3:]
    return rout + ra + rb + "00" + opcode

# takes instruction like ADDI Ro Ra immed5 and converts to opcode
def parse_arith_im(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is Rout, temp[2] is Ra, temp[3] is immediate
    temp = instr.split(" ")
    opcode = op[temp[0]]
    # convert registers to binary
    # check if registers are valid
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][1:]))):
        return
    rout = dec_to_bin(int(temp[1][1:]))[-3:]
    ra = dec_to_bin(int(temp[2][1:]))[-3:]
    # checks if input as binary (start with 0bxxx) or decimal
    if ("0b" not in temp[3]):
        immed5 = dec_to_bin(int(temp[3]))
        # check if immediate value is too large
        if (immed5[-6] != '0'):
            print("Immediate value too large")
            return
        immed5 = immed5[-5:]
    else:
        immed5 = zero_extend_5_bit(temp[3][2:])
        # check if immediate value is too large
        if (len(immed5) > 5):
            print("Immediate value too large")
            return
    return rout + ra + immed5 + opcode

# takes instruction like BR Immed5 or BRZ Immed5 and converts to opcode
def parse_br_brz(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is immediate
    temp = instr.split(" ")
    opcode = op[temp[0]]
    # checks if input as binary (start with 0bxxx) or decimal
    if ("0b" not in temp[1]):
        immed5 = dec_to_bin(int(temp[1]))
        # check if immediate value is too large
        if (immed5[-6] != '0'):
            print("Immediate value too large")
            return
        immed5 = immed5[-5:]
    else:
        immed5 = zero_extend_5_bit(temp[1][2:])
        # check if immediate value is too large
        if (len(immed5) > 5):
            print("Immediate value too large")
            return
    return "000000" + immed5 + opcode

# takes instruction like LDW Ro (Ra) and converts to opcode
def parse_ldw(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is Rout, temp[2] is (Ra)
    temp = instr.split(" ")
    opcode = op[temp[0]]
    # convert registers to binary
    # check if registers are valid
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][2:-1]))):
        return
    rout = dec_to_bin(int(temp[1][1:]))[-3:]
    ra = dec_to_bin(int(temp[2][2:3]))[-3:]
    return rout + ra + "00000" + opcode

# takes instruction like STW Rb (Ra) and converts to opcode
def parse_stw(instr):
    # split instruction into temp, temp[0] is operation, temp[1] is Rout, temp[2] is (Ra)
    temp = instr.split(" ")
    opcode = op[temp[0]]
    # convert registers to binary
    # check if registers are valid
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][2:-1]))):
        return
    rb = dec_to_bin(int(temp[1][1:]))[-3:]
    ra = dec_to_bin(int(temp[2][2:3]))[-3:]
    return "000" + ra + rb + "00" + opcode

# Compute sum of 1 to 30
# write the below printed code into the form
# mem[i] = parse_instr("INSTRUCTION")
# where i is the memory address
# then run the code
code = ["ADDI R1 R1 1", "ADDI R3 R3 29", "SUB R2 R2 R2", "SUB R4 R4 R4", "ADD R2 R1 R2", "ADD R4 R4 R2", "GT R5 R2 R3", "BRZ 4", "BR 8"]
i = 0
for line in code:
    print("mem[" + str(i) + "] = 16'b" + parse_instr(line) + ";")
    i += 1

res = 0
for i in range(31):
    res += i
print(res)

# print("mem[" + i + "]" + parse_instr("ADDI R1 R1 1")) # set r1 to 1
# print(parse_instr("ADDI R3 R3 29")) # set r3 to 29
# print(parse_instr("SUB R2 R2 R2")) # set r2 to 0
# print(parse_instr("SUB R4 R4 R4")) # set r4 to 0

# print(parse_instr("ADD R2 R1 R2")) # store current value of loop in r2
# print(parse_instr("ADD R4 R4 R2")) # add r2 to r4
# print(parse_instr("GT R5 R2 R3")) # check if current counter value less than 30
# print(parse_instr("BRZ 4")) # loops back to start of loop if current counter value less than 30

# print(parse_instr("BR 8")) # iloop


'''
.global _start
_start:
   movi r1, 1 /* put 1 in r1 */
   movi r3, 29
   movi r2, 0
   movi r12, 0
   
LOOP:
   add r2, r1, r2 /* store current value of loop in r2 */
   add r12, r12, r2 /* add r2 to r12 */
   ble r2, r3, LOOP /* loops back to start of loop if current counter value less than 30 */
   
done: br done 
'''