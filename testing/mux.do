vlib work

vlog cpu.v

#load simulation using mux as the top level simulation module
vsim MUX_2_to_1_SE

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, check sign extension
force {reset} 1 0 ms, 0 10 ms
force {a} 1111 0 ms
force {b} 01111 0 ms
force {sel} 0 0 ms, 1 20 ms

run 100 ms