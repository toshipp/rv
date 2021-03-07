`ifndef ALU_PKG
`define ALU_PKG

package alu_pkg;
  typedef enum logic [2:0] {
    ALU_ADD = 3'b000,
    ALU_SUB = 3'b001,
    ALU_XOR = 3'b100,
    ALU_OR  = 3'b110,
    ALU_AND = 3'b111
  } alu_type_t;
endpackage

`endif
