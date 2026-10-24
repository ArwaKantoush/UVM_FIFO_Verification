vlib work
vlog -f src_tb.list
vlog +cover=bcesft -f src_dut.list
vsim -voptargs=+acc -coverage work.top -classdebug -uvmcontrol=all -assertdebug
add wave /top/FIFOif/*
run -all
coverage save FIFO_cov.ucdb
vcover report FIFO_cov.ucdb -details -annotate -all -output coverage_rpt.txt
