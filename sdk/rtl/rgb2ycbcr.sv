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

module rgb2ycbcr (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic [23:0] data_in,  // RGB input: [23:16] = R, [15:8] = G, [7:0] = B
    output logic [23:0] data_out, // YCbCr output: [23:16] = Cr, [15:8] = Cb, [7:0] = Y
    output logic       enable_out
);


 // Include the constants file
    `include "rgb2ycbcr_constants.svh"

// Intermediate signals
logic [21:0] Y1_product, Y2_product, Y3_product;
logic [21:0] CB1_product, CB2_product, CB3_product;
logic [21:0] CR1_product, CR2_product, CR3_product;
logic [21:0] Y_temp, CB_temp, CR_temp;
logic [7:0]  Y, CB, CR;
logic        enable_1, enable_2;

// Output assignment
assign data_out = {CR, CB, Y};

// Stage 1: Multiply RGB inputs with coefficients
always_ff @(posedge clk) begin
    if (rst) begin
        Y1_product  <= 22'd0;
        Y2_product  <= 22'd0;
        Y3_product  <= 22'd0;
        CB1_product <= 22'd0;
        CB2_product <= 22'd0;
        CB3_product <= 22'd0;
        CR1_product <= 22'd0;
        CR2_product <= 22'd0;
        CR3_product <= 22'd0;
    end else if (enable) begin
        Y1_product  <= Y1  * data_in[7:0];   // B * Y1
        Y2_product  <= Y2  * data_in[15:8];  // G * Y2
        Y3_product  <= Y3  * data_in[23:16]; // R * Y3
        CB1_product <= CB1 * data_in[7:0];   // B * CB1
        CB2_product <= CB2 * data_in[15:8];  // G * CB2
        CB3_product <= CB3 * data_in[23:16]; // R * CB3
        CR1_product <= CR1 * data_in[7:0];   // B * CR1
        CR2_product <= CR2 * data_in[15:8];  // G * CR2
        CR3_product <= CR3 * data_in[23:16]; // R * CR3
    end
end

// Stage 2: Sum products and apply offsets
always_ff @(posedge clk) begin
    if (rst) begin
        Y_temp  <= 22'd0;
        CB_temp <= 22'd0;
        CR_temp <= 22'd0;
    end else if (enable) begin
        Y_temp  <= Y1_product + Y2_product + Y3_product;
        CB_temp <= OFFSET - CB1_product - CB2_product + CB3_product;
        CR_temp <= OFFSET + CR1_product - CR2_product - CR3_product;
    end
end

// Stage 3: Rounding and clamping
always_ff @(posedge clk) begin
    if (rst) begin
        Y  <= 8'd0;
        CB <= 8'd0;
        CR <= 8'd0;
    end else if (enable) begin
        // Y: Round if bit 13 is 1, no clamping needed (0-255 range assumed)
        Y <= Y_temp[13] ? Y_temp[21:14] + 8'd1 : Y_temp[21:14];
        
        // Cb: Round if bit 13 is 1, clamp to 255 to prevent overflow
        if (CB_temp[13] && CB_temp[21:14] != 8'd255) begin
            CB <= CB_temp[21:14] + 8'd1;
        end else begin
            CB <= CB_temp[21:14];
        end
        
        // Cr: Round if bit 13 is 1, clamp to 255 to prevent overflow
        if (CR_temp[13] && CR_temp[21:14] != 8'd255) begin
            CR <= CR_temp[21:14] + 8'd1;
        end else begin
            CR <= CR_temp[21:14];
        end
    end
end

// Enable signal pipeline
always_ff @(posedge clk) begin
    if (rst) begin
        enable_1   <= 1'b0;
        enable_2   <= 1'b0;
        enable_out <= 1'b0;
    end else begin
        enable_1   <= enable;
        enable_2   <= enable_1;
        enable_out <= enable_2;
    end
end

endmodule