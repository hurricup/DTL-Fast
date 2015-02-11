package DTL::Fast::Tag::Block;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Tag';  

use Data::Dumper;

our $VERSION = '1.00';

$DTL::Fast::TAG_HANDLERS{'block'} = __PACKAGE__;

#@Override
sub get_close_tag{return 'endblock';}

#@Override
sub parse_parameters
{
    my( $self ) = @_;

    if( not $self->{'_container_block'} )
    {
        die "There is no container block defined for: ".Dumper($self);
    }
    
    $self->{'_container'} = $self->{'_container_block'};    # store it for future usage
    $self->{'_container'}->add_blocks({$self->{'parameter'} => $self});
    
    return $self;
}

#@Override
sub get_container_block{ return shift; }

sub replace_with
{
    my( $self, $donor ) = @_;
    
    my @current_subblocks_names = keys %{$self->{'blocks'}};

    # remove current subblocks
    if( scalar @current_subblocks_names )
    {
        $self->remove_blocks(\@current_subblocks_names);
    }
    
    # register subblocks from donor
    $self->add_blocks($donor->{'blocks'});

    # moving chunks from donor to me
    $self->{'chunks'} = $donor->{'chunks'}; 
    
    # re-attaching container from donor to current
    my $subblocks = $self->{'blocks'};
    foreach my $subblock (keys %$subblocks)
    {
        if( $subblocks->{$subblock}->{'_container'} == $donor )
        {
            $subblocks->{$subblock}->{'_container'} = $self;
        }
    }
    return $self;
}

1;