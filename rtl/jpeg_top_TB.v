`timescale 1ps / 1ps

module jpeg_top_tb;

reg end_of_file_signal;
reg [23:0] data_in;
reg clk;
reg rst;
reg enable;
wire [31:0] JPEG_bitstream;
wire data_ready;
wire [4:0] end_of_file_bitstream_count;
wire eof_data_partial_ready;
integer outfile;

// Unit Under Test 
jpeg_top UUT (
    .end_of_file_signal(end_of_file_signal),
    .data_in(data_in),
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .JPEG_bitstream(JPEG_bitstream),
    .data_ready(data_ready),
    .end_of_file_bitstream_count(end_of_file_bitstream_count),
    .eof_data_partial_ready(eof_data_partial_ready)
);

// ----------------------
// Stimulus process
// ----------------------
initial begin : STIMUL
    rst = 1'b1;
    enable = 1'b0;
    end_of_file_signal = 1'b0;

    #10000; 
    rst = 1'b0;
    enable = 1'b1;






















    
#10000;
    #130000;
    enable = 1'b0;

    #2000000; 
end

// ----------------------
// Open output file once
// ----------------------
initial begin
    outfile = $fopen("bitstream_output.txt", "w");
    if (outfile == 0) begin
        $display("ERROR: Could not open bitstream_output.txt");
        $finish;
    end
end

// ----------------------
// End simulation later (also closes file)
// ----------------------
initial begin
  
	 
	    #500000000;
		 #500000000;
	  #500000000;
	 
    $fclose(outfile);  // close file before finishing
    $finish;
end

// ----------------------
// Clock generator
// ----------------------
always begin : CLOCK_clk
    clk = 1'b0;
    #5000;
    clk = 1'b1;
    #5000;
end

// ----------------------
// Write JPEG bitstream whenever ready
// ----------------------
always @(JPEG_bitstream or data_ready) begin : JPEG
    if (data_ready == 1'b1) begin
        $fwrite(outfile, "%h\n", JPEG_bitstream);   // write in hex
    end
end

endmodule