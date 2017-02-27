#!/bin/perl

use strict;
use warnings FATAL => 'all';
use v5.10;

my @images = qw(5.24 5.22 5.20 5.18 5.16 5.14);

for my $version (@images)
{
    my $imagename = "perl:$version";
    die "Failed for $imagename" if (system "docker run -it --rm --name perltest -v C:/Repository/DTL-Fast/:/workroot -w /workroot $imagename bash dockertest.sh");
}
