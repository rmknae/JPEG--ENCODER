// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This module converts the incoming Y data. The incoming data is unsigned 8 bits, so the data is in the range of 0-255
//    Unlike a typical DCT, the data is not subtracted by 128 to center it around 0,pixel value, a total value can be subtracted at the end 
//    of the first row/column multiply, involving the 8 pixel values and the 8 DCT matrix values.
//    For the other 7 rows of the DCT matrix, the values in each row add up to 0,
//    so it is not necessary to subtract 128 from each Y, Cb, and Cr pixel value.
//
// Author:Rameen
// Date:1st August,2025.

`timescale 1ns / 100ps
`include "dct_constants.svh"

module y_dct(
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic [7:0] data_in,
    output logic [10:0] Z_final[1:8][1:8],
    output logic       output_enable
);
logic [31:0] Z_temp[1:8][1:8];
logic [26:0] Z[1:8][1:8];

logic [24:0] Y_temp_11;
logic [24:0] Y11, Y21, Y31, Y41, Y51, Y61, Y71, Y81, Y11_final;
logic [31:0] Y_temp_21, Y_temp_31, Y_temp_41, Y_temp_51;
logic [31:0] Y_temp_61, Y_temp_71, Y_temp_81;

logic [31:0] Y11_final_2, Y21_final_2, Y11_final_3, Y11_final_4, Y31_final_2, Y41_final_2;
logic [31:0] Y51_final_2, Y61_final_2, Y71_final_2, Y81_final_2;
logic [12:0] Y11_final_1, Y21_final_1, Y31_final_1, Y41_final_1;
logic [12:0] Y51_final_1, Y61_final_1, Y71_final_1, Y81_final_1;
logic [24:0] Y21_final, Y31_final, Y41_final, Y51_final;
logic [24:0] Y61_final, Y71_final, Y81_final;
logic [24:0] Y21_final_prev, Y21_final_diff;
logic [24:0] Y31_final_prev, Y31_final_diff;
logic [24:0] Y41_final_prev, Y41_final_diff;
logic [24:0] Y51_final_prev, Y51_final_diff;
logic [24:0] Y61_final_prev, Y61_final_diff;
logic [24:0] Y71_final_prev, Y71_final_diff;
logic [24:0] Y81_final_prev, Y81_final_diff;

logic [2:0] count;
logic [2:0] count_of, count_of_copy;
logic count_1, count_3, count_4, count_5, count_6, count_7, count_8, enable_1;
logic count_9, count_10;

logic [7:0] data_1;

integer Y2_mul_input, Y3_mul_input, Y4_mul_input, Y5_mul_input;
integer Y6_mul_input, Y7_mul_input, Y8_mul_input;	
integer Ti2_mul_input, Ti3_mul_input, Ti4_mul_input, Ti5_mul_input;
integer Ti6_mul_input, Ti7_mul_input, Ti8_mul_input;

// This block computes partial DCT results for the Y channel.
// On reset → clears Z_temp matrix to 0.
// When enabled (enable_1 & count_8) →
//   Each row i (1–8) uses its Y[i]_final_* value,
//   multiplied with 8 transform coefficients (Ti1..Ti8),
//   filling row i of Z_temp[ ][ ] with products.
always_ff @(posedge clk) begin
    if (rst) begin
        for (int i = 1; i <= 8; i++) begin
            for (int j = 1; j <= 8; j++) begin
                Z_temp[i][j] <= 0;
            end
        end
    end 
    else if (enable_1 & count_8) begin
        Z_temp[1][1] <= Y11_final_4 * Ti1;            Z_temp[1][2] <= Y11_final_4 * Ti2_mul_input;
        Z_temp[1][3] <= Y11_final_4 * Ti3_mul_input;  Z_temp[1][4] <= Y11_final_4 * Ti4_mul_input;
        Z_temp[1][5] <= Y11_final_4 * Ti5_mul_input;  Z_temp[1][6] <= Y11_final_4 * Ti6_mul_input;
        Z_temp[1][7] <= Y11_final_4 * Ti7_mul_input;  Z_temp[1][8] <= Y11_final_4 * Ti8_mul_input;

        Z_temp[2][1] <= Y21_final_2 * Ti1;            Z_temp[2][2] <= Y21_final_2 * Ti2_mul_input;
        Z_temp[2][3] <= Y21_final_2 * Ti3_mul_input;  Z_temp[2][4] <= Y21_final_2 * Ti4_mul_input;
        Z_temp[2][5] <= Y21_final_2 * Ti5_mul_input;  Z_temp[2][6] <= Y21_final_2 * Ti6_mul_input;
        Z_temp[2][7] <= Y21_final_2 * Ti7_mul_input;  Z_temp[2][8] <= Y21_final_2 * Ti8_mul_input;

        Z_temp[3][1] <= Y31_final_2 * Ti1;            Z_temp[3][2] <= Y31_final_2 * Ti2_mul_input;
        Z_temp[3][3] <= Y31_final_2 * Ti3_mul_input;  Z_temp[3][4] <= Y31_final_2 * Ti4_mul_input;
        Z_temp[3][5] <= Y31_final_2 * Ti5_mul_input;  Z_temp[3][6] <= Y31_final_2 * Ti6_mul_input;
        Z_temp[3][7] <= Y31_final_2 * Ti7_mul_input;  Z_temp[3][8] <= Y31_final_2 * Ti8_mul_input;

        Z_temp[4][1] <= Y41_final_2 * Ti1;            Z_temp[4][2] <= Y41_final_2 * Ti2_mul_input;
        Z_temp[4][3] <= Y41_final_2 * Ti3_mul_input;  Z_temp[4][4] <= Y41_final_2 * Ti4_mul_input;
        Z_temp[4][5] <= Y41_final_2 * Ti5_mul_input;  Z_temp[4][6] <= Y41_final_2 * Ti6_mul_input;
        Z_temp[4][7] <= Y41_final_2 * Ti7_mul_input;  Z_temp[4][8] <= Y41_final_2 * Ti8_mul_input;

        Z_temp[5][1] <= Y51_final_2 * Ti1;            Z_temp[5][2] <= Y51_final_2 * Ti2_mul_input;
        Z_temp[5][3] <= Y51_final_2 * Ti3_mul_input;  Z_temp[5][4] <= Y51_final_2 * Ti4_mul_input;
        Z_temp[5][5] <= Y51_final_2 * Ti5_mul_input;  Z_temp[5][6] <= Y51_final_2 * Ti6_mul_input;
        Z_temp[5][7] <= Y51_final_2 * Ti7_mul_input;  Z_temp[5][8] <= Y51_final_2 * Ti8_mul_input;

        Z_temp[6][1] <= Y61_final_2 * Ti1;            Z_temp[6][2] <= Y61_final_2 * Ti2_mul_input;
        Z_temp[6][3] <= Y61_final_2 * Ti3_mul_input;  Z_temp[6][4] <= Y61_final_2 * Ti4_mul_input;
        Z_temp[6][5] <= Y61_final_2 * Ti5_mul_input;  Z_temp[6][6] <= Y61_final_2 * Ti6_mul_input;
        Z_temp[6][7] <= Y61_final_2 * Ti7_mul_input;  Z_temp[6][8] <= Y61_final_2 * Ti8_mul_input;

        Z_temp[7][1] <= Y71_final_2 * Ti1;            Z_temp[7][2] <= Y71_final_2 * Ti2_mul_input;
        Z_temp[7][3] <= Y71_final_2 * Ti3_mul_input;  Z_temp[7][4] <= Y71_final_2 * Ti4_mul_input;
        Z_temp[7][5] <= Y71_final_2 * Ti5_mul_input;  Z_temp[7][6] <= Y71_final_2 * Ti6_mul_input;
        Z_temp[7][7] <= Y71_final_2 * Ti7_mul_input;  Z_temp[7][8] <= Y71_final_2 * Ti8_mul_input;

        Z_temp[8][1] <= Y81_final_2 * Ti1;            Z_temp[8][2] <= Y81_final_2 * Ti2_mul_input;
        Z_temp[8][3] <= Y81_final_2 * Ti3_mul_input;  Z_temp[8][4] <= Y81_final_2 * Ti4_mul_input;
        Z_temp[8][5] <= Y81_final_2 * Ti5_mul_input;  Z_temp[8][6] <= Y81_final_2 * Ti6_mul_input;
        Z_temp[8][7] <= Y81_final_2 * Ti7_mul_input;  Z_temp[8][8] <= Y81_final_2 * Ti8_mul_input;
    end
end

// This block manages 8x8 DCT coefficients:
// - rst : clears all Z values
// - count_8 && count_of==1 : clears Z for new block
// - enable && count_9 : accumulates partial results (Z_temp) into Z
always_ff @(posedge clk) begin
    if (rst) begin
        foreach (Z[i,j]) begin
            Z[i][j] <= '0;
        end
    end 
    else if (count_8 & (count_of == 1)) begin
        foreach (Z[i,j]) begin
            Z[i][j] <= '0;
        end
    end 
    else if (enable & count_9) begin
        foreach (Z[i,j]) begin
            Z[i][j] <= Z_temp[i][j] + Z[i][j];
        end
    end
end

// This block finalizes DCT coefficients:
// - rst : clears all Z_final values
// - count_10 && count_of==0 : extracts 11-bit results from Z (with rounding)
always_ff @(posedge clk) begin
    if (rst) begin
        foreach (Z_final[i,j]) begin
            Z_final[i][j] <= '0;
        end
    end 
    else if (count_10 && count_of == 0) begin
        foreach (Z_final[i,j]) begin
            Z_final[i][j] <= Z[i][j][15] ? Z[i][j][26:16] + 1 : Z[i][j][26:16];
        end
    end
end


// output_enable signals the next block, the quantizer, that the input data is ready
always_ff @(posedge clk)
begin
	if (rst) 
 		output_enable <= 0;
	else if (!enable_1)
		output_enable <= 0;
	else if (count_10 == 0 | count_of)
		output_enable <= 0;
	else if (count_10 & count_of == 0)
		output_enable <= 1;
end
always_ff @(posedge clk)
begin
	if (rst)
		Y_temp_11 <= 0;
	else if (enable)
		Y_temp_11 <= data_in * T1; 
end  

always_ff @(posedge clk)
begin
	if (rst)
		Y11 <= 0;
	else if (count == 1 & enable == 1)
		Y11 <= Y_temp_11;
	else if (enable)
		Y11 <= Y_temp_11 + Y11;
end

always_ff @(posedge clk)
begin
	if (rst) begin
		Y_temp_21 <= 0;
		Y_temp_31 <= 0;
		Y_temp_41 <= 0;
		Y_temp_51 <= 0;
		Y_temp_61 <= 0;
		Y_temp_71 <= 0;
		Y_temp_81 <= 0;
		end
	else if (!enable_1) begin
		Y_temp_21 <= 0;
		Y_temp_31 <= 0;
		Y_temp_41 <= 0;
		Y_temp_51 <= 0;
		Y_temp_61 <= 0;
		Y_temp_71 <= 0;
		Y_temp_81 <= 0;
		end
	else if (enable_1) begin
		Y_temp_21 <= data_1 * Y2_mul_input; 
		Y_temp_31 <= data_1 * Y3_mul_input; 
		Y_temp_41 <= data_1 * Y4_mul_input; 
		Y_temp_51 <= data_1 * Y5_mul_input; 
		Y_temp_61 <= data_1 * Y6_mul_input; 
		Y_temp_71 <= data_1 * Y7_mul_input; 
		Y_temp_81 <= data_1 * Y8_mul_input; 
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		Y21 <= 0;
		Y31 <= 0;
		Y41 <= 0;
		Y51 <= 0;
		Y61 <= 0;
		Y71 <= 0;
		Y81 <= 0;
		end
	else if (!enable_1) begin
		Y21 <= 0;
		Y31 <= 0;
		Y41 <= 0;
		Y51 <= 0;
		Y61 <= 0;
		Y71 <= 0;
		Y81 <= 0;
		end
	else if (enable_1) begin
		Y21 <= Y_temp_21 + Y21;
		Y31 <= Y_temp_31 + Y31;
		Y41 <= Y_temp_41 + Y41;
		Y51 <= Y_temp_51 + Y51;
		Y61 <= Y_temp_61 + Y61;
		Y71 <= Y_temp_71 + Y71;
		Y81 <= Y_temp_81 + Y81;
		end
end 

always_ff @(posedge clk)
begin
	if (rst) begin
 		count <= 0; count_3 <= 0; count_4 <= 0; count_5 <= 0;
 		count_6 <= 0; count_7 <= 0; count_8 <= 0; count_9 <= 0;
 		count_10 <= 0;
		end
	else if (!enable) begin
		count <= 0; count_3 <= 0; count_4 <= 0; count_5 <= 0;
 		count_6 <= 0; count_7 <= 0; count_8 <= 0; count_9 <= 0;
 		count_10 <= 0;
		end
	else if (enable) begin
		count <= count + 1; count_3 <= count_1; count_4 <= count_3;
		count_5 <= count_4; count_6 <= count_5; count_7 <= count_6;
		count_8 <= count_7; count_9 <= count_8; count_10 <= count_9;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		count_1 <= 0;
		end
	else if (count != 7 | !enable) begin
		count_1 <= 0;
		end
	else if (count == 7) begin
		count_1 <= 1;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
 		count_of <= 0;
 		count_of_copy <= 0;
 		end
	else if (!enable) begin
		count_of <= 0;
		count_of_copy <= 0;
		end
	else if (count_1 == 1) begin
		count_of <= count_of + 1;
		count_of_copy <= count_of_copy + 1;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
 		Y11_final <= 0;
		end
	else if (count_3 & enable_1) begin
		Y11_final <= Y11 - 25'd5932032;  
		/* The Y values weren't centered on 0 before doing the DCT	
		 128 needs to be subtracted from each Y value before, or in this
		 case, 362 is subtracted from the total, because this is the 
		 total obtained by subtracting 128 from each element 
		 and then multiplying by the weight
		 assigned by the DCT matrix : 128*8*5793 = 5932032
		 This is only needed for the first row, the values in the rest of
		 the rows add up to 0 */
		end
end


always_ff @(posedge clk)
begin
	if (rst) begin
 		Y21_final <= 0; Y21_final_prev <= 0;
 		Y31_final <= 0; Y31_final_prev <= 0;
 		Y41_final <= 0; Y41_final_prev <= 0;
 		Y51_final <= 0; Y51_final_prev <= 0;
 		Y61_final <= 0; Y61_final_prev <= 0;
 		Y71_final <= 0; Y71_final_prev <= 0;
 		Y81_final <= 0; Y81_final_prev <= 0;
		end
	else if (!enable_1) begin
		Y21_final <= 0; Y21_final_prev <= 0;
 		Y31_final <= 0; Y31_final_prev <= 0;
 		Y41_final <= 0; Y41_final_prev <= 0;
 		Y51_final <= 0; Y51_final_prev <= 0;
 		Y61_final <= 0; Y61_final_prev <= 0;
 		Y71_final <= 0; Y71_final_prev <= 0;
 		Y81_final <= 0; Y81_final_prev <= 0;
		end
	else if (count_4 & enable_1) begin
		Y21_final <= Y21; Y21_final_prev <= Y21_final;
		Y31_final <= Y31; Y31_final_prev <= Y31_final;
		Y41_final <= Y41; Y41_final_prev <= Y41_final;
		Y51_final <= Y51; Y51_final_prev <= Y51_final;
		Y61_final <= Y61; Y61_final_prev <= Y61_final;
		Y71_final <= Y71; Y71_final_prev <= Y71_final;
		Y81_final <= Y81; Y81_final_prev <= Y81_final;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
 		Y21_final_diff <= 0; Y31_final_diff <= 0;
 		Y41_final_diff <= 0; Y51_final_diff <= 0;
 		Y61_final_diff <= 0; Y71_final_diff <= 0;
 		Y81_final_diff <= 0;	
		end
	else if (count_5 & enable_1) begin 
		Y21_final_diff <= Y21_final - Y21_final_prev;	
		Y31_final_diff <= Y31_final - Y31_final_prev;	
		Y41_final_diff <= Y41_final - Y41_final_prev;	
		Y51_final_diff <= Y51_final - Y51_final_prev;	
		Y61_final_diff <= Y61_final - Y61_final_prev;	
		Y71_final_diff <= Y71_final - Y71_final_prev;	
		Y81_final_diff <= Y81_final - Y81_final_prev;		
		end
end
always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y2_mul_input <= T21;
	3'b001:		Y2_mul_input <= T22;
	3'b010:		Y2_mul_input <= T23;
	3'b011:		Y2_mul_input <= T24;
	3'b100:		Y2_mul_input <= T25;
	3'b101:		Y2_mul_input <= T26;
	3'b110:		Y2_mul_input <= T27;
	3'b111:		Y2_mul_input <= T28;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y3_mul_input <= T31;
	3'b001:		Y3_mul_input <= T32;
	3'b010:		Y3_mul_input <= T33;
	3'b011:		Y3_mul_input <= T34;
	3'b100:		Y3_mul_input <= T34;
	3'b101:		Y3_mul_input <= T33;
	3'b110:		Y3_mul_input <= T32;
	3'b111:		Y3_mul_input <= T31;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y4_mul_input <= T22;
	3'b001:		Y4_mul_input <= T25;
	3'b010:		Y4_mul_input <= T28;
	3'b011:		Y4_mul_input <= T26;
	3'b100:		Y4_mul_input <= T23;
	3'b101:		Y4_mul_input <= T21;
	3'b110:		Y4_mul_input <= T24;
	3'b111:		Y4_mul_input <= T27;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y5_mul_input <= T1;
	3'b001:		Y5_mul_input <= T52;
	3'b010:		Y5_mul_input <= T52;
	3'b011:		Y5_mul_input <= T1;
	3'b100:		Y5_mul_input <= T1;
	3'b101:		Y5_mul_input <= T52;
	3'b110:		Y5_mul_input <= T52;
	3'b111:		Y5_mul_input <= T1;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y6_mul_input <= T23;
	3'b001:		Y6_mul_input <= T28;
	3'b010:		Y6_mul_input <= T24;
	3'b011:		Y6_mul_input <= T22;
	3'b100:		Y6_mul_input <= T27;
	3'b101:		Y6_mul_input <= T25;
	3'b110:		Y6_mul_input <= T21;
	3'b111:		Y6_mul_input <= T26;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y7_mul_input <= T32;
	3'b001:		Y7_mul_input <= T34;
	3'b010:		Y7_mul_input <= T31;
	3'b011:		Y7_mul_input <= T33;
	3'b100:		Y7_mul_input <= T33;
	3'b101:		Y7_mul_input <= T31;
	3'b110:		Y7_mul_input <= T34;
	3'b111:		Y7_mul_input <= T32;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Y8_mul_input <= T24;
	3'b001:		Y8_mul_input <= T26;
	3'b010:		Y8_mul_input <= T22;
	3'b011:		Y8_mul_input <= T28;
	3'b100:		Y8_mul_input <= T21;
	3'b101:		Y8_mul_input <= T27;
	3'b110:		Y8_mul_input <= T23;
	3'b111:		Y8_mul_input <= T25;
	endcase
end

// Inverse DCT matrix entries
always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti2_mul_input <= Ti28;
	3'b001:		Ti2_mul_input <= Ti21;
	3'b010:		Ti2_mul_input <= Ti22;
	3'b011:		Ti2_mul_input <= Ti23;
	3'b100:		Ti2_mul_input <= Ti24;
	3'b101:		Ti2_mul_input <= Ti25;
	3'b110:		Ti2_mul_input <= Ti26;
	3'b111:		Ti2_mul_input <= Ti27;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti3_mul_input <= Ti31;
	3'b001:		Ti3_mul_input <= Ti31;
	3'b010:		Ti3_mul_input <= Ti32;
	3'b011:		Ti3_mul_input <= Ti33;
	3'b100:		Ti3_mul_input <= Ti34;
	3'b101:		Ti3_mul_input <= Ti34;
	3'b110:		Ti3_mul_input <= Ti33;
	3'b111:		Ti3_mul_input <= Ti32;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti4_mul_input <= Ti27;
	3'b001:		Ti4_mul_input <= Ti22;
	3'b010:		Ti4_mul_input <= Ti25;
	3'b011:		Ti4_mul_input <= Ti28;
	3'b100:		Ti4_mul_input <= Ti26;
	3'b101:		Ti4_mul_input <= Ti23;
	3'b110:		Ti4_mul_input <= Ti21;
	3'b111:		Ti4_mul_input <= Ti24;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti5_mul_input <= Ti1;
	3'b001:		Ti5_mul_input <= Ti1;
	3'b010:		Ti5_mul_input <= Ti52;
	3'b011:		Ti5_mul_input <= Ti52;
	3'b100:		Ti5_mul_input <= Ti1;
	3'b101:		Ti5_mul_input <= Ti1;
	3'b110:		Ti5_mul_input <= Ti52;
	3'b111:		Ti5_mul_input <= Ti52;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti6_mul_input <= Ti26;
	3'b001:		Ti6_mul_input <= Ti23;
	3'b010:		Ti6_mul_input <= Ti28;
	3'b011:		Ti6_mul_input <= Ti24;
	3'b100:		Ti6_mul_input <= Ti22;
	3'b101:		Ti6_mul_input <= Ti27;
	3'b110:		Ti6_mul_input <= Ti25;
	3'b111:		Ti6_mul_input <= Ti21;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti7_mul_input <= Ti32;
	3'b001:		Ti7_mul_input <= Ti32;
	3'b010:		Ti7_mul_input <= Ti34;
	3'b011:		Ti7_mul_input <= Ti31;
	3'b100:		Ti7_mul_input <= Ti33;
	3'b101:		Ti7_mul_input <= Ti33;
	3'b110:		Ti7_mul_input <= Ti31;
	3'b111:		Ti7_mul_input <= Ti34;
	endcase
end

always_ff @(posedge clk)
begin
	case (count_of_copy)
	3'b000:		Ti8_mul_input <= Ti25;
	3'b001:		Ti8_mul_input <= Ti24;
	3'b010:		Ti8_mul_input <= Ti26;
	3'b011:		Ti8_mul_input <= Ti22;
	3'b100:		Ti8_mul_input <= Ti28;
	3'b101:		Ti8_mul_input <= Ti21;
	3'b110:		Ti8_mul_input <= Ti27;
	3'b111:		Ti8_mul_input <= Ti23;
	endcase
end

// Rounding stage
always_ff @(posedge clk)
begin
	if (rst) begin
 		data_1 <= 0;
 		Y11_final_1 <= 0; Y21_final_1 <= 0; Y31_final_1 <= 0; Y41_final_1 <= 0;
		Y51_final_1 <= 0; Y61_final_1 <= 0; Y71_final_1 <= 0; Y81_final_1 <= 0;
		Y11_final_2 <= 0; Y21_final_2 <= 0; Y31_final_2 <= 0; Y41_final_2 <= 0;
		Y51_final_2 <= 0; Y61_final_2 <= 0; Y71_final_2 <= 0; Y81_final_2 <= 0;
		Y11_final_3 <= 0; Y11_final_4 <= 0;
		end
	else if (enable) begin
		data_1 <= data_in;  
		Y11_final_1 <= Y11_final[11] ? Y11_final[24:12] + 1 : Y11_final[24:12];
		Y11_final_2[31:13] <= Y11_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y11_final_2[12:0] <= Y11_final_1;
		// Need to sign extend Y11_final_1 and the other logicisters to store a negative 
		// number as a twos complement number.  If you don't sign extend, then a negative number
		// will be stored incorrectly as a positive number.  For example, -215 would be stored
		// as 1833 without sign extending
		Y11_final_3 <= Y11_final_2;
		Y11_final_4 <= Y11_final_3;
		Y21_final_1 <= Y21_final_diff[11] ? Y21_final_diff[24:12] + 1 : Y21_final_diff[24:12];
		Y21_final_2[31:13] <= Y21_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y21_final_2[12:0] <= Y21_final_1;
		Y31_final_1 <= Y31_final_diff[11] ? Y31_final_diff[24:12] + 1 : Y31_final_diff[24:12];
		Y31_final_2[31:13] <= Y31_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y31_final_2[12:0] <= Y31_final_1;
		Y41_final_1 <= Y41_final_diff[11] ? Y41_final_diff[24:12] + 1 : Y41_final_diff[24:12];
		Y41_final_2[31:13] <= Y41_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y41_final_2[12:0] <= Y41_final_1;
		Y51_final_1 <= Y51_final_diff[11] ? Y51_final_diff[24:12] + 1 : Y51_final_diff[24:12];
		Y51_final_2[31:13] <= Y51_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y51_final_2[12:0] <= Y51_final_1;
		Y61_final_1 <= Y61_final_diff[11] ? Y61_final_diff[24:12] + 1 : Y61_final_diff[24:12];
		Y61_final_2[31:13] <= Y61_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y61_final_2[12:0] <= Y61_final_1;
		Y71_final_1 <= Y71_final_diff[11] ? Y71_final_diff[24:12] + 1 : Y71_final_diff[24:12];
		Y71_final_2[31:13] <= Y71_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y71_final_2[12:0] <= Y71_final_1;
		Y81_final_1 <= Y81_final_diff[11] ? Y81_final_diff[24:12] + 1 : Y81_final_diff[24:12];
		Y81_final_2[31:13] <= Y81_final_1[12] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Y81_final_2[12:0] <= Y81_final_1;
		// The bit in place 11 is the fraction part, for rounding purposes
		// if it is 1, then you need to add 1 to the bits in 24-12, 
		// if bit 11 is 0, then the bits in 24-12 won't change
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
 		enable_1 <= 0; 
		end
	else begin
		enable_1 <= enable;
		end
end

endmodule