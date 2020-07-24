`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/23/2020 05:24:49 PM
// Design Name: 
// Module Name: rto_core
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


module rto_core
#(
    parameter N_OUT=4
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
    
    input logic [63:0] counter,
    output logic [N_OUT-1:0] dout
);

// ##### Write logic

logic [31:0] time_reg[0:1];
logic wr_en;
assign wr_en = write && cs && (addr < 5'd2);

always @ (posedge clk)
    if(reset) begin
        time_reg[0] <= 0;
        time_reg[1] <= 0;
    end        
    else if(wr_en)
       time_reg[addr[0]] <= wr_data;


logic [63:0] time_out;
logic [31:0] cmd_out;

logic flush;
assign flush = write && cs && addr == 5'd5;

fifo_generator_0 fifo_unit(
    .clk(clk),
    .srst(reset | flush),
    .din({time_reg[1], time_reg[0], wr_data}), // Time + cmd
    .wr_en(write && cs && addr == 5'd2), // If cmd is written
    .rd_en(time_out == counter),
    .dout({time_out, cmd_out}),
    .full(full),
    .empty(empty)
);

//######### rto logic

always @ (posedge clk)
    if(reset)
        dout <= 0;
    else if(time_out == counter)
        dout <= cmd_out[N_OUT-1:0];
        
//####### read logic

logic full, empty;

always @ (*) begin
    rd_data = 0;
    case(addr)
    5'd3: rd_data = {30'b0, full, empty};
    5'd4: rd_data = time_out[31:0];
    5'd5: rd_data = time_out[63:32];
    5'd6: rd_data = cmd_out;
    5'd7: rd_data = dout;
    endcase
end


endmodule
