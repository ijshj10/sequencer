module top(
    input logic CLK100MHZ,
    input logic ck_rst, // active low reset
    
    input logic uart_txd_in, // Confusing name
    output logic uart_rxd_out,
    
    output logic [3:0] led,
    input logic [3:0] btn,
    input logic [3:0] sw
    );

logic clk;
assign clk = CLK100MHZ;
logic reset;
assign reset = ~ck_rst;

logic io_addr_strobe;
logic io_read_strobe;
logic io_write_strobe;
logic [3:0] io_byte_enable;
logic [31:0] io_address;
logic [31:0] io_read_data;
logic [31:0] io_write_data;
logic io_ready;

logic mmio_cs;
logic fp_wr;
logic fp_rd;
logic [20:0] fp_addr;
logic [31:0] fp_wr_data;
logic [31:0] fp_rd_data;

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
.IO_write_strobe(io_write_strobe)
);



mcs_bridge mcs_bridge_unit(.*);
mmio_sys_vanila#(4,8) mmio_unit(
    .*,
    .mmio_wr(fp_wr),
    .mmio_rd(fp_rd),
    .mmio_addr(fp_addr),
    .mmio_wr_data(fp_wr_data),
    .mmio_rd_data(fp_rd_data),
    .sw({sw,btn}),    
    .led(led),
    .rx(uart_txd_in),
    .tx(uart_rxd_out)
);
endmodule