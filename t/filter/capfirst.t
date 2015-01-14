#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
    'var1' => "this is not 'sparta'!",
    'var2' => 'this is not "sparta"!',
});

my $SET = [
    {
        'template' => <<'_EOT_',
Static {{ "this is not 'sparta'!"|capfirst }}
_EOT_
        'test' => <<'_EOT_',
Static This is not &#39;sparta&#39;!
_EOT_
        'title' => 'Static uppercase',
    },
    {
        'template' => <<'_EOT_',
Dynamic {{ var1|capfirst }}
_EOT_
        'test' => <<'_EOT_',
Dynamic This is not &#39;sparta&#39;!
_EOT_
        'title' => 'Dynamic uppercase',
    },
];

foreach my $data (@$SET)
{
    is( DTL::Fast::Template->new($data->{'template'})->render($context), $data->{'test'}, $data->{'title'});
    
}

done_testing();
