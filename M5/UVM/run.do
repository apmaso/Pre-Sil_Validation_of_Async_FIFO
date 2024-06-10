if [file exists "work"] {vdel -all}
vlib work

# Compile the DUT, include linting check and...
# TODO: Check what acc does
vlog -lint dut/fifo_top.sv 
vlog -lint dut/fifo_memory.sv 
vlog -lint dut/read_pointer.sv 
vlog -lint dut/write_pointer.sv 
vlog -lint dut/sync.sv
 
vlog -f tb.f
vopt top -o top_optimized  +acc +cover=sbfec+fifo_top(rtl).
#vopt top -o top_optimized  +acc 
vsim top_optimized -coverage +UVM_TESTNAME=burst_test
vsim top_optimized -coverage +UVM_TESTNAME=flag_test
#vsim top_optimized -coverage +UVM_TESTNAME=random_test

set NoQuitOnFinish 1
onbreak {resume}
log /* -r
run -all

coverage save async_fifo.ucdb
vcover report async_fifo.ucdb
vcover report async_fifo.ucdb -cvg -details

#quit 
