`ifndef SHIFTER_PKG
`define SHIFTER_PKG

package shifter_pkg;
  typedef enum logic [1:0] {
    SHIFT_LEFT  = 2'b00,
    SHIFT_RIGHT = 2'b01,
    SHIFT_ARITH = 2'b10
  } shifter_type_t;
endpackage

`endif
