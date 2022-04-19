module i2c_top(
  input clk,   
  input rst_n,   
  input [6:0] addr,   
  input rw,  
  input [7:0] data_w,   
  input start,   
  input t_sda,      /////////////////////

  output logic [7:0] data_out,
  output logic valid_out, // READ finish

  inout scl,
  inout  sda,

  output logic busy,
  output logic erro_addr    
);

i2c_master i2c_master(
    .*
);

i2c_slave_model i2c_slave_model(
    .*
);

endmodule