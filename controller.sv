`include "immediate_decoder_pkg.sv"
`include "shifter_pkg.sv"
`include "alu_pkg.sv"
`include "csr_pkg.sv"
`include "controller_pkg.sv"

typedef enum logic [6:0] {
  LUI    = 7'b0110111,
  AUIPC  = 7'b0010111,
  JAR    = 7'b1101111,
  JALR   = 7'b1100111,
  BRANCH = 7'b1100011,
  LOAD   = 7'b0000011,
  STORE  = 7'b0100011,
  CALCI  = 7'b0010011,
  CALCR  = 7'b0110011,
  FENCE  = 7'b0001111,
  SYSTEM = 7'b1110011
} opcode_t;

typedef enum logic [31:0] {
  MRET   = 32'b0011000_00010_00000_000_00000_1110011,
  ECALL  = 32'b000000000000_00000_000_00000_1110011,
  EBREAK = 32'b000000000001_00000_000_00000_1110011

} system_instruction_t;

module controller (
    input logic clk,
    input logic reset,

    input logic [31:0] next_pc,
    input logic [31:0] instruction,

    input logic [31:0] read_memory_address,
    input logic [31:0] write_memory_address,

    input logic ack_i,

    input logic interrupted,

    input logic misaligned_exception,

    output logic execute_result_write_enable,
    output logic load_memory_data_write_enable,
    output logic pc_write_enable,
    output logic instruction_write_enable,
    output logic register_file_write_enable,
    output logic memory_command,
    output logic [31:0] adr_o,
    output logic stb_o,

    output logic write_immediate_to_register_file,
    output logic write_pc_inc_to_register_file,
    output logic write_execute_result_to_pc,
    output logic clear_pc_lsb,
    output logic write_execute_result_to_pc_if_compare_met,
    output logic write_load_memory_to_register_file,

    output logic use_execute_result_for_read_memory,

    output logic execute_alu,
    output logic execute_compare,
    output logic execute_shift,
    output logic execute_csr,
    output logic use_immediate,
    output logic use_immediate_for_compare,
    output logic use_pc_for_alu,

    output logic [2:0] immediate_type,
    output logic [2:0] alu_type,
    output logic [1:0] shift_type,
    output logic [2:0] compare_type,
    output logic [2:0] load_memory_decoder_type,
    output logic [1:0] store_memory_encoder_type,
    output logic [1:0] csr_access_type,

    output logic [11:0] csr_id,
    output logic        handle_trap,
    output logic        exit_trap,
    output logic        trap_value_type,

    output logic [ 2:0] debug_state,
    output logic        exception,
    output logic [30:0] exception_cause
);

  opcode_t opcode;
  logic [2:0] funct3;
  logic [6:0] funct7;

  typedef enum logic [2:0] {
    state_fetch,
    state_decode,
    state_execute,
    state_memory,
    state_write_back,
    state_trap
  } state;
  state current_state;
  state next_state;

  logic next_exception;
  logic [30:0] next_exception_cause;
  logic next_trap_value_type;

  always_ff @(posedge clk)
    if (reset) begin
      current_state <= state_fetch;
      exception <= 0;
      exception_cause <= 0;
      trap_value_type <= controller_pkg::ZERO;
    end else begin
      current_state <= next_state;
      exception <= next_exception;
      exception_cause <= next_exception_cause;
      trap_value_type <= next_trap_value_type;
    end

  assign opcode = instruction[6:0];
  assign funct3 = instruction[14:12];
  assign funct7 = instruction[31:25];

  always_comb begin
    execute_result_write_enable = 0;
    load_memory_data_write_enable = 0;
    pc_write_enable = 0;
    instruction_write_enable = 0;
    register_file_write_enable = 0;
    memory_command = 1'bx;
    adr_o = 32'bx;
    stb_o = 0;

    write_immediate_to_register_file = 0;
    write_pc_inc_to_register_file = 0;
    write_execute_result_to_pc = 0;
    clear_pc_lsb = 0;
    write_execute_result_to_pc_if_compare_met = 0;
    write_load_memory_to_register_file = 0;

    use_execute_result_for_read_memory = 0;

    execute_alu = 0;
    execute_compare = 0;
    execute_shift = 0;
    execute_csr = 0;
    use_immediate = 0;
    use_immediate_for_compare = 0;
    use_pc_for_alu = 0;

    immediate_type = 3'bx;
    alu_type = 3'bx;
    compare_type = 3'bx;
    shift_type = 2'bx;
    load_memory_decoder_type = funct3;
    store_memory_encoder_type = funct3[1:0];

    csr_access_type = csr_pkg::CSR_READ_ONLY;

    csr_id = instruction[31:20];
    handle_trap = 0;
    exit_trap = 0;

    next_exception = exception;
    next_exception_cause = exception_cause;
    next_trap_value_type = trap_value_type;

    case (current_state)
      state_fetch: begin
        next_state = state_fetch;
        next_exception = 0;
        next_exception_cause = 0;
        next_trap_value_type = controller_pkg::ZERO;
        memory_command = controller_pkg::READ;
        adr_o = read_memory_address;
        stb_o = 1;
        if (ack_i) begin
          next_state = state_decode;
          instruction_write_enable = 1;
        end
      end

      state_decode: begin
        next_state = state_execute;

        if (interrupted) next_state = state_trap;
      end

      state_execute: begin
        next_state = state_write_back;
        execute_result_write_enable = 1;
        case (opcode)
          LUI:  /* do nothing */;
          AUIPC, JAR, BRANCH: begin
            execute_alu = 1;
            alu_type = alu_pkg::ALU_ADD;
            use_pc_for_alu = 1;
            use_immediate = 1;
            case (opcode)
              AUIPC: immediate_type = immediate_decoder_pkg::IMM_U;
              JAR: immediate_type = immediate_decoder_pkg::IMM_J;
              BRANCH: begin
                immediate_type = immediate_decoder_pkg::IMM_B;
                compare_type   = funct3;
              end
              default: immediate_type = 3'bx;
            endcase
          end
          JALR: begin
            execute_alu = 1;
            alu_type = alu_pkg::ALU_ADD;
            use_immediate = 1;
            immediate_type = immediate_decoder_pkg::IMM_I;
          end
          LOAD, STORE: begin
            execute_alu = 1;
            alu_type = alu_pkg::ALU_ADD;
            use_immediate = 1;
            immediate_type = (opcode == LOAD) ? immediate_decoder_pkg::IMM_I :
                immediate_decoder_pkg::IMM_S;
            next_state = state_memory;
          end
          CALCI, CALCR: begin
            if (opcode == CALCI) begin
              use_immediate = 1;
              use_immediate_for_compare = 1;
              immediate_type = immediate_decoder_pkg::IMM_I;
            end
            casez (funct3)
              3'b01?: begin
                // compare set
                execute_compare = 1;
                compare_type = funct3;
              end
              3'b?01: begin
                // shift
                execute_shift = 1;
                case ({
                  funct3[2], funct7
                })
                  8'b00000000: shift_type = shifter_pkg::SHIFT_LEFT;
                  8'b10000000: shift_type = shifter_pkg::SHIFT_RIGHT;
                  8'b10100000: shift_type = shifter_pkg::SHIFT_ARITH;
                  default: begin
                    next_exception = 1;
                    next_exception_cause = csr_pkg::ILLEGAL_INSTRUCTION_CODE;
                  end
                endcase
              end
              default: begin
                // alu
                execute_alu = 1;
                alu_type = (opcode == CALCR && funct7 == 7'b0100000) ? alu_pkg::ALU_SUB : funct3;
              end
            endcase
          end
          FENCE: begin
            // currently we have no cache, act as nop.
            next_state = state_write_back;
          end
          SYSTEM: begin
            case (funct3)
              3'b000, 3'b100: begin
                case (instruction)
                  MRET: exit_trap = 1;
                  EBREAK: begin
                    next_exception = 1;
                    next_exception_cause = csr_pkg::BREAKPOINT_CODE;
                  end
                  ECALL: begin
                    next_exception = 1;
                    next_exception_cause = csr_pkg::ECALL_CODE;
                  end
                  default: begin
                    next_exception = 1;
                    next_exception_cause = csr_pkg::ILLEGAL_INSTRUCTION_CODE;
                  end
                endcase
              end
              default: begin
                execute_csr   = 1;
                use_immediate = funct3[2];
                case (funct3[1:0])
                  2'b01:   csr_access_type = csr_pkg::CSR_WRITE;
                  2'b10:   csr_access_type = csr_pkg::CSR_SET;
                  2'b11:   csr_access_type = csr_pkg::CSR_CLEAR;
                  default: ;
                endcase
              end
            endcase
            next_state = state_write_back;
          end
          default: begin
            next_exception = 1;
            next_exception_cause = csr_pkg::ILLEGAL_INSTRUCTION_CODE;
          end
        endcase

        if (next_exception) next_state = state_trap;
      end

      state_memory: begin
        next_state = state_memory;
        if (opcode == LOAD) begin
          use_execute_result_for_read_memory = 1;
          memory_command = controller_pkg::READ;
          adr_o = read_memory_address;
        end else begin
          memory_command = controller_pkg::WRITE;
          adr_o = write_memory_address;
        end
        if (misaligned_exception) begin
          next_state = state_trap;
          next_exception = 1;
          next_exception_cause = (opcode == LOAD) ? csr_pkg::LOAD_ADDRESS_MISALIGNED_CODE :
              csr_pkg::STORE_ADDRESS_MISALIGNED_CODE;
          next_trap_value_type = controller_pkg::EXECUTE_RESULT;
        end else begin
          stb_o = 1;
          if (ack_i) begin
            next_state = state_write_back;
            if (opcode == LOAD) begin
              load_memory_data_write_enable = 1;
            end
          end
        end
      end

      state_write_back: begin
        case (opcode)
          LUI: begin
            write_immediate_to_register_file = 1;
            immediate_type = immediate_decoder_pkg::IMM_U;
          end
          JAR, JALR: begin
            write_pc_inc_to_register_file = 1;
            write_execute_result_to_pc = 1;
            clear_pc_lsb = opcode == JALR;
          end
          BRANCH: write_execute_result_to_pc_if_compare_met = 1;
          LOAD: write_load_memory_to_register_file = 1;
          SYSTEM: if (instruction == MRET) write_execute_result_to_pc = 1;
          default: ;
        endcase

        if ((opcode == JAR || opcode == JALR || opcode == BRANCH) && next_pc[1:0] != 0) begin
          next_state = state_trap;
          next_exception = 1;
          next_exception_cause = csr_pkg::INSTRUCTION_ADDRESS_MISALIGNED_CODE;
        end else begin
          next_state = state_fetch;
          pc_write_enable = 1;

          case (opcode)
            LUI, AUIPC, JAR, JALR, LOAD, CALCI, CALCR: register_file_write_enable = 1;
            SYSTEM: begin
              // csr
              if (funct3 != 3'b000 && funct3 != 3'b100) register_file_write_enable = 1;
            end
            default: ;
          endcase
        end
      end

      state_trap: begin
        next_state = state_fetch;
        pc_write_enable = 1;
        handle_trap = 1;
      end

      default: next_state = 3'bx;  // dont care
    endcase
  end

  assign debug_state = current_state;
endmodule
