// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//   This module performs quantization on an 8x8 block of Cb (chrominance-blue)
//   values after 2D Discrete Cosine Transform (DCT). Like the Y channel, the
//   DCT coefficients are divided (quantized) by a matrix of constants. This
//   is implemented by multiplying each DCT coefficient with a precomputed
//   reciprocal value (scaled by 4096) followed by a right-shift.
//   This step reduces DCT precision and achieves lossy compression.
//
// Author: Navaal Noshi
// Date: 29th July, 2025

`timescale 1ns / 100ps
`include "quantizer_constants.svh"

module cb_quantizer(
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  wire [10:0]  Z[1:8][1:8],  // Explicit wire
    output logic [10:0] Q[1:8][1:8],
    output logic        out_enable
);

logic [12:0] QM[1:8][1:8] = '{
  '{QQ1_1, QQ1_2, QQ1_3, QQ1_4, QQ1_5, QQ1_6, QQ1_7, QQ1_8},
  '{QQ2_1, QQ2_2, QQ2_3, QQ2_4, QQ2_5, QQ2_6, QQ2_7, QQ2_8},
  '{QQ3_1, QQ3_2, QQ3_3, QQ3_4, QQ3_5, QQ3_6, QQ3_7, QQ3_8},
  '{QQ4_1, QQ4_2, QQ4_3, QQ4_4, QQ4_5, QQ4_6, QQ4_7, QQ4_8},
  '{QQ5_1, QQ5_2, QQ5_3, QQ5_4, QQ5_5, QQ5_6, QQ5_7, QQ5_8},
  '{QQ6_1, QQ6_2, QQ6_3, QQ6_4, QQ6_5, QQ6_6, QQ6_7, QQ6_8},
  '{QQ7_1, QQ7_2, QQ7_3, QQ7_4, QQ7_5, QQ7_6, QQ7_7, QQ7_8},
  '{QQ8_1, QQ8_2, QQ8_3, QQ8_4, QQ8_5, QQ8_6, QQ8_7, QQ8_8}
};

logic signed [31:0] Z_int   [1:8][1:8];
logic [22:0]        Z_temp  [1:8][1:8];
logic [22:0]        Z_temp_1[1:8][1:8];
logic enable_1, enable_2, enable_3;

// Stage 1: Sign extension
always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_int[i][j] <= 32'sd0;
      end
    end
  end else if (enable) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_int[i][j] <= {{21{Z[i][j][10]}}, Z[i][j]};
      end
    end
  end
end

// Stage 2: Multiplication
always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_temp[i][j] <= '0;
      end
    end
  end else if (enable_1) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_temp[i][j] <= Z_int[i][j] * QM[i][j];
      end
    end
  end
end

// Stage 3: Pipeline Z_temp to Z_temp_1
always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_temp_1[i][j] <= '0;
      end
    end
  end else if (enable_2) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Z_temp_1[i][j] <= Z_temp[i][j];
      end
    end
  end
end

// Stage 4: Rounding and truncation
always_ff @(posedge clk) begin
  if (rst) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Q[i][j] <= '0;
      end
    end
  end else if (enable_3) begin
    for (int i = 1; i <= 8; i++) begin
      for (int j = 1; j <= 8; j++) begin
        Q[i][j] <= Z_temp_1[i][j][11] ? 
                   (Z_temp_1[i][j][22:12] + 1) : 
                   (Z_temp_1[i][j][22:12]);
      end
    end
  end
end


/* enable_1 is delayed one clock cycle from enable, and it's used to 
enable the logic that needs to execute on the clock cycle after enable goes high 
enable_2 is delayed two clock cycles, and out_enable signals the next module
that its input data is ready*/

always_ff @(posedge clk) begin
  if (rst) begin
    enable_1   <= 1'b0;
    enable_2   <= 1'b0;
    enable_3   <= 1'b0;
    out_enable <= 1'b0;
  end else begin
    enable_1   <= enable;
    enable_2   <= enable_1;
    enable_3   <= enable_2;
    out_enable <= enable_3;
  end
end

endmodule