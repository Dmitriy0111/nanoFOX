#
#  File            :   run_rvc_gen.py
#  Autor           :   Vlasov D.V.
#  Data            :   2019.05.26
#  Language        :   Python
#  Description     :   This is script for generating run script for rvc test
#  Copyright(c)    :   2018 - 2019 Vlasov D.V.
#

import sys

print(sys.argv[1])

map_file = open("program_file/"+sys.argv[1]+"/main.map" , "r")

out_file_f = open("run/rvc_run_"+sys.argv[1]+".tcl"  , "w")

out_file_f.write('''vlib work

set i0 +incdir+../rtl/common
set i1 +incdir+../rtl/core
set i2 +incdir+../rtl/periphery
set i3 +incdir+../rtl/periphery/uart
set i4 +incdir+../rtl/periphery/pwm
set i5 +incdir+../rtl/periphery/gpio
set i6 +incdir+../rtl/bus/ahb
set i7 +incdir+../rtl/top
set i8 +incdir+../tb

set s0 ../rtl/common/*.*v
set s1 ../rtl/core/*.*v
set s2 ../rtl/periphery/*.*v
set s3 ../rtl/periphery/uart/*.*v
set s4 ../rtl/periphery/pwm/*.*v
set s5 ../rtl/periphery/gpio/*.*v
set s6 ../rtl/bus/ahb/*.*v
set s7 ../rtl/top/*.*v
set s8 ../tb/*.*v

vlog $i0 $i1 $i2 $i3 $i4 $i5 $i6 $i7 $i8 $s0 $s1 $s2 $s3 $s4 $s5 $s6 $s7 $s8
''')

out_file_f.write(str("vsim -novopt work.nf_tb -gpath2file=../program_file/{:s}/program\n".format(sys.argv[1])))

out_file_f.write('''add wave -divider  "pipeline stages"
add wave -position insertpoint sim:/nf_tb/instruction_if_stage
add wave -position insertpoint sim:/nf_tb/instruction_id_stage
add wave -position insertpoint sim:/nf_tb/instruction_iexe_stage
add wave -position insertpoint sim:/nf_tb/instruction_imem_stage
add wave -position insertpoint sim:/nf_tb/instruction_iwb_stage
add wave -divider  "load store unit"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_i_lsu_0/*
add wave -divider  "core singals"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/*
add wave -divider  "hasard stall & flush singals"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_hz_stall_unit_0/*
add wave -divider  "cc unit singals"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_cc_0/*
add wave -divider  "instruction fetch unit"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_i_fu_0/*
add wave -divider  "csr singals"
add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_csr_0/*
add wave -divider  "testbench signals"
add wave -position insertpoint sim:/nf_tb/*

run -all
''')

start_addr = "0x2030"
end_addr = "0x20e0"

for lines in map_file:
    if(lines.find("begin_signature")!=-1):
        start_addr = lines.replace(" ", "")[0:18]
    if(lines.find("end_signature")!=-1):
        end_addr = lines.replace(" ", "")[0:18]

out_file_f.write(str("mem save -o ../program_file/{:s}/mem.hex -f hex -noaddress -startaddress {:d} -endaddress {:d} /nf_tb/nf_top_0/nf_ram_i_d_0/ram\n".format(sys.argv[1], int(start_addr,16), int(end_addr,16) ) ) )

out_file_f.write('''quit''')
