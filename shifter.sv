module shifter
  #(parameter N = 32)
   (input logic [1:0] type_,
    input logic [N-1:0]  in,
    input logic [4:0]    shift,
    output logic [N-1:0] out);
   always_comb
     case(type_)
       2'b00: out = in << shift;
       2'b01: out = in >> shift;
       2'b10: out = $signed(in) >>> shift;
       default: out = 'bx;
     endcase
endmodule
