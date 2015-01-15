#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);
use DTL::Fast qw(get_template);
use Storable qw(freeze thaw);
use Compress::Zlib;

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

my $serialized;

sub dtl_serialize
{
    $serialized = freeze($tpl);
}

my $compressed;

sub dtl_compress
{
    $compressed = Compress::Zlib::memGzip($serialized);
}

sub dtl_decompress
{
    Compress::Zlib::memGunzip($compressed);
}

sub dtl_deserialize
{
    thaw($serialized);
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

timethese( 20000, {
    '1 Parse      ' => \&dtl_fast_parse,
    '2 Render     ' => \&dtl_fast_render,
    '3 Serialize  ' => \&dtl_serialize,
    '4 Compress   ' => \&dtl_compress,
    '5 Decompress ' => \&dtl_decompress,
    '6 Deserialize' => \&dtl_deserialize,
});
