// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//   Defines the standard 8x8 Discrete Cosine Transform (DCT) basis
//   matrix used in JPEG encoding and decoding.
//   - The matrix elements are based on the definition of the DCT-II.
//   - In hardware, these coefficients are usually scaled to fixed-point
//     representation (e.g., multiplied by 4096) 
//   - This version provides a fixed-point integer version (scaled by 4096),
//     suitable for use in testbenches and hardware modules.
//
// Author : Rameen
// Date   : 29th July 2025

`ifndef DCT_CONSTANTS_SVH
`define DCT_CONSTANTS_SVH

// ---------------------
// DCT matrix entries
// ---------------------
parameter int T1  = 5793;   // .3536
parameter int T21 = 8035;   // .4904
parameter int T22 = 6811;   // .4157
parameter int T23 = 4551;   // .2778
parameter int T24 = 1598;   // .0975
parameter int T25 = -1598;  // -.0975
parameter int T26 = -4551;  // -.2778
parameter int T27 = -6811;  // -.4157
parameter int T28 = -8035;  // -.4904
parameter int T31 = 7568;   // .4619
parameter int T32 = 3135;   // .1913
parameter int T33 = -3135;  // -.1913
parameter int T34 = -7568;  // -.4619
parameter int T52 = -5793;  // -.3536

// ---------------------
// Inverse DCT matrix entries
// ---------------------
parameter int Ti1  = 5793;   // .3536
parameter int Ti21 = 8035;   // .4904
parameter int Ti22 = 6811;   // .4157
parameter int Ti23 = 4551;   // .2778
parameter int Ti24 = 1598;   // .0975
parameter int Ti25 = -1598;  // -.0975
parameter int Ti26 = -4551;  // -.2778
parameter int Ti27 = -6811;  // -.4157
parameter int Ti28 = -8035;  // -.4904
parameter int Ti31 = 7568;   // .4619
parameter int Ti32 = 3135;   // .1913
parameter int Ti33 = -3135;  // -.1913
parameter int Ti34 = -7568;  // -.4619
parameter int Ti52 = -5793;  // -.3536

`endif // DCT_CONSTANTS_SVH
