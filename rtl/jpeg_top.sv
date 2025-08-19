// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//   This is the top-level module for the JPEG Encoder Core.
//   It connects the `fifo_out` and `ff_checker` submodules to create the final
//   JPEG output stream. It performs the following tasks:
//   1. Receives 24-bit encoded input data from `fifo_out`.
//   2. Passes this data to `ff_checker`, which inserts `0x00` after any `0xFF`
//      in the bitstream (as required by the JPEG format).
//   3. At end-of-file, if the bitstream contains fewer than 32 valid bits,
//      it signals this with `eof_data_partial_ready` and outputs the valid bit
//      count using `end_of_file_bitstream_count`.
//
// Author:Navaal Noshi
// Date:11th July,2025.

`timescale 1ns / 100ps

module jpeg_top(clk, rst, end_of_file_signal, enable, data_in, JPEG_bitstream, 
data_ready, end_of_file_bitstream_count, eof_data_partial_ready);
input		clk;
input		rst;
input		end_of_file_signal;
input		enable;
input	[23:0]	data_in;
output  [31:0]  JPEG_bitstream;
output		data_ready;
output	[4:0] end_of_file_bitstream_count;
output		eof_data_partial_ready;

wire [31:0] JPEG_FF;
wire data_ready_FF;
wire [4:0] orc_reg_in;
 

 fifo_out u19 (.clk(clk), .rst(rst), .enable(enable), .data_in(data_in), 
 .JPEG_bitstream(JPEG_FF), .data_ready(data_ready_FF), .orc_reg(orc_reg_in));
 
 ff_checker u20 (.clk(clk), .rst(rst), 
 .end_of_file_signal(end_of_file_signal), .JPEG_in(JPEG_FF), 
 .data_ready_in(data_ready_FF), .orc_reg_in(orc_reg_in),
 .JPEG_bitstream_1(JPEG_bitstream), 
 .data_ready_1(data_ready), .orc_reg(end_of_file_bitstream_count),
 .eof_data_partial_ready(eof_data_partial_ready));

`ifdef TRACE
initial begin
  $dumpfile ("waveform.vcd");
  $dumpvars (0,jpeg_top);
end
`endif
 
 
 endmodule
