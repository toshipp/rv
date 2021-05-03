`ifndef CONTROLLER_PKG
`define CONTROLLER_PKG

package controller_pkg;
  typedef enum logic {
    READ  = 1'b0,
    WRITE = 1'b1
  } memory_command_type_t;

  typedef enum logic {
    ZERO           = 1'b0,
    EXECUTE_RESULT = 1'b1
  } trap_value_type_t;
endpackage

`endif
