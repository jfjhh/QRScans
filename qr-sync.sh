#!/bin/bash

# Syncs QR Code images in directory $1 to the remote webserver (via rsync). It
# generates a HTML file with information about the image, and keeps track of
# prevous/next image links.

[ -d "$1" ] || return 1
DIR="$1"

for i in `ls $DIR/ | grep ".jpg$"`; do

	f=serial.txt
	n="`basename $DIR/$i | sed 's%\..\+$%%'`"
	info="$(cd $DIR && file $i | sed 's%,%\n%g')"
	h="${n}.html"

	let p=n-1
	let q=n+1
	read SER < $f

	# Previous page or index.
	# [[ $p -lt 1 ]] && p="" || p="${p}.html"
	[ -f "${DIR}/${p}.jpg" ] && p="${p}.html" || p=""

	# Next page or index.
	# [[ $q -gt $SER ]] && q="" || q="${q}.html"
	[ -f "${DIR}/${q}.jpg" ] && q="${q}.html" || q=""

	cat <<-EOF > $DIR/$h
<!DOCTYPE html>

<!--
   __     ______     __     __  __     __  __
  /\ \   /\  ___\   /\ \   /\ \_\ \   /\ \_\ \
 _\_\ \  \ \  __\  _\_\ \  \ \  __ \  \ \  __ \
/\_____\  \ \_\   /\_____\  \ \_\ \_\  \ \_\ \_\
\/_____/   \/_/   \/_____/   \/_/\/_/   \/_/\/_/
-->

<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Site J.2 - Scan $n</title>
		<link rel="stylesheet" type="text/css" href="/css/scan.css" />
	</head>
	<body>
		<a class="image" href="/s/$i">
			<h1>$i</h1>
			<img src="/s/$i" alt="Scanned Image $n"
			title="Updated: `date -I`" height="100%" width="100%"/>
			<h3>Click to Enlarge.</h3>
			<h2>
				<a href="/s/${p}">&lt;= Previous</a> ::
				<a href="/s/${q}">Next =&gt;</a>
			</h2>
		</a>
		<div class="info"><pre><code>$info</code></pre></div>
	</body>
</html>
	EOF
done

rsync -av --delete --checksum ${DIR}/ jfjhh@nouveau.local:/var/www/scans/

