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
        , 'positive' => '1'
        , 'negative' => '0'
        , 'title' => 'True value'
    }
    , {
        'var' =>  \0,
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'False value'
    }
    , {
        'var' =>  1,
        , 'positive' => '1'
        , 'negative' => '0'
        , 'title' => 'Non-zero value'
    }
    , {
        'var' =>  0,
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'Zero'
    }
    , {
        'var' =>  undef,
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'Undefinded value'
    }
    , {
        'var' =>  'string',
        , 'positive' => '1'
        , 'negative' => '0'
        , 'title' => 'Non-empty string'
    }
    , {
        'var' =>  '',
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'Empty string'
    }
    , {
        'var' =>  [],
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'Empty arrray'
    }
    , {
        'var' =>  {},
        , 'positive' => '0'
        , 'negative' => '1'
        , 'title' => 'Empty hash'
    }
    , {
        'var' =>  [1],
        , 'positive' => '1'
        , 'negative' => '0'
        , 'title' => 'Non-empty array'
    }
    , {
        'var' =>  {'a' => 'b'},
        , 'positive' => '1'
        , 'negative' => '0'
        , 'title' => 'Non-empty hash'
    }
);

my %TPL = (
    '1' => [  # one parameter test
        {
            'template' => '{% if var %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my $var = shift;
                return $var->{'positive'} ? 1: 0;
            }
            , 'title' => sub
            {
                my $var = shift;
                return sprintf '%s', lc($var->{'title'});
            }
        },
        {
            'template' => '{% if not var %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my $var = shift;
                return $var->{'negative'} ? 1: 0;
            }
            , 'title' => sub
            {
                my $var = shift;
                return sprintf 'not %s', lc($var->{'title'});
            }
        },
    ],
    2 => [
        {
            'template' => '{% if varx and vary %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my ($varx, $vary) = @_;
                return $varx->{'positive'} && $vary->{'positive'} ? 1: 0;
            }
            , 'title' => sub
            {
                my ($varx, $vary) = @_;
                return sprintf '%s and %s', lc($varx->{'title'}), lc($vary->{'title'});
            }
        },
        {
            'template' => '{% if varx or vary %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my ($varx, $vary) = @_;
                return $varx->{'positive'} || $vary->{'positive'} ? 1: 0;
            }
            , 'title' => sub
            {
                my ($varx, $vary) = @_;
                return sprintf '%s or %s', lc($varx->{'title'}), lc($vary->{'title'});
            }
        },
        {
            'template' => '{% if varx and not vary %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my ($varx, $vary) = @_;
                return $varx->{'positive'} && !$vary->{'positive'} ? 1: 0;
            }
            , 'title' => sub
            {
                my ($varx, $vary) = @_;
                return sprintf '%s and not %s', lc($varx->{'title'}), lc($vary->{'title'});
            }
        },
        {
            'template' => '{% if not varx or vary %}1{% else %}0{% endif %}'
            , 'validate' => sub{
                my ($varx, $vary) = @_;
                return !$varx->{'positive'} || $vary->{'positive'} ? 1: 0;
            }
            , 'title' => sub
            {
                my ($varx, $vary) = @_;
                return sprintf 'not %s or %s', lc($varx->{'title'}), lc($vary->{'title'});
            }
        },
    ]
);

subtest 'One parameter tests' => sub{
    foreach my $tpl (@{$TPL{1}})
    {
        my $template = DTL::Fast::Template->new($tpl->{'template'});
        foreach my $data (@DATA)
        {
            $context->set('var' => $data->{'var'});
            is( $template->render($context), $tpl->{'validate'}->($data), $tpl->{'title'}->($data) );
        }
    }
};

subtest 'Two parameters tests' => sub{
    foreach my $tpl (@{$TPL{2}})
    {
        my $template = DTL::Fast::Template->new($tpl->{'template'});
        foreach my $datax (@DATA)
        {
            foreach my $datay (@DATA)
            {
                $context->set(
                    'varx' => $datax->{'var'},
                    'vary' => $datay->{'var'},
                );
                is( $template->render($context), $tpl->{'validate'}->($datax, $datay), $tpl->{'title'}->($datax, $datay) );
            }
        }
    }
};

done_testing();
