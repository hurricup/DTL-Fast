#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

my $dirs = ['./t/tmpl', './t/tmpl2'];
$context = new DTL::Fast::Context({
    'include' => ['child0.txt']
});

$test_string = 'this is a simple include';
is( get_template('included.txt', $dirs)->render($context), $test_string, 'Simple include block');

$test_string = 'And this is a simple include was nested';
is( get_template('included2.txt', $dirs)->render($context), $test_string, 'Two levels include');

$test_string = <<'_EOT_';
this is a Child main text

This is a parent more text
 include
_EOT_
chomp $test_string;
is( get_template('included_dynamic.txt', $dirs)->render($context), $test_string, 'Include from context value');


done_testing();
