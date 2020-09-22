module regcell_reset #(
    parameter RESET_VALUE = 0
) (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] in,
    input  logic        write_enable,
    output logic [31:0] out
);
  always_ff @(posedge clk)
     if(reset)
       out <= RESET_VALUE;
     else if(write_enable)
       out <= in;
endmodule
