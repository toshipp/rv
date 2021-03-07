`include "immediate_decoder_pkg.sv"

module immediate_decoder (
    input  logic [ 2:0] type_,
    input  logic [31:0] in,
    output logic [31:0] out
);
  always_comb
    case (type_)
      immediate_decoder_pkg::IMM_I: out = {{21{in[31]}}, in[30:25], in[24:21], in[20]};
      immediate_decoder_pkg::IMM_S: out = {{21{in[31]}}, in[30:25], in[11:8], in[7]};
      immediate_decoder_pkg::IMM_B: out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
      immediate_decoder_pkg::IMM_U: out = {in[31], in[30:20], in[19:12], 12'b0};
      immediate_decoder_pkg::IMM_J:
      out = {{12{in[31]}}, in[19:12], in[20], in[30:25], in[24:21], 1'b0};
      default: out = 'bx;
    endcase
endmodule
