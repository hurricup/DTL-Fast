#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my @LAST_WARNING;
local $SIG{__WARN__} = sub {@LAST_WARNING = @_;}; # here we get the warning

my $dirs = ['./t/tmpl'];
my( $template, $test_string, $context);

$template = new DTL::Fast::Template( 'Hello, {{ username }}!' );

$context = new DTL::Fast::Context({
    'username' => 'Ivan'
});

is( $template->render($context), 'Hello, Ivan!', 'Scalar substitution');

$template = new DTL::Fast::Template( 'Hello, {{ username }}! Your age is {{ user_age }}' );
$context->set('user_age' => sub{ return 27;});

is( $template->render($context), 'Hello, Ivan! Your age is 27', 'Code substitution');

package Foo;

sub new{ return bless {}, shift; };
sub method1{ return 'result1'; };
sub method2{ return 'result2'; };

package main;

$context->set(
    'array' => [
        'first'
        , {'second' => 'third'}
        , ['fourth']
        , sub{ return 'fifth';}
        , new Foo()
    ]
    , 'hash' => {
        'key1' => 'val1'
        , 'key2' => ['val2']
        , 'key3' => [sub{ return 42;}]
        , 'key4' => {
            'key5' => 'val5'
        }
        , 'key6' => new Foo()
    }
);

is( DTL::Fast::Template->new('checking {{ array.0 }}')->render($context), 'checking first', 'Traversed substitution: array->scalar');
is( DTL::Fast::Template->new('checking {{ array.1.second }}')->render($context), 'checking third', 'Traversed substitution: array->hash->scalar');
is( DTL::Fast::Template->new('checking {{ array.2.0 }}')->render($context), 'checking fourth', 'Traversed substitution: array->array->scalar');
is( DTL::Fast::Template->new('checking {{ array.3 }}')->render($context), 'checking fifth', 'Traversed substitution: array->code');
is( DTL::Fast::Template->new('checking {{ array.4.method1 }}')->render($context), 'checking result1', 'Traversed substitution: array->object->method');

is( DTL::Fast::Template->new('checking {{ hash.key1 }}')->render($context), 'checking val1', 'Traversed substitution: hash->scalar');
is( DTL::Fast::Template->new('checking {{ hash.key2.0 }}')->render($context), 'checking val2', 'Traversed substitution: hash->array->scalar');
is( DTL::Fast::Template->new('checking {{ hash.key3.0 }}')->render($context), 'checking 42', 'Traversed substitution: hash->array->code');
is( DTL::Fast::Template->new('checking {{ hash.key4.key5 }}')->render($context), 'checking val5', 'Traversed substitution: hash->hash->scalar');
is( DTL::Fast::Template->new('checking {{ hash.key6.method2 }}')->render($context), 'checking result2', 'Traversed substitution: hash->object->method');

is( DTL::Fast::Template->new('checking {{ "static variable" }}')->render($context), 'checking static variable', 'Static variable interpolation');
is( DTL::Fast::Template->new('checking {{ "static variable"|unknown_filter_example }}')->render($context), 'checking static variable', 'Static variable interpolation with unknown filter warning');
is( DTL::Fast::Template->new('checking {{ "static variable" }}{% unknown_tag_example vars %}')->render($context), 'checking static variable', 'Static variable interpolation with unknown tag warning');

is( DTL::Fast::Template->new('{{array.0}}')->render($context), 'first', 'Interpolation without spaces');
is( DTL::Fast::Template->new('{{ array.0 }}')->render($context), 'first', 'Interpolation with spaces');
is( DTL::Fast::Template->new('{{array.0|upper}}')->render($context), 'FIRST', 'Filter without spaces');
is( DTL::Fast::Template->new('{{ array.0 | upper}}')->render($context), 'FIRST', 'Filter with spaces');
is( DTL::Fast::Template->new('{{ missvar | default: "blabla"}}')->render($context), 'blabla', 'Default filter with spaces');

local $SIG{__WARN__} = undef;
$template = get_template('error_tag.txt', 'dirs' => $dirs)->render();
ok(
    (
        $LAST_WARNING[0] =~ /error_tag.txt/si
        and $LAST_WARNING[0] =~ /duplicate/si
    )
    , 'Template name on missing tag'
);

$template = get_template('error_undisclosed.txt', 'dirs' => $dirs)->render();
ok(
    (
        $LAST_WARNING[0] =~ /error_undisclosed.txt/si
        and $LAST_WARNING[0] =~ /endif/si
        and $LAST_WARNING[0] =~ /with/si
    )
    , 'Template name on undisclosed block tag'
);

done_testing();
