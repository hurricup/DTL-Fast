package DTL::Fast::Tag::Debug;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag::Simple';  

$DTL::Fast::TAG_HANDLERS{'debug'} = __PACKAGE__;

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