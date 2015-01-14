#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
    'var1' => "tEsT1",
    'var2' => 'Test2',
});

my $SET = [
    {
        'template' => <<'_EOT_',
Static {{ "tESt"|lower }}
_EOT_
        'test' => <<'_EOT_',
Static test
_EOT_
        'title' => 'Static lowercasing',
    },
    {
        'template' => <<'_EOT_',
Dynamic {{ var1|lower }}
_EOT_
        'test' => <<'_EOT_',
Dynamic test1
_EOT_
        'title' => 'Dynamic lowercasing',
    },
];

foreach my $data (@$SET)
{
    is( DTL::Fast::Template->new($data->{'template'})->render($context), $data->{'test'}, $data->{'title'});
    
}

done_testing();
