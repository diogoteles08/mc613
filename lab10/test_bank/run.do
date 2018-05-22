# brief : vsim scripts
# authors: ciroceissler

set library_file_list {
  Processor Processor/pack.vhd
  Processor Processor/reg.vhd
  Processor Processor/bank.vhd
  Processor Processor/zbuffer.vhd
  Processor Processor/dec5_to_32.vhd
  Processor Processor/testbench.vhd
}

set top_level Processor.testbench

vlib Processor
foreach {library file} $library_file_list {
  vcom -work $library -2008 $file
}

# load the simulation
eval vsim $top_level

# run the simulation
run -all
