# set the working dir, where all compiled verilog goes

vlib work

vlog cpu.v memory.v

#load simulation using mux as the top level simulation module
vsim cpu

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, play middle c (c4), square
force {reset} 1 0 ms, 0 10 ms
run 100 ms