package DTL::Fast::Template::Tag::Ifnotequal;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Ifequal';

$DTL::Fast::Template::TAG_HANDLERS{'ifnotequal'} = __PACKAGE__;

use DTL::Fast::Template::Tag::If::Condition;
use DTL::Fast::Template::Expression::Operator::Binary::Ne;

#@Override
sub get_close_tag{ return 'endifnotequal';}

#@Override
sub add_main_condition
{
    my $self = shift;
    my $sources = shift;
    return $self->add_condition(DTL::Fast::Template::Expression::Operator::Binary::Ne->new(@{$sources}[0,1]));
}

1;