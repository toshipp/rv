`include "csr.h"

`define MISA 12'h301
`define MVENDORID 12'hf11
`define MARCHID 12'hf12
`define MIMPID 12'hf13
`define MHARTID 12'hf14
`define MSTATUS 12'h300
`define MTVEC 12'h305
`define MIE 12'h304
`define MEPC 12'h341

module csr(input logic clk,
           input logic         reset,
           input logic [11:0]  number,
           input logic [1:0]   access_type,
           input logic [31:0]  in,
           output logic [31:0] out);
   logic [31:0]                mepc;
   logic [31:0]                mtvec;
   logic [31:0]                current;
   logic [31:0]                next;
   logic                       write_enable;
   logic                       mie_meie;
   logic                       mie_mtie;
   logic                       mie_msie;
   logic                       mstatus_mie;

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
           `MIE:
             begin
                mie_meie <= next[11];
                mie_mtie <= next[7];
                mie_msie <= next[3];
             end
           `MSTATUS:
             mstatus_mie <= next[3];
           default:
             ;
         endcase

   assign write_enable = access_type != `CSR_READ_ONLY;
   assign out = current;

   always_comb
     case(number)
       `MISA:
         current = 32'h40000000 /* XLEN=32 */
                   | (32'b1 << 8) /* I */ ;

       `MVENDORID:
         current = 32'b0;

       `MARCHID:
         current = 32'b0;

       `MIMPID:
         current = 32'b0;

       `MHARTID:
         current = 32'b0;

       `MSTATUS:
         current = {28'b0, mstatus_mie, 3'b0};

       `MTVEC:
         current = mtvec;

       `MIE:
         current = {20'b0, mie_meie, 3'b0, mie_mtie, 3'b0, mie_msie, 3'b0};

       `MEPC:
         current = mepc;

       default:
         current = 32'b0;
     endcase

   always_comb
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
endmodule
