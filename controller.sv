`include "immediate_decoder.h"
`include "shifter.h"
`include "alu.h"
`include "csr_register.h"

`define LUI 7'b0110111
`define AUIPC 7'b0010111
`define JAR 7'b1101111
`define JALR 7'b1100111
`define BRANCH 7'b1100011
`define LOAD 7'b0000011
`define STORE 7'b0100011
`define CALCI 7'b0010011
`define CALCR 7'b0110011
`define FENCE 7'b0001111
`define SYSTEM 7'b1110011

`define CSRRW 3'b001
`define CSRRS 3'b010
`define CSRRWI 3'b101

`define MRET 32'b0011000_00010_00000_000_00000_1110011

module controller(input logic        clk,
                  input logic         reset,

                  input logic [31:0]  instruction,

                  output logic        execute_result_write_enable,
                  output logic        load_memory_data_write_enable,
                  output logic        pc_write_enable,
                  output logic        instruction_write_enable,
                  output logic        register_file_write_enable,
                  output logic        memory_write_enable,

                  output logic        write_immediate_to_register_file,
                  output logic        write_pc_inc_to_register_file,
                  output logic        write_execute_result_to_pc,
                  output logic        write_execute_result_to_pc_if_compare_met,
                  output logic        write_load_memory_to_register_file,

                  output logic        use_execute_result_for_read_memory,

                  output logic        execute_alu,
                  output logic        execute_compare,
                  output logic        execute_shift,
                  output logic        execute_csr,
                  output logic        use_immediate,
                  output logic        use_immediate_for_compare,
                  output logic        use_pc_for_alu,

                  output logic [2:0]  immediate_type,
                  output logic [2:0]  alu_type,
                  output logic [1:0]  shift_type,
                  output logic [2:0]  compare_type,
                  output logic [2:0]  load_memory_decoder_type,
                  output logic [1:0]  store_memory_encoder_type,
                  output logic [1:0]  csr_access_type,

                  output logic [11:0] csr_number,

                  output logic [2:0]  debug_state,
                  output logic        trap);

   logic [6:0]                        opcode;
   logic [2:0]                        funct3;
   logic [6:0]                        funct7;

   typedef enum                       logic [2:0]  {
                                                    fetch,
                                                    fetch2,
                                                    decode,
                                                    execute,
                                                    memory,
                                                    memory2,
                                                    write_back
                                                    } state;
   state current_state;
   state next_state;

   always_ff @(posedge clk)
     if(reset)
       current_state <= fetch;
     else
       current_state <= next_state;

   assign opcode = instruction[6:0];
   assign funct3 = instruction[14:12];
   assign funct7 = instruction[31:25];

   always_comb
     begin
        execute_result_write_enable = 0;
        load_memory_data_write_enable = 0;
        pc_write_enable = 0;
        instruction_write_enable = 0;
        register_file_write_enable = 0;
        memory_write_enable = 0;

        write_immediate_to_register_file = 0;
        write_pc_inc_to_register_file = 0;
        write_execute_result_to_pc = 0;
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
        load_memory_decoder_type = 3'bx;
        store_memory_encoder_type = 2'bx;
        csr_access_type = 2'b00;

        csr_number = instruction[31:20];

        case(current_state)
          fetch:
            begin
               next_state = fetch2;
            end

          fetch2:
            begin
               next_state = decode;
               instruction_write_enable = 1;
            end

          decode:
            begin
               next_state = execute;
            end

          execute:
            begin
               next_state = write_back;
               execute_result_write_enable = 1;
               if(opcode == `LUI)
                 ; // do nothing
               else if(opcode == `AUIPC ||
                       opcode == `JAR ||
                       opcode == `BRANCH)
                 begin
                    execute_alu = 1;
                    alu_type = `ALU_ADD;
                    use_pc_for_alu = 1;
                    use_immediate = 1;
                    case(opcode)
                      `AUIPC:
                        immediate_type = `IMM_U;
                      `JAR:
                        immediate_type = `IMM_J;
                      `BRANCH:
                        begin
                           immediate_type = `IMM_B;
                           compare_type = funct3;
                        end
                      default:
                        immediate_type = 3'bx;
                    endcase
                 end
               else if(opcode == `JALR)
                 begin
                    execute_alu = 1;
                    alu_type = `ALU_ADD;
                    use_immediate = 1;
                    immediate_type = `IMM_I;
                 end
               else if(opcode == `LOAD || opcode == `STORE)
                 begin
                    execute_alu = 1;
                    alu_type = `ALU_ADD;
                    use_immediate = 1;
                    immediate_type = (opcode == `LOAD) ? `IMM_I : `IMM_S;
                    next_state = memory;
                 end
               else if(opcode == `CALCI || opcode == `CALCR)
                 begin
                    if(opcode == `CALCI)
                      begin
                         use_immediate = 1;
                         use_immediate_for_compare = 1;
                         immediate_type = `IMM_I;
                      end
                    if(funct3[2:1] == 2'b01)
                      // compare set
                      begin
                         execute_compare = 1;
                         compare_type = funct3;
                      end
                    else if(funct3[1:0] == 2'b01)
                      // shift
                      begin
                         execute_shift = 1;
                         if(funct3 == 3'b001)
                           shift_type = `SHIFT_LEFT;
                         else if(funct7 == 7'b0000000)
                           shift_type = `SHIFT_RIGHT;
                         else if(funct7 == 7'b0100000)
                           shift_type = `SHIFT_ARITH;
                         else
                           trap = 1;
                      end
                    else
                      // alu
                      begin
                         execute_alu = 1;
                         alu_type = (opcode == `CALCR && funct7 == 7'b0100000) ? `ALU_SUB : funct3;
                      end
                 end
               else if(opcode == `FENCE)
                 begin
                    // currently we have no cache, act as nop.
                    next_state = write_back;
                 end
               else if(opcode == `SYSTEM)
                 begin
                    if(instruction == `MRET)
                      begin
                         execute_csr = 1;
                         csr_number = 12'h341;
                      end
                    else
                      case(funct3)
                        `CSRRW:
                          begin
                             execute_csr = 1;
                             csr_access_type = `CSR_WRITE;
                          end
                        `CSRRS:
                          begin
                             execute_csr = 1;
                             csr_access_type = `CSR_SET;
                          end
                        `CSRRWI:
                          begin
                             execute_csr = 1;
                             csr_access_type = `CSR_CLEAR;
                             use_immediate = 1;
                          end
                        default:
                          trap = 1;
                      endcase
                    next_state = write_back;
                 end
               else
                 trap = 1;
            end

          memory:
            begin
               next_state = write_back;
               if(opcode == `LOAD)
                 begin
                    use_execute_result_for_read_memory = 1;
                    next_state = memory2;
                 end
               else if(opcode == `STORE)
                 begin
                    memory_write_enable = 1;
                    store_memory_encoder_type = funct3[1:0];
                 end
            end

          memory2:
            begin
               next_state = write_back;
               load_memory_decoder_type = funct3;
               load_memory_data_write_enable = 1;
            end

          write_back:
            begin
               next_state = fetch;
               pc_write_enable = 1;

               if(opcode == `LUI ||
                  opcode == `AUIPC ||
                  opcode == `JAR ||
                  opcode == `JALR ||
                  opcode == `LOAD ||
                  opcode == `CALCI ||
                  opcode == `CALCR)
                 register_file_write_enable = 1;

               if(opcode == `LUI)
                 begin
                    write_immediate_to_register_file = 1;
                    immediate_type = `IMM_U;
                 end
               else if(opcode == `JAR ||
                       opcode == `JALR)
                 begin
                    write_pc_inc_to_register_file = 1;
                    write_execute_result_to_pc = 1;
                 end
               else if(opcode == `BRANCH)
                 begin
                    write_execute_result_to_pc_if_compare_met = 1;
                 end
               else if(opcode == `LOAD)
                 begin
                    write_load_memory_to_register_file = 1;
                 end
               else if(opcode == `SYSTEM)
                 begin
                    if(instruction == `MRET)
                      write_execute_result_to_pc = 1;
                    // csr
                    if(funct3 != 3'b000 && funct3 != 3'b100)
                      register_file_write_enable = 1;
                 end
            end

          default:
            next_state = 3'bx; // dont care
        endcase
     end

   assign debug_state = current_state;
endmodule
