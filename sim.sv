module sim(input logic clk,
           input logic         reset,

           output logic [31:0] debug_pc,
           output logic [31:0] debug_instruction,
           output logic [2:0]  debug_state,
           output logic        trap);

   logic [31:0]                read_memory_data;
   logic [31:0]                read_memory_address;
   logic [31:0]                write_memory_data;
   logic [31:0]                write_memory_address;
   logic [31:0]                write_memory_mask;
   logic                       memory_write_enable;

   core #(32'h80000000) core(clk,
                             reset,
                             read_memory_data,
                             read_memory_address,
                             write_memory_data,
                             write_memory_address,
                             write_memory_mask,
                             memory_write_enable,
                             debug_pc,
                             debug_instruction,
                             debug_state,
                             trap);

   memory memory(clk,
                 read_memory_data,
                 read_memory_address,
                 write_memory_data,
                 write_memory_address,
                 write_memory_mask,
                 memory_write_enable);
endmodule

module memory(input logic clk,
              output logic [31:0] read_memory_data,
              input logic [31:0]  read_memory_address,
              input logic [31:0]  write_memory_data,
              input logic [31:0]  write_memory_address,
              input logic [31:0]  write_memory_mask,
              input logic         memory_write_enable);

   logic [31:0]                   ra;
   logic [31:0]                   wa;

   import "DPI-C" function void memory_write(input int addr, input int data, input int mask);
   import "DPI-C" function int memory_read(input int addr);

   always_ff @(posedge clk)
     if(memory_write_enable)
       memory_write(wa, write_memory_data, write_memory_mask);
     else
       read_memory_data <= memory_read(ra);

   assign ra = {read_memory_address[31:2], 2'b0};
   assign wa = {write_memory_address[31:2], 2'b0};
endmodule
