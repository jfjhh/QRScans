QRScans
=======

Imagine, you take a picture of a document, and it is uploaded to the URL encoded
by the QR code that is printed on it. Then, just scan the QR code and see the
scanned document and others scanned before it, or even throw away the original
and distribute the QR code, or just destroy all the paper and have it all be
digital. Yes, I implemented this with a bunch of bash scripts hacked together.

### The Trade-off ###

When printing a QR code on a document, I want it to be as small as possible, to
not infringe on the material on the piece of paper. However, the smaller the QR
code the harder it is to read, because it is a smaller percentage of the final
image, and has less error correction. I have opted for `H`-level error
correction in my QR codes (I had leftover space because the URLs are short), and
they end up being about `16mm` square on the paper. This is big enough to be
reliably scanned, but not big enough to the point that it seems unsightly.

### How it Works ###

You just run `qr-daemon.sh`. It doesn't care if it is sourced or executed
(`./x.sh` *vs.* `. x.sh`).

The daemon checks, via inotify, if any new files have been synced by OwnCloud.
If so, then try to read a QR code from the image. If this fails, then it is
assumed to be a normal image (think cat pictures), and the scanned and temporary
files are deleted. Otherwise, the code is recognized, and the scanned image is
renamed to be the image named in the encoded URL (like `42.jpg`). The sync
script is then executed, which creates a HTML file with the image's metadata,
the ability to see the image larger, and navigation links to the previous and
next images. Every time a new image is added, all the pages are regenerated, so
that these navigation links reflect changes in uploaded scans. If no previous or
next image exists, the links will go to the index, `/s/`. The images and the
HTML are then rsync'd to the web server. The whole process, from picture on
phone, past upload to OwnCloud, to availability on the web server, takes a few
minutes per image. This is because OwnCloud clients are a bit slow to update for
this kind of task, and because the image processing in `textcleaner.sh` is
insanely CPU intensive.

* * *

### Scripts ###

These scripts require some things that may not be installed on most \*nix
systems.

- `inotify-tools` (`inotifywait`).
- `zbar-tools` (`zbarimg`).
- `GNU Parallel` (`parallel`).
- `qrencode` (`qrencode`).
- `ImageMagick` (`identify`, `convert`, `mogrify`, etc.).

#### Writing (Printing) QR Codes ####

- `qr-lp.sh`
- `qr-writel.sh`
- `qr-writed.sh`

#### Reading QR Codes ####

- `qr-read.sh`

#### Watching for New Images (OwnCloud) ####

- `qr-daemon.sh`

### Syncing Images (and HTML) ###

- `qr-sync.sh`

### Scan Image Processing (Reused, Credit: Fred Weinhaus) ###

I was too lazy to implement fancy scripts for ImageMagick to scan documents
(similar to how Google Drive scans documents), so I use `textcleaner.sh` with
parameters that I have toyed around with (see `qr-read.sh` for the parameters).

- `textcleaner.sh`

* * *

### Too Meta ###

These scripts, except `textcleaner.sh`, are scanned, of course.

- [1.html](http://jfjhh.ddns.net/s/1.html)
- [2.html](http://jfjhh.ddns.net/s/2.html)
- [3.html](http://jfjhh.ddns.net/s/3.html)
- [4.html](http://jfjhh.ddns.net/s/4.html)

I look forward to the smug satisfaction of watching people be all, "WTF is
this QR code?" and replying, *"Scan it."*

[![http://jfjhh.ddns.net/s/0.html](http://jfjhh.ddns.net/images/qr.png)](http://jfjhh.ddns.net/s/0.html)

