module register_file (
    input  logic        clk,
    input  logic [ 4:0] read_address1,
    input  logic [ 4:0] read_address2,
    input  logic [ 4:0] write_address,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
  logic [31:0] rf[31:0];
  logic [31:0] d1, d2;

`ifdef VERILATOR
  export "DPI-C"
  task read_register
  ;

  task read_register(input int address, output int data);
    data = rf[address];
  endtask
`endif

  always_ff @(posedge clk)
    if (write_enable) rf[write_address] <= write_data;
    else begin
      d1 <= rf[read_address1];
      d2 <= rf[read_address2];
    end

  assign read_data1 = read_address1 == 0 ? 0 : d1;
  assign read_data2 = read_address2 == 0 ? 0 : d2;
endmodule
