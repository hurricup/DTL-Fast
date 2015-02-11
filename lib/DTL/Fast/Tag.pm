package DTL::Fast::Tag;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Parser';

use DTL::Fast::Template;

sub new
{
    my( $proto, $parameter, %kwargs ) = @_;
    $parameter //= '';
    
    $parameter =~ s/(^\s+|\s+$)//gs;

    $DTL::Fast::Template::CURRENT_TEMPLATE->{'modules'}->{$proto} //= $proto->VERSION // DTL::Fast->VERSION;
    
    $kwargs{'parameter'} = $parameter;
    return $proto->SUPER::new(%kwargs);
}

sub parse_parameters{return shift;}

sub parse_chunks
{
    my( $self ) = @_;
    $self->parse_parameters();
    return $self->SUPER::parse_chunks();
}

sub get_close_tag
{
    my( $self ) = @_;
    die sprintf(
        "ABSTRACT method get_close_tag, must be overriden in %s"
        , ref $self
    );
}

# Close tag processor
sub parse_tag_chunk
{
    my( $self, $tag_name, $tag_param ) = @_;
    
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
