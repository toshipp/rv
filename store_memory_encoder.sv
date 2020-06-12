`define B 2'b00
`define H 2'b01
`define W 2'b10

module store_memory_encoder(input logic [1:0] type_,
                            input logic [1:0]   offset,
                            input logic [31:0]  in,
                            output logic [31:0] out,
                            output logic [31:0] mask);
   always_comb
     case(type_)
       `B:
         case(offset)
           0:
             begin
                out = {24'bx, in[8:0]};
                mask = 32'h000000ff;
             end
           1:
             begin
                out = {16'bx, in[7:0], 8'bx};
                mask = 32'h0000ff00;
             end
           2:
             begin
                out = {8'bx, in[7:0], 16'bx};
                mask = 32'h00ff0000;
             end
           3:
             begin
                out = {in[7:0], 24'bx};
                mask = 32'hff000000;
             end
         endcase
       `H:
         case(offset)
           0:
             begin
                out = {16'bx, in[15:0]};
                mask = 32'h0000ffff;
             end
           2:
             begin
                out = {in[15:0], 16'bx};
                mask = 32'hffff0000;
             end
           default:
             // trap?
             begin
                out = 'bx;
                mask = 'bx;
             end
         endcase
       `W:
         case(offset)
           0:
             begin
                out = in;
                mask = 32'hffffffff;
             end
           default:
             // trap?
             begin
                out = 'bx;
                mask = 'bx;
             end
         endcase
       default:
         begin
            out = 'bx;
            mask = 'bx;
         end
     endcase
endmodule
