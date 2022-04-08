`timescale 1ns/1ps
module tb_I2C_master;
logic  clk, reset, rw, ack, ack2;
logic [6:0] addr;
logic [7:0] data_master, data_slave;
logic i2c_scl, i2c_sda;

I2C_master I2C_master(
    .clk(clk),
    .reset(reset),
    .rw(rw),
    .ack(ack),
    .ack2(ack2),
    .addr(addr),
    .data_master(data_master),
    .data_slave(data_slave),
    .i2c_scl(i2c_scl),
    .i2c_sda(i2c_sda)
);

always #5 clk = !clk;

initial begin
    clk     = 1'b0;
    reset   = 1'b0;
    rw      = 1'b0;
    ack     = 1'b0;
    ack2    = 1'b0;
    addr    = 7'b1100110;
    data_master = 8'b11100111;
    data_slave  = 8'b10101010;
    #5;
    clk     = 1'b1;
    reset   = 1'b1;
end

endmodule