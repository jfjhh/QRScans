#!/bin/bash

# QR Code Daemon. Watches for updates in image directory, and then starts the
# reading and syncing QR scripts.

IMGDIR="`readlink -f ~/Documents/media/images/android/`"
DMONDIR="`cd "$(dirname \`readlink -f "${BASH_SOURCE[0]}"\`)" && pwd`"
OUTDIR="${DMONDIR}/out"
FIFO="${DMONDIR}/inotify_images.fifo"
RUNDIR="`pwd`"
INOTIFYCMD=$(cat <<-CMD
inotifywait \
	--event moved_to \
	--format %f \
	--monitor \
	${IMGDIR}
CMD
)

(
echo -e "RUNDIR:\t\t"   $RUNDIR
echo -e "DAEMON:\t\t"   $DMONDIR
echo -e "IMGDIR:\t\t"   $IMGDIR
echo -e "OUTDIR:\t\t"   $OUTDIR
echo -e "FIFO:\t\t"     $FIFO
echo -e "INOTIFYCMD:\t" $INOTIFYCMD
) 1>&2

cd "$DMONDIR"
mkfifo "${FIFO}" 2> /dev/null

( $INOTIFYCMD > ${FIFO} | tee /dev/stderr ) &

while read f; do
	IMG="${IMGDIR}/${f}"
	echo -n "Found ${IMG} ... " 1>&2
	if [ -f "${IMG}" ]; then
		source qr-read.sh "${IMG}" \
			&& source qr-sync.sh "${OUTDIR}" \
			&& echo "Synced!" 1>&2 \
			|| echo "ERROR!" 1>&2
	else
		echo "Does not exist!" 1>&2
	fi
done < ${FIFO}

