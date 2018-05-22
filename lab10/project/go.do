# brief : vsim scripts
# authors: ciroceissler

set library_file_list {
  Processor Processor/ALU.vhd
  Processor Processor/bank.vhd
  Processor Processor/CPU.vhd
  Processor Processor/memory.vhd
  Processor Processor/mux_0.vhd
  Processor Processor/mux2.vhd
  Processor Processor/pack.vhd
  Processor Processor/PC.vhd
  Processor Processor/reg.vhd
  Processor Processor/UC.vhd
  Processor Processor/testbench.vhd
}

set top_level Processor.testbench

# vcom -93 -explicit -reportprogress 300 -work altera {/run/media/ciro.ceissler/d5b27d24-8e5a-4002-8645-05f0f26c7f2d/work/quartus_lite/quartus/libraries/vhdl/altera/maxplus2.vhd}

vlib Processor
foreach {library file} $library_file_list {
  vcom -work $library -2008 $file
}

# load the simulation
eval vsim $top_level

# run the simulation
# run -all
