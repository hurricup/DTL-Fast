#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template select_template);

my $dirs = ['./t/tmpl'];
my $dirs2 = [@$dirs, './t/tmpl2'];

my( $template, $test_string);

$template = get_template('simple.txt', $dirs);
isa_ok($template, 'DTL::Fast::Template');
my $chunks = $template->{'chunks'};
isa_ok($chunks, 'ARRAY', 'Chunks generated');
my $chunk = $chunks->[0];
isa_ok($chunk, 'DTL::Fast::Template::Text', 'Text element');
is($chunk->render, 'simple', 'Simple template loading');

$test_string = <<'_EOT_';
This is a parent main text

This is a parent more text
_EOT_
$template = get_template('parent.txt', $dirs);
isa_ok($template, 'DTL::Fast::Template');
is($template->render, $test_string, 'Parent template loading');

$test_string = <<'_EOT_';
Child main text

This is a parent more text
_EOT_
$template = get_template('child0.txt', $dirs);
isa_ok($template, 'DTL::Fast::Template');
is($template->render, $test_string, 'One-level of inheritance, first block');

$test_string = <<'_EOT_';
This is a parent main text

Child more text
_EOT_
$template = get_template('child1.txt', $dirs);
isa_ok($template, 'DTL::Fast::Template');
is($template->render, $test_string, 'One-level of inheritance, second block');

$test_string = <<'_EOT_';
Child main text

Child more text
_EOT_
$template = get_template('child2.txt', $dirs);
isa_ok($template, 'DTL::Fast::Template');
is($template->render, $test_string, 'Two-level of inheritance, both blocks');

$template = get_template('child0.txt', $dirs);

is( $DTL::Fast::TEMPLATES_CACHE_HITS, 3, 'Templates cache');
is( $DTL::Fast::OBJECTS_CACHE_HITS, 1, 'Objecst cache');

$template = get_template('simple2.txt', $dirs2);
is( $template->render, 'simple2-text', 'Multiple directories search');

$test_string = <<'_EOT_';
This is a parent main text

Override from another directory
_EOT_
$template = get_template('childother.txt', $dirs2);
is( $template->render, $test_string, 'Cross-directory inheritance');

$template = select_template(['simple3.txt', 'simple.txt'], $dirs2);
is( $template->render, 'simple3-text', 'Multi-directory template selecting, backward');

$template = select_template(['simple.txt', 'simple3.txt'], $dirs2);
is( $template->render, 'simple', 'Multi-directory template selecting, forward');

done_testing();
