module store_memory_encoder_test ();
  logic [1:0] type_;
  logic [1:0] offset;
  logic [31:0] in, out, mask;

  store_memory_encoder dut (
      type_,
      offset,
      in,
      out,
      mask
  );

  initial begin
    // SB
    type_ = 2'b00;
    offset = 0;
    in = 32'h000000ff;
    #1;
    assert ((out & mask) === 32'h000000ff)
    else $fatal;

    type_ = 2'b00;
    offset = 1;
    in = 32'h000000ff;
    #1;
    assert ((out & mask) === 32'h0000ff00)
    else $fatal;

    type_ = 2'b00;
    offset = 2;
    in = 32'h000000ff;
    #1;
    assert ((out & mask) === 32'h00ff0000)
    else $fatal;

    type_ = 2'b00;
    offset = 3;
    in = 32'h000000ff;
    #1;
    assert ((out & mask) === 32'hff000000)
    else $fatal;

    // SH
    type_ = 2'b01;
    offset = 0;
    in = 32'h0000ffff;
    #1;
    assert ((out & mask) === 32'h0000ffff)
    else $fatal;

    type_ = 2'b01;
    offset = 2;
    in = 32'h0000ffff;
    #1;
    assert ((out & mask) === 32'hffff0000)
    else $fatal;

    // SW
    type_ = 2'b10;
    offset = 0;
    in = 32'hffffffff;
    #1;
    assert ((out & mask) === 32'hffffffff)
    else $fatal;
  end
endmodule
