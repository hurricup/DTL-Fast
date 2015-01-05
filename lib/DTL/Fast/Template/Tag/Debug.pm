package DTL::Fast::Template::Tag::Debug;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';  
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'debug'} = __PACKAGE__;

use Data::Dumper;

#@Override
sub render
{
    my $self = shift;
    my $context = shift;

    my $result = Dumper($context);
 
    return $result;
}

1;