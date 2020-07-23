TESTS := $(wildcard *_test.sv)
TEST_TARGETS := $(patsubst %.sv,%,$(TESTS))

test: $(TEST_TARGETS)

%: %.vvp
	vvp $<

%.vvp: %.sv
	iverilog -g2005-sv -o $@ $< $(subst _test,,$<)

%__gen.v: %.sv
	yosys -q -p "read_verilog -sv $<; proc; write_verilog $@"

immediate_decoder_test.vvp: immediate_decoder_test.sv immediate_decoder__gen.v
	iverilog -g2005-sv -o $@ $^

load_memory_decoder_test.vvp: load_memory_decoder_test.sv load_memory_decoder__gen.v
	iverilog -g2005-sv -o $@ $^

store_memory_encoder_test.vvp: store_memory_encoder_test.sv store_memory_encoder__gen.v
	iverilog -g2005-sv -o $@ $^

sim: sim.cc $(wildcard *.sv)
	verilator --cc -sv --exe --Mdir generated -o sim sim.sv sim.cc
	make -C generated -f Vsim.mk
	mv generated/sim sim

synth: synth.ys $(wildcard *.sv)
	yosys -s synth.ys

clean:
	rm -rf *__gen.v *.vvp sim generated

.PHONY: test clean
