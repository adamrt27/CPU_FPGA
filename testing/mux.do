vlib work

vlog code/mux.v

#load simulation using mux as the top level simulation module
vsim mux

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all itens in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, check sign extension
force {reset} 1 0 ns, 0 10 ns
force {a} 1111 0 ns
force {b} 11111 0 ns
force {sel} 0 0 ns, 1 20 ns

run 100 ns