#
#  File            :   ihex2hex.py
#  Autor           :   Vlasov D.V.
#  Data            :   2019.03.04
#  Language        :   Python
#  Description     :   This is script for converting ihex format to hex
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
#


pars_file  = open("program_file/program.ihex" , "r")

out_file_0 = open("program_file/program_0.hex", "w")    # bank_0
out_file_1 = open("program_file/program_1.hex", "w")    # bank_1
out_file_2 = open("program_file/program_2.hex", "w")    # bank_2
out_file_3 = open("program_file/program_3.hex", "w")    # bank_3

hi_addr = 0

for lines in pars_file:
    # find checksum
    checksum = lines[-3:-1]
    lines = lines[0:-3]
    # break if end of record
    if( lines[7:9] == "01"):
        break
    # update high address of linear record
    elif( lines[7:9] == "04"):
        hi_addr = int('0x'+lines[9:13],16)
    # record data
    elif( lines[7:9] == "00" ):
        # delete ':'
        lines = lines[1:]
        # find lenght
        lenght = int('0x'+lines[0:2],16)
        lines = lines[2:]
        # find addr
        lo_addr = int('0x'+lines[0:4],16)
        lines = lines[4:]
        # find type
        type_ = lines[0:2]
        lines = lines[2:]
        i = 0
        # write addr
        st_addr = str("@{:s}\n".format( hex( ( ( hi_addr << 16 ) + lo_addr ) >> 2 )[2:] ))
        out_file_0.write(st_addr)
        out_file_1.write(st_addr)
        out_file_2.write(st_addr)
        out_file_3.write(st_addr)
        while(1):
            # write data
            out_file_0.write(lines[0:2] + "\n")
            out_file_1.write(lines[2:4] + "\n")
            out_file_2.write(lines[4:6] + "\n")
            out_file_3.write(lines[6:8] + "\n")
            lines = lines[8:]
            i += 4
            if( i >= lenght ):
                break

print("Conversion comlete!")
