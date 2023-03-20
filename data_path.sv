`include "controller_pkg.sv"

module data_path #(
    parameter START_ADDRESS = 0
) (
    input logic clk,
    input logic reset,

    // for ram
    input logic memory_command,
    input logic [31:0] read_memory_data,
    output logic [31:0] read_memory_address,
    output logic [31:0] write_memory_data,
    output logic [31:0] write_memory_address,
    output logic [3:0] sel_o,

    // for control
    input logic execute_result_write_enable,
    input logic load_memory_data_write_enable,
    input logic pc_write_enable,
    input logic instruction_write_enable,
    input logic register_file_write_enable,

    input logic write_immediate_to_register_file,
    input logic write_load_memory_to_register_file,
    input logic write_execute_result_to_pc,
    input logic write_execute_result_to_pc_if_compare_met,
    input logic write_pc_inc_to_register_file,

    input logic use_execute_result_for_read_memory,

    input logic execute_alu,
    input logic execute_compare,
    input logic execute_shift,
    input logic execute_csr,
    input logic use_immediate,
    input logic use_immediate_for_compare,
    input logic use_pc_for_alu,
    input logic handle_trap,
    input logic exit_trap,

    input logic [2:0] immediate_type,
    input logic [2:0] alu_type,
    input logic [1:0] shift_type,
    input logic [2:0] compare_type,
    input logic [2:0] load_memory_decoder_type,
    input logic [1:0] store_memory_encoder_type,

    output logic [31:0] instruction,

    output logic [31:0] current_pc,
    output logic [31:0] next_pc,
    input  logic [31:0] csr_trap_pc,
    input  logic [31:0] csr_ret_pc,

    output logic [31:0] csr_in,
    input  logic [31:0] csr_out,

    output logic misaligned_exception,

    input logic trap_value_type,
    output logic [31:0] trap_value,

    output logic [31:0] debug_in1,
    output logic [31:0] debug_in2,
    output logic [31:0] debug_result
);

  logic        use_execute_result_to_pc;

  logic [31:0] pc_inc;

  logic [31:0] register_file_write_data;
  logic [31:0] register_file_read_data1;
  logic [31:0] register_file_read_data2;

  logic [31:0] immediate;

  logic [31:0] alu_in1;
  logic [31:0] alu_in2;
  logic [31:0] alu_out;

  logic [31:0] compare_in2;
  logic        compare_out;
  logic [31:0] compare_out_extended;
  logic        compare_result;

  logic [ 4:0] shift_count;
  logic [31:0] shift_out;

  logic [31:0] execute_result_in;
  logic [31:0] execute_result;

  logic [31:0] load_memory_decoder_out;

  logic [31:0] load_memory_data;

  logic        load_misaligned_exception;
  logic        store_misaligned_exception;

  regcell_reset #(START_ADDRESS) reg_pc (
      clk,
      reset,
      next_pc,
      pc_write_enable,
      current_pc
  );

  regcell reg_instruction (
      clk,
      read_memory_data,
      instruction_write_enable,
      instruction
  );

  register_file register_file (
      clk,
      instruction[19:15],
      instruction[24:20],
      instruction[11:7],
      register_file_write_data,
      register_file_write_enable,
      register_file_read_data1,
      register_file_read_data2
  );

  immediate_decoder immediate_decoder (
      immediate_type,
      instruction,
      immediate
  );

  alu alu (
      alu_type,
      alu_in1,
      alu_in2,
      alu_out
  );

  comparer comparer (
      compare_type,
      register_file_read_data1,
      compare_in2,
      compare_out
  );

  regcell #(1) reg_compare_result (
      clk,
      compare_out,
      execute_result_write_enable,
      compare_result
  );

  shifter shifter (
      shift_type,
      register_file_read_data1,
      shift_count,
      shift_out
  );

  regcell reg_execute_result (
      clk,
      execute_result_in,
      execute_result_write_enable,
      execute_result
  );

  load_memory_decoder load_memory_decoder (
      load_memory_decoder_type,
      execute_result[1:0],
      read_memory_data,
      load_memory_decoder_out,
      load_misaligned_exception
  );

  regcell reg_load_memory_data (
      clk,
      load_memory_decoder_out,
      load_memory_data_write_enable,
      load_memory_data
  );

  store_memory_encoder store_memory_encoder (
      store_memory_encoder_type,
      execute_result[1:0],
      register_file_read_data2,
      write_memory_data,
      sel_o,
      store_misaligned_exception
  );

  assign debug_result = execute_result_in;
  assign debug_in1 = alu_in1;
  assign debug_in2 = alu_in2;

  assign pc_inc = current_pc + 4;

  assign use_execute_result_to_pc = (
      write_execute_result_to_pc || (write_execute_result_to_pc_if_compare_met && compare_result));

  always_comb
    case (1'b1)
      use_execute_result_to_pc: next_pc = execute_result;
      handle_trap: next_pc = csr_trap_pc;
      default: next_pc = pc_inc;
    endcase

  always_comb
    case (1'b1)
      write_pc_inc_to_register_file: register_file_write_data = pc_inc;
      write_immediate_to_register_file: register_file_write_data = immediate;
      write_load_memory_to_register_file: register_file_write_data = load_memory_data;
      default: register_file_write_data = execute_result;
    endcase

  assign alu_in1 = use_pc_for_alu ? current_pc : register_file_read_data1;
  assign alu_in2 = use_immediate ? immediate : register_file_read_data2;

  assign compare_in2 = use_immediate_for_compare ? immediate : register_file_read_data2;
  assign compare_out_extended = {31'b0, compare_out};

  assign shift_count = use_immediate ? instruction[24:20] : register_file_read_data2[4:0];

  always_comb
    case (1'b1)
      execute_alu: execute_result_in = alu_out;
      execute_compare: execute_result_in = compare_out_extended;
      execute_shift: execute_result_in = shift_out;
      execute_csr: execute_result_in = csr_out;
      exit_trap: execute_result_in = csr_ret_pc;
      default: execute_result_in = 'bx;
    endcase

  assign read_memory_address = use_execute_result_for_read_memory ? execute_result : current_pc;
  assign write_memory_address = execute_result;

  assign csr_in = use_immediate ? {27'b0, instruction[19:15]} : register_file_read_data1;

  assign misaligned_exception = (memory_command == controller_pkg::READ && load_misaligned_exception
      ) || (memory_command == controller_pkg::WRITE && store_misaligned_exception);

  always_comb
    case (trap_value_type)
      controller_pkg::ZERO: trap_value = 0;
      controller_pkg::EXECUTE_RESULT: trap_value = execute_result;
      default: trap_value = 'bx;
    endcase

endmodule
