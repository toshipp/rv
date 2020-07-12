module regcell
  #(parameter N = 32)
   (input logic clk,
    input logic [N-1:0]  in,
    input logic          write_enable,
    output logic [N-1:0] out);
   always_ff @(posedge clk)
     if(write_enable)
       out <= in;
endmodule
