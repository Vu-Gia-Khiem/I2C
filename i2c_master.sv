module i2c_master (
  input clk,   
  input rst_n,   
  input [6:0] addr,   
  input rw,  
  input [7:0] data_w,   
  input start,   

  output logic [7:0] data_out,
  output logic valid_out, // READ finish

  output scl,
  inout  sda,

  output logic busy,
  output logic erro_addr
);


enum logic [3:0] {
  IDLE = 4'b0000,
  START = 4'b0111,
  ADDR_RW = 4'b0001,
  R_ACK = 4'b0010,
  T_ACK = 4'b0011,
  WRITE = 4'b0100,
  READ = 4'b0101,
  STOP = 4'b0110
} cur_state, next_state ;

logic en_sda;
logic en_clk;
logic sample_h;  
logic sample_l; 
logic [7:0] reg_addr;
logic [7:0] reg_data_w;
logic reg_sda;
logic reg_rw;
logic [3:0] bit_counter;
logic [7:0] reg_dataout;
logic write_done;
logic done; 


logic load; 
logic shift_addr;
logic shift_w_data;
logic shift_r_data;
logic clear_bit_counter; 
logic plus_bit_couter;
logic stop;
logic send_ack;
logic reg_scl;
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
  shift_addr = 1'b0;
  shift_w_data = 1'b0;
  shift_r_data = 1'b0;
  clear_bit_counter = 1'b0;
  plus_bit_couter = 1'b0;
  stop = 1'b0;
  erro_addr = 1'b0;
  send_ack = 1'b0;
  en_sda = 1'b1;
  scl_n = 1'b0;
  scl_p = 1'b0;
  stop_scl = 1'b0;
  stop_sda = 1'b0;
  valid_out = 1'b0;
  case (cur_state)
  IDLE: begin 
    write_done = 1'b0;
    if (start & !busy) begin
      next_state = START ;
      load = 1'b1;
      en_clk = 1'b1;
    end
  end
  START: begin
    if (sample_h) begin
      scl_n = 1'b1;
    end
    if (sample_l) begin
      scl_n = 1'b1;
      next_state = ADDR_RW;
      shift_addr = 1'b1;
      plus_bit_couter = 1'b1;
    end
  end
  ADDR_RW: begin
    if (sample_l) begin
      scl_n = 1'b1;
      shift_addr = 1'b1;
      if (bit_counter == 8) begin
        clear_bit_counter = 1'b1;
        next_state = R_ACK;
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
    if (sample_h) begin
      if (!sda) begin   // sda_in = 0 <=> R_ACK = 0
        if (write_done) begin
          next_state = STOP;
        end
        else begin
          next_state = reg_rw ? READ : WRITE ;
        end
      end
      else begin
        next_state <= IDLE;
        erro_addr = 1'b1 ;
      end
    end
    if (sample_h) begin
      scl_p = 1'b1;
    end
  end
  WRITE: begin
    if (sample_l) begin
      scl_n = 1'b1;
      shift_w_data = 1'b1;
      if (bit_counter == 8) begin
        clear_bit_counter = 1'b1;
        next_state = R_ACK;
        write_done = 1;
      end
      else 
        plus_bit_couter = 1'b1;
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
        done = 1'b1;
      end
      else
        plus_bit_couter = 1'b1;
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
      done = 1'b0;
    end
  end
  T_ACK: begin
    if (sample_l) begin
      scl_n = 1'b1;
      next_state = STOP;
      send_ack = 1;
    end
    if (sample_l) begin
     scl_n = 1'b1;
    end
    if (sample_h) begin
     scl_p = 1'b1;
    end
  end
  STOP: begin
    if (sample_h) begin
      stop_scl = 1'b1;
      // en_sda = 1'b0;
    end
    if (sample_l) begin
      en_sda = 1'b0;
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
    en_clk <= 1'b0;
    done <= 1'b0;
  end 
  else begin
    if (load) begin
      reg_data_w <= data_w ;
      reg_addr <= {addr, rw};
      reg_rw <= rw ;
      reg_sda <= 1'b0;
      busy <= 1'b1;
      reg_scl <= 1'b1;
    end
    if (scl_n) begin
      reg_scl <= 1'b0;
    end
    if (scl_p) begin
      reg_scl <= 1'b1;
    end
    if (shift_addr) begin
      reg_sda <= reg_addr[7];
      reg_addr <= {reg_addr[6:0], 1'b0};
    end

    if (shift_w_data) begin
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
  end
end

assign sda = en_sda ? reg_sda : 1'bz;
assign data_out = valid_out ? reg_dataout : 0;
assign scl = reg_scl ;
endmodule