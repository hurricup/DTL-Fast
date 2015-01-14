#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);

#
# In order to test Dotiac without caching, you need to modify Dotiac::DTL module
# and make %cache variable our instead of my
#
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
    'dirs' => [ './tpl' ]
);
sub dtl_fast_render
{
   $tpl->render($context);
}

sub dtl_fast_parse
{
    %DTL::Fast::TEMPLATES_CACHE = ();
    %DTL::Fast::OBJECTS_CACHE = ();
    my $tpl = get_template(
        'root.txt',
        'dirs' => [ './tpl' ]
    );
}

print "This is a test for optimisation iterations\n";

timethese( 3000, {
    'Render' => \&dtl_fast_render,
    'Parse ' => \&dtl_fast_parse,
});
