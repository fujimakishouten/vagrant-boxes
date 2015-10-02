#!/usr/bin/perl
# This programm updates the SHA512SUM of the Debian testing manifest
# based on the cheksums provided by debian-cd
use strict;
use warnings;
use JSON;
use LWP::Simple;

my $url = 'http://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/SHA512SUMS';
my $template = 'debian-9-testing-virtualbox.json';

update_template(get_testing_sum($url), $template);

sub get_testing_sum {

	my ($url) = @_;
	my $file = '/tmp/packer-virtualbox-vagrant-SHA512SUMS';
getstore($url, $file);
	open (DATA, "< $file") or die "checksum file $file not found";
	my @lines = <DATA>;
	close DATA;
	unlink $file;
	# get the iso checksum by stripping the iso name
	# iso name is expressed as a suit of blank spaces, one word and a carriage return
	my $isoSum = $lines[0] =~ s/\s*\S+\n//r;
	return $isoSum
}

sub update_template {

	my ($isoSum, $template) = @_;
	my $json;
	{
		# redefine the record separator from \n to undef
		# allows reading all lines in a single step
		local $/ = undef;
		open (my $fh, "<", $template);
		$json = <$fh>;
		close $fh;
	}

	my $manifest = decode_json($json);

	my $old_iso_checksum = $manifest->{'builders'}->[0]->{'iso_checksum'};

	if ($isoSum eq $old_iso_checksum) {
		print "checksum $old_iso_checksum is up to date, doing nothing\n";
		return 0;
	} else {
		print "old iso_checksum: $old_iso_checksum\n";
		$manifest->{'builders'}->[0]->{'iso_checksum'} = $isoSum;
		print "new iso_checksum: ".$isoSum."\n";

		open (my $fh, ">", $template);
		my $json_printer = JSON->new;
		$json_printer = $json_printer->canonical(1);
		$json_printer = $json_printer->pretty(1);
		print $fh $json_printer->encode($manifest)."\n";
		close $fh;

		return 0;
	}
}
