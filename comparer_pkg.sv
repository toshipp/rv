`ifndef COMPARER_PKG
`define COMPARER_PKG

package comparer_pkg;
  typedef enum logic [2:0] {
    CMP_EQ   = 3'b000,
    CMP_NE   = 3'b001,
    CMP_LT2  = 3'b010,
    CMP_LTU2 = 3'b011,
    CMP_LT   = 3'b100,
    CMP_GE   = 3'b101,
    CMP_LTU  = 3'b110,
    CMP_GEU  = 3'b111
  } comparer_type_t;
endpackage

`endif
