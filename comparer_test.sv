module comparer_test();
   logic [31:0] in1, in2;
   logic        out;
   logic [2:0]  type_;

   comparer dut(type_,
                in1,
                in2,
                out);

   initial begin
      // eq
      type_ = 3'b000;
      in1 = 1;
      in2 = 1;
      #1;
      assert(out === 1) else $fatal;

      // ne
      type_ = 3'b001;
      in1 = 1;
      in2 = 2;
      #1;
      assert(out === 1) else $fatal;

      // lt
      type_ = 3'b010;
      in1 = 'h80000000;
      in2 = 0;
      #1;
      assert(out === 1) else $fatal;

      type_ = 3'b100;
      in1 = 'h80000000;
      in2 = 0;
      #1;
      assert(out === 1) else $fatal;

      // ltu
      type_ = 3'b011;
      in1 = 0;
      in2 = 1;
      #1;
      assert(out === 1) else $fatal;

      type_ = 3'b110;
      in1 = 0;
      in2 = 1;
      #1;
      assert(out === 1) else $fatal;

      // ge
      type_ = 3'b101;
      in1 = 0;
      in2 = 'h80000000;
      #1;
      assert(out === 1) else $fatal;

      // geu
      type_ = 3'b111;
      in1 = 1;
      in2 = 0;
      #1;
      assert(out === 1) else $fatal;
   end
endmodule
