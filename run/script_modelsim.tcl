
vlib work

set test "ahb test"

set i0 +incdir+../rtl/common
set i1 +incdir+../rtl/core
set i2 +incdir+../rtl/periphery
set i3 +incdir+../rtl/ahb
set i4 +incdir+../rtl
set i5 +incdir+../tb

set s0 ../rtl/common/*.*v
set s1 ../rtl/core/*.*v
set s2 ../rtl/periphery/*.*v
set s3 ../rtl/ahb/*.*v
set s4 ../rtl/*.*v
set s5 ../tb/*.*v

vlog $i0 $i1 $i2 $i3 $i4 $i5 $s0 $s1 $s2 $s3 $s4 $s5

if {$test == "core test"} {
    vsim -novopt work.nf_tb
    add wave -position insertpoint sim:/nf_tb/nf_top_0/nf_cpu_0/*
    add wave -position insertpoint sim:/nf_tb/instruction_id_stage
    add wave -position insertpoint sim:/nf_tb/*
} elseif {$test == "ahb test"} {
    vsim -novopt work.nf_ahb_tb
    add wave -position insertpoint sim:/nf_ahb_tb/*
}

run -all

wave zoom full

#quit
