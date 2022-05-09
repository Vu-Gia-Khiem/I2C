module i2c_master (
  input clk,   
  input rst_n,   
  input [6:0] addr,   
  input rw,  
  input [7:0] data_w,   
  input start,   
  input [3:0] N_byte,


  output logic [7:0] data_out,
  output logic valid_out, 
  output scl,
  inout  sda,

  output logic busy,
  output logic erro_addr
);


enum logic [3:0] {
  IDLE  = 4'd0,
  START = 4'd1,
  ADDR_SLAVE = 4'd2,
  R_ACK = 4'd3,
  WRITE = 4'd5,
  READ = 4'd6,
  T_ACK = 4'd7,
  STOP = 4'd8
} cur_state, next_state ;

logic en_sda;
logic en_clk;
logic sample_h;  
logic sample_l; 

logic [7:0] reg_data_w;
logic [7:0] reg_dataout;
logic reg_rw;
logic [7:0] reg_N_byte;
logic [7:0] reg_addr;

logic reg_sda;
logic reg_scl;
logic [3:0] bit_counter;
logic write_done;
logic done; 
logic rack_done;

logic load; 
logic load_data_w;
logic shift_addr_slave;
logic shift_w_data;
logic shift_r_data;
logic shift_addr_rw;
logic clear_bit_counter; 
logic plus_bit_couter;
logic begin_stop;
logic send_ack;


logic scl_n;
logic scl_p;
logic stop_scl;
logic stop_sda;

div_clk div_clk(
  .clk(clk),
  .en_clk(en_clk),
  .rst_n(rst_n),
  .sample_h(sample_h),
  .sample_l(sample_l)
);

always_ff @(posedge clk, negedge rst_n) begin 
  if(~rst_n) begin
    cur_state <= IDLE;
  end 
  else begin
    cur_state <= next_state ;
  end
end

always_comb begin 
  load = 1'b0;
  load_data_w = 1'b0;
  shift_addr_slave = 1'b0;
  shift_addr_rw = 1'b0;
  shift_w_data = 1'b0;
  shift_r_data = 1'b0;
  clear_bit_counter = 1'b0;
  plus_bit_couter = 1'b0;
  begin_stop = 1'b0;
  erro_addr = 1'b0;
  send_ack = 1'b0;
  en_sda = 1'b1;
  scl_n = 1'b0;
  scl_p = 1'b0;
  stop_scl = 1'b0;
  stop_sda = 1'b0;
  valid_out = 1'b0;
  write_done = 1'b0;
  case (cur_state)
  IDLE: begin
    if (start & !busy) begin
      next_state = START ;
      load = 1'b1;
      load_data_w = 1'b1;
      en_clk = 1'b1;
    end
  end
  START: begin
    if (sample_h) begin
      scl_n = 1'b1;
    end
    if (sample_l) begin
      scl_n = 1'b1;
      next_state = ADDR_SLAVE;
      shift_addr_slave = 1'b1;
      plus_bit_couter = 1'b1;
    end
  end
  ADDR_SLAVE: begin 
    if (sample_l) begin
      scl_n = 1'b1;
      shift_addr_slave = 1'b1;
      if (bit_counter == 8) begin
        clear_bit_counter = 1'b1;
        next_state = R_ACK;
        load_data_w = 1'b1;
      end
      else begin
       plus_bit_couter = 1'b1;
      end
    end
    if (sample_h) begin
      scl_p = 1'b1;
    end
  end
  R_ACK: begin 
    en_sda = 1'b0;
    if (sample_l) begin
    scl_n = 1'b1;   
      if (!sda) begin   
        rack_done = 1'b1;
      end
      else begin
        next_state = STOP;
        erro_addr = 1'b1 ;
      end
    end
    if (sample_l & rack_done) begin
        scl_n = 1'b1;   
      if (reg_rw == 1'b0) begin  
        if (reg_N_byte != 0) begin
          next_state = WRITE;
          shift_w_data = 1'b1;
          plus_bit_couter = 1'b1;
        end
        else begin
          begin_stop = 1'b1;
          next_state = STOP;
        end
      end
      else begin
        if (reg_N_byte != 0) begin
          next_state = READ;
        end
        else begin
          begin_stop = 1'b1;
          next_state = STOP;
        end
      end
    end
    if (sample_l) begin
      scl_n = 1'b1;
    end
    if (sample_h) begin
      scl_p = 1'b1;
    end
  end
  WRITE: begin                      
    if (sample_l) begin
      scl_n = 1'b1;
      if (bit_counter == 8) begin
        clear_bit_counter = 1'b1;
        write_done = 1'b1;
        next_state = R_ACK;
        load_data_w = 1'b1;
      end
      else begin
        plus_bit_couter = 1'b1; 
        shift_w_data = 1'b1;
      end
    end
    if (sample_h) begin
    scl_p = 1'b1;
  end
  end
  READ: begin
    en_sda = 0;
    if (sample_h) begin
      shift_r_data = 1'b1;
      if (bit_counter == 7) begin
        clear_bit_counter = 1'b1;
        shift_r_data = 1'b1;
        write_done = 1'b1;
        done = 1'b1;
      end
      else begin
        plus_bit_couter = 1'b1;
      end
    end
    if (sample_l) begin
     scl_n = 1'b1;
    end
    if (sample_h) begin
     scl_p = 1'b1;
    end
    if (done & sample_l) begin
      next_state = T_ACK ;
      valid_out = 1'b1;
      send_ack = 1'b1;
      done = 1'b0;
    end
  end
  T_ACK: begin
    if (sample_l) begin
      scl_n = 1'b1;
      if (reg_N_byte != 0) begin
        next_state = READ;
      end
      else begin
        en_sda = 1'b1;
        begin_stop = 1'b1;
        next_state = STOP;
      end
    end
    if (sample_l) begin
     scl_n = 1'b1;
    end
    if (sample_h) begin
     scl_p = 1'b1;
    end
  end
  STOP: begin
      en_sda = 1'b1;
    if (sample_h) begin
      stop_scl = 1'b1;
    end
    if (sample_l) begin
      stop_sda = 1'b1;
      next_state = IDLE;
      en_clk = 1'b0;
    end
  end
    default : next_state = IDLE;
  endcase
end

always_ff @(posedge clk, negedge rst_n) begin 
  if(~rst_n) begin
    bit_counter <= 0;
    busy <= 1'b0;
    reg_sda <= 1'b1;
    reg_scl <= 1'b1;
  end 
  else begin
    if (load) begin
      reg_addr <= {addr, rw};
      reg_rw <= rw ;
      reg_N_byte <= N_byte;
      reg_sda <= 1'b0;
      busy <= 1'b1;
      reg_scl <= 1'b1;
    end
    if (load_data_w) begin
      reg_data_w <= data_w;
    end
    if (scl_n) begin
      reg_scl <= 1'b0;
    end
    if (scl_p) begin
      reg_scl <= 1'b1;
    end
    if (shift_addr_slave) begin
      reg_sda <= reg_addr[7];
      reg_addr <= {reg_addr[6:0], 1'b0};
    end
    if (shift_w_data | shift_addr_rw) begin
      reg_sda <= reg_data_w[7];
      reg_data_w <= {reg_data_w[6:0], 1'b0};
    end
    if (shift_r_data) begin
      reg_dataout <= {reg_dataout[6:0] ,sda };
    end
    if (clear_bit_counter) begin
      bit_counter <= 0;
    end
    if (plus_bit_couter) begin
      bit_counter <= bit_counter + 1'b1;
    end
    if (stop_scl) begin
      reg_scl <= 1'b1;
      reg_sda <= 1'b0;
      busy <= 1'b1;
    end
    if(begin_stop) begin
      reg_sda <= 1'b0;
    end
    if (stop_sda) begin
      reg_sda <= 1'b1;
      busy <= 1'b0;
    end
    if (erro_addr) begin
      busy <= 1'b0;
    end
    if (send_ack) begin
      reg_sda = 1'b0;
    end
    if (write_done) begin
      reg_N_byte <= reg_N_byte - 1'b1;
    end
  end
end

assign sda = en_sda ? reg_sda :   1'bz;
assign data_out = valid_out ? reg_dataout : 0;
assign scl = reg_scl ;
endmodule
