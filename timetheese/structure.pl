#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);

my $tpl = get_template(
    'parent.txt',
    'dirs' => [ './tpl' ]
);
use Data::Dumper;
print Dumper($tpl);