// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Module Name: yd_q_h
// Description:
//    This is a top-level integration module designed for processing the luminance (Y)
//    component within a JPEG encoder pipeline. It orchestrates the flow and control
//    among three primary processing stages:
//    1. `y_dct`: Executes the 2D Discrete Cosine Transform on incoming 8x8 pixel blocks.
//    2. `y_quantizer`: Applies the necessary quantization to the DCT coefficients using
//       a pre-defined luminance quantization matrix.
//    3. `y_huff`: Performs Huffman encoding on the quantized coefficients to generate
//       the compressed, variable-length JPEG bitstream.
//
//    The module accepts pixel data serially via `data_in` and manages its progression
//    through the DCT, quantization, and Huffman encoding stages. It incorporates
//    `enable` and `rst` control signals for proper synchronization and operation.
//    The final, JPEG-compliant output bitstream is provided via `JPEG_bitstream`,
//    accompanied by `data_ready` and `end_of_block` flags to signal output validity
//    and block completion.
//
// Author:Rameen
// Date:19th July,2025.

`timescale 1ns / 100ps

module yd_q_h (
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [7:0]  data_in,

    output logic [31:0] JPEG_bitstream,
    output logic        data_ready,
    output logic [4:0]  y_orc,
    output logic        end_of_block_output,
    output logic        end_of_block_empty
);



logic	dct_enable, quantizer_enable;
logic [10:0] Z11_final, Z12_final, Z13_final, Z14_final;
logic [10:0] Z15_final, Z16_final, Z17_final, Z18_final;
logic [10:0] Z21_final, Z22_final, Z23_final, Z24_final;
logic [10:0] Z25_final, Z26_final, Z27_final, Z28_final;
logic [10:0] Z31_final, Z32_final, Z33_final, Z34_final;
logic [10:0] Z35_final, Z36_final, Z37_final, Z38_final;
logic [10:0] Z41_final, Z42_final, Z43_final, Z44_final;
logic [10:0] Z45_final, Z46_final, Z47_final, Z48_final;
logic [10:0] Z51_final, Z52_final, Z53_final, Z54_final;
logic [10:0] Z55_final, Z56_final, Z57_final, Z58_final;
logic [10:0] Z61_final, Z62_final, Z63_final, Z64_final;
logic [10:0] Z65_final, Z66_final, Z67_final, Z68_final;
logic [10:0] Z71_final, Z72_final, Z73_final, Z74_final;
logic [10:0] Z75_final, Z76_final, Z77_final, Z78_final;
logic [10:0] Z81_final, Z82_final, Z83_final, Z84_final;
logic [10:0] Z85_final, Z86_final, Z87_final, Z88_final;
logic [10:0] Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18; 	
logic [10:0] Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28; 
logic [10:0] Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38; 
logic [10:0] Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48; 
logic [10:0] Q51, Q52, Q53, Q54, Q55, Q56, Q57, Q58; 
logic [10:0] Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68; 
logic [10:0] Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78; 
logic [10:0] Q81, Q82, Q83, Q84, Q85, Q86, Q87, Q88; 

y_dct u1(
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .data_in(data_in),
    // Output 2D array of DCT coefficients
    .Z_final('{
        '{Z11_final, Z12_final, Z13_final, Z14_final, Z15_final, Z16_final, Z17_final, Z18_final},
        '{Z21_final, Z22_final, Z23_final, Z24_final, Z25_final, Z26_final, Z27_final, Z28_final},
        '{Z31_final, Z32_final, Z33_final, Z34_final, Z35_final, Z36_final, Z37_final, Z38_final},
        '{Z41_final, Z42_final, Z43_final, Z44_final, Z45_final, Z46_final, Z47_final, Z48_final},
        '{Z51_final, Z52_final, Z53_final, Z54_final, Z55_final, Z56_final, Z57_final, Z58_final},
        '{Z61_final, Z62_final, Z63_final, Z64_final, Z65_final, Z66_final, Z67_final, Z68_final},
        '{Z71_final, Z72_final, Z73_final, Z74_final, Z75_final, Z76_final, Z77_final, Z78_final},
        '{Z81_final, Z82_final, Z83_final, Z84_final, Z85_final, Z86_final, Z87_final, Z88_final}
    }),
    .output_enable(dct_enable)
);
	
y_quantizer u6 (
    .clk(clk),
    .rst(rst),
    .enable(dct_enable),

    // Input 2D array
    .Z('{
        '{Z11_final, Z12_final, Z13_final, Z14_final, Z15_final, Z16_final, Z17_final, Z18_final},
        '{Z21_final, Z22_final, Z23_final, Z24_final, Z25_final, Z26_final, Z27_final, Z28_final},
        '{Z31_final, Z32_final, Z33_final, Z34_final, Z35_final, Z36_final, Z37_final, Z38_final},
        '{Z41_final, Z42_final, Z43_final, Z44_final, Z45_final, Z46_final, Z47_final, Z48_final},
        '{Z51_final, Z52_final, Z53_final, Z54_final, Z55_final, Z56_final, Z57_final, Z58_final},
        '{Z61_final, Z62_final, Z63_final, Z64_final, Z65_final, Z66_final, Z67_final, Z68_final},
        '{Z71_final, Z72_final, Z73_final, Z74_final, Z75_final, Z76_final, Z77_final, Z78_final},
        '{Z81_final, Z82_final, Z83_final, Z84_final, Z85_final, Z86_final, Z87_final, Z88_final}
    }),

    // Output 2D array
    .Q('{
        '{Q11, Q12, Q13, Q14, Q15, Q16, Q17, Q18},
        '{Q21, Q22, Q23, Q24, Q25, Q26, Q27, Q28},
        '{Q31, Q32, Q33, Q34, Q35, Q36, Q37, Q38},
        '{Q41, Q42, Q43, Q44, Q45, Q46, Q47, Q48},
        '{Q51, Q52, Q53, Q54, Q55, Q56, Q57, Q58},
        '{Q61, Q62, Q63, Q64, Q65, Q66, Q67, Q68},
        '{Q71, Q72, Q73, Q74, Q75, Q76, Q77, Q78},
        '{Q81, Q82, Q83, Q84, Q85, Q86, Q87, Q88}
    }),

    .out_enable(quantizer_enable)
);


	y_huff u3(.clk(clk), .rst(rst), .enable(quantizer_enable), 
	.Y11(Q11), .Y12(Q21), .Y13(Q31), .Y14(Q41), .Y15(Q51), .Y16(Q61), .Y17(Q71), .Y18(Q81), 
	.Y21(Q12), .Y22(Q22), .Y23(Q32), .Y24(Q42), .Y25(Q52), .Y26(Q62), .Y27(Q72), .Y28(Q82),
	.Y31(Q13), .Y32(Q23), .Y33(Q33), .Y34(Q43), .Y35(Q53), .Y36(Q63), .Y37(Q73), .Y38(Q83), 
	.Y41(Q14), .Y42(Q24), .Y43(Q34), .Y44(Q44), .Y45(Q54), .Y46(Q64), .Y47(Q74), .Y48(Q84),
	.Y51(Q15), .Y52(Q25), .Y53(Q35), .Y54(Q45), .Y55(Q55), .Y56(Q65), .Y57(Q75), .Y58(Q85), 
	.Y61(Q16), .Y62(Q26), .Y63(Q36), .Y64(Q46), .Y65(Q56), .Y66(Q66), .Y67(Q76), .Y68(Q86),
	.Y71(Q17), .Y72(Q27), .Y73(Q37), .Y74(Q47), .Y75(Q57), .Y76(Q67), .Y77(Q77), .Y78(Q87), 
	.Y81(Q18), .Y82(Q28), .Y83(Q38), .Y84(Q48), .Y85(Q58), .Y86(Q68), .Y87(Q78), .Y88(Q88),
	.JPEG_bitstream(JPEG_bitstream), .data_ready(data_ready), .output_reg_count(y_orc),
	.end_of_block_output(end_of_block_output),
	 .end_of_block_empty(end_of_block_empty));	

	endmodule
