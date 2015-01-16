#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;use utf8;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
});

my @DATA = (
    {
        'var' =>  \1,
        , 'positive' => 'true'
        , 'negative' => 'false'
        , 'title' => 'True value'
    }
    , {
        'var' =>  \0,
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'False value'
    }
    , {
        'var' =>  1,
        , 'positive' => 'true'
        , 'negative' => 'false'
        , 'title' => 'Non-zero value'
    }
    , {
        'var' =>  0,
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'Zero'
    }
    , {
        'var' =>  undef,
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'Undefinded value'
    }
    , {
        'var' =>  'string',
        , 'positive' => 'true'
        , 'negative' => 'false'
        , 'title' => 'Non-empty string'
    }
    , {
        'var' =>  '',
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'Empty string'
    }
    , {
        'var' =>  [],
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'Empty arrray'
    }
    , {
        'var' =>  {},
        , 'positive' => 'false'
        , 'negative' => 'true'
        , 'title' => 'Empty hash'
    }
    , {
        'var' =>  [1],
        , 'positive' => 'true'
        , 'negative' => 'false'
        , 'title' => 'Non-empty array'
    }
    , {
        'var' =>  {'a' => 'b'},
        , 'positive' => 'true'
        , 'negative' => 'false'
        , 'title' => 'Non-empty hash'
    }
);

my $tpl_true = DTL::Fast::Template->new('{% if var %}true{% else %}false{% endif %}');
my $tpl_false = DTL::Fast::Template->new('{% if not var %}true{% else %}false{% endif %}');

foreach my $data (@DATA)
{
    $context->set('var' => $data->{'var'});
    is( $tpl_true->render($context), $data->{'positive'}, "Positive test, ".$data->{'title'});
    is( $tpl_false->render($context), $data->{'negative'}, "Negative test, ".$data->{'title'});
}

done_testing();
