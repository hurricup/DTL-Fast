#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;
use Date::Format;

my( $template, $test_string, $context);

my $dirs = ['./t/tmpl', './t/tmpl2'];

$context = DTL::Fast::Context->new({
    'format1' => '%B-%y-%Y-%Z-%z'
});


$template = '{% now format1 %}';
$test_string = Date::Format::time2str($context->get('format1'), time);

is( DTL::Fast::Template->new($template)->render($context), $test_string, 'Now formatting from variable.');

$template = '{% now "%%-%Z-%z-B-%y-%Y" %}';
$test_string = Date::Format::time2str('%%-%Z-%z-B-%y-%Y', time);

is( DTL::Fast::Template->new($template)->render($context), $test_string, 'Static now formatting.');


done_testing();
