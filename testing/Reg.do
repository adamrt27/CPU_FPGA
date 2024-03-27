vlib work

vlog code/Reg.v

#load simulation using mux as the top level simulation module
vsim Reg

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ms, 1 {5ms} -r 10 ms

# TestCases: reset, play middle c (c4), square
force {reset} 1 0 ms, 0 10 ms
force {EN} 0 0 ms, 1 10 ms, 0 20 ms
force {in} 10'd50 0 ms, 10'd100 20 ms

run 100 ms