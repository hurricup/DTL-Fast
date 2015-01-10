#!/usr/bin/perl -I../lib/

use DTL::Fast qw(get_template);

my $context = {
	'var1' => 'This',
	'var2' => 'is',
	'var3' => 'SPARTA',
	'var4' => 'GREEKS',
	'var5' => 'GO HOME!',
	'array1' => [qw( this is a text string as array )],
};

my $tpl = get_template(
    'root.txt',
    [ './tpl' ]
);
$tpl->render($context);
