`include "csr_register.h"

`define MISA 12'h301
`define MVENDORID 12'hf11
`define MARCHID 12'hf12
`define MIMPID 12'hf13
`define MHARTID 12'hf14
`define MSTATUS 12'h300
`define MTVEC 12'h305
`define MIE 12'h304
`define MEPC 12'h341

module csr_register(input logic clk,
                    input logic         reset,
                    input logic [11:0]  number,
                    input logic [1:0]   access_type,
                    input logic [31:0]  in,
                    output logic [31:0] out);
   logic [31:0]                         mepc;
   logic [31:0]                         mtvec;
   logic [31:0]                         current;
   logic [31:0]                         next;
   logic                                write_enable;
   logic                                is_mepc;

   always_ff @(posedge clk)
     if(reset)
       begin
          mepc <= 0;
          mtvec <= 0;
       end
     else
       if(write_enable)
         case(number)
           `MTVEC:
             mtvec <= next;
           `MEPC:
             mepc <= next;
           default:
             ;
         endcase

   assign is_mepc = number == 12'h341;
   assign write_enable = access_type != `CSR_READ_ONLY;

   always_comb
     case(number)
       `MISA:
         out = 32'h80000000 /* 32bit */
               | (32'b1 << 8) /* I */ ;

       `MVENDORID:
         out = 32'b0;

       `MARCHID:
         out = 32'b0;

       `MIMPID:
         out = 32'b0;

       `MHARTID:
         out = 32'b0;

       `MSTATUS:
         out = 'bx;             // todo

       `MTVEC:
         out = mtvec;

       `MIE:
         out = 'bx;             // todo

       `MEPC:
         out = mepc;

       default:
         out = 32'b0;
     endcase

   always_comb
     begin
        case(number)
          `MTVEC:
            current = mtvec;
          `MEPC:
            current = mepc;
          default:
            current = 'bx;
        endcase

        case(access_type)
          `CSR_WRITE:
            next = in;
          `CSR_SET:
            next = current | in;
          `CSR_CLEAR:
            next = current & ~in;
          default:
            next = 'bx;
        endcase
     end
endmodule
