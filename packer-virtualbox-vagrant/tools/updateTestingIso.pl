#!/usr/bin/perl
# This programm updates the SHA512SUM of the Debian testing manifest
# based on the cheksums provided by debian-cd
use strict;
use warnings;
use JSON;
use LWP::Simple;

my $url = 'http://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/SHA512SUMS';
my $file = '/tmp/packer-virtualbox-vagrant-SHA512SUMS';

getstore($url, $file);

open (DATA, "< $file");

my $content;

while (my $line = <DATA>) {
	$content .= $line;
}

close DATA;
unlink $file;

# get the iso checksum by stripping the iso name
# iso name is expressed as a suit of blank spaces, one word and a carriage return
my $isoSum = $content =~ s/\s*\S+\n//r;

my $json;
{
	local $/;
	open (my $fh, "<", "debian-9-testing-virtualbox.json");
	$json = <$fh>;
	close $fh;
}

my $manifest = decode_json($json);

print "old iso_checksum: ".$manifest->{'builders'}->[0]->{'iso_checksum'}."\n";
$manifest->{'builders'}->[0]->{'iso_checksum'} = $isoSum;
$manifest->{'builders'}->[0]->{'iso_checksum_type'} = 'sha512';
print "new iso_checksum: ".$isoSum."\n";

open my $fh, ">", "debian-9-testing-virtualbox.json";
print $fh JSON->new->pretty->encode($manifest)."\n";
close $fh;




	
	
