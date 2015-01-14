#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use DTL::Fast::Template::Filter::Ru::Pluralize;
use Data::Dumper;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
    'var1' => 1,
    'var2' => 2,
    'var7' => 7,
    'var12' => 11,
    'var21' => 21,
    'var100' => 100,
    'var2_5' => 2.5,
});

my $SET = [
    {
        'template' => 'товар{{ var1|pluralize }}',
        'test' => 'товар',
        'title' => 'Default single',
    },
    {
        'template' => 'товар{{ var2|pluralize }}',
        'test' => 'товар',
        'title' => 'Default multi',
    },
    {
        'template' => 'товар{{ var2|pluralize:",ов" }}',
        'test' => 'товаров',
        'title' => 'Override not complete values',
    },
    {
        'template' => 'товар{{ var1|pluralize:",а,ов" }} товар{{ var2|pluralize:",а,ов" }} товар{{ var7|pluralize:",а,ов" }} товар{{ var12|pluralize:",а,ов" }} товар{{ var21|pluralize:",а,ов" }} товар{{ var100|pluralize:",а,ов" }}',
        'test' => 'товар товара товаров товаров товар товаров',
        'title' => 'Override multi',
    },
    {
        'template' => 'товар{{ var7|pluralize:",ов" }}',
        'test' => 'товаров',
        'title' => 'Override not complete values 2',
    },
    {
        'template' => 'товар{{ var2_5|pluralize:",а,ов" }}',
        'test' => 'товара',
        'title' => 'Float value',
    },
];

foreach my $data (@$SET)
{
    is( DTL::Fast::Template->new($data->{'template'}, [])->render($context), $data->{'test'}, $data->{'title'});
    
}

done_testing();
