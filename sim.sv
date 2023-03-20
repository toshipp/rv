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

  logic        ack;
  logic [31:0] data_m2c;
  logic [31:0] data_c2m;
  logic [31:0] adr;
  logic [ 3:0] sel;
  logic        we;
  logic        stb;

  core #(32'h80000000) core (
      clk,
      reset,
      ack,
      data_m2c,
      adr,
      data_c2m,
      sel,
      we,
      stb,
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
      ack,
      data_m2c,
      data_c2m,
      adr,
      sel,
      we,
      stb
  );
endmodule

module memory (
    input  logic        clk_i,
    output logic        ack_o,
    output logic [31:0] data_o,
    input  logic [31:0] data_i,
    input  logic [31:0] adr_i,
    input  logic [ 3:0] sel_i,
    input  logic        we_i,
    input  logic        stb_i
);

  logic [31:0] adr;
  logic [31:0] mask;

  import "DPI-C" function void memory_write(input int addr, input int data, input int mask);
  import "DPI-C" function int memory_read(input int addr);

  always_ff @(posedge clk_i) begin
    if (stb_i)
      if (we_i) memory_write(adr, data_i, mask);
      else data_o <= memory_read(adr);

    ack_o <= stb_i;
  end

  assign adr  = {adr_i[31:2], 2'b0};
  assign mask = {{8{sel_i[3]}}, {8{sel_i[2]}}, {8{sel_i[1]}}, {8{sel_i[0]}}};

endmodule
