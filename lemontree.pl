#!/usr/bin/perl
#
# LemonADE: A somewhat fruity ascii demo engine
#
#     -- Shish
#
#
# 2005/09/22: For school we have to make an animated presentation about
#    floating point binary. Seeing as I dislike powerpoint, I decide to
#    make a flipbook style presentation by hand typing ASCII frames and
#    flicking though them by holding the Page Down button.
# 2005/09/23: I realise holding page down is a sucky method to animate,
#    and write a simple perl player which just loops through the frames
# 2005/09/24: The player gets some more basic features
# 2005/09/25: Realising that the presentation is ~5KB when tarballed, I
#    figure it shouldn't be hard to cut it down to a 4k demo. Replacing
#    the hand animated slides in & out with a perl function shrinks the
#    total size to 3k, so I aim for 2k
# 2005/09/26: With 7zip rather than gzip for compression, and some perl
#    pointers from Minase, 2k is cleared. Editing the data file to make
#    runs of whitespace all the same length and remove it at the end of
#    lines also saves ~50 bytes
# 2006/01/31: Saw I could save 6 bytes by replacing @s=blah;foreach(@s)
#    with foreach(blah)... How the fsck did I miss that :-/
# 2006/06/30: Posted in a slashdot discussion, Michael Woodhams replied
#    with suggestions to cut a few more bytes off
#

# Commands are pretty self enclosed; you can cut out any you don't use.
# The only exception being things like slide in / out which are written
# as one -- you can save space by manually removing the functionality,
# but it's not so neat.


use strict;
use warnings;

my $inputfile = $ARGV[0];
my $data = "";
my $outputfile = undef;
my $zdata = "";

if(-f $inputfile) {
	print "Opening pre-prepared data file...";
	# scan the raw data file to find out what commands are used
	open(DATA, "zcat $inputfile|") or die $!;
	while(<DATA>) {
		next if /^ /;
		next if /^$/;
		$data .= $_;
	}
	close(DATA);
	print "ok\n";

	print "Reading raw data...";
	# load the compressed data file
	open(ZDATA, "<$inputfile") or die $!;
	binmode(ZDATA);
	while(<ZDATA>) {
		$zdata .= $_;
	}
	close(ZDATA);
	print "ok\n";

	($outputfile) = $inputfile =~ /^(.*)\.gz$/;
	$outputfile .= ".pl";
	print "in:$inputfile, out:$outputfile\n";
}
elsif(-d $inputfile) {
	print "reading frames...";
	foreach(glob("$inputfile/*")) {
		print ".($_)\n";
		open(DATA, "<$_") or die $!;
		while(<DATA>) {
			next if /^ /;
			next if /^$/;
			$data .= $_;
		}
		close(DATA);
		$data .= "\nc\n";
	}
	print "ok\n";

	print "compressing...";
	open(TMP, "| 7z a -tgzip -mx=9 -mpass=4 -mfb=255 -si tmp.gz");
	print TMP $data;
	close(TMP);
	print "ok\n";

	print "reading data...";
	open(ZDATA, "<tmp.gz");
	binmode(ZDATA);
	while(<ZDATA>) {
		$zdata .= $_;
	}
	close(ZDATA);
	print "ok\n";

	($outputfile) = $inputfile =~ /^(.*)\/?$/;
	$outputfile .= ".pl";
	print "in:$inputfile, out:$outputfile\n";
}




# XXX: "tail -c +N" shows all but the first N bytes of the file --
# set this to whatever size this file is, and account for a newline
# after the END and before the data
my $output .= q($c=`clear`;for(`tail -c+SIZ $0|zcat`){);

# print buffer
if($data =~ /\np/) {
	$output .= q(
		if(/^p/){
			print@l;
			@l=()
		}
	);
}

# delay
if($data =~ /\nd(.+)/) {
	$output .= q(
		elsif(/^d(.+)/){
			select$u,$u,$u,$1/10
		}
	);
}

# slide in / out
if($data =~ /\ns(.)/) {
	$output .= q(
		elsif(/^s(.)/){
			$s=9;$e=-30;$m=-1;
			if('o'eq$1){
				$s=-30;$e=9;$m=1
			}
			for($i=$s;$i!=$e;$i+=$m){
				$j=0;
				for(@l){
					print substr($_,$i+$j++>0?($i+$j)**2:0,-1)."\n"
				}
				select$u,$u,$u,.1;
				print$c
			}
		}
	);
}

# clear screen
if($data =~ /\nc/) {
	$output .= q(
		elsif(/^c/){
			print$c;
			@l=()
		}
	);
}

# default, add to buffer
$output .= q(
		else{
			push@l,$_
		}
	}
	__END__
);

$output =~ s/[\n\t]//g;
my $size = sprintf("%03i", length($output)+2);
$output =~ s/SIZ/$size/;

open(FOUT, ">$outputfile") or die $!;
print FOUT "$output\n$zdata";
close(FOUT);
