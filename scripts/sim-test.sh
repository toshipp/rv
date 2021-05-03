#!/bin/sh

set -eu

ret=0

mkdir -p log

for input in $(ls test-assets/*.bin); do
    if ./sim $input 2>log/$(basename $input).log; then
        echo $(basename $input) ok
    else
        echo $(basename $input) ng
        ret=1
    fi
done

exit $ret
