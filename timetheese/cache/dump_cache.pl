#!/usr/bin/perl

use Storable;
use Compress::Zlib;
use Data::Dumper;

my $compressed = join '', <>;
my $serialized = Compress::Zlib::memGunzip($compressed);
my $data = Storable::thaw($serialized);
print Dumper($data);
