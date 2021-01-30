`include "csr.h"

`define MSTATUS 12'h300
`define MISA 12'h301
`define MIE 12'h304
`define MTVEC 12'h305
`define MSCRATCH 12'h340
`define MEPC 12'h341
`define MCAUSE 12'h342
`define MVENDORID 12'hf11
`define MARCHID 12'hf12
`define MIMPID 12'hf13
`define MHARTID 12'hf14

module csr (
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] number,
    input  logic [ 1:0] access_type,
    input  logic [31:0] in,
    output logic [31:0] out,
    input  logic        external_interrupt,
    input  logic        timer_interrupt,
    input  logic        software_interrupt,
    input  logic        exception,
    input  logic [30:0] exception_cause,
    input  logic        exit_trap,
    input  logic [31:0] current_pc,
    output logic [31:0] trap_pc,
    output logic [31:0] ret_pc,
    input  logic        handle_trap,
    output logic        interrupted
);
  logic [31:0] mtvec;
  logic [31:0] mscratch;
  logic [31:0] mepc;
  logic [31:0] mcause;
  logic        mie_meie;
  logic        mie_mtie;
  logic        mie_msie;
  logic        mstatus_mie;
  logic        mstatus_mpie;

  logic        write_enable;
  logic [31:0] current;
  logic [31:0] next;

  assign write_enable = access_type != `CSR_READ_ONLY;

  assign interrupted = (mstatus_mie
                        && (external_interrupt && mie_meie
                            || timer_interrupt && mie_mtie
                            || software_interrupt && mie_msie));

  always_ff @(posedge clk)
    if (reset) begin
      mepc <= 0;
      mtvec <= 0;
      mcause <= 0;
      mie_meie <= 0;
      mie_mtie <= 0;
      mie_msie <= 0;
      mstatus_mie <= 0;
      mstatus_mpie <= 0;
    end else if (handle_trap) begin
      mepc <= current_pc;
      mstatus_mpie <= mstatus_mie;
      mstatus_mie <= 0;
      mcause[31] <= exception ? 0 : 1;
      case (1'b1)
        mstatus_mie && external_interrupt && mie_meie: mcause[30:0] <= 11;
        mstatus_mie && software_interrupt && mie_msie: mcause[30:0] <= 3;
        mstatus_mie && timer_interrupt && mie_mtie: mcause[30:0] <= 7;
        default: mcause[30:0] <= exception_cause;
      endcase
    end else if (exit_trap) begin
      mstatus_mie  <= mstatus_mpie;
      mstatus_mpie <= 1;
    end else if (write_enable)
      case (number)
        `MTVEC: mtvec <= next;
        `MSCRATCH: mscratch <= next;
        `MEPC: mepc <= next;
        `MCAUSE: mcause <= next;
        `MIE: begin
          mie_meie <= next[11];
          mie_mtie <= next[7];
          mie_msie <= next[3];
        end
        `MSTATUS: begin
          mstatus_mie  <= next[3];
          mstatus_mpie <= next[7];
        end
        default: ;
      endcase

  assign out = current;

  assign trap_pc = mtvec;
  assign ret_pc = mepc;

  always_comb
    case (number)
      `MISA: current = 32'h40000000  /* XLEN=32 */ | (32'b1 << 8)  /* I */;

      `MVENDORID: current = 32'b0;

      `MARCHID: current = 32'b0;

      `MIMPID: current = 32'b0;

      `MHARTID: current = 32'b0;

      `MSTATUS: begin
        current = 32'b0;
        current[7] = mstatus_mpie;
        current[3] = mstatus_mie;
      end

      `MIE: begin
        current = 32'b0;
        current[11] = mie_meie;
        current[7] = mie_mtie;
        current[3] = mie_msie;
      end

      `MTVEC: current = mtvec;

      `MSCRATCH: current = mscratch;

      `MEPC: current = mepc;

      `MCAUSE: current = mcause;

      default: current = 32'b0;
    endcase

  always_comb
    case (access_type)
      `CSR_WRITE: next = in;
      `CSR_SET: next = current | in;
      `CSR_CLEAR: next = current & ~in;
      default: next = 'bx;
    endcase

endmodule
