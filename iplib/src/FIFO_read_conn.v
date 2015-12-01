`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2014 11:21:28 AM
// Design Name: 
// Module Name: FIFO_read_conn
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO_read_conn#
(parameter DATA_WIDTH = 32)
(
	input [DATA_WIDTH-1:0] din_src,
	output rd_en_src,
	input empty_src,
	
	output [DATA_WIDTH-1:0] din,
	input rd_en,
	output empty_n
	
	

    );



assign din = din_src;
assign rd_en_src = rd_en;
assign empty_n = ~empty_src;


endmodule