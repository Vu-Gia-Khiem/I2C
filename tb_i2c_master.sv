 module tb_i2c_master ();
   logic clk;
   logic rst_n;
   logic [6:0] addr;
   logic rw;
   logic [7:0] data_w;
   logic start;
   logic [7:0] data_out; 
   logic valid_out; 
   logic scl; 
   wire  sda; 
   logic busy;
   logic erro_addr;
   logic  t_sda;
   logic [3:0] N_byte;

   i2c_master dut (
     .clk(clk),
     .rst_n(rst_n),
     .addr(addr),
     .rw(rw),
     .data_w(data_w),
     .start(start),
     .data_out(data_out),
     .valid_out (valid_out ),
     .scl(scl),
     .sda(sda),
     .t_sda(t_sda),
     .busy(busy),
     .erro_addr(erro_addr)
     );
 assign sda = !dut.en_sda ? t_sda : 1'bz;
   always #20 clk = !clk ;
   initial begin
     addr = 7'b0010000;
     data_w = 8'd0;
     start = 1'b0;
     rw = 0;
     clk = 1'b1;
     rst_n = 1'b0;
     #40;
     rst_n = 1'b1;
     #100;
     start = 1'b1;
     #50;
     start = 1'b0;
     repeat(9) begin
       @(negedge dut.sample_l);
     end
     t_sda = 0;
     repeat(9) begin
       @(negedge dut.sample_l);
     end
     t_sda = 0;
     #5000;
     $finish;
   end

 endmodule





//module tb_i2c_master ();
//  logic clk;
//  logic rst_n;
//  logic [6:0] addr;
//  logic rw;
//  logic [7:0] data_w;
//  logic start;
//  logic [7:0] data_out; 
//  logic valid_out; 
//  logic scl; 
//  wire sda; 
//  logic busy;
//  logic erro_addr;
//  logic t_sda;

//  i2c_master dut (
//    .clk(clk),
//    .rst_n(rst_n),
//    .addr(addr),
//    .rw(rw),
//    .data_w(data_w),
//    .start(start),
//    .data_out(data_out),
//    .valid_out(valid_out),
//    .scl(scl),
//    .sda(sda),
//    .t_sda(t_sda),
//    .busy(busy),
//    .erro_addr(erro_addr)
//    );
//// assign sda = !dut.en_sda ? t_sda : 1'bz;
//  always #20 clk = !clk ;
//  initial begin
//    addr = 7'b1011001;
//    data_w = 8'b10100101;
//    start = 1'b0;
//    rw = 1;
//    clk = 1'b1;
//    rst_n = 1'b0;
//    #40;
//    rst_n = 1'b1;
//    #100;
//    start = 1'b1;
//    #50;
//    start = 1'b0;
//    repeat(9) begin
//      @(negedge dut.sample_l);
//    end
//    t_sda = 0;
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 1;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 0;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 1;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda =0;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 1;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 1;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 0;
//    end
//    @(negedge dut.sample_l);
//    begin
//      t_sda = 1;
//    end
//    repeat(9) begin
//      @(negedge dut.sample_l);
//    end
//    t_sda = 0;
//    #5000;
//    $finish;
//  end

//endmodule