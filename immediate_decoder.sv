`define I 3'b000
`define S 3'b001
`define B 3'b010
`define U 3'b011
`define J 3'b100

module immediate_decoder(input  logic [2:0] type_,
                         input logic [31:0]  in,
                         output logic [31:0] out);
   always_comb
     case(type_)
       `I: out = {{21{in[31]}}, in[30:25], in[24:21], in[20]};
       `S: out = {{21{in[31]}}, in[30:25], in[11:8], in[7]};
       `B: out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
       `U: out = {in[31], in[30:20], in[19:12], 12'b0};
       `J: out = {{12{in[31]}}, in[19:12], in[20], in[30:25], in[24:21], 1'b0};
       default: out='bx;
     endcase
endmodule
