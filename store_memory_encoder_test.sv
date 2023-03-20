module store_memory_encoder_test ();
  logic [1:0] type_;
  logic [1:0] offset;
  logic [31:0] in, out;
  logic [3:0] sel;
  logic exception;

  store_memory_encoder dut (
      type_,
      offset,
      in,
      out,
      sel,
      exception
  );

  initial begin
    // SB
    type_ = 2'b00;
    offset = 0;
    in = 32'h000000ff;
    #1;
    assert (exception === 0 && out[7:0] === 8'hff && sel === 4'b0001)
    else $fatal;

    type_ = 2'b00;
    offset = 1;
    in = 32'h000000ff;
    #1;
    assert (exception === 0 && out[15:8] === 8'hff && sel === 4'b0010)
    else $fatal;

    type_ = 2'b00;
    offset = 2;
    in = 32'h000000ff;
    #1;
    assert (exception === 0 && out[23:16] === 8'hff && sel === 4'b0100)
    else $fatal;

    type_ = 2'b00;
    offset = 3;
    in = 32'h000000ff;
    #1;
    assert (exception === 0 && out[31:24] === 8'hff && sel === 4'b1000)
    else $fatal;

    // SH
    type_ = 2'b01;
    offset = 0;
    in = 32'h0000ffff;
    #1;
    assert (exception === 0 && out[15:0] === 16'hffff && sel === 4'b0011)
    else $fatal;

    type_ = 2'b01;
    offset = 1;
    in = 32'h0000ffff;
    #1;
    assert (exception === 0 && out[23:8] === 16'hffff && sel === 4'b0110)
    else $fatal;

    type_ = 2'b01;
    offset = 2;
    in = 32'h0000ffff;
    #1;
    assert (exception === 0 && out[31:16] === 16'hffff && sel === 4'b1100)
    else $fatal;

    type_ = 2'b01;
    offset = 3;
    in = 32'h0000ffff;
    #1;
    assert (exception === 1)
    else $fatal;

    // SW
    type_ = 2'b10;
    offset = 0;
    in = 32'hffffffff;
    #1;
    assert (exception === 0 && out === 32'hffffffff && sel === 4'b1111)
    else $fatal;

    type_ = 2'b10;
    offset = 1;
    in = 32'hffffffff;
    #1;
    assert (exception === 1)
    else $fatal;
  end

endmodule
