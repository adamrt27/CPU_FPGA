vlib work

vlog cpu.v

#load simulation using mux as the top level simulation module
vsim Reg

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, play middle c (c4), square
force {reset} 1 0 ms, 0 10 ms
force {EN} 0 0 ms, 1 10 ms, 0 20 ms, 1 30 ms
force {in} 50 0 ms, 100 15 ms

run 100 ms