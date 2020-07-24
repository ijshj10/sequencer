`include "io_map.svh"

module mcs_bridge
#(parameter BRIDGE_BASE = 32'hc000_0000)
(
    //Microblaze mcs bus
    input logic io_addr_strobe,
    input logic io_read_strobe,
    input logic io_write_strobe,
    input logic [31:0] io_address,
    input logic [31:0] io_write_data,
    output logic [31:0] io_read_data,

    input logic [3:0] io_byte_enable, // not used
    output logic io_ready, // not used

    //Fpro bus
    output logic mmio_cs,
    output logic fp_wr,
    output logic fp_rd,
    output logic [20:0] fp_addr,
    output logic [31:0] fp_wr_data,
    input logic [31:0] fp_rd_data
);

logic mcs_bridge_en;


assign mcs_bridge_en = (io_address[31:24] == BRIDGE_BASE[31:24]);
assign mmio_cs = (mcs_bridge_en && io_address[23] == 0);
assign fp_addr = io_address[22:2];

assign fp_rd = io_read_strobe;
assign fp_wr = io_write_strobe;
assign io_ready = 1; 

assign fp_wr_data = io_write_data;
assign io_read_data = fp_rd_data;


endmodule