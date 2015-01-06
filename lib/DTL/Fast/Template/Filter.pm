package DTL::Fast::Template::Filter;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

use DTL::Fast::Template;

sub new
{
    my $proto = shift;
    my $parameter = shift;
    my %kwargs = @_;
    $kwargs{'parameter'} = $parameter;
    my $self = bless {%kwargs}, $proto;
    
    return $self->parse_parameters();
}

sub parse_parameters{return shift;}

sub filter
{
    confess "This is abstract method and it must be overrided";
}

1;
