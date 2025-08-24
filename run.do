# run.do for JPEG project simulation

# Create or reset work library
vlib work
vmap work work

# Compile all design files (relative to run.do location: rtl/)
vlog -sv rtl/dct_constants.svh
vlog -sv rtl/quantizer_constants.svh
vlog -sv rtl/cb_dct.sv
vlog -sv rtl/cb_huff.sv
vlog -sv rtl/cb_quantizer.sv
vlog -sv rtl/cbd_q_h.sv
vlog -sv rtl/cr_dct.sv
vlog -sv rtl/cr_huff.sv
vlog -sv rtl/cr_quantizer.sv
vlog -sv rtl/crd_q_h.sv
vlog -sv rtl/ff_checker.sv
vlog -sv rtl/fifo_out.sv
vlog -sv rtl/jpeg_top.sv
vlog -sv rtl/pre_fifo.sv
vlog -sv rtl/rgb2ycbcr.sv
vlog -sv rtl/sync_fifo_32.sv
vlog -sv rtl/sync_fifo_ff.sv
vlog -sv rtl/y_dct.sv
vlog -sv rtl/y_huff.sv
vlog -sv rtl/y_quantizer.sv
vlog -sv rtl/yd_q_h.sv
vlog -sv rtl/jpeg_top_TB.sv

# Elaborate and start simulation
vsim -voptargs=+acc work.jpeg_top_tb

# Add all waveforms
add wave -r sim:/jpeg_top_tb/*

# Run simulation until finish
run -all
