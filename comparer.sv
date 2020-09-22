`include "comparer.h"

module comparer #(
    parameter N = 32
) (
    input  logic [  2:0] type_,
    input  logic [N-1:0] in1,
    input  logic [N-1:0] in2,
    output logic         out
);
  always_comb
    case (type_)
      `CMP_EQ:   out = in1 == in2;
      `CMP_NE:   out = in1 != in2;
      `CMP_LT2:  out = $signed(in1) < $signed(in2);
      `CMP_LTU2: out = in1 < in2;
      `CMP_LT:   out = $signed(in1) < $signed(in2);
      `CMP_GE:   out = $signed(in1) >= $signed(in2);
      `CMP_LTU:  out = in1 < in2;
      `CMP_GEU:  out = in1 >= in2;
    endcase
endmodule
