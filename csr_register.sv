`include "csr_register.h"

// currently, only mepc is RW-able.
// other registers is not writable, and read data is always zero.
module csr_register(input logic clk,
                    input logic [11:0]  number,
                    input logic [1:0]   access_type,
                    input logic [31:0]  in,
                    output logic [31:0] out);
   logic [31:0]                         mepc;
   logic [31:0]                         next;
   logic                                write_enable;
   logic                                is_mepc;

   always_ff @(posedge clk)
     if(write_enable)
       mepc <= next;

   assign is_mepc = number == 12'h341;
   assign out = is_mepc ? mepc : 0;
   assign write_enable = is_mepc && (access_type != `CSR_READ_ONLY);

   always_comb
     begin
        case(access_type)
          `CSR_WRITE:
            next = in;
          `CSR_SET:
            next = mepc | in;
          `CSR_CLEAR:
            next = mepc & ~in;
          default:
            next = 'bx;
        endcase
     end
endmodule
