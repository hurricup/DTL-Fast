#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Dotiac::DTL qw/Template Context/;

#
# In order to test Dotiac without caching, you need to modify Dotiac::DTL module
# and make %cache variable our instead of my
#
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

my $tpl = get_template(
    'root.txt',
    [ @Dotiac::DTL::TEMPLATE_DIRS ]
);
sub dtl_fast
{
   $tpl->render($context);
}

sub dtl_fast_nocache
{
    %DTL::Fast::TEMPLATES_CACHE = ();
    %DTL::Fast::OBJECTS_CACHE = ();
    my $tpl = get_template(
        'root.txt',
        [ @Dotiac::DTL::TEMPLATE_DIRS ]
    );
   $tpl->render($context);
}

my $t=Dotiac::DTL::Template('root.txt');
sub dtl_dotiac
{
    $t->string($context);
}

sub dtl_dotiac_nocache
{
    %Dotiac::DTL::cache = ();
    my $t=Dotiac::DTL::Template('root.txt', -1);
    $t->string($context);
}

sub dtl_fast_cgi
{
    system('perl cgi_dtl_fast.pl');
}

sub dtl_dotiac_cgi
{
    system('perl cgi_dtl_dotiac.pl');
}

print "IMPORTANT: In order to get proper results, you must alter Dotiac::DTL module and change my %cache definition to our %cache\n";

print "Saving results into files...\n";

open OF, '>', 'dtl_fast.txt';
print OF dtl_fast();
close OF;

open OF, '>', 'dtl_dotiac.txt';
print OF dtl_dotiac();
close OF;

print "Testing FCGI mode...\n";

timethese( 3000, {
    'Fast render   ' => \&dtl_fast,
    'Fast reparse  ' => \&dtl_fast_nocache,
    'Dotiac render ' => \&dtl_dotiac,
    'Dotiac reparse' => \&dtl_dotiac_nocache,
});

print "Testing CGI mode...\n";

timethese( 500, {
    'Fast render   ' => \&dtl_fast_cgi,
    'Dotiac render ' => \&dtl_dotiac_cgi,
});
