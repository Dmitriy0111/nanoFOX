pars_file  = open("program_file/program.ihex" , "r")

out_file   = open("program_file/program.hex"  , "w")
out_file_0 = open("program_file/program_0.hex", "w")
out_file_1 = open("program_file/program_1.hex", "w")
out_file_2 = open("program_file/program_2.hex", "w")
out_file_3 = open("program_file/program_3.hex", "w")

def ascii2dec(symbol):
    value = -1
    value = 0  if (symbol == '0') else value
    value = 1  if (symbol == '1') else value
    value = 2  if (symbol == '2') else value
    value = 3  if (symbol == '3') else value
    value = 4  if (symbol == '4') else value
    value = 5  if (symbol == '5') else value
    value = 6  if (symbol == '6') else value
    value = 7  if (symbol == '7') else value
    value = 8  if (symbol == '8') else value
    value = 9  if (symbol == '9') else value
    value = 10 if (symbol == 'A') else value
    value = 11 if (symbol == 'B') else value
    value = 12 if (symbol == 'C') else value
    value = 13 if (symbol == 'D') else value
    value = 14 if (symbol == 'E') else value
    value = 15 if (symbol == 'F') else value
    return value

for lines in pars_file:
    # break if end of program
    if( lines[0:-1] == ":00000001FF" ):
        break
    # delete :
    lines = lines[1:]
    # find lenght
    lenght = ascii2dec(lines[1]) + ascii2dec(lines[0]) * 16
    lines = lines[2:]
    # find addr
    addr = ( ascii2dec(lines[3]) + ascii2dec(lines[2]) * 16 + ascii2dec(lines[1]) * 32 + ascii2dec(lines[0]) * 64 ) // 4
    addr = hex(addr)[2:]
    lines = lines[4:]
    # find type
    type_ = lines[0:2]
    lines = lines[2:]
    # find checksum
    checksum = lines[-3:-1]
    lines = lines[0:-3]
    i = 0
    # write addr
    out_file.write  ("@" + addr + "\n")
    out_file_0.write("@" + addr + "\n")
    out_file_1.write("@" + addr + "\n")
    out_file_2.write("@" + addr + "\n")
    out_file_3.write("@" + addr + "\n")
    while(1):
        # write data
        out_file_0.write(lines[0:2] + "\n")
        out_file_1.write(lines[2:4] + "\n")
        out_file_2.write(lines[4:6] + "\n")
        out_file_3.write(lines[6:8] + "\n")
        out_file.write  (lines[0:8] + "\n")
        lines = lines[8:]
        i += 4
        if( i >= lenght ):
            break

print("Conversion comlete!")
