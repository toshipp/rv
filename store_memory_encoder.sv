`include "store_memory_encoder_pkg.sv"

module store_memory_encoder (
    input logic [1:0] type_,
    input logic [1:0] offset,
    input logic [31:0] in,
    output logic [31:0] out,
    output logic [3:0] sel,
    output logic misaligned_exception
);
  always_comb begin
    misaligned_exception = 0;
    out = 'bx;
    sel = 4'bx;

    case (type_)
      store_memory_encoder_pkg::STORE_B:
      case (offset)
        0: begin
          out = {24'bx, in[7:0]};
          sel = 4'b0001;
        end
        1: begin
          out = {16'bx, in[7:0], 8'bx};
          sel = 4'b0010;
        end
        2: begin
          out = {8'bx, in[7:0], 16'bx};
          sel = 4'b0100;
        end
        3: begin
          out = {in[7:0], 24'bx};
          sel = 4'b1000;
        end
      endcase

      store_memory_encoder_pkg::STORE_H:
      case (offset)
        0: begin
          out = {16'bx, in[15:0]};
          sel = 4'b0011;
        end
        1: begin
          out = {8'bx, in[15:0], 8'bx};
          sel = 4'b0110;
        end
        2: begin
          out = {in[15:0], 16'bx};
          sel = 4'b1100;
        end
        default: misaligned_exception = 1;
      endcase

      store_memory_encoder_pkg::STORE_W:
      case (offset)
        0: begin
          out = in;
          sel = 4'b1111;
        end
        default: misaligned_exception = 1;
      endcase

      default: ;
    endcase
  end
endmodule
