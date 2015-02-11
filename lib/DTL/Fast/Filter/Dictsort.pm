package DTL::Fast::Filter::Dictsort;
use strict; use utf8; use warnings FATAL => 'all';
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'dictsort'} = __PACKAGE__;

use Scalar::Util qw(looks_like_number);
use locale;

#@Override
sub parse_parameters
{
    my $self = shift;
    die "No sorting key specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'key'} = [split /\./, $self->{'parameter'}->[0]->render()]; # do we need to backup strings here ?
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;

    die "dictsort works only with array of hashes"
        if ref $value ne 'ARRAY';

    return [(
        sort{
            $self->sort_function(
                $context->traverse($a, $self->{'key'})
                , $context->traverse($b, $self->{'key'})
            )
        } @$value
    )];
}

sub sort_function
{
    my $self = shift;
    my $val1 = shift;
    my $val2 = shift;
    my $result;

    if( looks_like_number($val1) and looks_like_number($val2))
    {
        $result = ($val1 <=> $val2);
    }
    elsif( UNIVERSAL::can($val1, 'compare'))
    {
        $result = $val1->compare($val2);
    }
    else
    {
        $result = ($val1 cmp $val2);
    }

    return $result;
}

1;
