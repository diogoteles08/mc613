onerror {exit -code 1}
vlib work
vcom -work work lab3.vho
vcom -work work sim_mux16_to_1.vwf.vht
vsim -novopt -c -t 1ps -L cyclonev -L altera -L altera_mf -L 220model -L sgate -L altera_lnsim work.mux16_to_1_vhd_vec_tst
vcd file -direction lab3.msim.vcd
vcd add -internal mux16_to_1_vhd_vec_tst/*
vcd add -internal mux16_to_1_vhd_vec_tst/i1/*
proc simTimestamp {} {
    echo "Simulation time: $::now ps"
    if { [string equal running [runStatus]] } {
        after 2500 simTimestamp
    }
}
after 2500 simTimestamp
run -all
quit -f
