module immediate_decoder_test();
   logic [2:0] type_;
   logic [31:0] in, out;

   immediate_decoder dut(type_, in,out);

   initial begin
      // I
      type_ = 3'b000;
      in = 32'hfff00000;
      #1;
      assert(out === 32'hffffffff) else $fatal;

      // S
      type_ = 3'b001;
      in = 32'hfe000f80;
      #1;
      assert(out === 32'hffffffff) else $fatal;

      // B
      type_ = 3'b010;
      in = 32'hfe000f00;
      #1;
      assert(out === 32'hfffff7fe) else $fatal;

      // U
      type_ = 3'b011;
      in = 32'hfffff000;
      #1;
      assert(out === 32'hfffff000) else $fatal;

      // J
      type_ = 3'b100;
      in = 32'hffeff000;
      #1;
      assert(out === 32'hfffff7fe) else $fatal;
   end
endmodule
