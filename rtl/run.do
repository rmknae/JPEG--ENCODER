# run.do for JPEG project simulation

# Create or reset work library
vlib work
vmap work work

# Compile all design files
vlog -sv dct_constants.svh
vlog -sv quantizer_constants.svh
vlog -sv cb_dct.sv
vlog -sv cb_huff.sv
vlog -sv cb_quantizer.sv
vlog -sv cbd_q_h.sv
vlog -sv cr_dct.sv
vlog -sv cr_huff.sv
vlog -sv cr_quantizer.sv
vlog -sv crd_q_h.sv
vlog -sv ff_checker.sv
vlog -sv fifo_out.sv
vlog -sv jpeg_top.sv
vlog -sv pre_fifo.sv
vlog -sv rgb2ycbcr.sv
vlog -sv sync_fifo_32.sv
vlog -sv sync_fifo_ff.sv
vlog -sv y_dct.sv
vlog -sv y_huff.sv
vlog -sv y_quantizer.sv
vlog -sv yd_q_h.sv
vlog -sv jpeg_top_TB.sv

# Elaborate and start simulation
vsim -voptargs=+acc work.jpeg_top_tb

# Optional: add waveforms
add wave -r sim:/jpeg_top_tb/*

# Run simulation until finish
run -all
