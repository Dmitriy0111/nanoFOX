#
#  File            :   rvc_test.py
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.24
#  Language        :   Python
#  Description     :   This is script for testing risc-v core with riscv-compliance
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
#

import sys

print(sys.argv[1])

pars_file = open("program_file/"+sys.argv[1]+"/mem.hex" , "r")

reference_file = open("program/riscv-compliance/riscv-test-suite/rv32i/references/"+sys.argv[1]+".reference_output" , "r")

#out_file = open("program_file/refhex.hex", "w") # reference
log_file = open("rvc_log/"+sys.argv[1]+".log", "w") # reference

pars_file.readline()    # delete first three lines
pars_file.readline()    # delete first three lines
pars_file.readline()    # delete first three lines

pars_str = ""       # parsing string
comp_str = ""       # comparing string
sub_comp = ""       # help comparing string
ref_str  = ""

error = 0

for lines in pars_file:
    pars_str = pars_str + lines # loading data in pars string

for lines in reference_file:
    ref_str = ref_str + lines # loading data in pars string

pars_str = pars_str.replace("\n", " ")
i=0
j=0
for i in range(0,len(pars_str)):
    j += 1
    if(j==12):
        j=0
        comp_str = comp_str + sub_comp[6:8] + sub_comp[4:6] + sub_comp[2:4] + sub_comp[0:2] + "\n"
        sub_comp = ""
    elif( not( (j==3) or (j==6) or (j==9) ) ):
        sub_comp = sub_comp + pars_str[i]

j=0
sub_comp = ""
ref_comp = ""
out_str = ""

out_str = str( "| Status  | comp str   | ref str    |\n" )
log_file.write( out_str )
print( out_str )
out_str = str( "| ------- | ---------- | ---------- |\n" )
log_file.write( out_str )
print( out_str )

for i in range(0,len(ref_str)):
    j += 1
    if(j != 9):
        sub_comp += comp_str[i]
        ref_comp += ref_str[i]
    elif(j == 9):
        j=0
        out_str = str("| [{:s}] | 0x{:s} | 0x{:s} |\n".format( ( "Pass " if (sub_comp == ref_comp) else "Error") , sub_comp, ref_comp ) )
        log_file.write( out_str )
        if(sub_comp != ref_comp):
            error += 1
        print( out_str )
        sub_comp = ""
        ref_comp = ""

#out_file.write(comp_str)
log_file.write( str("Comparing test complete with {:d} errors\n".format( error ) ) )
print(str("Comparing test complete with {:d} errors\n".format( error ) ) )
