`include "alu_pkg.sv"

module alu #(
    parameter N = 32
) (
    input  logic [  2:0] type_,
    input  logic [N-1:0] in1,
    input  logic [N-1:0] in2,
    output logic [N-1:0] out
);
  always_comb
    case (type_)
      alu_pkg::ALU_ADD: out = in1 + in2;
      alu_pkg::ALU_SUB: out = in1 - in2;
      alu_pkg::ALU_XOR: out = in1 ^ in2;
      alu_pkg::ALU_OR:  out = in1 | in2;
      alu_pkg::ALU_AND: out = in1 & in2;
      default:          out = 'bx;
    endcase
endmodule
