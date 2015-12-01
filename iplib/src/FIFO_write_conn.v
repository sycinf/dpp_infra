`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:01:08 04/23/2014 
// Design Name: 
// Module Name:    FIFO_write_conn 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FIFO_write_conn#
(parameter DATA_WIDTH = 32)
(
	input [DATA_WIDTH-1:0] dout_src,
	input wr_en_src,
	output full_n,
	
	output [DATA_WIDTH-1:0] din,
	output wr_en,
	input full
	
	

    );



assign din = dout_src;
assign wr_en = wr_en_src;
assign full_n = ~full;


endmodule
