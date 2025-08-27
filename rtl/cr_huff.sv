// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This module performs Huffman encoding for Cr (Chroma Red) data. It takes the quantized
//    DCT coefficients for an 8x8 Cr block and generates the corresponding variable-length
//    Huffman codes, suitable for bitstream compression.
//
// Author:Rameen
// Date:16th July,2025.

`timescale 1ns / 100ps
		
module cr_huff(
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [10:0] Cr11, Cr12, Cr13, Cr14, Cr15, Cr16, Cr17, Cr18,
    input  logic [10:0] Cr21, Cr22, Cr23, Cr24, Cr25, Cr26, Cr27, Cr28,
    input  logic [10:0] Cr31, Cr32, Cr33, Cr34, Cr35, Cr36, Cr37, Cr38,
    input  logic [10:0] Cr41, Cr42, Cr43, Cr44, Cr45, Cr46, Cr47, Cr48,
    input  logic [10:0] Cr51, Cr52, Cr53, Cr54, Cr55, Cr56, Cr57, Cr58,
    input  logic [10:0] Cr61, Cr62, Cr63, Cr64, Cr65, Cr66, Cr67, Cr68,
    input  logic [10:0] Cr71, Cr72, Cr73, Cr74, Cr75, Cr76, Cr77, Cr78,
    input  logic [10:0] Cr81, Cr82, Cr83, Cr84, Cr85, Cr86, Cr87, Cr88,
    output logic [31:0] JPEG_bitstream,
    output logic        data_ready,
    output logic [4:0]  output_reg_count,
    output logic        end_of_block_empty
);

    logic [7:0]  block_counter;
    logic [11:0] Cr11_amp, Cr11_1_pos, Cr11_1_neg, Cr11_diff;
    logic [11:0] Cr11_previous, Cr11_1;
    logic [10:0] Cr12_amp, Cr12_pos, Cr12_neg;
    logic [10:0] Cr21_pos, Cr21_neg, Cr31_pos, Cr31_neg, Cr22_pos, Cr22_neg;
    logic [10:0] Cr13_pos, Cr13_neg, Cr14_pos, Cr14_neg, Cr15_pos, Cr15_neg;
    logic [10:0] Cr16_pos, Cr16_neg, Cr17_pos, Cr17_neg, Cr18_pos, Cr18_neg;
    logic [10:0] Cr23_pos, Cr23_neg, Cr24_pos, Cr24_neg, Cr25_pos, Cr25_neg;
    logic [10:0] Cr26_pos, Cr26_neg, Cr27_pos, Cr27_neg, Cr28_pos, Cr28_neg;
    logic [10:0] Cr32_pos, Cr32_neg;
    logic [10:0] Cr33_pos, Cr33_neg, Cr34_pos, Cr34_neg, Cr35_pos, Cr35_neg;
    logic [10:0] Cr36_pos, Cr36_neg, Cr37_pos, Cr37_neg, Cr38_pos, Cr38_neg;
    logic [10:0] Cr41_pos, Cr41_neg, Cr42_pos, Cr42_neg;
    logic [10:0] Cr43_pos, Cr43_neg, Cr44_pos, Cr44_neg, Cr45_pos, Cr45_neg;
    logic [10:0] Cr46_pos, Cr46_neg, Cr47_pos, Cr47_neg, Cr48_pos, Cr48_neg;
    logic [10:0] Cr51_pos, Cr51_neg, Cr52_pos, Cr52_neg;
    logic [10:0] Cr53_pos, Cr53_neg, Cr54_pos, Cr54_neg, Cr55_pos, Cr55_neg;
    logic [10:0] Cr56_pos, Cr56_neg, Cr57_pos, Cr57_neg, Cr58_pos, Cr58_neg;
    logic [10:0] Cr61_pos, Cr61_neg, Cr62_pos, Cr62_neg;
    logic [10:0] Cr63_pos, Cr63_neg, Cr64_pos, Cr64_neg, Cr65_pos, Cr65_neg;
    logic [10:0] Cr66_pos, Cr66_neg, Cr67_pos, Cr67_neg, Cr68_pos, Cr68_neg;
    logic [10:0] Cr71_pos, Cr71_neg, Cr72_pos, Cr72_neg;
    logic [10:0] Cr73_pos, Cr73_neg, Cr74_pos, Cr74_neg, Cr75_pos, Cr75_neg;
    logic [10:0] Cr76_pos, Cr76_neg, Cr77_pos, Cr77_neg, Cr78_pos, Cr78_neg;
    logic [10:0] Cr81_pos, Cr81_neg, Cr82_pos, Cr82_neg;
    logic [10:0] Cr83_pos, Cr83_neg, Cr84_pos, Cr84_neg, Cr85_pos, Cr85_neg;
    logic [10:0] Cr86_pos, Cr86_neg, Cr87_pos, Cr87_neg, Cr88_pos, Cr88_neg;

    logic [3:0] Cr11_bits_pos, Cr11_bits_neg, Cr11_bits, Cr11_bits_1;
    logic [3:0] Cr12_bits_pos, Cr12_bits_neg, Cr12_bits, Cr12_bits_1; 
    logic [3:0] Cr12_bits_2, Cr12_bits_3;

    logic Cr11_msb, Cr12_msb, Cr12_msb_1;
    logic enable_1, enable_2, enable_3, enable_4, enable_5, enable_6;
    logic enable_7, enable_8, enable_9, enable_10, enable_11, enable_12;
    logic enable_13, enable_module, enable_latch_7, enable_latch_8;
    logic Cr12_et_zero, rollover, rollover_1, rollover_2, rollover_3;
    logic rollover_4, rollover_5, rollover_6, rollover_7;
    logic Cr21_et_zero, Cr21_msb, Cr31_et_zero, Cr31_msb;
    logic Cr22_et_zero, Cr22_msb, Cr13_et_zero, Cr13_msb;
    logic Cr14_et_zero, Cr14_msb, Cr15_et_zero, Cr15_msb;
    logic Cr16_et_zero, Cr16_msb, Cr17_et_zero, Cr17_msb;
    logic Cr18_et_zero, Cr18_msb;
    logic Cr23_et_zero, Cr23_msb, Cr24_et_zero, Cr24_msb;
    logic Cr25_et_zero, Cr25_msb, Cr26_et_zero, Cr26_msb;
    logic Cr27_et_zero, Cr27_msb, Cr28_et_zero, Cr28_msb;
    logic Cr32_et_zero, Cr32_msb, Cr33_et_zero, Cr33_msb;
    logic Cr34_et_zero, Cr34_msb, Cr35_et_zero, Cr35_msb;
    logic Cr36_et_zero, Cr36_msb, Cr37_et_zero, Cr37_msb;
    logic Cr38_et_zero, Cr38_msb;
    logic Cr41_et_zero, Cr41_msb, Cr42_et_zero, Cr42_msb;
    logic Cr43_et_zero, Cr43_msb, Cr44_et_zero, Cr44_msb;
    logic Cr45_et_zero, Cr45_msb, Cr46_et_zero, Cr46_msb;
    logic Cr47_et_zero, Cr47_msb, Cr48_et_zero, Cr48_msb;
    logic Cr51_et_zero, Cr51_msb, Cr52_et_zero, Cr52_msb;
    logic Cr53_et_zero, Cr53_msb, Cr54_et_zero, Cr54_msb;
    logic Cr55_et_zero, Cr55_msb, Cr56_et_zero, Cr56_msb;
    logic Cr57_et_zero, Cr57_msb, Cr58_et_zero, Cr58_msb;
    logic Cr61_et_zero, Cr61_msb, Cr62_et_zero, Cr62_msb;
    logic Cr63_et_zero, Cr63_msb, Cr64_et_zero, Cr64_msb;
    logic Cr65_et_zero, Cr65_msb, Cr66_et_zero, Cr66_msb;
    logic Cr67_et_zero, Cr67_msb, Cr68_et_zero, Cr68_msb;
    logic Cr71_et_zero, Cr71_msb, Cr72_et_zero, Cr72_msb;
    logic Cr73_et_zero, Cr73_msb, Cr74_et_zero, Cr74_msb;
    logic Cr75_et_zero, Cr75_msb, Cr76_et_zero, Cr76_msb;
    logic Cr77_et_zero, Cr77_msb, Cr78_et_zero, Cr78_msb;
    logic Cr81_et_zero, Cr81_msb, Cr82_et_zero, Cr82_msb;
    logic Cr83_et_zero, Cr83_msb, Cr84_et_zero, Cr84_msb;
    logic Cr85_et_zero, Cr85_msb, Cr86_et_zero, Cr86_msb;
    logic Cr87_et_zero, Cr87_msb, Cr88_et_zero, Cr88_msb;

    logic Cr12_et_zero_1, Cr12_et_zero_2, Cr12_et_zero_3, Cr12_et_zero_4, Cr12_et_zero_5;

   

    logic [10:0] Cr11_Huff, Cr11_Huff_1, Cr11_Huff_2;
    logic [15:0] Cr12_Huff, Cr12_Huff_1, Cr12_Huff_2;
    logic [3:0]  Cr11_Huff_count, Cr11_Huff_shift, Cr11_Huff_shift_1, Cr11_amp_shift, Cr12_amp_shift;
    logic [3:0]  Cr12_Huff_shift, Cr12_Huff_shift_1, zero_run_length, zrl_1, zrl_2, zrl_3;
    logic [4:0]  Cr12_Huff_count, Cr12_Huff_count_1;
    logic [4:0]  Cr11_output_count, old_orc_1, old_orc_2;
    logic [4:0]  old_orc_3, old_orc_4, old_orc_5, old_orc_6, Cr12_oc_1;
    logic [4:0]  orc_3, orc_4, orc_5, orc_6, orc_7, orc_8;
    logic [4:0]  Cr12_output_count;
    logic [4:0]  Cr12_edge, Cr12_edge_1, Cr12_edge_2, Cr12_edge_3, Cr12_edge_4;

    logic [31:0] JPEG_bs, JPEG_bs_1, JPEG_bs_2, JPEG_bs_3, JPEG_bs_4, JPEG_bs_5;
    logic [31:0] JPEG_Cr12_bs, JPEG_Cr12_bs_1, JPEG_Cr12_bs_2, JPEG_Cr12_bs_3, JPEG_Cr12_bs_4;
    logic [31:0] JPEG_ro_bs, JPEG_ro_bs_1, JPEG_ro_bs_2, JPEG_ro_bs_3, JPEG_ro_bs_4;

    logic [21:0] Cr11_JPEG_LSBs_3;
    logic [10:0] Cr11_JPEG_LSBs, Cr11_JPEG_LSBs_1, Cr11_JPEG_LSBs_2;
    logic [9:0]  Cr12_JPEG_LSBs, Cr12_JPEG_LSBs_1, Cr12_JPEG_LSBs_2, Cr12_JPEG_LSBs_3;
    logic [25:0] Cr11_JPEG_bits, Cr11_JPEG_bits_1, Cr12_JPEG_bits, Cr12_JPEG_LSBs_4;

    logic [7:0]  Cr12_code_entry;

    logic third_8_all_0s, fourth_8_all_0s, fifth_8_all_0s, sixth_8_all_0s, seventh_8_all_0s;
    logic eighth_8_all_0s, end_of_block, code_15_0, zrl_et_15, end_of_block_output;

wire	[7:0]	code_index = { zrl_2, Cr12_bits };

 // Include the constants file
    `include "cr_huff_constants.svh"


always_ff @(posedge clk)
begin
	if (rst) begin
		third_8_all_0s <= 0; fourth_8_all_0s <= 0;
		fifth_8_all_0s <= 0; sixth_8_all_0s <= 0; seventh_8_all_0s <= 0;
		eighth_8_all_0s <= 0;
		end
	else if (enable_1) begin
		third_8_all_0s <= Cr25_et_zero & Cr34_et_zero & Cr43_et_zero & Cr52_et_zero
					  & Cr61_et_zero & Cr71_et_zero & Cr62_et_zero & Cr53_et_zero;
		fourth_8_all_0s <= Cr44_et_zero & Cr35_et_zero & Cr26_et_zero & Cr17_et_zero
					  & Cr18_et_zero & Cr27_et_zero & Cr36_et_zero & Cr45_et_zero;
		fifth_8_all_0s <= Cr54_et_zero & Cr63_et_zero & Cr72_et_zero & Cr81_et_zero
					  & Cr82_et_zero & Cr73_et_zero & Cr64_et_zero & Cr55_et_zero;
		sixth_8_all_0s <= Cr46_et_zero & Cr37_et_zero & Cr28_et_zero & Cr38_et_zero
					  & Cr47_et_zero & Cr56_et_zero & Cr65_et_zero & Cr74_et_zero;
		seventh_8_all_0s <= Cr83_et_zero & Cr84_et_zero & Cr75_et_zero & Cr66_et_zero
					  & Cr57_et_zero & Cr48_et_zero & Cr58_et_zero & Cr67_et_zero;
		eighth_8_all_0s <= Cr76_et_zero & Cr85_et_zero & Cr86_et_zero & Cr77_et_zero
					  & Cr68_et_zero & Cr78_et_zero & Cr87_et_zero & Cr88_et_zero;						  			  
		end
end	 


/* end_of_block checks to see if there are any nonzero elements left in the block
If there aren't any nonzero elements left, then the last bits in the JPEG stream
will be the end of block code.  The purpose of this register is to determine if the
zero run length code 15-0 should be used or not.  It should be used if there are 15 or more
zeros in a row, followed by a nonzero value.  If there are only zeros left in the block,
then end_of_block will be 1.  If there are any nonzero values left in the block, end_of_block 
will be 0. */

always_ff @(posedge clk)
begin
	if (rst) 
		end_of_block <= 0;
	else if (enable)
		end_of_block <= 0;
	else if (enable_module & block_counter < 32)
		end_of_block <= third_8_all_0s & fourth_8_all_0s & fifth_8_all_0s
					& sixth_8_all_0s & seventh_8_all_0s & eighth_8_all_0s;
	else if (enable_module & block_counter < 48)
		end_of_block <= fifth_8_all_0s & sixth_8_all_0s & seventh_8_all_0s 
					& eighth_8_all_0s;
	else if (enable_module & block_counter <= 64)
		end_of_block <= seventh_8_all_0s & eighth_8_all_0s;
	else if (enable_module & block_counter > 64)
		end_of_block <= 1;
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		block_counter <= 0;
		end
	else if (enable) begin
		block_counter <= 0;
		end	
	else if (enable_module) begin
		block_counter <= block_counter + 1;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		output_reg_count <= 0;
		end
	else if (end_of_block_output) begin
		output_reg_count <= 0;
		end
	else if (enable_6) begin
		output_reg_count <= output_reg_count + Cr11_output_count;
		end	
	else if (enable_latch_7) begin
		output_reg_count <= output_reg_count + Cr12_oc_1;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		old_orc_1 <= 0;
		end
	else if (end_of_block_output) begin
		old_orc_1 <= 0;
		end
	else if (enable_module) begin
		old_orc_1 <= output_reg_count;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		rollover <= 0; rollover_1 <= 0; rollover_2 <= 0;
		rollover_3 <= 0; rollover_4 <= 0; rollover_5 <= 0;
		rollover_6 <= 0; rollover_7 <= 0;
		old_orc_2 <= 0; 
		orc_3 <= 0; orc_4 <= 0; orc_5 <= 0; orc_6 <= 0; 
		orc_7 <= 0; orc_8 <= 0; data_ready <= 0;
		end_of_block_output <= 0; end_of_block_empty <= 0;
		end
	else if (enable_module) begin
		rollover <= (old_orc_1 > output_reg_count); 
		rollover_1 <= rollover;
		rollover_2 <= rollover_1;
		rollover_3 <= rollover_2;
		rollover_4 <= rollover_3;
		rollover_5 <= rollover_4;
		rollover_6 <= rollover_5;
		rollover_7 <= rollover_6;
		old_orc_2 <= old_orc_1;
		orc_3 <= old_orc_2;
		orc_4 <= orc_3; orc_5 <= orc_4;
		orc_6 <= orc_5; orc_7 <= orc_6;
		orc_8 <= orc_7;
		data_ready <= rollover_6 | block_counter == 77;
		end_of_block_output <= block_counter == 77;
		end_of_block_empty <= rollover_7 & block_counter == 77 & output_reg_count == 0;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_5 <= 0; 
		end
 else if (enable_module) begin
        for (int i = 31; i > 0; i--) begin
            JPEG_bs_5[i] <= (rollover_6 & (orc_7 > (31-i))) ? JPEG_ro_bs_4[i] : JPEG_bs_4[i];
        end
        JPEG_bs_5[0] <= JPEG_bs_4[0]; // LSB remains unchanged
    end
end

	
always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_4 <= 0; JPEG_ro_bs_4 <= 0;
		end
	else if (enable_module) begin 
		JPEG_bs_4 <= (old_orc_6 == 1) ? JPEG_bs_3 >> 1 : JPEG_bs_3;
		JPEG_ro_bs_4 <= (Cr12_edge_4 <= 1) ? JPEG_ro_bs_3 << 1 : JPEG_ro_bs_3;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_3 <= 0; old_orc_6 <= 0; JPEG_ro_bs_3 <= 0;
		Cr12_edge_4 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_3 <= (old_orc_5 >= 2) ? JPEG_bs_2 >> 2 : JPEG_bs_2;
		old_orc_6 <= (old_orc_5 >= 2) ? old_orc_5 - 2 : old_orc_5;
		JPEG_ro_bs_3 <= (Cr12_edge_3 <= 2) ? JPEG_ro_bs_2 << 2 : JPEG_ro_bs_2;
		Cr12_edge_4 <= (Cr12_edge_3 <= 2) ? Cr12_edge_3 : Cr12_edge_3 - 2;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_2 <= 0; old_orc_5 <= 0; JPEG_ro_bs_2 <= 0;
		Cr12_edge_3 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_2 <= (old_orc_4 >= 4) ? JPEG_bs_1 >> 4 : JPEG_bs_1;
		old_orc_5 <= (old_orc_4 >= 4) ? old_orc_4 - 4 : old_orc_4;
		JPEG_ro_bs_2 <= (Cr12_edge_2 <= 4) ? JPEG_ro_bs_1 << 4 : JPEG_ro_bs_1;
		Cr12_edge_3 <= (Cr12_edge_2 <= 4) ? Cr12_edge_2 : Cr12_edge_2 - 4;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs_1 <= 0; old_orc_4 <= 0; JPEG_ro_bs_1 <= 0; 
		Cr12_edge_2 <= 0; 
		end
	else if (enable_module) begin 
		JPEG_bs_1 <= (old_orc_3 >= 8) ? JPEG_bs >> 8 : JPEG_bs;
		old_orc_4 <= (old_orc_3 >= 8) ? old_orc_3 - 8 : old_orc_3;
		JPEG_ro_bs_1 <= (Cr12_edge_1 <= 8) ? JPEG_ro_bs << 8 : JPEG_ro_bs;
		Cr12_edge_2 <= (Cr12_edge_1 <= 8) ? Cr12_edge_1 : Cr12_edge_1 - 8;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		JPEG_bs <= 0; old_orc_3 <= 0; JPEG_ro_bs <= 0;
		Cr12_edge_1 <= 0; Cr11_JPEG_bits_1 <= 0;
		end
	else if (enable_module) begin 
		JPEG_bs <= (old_orc_2 >= 16) ? Cr11_JPEG_bits >> 10 : Cr11_JPEG_bits << 6;
		old_orc_3 <= (old_orc_2 >= 16) ? old_orc_2 - 16 : old_orc_2;
		JPEG_ro_bs <= (Cr12_edge <= 16) ? Cr11_JPEG_bits_1 << 16 : Cr11_JPEG_bits_1;
		Cr12_edge_1 <= (Cr12_edge <= 16) ? Cr12_edge : Cr12_edge - 16;
		Cr11_JPEG_bits_1 <= Cr11_JPEG_bits;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_JPEG_bits <= 0; Cr12_edge <= 0;
		end
	else if (enable_module) begin
    // Assign bits [25:10] based on the shift value
    for (int i = 25; i >= 10; i--) begin
        Cr12_JPEG_bits[i] <= (Cr12_Huff_shift_1 >= (i - 9)) ? Cr12_JPEG_LSBs_4[i] : Cr12_Huff_2[i - 10];
    end

    // Directly assign lower bits [9:0]
    Cr12_JPEG_bits[9:0] <= Cr12_JPEG_LSBs_4[9:0];

    // Update edge
    Cr12_edge <= old_orc_2 + 26; // 26 is the size of Cr11_JPEG_bits
end

end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_JPEG_bits <= 0; 
		end
else if (enable_7) begin
    // Assign bits [25:15] based on the shift value
    for (int i = 25; i >= 15; i--) begin
        Cr11_JPEG_bits[i] <= (Cr11_Huff_shift_1 >= (i - 14)) ? Cr11_JPEG_LSBs_3[i - 4] : Cr11_Huff_2[i - 15];
    end

    // Directly assign lower bits [14:4]
    Cr11_JPEG_bits[14:4] <= Cr11_JPEG_LSBs_3[10:0];
end

	else if (enable_latch_8) begin
		Cr11_JPEG_bits <= Cr12_JPEG_bits;
		end
end	


always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_oc_1 <= 0; Cr12_JPEG_LSBs_4 <= 0;
		Cr12_Huff_2 <= 0; Cr12_Huff_shift_1 <= 0;
		end
	else if (enable_module) begin 
		Cr12_oc_1 <= (Cr12_et_zero_5 & !code_15_0 & block_counter != 67) ? 0 : 
			Cr12_bits_3 + Cr12_Huff_count_1;
		Cr12_JPEG_LSBs_4 <= Cr12_JPEG_LSBs_3 << Cr12_Huff_shift;
		Cr12_Huff_2 <= Cr12_Huff_1;
		Cr12_Huff_shift_1 <= Cr12_Huff_shift;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_JPEG_LSBs_3 <= 0; Cr11_Huff_2 <= 0; 
		Cr11_Huff_shift_1 <= 0; 
		end
	else if (enable_6) begin 
		Cr11_JPEG_LSBs_3 <= Cr11_JPEG_LSBs_2 << Cr11_Huff_shift;
		Cr11_Huff_2 <= Cr11_Huff_1;
		Cr11_Huff_shift_1 <= Cr11_Huff_shift;
		end
end	


always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_Huff_shift <= 0;
		Cr12_Huff_1 <= 0; Cr12_JPEG_LSBs_3 <= 0; Cr12_bits_3 <= 0;
		Cr12_Huff_count_1 <= 0; Cr12_et_zero_5 <= 0; code_15_0 <= 0;
		end
	else if (enable_module) begin 
		Cr12_Huff_shift <= 16 - Cr12_Huff_count;
		Cr12_Huff_1 <= Cr12_Huff;
		Cr12_JPEG_LSBs_3 <= Cr12_JPEG_LSBs_2;
		Cr12_bits_3 <= Cr12_bits_2;
		Cr12_Huff_count_1 <= Cr12_Huff_count;
		Cr12_et_zero_5 <= Cr12_et_zero_4;
		code_15_0 <= zrl_et_15 & !end_of_block;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_output_count <= 0; Cr11_JPEG_LSBs_2 <= 0; Cr11_Huff_shift <= 0;
		Cr11_Huff_1 <= 0;
		end
	else if (enable_5) begin 
		Cr11_output_count <= Cr11_bits_1 + Cr11_Huff_count;
		Cr11_JPEG_LSBs_2 <= Cr11_JPEG_LSBs_1 << Cr11_amp_shift;
		Cr11_Huff_shift <= 11 - Cr11_Huff_count;
		Cr11_Huff_1 <= Cr11_Huff;
		end
end	


always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_JPEG_LSBs_2 <= 0;
		Cr12_Huff <= 0; Cr12_Huff_count <= 0; Cr12_bits_2 <= 0;
		Cr12_et_zero_4 <= 0; zrl_et_15 <= 0; zrl_3 <= 0;
		end
	else if (enable_module) begin
		Cr12_JPEG_LSBs_2 <= Cr12_JPEG_LSBs_1 << Cr12_amp_shift;
		Cr12_Huff <= Cr_AC[Cr12_code_entry];
		Cr12_Huff_count <= Cr_AC_code_length[Cr12_code_entry];
		Cr12_bits_2 <= Cr12_bits_1;
		Cr12_et_zero_4 <= Cr12_et_zero_3;
		zrl_et_15 <= zrl_3 == 15;
		zrl_3 <= zrl_2;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_Huff <= 0; Cr11_Huff_count <= 0; Cr11_amp_shift <= 0;
		Cr11_JPEG_LSBs_1 <= 0; Cr11_bits_1 <= 0; 
		end
	else if (enable_4) begin
		Cr11_Huff[10:0] <= Cr_DC[Cr11_bits];
		Cr11_Huff_count <= Cr_DC_code_length[Cr11_bits];
		Cr11_amp_shift <= 11 - Cr11_bits;
		Cr11_JPEG_LSBs_1 <= Cr11_JPEG_LSBs;
		Cr11_bits_1 <= Cr11_bits;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_code_entry <= 0; Cr12_JPEG_LSBs_1 <= 0; Cr12_amp_shift <= 0; 
		Cr12_bits_1 <= 0; Cr12_et_zero_3 <= 0; zrl_2 <= 0;
		end
	else if (enable_module) begin
		Cr12_code_entry <= Cr_AC_run_code[code_index];
		Cr12_JPEG_LSBs_1 <= Cr12_JPEG_LSBs;
		Cr12_amp_shift <= 10 - Cr12_bits;
		Cr12_bits_1 <= Cr12_bits;
		Cr12_et_zero_3 <= Cr12_et_zero_2;
		zrl_2 <= zrl_1;
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_bits <= 0; Cr11_JPEG_LSBs <= 0; 
		end
	else if (enable_3) begin
		Cr11_bits <= Cr11_msb ? Cr11_bits_neg : Cr11_bits_pos;
		Cr11_JPEG_LSBs <= Cr11_amp[10:0]; // The top bit of Cr11_amp is the sign bit
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_bits <= 0; Cr12_JPEG_LSBs <= 0; zrl_1 <= 0;
		Cr12_et_zero_2 <= 0;
		end
	else if (enable_module) begin 
		Cr12_bits <= Cr12_msb_1 ? Cr12_bits_neg : Cr12_bits_pos;
		Cr12_JPEG_LSBs <= Cr12_amp[9:0]; // The top bit of Cr12_amp is the sign bit
		zrl_1 <= block_counter == 62 & Cr12_et_zero ? 0 : zero_run_length;
		Cr12_et_zero_2 <= Cr12_et_zero_1;
		end
end	

// Cr11_amp is the amplitude that will be represented in bits in the 
// JPEG code, following the run length code
always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_amp <= 0;
		end
	else if (enable_2) begin 
		Cr11_amp <= Cr11_msb ? Cr11_1_neg : Cr11_1_pos;
		end
end	


always_ff @(posedge clk)
begin
	if (rst) 
		zero_run_length <= 0; 
	else if (enable)
		zero_run_length <= 0; 
	else if (enable_module) 
		zero_run_length <= Cr12_et_zero ? zero_run_length + 1: 0;
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr12_amp <= 0;  
		Cr12_et_zero_1 <= 0; Cr12_msb_1 <= 0;
		end
	else if (enable_module) begin
		Cr12_amp <= Cr12_msb ? Cr12_neg : Cr12_pos;
		Cr12_et_zero_1 <= Cr12_et_zero;
		Cr12_msb_1 <= Cr12_msb;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		Cr11_1_pos <= 0; Cr11_1_neg <= 0; Cr11_msb <= 0;
		Cr11_previous <= 0; 
		end
	else if (enable_1) begin
		Cr11_1_pos <= Cr11_diff;
		Cr11_1_neg <= Cr11_diff - 1;
		Cr11_msb <= Cr11_diff[11];
		Cr11_previous <= Cr11_1;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin 
		Cr12_pos <= 0; Cr12_neg <= 0; Cr12_msb <= 0; Cr12_et_zero <= 0; 
		Cr13_pos <= 0; Cr13_neg <= 0; Cr13_msb <= 0; Cr13_et_zero <= 0;
		Cr14_pos <= 0; Cr14_neg <= 0; Cr14_msb <= 0; Cr14_et_zero <= 0; 
		Cr15_pos <= 0; Cr15_neg <= 0; Cr15_msb <= 0; Cr15_et_zero <= 0;
		Cr16_pos <= 0; Cr16_neg <= 0; Cr16_msb <= 0; Cr16_et_zero <= 0; 
		Cr17_pos <= 0; Cr17_neg <= 0; Cr17_msb <= 0; Cr17_et_zero <= 0;
		Cr18_pos <= 0; Cr18_neg <= 0; Cr18_msb <= 0; Cr18_et_zero <= 0; 
		Cr21_pos <= 0; Cr21_neg <= 0; Cr21_msb <= 0; Cr21_et_zero <= 0;
		Cr22_pos <= 0; Cr22_neg <= 0; Cr22_msb <= 0; Cr22_et_zero <= 0; 
		Cr23_pos <= 0; Cr23_neg <= 0; Cr23_msb <= 0; Cr23_et_zero <= 0;
		Cr24_pos <= 0; Cr24_neg <= 0; Cr24_msb <= 0; Cr24_et_zero <= 0; 
		Cr25_pos <= 0; Cr25_neg <= 0; Cr25_msb <= 0; Cr25_et_zero <= 0;
		Cr26_pos <= 0; Cr26_neg <= 0; Cr26_msb <= 0; Cr26_et_zero <= 0; 
		Cr27_pos <= 0; Cr27_neg <= 0; Cr27_msb <= 0; Cr27_et_zero <= 0;
		Cr28_pos <= 0; Cr28_neg <= 0; Cr28_msb <= 0; Cr28_et_zero <= 0; 
		Cr31_pos <= 0; Cr31_neg <= 0; Cr31_msb <= 0; Cr31_et_zero <= 0;  
		Cr32_pos <= 0; Cr32_neg <= 0; Cr32_msb <= 0; Cr32_et_zero <= 0; 
		Cr33_pos <= 0; Cr33_neg <= 0; Cr33_msb <= 0; Cr33_et_zero <= 0;
		Cr34_pos <= 0; Cr34_neg <= 0; Cr34_msb <= 0; Cr34_et_zero <= 0; 
		Cr35_pos <= 0; Cr35_neg <= 0; Cr35_msb <= 0; Cr35_et_zero <= 0;
		Cr36_pos <= 0; Cr36_neg <= 0; Cr36_msb <= 0; Cr36_et_zero <= 0; 
		Cr37_pos <= 0; Cr37_neg <= 0; Cr37_msb <= 0; Cr37_et_zero <= 0;
		Cr38_pos <= 0; Cr38_neg <= 0; Cr38_msb <= 0; Cr38_et_zero <= 0;
		Cr41_pos <= 0; Cr41_neg <= 0; Cr41_msb <= 0; Cr41_et_zero <= 0;  
		Cr42_pos <= 0; Cr42_neg <= 0; Cr42_msb <= 0; Cr42_et_zero <= 0; 
		Cr43_pos <= 0; Cr43_neg <= 0; Cr43_msb <= 0; Cr43_et_zero <= 0;
		Cr44_pos <= 0; Cr44_neg <= 0; Cr44_msb <= 0; Cr44_et_zero <= 0; 
		Cr45_pos <= 0; Cr45_neg <= 0; Cr45_msb <= 0; Cr45_et_zero <= 0;
		Cr46_pos <= 0; Cr46_neg <= 0; Cr46_msb <= 0; Cr46_et_zero <= 0; 
		Cr47_pos <= 0; Cr47_neg <= 0; Cr47_msb <= 0; Cr47_et_zero <= 0;
		Cr48_pos <= 0; Cr48_neg <= 0; Cr48_msb <= 0; Cr48_et_zero <= 0;
		Cr51_pos <= 0; Cr51_neg <= 0; Cr51_msb <= 0; Cr51_et_zero <= 0;  
		Cr52_pos <= 0; Cr52_neg <= 0; Cr52_msb <= 0; Cr52_et_zero <= 0; 
		Cr53_pos <= 0; Cr53_neg <= 0; Cr53_msb <= 0; Cr53_et_zero <= 0;
		Cr54_pos <= 0; Cr54_neg <= 0; Cr54_msb <= 0; Cr54_et_zero <= 0; 
		Cr55_pos <= 0; Cr55_neg <= 0; Cr55_msb <= 0; Cr55_et_zero <= 0;
		Cr56_pos <= 0; Cr56_neg <= 0; Cr56_msb <= 0; Cr56_et_zero <= 0; 
		Cr57_pos <= 0; Cr57_neg <= 0; Cr57_msb <= 0; Cr57_et_zero <= 0;
		Cr58_pos <= 0; Cr58_neg <= 0; Cr58_msb <= 0; Cr58_et_zero <= 0;
		Cr61_pos <= 0; Cr61_neg <= 0; Cr61_msb <= 0; Cr61_et_zero <= 0;  
		Cr62_pos <= 0; Cr62_neg <= 0; Cr62_msb <= 0; Cr62_et_zero <= 0; 
		Cr63_pos <= 0; Cr63_neg <= 0; Cr63_msb <= 0; Cr63_et_zero <= 0;
		Cr64_pos <= 0; Cr64_neg <= 0; Cr64_msb <= 0; Cr64_et_zero <= 0; 
		Cr65_pos <= 0; Cr65_neg <= 0; Cr65_msb <= 0; Cr65_et_zero <= 0;
		Cr66_pos <= 0; Cr66_neg <= 0; Cr66_msb <= 0; Cr66_et_zero <= 0; 
		Cr67_pos <= 0; Cr67_neg <= 0; Cr67_msb <= 0; Cr67_et_zero <= 0;
		Cr68_pos <= 0; Cr68_neg <= 0; Cr68_msb <= 0; Cr68_et_zero <= 0;
		Cr71_pos <= 0; Cr71_neg <= 0; Cr71_msb <= 0; Cr71_et_zero <= 0;  
		Cr72_pos <= 0; Cr72_neg <= 0; Cr72_msb <= 0; Cr72_et_zero <= 0; 
		Cr73_pos <= 0; Cr73_neg <= 0; Cr73_msb <= 0; Cr73_et_zero <= 0;
		Cr74_pos <= 0; Cr74_neg <= 0; Cr74_msb <= 0; Cr74_et_zero <= 0; 
		Cr75_pos <= 0; Cr75_neg <= 0; Cr75_msb <= 0; Cr75_et_zero <= 0;
		Cr76_pos <= 0; Cr76_neg <= 0; Cr76_msb <= 0; Cr76_et_zero <= 0; 
		Cr77_pos <= 0; Cr77_neg <= 0; Cr77_msb <= 0; Cr77_et_zero <= 0;
		Cr78_pos <= 0; Cr78_neg <= 0; Cr78_msb <= 0; Cr78_et_zero <= 0;
		Cr81_pos <= 0; Cr81_neg <= 0; Cr81_msb <= 0; Cr81_et_zero <= 0;  
		Cr82_pos <= 0; Cr82_neg <= 0; Cr82_msb <= 0; Cr82_et_zero <= 0; 
		Cr83_pos <= 0; Cr83_neg <= 0; Cr83_msb <= 0; Cr83_et_zero <= 0;
		Cr84_pos <= 0; Cr84_neg <= 0; Cr84_msb <= 0; Cr84_et_zero <= 0; 
		Cr85_pos <= 0; Cr85_neg <= 0; Cr85_msb <= 0; Cr85_et_zero <= 0;
		Cr86_pos <= 0; Cr86_neg <= 0; Cr86_msb <= 0; Cr86_et_zero <= 0; 
		Cr87_pos <= 0; Cr87_neg <= 0; Cr87_msb <= 0; Cr87_et_zero <= 0;
		Cr88_pos <= 0; Cr88_neg <= 0; Cr88_msb <= 0; Cr88_et_zero <= 0; 
		end
	else if (enable) begin 
		Cr12_pos <= Cr12;	   
		Cr12_neg <= Cr12 - 1;
		Cr12_msb <= Cr12[10];
		Cr12_et_zero <= !(|Cr12);
		Cr13_pos <= Cr13;	   
		Cr13_neg <= Cr13 - 1;
		Cr13_msb <= Cr13[10];
		Cr13_et_zero <= !(|Cr13);
		Cr14_pos <= Cr14;	   
		Cr14_neg <= Cr14 - 1;
		Cr14_msb <= Cr14[10];
		Cr14_et_zero <= !(|Cr14);
		Cr15_pos <= Cr15;	   
		Cr15_neg <= Cr15 - 1;
		Cr15_msb <= Cr15[10];
		Cr15_et_zero <= !(|Cr15);
		Cr16_pos <= Cr16;	   
		Cr16_neg <= Cr16 - 1;
		Cr16_msb <= Cr16[10];
		Cr16_et_zero <= !(|Cr16);
		Cr17_pos <= Cr17;	   
		Cr17_neg <= Cr17 - 1;
		Cr17_msb <= Cr17[10];
		Cr17_et_zero <= !(|Cr17);
		Cr18_pos <= Cr18;	   
		Cr18_neg <= Cr18 - 1;
		Cr18_msb <= Cr18[10];
		Cr18_et_zero <= !(|Cr18);
		Cr21_pos <= Cr21;	   
		Cr21_neg <= Cr21 - 1;
		Cr21_msb <= Cr21[10];
		Cr21_et_zero <= !(|Cr21);
		Cr22_pos <= Cr22;	   
		Cr22_neg <= Cr22 - 1;
		Cr22_msb <= Cr22[10];
		Cr22_et_zero <= !(|Cr22);
		Cr23_pos <= Cr23;	   
		Cr23_neg <= Cr23 - 1;
		Cr23_msb <= Cr23[10];
		Cr23_et_zero <= !(|Cr23);
		Cr24_pos <= Cr24;	   
		Cr24_neg <= Cr24 - 1;
		Cr24_msb <= Cr24[10];
		Cr24_et_zero <= !(|Cr24);
		Cr25_pos <= Cr25;	   
		Cr25_neg <= Cr25 - 1;
		Cr25_msb <= Cr25[10];
		Cr25_et_zero <= !(|Cr25);
		Cr26_pos <= Cr26;	   
		Cr26_neg <= Cr26 - 1;
		Cr26_msb <= Cr26[10];
		Cr26_et_zero <= !(|Cr26);
		Cr27_pos <= Cr27;	   
		Cr27_neg <= Cr27 - 1;
		Cr27_msb <= Cr27[10];
		Cr27_et_zero <= !(|Cr27);
		Cr28_pos <= Cr28;	   
		Cr28_neg <= Cr28 - 1;
		Cr28_msb <= Cr28[10];
		Cr28_et_zero <= !(|Cr28);
		Cr31_pos <= Cr31;	   
		Cr31_neg <= Cr31 - 1;
		Cr31_msb <= Cr31[10];
		Cr31_et_zero <= !(|Cr31);
		Cr32_pos <= Cr32;	   
		Cr32_neg <= Cr32 - 1;
		Cr32_msb <= Cr32[10];
		Cr32_et_zero <= !(|Cr32);
		Cr33_pos <= Cr33;	   
		Cr33_neg <= Cr33 - 1;
		Cr33_msb <= Cr33[10];
		Cr33_et_zero <= !(|Cr33);
		Cr34_pos <= Cr34;	   
		Cr34_neg <= Cr34 - 1;
		Cr34_msb <= Cr34[10];
		Cr34_et_zero <= !(|Cr34);
		Cr35_pos <= Cr35;	   
		Cr35_neg <= Cr35 - 1;
		Cr35_msb <= Cr35[10];
		Cr35_et_zero <= !(|Cr35);
		Cr36_pos <= Cr36;	   
		Cr36_neg <= Cr36 - 1;
		Cr36_msb <= Cr36[10];
		Cr36_et_zero <= !(|Cr36);
		Cr37_pos <= Cr37;	   
		Cr37_neg <= Cr37 - 1;
		Cr37_msb <= Cr37[10];
		Cr37_et_zero <= !(|Cr37);
		Cr38_pos <= Cr38;	   
		Cr38_neg <= Cr38 - 1;
		Cr38_msb <= Cr38[10];
		Cr38_et_zero <= !(|Cr38);
		Cr41_pos <= Cr41;	   
		Cr41_neg <= Cr41 - 1;
		Cr41_msb <= Cr41[10];
		Cr41_et_zero <= !(|Cr41);
		Cr42_pos <= Cr42;	   
		Cr42_neg <= Cr42 - 1;
		Cr42_msb <= Cr42[10];
		Cr42_et_zero <= !(|Cr42);
		Cr43_pos <= Cr43;	   
		Cr43_neg <= Cr43 - 1;
		Cr43_msb <= Cr43[10];
		Cr43_et_zero <= !(|Cr43);
		Cr44_pos <= Cr44;	   
		Cr44_neg <= Cr44 - 1;
		Cr44_msb <= Cr44[10];
		Cr44_et_zero <= !(|Cr44);
		Cr45_pos <= Cr45;	   
		Cr45_neg <= Cr45 - 1;
		Cr45_msb <= Cr45[10];
		Cr45_et_zero <= !(|Cr45);
		Cr46_pos <= Cr46;	   
		Cr46_neg <= Cr46 - 1;
		Cr46_msb <= Cr46[10];
		Cr46_et_zero <= !(|Cr46);
		Cr47_pos <= Cr47;	   
		Cr47_neg <= Cr47 - 1;
		Cr47_msb <= Cr47[10];
		Cr47_et_zero <= !(|Cr47);
		Cr48_pos <= Cr48;	   
		Cr48_neg <= Cr48 - 1;
		Cr48_msb <= Cr48[10];
		Cr48_et_zero <= !(|Cr48);
		Cr51_pos <= Cr51;	   
		Cr51_neg <= Cr51 - 1;
		Cr51_msb <= Cr51[10];
		Cr51_et_zero <= !(|Cr51);
		Cr52_pos <= Cr52;	   
		Cr52_neg <= Cr52 - 1;
		Cr52_msb <= Cr52[10];
		Cr52_et_zero <= !(|Cr52);
		Cr53_pos <= Cr53;	   
		Cr53_neg <= Cr53 - 1;
		Cr53_msb <= Cr53[10];
		Cr53_et_zero <= !(|Cr53);
		Cr54_pos <= Cr54;	   
		Cr54_neg <= Cr54 - 1;
		Cr54_msb <= Cr54[10];
		Cr54_et_zero <= !(|Cr54);
		Cr55_pos <= Cr55;	   
		Cr55_neg <= Cr55 - 1;
		Cr55_msb <= Cr55[10];
		Cr55_et_zero <= !(|Cr55);
		Cr56_pos <= Cr56;	   
		Cr56_neg <= Cr56 - 1;
		Cr56_msb <= Cr56[10];
		Cr56_et_zero <= !(|Cr56);
		Cr57_pos <= Cr57;	   
		Cr57_neg <= Cr57 - 1;
		Cr57_msb <= Cr57[10];
		Cr57_et_zero <= !(|Cr57);
		Cr58_pos <= Cr58;	   
		Cr58_neg <= Cr58 - 1;
		Cr58_msb <= Cr58[10];
		Cr58_et_zero <= !(|Cr58);
		Cr61_pos <= Cr61;	   
		Cr61_neg <= Cr61 - 1;
		Cr61_msb <= Cr61[10];
		Cr61_et_zero <= !(|Cr61);
		Cr62_pos <= Cr62;	   
		Cr62_neg <= Cr62 - 1;
		Cr62_msb <= Cr62[10];
		Cr62_et_zero <= !(|Cr62);
		Cr63_pos <= Cr63;	   
		Cr63_neg <= Cr63 - 1;
		Cr63_msb <= Cr63[10];
		Cr63_et_zero <= !(|Cr63);
		Cr64_pos <= Cr64;	   
		Cr64_neg <= Cr64 - 1;
		Cr64_msb <= Cr64[10];
		Cr64_et_zero <= !(|Cr64);
		Cr65_pos <= Cr65;	   
		Cr65_neg <= Cr65 - 1;
		Cr65_msb <= Cr65[10];
		Cr65_et_zero <= !(|Cr65);
		Cr66_pos <= Cr66;	   
		Cr66_neg <= Cr66 - 1;
		Cr66_msb <= Cr66[10];
		Cr66_et_zero <= !(|Cr66);
		Cr67_pos <= Cr67;	   
		Cr67_neg <= Cr67 - 1;
		Cr67_msb <= Cr67[10];
		Cr67_et_zero <= !(|Cr67);
		Cr68_pos <= Cr68;	   
		Cr68_neg <= Cr68 - 1;
		Cr68_msb <= Cr68[10];
		Cr68_et_zero <= !(|Cr68);
		Cr71_pos <= Cr71;	   
		Cr71_neg <= Cr71 - 1;
		Cr71_msb <= Cr71[10];
		Cr71_et_zero <= !(|Cr71);
		Cr72_pos <= Cr72;	   
		Cr72_neg <= Cr72 - 1;
		Cr72_msb <= Cr72[10];
		Cr72_et_zero <= !(|Cr72);
		Cr73_pos <= Cr73;	   
		Cr73_neg <= Cr73 - 1;
		Cr73_msb <= Cr73[10];
		Cr73_et_zero <= !(|Cr73);
		Cr74_pos <= Cr74;	   
		Cr74_neg <= Cr74 - 1;
		Cr74_msb <= Cr74[10];
		Cr74_et_zero <= !(|Cr74);
		Cr75_pos <= Cr75;	   
		Cr75_neg <= Cr75 - 1;
		Cr75_msb <= Cr75[10];
		Cr75_et_zero <= !(|Cr75);
		Cr76_pos <= Cr76;	   
		Cr76_neg <= Cr76 - 1;
		Cr76_msb <= Cr76[10];
		Cr76_et_zero <= !(|Cr76);
		Cr77_pos <= Cr77;	   
		Cr77_neg <= Cr77 - 1;
		Cr77_msb <= Cr77[10];
		Cr77_et_zero <= !(|Cr77);
		Cr78_pos <= Cr78;	   
		Cr78_neg <= Cr78 - 1;
		Cr78_msb <= Cr78[10];
		Cr78_et_zero <= !(|Cr78);
		Cr81_pos <= Cr81;	   
		Cr81_neg <= Cr81 - 1;
		Cr81_msb <= Cr81[10];
		Cr81_et_zero <= !(|Cr81);
		Cr82_pos <= Cr82;	   
		Cr82_neg <= Cr82 - 1;
		Cr82_msb <= Cr82[10];
		Cr82_et_zero <= !(|Cr82);
		Cr83_pos <= Cr83;	   
		Cr83_neg <= Cr83 - 1;
		Cr83_msb <= Cr83[10];
		Cr83_et_zero <= !(|Cr83);
		Cr84_pos <= Cr84;	   
		Cr84_neg <= Cr84 - 1;
		Cr84_msb <= Cr84[10];
		Cr84_et_zero <= !(|Cr84);
		Cr85_pos <= Cr85;	   
		Cr85_neg <= Cr85 - 1;
		Cr85_msb <= Cr85[10];
		Cr85_et_zero <= !(|Cr85);
		Cr86_pos <= Cr86;	   
		Cr86_neg <= Cr86 - 1;
		Cr86_msb <= Cr86[10];
		Cr86_et_zero <= !(|Cr86);
		Cr87_pos <= Cr87;	   
		Cr87_neg <= Cr87 - 1;
		Cr87_msb <= Cr87[10];
		Cr87_et_zero <= !(|Cr87);
		Cr88_pos <= Cr88;	   
		Cr88_neg <= Cr88 - 1;
		Cr88_msb <= Cr88[10];
		Cr88_et_zero <= !(|Cr88);
		end
	else if (enable_module) begin 
		Cr12_pos <= Cr21_pos;	   
		Cr12_neg <= Cr21_neg;
		Cr12_msb <= Cr21_msb;
		Cr12_et_zero <= Cr21_et_zero;
		Cr21_pos <= Cr31_pos;	   
		Cr21_neg <= Cr31_neg;
		Cr21_msb <= Cr31_msb;
		Cr21_et_zero <= Cr31_et_zero;
		Cr31_pos <= Cr22_pos;	   
		Cr31_neg <= Cr22_neg;
		Cr31_msb <= Cr22_msb;
		Cr31_et_zero <= Cr22_et_zero;
		Cr22_pos <= Cr13_pos;	   
		Cr22_neg <= Cr13_neg;
		Cr22_msb <= Cr13_msb;
		Cr22_et_zero <= Cr13_et_zero;
		Cr13_pos <= Cr14_pos;	   
		Cr13_neg <= Cr14_neg;
		Cr13_msb <= Cr14_msb;
		Cr13_et_zero <= Cr14_et_zero;
		Cr14_pos <= Cr23_pos;	   
		Cr14_neg <= Cr23_neg;
		Cr14_msb <= Cr23_msb;
		Cr14_et_zero <= Cr23_et_zero;
		Cr23_pos <= Cr32_pos;	   
		Cr23_neg <= Cr32_neg;
		Cr23_msb <= Cr32_msb;
		Cr23_et_zero <= Cr32_et_zero;
		Cr32_pos <= Cr41_pos;	   
		Cr32_neg <= Cr41_neg;
		Cr32_msb <= Cr41_msb;
		Cr32_et_zero <= Cr41_et_zero;
		Cr41_pos <= Cr51_pos;	   
		Cr41_neg <= Cr51_neg;
		Cr41_msb <= Cr51_msb;
		Cr41_et_zero <= Cr51_et_zero;
		Cr51_pos <= Cr42_pos;	   
		Cr51_neg <= Cr42_neg;
		Cr51_msb <= Cr42_msb;
		Cr51_et_zero <= Cr42_et_zero;
		Cr42_pos <= Cr33_pos;	   
		Cr42_neg <= Cr33_neg;
		Cr42_msb <= Cr33_msb;
		Cr42_et_zero <= Cr33_et_zero;
		Cr33_pos <= Cr24_pos;	   
		Cr33_neg <= Cr24_neg;
		Cr33_msb <= Cr24_msb;
		Cr33_et_zero <= Cr24_et_zero;
		Cr24_pos <= Cr15_pos;	   
		Cr24_neg <= Cr15_neg;
		Cr24_msb <= Cr15_msb;
		Cr24_et_zero <= Cr15_et_zero;
		Cr15_pos <= Cr16_pos;	   
		Cr15_neg <= Cr16_neg;
		Cr15_msb <= Cr16_msb;
		Cr15_et_zero <= Cr16_et_zero;
		Cr16_pos <= Cr25_pos;	   
		Cr16_neg <= Cr25_neg;
		Cr16_msb <= Cr25_msb;
		Cr16_et_zero <= Cr25_et_zero;
		Cr25_pos <= Cr34_pos;	   
		Cr25_neg <= Cr34_neg;
		Cr25_msb <= Cr34_msb;
		Cr25_et_zero <= Cr34_et_zero;
		Cr34_pos <= Cr43_pos;	   
		Cr34_neg <= Cr43_neg;
		Cr34_msb <= Cr43_msb;
		Cr34_et_zero <= Cr43_et_zero;
		Cr43_pos <= Cr52_pos;	   
		Cr43_neg <= Cr52_neg;
		Cr43_msb <= Cr52_msb;
		Cr43_et_zero <= Cr52_et_zero;
		Cr52_pos <= Cr61_pos;	   
		Cr52_neg <= Cr61_neg;
		Cr52_msb <= Cr61_msb;
		Cr52_et_zero <= Cr61_et_zero;
		Cr61_pos <= Cr71_pos;	   
		Cr61_neg <= Cr71_neg;
		Cr61_msb <= Cr71_msb;
		Cr61_et_zero <= Cr71_et_zero;
		Cr71_pos <= Cr62_pos;	   
		Cr71_neg <= Cr62_neg;
		Cr71_msb <= Cr62_msb;
		Cr71_et_zero <= Cr62_et_zero;
		Cr62_pos <= Cr53_pos;	   
		Cr62_neg <= Cr53_neg;
		Cr62_msb <= Cr53_msb;
		Cr62_et_zero <= Cr53_et_zero;
		Cr53_pos <= Cr44_pos;	   
		Cr53_neg <= Cr44_neg;
		Cr53_msb <= Cr44_msb;
		Cr53_et_zero <= Cr44_et_zero;
		Cr44_pos <= Cr35_pos;	   
		Cr44_neg <= Cr35_neg;
		Cr44_msb <= Cr35_msb;
		Cr44_et_zero <= Cr35_et_zero;
		Cr35_pos <= Cr26_pos;	   
		Cr35_neg <= Cr26_neg;
		Cr35_msb <= Cr26_msb;
		Cr35_et_zero <= Cr26_et_zero;
		Cr26_pos <= Cr17_pos;	   
		Cr26_neg <= Cr17_neg;
		Cr26_msb <= Cr17_msb;
		Cr26_et_zero <= Cr17_et_zero;
		Cr17_pos <= Cr18_pos;	   
		Cr17_neg <= Cr18_neg;
		Cr17_msb <= Cr18_msb;
		Cr17_et_zero <= Cr18_et_zero;
		Cr18_pos <= Cr27_pos;	   
		Cr18_neg <= Cr27_neg;
		Cr18_msb <= Cr27_msb;
		Cr18_et_zero <= Cr27_et_zero;
		Cr27_pos <= Cr36_pos;	   
		Cr27_neg <= Cr36_neg;
		Cr27_msb <= Cr36_msb;
		Cr27_et_zero <= Cr36_et_zero;
		Cr36_pos <= Cr45_pos;	   
		Cr36_neg <= Cr45_neg;
		Cr36_msb <= Cr45_msb;
		Cr36_et_zero <= Cr45_et_zero;
		Cr45_pos <= Cr54_pos;	   
		Cr45_neg <= Cr54_neg;
		Cr45_msb <= Cr54_msb;
		Cr45_et_zero <= Cr54_et_zero;
		Cr54_pos <= Cr63_pos;	   
		Cr54_neg <= Cr63_neg;
		Cr54_msb <= Cr63_msb;
		Cr54_et_zero <= Cr63_et_zero;
		Cr63_pos <= Cr72_pos;	   
		Cr63_neg <= Cr72_neg;
		Cr63_msb <= Cr72_msb;
		Cr63_et_zero <= Cr72_et_zero;
		Cr72_pos <= Cr81_pos;	   
		Cr72_neg <= Cr81_neg;
		Cr72_msb <= Cr81_msb;
		Cr72_et_zero <= Cr81_et_zero;
		Cr81_pos <= Cr82_pos;	   
		Cr81_neg <= Cr82_neg;
		Cr81_msb <= Cr82_msb;
		Cr81_et_zero <= Cr82_et_zero;
		Cr82_pos <= Cr73_pos;	   
		Cr82_neg <= Cr73_neg;
		Cr82_msb <= Cr73_msb;
		Cr82_et_zero <= Cr73_et_zero;
		Cr73_pos <= Cr64_pos;	   
		Cr73_neg <= Cr64_neg;
		Cr73_msb <= Cr64_msb;
		Cr73_et_zero <= Cr64_et_zero;
		Cr64_pos <= Cr55_pos;	   
		Cr64_neg <= Cr55_neg;
		Cr64_msb <= Cr55_msb;
		Cr64_et_zero <= Cr55_et_zero;
		Cr55_pos <= Cr46_pos;	   
		Cr55_neg <= Cr46_neg;
		Cr55_msb <= Cr46_msb;
		Cr55_et_zero <= Cr46_et_zero;
		Cr46_pos <= Cr37_pos;	   
		Cr46_neg <= Cr37_neg;
		Cr46_msb <= Cr37_msb;
		Cr46_et_zero <= Cr37_et_zero;
		Cr37_pos <= Cr28_pos;	   
		Cr37_neg <= Cr28_neg;
		Cr37_msb <= Cr28_msb;
		Cr37_et_zero <= Cr28_et_zero;
		Cr28_pos <= Cr38_pos;	   
		Cr28_neg <= Cr38_neg;
		Cr28_msb <= Cr38_msb;
		Cr28_et_zero <= Cr38_et_zero;
		Cr38_pos <= Cr47_pos;	   
		Cr38_neg <= Cr47_neg;
		Cr38_msb <= Cr47_msb;
		Cr38_et_zero <= Cr47_et_zero;
		Cr47_pos <= Cr56_pos;	   
		Cr47_neg <= Cr56_neg;
		Cr47_msb <= Cr56_msb;
		Cr47_et_zero <= Cr56_et_zero;
		Cr56_pos <= Cr65_pos;	   
		Cr56_neg <= Cr65_neg;
		Cr56_msb <= Cr65_msb;
		Cr56_et_zero <= Cr65_et_zero;
		Cr65_pos <= Cr74_pos;	   
		Cr65_neg <= Cr74_neg;
		Cr65_msb <= Cr74_msb;
		Cr65_et_zero <= Cr74_et_zero;
		Cr74_pos <= Cr83_pos;	   
		Cr74_neg <= Cr83_neg;
		Cr74_msb <= Cr83_msb;
		Cr74_et_zero <= Cr83_et_zero;
		Cr83_pos <= Cr84_pos;	   
		Cr83_neg <= Cr84_neg;
		Cr83_msb <= Cr84_msb;
		Cr83_et_zero <= Cr84_et_zero;
		Cr84_pos <= Cr75_pos;	   
		Cr84_neg <= Cr75_neg;
		Cr84_msb <= Cr75_msb;
		Cr84_et_zero <= Cr75_et_zero;
		Cr75_pos <= Cr66_pos;	   
		Cr75_neg <= Cr66_neg;
		Cr75_msb <= Cr66_msb;
		Cr75_et_zero <= Cr66_et_zero;
		Cr66_pos <= Cr57_pos;	   
		Cr66_neg <= Cr57_neg;
		Cr66_msb <= Cr57_msb;
		Cr66_et_zero <= Cr57_et_zero;
		Cr57_pos <= Cr48_pos;	   
		Cr57_neg <= Cr48_neg;
		Cr57_msb <= Cr48_msb;
		Cr57_et_zero <= Cr48_et_zero;
		Cr48_pos <= Cr58_pos;	   
		Cr48_neg <= Cr58_neg;
		Cr48_msb <= Cr58_msb;
		Cr48_et_zero <= Cr58_et_zero;
		Cr58_pos <= Cr67_pos;	   
		Cr58_neg <= Cr67_neg;
		Cr58_msb <= Cr67_msb;
		Cr58_et_zero <= Cr67_et_zero;
		Cr67_pos <= Cr76_pos;	   
		Cr67_neg <= Cr76_neg;
		Cr67_msb <= Cr76_msb;
		Cr67_et_zero <= Cr76_et_zero;
		Cr76_pos <= Cr85_pos;	   
		Cr76_neg <= Cr85_neg;
		Cr76_msb <= Cr85_msb;
		Cr76_et_zero <= Cr85_et_zero;
		Cr85_pos <= Cr86_pos;	   
		Cr85_neg <= Cr86_neg;
		Cr85_msb <= Cr86_msb;
		Cr85_et_zero <= Cr86_et_zero;
		Cr86_pos <= Cr77_pos;	   
		Cr86_neg <= Cr77_neg;
		Cr86_msb <= Cr77_msb;
		Cr86_et_zero <= Cr77_et_zero;
		Cr77_pos <= Cr68_pos;	   
		Cr77_neg <= Cr68_neg;
		Cr77_msb <= Cr68_msb;
		Cr77_et_zero <= Cr68_et_zero;
		Cr68_pos <= Cr78_pos;	   
		Cr68_neg <= Cr78_neg;
		Cr68_msb <= Cr78_msb;
		Cr68_et_zero <= Cr78_et_zero;
		Cr78_pos <= Cr87_pos;	   
		Cr78_neg <= Cr87_neg;
		Cr78_msb <= Cr87_msb;
		Cr78_et_zero <= Cr87_et_zero;
		Cr87_pos <= Cr88_pos;	   
		Cr87_neg <= Cr88_neg;
		Cr87_msb <= Cr88_msb;
		Cr87_et_zero <= Cr88_et_zero;
		Cr88_pos <= 0;	   
		Cr88_neg <= 0;
		Cr88_msb <= 0;
		Cr88_et_zero <= 1;
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin 
		Cr11_diff <= 0; Cr11_1 <= 0; 
		end
	else if (enable) begin // Need to sign extend Cr11 to 12 bits
		Cr11_diff <= {Cr11[10], Cr11} - Cr11_previous;
		Cr11_1 <= Cr11[10] ? { 1'b1, Cr11 } : { 1'b0, Cr11 };
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) 
		Cr11_bits_pos <= 0;
	else if (Cr11_1_pos[10] == 1) 
		Cr11_bits_pos <= 11;	
	else if (Cr11_1_pos[9] == 1) 
		Cr11_bits_pos <= 10;
	else if (Cr11_1_pos[8] == 1) 
		Cr11_bits_pos <= 9;
	else if (Cr11_1_pos[7] == 1) 
		Cr11_bits_pos <= 8;
	else if (Cr11_1_pos[6] == 1) 
		Cr11_bits_pos <= 7;
	else if (Cr11_1_pos[5] == 1) 
		Cr11_bits_pos <= 6;
	else if (Cr11_1_pos[4] == 1) 
		Cr11_bits_pos <= 5;
	else if (Cr11_1_pos[3] == 1) 
		Cr11_bits_pos <= 4;
	else if (Cr11_1_pos[2] == 1) 
		Cr11_bits_pos <= 3;
	else if (Cr11_1_pos[1] == 1) 
		Cr11_bits_pos <= 2;
	else if (Cr11_1_pos[0] == 1) 
		Cr11_bits_pos <= 1;
	else 
	 	Cr11_bits_pos <= 0;
end

always_ff @(posedge clk)
begin
	if (rst) 
		Cr11_bits_neg <= 0;
	else if (Cr11_1_neg[10] == 0) 
		Cr11_bits_neg <= 11;	
	else if (Cr11_1_neg[9] == 0) 
		Cr11_bits_neg <= 10;  
	else if (Cr11_1_neg[8] == 0) 
		Cr11_bits_neg <= 9;   
	else if (Cr11_1_neg[7] == 0) 
		Cr11_bits_neg <= 8;   
	else if (Cr11_1_neg[6] == 0) 
		Cr11_bits_neg <= 7;   
	else if (Cr11_1_neg[5] == 0) 
		Cr11_bits_neg <= 6;   
	else if (Cr11_1_neg[4] == 0) 
		Cr11_bits_neg <= 5;   
	else if (Cr11_1_neg[3] == 0) 
		Cr11_bits_neg <= 4;   
	else if (Cr11_1_neg[2] == 0) 
		Cr11_bits_neg <= 3;   
	else if (Cr11_1_neg[1] == 0) 
		Cr11_bits_neg <= 2;   
	else if (Cr11_1_neg[0] == 0) 
		Cr11_bits_neg <= 1;
	else 
	 	Cr11_bits_neg <= 0;
end


always_ff @(posedge clk)
begin
	if (rst) 
		Cr12_bits_pos <= 0;
	else if (Cr12_pos[9] == 1) 
		Cr12_bits_pos <= 10;
	else if (Cr12_pos[8] == 1) 
		Cr12_bits_pos <= 9;
	else if (Cr12_pos[7] == 1) 
		Cr12_bits_pos <= 8;
	else if (Cr12_pos[6] == 1) 
		Cr12_bits_pos <= 7;
	else if (Cr12_pos[5] == 1) 
		Cr12_bits_pos <= 6;
	else if (Cr12_pos[4] == 1) 
		Cr12_bits_pos <= 5;
	else if (Cr12_pos[3] == 1) 
		Cr12_bits_pos <= 4;
	else if (Cr12_pos[2] == 1) 
		Cr12_bits_pos <= 3;
	else if (Cr12_pos[1] == 1) 
		Cr12_bits_pos <= 2;
	else if (Cr12_pos[0] == 1) 
		Cr12_bits_pos <= 1;
	else 
	 	Cr12_bits_pos <= 0;
end

always_ff @(posedge clk)
begin
	if (rst) 
		Cr12_bits_neg <= 0;
	else if (Cr12_neg[9] == 0) 
		Cr12_bits_neg <= 10;  
	else if (Cr12_neg[8] == 0) 
		Cr12_bits_neg <= 9;   
	else if (Cr12_neg[7] == 0) 
		Cr12_bits_neg <= 8;   
	else if (Cr12_neg[6] == 0) 
		Cr12_bits_neg <= 7;   
	else if (Cr12_neg[5] == 0) 
		Cr12_bits_neg <= 6;   
	else if (Cr12_neg[4] == 0) 
		Cr12_bits_neg <= 5;   
	else if (Cr12_neg[3] == 0) 
		Cr12_bits_neg <= 4;   
	else if (Cr12_neg[2] == 0) 
		Cr12_bits_neg <= 3;   
	else if (Cr12_neg[1] == 0) 
		Cr12_bits_neg <= 2;   
	else if (Cr12_neg[0] == 0) 
		Cr12_bits_neg <= 1;
	else 
	 	Cr12_bits_neg <= 0;
end

always_ff @(posedge clk)
begin
	if (rst) begin
		enable_module <= 0; 
		end
	else if (enable) begin
		enable_module <= 1; 
		end
end	 

always_ff @(posedge clk)
begin
	if (rst) begin
		enable_latch_7 <= 0; 
		end
	else if (block_counter == 68)  begin
		enable_latch_7 <= 0; 
		end
	else if (enable_6) begin
		enable_latch_7 <= 1; 
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		enable_latch_8 <= 0; 
		end
	else if (enable_7) begin
		enable_latch_8 <= 1; 
		end
end	

always_ff @(posedge clk)
begin
	if (rst) begin
		enable_1 <= 0; enable_2 <= 0; enable_3 <= 0;
		enable_4 <= 0; enable_5 <= 0; enable_6 <= 0;
		enable_7 <= 0; enable_8 <= 0; enable_9 <= 0;
		enable_10 <= 0; enable_11 <= 0; enable_12 <= 0;
		enable_13 <= 0;
		end
	else begin
		enable_1 <= enable; enable_2 <= enable_1; enable_3 <= enable_2;
		enable_4 <= enable_3; enable_5 <= enable_4; enable_6 <= enable_5;
		enable_7 <= enable_6; enable_8 <= enable_7; enable_9 <= enable_8;
		enable_10 <= enable_9; enable_11 <= enable_10; enable_12 <= enable_11;
		enable_13 <= enable_12;
		end
end	 


always_ff @(posedge clk) begin
    if (rst) begin
        JPEG_bitstream <= 0;
    end
    else if (enable_module) begin
        for (int i = 0; i < 32; i++) begin
            if (rollover_7 || orc_8 <= (31 - i))
                JPEG_bitstream[i] <= JPEG_bs_5[i];
        end
    end
end
endmodule
