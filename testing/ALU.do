vlib work

vlog cpu.v

#load simulation using mux as the top level simulation module
vsim ALU

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, check 2 + 3
force {reset} 1 0 ms, 0 10 ms
force {op} 1 0 ms
force {in_a} 2 0 ms
force {in_b} 3 0 ms

run 100 ms