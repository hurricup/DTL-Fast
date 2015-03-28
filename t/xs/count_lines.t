#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;use utf8;

use DTL::Fast;

my $SETS = [
  {
        'text' => <<'_EOM_'
This
is a
test
_EOM_
        , 'control' => 3
        , 'title' => 'Regular text'
  },
  {
        'text' => <<'_EOM_'
úüýþÿ
_EOM_
        , 'control' => 1
        , 'title' => 'Non utf8 string with UTF8 control chars'
  },
  {
        'text' => ""
        , 'control' => 0
        , 'title' => 'Empty line'
  },
  {
        'text' => undef
        , 'control' => 0
        , 'title' => 'Undef value'
  },
  {
        'text' => "\n\n\n\n\n\n\n\n\n\n"
        , 'control' => 10
        , 'title' => '10 newlines'
  },
];

foreach my $data (@$SETS)
{
    is( DTL::Fast::count_lines($data->{'text'}), $data->{'control'}, $data->{'title'});
}

done_testing();
