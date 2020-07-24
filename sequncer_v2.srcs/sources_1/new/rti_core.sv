`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/23/2020 09:14:30 PM
// Design Name: 
// Module Name: rti_core
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


module rti_core
#(
    parameter N_IN=4
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
    output logic [N_IN-1:0] din
);

logic [N_IN-1:0] buffer; // Prevent metastable
logic [N_IN-1:0] prev;

always @(posedge clk) begin
    buffer <= din;
    prev <= buffer;
end

logic wr_en;
assign wr_en = write && cs && (addr==5'd4);
logic flush;
assign flush = write && cs && (addr == 5'd5);

logic full, empty;

logic [31:0] timer_upper, timer_lower, edges;

fifo_generator_0 fifo_unit(
    .clk(clk),
    .srst(reset | flush),
    .din({counter,{(32-2*N_IN){0}}, buffer}),
    .wr_en(|(buffer & ~prev)), 
    .rd_en(wr_en),
    .dout({timer_upper, timer_lower, edges}),
    .full(full),
    .empty(empty)
);

always @ (*)
    case(addr)
    5'd0:
        rd_data = timer_lower;
    5'd1:
        rd_data = timer_upper;
    5'd2:
        rd_data = edges;
    5'd3:
        rd_data = {30'b0, full, empty};
    default:
        rd_data = 0;  
    endcase
    



endmodule
