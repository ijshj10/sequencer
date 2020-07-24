module sym_top;

logic clk=1;
logic reset = 0;
logic cs, read, write;
logic [31:0] rd_data, wr_data;
logic [5:0 ] reg_addr;
logic rx;
logic tx;

uart_core uart_slot_1(
    .*
);

always #5 clk = ~clk;

initial begin
    reset = 1;
    #15 reset = 0;
    cs = 1;
    write = 1;
    wr_data = {24'b0, 8'b01010101};
    reg_addr = 1;
end
    



endmodule