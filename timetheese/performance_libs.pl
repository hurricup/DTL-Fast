#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Storable qw(freeze thaw);
use Compress::Zlib;

my @libs = qw(
    Data::Dumper
    DBI
    Cache::Memcached
    Cache::Memcached::Fast
    warnings
    strict
    Storable
    Digest::MD5
    Compress::Zlib
    Encode
    Carp
    URI::Escape
    URI::Escape::XS
    JSON::XS
);

my $cmd = {
    map{
        $_ => sub { my $x=shift; sub{ system("perl -M$x -e \"1;\"");} }->($_)
    } @libs
};

timethese( 100, $cmd );
