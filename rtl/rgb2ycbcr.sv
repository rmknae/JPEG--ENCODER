// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//   This module converts 8-bit RGB (Red, Green, Blue) pixel data into 8-bit
//   YCbCr format.The transformation uses a fixed-point approximation of the standard ITU-R
//   BT.601 matrix, with scaling by 2^13 to avoid floating point arithmetic.
//   A 2-stage pipeline performs the following:
//     - Stage 1: Multiplication of RGB with fixed-point coefficients
//     - Stage 2: Rounding and clamping to [0, 255]
//   Outputs are registered and synchronized using delayed enable signals.
//
// Author:Navaal Noshi
// Date:12th July,2025.

`timescale 1ns / 100ps

module rgb2ycrcb(
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic [23:0] data_in,
    output logic [23:0] data_out,
    output logic       enable_out
);

logic [13:0] Y1 = 14'd4899;
logic [13:0] Y2 = 14'd9617;
logic [13:0] Y3 = 14'd1868;
logic [13:0] CB1 = 14'd2764;
logic [13:0] CB2 = 14'd5428;
logic [13:0] CB3 = 14'd8192;
logic [13:0] CR1 = 14'd8192;
logic [13:0] CR2 = 14'd6860;
logic [13:0] CR3 = 14'd1332;
logic [21:0] Y_temp, CB_temp, CR_temp;
logic [21:0] Y1_product, Y2_product, Y3_product;
logic [21:0] CB1_product, CB2_product, CB3_product;
logic [21:0] CR1_product, CR2_product, CR3_product;
logic [7:0] Y, CB, CR;
logic	enable_1, enable_2;
assign data_out = {CR, CB, Y};

always_ff @(posedge clk)
begin
	if (rst) begin
		Y1_product <= 0;	
		Y2_product <= 0;
		Y3_product <= 0;   
		CB1_product <= 0;	
		CB2_product <= 0;
		CB3_product <= 0;
		CR1_product <= 0;	
		CR2_product <= 0;
		CR3_product <= 0;
		Y_temp <= 0;
		CB_temp <= 0;
		CR_temp <= 0;
		end
	else if (enable) begin
		Y1_product <= Y1 * data_in[7:0];	
		Y2_product <= Y2 * data_in[15:8];
		Y3_product <= Y3 * data_in[23:16];   
		CB1_product <= CB1 * data_in[7:0];	
		CB2_product <= CB2 * data_in[15:8];
		CB3_product <= CB3 * data_in[23:16];
		CR1_product <= CR1 * data_in[7:0];	
		CR2_product <= CR2 * data_in[15:8];
		CR3_product <= CR3 * data_in[23:16];
		Y_temp <= Y1_product + Y2_product + Y3_product;
		CB_temp <= 22'd2097152 - CB1_product - CB2_product + CB3_product;
		CR_temp <= 22'd2097152 + CR1_product - CR2_product - CR3_product;  
		end
end 
 
/* Rounding of Y, CB, CR requires looking at bit 13.  If there is a '1' in bit 13,
then the value in bits [21:14] needs to be rounded up by adding 1 to the value
in those bits */

always_ff @(posedge clk)
begin
	if (rst) begin
		Y <= 0;
		CB <= 0;
		CR <= 0;   
		end
	else if (enable) begin
		Y <= Y_temp[13] ? Y_temp[21:14] + 1: Y_temp[21:14];
		CB <= CB_temp[13] & (CB_temp[21:14] != 8'd255) ? CB_temp[21:14] + 1: CB_temp[21:14];
		CR <= CR_temp[13] & (CR_temp[21:14] != 8'd255) ? CR_temp[21:14] + 1: CR_temp[21:14]; 
		// Need to avoid rounding if the value in the top 8 bits is 255, otherwise
		// the value would rollover from 255 to 0
		end
end


always_ff @(posedge clk)
begin
	if (rst) begin
		enable_1 <= 0;
		enable_2 <= 0;
		enable_out <= 0;   
		end
	else begin
		enable_1 <= enable;
		enable_2 <= enable_1;
		enable_out <= enable_2;
		end
end
endmodule

