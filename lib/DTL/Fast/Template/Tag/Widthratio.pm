package DTL::Fast::Template::Tag::Widthratio;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'widthratio'} = __PACKAGE__;

use DTL::Fast::Utils;

#@Override
sub parse_parameters
{
    my $self = shift;

    if( $self->{'parameter'} =~ /^\s*(.+?)(?:\s+as\s+([^\s]+))?\s*$/s )
    {
        $self->{'target_name'} = $2;
        
        $self->{'sources'} = $self->parse_sources($1);
        
        die sprintf(
            "Three arguments should be passed to widthratio: %s %s"
            , $self->{'parameter'} 
            , scalar @{$self->{'sources'}}
        ) if scalar @{$self->{'sources'}} != 3;
    }
    else
    {
        die "Unable to parse ratio parameters $self->{'parameter'}";
    }
    
    return $self;
}

#@Override
sub render
{
    my $self = shift;
    my $context = shift;

    my $sources = $self->{'sources'};
    my $result = int(
        $sources->[0]->render($context) 
        / $sources->[1]->render($context) 
        * $sources->[2]->render($context)
    );
    
    if( $self->{'target_name'} )
    {
        $context->set($self->{'target_name'} => $result);
        $result = '';
    }
    
    return $result;
}

1;