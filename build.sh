#!/bin/sh

rm -f $1.gz
for n in $1/frame*.txt ; do cat $n >> $1.txt && echo "{c}" >> $1.txt ; done
cat $1.txt | 7z a -tgzip -mx=9 -mpass=4 -mfb=255 -si $1.gz
rm -f $1.txt
perl lemontree.pl $1.gz
rm -f $1.gz
