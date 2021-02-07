module sim (
    input logic clk,
    input logic reset,

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

  logic        memory_ready;
  logic        memory_valid;
  logic [31:0] read_memory_data;
  logic [31:0] read_memory_address;
  logic [31:0] write_memory_data;
  logic [31:0] write_memory_address;
  logic [31:0] write_memory_mask;
  logic        memory_enable;
  logic        memory_command;

  core #(32'h80000000) core (
      clk,
      reset,
      memory_ready,
      memory_valid,
      read_memory_data,
      read_memory_address,
      write_memory_data,
      write_memory_address,
      write_memory_mask,
      memory_command,
      memory_enable,
      external_interrupt,
      timer_interrupt,
      software_interrupt,
      debug_pc,
      debug_instruction,
      debug_state,
      debug_in1,
      debug_in2,
      debug_result
  );

  memory memory (
      clk,
      memory_ready,
      memory_valid,
      read_memory_data,
      read_memory_address,
      write_memory_data,
      write_memory_address,
      write_memory_mask,
      memory_command,
      memory_enable
  );
endmodule

module memory (
    input  logic        clk,
    output logic        memory_ready,
    output logic        memory_valid,
    output logic [31:0] read_memory_data,
    input  logic [31:0] read_memory_address,
    input  logic [31:0] write_memory_data,
    input  logic [31:0] write_memory_address,
    input  logic [31:0] write_memory_mask,
    input  logic        memory_command,
    input  logic        memory_enable
);

  logic [31:0] ra;
  logic [31:0] wa;

  import "DPI-C" function void memory_write(input int addr, input int data, input int mask);
  import "DPI-C" function int memory_read(input int addr);

  always_ff @(posedge clk)
    if (memory_enable) begin
      if (memory_command) memory_write(wa, write_memory_data, write_memory_mask);
      else read_memory_data <= memory_read(ra);

      memory_valid <= 1;
    end else memory_valid <= 0;

  assign ra = {read_memory_address[31:2], 2'b0};
  assign wa = {write_memory_address[31:2], 2'b0};

  assign memory_ready = 1;
endmodule
