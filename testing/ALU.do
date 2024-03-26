vlib work

vlog code/cpu.v

#load simulation using mux as the top level simulation module
vsim ALU

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, check 2 + 3
force {reset} 1 0 ns, 0 10 ns
force {op} 10 0 ns
force {in_a} 10 0 ns
force {in_b} 11 0 ns

run 100 ns