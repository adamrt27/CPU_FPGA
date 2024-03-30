quit -sim
# set the working dir, where all compiled verilog goes

vlib work

vlog code/cpu.v code/memory.v code/parser.v code/ALU.v code/FSM.v code/Reg.v code/RegisterFile.v

#load simulation using mux as the top level simulation module
vsim cpu

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ms, 1 {5ms} -r 10 ms

# TestCases: reset, play middle c (c4), square
force {reset} 1 0 ms, 0 10 ms
run 1200 ms