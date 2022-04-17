module tb_div_clk ();
  logic      clk       ;
  logic      en_clk    ;
  logic      rst_n     ;
  logic      scl_posedge  ;
  logic      scl_negedge  ;

  div_clk div_clk (
    .clk       (clk      )  ,
    .en_clk    (en_clk   )  ,
    .rst_n     (rst_n    )  ,
    .scl_posedge  (scl_posedge )  ,
    .scl_negedge  (scl_negedge )  
    );
  always #20 clk = !clk ;
  initial begin
    clk = 1;
    rst_n = 1;
    en_clk = 0;
    #10
    rst_n = 0;
    #50
    rst_n = 1;
    #50;
    en_clk = 1 ;
  end
endmodule : tb_div_clk