#!/bin/sh

if [ "x$1" = "x" ] ; then
	echo "Usage: $0 [framedir]"
else
	echo -n "catting frames..."
	for n in $1/frame*.txt ; do cat $n >> $1.txt && echo "c" >> $1.txt && echo -n "." ; done
	echo "ok"

	echo -n "compressing..."
	cat $1.txt | 7z a -tgzip -mx=9 -mpass=4 -mfb=255 -si $1.gz
	echo "ok"

	echo -n "building header..."
	perl lemontree.pl $1.gz
	chmod +x $1.pl
	echo "ok"

	echo -n "tidying up..."
	rm -f $1.txt
	rm -f $1.gz
	echo "ok"
fi
