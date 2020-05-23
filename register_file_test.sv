module register_file_test();
   logic clk;
   always begin
      clk = 0;
      #1;
      clk = 1;
      #1;
   end

   logic [4:0] read_address1, read_address2;
   logic [4:0] write_address;
   logic       write_enable;
   logic [31:0] write_data;
   logic [31:0] read_data1, read_data2;

   register_file dut(clk,
                     read_address1,
                     read_address2,
                     write_address,
                     write_data,
                     write_enable,
                     read_data1,
                     read_data2);

   initial begin;
      $dumpfile("dump.vcd");

      // x0 always returns 0.
      write_enable = 0;
      read_address1 = 0;
      read_address2 = 0;
      #10;
      assert(read_data1 === 0) else begin
         $display("$d", read_data1);
         $fatal;
      end
      assert(read_data2 === 0) else begin
         $display("$d", read_data2);
         $fatal;
      end

      // check whether data written can be read.
      write_enable = 1;
      write_address = 1;
      write_data = 1234;
      #10;
      write_enable = 1;
      write_address = 2;
      write_data = 5678;
      #10;

      write_enable = 0;
      read_address1 = 2;
      read_address2 = 1;

      #10;
      assert(read_data1 === 5678);
      assert(read_data2 === 1234);

      $finish;
   end
endmodule
