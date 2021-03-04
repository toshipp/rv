`ifndef CSR_PKG
`define CSR_PKG

package csr_pkg;
  typedef enum logic [1:0] {
    CSR_READ_ONLY = 2'b00,
    CSR_WRITE     = 2'b01,
    CSR_SET       = 2'b10,
    CSR_CLEAR     = 2'b11
  } csr_access_type_t;

  typedef enum logic [30:0] {
    INSTRUCTION_ADDRESS_MISALIGNED_CODE = 0,
    ILLEGAL_INSTRUCTION_CODE            = 2,
    BREAKPOINT_CODE                     = 3,
    LOAD_ADDRESS_MISALIGNED_CODE        = 4,
    STORE_ADDRESS_MISALIGNED_CODE       = 6,
    ECALL_CODE                          = 11
  } exception_cause_t;
endpackage

`endif
