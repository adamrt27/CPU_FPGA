input_file = "assembly2.txt"

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
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][2:-2]))):
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
    if not (check_reg(int(temp[1][1:])) and check_reg(int(temp[2][2:-2]))):
        return
    rb = dec_to_bin(int(temp[1][1:]))[-3:]
    ra = dec_to_bin(int(temp[2][2:3]))[-3:]
    return "000" + ra + rb + "00" + opcode

# open file and parse each line
in_file = open(input_file, "r")
out_file = open("output.txt", "w")
i = 0
data = False
code = False
for line in in_file:
    if line == "\n":
        continue
    if line[0] == "#":
        continue
    if line == "data:\n":
        data = True
        continue
    if line == "code:\n":
        data = False
        code = True
        i = 0
        continue
    if data:
        temp = line.split(" ")
        num = temp[1].split(",")
        if(len(num) > 1):
            for j in range(len(num)):
                out_file.write("mem[" + str(int(temp[0][:-1]) + j) + "] = 16'd" + str(int(num[j])) + ";")
                out_file.write("\n")
        else:
            out_file.write("mem[" + temp[0][:-1] + "] = 16'd" + str(int(temp[1])) + ";")
    if code:
        out_file.write("mem[" + str(i) + "] = 16'b" + parse_instr(line) + ";")
    i += 1
    out_file.write("\n")