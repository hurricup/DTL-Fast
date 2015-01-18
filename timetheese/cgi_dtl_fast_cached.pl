#!/usr/bin/perl -I../lib/

use DTL::Fast qw(get_template);
use DTL::Fast::Cache::File;

my $context = {
    'var1' => 'This',
    'var2' => 'is',
    'var3' => 'SPARTA',
    'var4' => 'GREEKS',
    'var5' => 'GO HOME!',
    'array1' => [qw( this is a text string as array )],
};

my $cache = DTL::Fast::Cache::File->new('./cache');

my $tpl = get_template(
    'root.txt',
#    'child5.txt',
    , 'dirs' => [ './tpl' ]
    , 'cache' => $cache
);
$tpl->render($context);