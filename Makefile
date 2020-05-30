TESTS := $(wildcard *_test.sv)
TEST_TARGETS := $(patsubst %.sv,%,$(TESTS))

test: $(TEST_TARGETS)

%: %.vvp
	vvp $<

%.vvp: %.sv
	iverilog -g2005-sv -o $@ $< $(subst _test,,$<)

.PHONY: test
