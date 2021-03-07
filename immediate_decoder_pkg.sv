`ifndef IMMEDIATE_DECODER_PKG
`define IMMEDIATE_DECODER_PKG

package immediate_decoder_pkg;
  typedef enum logic [2:0] {
    IMM_I = 3'b000,
    IMM_S = 3'b001,
    IMM_B = 3'b010,
    IMM_U = 3'b011,
    IMM_J = 3'b100
  } immediate_decoder_type_t;
endpackage

`endif
