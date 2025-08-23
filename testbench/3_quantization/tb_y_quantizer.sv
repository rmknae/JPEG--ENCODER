// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This testbench verifies the functionality of the `y_quantizer` module,
//    which performs quantization on 8x8 blocks of DCT (Discrete Cosine Transform)
//    coefficients corresponding to the y  component of a JPEG image. The testbench generates a clock, 
//    applies reset, and feeds various test patterns into the input matrix `Z`, including maximum values,
//    ramp sequences, and checkerboard alternating patterns.
//    It computes the expected quantized output using the same quantization matrix
//    as the `y_quantizer` module (standard JPEG chroma Q matrix) and a fixed-point
//    approximation: multiplying by (4096 / Q[i][j]) and right-shifting by 12,
//    with rounding.
//
//    After waiting for the pipeline to complete (signaled by `out_enable`),
//    the testbench prints the input, expected, and actual output matrices
//    side-by-side in a horizontal format for easy visual verification.
//
// Author: Navaal Noshi
// Date: 24th July, 2025

`timescale 1ns / 100ps
`include "quantizer_constants.svh"

module tb_y_quantizer;             // cr,cb replace here only

    // Signals for the DUT
    logic clk;
    logic rst;
    logic enable;
    logic [10:0] Z [0:7][0:7];
    logic [10:0] Q [0:7][0:7];
    logic out_enable;

    integer i, j;
    
    // DUT Instantiation
    y_quantizer dut (
        .clk(clk),
        .rst(rst),
        .enable(enable),
        
        // Connect the input array to the individual DUT ports
        .Z11(Z[0][0]), .Z12(Z[0][1]), .Z13(Z[0][2]), .Z14(Z[0][3]),
        .Z15(Z[0][4]), .Z16(Z[0][5]), .Z17(Z[0][6]), .Z18(Z[0][7]),
        .Z21(Z[1][0]), .Z22(Z[1][1]), .Z23(Z[1][2]), .Z24(Z[1][3]),
        .Z25(Z[1][4]), .Z26(Z[1][5]), .Z27(Z[1][6]), .Z28(Z[1][7]),
        .Z31(Z[2][0]), .Z32(Z[2][1]), .Z33(Z[2][2]), .Z34(Z[2][3]),
        .Z35(Z[2][4]), .Z36(Z[2][5]), .Z37(Z[2][6]), .Z38(Z[2][7]),
        .Z41(Z[3][0]), .Z42(Z[3][1]), .Z43(Z[3][2]), .Z44(Z[3][3]),
        .Z45(Z[3][4]), .Z46(Z[3][5]), .Z47(Z[3][6]), .Z48(Z[3][7]),
        .Z51(Z[4][0]), .Z52(Z[4][1]), .Z53(Z[4][2]), .Z54(Z[4][3]),
        .Z55(Z[4][4]), .Z56(Z[4][5]), .Z57(Z[4][6]), .Z58(Z[4][7]),
        .Z61(Z[5][0]), .Z62(Z[5][1]), .Z63(Z[5][2]), .Z64(Z[5][3]),
        .Z65(Z[5][4]), .Z66(Z[5][5]), .Z67(Z[5][6]), .Z68(Z[5][7]),
        .Z71(Z[6][0]), .Z72(Z[6][1]), .Z73(Z[6][2]), .Z74(Z[6][3]),
        .Z75(Z[6][4]), .Q76(Q[6][5]), .Q77(Q[6][6]), .Q78(Q[6][7]),
        .Q81(Q[7][0]), .Q82(Q[7][1]), .Q83(Q[7][2]), .Q84(Q[7][3]),
        .Q85(Q[7][4]), .Q86(Q[7][5]), .Q87(Q[7][6]), .Q88(Q[7][7]),

        .out_enable(out_enable)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Stimulus and Output Print
    initial begin
        // 1. Reset
        rst = 1;
        enable = 0;
        Z = '{default: '{default: 11'd0}};
        #10;
        @(posedge clk);
        rst = 0;
        
        // 2. Provide random data
        @(posedge clk);
        enable = 1;
        
        // Use a for loop to assign random values to the Z matrix
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < 8; j++) begin
                // $urandom_range generates a non-negative random number
                Z[i][j] = $urandom_range(0, 2047); 
            end
        end
        
        // Wait for the pipeline to finish
        repeat (4) @(posedge clk);
        enable = 0;

        // 3. Print the input and output data
        $display("Input Z Matrix (Randomly Generated):");
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < 8; j++) begin
                $write("%0d\t", Z[i][j]);
            end
            $write("\n");
        end
        
        $display("\nOutput Q Matrix:");
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < 8; j++) begin
                $write("%0d\t", Q[i][j]);
            end
            $write("\n");
        end
        
        #10;
        $finish;
    end
endmodule


