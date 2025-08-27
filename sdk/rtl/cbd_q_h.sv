// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//   This module integrates the Discrete Cosine Transform (DCT), quantizer,
//   Y and Huffman encoder modules for the **Cb (chrominance-blue)** component of the JPEG
//   encoding pipeline. The operations performed include:
//   1. Applying 2D-DCT on an 8x8 input block
//   2. Quantizing the DCT coefficients using a chrominance-specific matrix
//   3. Huffman encoding the quantized values to produce a compressed JPEG stream
//  This combined module outputs a 32-bit Huffman encoded JPEG stream and provides
// flags for data readiness and end-of-block status.
//
// Author:Navaal Noshi
// Date:19th July,2025.


`timescale 1ns / 100ps

module cbd_q_h(
    input  logic        clk,
    input  logic        rst,
    input  logic        enable,
    input  logic [7:0]  data_in,
    output logic [31:0] JPEG_bitstream,
    output logic        data_ready,
    output logic [4:0]  cb_orc,
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

cb_dct u5 (
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
	
cb_quantizer u6 (
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


	cb_huff u7(.clk(clk), .rst(rst), .enable(quantizer_enable), 
	.Cb11(Q11), .Cb12(Q21), .Cb13(Q31), .Cb14(Q41), .Cb15(Q51), .Cb16(Q61), .Cb17(Q71), .Cb18(Q81), 
	.Cb21(Q12), .Cb22(Q22), .Cb23(Q32), .Cb24(Q42), .Cb25(Q52), .Cb26(Q62), .Cb27(Q72), .Cb28(Q82),
	.Cb31(Q13), .Cb32(Q23), .Cb33(Q33), .Cb34(Q43), .Cb35(Q53), .Cb36(Q63), .Cb37(Q73), .Cb38(Q83), 
	.Cb41(Q14), .Cb42(Q24), .Cb43(Q34), .Cb44(Q44), .Cb45(Q54), .Cb46(Q64), .Cb47(Q74), .Cb48(Q84),
	.Cb51(Q15), .Cb52(Q25), .Cb53(Q35), .Cb54(Q45), .Cb55(Q55), .Cb56(Q65), .Cb57(Q75), .Cb58(Q85), 
	.Cb61(Q16), .Cb62(Q26), .Cb63(Q36), .Cb64(Q46), .Cb65(Q56), .Cb66(Q66), .Cb67(Q76), .Cb68(Q86),
	.Cb71(Q17), .Cb72(Q27), .Cb73(Q37), .Cb74(Q47), .Cb75(Q57), .Cb76(Q67), .Cb77(Q77), .Cb78(Q87), 
	.Cb81(Q18), .Cb82(Q28), .Cb83(Q38), .Cb84(Q48), .Cb85(Q58), .Cb86(Q68), .Cb87(Q78), .Cb88(Q88),
	.JPEG_bitstream(JPEG_bitstream), .data_ready(data_ready), .output_reg_count(cb_orc),
	.end_of_block_empty(end_of_block_empty));		
	

	endmodule
