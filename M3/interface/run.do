if [file exists "work"] {vdel -all}
vlib work


# SystemVerilog DUT
vlog -lint fifo_top.sv +acc -sv
vlog -lint fifo_memory.sv +acc -sv
vlog -lint read_pointer.sv +acc -sv
vlog -lint write_pointer.sv +acc -sv
vlog -lint sync.sv +acc -sv
vlog -lint fifo_tb.sv +acc -sv
vlog -lint interface.sv +acc -sv

vopt top -o top_optimized  +acc +cover=sbfec+fifo_top(rtl).
vsim top_optimized -coverage
set NoQuitOnFinish 1
onbreak {resume}
log /* -r

#adding waves
#add wave -position insertpoint sim:/top/*
#add wave -position insertpoint sim:/top/memory
#add wave -position insertpoint sim:/top/dut/*
#add wave -position insertpoint sim:/top/dut/mem_inst/mem
#add wave -position insertpoint sim:/top/bfm_ext/*

run -all

coverage save async_fifo.ucdb
vcover report async_fifo.ucdb
vcover report async_fifo.ucdb -cvg -details

#quit
