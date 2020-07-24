`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2020 10:54:53 PM
// Design Name: 
// Module Name: gpo_core
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


module gpo_core
#(
    parameter N_LED = 4 
)
(
    input logic clk,
    input logic reset,
    
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    
    output logic [N_LED-1:0] dout
);

logic [3:0] buf_reg;
logic wr_en;

always @ (posedge clk)
    if(reset)
        buf_reg <= 0;
    else if(wr_en)
        buf_reg <= wr_data[3:0];
assign wr_en = cs && write;
assign rd_data = 0;
assign dout = buf_reg;        

endmodule
