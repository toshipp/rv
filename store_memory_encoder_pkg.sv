`ifndef STORE_MEMORY_ENCODER_PKG
`define STORE_MEMORY_ENCODER_PKG

package store_memory_encoder_pkg;
  typedef enum logic [1:0] {
    STORE_B = 2'b00,
    STORE_H = 2'b01,
    STORE_W = 2'b10
  } store_memory_encoder_type_t;
endpackage

`endif
