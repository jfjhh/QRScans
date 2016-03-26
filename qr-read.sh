#!/bin/bash

# Reads a QR Code from file $1. Returns 0 on success, 1 on error, 2 for no
# arguments, and -1 for whatever else.

OUTDIR="out"
TMPDIR="`mktemp -d`"
IN="${TMPDIR}/qr-in.mpc"
SCAN="${OUTDIR}/`basename $1 | sed 's/\..\+$//'`-scan.jpg"
CACHE="${TMPDIR}/qr-in.cache"
OUT="${TMPDIR}/qr-out"
STATUS=-1
S=500 # Size of squares for cropping and searching for QR code.
O=$(($S / 2)) # Offset from corners of image.

if [ -n "$1" ]; then
	# Fancy but CPU intensive "scanned image" processing.
	( source textcleaner.sh -g -e stretch -f 64 -o 2 -u -s 2 -T \
		$1 ${SCAN} 2> /dev/null )

	# Faster "scanned image" processing, but not as good.
	# convert ${SCAN} \
		# 	-colorspace GRAY \
		# 	-brightness-contrast 0x42 \
		# 	-limit area 16mb \
		# 	${IN}

	# Convert image to ImageMagick native format for speed.
	convert ${SCAN} \
		-limit area 16mb \
		${IN}

	# Crop image into ${S} squares.
	# convert ${IN} -crop ${S}x${S} ${OUT}%04d.jpg

	# Crop image into ${S} squares.
	W=`identify -format %w ${IN}`
	H=`identify -format %h ${IN}`

	# Border squares.
	convert ${IN} -crop ${S}x${S}+0+0 ${OUT}-bTL.jpg
	convert ${IN} -crop ${S}x${S}+0+$(($H - $S)) ${OUT}-bBL.jpg
	convert ${IN} -crop ${S}x${S}+$(($W - $S))+0 ${OUT}-bTR.jpg
	convert ${IN} -crop ${S}x${S}+$(($W - $S))+$(($H - $S)) ${OUT}-bBR.jpg

	# Offset squares.
	convert ${IN} -crop ${S}x${S}+${O}+${O} ${OUT}-oTL.jpg
	convert ${IN} -crop ${S}x${S}+${O}+$(($H - $O - $S)) ${OUT}-oBL.jpg
	convert ${IN} -crop ${S}x${S}+$(($W - $O - $S))+${O} ${OUT}-oTR.jpg
	convert ${IN} -crop ${S}x${S}+$(($W - $O - $S))+$(($H - $O - $S)) ${OUT}-oBR.jpg

	# Full image.
	convert ${IN} ${OUT}-full.jpg

	# Get QR code from cropped squares
	URL="`zbarimg -q ${OUT}*.jpg | sed 's/QR-Code://' | head -1`"
	if [ -n "$URL" ]; then
		IMGNAME="`sed 's%http\://jfjhh\.ddns\.net/s/\(.*\)\.html%\1.jpg%' <<< $URL`"
		mv ${SCAN} ${OUTDIR}/${IMGNAME}
		STATUS=0
	else
		rm ${SCAN}
		STATUS=1
	fi
else
	echo "Give an image filename as the first argument!" 1>&2
	STATUS=2
fi

[ -d ${TMPDIR} ] && rm -r ${TMPDIR} 1>&2
return ${STATUS}

