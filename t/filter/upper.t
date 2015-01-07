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
Static {{ "tESt"|upper }}
_EOT_
        'test' => <<'_EOT_',
Static TEST
_EOT_
        'title' => 'Static uppercasing',
    },
    {
        'template' => <<'_EOT_',
Dynamic {{ var1|upper }}
_EOT_
        'test' => <<'_EOT_',
Dynamic TEST1
_EOT_
        'title' => 'Dynamic uppercasing',
    },
];

foreach my $data (@$SET)
{
    is( DTL::Fast::Template->new($data->{'template'}, [])->render($context), $data->{'test'}, $data->{'title'});
    
}

done_testing();
