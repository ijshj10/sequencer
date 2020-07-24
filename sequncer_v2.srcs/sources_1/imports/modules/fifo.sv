
module fifo_ctrl
#(
    parameter ADDR_WIDTH = 5
)
(
    input logic clk, reset,
    input logic rd, wr,
    output logic empty, full,
    output logic [ADDR_WIDTH-1:0] w_addr,
    output logic [ADDR_WIDTH-1:0] r_addr
);

logic [ADDR_WIDTH-1:0] w_ptr_reg, w_ptr_next, w_ptr_succ;
logic [ADDR_WIDTH-1:0] r_ptr_reg, r_ptr_next, r_ptr_succ;
logic full_reg, full_next, empty_reg, empty_next;

always @ (posedge clk)
    if(reset) begin
        w_ptr_reg <= 0;
        r_ptr_reg <= 0;
        full_reg <= 0;
        empty_reg <= 1;
    end
    else begin
        w_ptr_reg <= w_ptr_next;
        r_ptr_reg <= r_ptr_next;
        full_reg <= full_next;
        empty_reg <= empty_next;
    end

always @ (*) begin
    w_ptr_succ = w_ptr_reg + 1;
    r_ptr_succ = r_ptr_reg + 1;
    
    w_ptr_next = w_ptr_reg;
    r_ptr_next = r_ptr_reg;
    full_next = full_reg;
    empty_next = empty_reg;
    
    case({wr, rd})
    2'b01: // read
        if(~empty_reg) begin
            r_ptr_next = r_ptr_succ;
            full_next = 0;
            if(r_ptr_succ == w_ptr_reg)
                empty_next = 1;
        end
    2'b10: //write
        if(~full_reg) begin
            w_ptr_next = w_ptr_succ;
            empty_next = 0;
            if(w_ptr_succ == r_ptr_reg)
                full_next = 1;
        end
    2'b11: // read and write
    begin
        w_ptr_next = w_ptr_succ;
        r_ptr_next = r_ptr_succ;
    end
    default:;
    endcase
end

assign w_addr = w_ptr_reg;
assign r_addr = r_ptr_reg;
assign full = full_reg;
assign empty = empty_reg;
endmodule

module fifo
#(
    parameter
        DATA_WIDTH = 8,
        ADDR_WIDTH = 5
)
(
    input logic clk, reset,
    input logic rd, wr,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic full, empty,
    output logic [DATA_WIDTH-1:0] r_data
);

logic [ADDR_WIDTH-1:0] w_addr, r_addr;
logic wr_en, full_tmp;

assign wr_en = wr & ~full_tmp;
assign full = full_tmp;

fifo_ctrl #(.ADDR_WIDTH(ADDR_WIDTH)) fifo_ctrl_unit(
    .*, .full(full_tmp)
);

register_file #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH(ADDR_WIDTH)) register_file_unit(.*);

endmodule

