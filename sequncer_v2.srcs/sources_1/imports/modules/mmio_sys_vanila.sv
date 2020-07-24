`include "io_map.svh"
`define S2_GPO 2
`define S3_GPI 3
`define S4_RTO 4
`define S5_RTI 5

module mmio_sys_vanila
#(
    parameter N_SW = 4,
    parameter N_LED = 4,
    parameter N_OUT = 4,
    parameter N_IN = 4
)
(
    input logic clk, reset,

    input logic mmio_cs,
    input logic mmio_wr,
    input logic mmio_rd,
    input logic [20:0] mmio_addr,
    input logic [31:0] mmio_wr_data,
    output logic [31:0] mmio_rd_data,

    input logic [N_SW-1:0] sw,
    output logic [N_LED-1:0] led,

    input logic rx,
    output logic tx
);

logic [63:0] mem_rd_array;
logic [63:0] mem_wr_array;
logic [63:0] cs_array;
logic [4:0] reg_addr_array[63:0];
logic [31:0] rd_data_array[63:0];
logic [31:0] wr_data_array[63:0];

logic [63:0] counter;

mmio_controller ctrl_unit
(
    .clk(clk),
    .reset(reset),
    .mmio_cs(mmio_cs),
    .mmio_wr(mmio_wr),
    .mmio_rd(mmio_rd),
    .mmio_addr(mmio_addr),
    .mmio_wr_data(mmio_wr_data),
    .mmio_rd_data(mmio_rd_data),

    .slot_cs_array(cs_array),
    .slot_rd_array(mem_rd_array),
    .slot_wr_array(mem_wr_array),
    .slot_reg_addr_array(reg_addr_array),
    .slot_rd_data_array(rd_data_array),
    .slot_wr_data_array(wr_data_array)
);

timer_core timer_slot_0(
    .*,
    .cs(cs_array[`S0_SYS_TIMER]),
    .read(mem_rd_array[`S0_SYS_TIMER]),
    .write(mem_wr_array[`S0_SYS_TIMER]),
    .addr(reg_addr_array[`S0_SYS_TIMER]),
    .rd_data(rd_data_array[`S0_SYS_TIMER]),
    .wr_data(wr_data_array[`S0_SYS_TIMER]),
    .counter(counter)
);

uart_core uart_slot_1(
    .*,
    .cs(cs_array[`S1_UART1]),
    .read(mem_rd_array[`S1_UART1]),
    .write(mem_wr_array[`S1_UART1]),
    .addr(reg_addr_array[`S1_UART1]),
    .rd_data(rd_data_array[`S1_UART1]),
    .wr_data(wr_data_array[`S1_UART1]),
    .tx(tx),
    .rx(rx)
);

gpo_core#(N_LED)
 gpo_slot_2
(
    .*,
    .cs(cs_array[`S2_GPO]),
    .read(mem_rd_array[`S2_GPO]),
    .write(mem_wr_array[`S2_GPO]),
    .addr(reg_addr_array[`S2_GPO]),
    .rd_data(rd_data_array[`S2_GPO]),
    .wr_data(wr_data_array[`S2_GPO]),
    .dout()
);

gpi_core#(N_SW) gpi_slot_3
(
    .*,
    .cs(cs_array[`S3_GPI]),
    .read(mem_rd_array[`S3_GPI]),
    .write(mem_wr_array[`S3_GPI]),
    .addr(reg_addr_array[`S3_GPI]),
    .rd_data(rd_data_array[`S3_GPI]),
    .wr_data(wr_data_array[`S3_GPI]),
    .din(sw)
);



rto_core#(N_OUT) rto_slot_4
(
    .*,
    .cs(cs_array[`S4_RTO]),
    .read(mem_rd_array[`S4_RTO]),
    .write(mem_wr_array[`S4_RTO]),
    .addr(reg_addr_array[`S4_RTO]),
    .rd_data(rd_data_array[`S4_RTO]),
    .wr_data(wr_data_array[`S4_RTO]),
    .dout(led),
    .counter(counter)
);

rti_core#(N_IN) rti_slot_5
(
    .*,
    .cs(cs_array[`S5_RTI]),
    .read(mem_rd_array[`S5_RTI]),
    .write(mem_wr_array[`S5_RTI]),
    .addr(reg_addr_array[`S5_RTI]),
    .rd_data(rd_data_array[`S5_RTI]),
    .wr_data(wr_data_array[`S5_RTI]),
    .din(sw),
    .counter(counter)
);     

     


generate
    genvar i;
    for(i=6; i<64; i=i+1)
    begin
        assign rd_data_array[i] = 32'hffffffff;
    end
endgenerate


endmodule