#!/bin/bash

# Syncs QR Code images in directory $1 to the remote webserver (via rsync). It
# generates a HTML file with information about the image, and keeps track of
# prevous/next image links.

[ -d "$1" ] || return 1
DIR="$1"

IMAGES=(`ls $DIR/ | grep ".jpg$" | sort -n`)
for ((i = 0; i < ${#IMAGES[@]}; i++)); do
	# f=serial.txt
	img="${DIR}/${IMAGES[$i]}"
	n="`basename -s '.jpg' ${img}`"
	info="$(cd $DIR && file -b $img | sed 's%,%\n%g')"
	h="${n}.html"

	echo $i ${IMAGES[$i]} >&2

	[ $i -gt 0 ] \
		&& p="`basename ${IMAGES[$(($i - 1))]} | sed 's/\.jpg$/\.html/'`" || p=""
	[ $i -lt $((${#IMAGES[@]} - 1)) ] \
		&& q="`basename ${IMAGES[$(($i + 1))]} | sed 's/\.jpg$/\.html/'`" || q=""

	cat <<-EOF > $DIR/$h
<!DOCTYPE html>

<!--
   __     ______     __     __  __     __  __
  /\\ \\   /\\  ___\\   /\\ \\   /\\ \\_\\ \\   /\\ \\_\\ \\
 _\\_\\ \\  \\ \\  __\\  _\\_\\ \\  \\ \\  __ \\  \\ \\  __ \\
/\\_____\\  \\ \\_\\   /\\_____\\  \\ \\_\\ \\_\\  \\ \\_\\ \\_\\
\\/_____/   \\/_/   \\/_____/   \\/_/\\/_/   \\/_/\\/_/
-->

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Site J.2 - Scan $n</title>
		<link rel="stylesheet" type="text/css" href="/css/scan.css" />
	</head>
	<body>
		<a class="image" href="/s/${n}.jpg">
			<h1>Scan ${n}</h1>
			<img src="/s/${n}.jpg" alt="Scanned Image $n"
			title="Updated: `date -I`" height="100%" width="100%"/>
			<h3>Click to Enlarge.</h3>
			<h2>
				<a href="/s/${p}">&lt;= Previous</a>
				&nbsp;<a href="/s/">::</a>&nbsp;
				<a href="/s/${q}">Next =&gt;</a>
			</h2>
		</a>
		<div class="info"><pre><code>$info</code></pre></div>
	</body>
</html>
	EOF
done

rsync -av --delete --checksum ${DIR}/ jfjhh@nouveau.local:/var/www/scans/

