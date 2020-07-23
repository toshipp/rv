module load_memory_decoder_test();
   logic [2:0] type_;
   logic [1:0] offset;
   logic [31:0] in, out;

   load_memory_decoder dut(type_,
                           offset,
                           in,
                           out);

   initial begin
      // LB
      type_ = 3'b000;
      offset = 0;
      in = 32'hxxxxxxbf;
      #1;
      assert(out === 32'hffffffbf) else $fatal;

      type_ = 3'b000;
      offset = 1;
      in = 32'hxxxxbfxx;
      #1;
      assert(out === 32'hffffffbf) else $fatal;

      type_ = 3'b000;
      offset = 2;
      in = 32'hxxbfxxxx;
      #1;
      assert(out === 32'hffffffbf) else $fatal;

      type_ = 3'b000;
      offset = 3;
      in = 32'hbfxxxxxx;
      #1;
      assert(out === 32'hffffffbf) else $fatal;

      // LH
      type_ = 3'b001;
      offset = 0;
      in = 32'hxxxxbfff;
      #1;
      assert(out === 32'hffffbfff) else $fatal;

      type_ = 3'b001;
      offset = 2;
      in = 32'hbfffxxxx;
      #1;
      assert(out === 32'hffffbfff) else $fatal;

      // LW
      type_ = 3'b010;
      offset = 0;
      in = 32'hffffffff;
      #1;
      assert(out === 32'hffffffff) else $fatal;

      // LBU
      type_ = 3'b100;
      offset = 0;
      in = 32'hxxxxxxff;
      #1;
      assert(out === 32'h000000ff) else $fatal;

      type_ = 3'b100;
      offset = 1;
      in = 32'hxxxxffxx;
      #1;
      assert(out === 32'h000000ff) else $fatal;

      type_ = 3'b100;
      offset = 2;
      in = 32'hxxffxxxx;
      #1;
      assert(out === 32'h000000ff) else $fatal;

      type_ = 3'b100;
      offset = 3;
      in = 32'hffxxxxxx;
      #1;
      assert(out === 32'h000000ff) else $fatal;

      // LHU
      type_ = 3'b101;
      offset = 0;
      in = 32'hxxxxffff;
      #1;
      assert(out === 32'h0000ffff) else $fatal;

      type_ = 3'b101;
      offset = 2;
      in = 32'hffffxxxx;
      #1;
      assert(out === 32'h0000ffff) else $fatal;
   end
endmodule
