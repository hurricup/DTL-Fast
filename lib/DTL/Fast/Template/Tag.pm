package DTL::Fast::Template::Tag;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Parser';
use Carp qw(confess);

sub new
{
    my $proto = shift;
    my $parameter = shift // '';
    my %kwargs = @_;
    
    $parameter =~ s/(^\s+|\s+$)//gs;
    
    $kwargs{'parameter'} = $parameter;
    return $proto->SUPER::new(%kwargs);
}

sub parse_parameters{return shift;}

sub parse_chunks
{
    my $self = shift;
    $self->parse_parameters();
    return $self->SUPER::parse_chunks();
}

sub get_close_tag
{
    my $self = shift;
    confess sprintf(
        "ABSTRACT method get_close_tag, must be overriden in %s"
        , ref $self
    );
}

# Close tag processor
sub parse_tag_chunk
{
    my $self = shift;
    my $tag_name = shift;
    my $tag_param = shift;
    
    my $result = undef;

    if( $tag_name eq $self->get_close_tag )
    {
        $self->{'raw_chunks'} = []; # this stops parsing
    }
    else
    {
        $result = $self->SUPER::parse_tag_chunk($tag_name, $tag_param);
    }
    
    return $result;
}


1;
