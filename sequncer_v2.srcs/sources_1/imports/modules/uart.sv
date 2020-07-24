
module baud_gen (
    input logic clk, reset,
    input logic [10:0] dvsr, // dvsr = clk_freq/(baudrate*16) - 1
    output logic tick
);

logic [10:0] r_reg;
logic [10:0] r_next;

always @ (posedge clk)
    if(reset)
        r_reg <= 0;
    else
        r_reg <= r_next;
assign r_next = (r_reg == dvsr) ? 0 : r_reg + 1;
assign tick = (r_reg == 1);
endmodule


module uart_rx(
    input logic clk, reset,
    input logic rx, s_tick,
    output logic rx_done_tick,
    output logic [7:0] dout
);

typedef enum {idle, start, data, stop} state_type;

state_type state_reg, state_next;
logic [3:0] s_reg, s_next;
logic [2:0] n_reg, n_next;
logic [7:0] b_reg, b_next;

always @ (posedge clk)
    if(reset) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
    end
    else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end

always @ (*) begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    rx_done_tick = 0;
    case(state_reg)
    idle:
        if(~rx) begin
            state_next = start;
            s_next = 0;
        end
    start:
        if(s_tick)
            if(s_reg == 7) begin
                state_next = data;
                s_next = 0;
                n_next = 0;
            end
            else
                s_next = s_reg + 1;
    data:
        if(s_tick)
            if(s_reg == 15) begin
                s_next = 0;
                n_next = n_reg + 1;
                b_next = {rx, b_next[7:1]};
                if(n_reg == 7)
                    state_next = stop;
            end
            else
                s_next = s_reg + 1;
    stop:
        if(s_tick)
            if(s_reg == 15) begin
                rx_done_tick = 1;
                state_next = idle;
            end
            else
                s_next = s_reg + 1;
    endcase
end
assign dout = b_reg;

endmodule

module uart_tx (
    input logic clk, reset,
    input logic tx_start, s_tick,
    input logic [7:0] din,
    output logic tx_done_tick,
    output logic tx
);

typedef enum {idle, start, data, stop} state_type;

state_type state_reg, state_next;
logic [3:0] s_reg, s_next;
logic [2:0] n_reg, n_next;
logic [7:0] b_reg, b_next;

always @ (posedge clk)
    if(reset) begin
        state_reg <= idle;
        s_reg <= 0;
        n_reg <= 0;
        b_reg <= 0;
    end
    else begin
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
    end

always @ (*) begin
    state_next = state_reg;
    s_next = s_reg;
    n_next = n_reg;
    b_next = b_reg;
    tx_done_tick = 0;
    tx = 1;
    case (state_reg)
    idle:
        if(tx_start) begin
            state_next = start;
            b_next = din;
            s_next = 0;
        end
    start: begin
        tx = 0;
        if(s_tick)
            if(s_reg == 15) begin
                state_next = data;
                n_next = 0;
                s_next = 0;
            end
            else
                s_next = s_reg + 1;
    end
    data: begin
        tx = b_reg[0];
        if(s_tick)
            if(s_reg == 15) begin
                s_next = 0;
                n_next = n_reg + 1;
                b_next = b_reg >> 1;
                if(n_reg == 7)
                    state_next = stop;
            end
            else
                s_next = s_reg + 1;
    end
    stop: begin
        tx = 1;
        if(s_tick)
            if(s_reg == 15) begin
                state_next = idle;
                tx_done_tick = 1;
            end
            else
                s_next = s_reg + 1;
    end
    endcase
end

endmodule


module uart 
#(
    parameter FIFO_W = 8
)
(
    input logic clk, reset,
    input logic rd_uart, wr_uart, rx,
    input logic [7:0] w_data,
    input logic [10:0] dvsr,
    output logic tx_full, rx_empty, tx,
    output logic [7:0] r_data
);

logic tick, rx_done_tick, tx_done_tick;
logic tx_empty;
logic [7:0] tx_fifo_out, rx_data_out;
logic tx_not_empty;
assign tx_not_empty = ~tx_empty;

baud_gen baud_gen_unit(.*);
uart_rx uart_rx_unit(.*, .s_tick(tick), .dout(rx_data_out));
uart_tx uart_tx_unit(.*, .s_tick(tick), .din(tx_fifo_out), .tx_start(tx_not_empty));
fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(FIFO_W)) rx_fifo_unit(
    .*, .rd(rd_uart), .wr(rx_done_tick), .w_data(rx_data_out), .empty(rx_empty), .full(), .r_data(r_data)
);
fifo #(.DATA_WIDTH(8), .ADDR_WIDTH(FIFO_W)) tx_fifo_unit(
    .*, .rd(tx_done_tick), .wr(wr_uart), .w_data(w_data), .empty(tx_empty), .full(tx_full), .r_data(tx_fifo_out)
);

endmodule

module uart_core
#(
    parameter FIFO_DEPTH = 8
)
(
    input logic clk, reset,

    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    output logic tx,
    input logic rx
);

logic wr_uart, rd_uart, wr_dvsr;
logic tx_full, rx_empty;
logic [10:0] dvsr_reg;
logic [7:0] r_data;
logic ctrl_reg;

uart #(.FIFO_W(FIFO_DEPTH)) uart_unit(.*, .dvsr(dvsr_reg), .w_data(wr_data[7:0]));

always @ (posedge clk)
    if(reset)
        dvsr_reg <= 53;
    else if (wr_dvsr)
        dvsr_reg <= wr_data[10:0];

assign wr_dvsr = (write & cs & (addr[1:0] == 2'b01));
assign wr_uart = (write & cs & (addr[1:0] == 2'b10));
assign rd_uart = (write && cs && (addr[1:0] == 2'b11));
assign rd_data = {22'b0, tx_full, rx_empty, r_data};

endmodule