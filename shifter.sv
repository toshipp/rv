`include "shifter.h"

module shifter
  #(parameter N = 32)
   (input logic [1:0] type_,
    input logic [N-1:0]  in,
    input logic [4:0]    shift,
    output logic [N-1:0] out);
   always_comb
     case(type_)
       `SHIFT_LEFT: out = in << shift;
       `SHIFT_RIGHT: out = in >> shift;
       `SHIFT_ARITH: out = $signed(in) >>> shift;
       default: out = 'bx;
     endcase
endmodule
