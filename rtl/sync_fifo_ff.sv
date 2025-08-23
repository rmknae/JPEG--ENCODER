// Copyright 2025 Maktab-e-Digital Systems Lahore.
// Licensed under the Apache License, Version 2.0, see LICENSE file for details.
// SPDX-License-Identifier: Apache-2.0
//
// Description:
//    This module implements a synchronous FIFO (First-In, First-Out) buffer.
//    Its primary purpose is to store encoded data blocks and output them sequentially,
//    specifically designed to facilitate "FF checking" (e.g., for JPEG byte stuffing).
//    It includes a special "rollover_write" mechanism to introduce a controlled delay
//    or specific behavior after an FF escaping operation.
//    The FIFO has a fixed depth of 16 entries.
//    It provides a 'valid' output signal to indicate when valid data is available
//    and an 'empty' signal to indicate the FIFO's status.
//
// Author:Navaal Noshi
// Date:20ht July,2025.


`timescale 1ns / 100ps

module sync_fifo_ff (
    input  logic        clk,
    input  logic        rst,
    input  logic        read_req,
    input  logic [90:0] write_data,
    input  logic        write_enable,
    input  logic        rollover_write,
    output logic [90:0] read_data,  
    output logic        fifo_empty, 
    output logic        rdata_valid
);

    logic [4:0]  read_ptr;
    logic [4:0]  write_ptr;
    logic [90:0] mem [0:15];


    logic [3:0] write_addr;
    logic [3:0] read_addr;
    logic       read_enable;

    assign write_addr  = write_ptr[3:0];
    assign read_addr   = read_ptr[3:0];
    assign read_enable = read_req && (~fifo_empty);
    assign fifo_empty  = (read_ptr == write_ptr);


always_ff @(posedge clk)
  begin
   if (rst)
      write_ptr <= {(5){1'b0}};
   else if (write_enable & !rollover_write)
      write_ptr <= write_ptr + {{4{1'b0}},1'b1};
   else if (write_enable & rollover_write)
      write_ptr <= write_ptr + 5'b00010;
   // A rollover_write means that there have been a total of 4 FF's
   // that have been detected in the bitstream.  So an extra set of 32
   // bits will be put into the bitstream (due to the 4 extra 00's added
   // after the 4 FF's), and the input data will have to 
   // be delayed by 1 clock cycle as it makes its way into the output
   // bitstream.  So the write_ptr is incremented by 2 for a rollover, giving
   // the output the extra clock cycle it needs to write the 
   // extra 32 bits to the bitstream.  The output
   // will read the dummy data from the FIFO, but won't do anything with it,
   // it will be putting the extra set of 32 bits into the bitstream on that
   // clock cycle.
  end

always_ff @(posedge clk)
begin
   if (rst)
      rdata_valid <= 1'b0;
   else if (read_enable)
      rdata_valid <= 1'b1;
   else
   	  rdata_valid <= 1'b0;  
end
  
always_ff @(posedge clk)
 begin
   if (rst)
      read_ptr <= {(5){1'b0}};
   else if (read_enable)
      read_ptr <= read_ptr + {{4{1'b0}},1'b1};
end

// Mem write
always_ff @(posedge clk)
  begin
   if (write_enable)
     mem[write_addr] <= write_data;
  end
// Mem Read
always_ff @(posedge clk)
  begin
   if (read_enable)
      read_data <= mem[read_addr];
  end
  
endmodule
