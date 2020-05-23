test: a.out
	./a.out

a.out: register_file_test.sv register_file.sv
	iverilog -g2005-sv $^

.PHONY: test
