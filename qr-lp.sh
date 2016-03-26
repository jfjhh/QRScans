#!/bin/bash

# Prints a QR Code for the URL for image $1.

ser="$1"

TMPDIR="`mktemp -d`"
QR="qr-" # Image prefix.
M=2	 # Scale factor.
W=850	 # Width of image.
H=1100	 # Height of image.

qrencode \
	-s 1 \
	-l H \
	-v 1 \
	-o ${TMPDIR}/${ser}.png \
	"http://jfjhh.ddns.net/s/${ser}.html"

X=`identify -format %w ${TMPDIR}/${ser}.png`
S=$((${M}*${X}))

mogrify -scale ${S}x${S} ${TMPDIR}/${ser}.png
convert \
	-page ${W}x${H}+$((${W}-${S}))+$((${H}-${S})) \
	-background '#fff' \
	+repage \
	-flatten \
	${TMPDIR}/${ser}.png \
	${TMPDIR}/${QR}${ser}.jpg

lp ${TMPDIR}/${QR}${ser}.jpg

rm -r ${TMPDIR} 1>&2

