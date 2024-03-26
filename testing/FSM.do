vlib work

vlog code/FSM.v

#load simulation using mux as the top level simulation module
vsim FSM

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, check FSM for ADDI
force {reset} 1 0 ms, 0 10 ms
force {opcode} 16'b0010011111100111 0 ms

run 100 ms