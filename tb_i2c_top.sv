module tb_i2c_top;
logic clk;
logic rst_n;   
logic [6:0] addr;   
logic rw ;
logic [7:0] data_w;   
logic start;   
logic [7:0] data_out;
logic valid_out; // READ finish
logic t_sda;
wire scl;
wire sda;
logic busy;
logic erro_addr ;

    i2c_top  dut(
        .*
    );

    pullup p1(scl);
    pullup p2(sda);

//assign sda = !dut.en_sda ? t_sda : 1'bz;
 
always #20 clk = !clk;

initial begin
    addr = 7'b0010000;
    data_w = 8'd0;
    start = 1'b0;
    rw = 1;
    clk = 1'b1;
    rst_n = 1'b0;
    #40;
    rst_n = 1'b1;
    #100;
    start = 1'b1;
    #50;
    start = 1'b0;
//    repeat(9) begin
//      @(negedge dut.sample_l);
//    end
//    t_sda = 0;
//    repeat(9) begin
//      @(negedge dut.sample_l);
//    end
    t_sda = 0;
    #50000;
    $finish;

end
endmodule