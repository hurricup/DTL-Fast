#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;use utf8;

use DTL::Fast;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
    'var1' => '>',
    'var2' => '<',
    'var3' => '&',
    'var4' => '"',
    'var5' => '\'',
});

my $SET = [
    {
        'template' => ">",
        'test' => '&gt;',
        'title' => 'Greater than',
    },
    {
        'template' => "<",
        'test' => '&lt;',
        'title' => 'Lesser than',
    },
    {
        'template' => "&",
        'test' => '&amp;',
        'title' => 'Ampersand',
    },
    {
        'template' => "\"",
        'test' => '&quot;',
        'title' => 'Double quote',
    },
    {
        'template' => "'",
        'test' => '&#39;',
        'title' => 'Single quote',
    },
];

foreach my $data (@$SET)
{
    my $test = sub{
        DTL::Fast::html_protect($data->{'template'});
        return $data->{'template'};
    };
    is( $test->(), $data->{'test'}, $data->{'title'});
    
}

done_testing();
