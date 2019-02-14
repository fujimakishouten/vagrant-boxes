#!/usr/bin/perl

use strict;
use warnings;
use feature 'say';
use Data::Dumper;
use Scalar::Util qw(looks_like_number);

# this requires the use libguestfs-perl debian package
use Sys::Guestfs;


if (@ARGV < 1) {
    die "Usage: '$0 path/to/disk_image\n"
}

my $disk_image = $ARGV[0];
-f $disk_image or die "$disk_image not found\n";

# Open the guest in libguestfs so we can inspect it.
my $g = Sys::Guestfs->new();
$g->add_drive_opts ($disk_image, readonly => 1);
$g->launch();

my ($root_fs) = $g->inspect_os();
my $product_name = $g->inspect_get_product_name ($root_fs); #7.11
$g->close();

warn "Warning: $product_name is not a number\n" if ! looks_like_number $product_name;
say $product_name;
