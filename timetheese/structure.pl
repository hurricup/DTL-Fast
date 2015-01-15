#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Storable qw(freeze);
use Compress::Zlib;

my $tpl = get_template(
#    'child5.txt',
    'parent.txt',
    'dirs' => [ './tpl' ]
);
use Data::Dumper;
print Dumper($tpl);

open OF, '>', 'structure.cache';
binmode OF;
print OF Compress::Zlib::memGzip(freeze($tpl));
close OF;