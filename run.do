vlib work
vlog addr.v ALU.v ALUControl.v control.v DataMem.v ID_Stage.v inst_mem.v Mux_2_1.v program_counter.v Registers.v mips_top.v mips_tb.v
vsim -voptargs=+acc work.mips_tb
add wave -position insertpoint sim:/mips_tb/dut/*
run -all
