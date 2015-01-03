#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

my $dirs = ['./t/tmpl', './t/tmpl2'];

$context = DTL::Fast::Context->new({});

$template = DTL::Fast::Template->new( << '_EOT_' );
Simple {% comment Some explanation %} NOT RENDER {% uncomment need this %}uncomment in{% enduncomment %}{% endcomment %} comment test
_EOT_

$test_string = <<'_EOT_';
Simple uncomment in comment test
_EOT_

is( $template->render($context), $test_string, 'Simple uncomment in comment');

$template = DTL::Fast::Template->new( << '_EOT_' );
Simple {% uncomment need this %}uncomment in{% enduncomment %} test
_EOT_

$test_string = <<'_EOT_';
Simple uncomment in test
_EOT_

is( $template->render($context), $test_string, 'Simple uncomment in text without comment');

$test_string = <<'_EOT_';
This is commented Bingo test checking bar endit
_EOT_

is( get_template( 'uncomment_top.txt', $dirs)->render($context), $test_string, 'Uncomment in comment with inclusion');

$test_string = 'commented uncommented block test';

is( get_template( 'uncomment_nested.txt', $dirs)->render($context), $test_string, 'Nested comments');

$test_string = <<'_EOT_';
This block has

line 2

line 4
line 5

line 7
line 8
line 9

some logick
_EOT_

is( get_template( 'uncomment_if.txt', $dirs)->render($context), $test_string, 'Logic-breaking uncomment');

done_testing();
