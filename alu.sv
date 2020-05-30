module alu
  #(parameter N = 32)
   (input logic [2:0] type_,
    input logic [N-1:0]  in1,
    input logic [N-1:0]  in2,
    output logic [N-1:0] out);
   always_comb
     case(type_)
       3'b000: out = in1 + in2;
       3'b001: out = in1 - in2;
       3'b100: out = in1 ^ in2;
       3'b110: out = in1 | in2;
       3'b111: out = in1 & in2;
       default: out = 'bx;
     endcase
endmodule
