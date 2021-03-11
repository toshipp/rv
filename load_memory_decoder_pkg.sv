`ifndef LOAD_MEMORY_DECODER_PKG
`define LOAD_MEMORY_DECODER_PKG

package load_memory_decoder_pkg;
  typedef enum logic [2:0] {
    LOAD_B  = 3'b000,
    LOAD_H  = 3'b001,
    LOAD_W  = 3'b010,
    LOAD_BU = 3'b100,
    LOAD_HU = 3'b101
  } load_memory_decoder_type_t;
endpackage

`endif
