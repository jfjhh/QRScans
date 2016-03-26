#!/bin/bash

# Printes QR codes in a linear fashion, one after another. Prints $1 codes.

f=serial.txt

read NUM < $f

let NEW=$NUM+$1
echo $NEW 1>&2

for ser in `seq $(($NUM+1)) $(($NEW))`; do
	source qr-lp.sh ${ser}
done

echo $NEW > $f

