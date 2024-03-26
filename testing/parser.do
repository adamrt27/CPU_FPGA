vlib work

vlog code/parser.v

#load simulation using mux as the top level simulation module
vsim parser

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ms, 1 {5ms} -r 10 ms

# TestCases: reset, check parsing of an ADDI command
force {reset} 1 0 ms, 0 10 ms
force {opcode} 16'b0010011111100011 0 ms

run 100 ms