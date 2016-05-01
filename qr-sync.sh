#!/bin/bash

# Syncs QR Code images in directory $1 to the remote webserver (via rsync). It
# generates a HTML file with information about the image, and keeps track of
# prevous/next image links.

[ -d "$1" ] || return 1
DIR="$1"
INDEX="$DIR/index.html"

IMAGES=(`ls $DIR/ | grep "[0-9].jpg$" | sort -n`)

FIRST=`basename ${IMAGES[0]} | sed 's/\.jpg$/\.html/'`
LAST=`basename ${IMAGES[$((${#IMAGES[@]} - 1))]} | sed 's/\.jpg$/\.html/'`

for ((i = 0; i < ${#IMAGES[@]}; i++)); do
	img="${DIR}/${IMAGES[$i]}"
	n="`basename -s '.jpg' ${img}`"
	info="$(cd $DIR && file -b ${IMAGES[$i]} | sed 's%,%\n%g')"
	h="${n}.html"
	t="${n}_t.jpg"

	echo $i ${IMAGES[$i]} >&2

	! [ -e "${DIR}/${t}" ] && convert $img -resize 10% "${DIR}/${t}"

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
			<img src="/s/${t}" alt="Scanned Image $n"
			title="Updated: `date -I`" />
			<h3>Click to Enlarge.</h3>
			<h2>
				<a href="/s/${FIRST}">&lt;&lt;</a>
				&nbsp;<a href="/s/${p}">&lt;= Previous</a>
				<br />
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="/s/">::</a>
				&nbsp;<a href="/s/${q}">Next =&gt;</a>
				&nbsp;<a href="/s/${LAST}">&gt;&gt;</a>
			</h2>
		</a>
		<div class="info"><pre><code>$info</code></pre></div>
	</body>
</html>
	EOF
done

cat <<-EOF > $INDEX
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
		<title>Site J.2 - Scan Index</title>
		<link rel="stylesheet" type="text/css" href="/css/scan.css" />
	</head>
	<body>
EOF

for ((i = 0; i < ${#IMAGES[@]}; i++)); do
	img="${DIR}/${IMAGES[$i]}"
	n="`basename -s '.jpg' ${img}`"
	h="${n}.html"
	t="${n}_t.jpg"
	cat <<-EOF >> $INDEX
<!-- Thumbnail for image ${n}. -->
<div class="thumb">
	<a class="image" href="/s/${n}.jpg">
		<img src="/s/${t}" alt="Scanned Image $n"
		title="Updated: `date -I`" />
	</a>
</div>

	EOF
done

cat <<-EOF >> $INDEX
	</body>
</html>
EOF

rsync -av --delete --checksum ${DIR}/ jfjhh@nouveau.local:/var/www/scans/

