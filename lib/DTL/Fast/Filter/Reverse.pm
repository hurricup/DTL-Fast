package DTL::Fast::Filter::Reverse;
use strict; use utf8; use warnings FATAL => 'all';
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'reverse'} = __PACKAGE__;

#@Overrde
sub filter
{
    my $self = shift;
    my $filter_manager = shift;
    my $value = shift;
    my $context = shift;
    my $result;

    my $value_type = ref $value;

    if( $value_type eq 'ARRAY' )
    {
        $result = [reverse @$value];
    }
    elsif( $value_type eq 'HASH' )
    {
        $result = {reverse %$value};
    }
    elsif( UNIVERSAL::can($value_type, 'reverse') )
    {
        $result = $value->reverse($context);
    }
    else
    {
        die "Don't know how to reverse $value ($value_type)";
    }

    return $result;
}

1;
