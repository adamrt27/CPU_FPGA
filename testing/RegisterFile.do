vlib work

vlog code/RegisterFile.v

#load simulation using mux as the top level simulation module
vsim RegisterFile

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ms, 1 {5ms} -r 10 ms

# TestCases: reset, put 10 in r1, put 20 in r2
force {reset} 1 0 ms, 0 10 ms
force {regA} 1 0 ms
force {regB} 0 0 ms
force {regW} 1 0ms, 0 20 ms
force {dataW} 10'd10 0ms, 10'd20 20 ms
force {RFwrite} 0 0 ms, 1 10 ms, 0 20 ms, 1 30 ms

run 100 ms