// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This module performs a Discrete Cosine Transform (DCT) on 8x8 blocks of Cb (Chroma Blue) data.
//    It uses short integers for calculations and coefficients. Unlike typical DCTs,
//    it handles the DC offset by a final subtraction on the first coefficient,
//    rather than pre-subtracting 128 from each input pixel.
//
// Author:Rameen
// Date:11th July,2025.


`timescale 1ns / 100ps
`include "dct_constants.svh"

module cb_dct(
    input  logic       clk, rst, enable,
    input  logic [7:0] data_in,
    output logic [10:0] Z_final[1:8][1:8],
    output logic       output_enable
);

// Z variables are defined here 
logic [31:0] Z_temp[1:8][1:8];
logic [24:0] Z[1:8][1:8];

logic [24:0] Cb_temp_11;
logic [24:0] Cb11, Cb21, Cb31, Cb41, Cb51, Cb61, Cb71, Cb81, Cb11_final;

logic [31:0] Cb_temp_21, Cb_temp_31, Cb_temp_41, Cb_temp_51;
logic [31:0] Cb_temp_61, Cb_temp_71, Cb_temp_81;

logic [31:0] Cb11_final_2, Cb21_final_2, Cb11_final_3, Cb11_final_4;
logic [31:0] Cb31_final_2, Cb41_final_2, Cb51_final_2, Cb61_final_2, Cb71_final_2, Cb81_final_2;

logic [10:0] Cb11_final_1, Cb21_final_1, Cb31_final_1, Cb41_final_1;
logic [10:0] Cb51_final_1, Cb61_final_1, Cb71_final_1, Cb81_final_1;

logic [24:0] Cb21_final, Cb31_final, Cb41_final, Cb51_final;
logic [24:0] Cb61_final, Cb71_final, Cb81_final;

logic [24:0] Cb21_final_prev, Cb21_final_diff;
logic [24:0] Cb31_final_prev, Cb31_final_diff;
logic [24:0] Cb41_final_prev, Cb41_final_diff;
logic [24:0] Cb51_final_prev, Cb51_final_diff;
logic [24:0] Cb61_final_prev, Cb61_final_diff;
logic [24:0] Cb71_final_prev, Cb71_final_diff;
logic [24:0] Cb81_final_prev, Cb81_final_diff;

logic [2:0] count;
logic [2:0] count_of, count_of_copy;
logic count_1, count_3, count_4, count_5, count_6, count_7, count_8, enable_1;
logic count_9, count_10;

logic [7:0] data_1;

integer Cb2_mul_input, Cb3_mul_input, Cb4_mul_input, Cb5_mul_input;
integer Cb6_mul_input, Cb7_mul_input, Cb8_mul_input;	
integer Ti2_mul_input, Ti3_mul_input, Ti4_mul_input, Ti5_mul_input;
integer Ti6_mul_input, Ti7_mul_input, Ti8_mul_input;



// This block computes partial DCT results for the Cb channel.
// On reset → clears Z_temp matrix to 0.
// When enabled (enable_1 & count_8) →
//   Each row i (1–8) uses its Cb[i]_final_* value,
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
        Z_temp[1][1] <= Cb11_final_4 * Ti1;            Z_temp[1][2] <= Cb11_final_4 * Ti2_mul_input;
        Z_temp[1][3] <= Cb11_final_4 * Ti3_mul_input;  Z_temp[1][4] <= Cb11_final_4 * Ti4_mul_input;
        Z_temp[1][5] <= Cb11_final_4 * Ti5_mul_input;  Z_temp[1][6] <= Cb11_final_4 * Ti6_mul_input;
        Z_temp[1][7] <= Cb11_final_4 * Ti7_mul_input;  Z_temp[1][8] <= Cb11_final_4 * Ti8_mul_input;

        Z_temp[2][1] <= Cb21_final_2 * Ti1;            Z_temp[2][2] <= Cb21_final_2 * Ti2_mul_input;
        Z_temp[2][3] <= Cb21_final_2 * Ti3_mul_input;  Z_temp[2][4] <= Cb21_final_2 * Ti4_mul_input;
        Z_temp[2][5] <= Cb21_final_2 * Ti5_mul_input;  Z_temp[2][6] <= Cb21_final_2 * Ti6_mul_input;
        Z_temp[2][7] <= Cb21_final_2 * Ti7_mul_input;  Z_temp[2][8] <= Cb21_final_2 * Ti8_mul_input;

        Z_temp[3][1] <= Cb31_final_2 * Ti1;            Z_temp[3][2] <= Cb31_final_2 * Ti2_mul_input;
        Z_temp[3][3] <= Cb31_final_2 * Ti3_mul_input;  Z_temp[3][4] <= Cb31_final_2 * Ti4_mul_input;
        Z_temp[3][5] <= Cb31_final_2 * Ti5_mul_input;  Z_temp[3][6] <= Cb31_final_2 * Ti6_mul_input;
        Z_temp[3][7] <= Cb31_final_2 * Ti7_mul_input;  Z_temp[3][8] <= Cb31_final_2 * Ti8_mul_input;

        Z_temp[4][1] <= Cb41_final_2 * Ti1;            Z_temp[4][2] <= Cb41_final_2 * Ti2_mul_input;
        Z_temp[4][3] <= Cb41_final_2 * Ti3_mul_input;  Z_temp[4][4] <= Cb41_final_2 * Ti4_mul_input;
        Z_temp[4][5] <= Cb41_final_2 * Ti5_mul_input;  Z_temp[4][6] <= Cb41_final_2 * Ti6_mul_input;
        Z_temp[4][7] <= Cb41_final_2 * Ti7_mul_input;  Z_temp[4][8] <= Cb41_final_2 * Ti8_mul_input;

        Z_temp[5][1] <= Cb51_final_2 * Ti1;            Z_temp[5][2] <= Cb51_final_2 * Ti2_mul_input;
        Z_temp[5][3] <= Cb51_final_2 * Ti3_mul_input;  Z_temp[5][4] <= Cb51_final_2 * Ti4_mul_input;
        Z_temp[5][5] <= Cb51_final_2 * Ti5_mul_input;  Z_temp[5][6] <= Cb51_final_2 * Ti6_mul_input;
        Z_temp[5][7] <= Cb51_final_2 * Ti7_mul_input;  Z_temp[5][8] <= Cb51_final_2 * Ti8_mul_input;

        Z_temp[6][1] <= Cb61_final_2 * Ti1;            Z_temp[6][2] <= Cb61_final_2 * Ti2_mul_input;
        Z_temp[6][3] <= Cb61_final_2 * Ti3_mul_input;  Z_temp[6][4] <= Cb61_final_2 * Ti4_mul_input;
        Z_temp[6][5] <= Cb61_final_2 * Ti5_mul_input;  Z_temp[6][6] <= Cb61_final_2 * Ti6_mul_input;
        Z_temp[6][7] <= Cb61_final_2 * Ti7_mul_input;  Z_temp[6][8] <= Cb61_final_2 * Ti8_mul_input;

        Z_temp[7][1] <= Cb71_final_2 * Ti1;            Z_temp[7][2] <= Cb71_final_2 * Ti2_mul_input;
        Z_temp[7][3] <= Cb71_final_2 * Ti3_mul_input;  Z_temp[7][4] <= Cb71_final_2 * Ti4_mul_input;
        Z_temp[7][5] <= Cb71_final_2 * Ti5_mul_input;  Z_temp[7][6] <= Cb71_final_2 * Ti6_mul_input;
        Z_temp[7][7] <= Cb71_final_2 * Ti7_mul_input;  Z_temp[7][8] <= Cb71_final_2 * Ti8_mul_input;

        Z_temp[8][1] <= Cb81_final_2 * Ti1;            Z_temp[8][2] <= Cb81_final_2 * Ti2_mul_input;
        Z_temp[8][3] <= Cb81_final_2 * Ti3_mul_input;  Z_temp[8][4] <= Cb81_final_2 * Ti4_mul_input;
        Z_temp[8][5] <= Cb81_final_2 * Ti5_mul_input;  Z_temp[8][6] <= Cb81_final_2 * Ti6_mul_input;
        Z_temp[8][7] <= Cb81_final_2 * Ti7_mul_input;  Z_temp[8][8] <= Cb81_final_2 * Ti8_mul_input;
    end
end


// This block manages 8x8 DCT coefficients:
// - rst : clears all Z values
// - count_8 && count_of==1 : clears Z for new block
// - enable && count_9 : accumulates partial results (Z_temp) into Z

always_ff @(posedge clk) begin
    if (rst) begin
        // Reset all Z matrix elements to 0
        foreach (Z[i,j]) begin
            Z[i][j] <= '0;
        end
    end 
    else if (count_8 & (count_of == 1)) begin
        // Clear Z when count_8 and count_of=1
        foreach (Z[i,j]) begin
            Z[i][j] <= '0;
        end
    end 
    else if (enable & count_9) begin
        // Accumulate results into Z
        foreach (Z[i,j]) begin
            Z[i][j] <= Z_temp[i][j] + Z[i][j];
        end
    end
end




always_ff @(posedge clk) begin
    if (rst) begin
        foreach (Z_final[i, j]) 
            Z_final[i][j] <= '0;
    end 
    else if (count_10 && count_of == 0) begin
        foreach (Z_final[i, j]) begin
            Z_final[i][j] <= Z[i][j][13] ? Z[i][j][24:14] + 1
                                         : Z[i][j][24:14];
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
		Cb_temp_11 <= 0;
	else if (enable)
		Cb_temp_11 <= data_in * T1; 
end  

always_ff @(posedge clk)
begin
	if (rst)
		Cb11 <= 0;
	else if (count == 1 & enable == 1)
		Cb11 <= Cb_temp_11;
	else if (enable)
		Cb11 <= Cb_temp_11 + Cb11;
end

always_ff @(posedge clk)
begin
	if (rst) begin
		Cb_temp_21 <= 0;
		Cb_temp_31 <= 0;
		Cb_temp_41 <= 0;
		Cb_temp_51 <= 0;
		Cb_temp_61 <= 0;
		Cb_temp_71 <= 0;
		Cb_temp_81 <= 0;
		end
	else if (!enable_1) begin
		Cb_temp_21 <= 0;
		Cb_temp_31 <= 0;
		Cb_temp_41 <= 0;
		Cb_temp_51 <= 0;
		Cb_temp_61 <= 0;
		Cb_temp_71 <= 0;
		Cb_temp_81 <= 0;
		end
	else if (enable_1) begin
		Cb_temp_21 <= data_1 * Cb2_mul_input; 
		Cb_temp_31 <= data_1 * Cb3_mul_input; 
		Cb_temp_41 <= data_1 * Cb4_mul_input; 
		Cb_temp_51 <= data_1 * Cb5_mul_input; 
		Cb_temp_61 <= data_1 * Cb6_mul_input; 
		Cb_temp_71 <= data_1 * Cb7_mul_input; 
		Cb_temp_81 <= data_1 * Cb8_mul_input; 
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
		Cb21 <= 0;
		Cb31 <= 0;
		Cb41 <= 0;
		Cb51 <= 0;
		Cb61 <= 0;
		Cb71 <= 0;
		Cb81 <= 0;
		end
	else if (!enable_1) begin
		Cb21 <= 0;
		Cb31 <= 0;
		Cb41 <= 0;
		Cb51 <= 0;
		Cb61 <= 0;
		Cb71 <= 0;
		Cb81 <= 0;
		end
	else if (enable_1) begin
		Cb21 <= Cb_temp_21 + Cb21;
		Cb31 <= Cb_temp_31 + Cb31;
		Cb41 <= Cb_temp_41 + Cb41;
		Cb51 <= Cb_temp_51 + Cb51;
		Cb61 <= Cb_temp_61 + Cb61;
		Cb71 <= Cb_temp_71 + Cb71;
		Cb81 <= Cb_temp_81 + Cb81;
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
 		Cb11_final <= 0;
		end
	else if (count_3 & enable_1) begin
		Cb11_final <= Cb11 - 25'd5932032;  
		/* The Cb values weren't centered on 0 before doing the DCT	
		 128 needs to be subtracted from each Cb value before, or in this
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
 		Cb21_final <= 0; Cb21_final_prev <= 0;
 		Cb31_final <= 0; Cb31_final_prev <= 0;
 		Cb41_final <= 0; Cb41_final_prev <= 0;
 		Cb51_final <= 0; Cb51_final_prev <= 0;
 		Cb61_final <= 0; Cb61_final_prev <= 0;
 		Cb71_final <= 0; Cb71_final_prev <= 0;
 		Cb81_final <= 0; Cb81_final_prev <= 0;
		end
	else if (!enable_1) begin
		Cb21_final <= 0; Cb21_final_prev <= 0;
 		Cb31_final <= 0; Cb31_final_prev <= 0;
 		Cb41_final <= 0; Cb41_final_prev <= 0;
 		Cb51_final <= 0; Cb51_final_prev <= 0;
 		Cb61_final <= 0; Cb61_final_prev <= 0;
 		Cb71_final <= 0; Cb71_final_prev <= 0;
 		Cb81_final <= 0; Cb81_final_prev <= 0;
		end
	else if (count_4 & enable_1) begin
		Cb21_final <= Cb21; Cb21_final_prev <= Cb21_final;
		Cb31_final <= Cb31; Cb31_final_prev <= Cb31_final;
		Cb41_final <= Cb41; Cb41_final_prev <= Cb41_final;
		Cb51_final <= Cb51; Cb51_final_prev <= Cb51_final;
		Cb61_final <= Cb61; Cb61_final_prev <= Cb61_final;
		Cb71_final <= Cb71; Cb71_final_prev <= Cb71_final;
		Cb81_final <= Cb81; Cb81_final_prev <= Cb81_final;
		end
end

always_ff @(posedge clk)
begin
	if (rst) begin
 		Cb21_final_diff <= 0; Cb31_final_diff <= 0;
 		Cb41_final_diff <= 0; Cb51_final_diff <= 0;
 		Cb61_final_diff <= 0; Cb71_final_diff <= 0;
 		Cb81_final_diff <= 0;	
		end
	else if (count_5 & enable_1) begin 
		Cb21_final_diff <= Cb21_final - Cb21_final_prev;	
		Cb31_final_diff <= Cb31_final - Cb31_final_prev;	
		Cb41_final_diff <= Cb41_final - Cb41_final_prev;	
		Cb51_final_diff <= Cb51_final - Cb51_final_prev;	
		Cb61_final_diff <= Cb61_final - Cb61_final_prev;	
		Cb71_final_diff <= Cb71_final - Cb71_final_prev;	
		Cb81_final_diff <= Cb81_final - Cb81_final_prev;		
		end
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb2_mul_input <= T21;
	3'b001:		Cb2_mul_input <= T22;
	3'b010:		Cb2_mul_input <= T23;
	3'b011:		Cb2_mul_input <= T24;
	3'b100:		Cb2_mul_input <= T25;
	3'b101:		Cb2_mul_input <= T26;
	3'b110:		Cb2_mul_input <= T27;
	3'b111:		Cb2_mul_input <= T28;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb3_mul_input <= T31;
	3'b001:		Cb3_mul_input <= T32;
	3'b010:		Cb3_mul_input <= T33;
	3'b011:		Cb3_mul_input <= T34;
	3'b100:		Cb3_mul_input <= T34;
	3'b101:		Cb3_mul_input <= T33;
	3'b110:		Cb3_mul_input <= T32;
	3'b111:		Cb3_mul_input <= T31;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb4_mul_input <= T22;
	3'b001:		Cb4_mul_input <= T25;
	3'b010:		Cb4_mul_input <= T28;
	3'b011:		Cb4_mul_input <= T26;
	3'b100:		Cb4_mul_input <= T23;
	3'b101:		Cb4_mul_input <= T21;
	3'b110:		Cb4_mul_input <= T24;
	3'b111:		Cb4_mul_input <= T27;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb5_mul_input <= T1;
	3'b001:		Cb5_mul_input <= T52;
	3'b010:		Cb5_mul_input <= T52;
	3'b011:		Cb5_mul_input <= T1;
	3'b100:		Cb5_mul_input <= T1;
	3'b101:		Cb5_mul_input <= T52;
	3'b110:		Cb5_mul_input <= T52;
	3'b111:		Cb5_mul_input <= T1;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb6_mul_input <= T23;
	3'b001:		Cb6_mul_input <= T28;
	3'b010:		Cb6_mul_input <= T24;
	3'b011:		Cb6_mul_input <= T22;
	3'b100:		Cb6_mul_input <= T27;
	3'b101:		Cb6_mul_input <= T25;
	3'b110:		Cb6_mul_input <= T21;
	3'b111:		Cb6_mul_input <= T26;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb7_mul_input <= T32;
	3'b001:		Cb7_mul_input <= T34;
	3'b010:		Cb7_mul_input <= T31;
	3'b011:		Cb7_mul_input <= T33;
	3'b100:		Cb7_mul_input <= T33;
	3'b101:		Cb7_mul_input <= T31;
	3'b110:		Cb7_mul_input <= T34;
	3'b111:		Cb7_mul_input <= T32;
	endcase
end

always_ff @(posedge clk)
begin
	case (count)
	3'b000:		Cb8_mul_input <= T24;
	3'b001:		Cb8_mul_input <= T26;
	3'b010:		Cb8_mul_input <= T22;
	3'b011:		Cb8_mul_input <= T28;
	3'b100:		Cb8_mul_input <= T21;
	3'b101:		Cb8_mul_input <= T27;
	3'b110:		Cb8_mul_input <= T23;
	3'b111:		Cb8_mul_input <= T25;
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
 		Cb11_final_1 <= 0; Cb21_final_1 <= 0; Cb31_final_1 <= 0; Cb41_final_1 <= 0;
		Cb51_final_1 <= 0; Cb61_final_1 <= 0; Cb71_final_1 <= 0; Cb81_final_1 <= 0;
		Cb11_final_2 <= 0; Cb21_final_2 <= 0; Cb31_final_2 <= 0; Cb41_final_2 <= 0;
		Cb51_final_2 <= 0; Cb61_final_2 <= 0; Cb71_final_2 <= 0; Cb81_final_2 <= 0;
		Cb11_final_3 <= 0; Cb11_final_4 <= 0;
		end
	else if (enable) begin
		data_1 <= data_in;  
		Cb11_final_1 <= Cb11_final[13] ? Cb11_final[24:14] + 1 : Cb11_final[24:14];
		Cb11_final_2[31:11] <= Cb11_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb11_final_2[10:0] <= Cb11_final_1;
		// Need to sign extend Cb11_final_1 and the other logicisters to store a negative 
		// number as a twos complement number.  If you don't sign extend, then a negative number
		// will be stored incorrectly as a positive number.  For example, -215 would be stored
		// as 1833 without sign extending
		Cb11_final_3 <= Cb11_final_2;
		Cb11_final_4 <= Cb11_final_3;
		Cb21_final_1 <= Cb21_final_diff[13] ? Cb21_final_diff[24:14] + 1 : Cb21_final_diff[24:14];
		Cb21_final_2[31:11] <= Cb21_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb21_final_2[10:0] <= Cb21_final_1;
		Cb31_final_1 <= Cb31_final_diff[13] ? Cb31_final_diff[24:14] + 1 : Cb31_final_diff[24:14];
		Cb31_final_2[31:11] <= Cb31_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb31_final_2[10:0] <= Cb31_final_1;
		Cb41_final_1 <= Cb41_final_diff[13] ? Cb41_final_diff[24:14] + 1 : Cb41_final_diff[24:14];
		Cb41_final_2[31:11] <= Cb41_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb41_final_2[10:0] <= Cb41_final_1;
		Cb51_final_1 <= Cb51_final_diff[13] ? Cb51_final_diff[24:14] + 1 : Cb51_final_diff[24:14];
		Cb51_final_2[31:11] <= Cb51_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb51_final_2[10:0] <= Cb51_final_1;
		Cb61_final_1 <= Cb61_final_diff[13] ? Cb61_final_diff[24:14] + 1 : Cb61_final_diff[24:14];
		Cb61_final_2[31:11] <= Cb61_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb61_final_2[10:0] <= Cb61_final_1;
		Cb71_final_1 <= Cb71_final_diff[13] ? Cb71_final_diff[24:14] + 1 : Cb71_final_diff[24:14];
		Cb71_final_2[31:11] <= Cb71_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb71_final_2[10:0] <= Cb71_final_1;
		Cb81_final_1 <= Cb81_final_diff[13] ? Cb81_final_diff[24:14] + 1 : Cb81_final_diff[24:14];
		Cb81_final_2[31:11] <= Cb81_final_1[10] ? 21'b111111111111111111111 : 21'b000000000000000000000;
		Cb81_final_2[10:0] <= Cb81_final_1;
		// The bit in place 13 is the fraction part, for rounding purposes
		// if it is 1, then you need to add 1 to the bits in 22-14, 
		// if bit 13 is 0, then the bits in 22-14 won't change
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