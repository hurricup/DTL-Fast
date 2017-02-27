#!/bin/perl

use strict;
use warnings FATAL => 'all';
use v5.10;

my @images = qw(5.24 5.22 5.20 5.18 5.16 5.14 5.12 5.10);

for my $version (@images)
{
    my $image_name = "perl:$version";
    my $log_name = "${image_name}_err.log";
    $log_name =~ s/[^\w\s\.\-]/#/gsi;
    say STDERR "Testing with $image_name...";
    if( system "docker run -it --rm --name perltest -v C:/Repository/DTL-Fast/:/workroot -w /workroot $image_name bash dockertest.sh > $log_name"){
        say STDERR "FAILED, logged into $log_name";
    }
    else
    {
        say STDERR "PASSED";
        unlink $log_name;
    }
}
