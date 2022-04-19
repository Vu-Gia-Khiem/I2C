module tb_i2c_top;
logic clk;
logic rst_n;   
logic [6:0] addr;   
logic rw ;
logic [39:0] data_w;   
logic start;   
logic [7:0] data_out;
logic valid_out; 
wire scl;
wire sda;
logic busy;
logic erro_addr ;
logic [3:0] N_byte;

    i2c_top  i2c_top(
        .*
    );

    pullup p1(scl);
    pullup p2(sda);
    
always #20 clk = !clk;

initial begin
    addr = 7'b0010001;  ///erro addr
    N_byte = 4'd4;      ///write 5 byte
    data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    start = 1'b0;
    rw = 0;
    clk = 1'b1;
    rst_n = 1'b0;
    #40; 
    start = 1'b1;
    rst_n = 1'b1;
    #50;
    start = 1'b0;

    #50000;             /// true addr, write data

    addr = 7'b0010000;
    N_byte = 4'd4;  /// write 5 byte
    data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    start = 1'b0;
    rw = 0;    
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;

    #50000;     /// write addr_men
    addr = 7'b0010000;
    rw = 1'b0;  
    N_byte = 4'd0;  /// write 1 byte setup addr_men
    data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;

    #20000;

    rw = 1'b1;      /// read data
    N_byte = 4'd3;
    data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;
    #50000;
    $finish;

end
endmodule
