#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Dotiac::DTL qw/Template Context/;

@Dotiac::DTL::TEMPLATE_DIRS = ('./tpl');
$Dotiac::DTL::CURRENTDIR = './tpl';

my $context = {
	'var1' => 'This',
	'var2' => 'is',
	'var3' => 'SPARTA',
	'var4' => 'GREEKS',
	'var5' => 'GO HOME!',
	'array1' => [qw( this is a text string as array )],
};

sub dtl_fast
{
    my $tpl = get_template(
        'root.txt',
        [ @Dotiac::DTL::TEMPLATE_DIRS ]
    );
   $tpl->render($context);
}

sub dtl_dotiac
{
    my $t=Dotiac::DTL::Template('root.txt');
    $t->string($context);
}

open OF, '>', 'dtl_fast.txt';
print OF dtl_fast();
close OF;

open OF, '>', 'dtl_dotiac.txt';
print OF dtl_dotiac();
close OF;

timethese( 10000, {
	'DTL::Fast' => \&dtl_fast,
	'Dotiac' => \&dtl_dotiac,
});
