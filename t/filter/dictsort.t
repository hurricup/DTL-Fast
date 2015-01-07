#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my( $template, $test_string, $context);

$context = new DTL::Fast::Context({
    'books' => 
    [
        {'title' => 'Alice', 'author' => {'name' => 'Lewis', 'age' => 33}},
        {'title' => '1984', 'author' => {'name' => 'George', 'age' => 45}},
        {'title' => 'Timequake', 'author' => {'name' => 'Kurt', 'age' => 75}},
    ]
});

my $SET = [
    {
        'template' => <<'_EOT_',
{% for book in books|dictsort:"title" %}{{ book.title }} ({{ book.author.name }})
{% endfor %}
_EOT_
        'test' => <<'_EOT_',
1984 (George)
Alice (Lewis)
Timequake (Kurt)

_EOT_
        'title' => 'Simple dictionary sorting',
    },
    {
        'template' => <<'_EOT_',
{% for book in books|dictsort:"author.age" %}{{ book.title }} ({{ book.author.name }})
{% endfor %}
_EOT_
        'test' => <<'_EOT_',
Alice (Lewis)
1984 (George)
Timequake (Kurt)

_EOT_
        'title' => 'Complex dictionary sorting',
    },
];

foreach my $data (@$SET)
{
    is( DTL::Fast::Template->new($data->{'template'}, [])->render($context), $data->{'test'}, $data->{'title'});
    
}

done_testing();
