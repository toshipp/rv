TESTS := $(wildcard *_test.sv)
TEST_TARGETS := $(patsubst %.sv,%,$(TESTS))

test: $(TEST_TARGETS)

%: %.vvp
	vvp $<

%.vvp: %.sv
	iverilog -g2005-sv -o $@ $< $(subst _test,,$<)

%.v: %.sv
	yosys -q -p "read_verilog -sv $<; proc; write_verilog $@"

immediate_decoder_test.vvp: immediate_decoder_test.sv immediate_decoder.v
	iverilog -g2005-sv -o $@ $^

load_memory_decoder_test.vvp: load_memory_decoder_test.sv load_memory_decoder.v
	iverilog -g2005-sv -o $@ $^

store_memory_encoder_test.vvp: store_memory_encoder_test.sv store_memory_encoder.v
	iverilog -g2005-sv -o $@ $^

.PHONY: test
