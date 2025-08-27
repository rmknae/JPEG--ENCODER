// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file // for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description: rgb constants
 
//
// Author : Navaal Noshi
// Date   : 29th July 2025
//

`ifndef RGB2YCBCR_CONSTANTS_SVH
`define RGB2YCBCR_CONSTANTS_SVH

// Fixed-point coefficients (Q13.1 format, scaled by 2^14 = 16384)
localparam logic [13:0] Y1  = 14'd4899;  // 0.299 * 16384
localparam logic [13:0] Y2  = 14'd9617;  // 0.587 * 16384
localparam logic [13:0] Y3  = 14'd1868;  // 0.114 * 16384
localparam logic [13:0] CB1 = 14'd2764;  // 0.16874 * 16384
localparam logic [13:0] CB2 = 14'd5428;  // 0.33126 * 16384
localparam logic [13:0] CB3 = 14'd8192;  // 0.5 * 16384
localparam logic [13:0] CR1 = 14'd8192;  // 0.5 * 16384
localparam logic [13:0] CR2 = 14'd6860;  // 0.41869 * 16384
localparam logic [13:0] CR3 = 14'd1332;  // 0.08131 * 16384
localparam logic [21:0] OFFSET = 22'd2097152; // 128 * 16384 (for Cb, Cr offset)


`endif