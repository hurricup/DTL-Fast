package DTL::Fast::Tag::Block;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  
use Carp;
use Data::Dumper;

our $VERSION = '1.00';

$DTL::Fast::TAG_HANDLERS{'block'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endblock';}

#@Override
sub parse_parameters
{
    my $self = shift;

    croak sprintf("Structure error. Top-level object for %s must be a DTL::Fast::Template, not %s (%s)"
        , __PACKAGE__
        , $self->{'_template'} // 'undef'
        , ref $self->{'_template'} || 'SCALAR' 
    ) if not $self->{'_template'}
        or not ref $self->{'_template'}
        or not $self->{'_template'}->isa('DTL::Fast::Template')
    ;
    
    if( not $self->{'_container_block'} )
    {
        croak "There is no container block defined for: ".Dumper($self);
    }
    
    $self->{'_container'} = $self->{'_container_block'};    # store it for future usage
    $self->{'_container'}->add_blocks({$self->{'parameter'} => $self});
    
    return $self;
}

#@Override
sub get_container_block{ return shift; }

# remove subblocks from tree
sub detach_subblocks
{
    my $self = shift;

    foreach my $subblock (keys %{$self->{'blocks'}})
    {
        $self->{'blocks'}->{$subblock}->detach();
    }
    
    $self->{'chunks'} = []; # clean up buffer

    return $self;
}

# remove block from tree
sub detach 
{
    my $self = shift;
    
    $self->detach_subblocks();
    $self->{'_container'}->remove_block($self->{'parameter'});
    delete $self->{'_container'}; # remove a reference to a parent for proper GC
    
    return $self;
}

# Attaching subblocks from donor block
sub attach_subblocks_from
{
    my $self = shift;
    my $donor = shift;
    
    @{$self}{'chunks','blocks'} = @{$donor}{'chunks','blocks'};

    # re-attaching container from donor to current
    my $subblocks = $self->{'blocks'};
    foreach my $subblock (keys %$subblocks)
    {
        if( $subblocks->{$subblock}->{'_container'} == $donor )
        {
            $subblocks->{$subblock}->{'_container'} = $self;
        }
    }
    
    $self->{'_container'}->add_blocks($self->{'blocks'});
    
    return $self;
}

1;