vlib work

vlog memory.v

#load simulation using mux as the top level simulation module
vsim memory

#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module
add wave {/*}


# set clock
force {CLK} 0 0ns, 1 {5ns} -r 10 ns

# TestCases: reset, read mem[0] (which is preset after reset), write mem[1] = 10 and read mem[1] (== 10)
force {reset} 1 0 ms, 0 10 ms
force {MemRead} 0 0 ms, 1 10 ms, 0 20 ms, 1 30 ms
force {MemWrite} 0 0 ms, 1 20 ms
force {ADDR} 0 0 ms, 1 20 ms
force {DataIn} 0 0 ms, 10 20 ms,

run 100 ms