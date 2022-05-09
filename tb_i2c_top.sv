`timescale 1ns/1ps
module tb_i2c_top;
logic clk;
logic rst_n;   
logic [6:0] addr;   
logic rw ;
logic [7:0] data_w;   
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
    // data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    data_w = 8'd0;////////////////////
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
    start = 1'b1;
    addr = 7'b0010000;
    N_byte = 4'd5;  /// write 5 byte
    @(posedge clk);
    start = 1'b0;
 //    data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
     @(posedge clk);
     wait(i2c_top.i2c_master.load_data_w==1);
    @(posedge clk);
    data_w = 8'd0;///////////////////
    @(posedge clk);
    wait(i2c_top.i2c_master.load_data_w==1);
    @(posedge clk);
    data_w = 8'd3;///////////////////
    @(posedge clk);
    wait(i2c_top.i2c_master.load_data_w==1);
    @(posedge clk);
    data_w = 8'd5;///////////////////
        @(posedge clk);
    wait(i2c_top.i2c_master.load_data_w==1);
    @(posedge clk);
    data_w = 8'd7;///////////////////
     @(posedge clk);
    wait(i2c_top.i2c_master.load_data_w==1);
    @(posedge clk);
    data_w = 8'd9;///////////////////
    @(posedge clk);
    start = 1'b0;
    // READ
    #50000;     /// write addr_me
    rw = 1'b0;
    data_w = 8'b0;
    addr = 7'b0010000;
    N_byte = 4'd1;
    // data_w = {8'b0000_0000, 8'd3, 8'd5, 8'd7, 8'd9};
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;
    #50000;

    rw = 1'b1;
    addr = 7'b0010000;
    N_byte = 4'd4;
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;
    #500000;
    $finish;

end
endmodule
