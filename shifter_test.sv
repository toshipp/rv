module shifter_test ();
  logic [31:0] in, out;
  logic [4:0] shift;
  logic [1:0] type_;

  shifter dut (
      type_,
      in,
      shift,
      out
  );

  initial begin
    ;
    // left shift
    in = 'b1;
    shift = 31;
    type_ = 2'b00;
    #1;
    assert(out === 'h80000000) else $fatal;

    // logical shift
    in = 'b10;
    shift = 1;
    type_ = 2'b01;
    #1;
    assert(out === 'b1) else $fatal;

    // arithmetic shift
    in = 'h80000000;
    shift = 31;
    type_ = 2'b10;
    #1;
    assert(out == 'hffffffff) else $fatal;
  end
endmodule
