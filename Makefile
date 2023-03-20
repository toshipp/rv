RISCV_GCC ?= riscv64-elf-gcc
RISCV_OBJCOPY ?= riscv64-elf-objcopy

UNIT_TESTS := $(wildcard *_test.sv)
UNIT_TEST_TARGETS := $(patsubst %.sv,%,$(UNIT_TESTS))

.PHONY: test
test: unit sim-test synth interrupt-test

.PHONY: unit
unit: $(UNIT_TEST_TARGETS)

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
	verilator -Wno-ENUMVALUE --cc -sv --exe --Mdir generated -o sim sim.sv sim.cc
	make -C generated -f Vsim.mk
	cp generated/sim sim

interrupt_test.exe: interrupt_test.S link.ld
	$(RISCV_GCC) -march=rv32g -mabi=ilp32 -nostdlib -T link.ld $< -o $@

interrupt_test.bin: interrupt_test.exe
	$(RISCV_OBJCOPY) -O binary $< $@

.PHONY: interrupt-test
interrupt-test: interrupt_test.bin sim
	mkdir -p log
	./sim --interrupt-on-after=20 --timeout=1000 $< 2>log/$@.log

test-assets/.done: scripts/test-assets.sh
	./scripts/test-assets.sh
	touch $@

.PHONY: sim-test
sim-test: test-assets/.done sim ./scripts/sim-test.sh
	./scripts/sim-test.sh

.PHONY: synth
synth: synth.ys $(wildcard *.sv)
	yosys -s synth.ys

.PHONY: build-image
build-image:
	BUILDAH_LAYERS=true buildah bud -t builder --squash .

.PHONY: clean
clean:
	rm -rf *__gen.v *.vvp sim generated test-assets log interrupt_test.exe interrupt_test.bin
