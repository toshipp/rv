module data_path
  #(parameter START_ADDRESS = 0)
   (input logic         clk,
    input logic         reset,

    // for ram
    input logic [31:0]  read_memory_data,
    output logic [31:0] read_memory_address,
    output logic [31:0] write_memory_data,
    output logic [31:0] write_memory_address,
    output logic [31:0] write_memory_mask,

    // for control
    input logic         execute_result_write_enable,
    input logic         load_memory_data_write_enable,
    input logic         pc_write_enable,
    input logic         instruction_write_enable,
    input logic         register_file_write_enable,
    input logic         source_write_enable,

    input logic         write_immediate_to_register_file,
    input logic         write_load_memory_to_register_file,
    input logic         write_execute_result_to_pc,
    input logic         write_execute_result_to_pc_if_compare_met,
    input logic         write_pc_inc_to_register_file,

    input logic         use_execute_result_for_read_memory,

    input logic         execute_alu,
    input logic         execute_compare,
    input logic         execute_shift,
    input logic         use_immediate,
    input logic         use_pc_for_alu,

    input logic [2:0]   immediate_type,
    input logic [2:0]   alu_type,
    input logic [2:0]   compare_type,
    input logic [1:0]   shift_type,
    input logic [2:0]   load_memory_decoder_type,
    input logic [1:0]   store_memory_encoder_type,

    output logic [31:0] instruction,

    output logic [31:0] debug_pc
    );

   logic [31:0]         pc_next;
   logic [31:0]         pc_current;
   logic [31:0]         pc_inc;

   logic [31:0]         register_file_write_data;
   logic [31:0]         register_file_read_data1;
   logic [31:0]         register_file_read_data2;

   logic [31:0]         source1;

   logic [31:0]         source2;

   logic [31:0]         immediate;

   logic [31:0]         alu_in1;
   logic [31:0]         alu_in2;
   logic [31:0]         alu_out;

   logic [31:0]         compare_in2;
   logic                compare_out;
   logic [31:0]         compare_out_extended;

   logic [4:0]          shift_count;
   logic [31:0]         shift_out;

   logic [31:0]         execute_result_in;
   logic [31:0]         execute_result;

   logic [31:0]         load_memory_decoder_out;

   logic [31:0]         load_memory_data;

   regcell_reset #(START_ADDRESS) reg_pc(clk,
                                         reset,
                                         pc_next,
                                         pc_write_enable,
                                         pc_current);

   regcell reg_instruction(clk,
                           read_memory_data,
                           instruction_write_enable,
                           instruction);

   register_file register_file(clk,
                               instruction[19:15],
                               instruction[24:20],
                               instruction[11:7],
                               register_file_write_data,
                               register_file_write_enable,
                               register_file_read_data1,
                               register_file_read_data2);

   regcell reg_source1(clk,
                       register_file_read_data1,
                       source_write_enable,
                       source1);

   regcell reg_source2(clk,
                       register_file_read_data2,
                       source_write_enable,
                       source2);

   immediate_decoder immediate_decoder(immediate_type,
                                       instruction,
                                       immediate);

   alu alu(alu_type,
           alu_in1,
           alu_in2,
           alu_out);

   comparer comparer(compare_type,
                     source1,
                     compare_in2,
                     compare_out);

   shifter shifter(shift_type,
                   source1,
                   shift_count,
                   shift_out);

   regcell reg_execute_result(clk,
                              execute_result_in,
                              execute_result_write_enable,
                              execute_result);

   load_memory_decoder load_memory_decoder(load_memory_decoder_type,
                                           execute_result[1:0],
                                           read_memory_data,
                                           load_memory_decoder_out);

   regcell reg_load_memory_data(clk,
                                load_memory_decoder_out,
                                load_memory_data_write_enable,
                                load_memory_data);

   store_memory_encoder store_memory_encoder(store_memory_encoder_type,
                                             execute_result[1:0],
                                             source2,
                                             write_memory_data,
                                             write_memory_mask);

   assign debug_pc = pc_current;
   assign pc_inc = pc_current + 4;
   assign pc_next = (write_execute_result_to_pc ||
                     (write_execute_result_to_pc_if_compare_met && compare_out)) ? execute_result : pc_inc;

   assign register_file_write_data = write_pc_inc_to_register_file ? pc_inc :
                                     (write_immediate_to_register_file ? immediate :
                                      (write_load_memory_to_register_file ? load_memory_data :
                                       execute_result));

   assign alu_in1 = use_pc_for_alu ? pc_current : source1;
   assign alu_in2 = use_immediate ?  immediate : source2;

   assign compare_in2 = use_immediate ? immediate : source2;
   assign compare_out_extended = {31'b0, compare_out};

   assign shift_count = use_immediate ? instruction[24:20] : source2[4:0];

   assign execute_result_in = execute_alu ? alu_out :
                              (execute_compare ? compare_out_extended :
                               (execute_shift ? shift_out : 'bx));

   assign read_memory_address = use_execute_result_for_read_memory ? execute_result : pc_current;

   assign write_memory_address = execute_result;
endmodule
