#!/bin/sh

OBJCOPY=${OBJCOPY:-riscv64-unknown-elf-objcopy}

set -eu

if ! [ -d test-assets/riscv-tests ]; then
    mkdir -p test-assets
    git clone --recurse-submodules https://github.com/riscv/riscv-tests.git test-assets/riscv-tests
fi

(cd test-assets/riscv-tests; ./configure && make)

for input in $(find test-assets/riscv-tests/isa -maxdepth 1 -type f -executable \( -name "rv32ui-p-*" -o -name "rv32mi-p-*" \) ); do
    $OBJCOPY -O binary $input test-assets/$(basename $input).bin
done
