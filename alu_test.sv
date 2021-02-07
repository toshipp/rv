module alu_test ();
  logic [31:0] in1, in2, out;
  logic [2:0] type_;

  alu dut (
      type_,
      in1,
      in2,
      out
  );

  initial begin
    ;
    // add
    type_ = 3'b000;
    in1   = 10;
    in2   = 40;
    #1;
    assert (out === 50)
    else $fatal;

    // sub
    type_ = 3'b001;
    in1   = 30;
    in2   = 10;
    #1;
    assert (out === 20)
    else $fatal;

    // xor
    type_ = 3'b100;
    in1   = 'b1111;
    in2   = 'b1010;
    #1;
    assert (out === 'b0101)
    else $fatal;

    // or
    type_ = 3'b110;
    in1   = 'b0101;
    in2   = 'b1010;
    #1;
    assert (out === 'b1111)
    else $fatal;

    // and
    type_ = 3'b111;
    in1   = 'b1011;
    in2   = 'b0101;
    #1;
    assert (out === 'b0001)
    else $fatal;
  end
endmodule
