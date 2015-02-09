package DTL::Fast::Filter::Slice;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Filter';

$DTL::Fast::FILTER_HANDLERS{'slice'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    die "No slicing settings specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'settings'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $settings = $self->{'settings'}->render($context);
    
    if( ref $value eq 'ARRAY' )
    {
        $value = $self->slice_array($value, $settings);
    }
    elsif( ref $value eq 'HASH' )
    {
        $value = $self->slice_hash($value, $settings);
    }
    else
    {
        die sprintf(
            "Can slice only HASH or ARRAY, not %s (%s)"
            , $value // 'undef'
            , ref $value || 'SCALAR'
        );
    }
    
    return $value;
}

sub slice_array
{
    my $self = shift;
    my $array = shift;
    my $settings = shift;
    
    my $start = 0;
    my $end = $#$array;
    
    if( $settings =~ /^([-\d]+)?\:([-\d]+)?$/ ) # python's format
    {
        $start = $self->python_index_map($1, $end) // $start;
        $end = defined $2 ? 
            $self->python_index_map($2, $end) - 1
            : $end;
    }
    elsif( $settings =~ /^([-\d]+)?\s*\.\.\s*([-\d]+)?$/ ) # perl's format
    {
        $start = $1 // $start;
        $end = $2 // $end;
    }
    else
    {
        die "Array slicing option MUST be specified in Python's or Perl's format: [from_index]:[to_index+1] or [from_index]..[to_index]";
    }

    $start = $#$array if $start > $#$array;
    $end = $#$array if $end > $#$array;
    
    if ( $start > $end ) {
        my $var = $start;
        $start = $end;
        $end = $var;
    }
    
    return [@{$array}[$start .. $end]];
}

sub python_index_map
{
    my( $self, $pyvalue, $lastindex ) =  @_;
    
    return $pyvalue if not defined $pyvalue;

    return $pyvalue < 0 ?
        $lastindex + $pyvalue + 1
        : $pyvalue;
}

sub slice_hash
{
    my $self = shift;
    my $hash = shift;
    my $settings = shift;
    
    return [@{$hash}{(split /\s*,\s*/, $settings)}];
}

1;
