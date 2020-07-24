module timer_core(
    input logic clk, reset,

    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,    

    output logic [63:0] counter
);


logic clear, go;
logic [63:0] counter_reg;

always @ (posedge clk)
    if(reset || clear)
        counter_reg <= {-1,-1};
    else if(go)
        counter_reg <= counter_reg + 1;

logic ctrl_reg;

always @ (posedge clk)
    if(reset)
        ctrl_reg <= 0;
    else if(wr_en)
        ctrl_reg <= wr_data[0];

assign wr_en = write && cs && (addr[1:0] ==2'b10);
assign clear = wr_en && wr_data[1];
assign go = ctrl_reg;
assign rd_data = (addr[0] == 0) ? counter[31:0] : counter[63:32];
assign counter = counter_reg;

endmodule