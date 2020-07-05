module core
  #(parameter START_ADDRESS = 0)
   (input logic clk,
    input logic         reset,

    input logic [31:0]  read_memory_data,
    output logic [31:0] read_memory_address,
    output logic [31:0] write_memory_data,
    output logic [31:0] write_memory_address,
    output logic [31:0] write_memory_mask,
    output logic        memory_write_enable,

    output logic [31:0] debug_pc,
    output logic [31:0] debug_instruction,
    output logic [2:0]  debug_state,
    output logic        trap);

   logic [31:0]         instruction;

   logic                execute_result_write_enable;
   logic                load_memory_data_write_enable;
   logic                pc_write_enable;
   logic                instruction_write_enable;
   logic                register_file_write_enable;
   logic                source_write_enable;

   logic                write_immediate_to_register_file;
   logic                write_pc_inc_to_register_file;
   logic                write_execute_result_to_pc;
   logic                write_execute_result_to_pc_if_compare_met;
   logic                write_load_memory_to_register_file;

   logic                use_execute_result_for_read_memory;

   logic                execute_alu;
   logic                execute_compare;
   logic                execute_shift;
   logic                use_immediate;
   logic                use_pc_for_alu;

   logic [2:0]          immediate_type;
   logic [2:0]          alu_type;
   logic [1:0]          shift_type;
   logic [2:0]          compare_type;
   logic [2:0]          load_memory_decoder_type;
   logic [1:0]          store_memory_encoder_type;

   controller controller(clk,
                         reset,
                         instruction,

                         execute_result_write_enable,
                         load_memory_data_write_enable,
                         pc_write_enable,
                         instruction_write_enable,
                         register_file_write_enable,
                         source_write_enable,
                         memory_write_enable,

                         write_immediate_to_register_file,
                         write_pc_inc_to_register_file,
                         write_execute_result_to_pc,
                         write_execute_result_to_pc_if_compare_met,
                         write_load_memory_to_register_file,

                         use_execute_result_for_read_memory,

                         execute_alu,
                         execute_compare,
                         execute_shift,
                         use_immediate,
                         use_pc_for_alu,

                         immediate_type,
                         alu_type,
                         shift_type,
                         compare_type,
                         load_memory_decoder_type,
                         store_memory_encoder_type,

                         debug_state,
                         trap);

   data_path #(START_ADDRESS) data_path(clk,
                                        reset,
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
                                        source_write_enable,

                                        write_immediate_to_register_file,
                                        write_load_memory_to_register_file,
                                        write_execute_result_to_pc,
                                        write_execute_result_to_pc_if_compare_met,
                                        write_pc_inc_to_register_file,

                                        use_execute_result_for_read_memory,

                                        execute_alu,
                                        execute_compare,
                                        execute_shift,
                                        use_immediate,
                                        use_pc_for_alu,

                                        immediate_type,
                                        alu_type,
                                        compare_type,
                                        shift_type,
                                        load_memory_decoder_type,
                                        store_memory_encoder_type,

                                        instruction,

                                        debug_pc);

   assign debug_instruction = instruction;
endmodule
