package DTL::Fast::Template::Filter::Dictsort;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'dictsort'} = __PACKAGE__;

use DTL::Fast::Template::Variable;
use DTL::Fast::Utils qw(has_method);
use Scalar::Util qw(looks_like_number);

#@Override
#@todo make pre-defined formats from Django
sub parse_parameters
{
    my $self = shift;
    die "No sorting key specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'parameter'}->[0] =~ s/(^["']|["']$)//gs;
    $self->{'key'} = [(split /\./, $self->{'parameter'}->[0])]; # do we need to backup strings here ?
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
    elsif( has_method($val1, 'compare'))
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