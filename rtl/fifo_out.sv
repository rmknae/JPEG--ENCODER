
// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This testbench verifies the functionality of the `fifo_out` module,
//    which combines Y, Cb, and Cr data from the pre_fifo module into a single
//    JPEG bitstream using three FIFOs. The testbench generates a clock, applies
//    reset, and feeds various test patterns into the 24-bit data input, simulating
//    Y, Cb, and Cr components. After waiting for the `data_ready` signal, it prints
//    the input data, the generated JPEG bitstream, and output signals such as `orc_reg`
//    for verification.
//
// Author: Navaal Noshi
// Date: 29th July, 2025

`timescale 1ns / 100ps

module fifo_out(
    input  logic        clk, rst, enable,
    input  logic [23:0] data_in,
    output logic [31:0] JPEG_bitstream,
    output logic        data_ready,
    output logic [4:0]  orc_reg
);

    logic [31:0]  cb_JPEG_bitstream, cr_JPEG_bitstream, y_JPEG_bitstream;
    logic [4:0]   cr_orc, cb_orc, y_orc;
    logic [31:0]  y_bits_out;
    logic         y_out_enable;
    logic         cb_data_ready, cr_data_ready, y_data_ready;
    logic         end_of_block_output, y_eob_empty; 
    logic         cb_eob_empty, cr_eob_empty;
    logic         y_fifo_empty;

    logic [4:0]   orc, orc_cb, orc_cr, old_orc_reg, sorc_reg, roll_orc_reg;
    logic [4:0]   orc_1, orc_2, orc_3, orc_4, orc_5, orc_reg_delay;
    logic [4:0]   static_orc_1, static_orc_2, static_orc_3, static_orc_4, static_orc_5;
    logic [4:0]   static_orc_6;
    logic [4:0]   edge_ro_1, edge_ro_2, edge_ro_3, edge_ro_4, edge_ro_5;

    logic [31:0]  jpeg_ro_1, jpeg_ro_2, jpeg_ro_3, jpeg_ro_4, jpeg_ro_5, jpeg_delay;
    logic [31:0]  jpeg, jpeg_1, jpeg_2, jpeg_3, jpeg_4, jpeg_5, jpeg_6;

    logic [4:0]   cr_orc_1, cb_orc_1, y_orc_1;
    logic         cr_out_enable_1, cb_out_enable_1, y_out_enable_1, eob_1;
    logic         eob_2, eob_3, eob_4;

    logic         enable_1, enable_2, enable_3, enable_4, enable_5;
    logic         enable_6, enable_7, enable_8, enable_9, enable_10;
    logic         enable_11, enable_12, enable_13, enable_14, enable_15;
    logic         enable_16, enable_17, enable_18, enable_19, enable_20;
    logic         enable_21, enable_22, enable_23, enable_24, enable_25;
    logic         enable_26, enable_27, enable_28, enable_29, enable_30;
    logic         enable_31, enable_32, enable_33, enable_34, enable_35;

    logic [2:0]   bits_mux, old_orc_mux, read_mux;
    logic         bits_ready, br_1, br_2, br_3, br_4, br_5, br_6, br_7, br_8;
    logic         rollover, rollover_1, rollover_2, rollover_3, rollover_eob;
    logic         rollover_4, rollover_5, rollover_6, rollover_7;
    logic         eobe_1, cb_read_req, cr_read_req, y_read_req;
    logic         eob_early_out_enable, fifo_mux;

    logic [31:0]  cr_bits_out1, cr_bits_out2, cb_bits_out1, cb_bits_out2;
    logic         cr_fifo_empty1, cr_fifo_empty2, cb_fifo_empty1, cb_fifo_empty2;
    logic         cr_out_enable1, cr_out_enable2, cb_out_enable1, cb_out_enable2;


// --------------------
// Signal Declarations
// --------------------
logic cb_write_enable;
logic cr_write_enable;
logic y_write_enable;

logic cr_read_req1;
logic cr_read_req2;
logic [31:0] cr_JPEG_bitstream1;
logic [31:0] cr_JPEG_bitstream2;
logic cr_write_enable1;
logic cr_write_enable2;
logic [31:0] cr_bits_out;
logic cr_fifo_empty;
logic cr_out_enable;

logic cb_read_req1;
logic cb_read_req2;
logic [31:0] cb_JPEG_bitstream1;
logic [31:0] cb_JPEG_bitstream2;
logic cb_write_enable1;
logic cb_write_enable2;
logic [31:0] cb_bits_out;
logic cb_fifo_empty;
logic cb_out_enable;

// --------------------
// Assign Statements
// --------------------
assign cb_write_enable  = cb_data_ready && !cb_eob_empty;
assign cr_write_enable  = cr_data_ready && !cr_eob_empty;
assign y_write_enable   = y_data_ready  && !y_eob_empty;

assign cr_read_req1     = fifo_mux ? 0 : cr_read_req;
assign cr_read_req2     = fifo_mux ? cr_read_req : 0;
assign cr_JPEG_bitstream1 = fifo_mux ? cr_JPEG_bitstream : 0;
assign cr_JPEG_bitstream2 = fifo_mux ? 0 : cr_JPEG_bitstream;
assign cr_write_enable1 = fifo_mux && cr_write_enable;
assign cr_write_enable2 = !fifo_mux && cr_write_enable;
assign cr_bits_out      = fifo_mux ? cr_bits_out2 : cr_bits_out1;
assign cr_fifo_empty    = fifo_mux ? cr_fifo_empty2 : cr_fifo_empty1;
assign cr_out_enable    = fifo_mux ? cr_out_enable2 : cr_out_enable1;

assign cb_read_req1     = fifo_mux ? 0 : cb_read_req;
assign cb_read_req2     = fifo_mux ? cb_read_req : 0;
assign cb_JPEG_bitstream1 = fifo_mux ? cb_JPEG_bitstream : 0;
assign cb_JPEG_bitstream2 = fifo_mux ? 0 : cb_JPEG_bitstream;
assign cb_write_enable1 = fifo_mux && cb_write_enable;
assign cb_write_enable2 = !fifo_mux && cb_write_enable;
assign cb_bits_out      = fifo_mux ? cb_bits_out2 : cb_bits_out1;
assign cb_fifo_empty    = fifo_mux ? cb_fifo_empty2 : cb_fifo_empty1;
assign cb_out_enable    = fifo_mux ? cb_out_enable2 : cb_out_enable1;


 	pre_fifo u14(.clk(clk), .rst(rst), .enable(enable), .data_in(data_in),
	.cr_JPEG_bitstream(cr_JPEG_bitstream), .cr_data_ready(cr_data_ready), 
	.cr_orc(cr_orc), .cb_JPEG_bitstream(cb_JPEG_bitstream), 
	.cb_data_ready(cb_data_ready), .cb_orc(cb_orc), 
	.y_JPEG_bitstream(y_JPEG_bitstream), 
	.y_data_ready(y_data_ready), .y_orc(y_orc), 
	.y_eob_output(end_of_block_output), .y_eob_empty(y_eob_empty), 
	.cb_eob_empty(cb_eob_empty), .cr_eob_empty(cr_eob_empty));

	sync_fifo_32 u15(.clk(clk), .rst(rst), .read_req(cb_read_req1), 
		.write_data(cb_JPEG_bitstream1), .write_enable(cb_write_enable1), 
		.read_data(cb_bits_out1), 
		.fifo_empty(cb_fifo_empty1), .rdata_valid(cb_out_enable1));
	
	sync_fifo_32 u25(.clk(clk), .rst(rst), .read_req(cb_read_req2), 
		.write_data(cb_JPEG_bitstream2), .write_enable(cb_write_enable2), 
		.read_data(cb_bits_out2), 
		.fifo_empty(cb_fifo_empty2), .rdata_valid(cb_out_enable2));	
		
	sync_fifo_32 u16(.clk(clk), .rst(rst), .read_req(cr_read_req1), 
		.write_data(cr_JPEG_bitstream1), .write_enable(cr_write_enable1), 
		.read_data(cr_bits_out1), 
		.fifo_empty(cr_fifo_empty1), .rdata_valid(cr_out_enable1));
	
	sync_fifo_32 u24(.clk(clk), .rst(rst), .read_req(cr_read_req2), 
		.write_data(cr_JPEG_bitstream2), .write_enable(cr_write_enable2), 
		.read_data(cr_bits_out2), 
		.fifo_empty(cr_fifo_empty2), .rdata_valid(cr_out_enable2));		
	
	sync_fifo_32 u17(.clk(clk), .rst(rst), .read_req(y_read_req), 
		.write_data(y_JPEG_bitstream), .write_enable(y_write_enable), 
		.read_data(y_bits_out), 
		.fifo_empty(y_fifo_empty), .rdata_valid(y_out_enable));			

	always_ff @(posedge clk)
	begin
		if (rst) 
			fifo_mux <= 0;
		else if (end_of_block_output)
			fifo_mux <= fifo_mux + 1;
	end
	
always_ff @(posedge clk)
begin
	if (y_fifo_empty || read_mux != 3'b001)
		y_read_req <= 0; 
	else if (!y_fifo_empty && read_mux == 3'b001)
		y_read_req <= 1;
end	 

always_ff @(posedge clk)
begin
	if (cb_fifo_empty || read_mux != 3'b010)
		cb_read_req <= 0; 
	else if (!cb_fifo_empty && read_mux == 3'b010)
		cb_read_req <= 1;
end	
		
always_ff @(posedge clk)
begin
	if (cr_fifo_empty || read_mux != 3'b100)
		cr_read_req <= 0; 
	else if (!cr_fifo_empty && read_mux == 3'b100)
		cr_read_req <= 1;
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		br_1 <= 0; br_2 <= 0; br_3 <= 0; br_4 <= 0; br_5 <= 0; br_6 <= 0;
		br_7 <= 0; br_8 <= 0;
		static_orc_1 <= 0; static_orc_2 <= 0; static_orc_3 <= 0; 
		static_orc_4 <= 0; static_orc_5 <= 0; static_orc_6 <= 0;
		data_ready <= 0; eobe_1 <= 0;  
		end
	else begin 
		br_1 <= bits_ready & !eobe_1; br_2 <= br_1; br_3 <= br_2;
		br_4 <= br_3; br_5 <= br_4; br_6 <= br_5;
		br_7 <= br_6; br_8 <= br_7;
		static_orc_1 <= sorc_reg; static_orc_2 <= static_orc_1; 
		static_orc_3 <= static_orc_2; static_orc_4 <= static_orc_3; 
		static_orc_5 <= static_orc_4; static_orc_6 <= static_orc_5;
		data_ready <= br_6 & rollover_5;
		eobe_1 <= y_eob_empty;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) 
		rollover_eob <= 0; 
	else if (br_3)
		rollover_eob <= old_orc_reg >= roll_orc_reg;
end

always_ff @(posedge clk)
begin
	if (rst) begin
		rollover_1 <= 0; rollover_2 <= 0; rollover_3 <= 0; 
		rollover_4 <= 0; rollover_5 <= 0; rollover_6 <= 0; 
		rollover_7 <= 0; eob_1 <= 0; eob_2 <= 0;
		eob_3 <= 0; eob_4 <= 0;
		eob_early_out_enable <= 0; 
	end
	else begin 
		rollover_1 <= rollover; rollover_2 <= rollover_1; 
		rollover_3 <= rollover_2;
		rollover_4 <= rollover_3 | rollover_eob; 
		rollover_5 <= rollover_4; rollover_6 <= rollover_5; 
		rollover_7 <= rollover_6; eob_1 <= end_of_block_output; 
		eob_2 <= eob_1; eob_3 <= eob_2; eob_4 <= eob_3;	
		eob_early_out_enable <= y_out_enable & y_out_enable_1 & eob_2; 
	end
end

always_ff @(posedge clk)
begin
	case (bits_mux)
	3'b001:		rollover <= y_out_enable_1 & !eob_4 & !eob_early_out_enable;
	3'b010:		rollover <= cb_out_enable_1 & cb_out_enable;
	3'b100:		rollover <= cr_out_enable_1 & cr_out_enable;
	default:	rollover <= y_out_enable_1 & !eob_4;
	endcase
end	

always_ff @(posedge clk)
begin
	if (rst) 
		orc <= 0; 
	else if (enable_20)
		orc <= orc_cr + cr_orc_1;
end	

always_ff @(posedge clk)
begin
	if (rst) 
		orc_cb <= 0; 
	else if (eob_1)
		orc_cb <= orc + y_orc_1; 
end

always_ff @(posedge clk)
begin
	if (rst) 
		orc_cr <= 0; 
	else if (enable_5)
		orc_cr <= orc_cb + cb_orc_1; 
end

always_ff @(posedge clk)
begin
	if (rst) begin
		cr_out_enable_1 <= 0; cb_out_enable_1 <= 0; y_out_enable_1 <= 0; 
		end
	else begin 
		cr_out_enable_1 <= cr_out_enable;
		cb_out_enable_1 <= cb_out_enable;
		y_out_enable_1 <= y_out_enable;
		end
end	

always_ff @(posedge clk)
begin
	case (bits_mux)
	3'b001:		jpeg <= y_bits_out;
	3'b010:		jpeg <= cb_bits_out;
	3'b100:		jpeg <= cr_bits_out;
	default:	jpeg <= y_bits_out;
	endcase
end

always_ff @(posedge clk)
begin
	case (bits_mux)
	3'b001:		bits_ready <= y_out_enable;
	3'b010:		bits_ready <= cb_out_enable;
	3'b100:		bits_ready <= cr_out_enable;
	default:	bits_ready <= y_out_enable;
	endcase
end

always_ff @(posedge clk)
begin
	case (bits_mux)
	3'b001:		sorc_reg <= orc;
	3'b010:		sorc_reg <= orc_cb;
	3'b100:		sorc_reg <= orc_cr;
	default:	sorc_reg <= orc;
	endcase
end

always_ff @(posedge clk)
begin
	case (old_orc_mux)
	3'b001:		roll_orc_reg <= orc;
	3'b010:		roll_orc_reg <= orc_cb;
	3'b100:		roll_orc_reg <= orc_cr;
	default:	roll_orc_reg <= orc;
	endcase
end

always_ff @(posedge clk)
begin
	case (bits_mux)
	3'b001:		orc_reg <= orc;
	3'b010:		orc_reg <= orc_cb;
	3'b100:		orc_reg <= orc_cr;
	default:	orc_reg <= orc;
	endcase
end

always_ff @(posedge clk)
begin
	case (old_orc_mux)
	3'b001:		old_orc_reg <= orc_cr;
	3'b010:		old_orc_reg <= orc;
	3'b100:		old_orc_reg <= orc_cb;
	default:	old_orc_reg <= orc_cr;
	endcase
end

always_ff @(posedge clk)
begin
	if (rst)
		bits_mux <= 3'b001; // Y
	else if (enable_3)
		bits_mux <= 3'b010; // Cb
	else if (enable_19)
		bits_mux <= 3'b100; // Cr
	else if (enable_35)
		bits_mux <= 3'b001; // Y
end	

always_ff @(posedge clk)
begin
	if (rst)
		old_orc_mux <= 3'b001; // Y
	else if (enable_1)
		old_orc_mux <= 3'b010; // Cb
	else if (enable_6)
		old_orc_mux <= 3'b100; // Cr
	else if (enable_22)
		old_orc_mux <= 3'b001; // Y
end

always_ff @(posedge clk)
begin
	if (rst)
		read_mux <= 3'b001; // Y
	else if (enable_1)
		read_mux <= 3'b010; // Cb
	else if (enable_17)
		read_mux <= 3'b100; // Cr
	else if (enable_33)
		read_mux <= 3'b001; // Y
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		cr_orc_1 <= 0; cb_orc_1 <= 0; y_orc_1 <= 0;
		end
	else if (end_of_block_output) begin 
		cr_orc_1 <= cr_orc;
		cb_orc_1 <= cb_orc;
		y_orc_1 <= y_orc;
		end
end	


always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_ro_5 <= 0; edge_ro_5 <= 0;
		end
	else if (br_5) begin 
		jpeg_ro_5 <= (edge_ro_4 <= 1) ? jpeg_ro_4 << 1 : jpeg_ro_4; 
		edge_ro_5 <= (edge_ro_4 <= 1) ? edge_ro_4 : edge_ro_4 - 1;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_5 <= 0; orc_5 <= 0; jpeg_ro_4 <= 0; edge_ro_4 <= 0;
		end
	else if (br_4) begin 
		jpeg_5 <= (orc_4 >= 1) ? jpeg_4 >> 1 : jpeg_4;
		orc_5 <= (orc_4 >= 1) ? orc_4 - 1 : orc_4;
		jpeg_ro_4 <= (edge_ro_3 <= 2) ? jpeg_ro_3 << 2 : jpeg_ro_3; 
		edge_ro_4 <= (edge_ro_3 <= 2) ? edge_ro_3 : edge_ro_3 - 2;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_4 <= 0; orc_4 <= 0; jpeg_ro_3 <= 0; edge_ro_3 <= 0;
		end
	else if (br_3) begin 
		jpeg_4 <= (orc_3 >= 2) ? jpeg_3 >> 2 : jpeg_3;
		orc_4 <= (orc_3 >= 2) ? orc_3 - 2 : orc_3;
		jpeg_ro_3 <= (edge_ro_2 <= 4) ? jpeg_ro_2 << 4 : jpeg_ro_2; 
		edge_ro_3 <= (edge_ro_2 <= 4) ? edge_ro_2 : edge_ro_2 - 4;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_3 <= 0; orc_3 <= 0; jpeg_ro_2 <= 0; edge_ro_2 <= 0;
		end
	else if (br_2) begin 
		jpeg_3 <= (orc_2 >= 4) ? jpeg_2 >> 4 : jpeg_2;
		orc_3 <= (orc_2 >= 4) ? orc_2 - 4 : orc_2;
		jpeg_ro_2 <= (edge_ro_1 <= 8) ? jpeg_ro_1 << 8 : jpeg_ro_1; 
		edge_ro_2 <= (edge_ro_1 <= 8) ? edge_ro_1 : edge_ro_1 - 8;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_2 <= 0; orc_2 <= 0; jpeg_ro_1 <= 0; edge_ro_1 <= 0;
		end
	else if (br_1) begin 
		jpeg_2 <= (orc_1 >= 8) ? jpeg_1 >> 8 : jpeg_1;
		orc_2 <= (orc_1 >= 8) ? orc_1 - 8 : orc_1;
		jpeg_ro_1 <= (orc_reg_delay <= 16) ? jpeg_delay << 16 : jpeg_delay; 
		edge_ro_1 <= (orc_reg_delay <= 16) ? orc_reg_delay : orc_reg_delay - 16;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_1 <= 0; orc_1 <= 0; jpeg_delay <= 0; orc_reg_delay <= 0;
		end
	else if (bits_ready) begin 
		jpeg_1 <= (orc_reg >= 16) ? jpeg >> 16 : jpeg;
		orc_1 <= (orc_reg >= 16) ? orc_reg - 16 : orc_reg;
		jpeg_delay <= jpeg;
		orc_reg_delay <= orc_reg;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		enable_1 <= 0; enable_2 <= 0; enable_3 <= 0; enable_4 <= 0; enable_5 <= 0;
		enable_6 <= 0; enable_7 <= 0; enable_8 <= 0; enable_9 <= 0; enable_10 <= 0;
		enable_11 <= 0; enable_12 <= 0; enable_13 <= 0; enable_14 <= 0; enable_15 <= 0;
		enable_16 <= 0; enable_17 <= 0; enable_18 <= 0; enable_19 <= 0; enable_20 <= 0;
		enable_21 <= 0; enable_22 <= 0; enable_23 <= 0; enable_24 <= 0; enable_25 <= 0;
		enable_26 <= 0; enable_27 <= 0; enable_28 <= 0; enable_29 <= 0; enable_30 <= 0;
		enable_31 <= 0; enable_32 <= 0; enable_33 <= 0; enable_34 <= 0; enable_35 <= 0;
		end
	else begin 
		enable_1 <= end_of_block_output; enable_2 <= enable_1; 
		enable_3 <= enable_2; enable_4 <= enable_3; enable_5 <= enable_4;
		enable_6 <= enable_5; enable_7 <= enable_6; enable_8 <= enable_7; 
		enable_9 <= enable_8; enable_10 <= enable_9; enable_11 <= enable_10; 
		enable_12 <= enable_11; enable_13 <= enable_12; enable_14 <= enable_13; 
		enable_15 <= enable_14; enable_16 <= enable_15; enable_17 <= enable_16; 
		enable_18 <= enable_17; enable_19 <= enable_18; enable_20 <= enable_19;
		enable_21 <= enable_20; 
		enable_22 <= enable_21; enable_23 <= enable_22; enable_24 <= enable_23; 
		enable_25 <= enable_24; enable_26 <= enable_25; enable_27 <= enable_26; 
		enable_28 <= enable_27; enable_29 <= enable_28; enable_30 <= enable_29;
		enable_31 <= enable_30; 
		enable_32 <= enable_31; enable_33 <= enable_32; enable_34 <= enable_33; 
		enable_35 <= enable_34;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[31] <= 0;
	else if (br_7 & rollover_6) 
		JPEG_bitstream[31] <= jpeg_6[31];
	else if (br_6 && static_orc_6 == 0) 
		JPEG_bitstream[31] <= jpeg_6[31];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[30] <= 0;
	else if (br_7 & rollover_6) 
		JPEG_bitstream[30] <= jpeg_6[30];
	else if (br_6 && static_orc_6 <= 1) 
		JPEG_bitstream[30] <= jpeg_6[30];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[29] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[29] <= jpeg_6[29];
	else if (br_6 && static_orc_6 <= 2) 
		JPEG_bitstream[29] <= jpeg_6[29];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[28] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[28] <= jpeg_6[28];
	else if (br_6 && static_orc_6 <= 3) 
		JPEG_bitstream[28] <= jpeg_6[28];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[27] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[27] <= jpeg_6[27];
	else if (br_6 && static_orc_6 <= 4) 
		JPEG_bitstream[27] <= jpeg_6[27];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[26] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[26] <= jpeg_6[26];
	else if (br_6 && static_orc_6 <= 5) 
		JPEG_bitstream[26] <= jpeg_6[26];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[25] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[25] <= jpeg_6[25];
	else if (br_6 && static_orc_6 <= 6) 
		JPEG_bitstream[25] <= jpeg_6[25];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[24] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[24] <= jpeg_6[24];
	else if (br_6 && static_orc_6 <= 7) 
		JPEG_bitstream[24] <= jpeg_6[24];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[23] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[23] <= jpeg_6[23];
	else if (br_6 && static_orc_6 <= 8) 
		JPEG_bitstream[23] <= jpeg_6[23];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[22] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[22] <= jpeg_6[22];
	else if (br_6 && static_orc_6 <= 9) 
		JPEG_bitstream[22] <= jpeg_6[22];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[21] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[21] <= jpeg_6[21];
	else if (br_6 && static_orc_6 <= 10) 
		JPEG_bitstream[21] <= jpeg_6[21];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[20] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[20] <= jpeg_6[20];
	else if (br_6 && static_orc_6 <= 11) 
		JPEG_bitstream[20] <= jpeg_6[20];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[19] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[19] <= jpeg_6[19];
	else if (br_6 && static_orc_6 <= 12) 
		JPEG_bitstream[19] <= jpeg_6[19];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[18] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[18] <= jpeg_6[18];
	else if (br_6 && static_orc_6 <= 13) 
		JPEG_bitstream[18] <= jpeg_6[18];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[17] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[17] <= jpeg_6[17];
	else if (br_6 && static_orc_6 <= 14) 
		JPEG_bitstream[17] <= jpeg_6[17];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[16] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[16] <= jpeg_6[16];
	else if (br_6 && static_orc_6 <= 15) 
		JPEG_bitstream[16] <= jpeg_6[16];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[15] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[15] <= jpeg_6[15];
	else if (br_6 && static_orc_6 <= 16) 
		JPEG_bitstream[15] <= jpeg_6[15];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[14] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[14] <= jpeg_6[14];
	else if (br_6 && static_orc_6 <= 17) 
		JPEG_bitstream[14] <= jpeg_6[14];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[13] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[13] <= jpeg_6[13];
	else if (br_6 && static_orc_6 <= 18) 
		JPEG_bitstream[13] <= jpeg_6[13];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[12] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[12] <= jpeg_6[12];
	else if (br_6 && static_orc_6 <= 19) 
		JPEG_bitstream[12] <= jpeg_6[12];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[11] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[11] <= jpeg_6[11];
	else if (br_6 && static_orc_6 <= 20) 
		JPEG_bitstream[11] <= jpeg_6[11];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[10] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[10] <= jpeg_6[10];
	else if (br_6 && static_orc_6 <= 21) 
		JPEG_bitstream[10] <= jpeg_6[10];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[9] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[9] <= jpeg_6[9];
	else if (br_6 && static_orc_6 <= 22) 
		JPEG_bitstream[9] <= jpeg_6[9];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[8] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[8] <= jpeg_6[8];
	else if (br_6 && static_orc_6 <= 23) 
		JPEG_bitstream[8] <= jpeg_6[8];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[7] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[7] <= jpeg_6[7];
	else if (br_6 && static_orc_6 <= 24) 
		JPEG_bitstream[7] <= jpeg_6[7];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[6] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[6] <= jpeg_6[6];
	else if (br_6 && static_orc_6 <= 25) 
		JPEG_bitstream[6] <= jpeg_6[6];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[5] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[5] <= jpeg_6[5];
	else if (br_6 && static_orc_6 <= 26) 
		JPEG_bitstream[5] <= jpeg_6[5];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[4] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[4] <= jpeg_6[4];
	else if (br_6 && static_orc_6 <= 27) 
		JPEG_bitstream[4] <= jpeg_6[4];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[3] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[3] <= jpeg_6[3];
	else if (br_6 && static_orc_6 <= 28) 
		JPEG_bitstream[3] <= jpeg_6[3];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[2] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[2] <= jpeg_6[2];
	else if (br_6 && static_orc_6 <= 29) 
		JPEG_bitstream[2] <= jpeg_6[2];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[1] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[1] <= jpeg_6[1];
	else if (br_6 && static_orc_6 <= 30) 
		JPEG_bitstream[1] <= jpeg_6[1];
end

always_ff @(posedge clk)
begin
	if (rst) 
		JPEG_bitstream[0] <= 0;
	else if (br_7 & rollover_6)
		JPEG_bitstream[0] <= jpeg_6[0];
	else if (br_6 && static_orc_6 <= 31) 
		JPEG_bitstream[0] <= jpeg_6[0];
end

always_ff @(posedge clk)
begin
	if (rst) begin
		jpeg_6 <= 0; 
		end
	else if (br_5 | br_6) begin 
		jpeg_6[31] <= (rollover_5 & static_orc_5 > 0) ? jpeg_ro_5[31] : jpeg_5[31];
		jpeg_6[30] <= (rollover_5 & static_orc_5 > 1) ? jpeg_ro_5[30] : jpeg_5[30];
		jpeg_6[29] <= (rollover_5 & static_orc_5 > 2) ? jpeg_ro_5[29] : jpeg_5[29];
		jpeg_6[28] <= (rollover_5 & static_orc_5 > 3) ? jpeg_ro_5[28] : jpeg_5[28];
		jpeg_6[27] <= (rollover_5 & static_orc_5 > 4) ? jpeg_ro_5[27] : jpeg_5[27];
		jpeg_6[26] <= (rollover_5 & static_orc_5 > 5) ? jpeg_ro_5[26] : jpeg_5[26];
		jpeg_6[25] <= (rollover_5 & static_orc_5 > 6) ? jpeg_ro_5[25] : jpeg_5[25];
		jpeg_6[24] <= (rollover_5 & static_orc_5 > 7) ? jpeg_ro_5[24] : jpeg_5[24];
		jpeg_6[23] <= (rollover_5 & static_orc_5 > 8) ? jpeg_ro_5[23] : jpeg_5[23];
		jpeg_6[22] <= (rollover_5 & static_orc_5 > 9) ? jpeg_ro_5[22] : jpeg_5[22];
		jpeg_6[21] <= (rollover_5 & static_orc_5 > 10) ? jpeg_ro_5[21] : jpeg_5[21];
		jpeg_6[20] <= (rollover_5 & static_orc_5 > 11) ? jpeg_ro_5[20] : jpeg_5[20];
		jpeg_6[19] <= (rollover_5 & static_orc_5 > 12) ? jpeg_ro_5[19] : jpeg_5[19];
		jpeg_6[18] <= (rollover_5 & static_orc_5 > 13) ? jpeg_ro_5[18] : jpeg_5[18];
		jpeg_6[17] <= (rollover_5 & static_orc_5 > 14) ? jpeg_ro_5[17] : jpeg_5[17];
		jpeg_6[16] <= (rollover_5 & static_orc_5 > 15) ? jpeg_ro_5[16] : jpeg_5[16];
		jpeg_6[15] <= (rollover_5 & static_orc_5 > 16) ? jpeg_ro_5[15] : jpeg_5[15];
		jpeg_6[14] <= (rollover_5 & static_orc_5 > 17) ? jpeg_ro_5[14] : jpeg_5[14];
		jpeg_6[13] <= (rollover_5 & static_orc_5 > 18) ? jpeg_ro_5[13] : jpeg_5[13];
		jpeg_6[12] <= (rollover_5 & static_orc_5 > 19) ? jpeg_ro_5[12] : jpeg_5[12];
		jpeg_6[11] <= (rollover_5 & static_orc_5 > 20) ? jpeg_ro_5[11] : jpeg_5[11];
		jpeg_6[10] <= (rollover_5 & static_orc_5 > 21) ? jpeg_ro_5[10] : jpeg_5[10];
		jpeg_6[9] <= (rollover_5 & static_orc_5 > 22) ? jpeg_ro_5[9] : jpeg_5[9];
		jpeg_6[8] <= (rollover_5 & static_orc_5 > 23) ? jpeg_ro_5[8] : jpeg_5[8];
		jpeg_6[7] <= (rollover_5 & static_orc_5 > 24) ? jpeg_ro_5[7] : jpeg_5[7];
		jpeg_6[6] <= (rollover_5 & static_orc_5 > 25) ? jpeg_ro_5[6] : jpeg_5[6];
		jpeg_6[5] <= (rollover_5 & static_orc_5 > 26) ? jpeg_ro_5[5] : jpeg_5[5];
		jpeg_6[4] <= (rollover_5 & static_orc_5 > 27) ? jpeg_ro_5[4] : jpeg_5[4];
		jpeg_6[3] <= (rollover_5 & static_orc_5 > 28) ? jpeg_ro_5[3] : jpeg_5[3];
		jpeg_6[2] <= (rollover_5 & static_orc_5 > 29) ? jpeg_ro_5[2] : jpeg_5[2];
		jpeg_6[1] <= (rollover_5 & static_orc_5 > 30) ? jpeg_ro_5[1] : jpeg_5[1];
		jpeg_6[0] <= jpeg_5[0];
		end
end	
	
	endmodule
