
vlib work

set test "core test"

set i0 +incdir+../rtl/common
set i1 +incdir+../rtl/core
set i2 +incdir+../rtl/periphery
set i3 +incdir+../rtl/periphery/uart
set i4 +incdir+../rtl/periphery/pwm
set i5 +incdir+../rtl/periphery/gpio
set i6 +incdir+../rtl/ahb
set i7 +incdir+../rtl
set i8 +incdir+../tb

set s0 ../rtl/common/*.*v
set s1 ../rtl/core/*.*v
set s2 ../rtl/periphery/*.*v
set s3 ../rtl/periphery/uart/*.*v
set s4 ../rtl/periphery/pwm/*.*v
set s5 ../rtl/periphery/gpio/*.*v
set s6 ../rtl/ahb/*.*v
set s7 ../rtl/*.*v
set s8 ../tb/*.*v

vlog $i0 $i1 $i2 $i3 $i4 $i5 $i6 $i7 $i8 $s0 $s1 $s2 $s3 $s4 $s5 $s6 $s7 $s8

if {$test == "core test"} {
    vsim -novopt work.nf_tb
    add wave -divider  "pipeline stages"
    add wave -position insertpoint sim:/nf_tb/instruction_if_stage
    add wave -position insertpoint sim:/nf_tb/instruction_id_stage
    add wave -position insertpoint sim:/nf_tb/instruction_iexe_stage
    add wave -position insertpoint sim:/nf_tb/instruction_imem_stage
    add wave -position insertpoint sim:/nf_tb/instruction_iwb_stage
    add wave -divider  "core singals"
    add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/*
#    add wave -divider  "instruction fetch unit singals"
#    add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_i_fu_0/*
#    add wave -divider  "instruction load store unit singals"
#    add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/nf_i_lsu_0/*
#    add wave -divider  "instruction cross connect unit singals"
#    add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_cc_0/*
    add wave -divider  "testbench signals"
    add wave -position insertpoint sim:/nf_tb/*
} elseif {$test == "ahb test"} {
    vsim -novopt work.nf_ahb_tb
    add wave -position insertpoint sim:/nf_ahb_tb/*
} elseif {$test == "uart test"} {
    vsim -novopt work.nf_uart_top_tb
    add wave -position insertpoint sim:/nf_uart_top_tb/*
    add wave -position insertpoint sim:/nf_uart_top_tb/nf_uart_top_0/*
}

run -all

wave zoom full

#quit
