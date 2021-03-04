`include "csr_pkg.sv"

typedef enum logic [11:0] {
  MSTATUS   = 12'h300,
  MISA      = 12'h301,
  MIE       = 12'h304,
  MTVEC     = 12'h305,
  MSCRATCH  = 12'h340,
  MEPC      = 12'h341,
  MCAUSE    = 12'h342,
  MTVAL     = 12'h343,
  MVENDORID = 12'hf11,
  MARCHID   = 12'hf12,
  MIMPID    = 12'hf13,
  MHARTID   = 12'hf14
} csr_id_type;

module csr (
    input  logic        clk,
    input  logic        reset,
    input  logic [11:0] csr_id,
    input  logic [ 1:0] access_type,
    input  logic [31:0] in,
    output logic [31:0] out,
    input  logic        external_interrupt,
    input  logic        timer_interrupt,
    input  logic        software_interrupt,
    input  logic        exception,
    input  logic [30:0] exception_cause,
    input  logic [31:0] trap_value,
    input  logic        exit_trap,
    input  logic [31:0] current_pc,
    output logic [31:0] trap_pc,
    output logic [31:0] ret_pc,
    input  logic        handle_trap,
    output logic        interrupted
);
  // only direct mode is supported.
  logic [29:0] mtvec;
  logic [31:0] mscratch;
  logic [29:0] mepc;
  logic [31:0] mcause;
  logic [31:0] mtval;

  logic        mie_meie;
  logic        mie_mtie;
  logic        mie_msie;
  logic        mstatus_mie;
  logic        mstatus_mpie;

  logic        write_enable;
  logic [31:0] current;
  logic [31:0] next;

  assign write_enable = access_type != csr_pkg::CSR_READ_ONLY;

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
      mepc <= current_pc[31:2];
      mstatus_mpie <= mstatus_mie;
      mstatus_mie <= 0;
      mcause[31] <= exception ? 0 : 1;
      mtval <= trap_value;
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
      case (csr_id)
        MTVEC: mtvec <= next[31:2];
        MSCRATCH: mscratch <= next;
        MEPC: mepc <= next[31:2];
        MCAUSE: mcause <= next;
        MIE: begin
          mie_meie <= next[11];
          mie_mtie <= next[7];
          mie_msie <= next[3];
        end
        MSTATUS: begin
          mstatus_mie  <= next[3];
          mstatus_mpie <= next[7];
        end
        default: ;
      endcase

  assign out = current;

  assign trap_pc = {mtvec, 2'b0};
  assign ret_pc = {mepc, 2'b0};

  always_comb
    case (csr_id)
      MISA: current = 32'h40000000  /* XLEN=32 */ | (32'b1 << 8)  /* I */;

      MVENDORID: current = 32'b0;

      MARCHID: current = 32'b0;

      MIMPID: current = 32'b0;

      MHARTID: current = 32'b0;

      MSTATUS: begin
        current = 32'b0;
        current[7] = mstatus_mpie;
        current[3] = mstatus_mie;
      end

      MIE: begin
        current = 32'b0;
        current[11] = mie_meie;
        current[7] = mie_mtie;
        current[3] = mie_msie;
      end

      MTVEC: current = {mtvec, 2'b0};

      MSCRATCH: current = mscratch;

      MEPC: current = {mepc, 2'b0};

      MCAUSE: current = mcause;

      MTVAL: current = mtval;

      default: current = 32'b0;
    endcase

  always_comb
    case (access_type)
      csr_pkg::CSR_WRITE: next = in;
      csr_pkg::CSR_SET: next = current | in;
      csr_pkg::CSR_CLEAR: next = current & ~in;
      default: next = 'bx;
    endcase

endmodule
