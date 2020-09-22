`include "load_memory_decoder.h"

module load_memory_decoder (
    input  logic [ 2:0] type_,
    input  logic [ 1:0] offset,
    input  logic [31:0] in,
    output logic [31:0] out
);
  always_comb
    case (type_)
      `LOAD_B:
      case (offset)
        0: out = {{24{in[7]}}, in[7:0]};
        1: out = {{24{in[15]}}, in[15:8]};
        2: out = {{24{in[23]}}, in[23:16]};
        3: out = {{24{in[31]}}, in[31:24]};
      endcase
      `LOAD_H:
      case (offset)
        0: out = {{16{in[15]}}, in[15:0]};
        2: out = {{16{in[31]}}, in[31:16]};
        default: out = 'bx;  // trap?
      endcase
      `LOAD_W:
      case (offset)
        0: out = in;
        default: out = 'bx;  // trap?
      endcase
      `LOAD_BU:
      case (offset)
        0: out = {24'b0, in[7:0]};
        1: out = {24'b0, in[15:8]};
        2: out = {24'b0, in[23:16]};
        3: out = {24'b0, in[31:24]};
      endcase
      `LOAD_HU:
      case (offset)
        0: out = {16'b0, in[15:0]};
        2: out = {16'b0, in[31:16]};
        default: out = 'bx;  // trap?
      endcase
      default: out = 'bx;
    endcase
endmodule
