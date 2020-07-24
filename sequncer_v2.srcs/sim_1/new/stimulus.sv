`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2020 08:57:03 PM
// Design Name: 
// Module Name: stimulus
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


module stimulus;



logic clk = 1;
logic reset = 1;
/*logic cs = 1;
logic read=0;
logic write=0;
logic [4:0] addr = 2;
logic [31:0] wr_data = 8'b01010101;
logic [31:0] rd_data;
logic tx;
logic rx;
assign rx = tx;*/

always #5 clk = ~clk;


logic io_addr_strobe;
logic io_read_strobe;
logic io_write_strobe;
logic [3:0] io_byte_enable;
logic [31:0] io_address;
logic [31:0] io_read_data;
logic [31:0] io_write_data;
logic io_ready;


cpu cpu0(
.Clk(clk),
.Reset(reset),
.IO_addr_strobe(io_addr_strobe),
.IO_address(io_address),
.IO_byte_enable(io_byte_enable),
.IO_read_data(io_read_data),
.IO_read_strobe(io_read_strobe),
.IO_ready(io_ready),
.IO_write_data(io_write_data),
.IO_write_strobe(io_wrtie_strobe)
);

initial begin
    reset = 0;
end


endmodule
