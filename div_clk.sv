module div_clk (
  input clk,
  input en_clk,
  input rst_n,
  output logic sample_l       
);

reg [5:0] count ;
reg       high ;
always_ff @(posedge clk, negedge rst_n) begin 
  if(~rst_n) begin
    count <= 0;
    high <= 1'b1;
  end 
  else begin
  if(en_clk) begin
    count <= (count == 5) ? 0 : count + 1'b1 ;
    high  <= (count == 5) ? !high : high ;
  end
  else
    count <= 0 ;
end
end

assign sample_h = ( count == 5 ) & high;
assign sample_l = ( count == 5 ) & !high;

endmodule