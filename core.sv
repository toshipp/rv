module core #(
    parameter START_ADDRESS = 0
) (
    input logic clk,
    input logic reset,

    input  logic        memory_ready,
    input  logic        memory_valid,
    input  logic [31:0] read_memory_data,
    output logic [31:0] read_memory_address,
    output logic [31:0] write_memory_data,
    output logic [31:0] write_memory_address,
    output logic [31:0] write_memory_mask,
    output logic        memory_command_out,
    output logic        memory_enable,

    input logic external_interrupt,
    input logic timer_interrupt,
    input logic software_interrupt,

    output logic [31:0] debug_pc,
    output logic [31:0] debug_instruction,
    output logic [ 2:0] debug_state,
    output logic [31:0] debug_in1,
    output logic [31:0] debug_in2,
    output logic [31:0] debug_result
);

  logic [31:0] instruction;

  logic        interrupted;

  logic        misaligned_exception;

  logic        memory_command;

  logic        execute_result_write_enable;
  logic        load_memory_data_write_enable;
  logic        pc_write_enable;
  logic        instruction_write_enable;
  logic        register_file_write_enable;

  logic        write_immediate_to_register_file;
  logic        write_pc_inc_to_register_file;
  logic        write_execute_result_to_pc;
  logic        write_execute_result_to_pc_if_compare_met;
  logic        write_load_memory_to_register_file;

  logic        use_execute_result_for_read_memory;

  logic        execute_alu;
  logic        execute_compare;
  logic        execute_shift;
  logic        execute_csr;
  logic        use_immediate;
  logic        use_immediate_for_compare;
  logic        use_pc_for_alu;

  logic [ 2:0] immediate_type;
  logic [ 2:0] alu_type;
  logic [ 1:0] shift_type;
  logic [ 2:0] compare_type;
  logic [ 2:0] load_memory_decoder_type;
  logic [ 1:0] store_memory_encoder_type;
  logic [ 1:0] csr_access_type;

  logic [11:0] csr_number;
  logic        handle_trap;
  logic        exit_trap;

  logic [31:0] current_pc;
  logic [31:0] next_pc;
  logic [31:0] csr_trap_pc;
  logic [31:0] csr_ret_pc;
  logic        exception;
  logic [30:0] exception_cause;
  logic [31:0] trap_value;

  logic [31:0] csr_in;
  logic [31:0] csr_out;

  controller controller (
      clk,
      reset,

      next_pc,
      instruction,

      memory_ready,
      memory_valid,

      interrupted,

      misaligned_exception,

      execute_result_write_enable,
      load_memory_data_write_enable,
      pc_write_enable,
      instruction_write_enable,
      register_file_write_enable,
      memory_command,
      memory_enable,

      write_immediate_to_register_file,
      write_pc_inc_to_register_file,
      write_execute_result_to_pc,
      write_execute_result_to_pc_if_compare_met,
      write_load_memory_to_register_file,

      use_execute_result_for_read_memory,

      execute_alu,
      execute_compare,
      execute_shift,
      execute_csr,
      use_immediate,
      use_immediate_for_compare,
      use_pc_for_alu,

      immediate_type,
      alu_type,
      shift_type,
      compare_type,
      load_memory_decoder_type,
      store_memory_encoder_type,
      csr_access_type,

      csr_number,
      handle_trap,
      exit_trap,

      debug_state,
      exception,
      exception_cause
  );

  data_path #(START_ADDRESS) data_path (
      clk,
      reset,
      memory_command,
      read_memory_data,
      read_memory_address,
      write_memory_data,
      write_memory_address,
      write_memory_mask,

      execute_result_write_enable,
      load_memory_data_write_enable,
      pc_write_enable,
      instruction_write_enable,
      register_file_write_enable,

      write_immediate_to_register_file,
      write_load_memory_to_register_file,
      write_execute_result_to_pc,
      write_execute_result_to_pc_if_compare_met,
      write_pc_inc_to_register_file,

      use_execute_result_for_read_memory,

      execute_alu,
      execute_compare,
      execute_shift,
      execute_csr,
      use_immediate,
      use_immediate_for_compare,
      use_pc_for_alu,
      handle_trap,
      exit_trap,

      immediate_type,
      alu_type,
      shift_type,
      compare_type,
      load_memory_decoder_type,
      store_memory_encoder_type,
      instruction,

      current_pc,
      next_pc,
      csr_trap_pc,
      csr_ret_pc,

      csr_in,
      csr_out,

      misaligned_exception,

      trap_value,

      debug_in1,
      debug_in2,
      debug_result
  );

  csr csr (
      clk,
      reset,
      csr_number,
      csr_access_type,
      csr_in,
      csr_out,
      external_interrupt,
      timer_interrupt,
      software_interrupt,
      exception,
      exception_cause,
      trap_value,
      exit_trap,
      current_pc,
      csr_trap_pc,
      csr_ret_pc,
      handle_trap,
      interrupted
  );

  assign memory_command_out = memory_command;

  assign debug_instruction = instruction;
  assign debug_pc = current_pc;
endmodule
