#!/bin/bash

# Prints QR Codes in a duplex fashion. Prints $1 sheets worth of codes.

f=serial.txt

read NUM < $f
NEW=$(($NUM + ($1 * 2)))
echo $NEW 1>&2

for ser in `seq $(($NUM+1)) 2 $(($NEW))`; do
	source qr-lp.sh ${ser}
done

read -p "Flip (and rotate for odd n-up). Press <enter> to continue"

for ser in `seq $(($NUM+2)) 2 $(($NEW))`; do
	source qr-lp.sh ${ser}
done

echo $NEW > $f

