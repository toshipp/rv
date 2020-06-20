module regcell(input logic clk,
               input logic         reset,
               input logic [31:0]  in,
               input logic         write_enable,
               output logic [31:0] out);
   always_ff @(posedge clk, posedge reset)
     if(reset)
       out <= 0;
     else if(write_enable)
       out <= in;
endmodule
