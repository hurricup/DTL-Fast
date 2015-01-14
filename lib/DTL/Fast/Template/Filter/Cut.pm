package DTL::Fast::Template::Filter::Cut;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'cut'} = __PACKAGE__;

use DTL::Fast::Template::Variable;


#@Override
sub parse_parameters
{
    my $self = shift;
    die "No substitute specified for removing"
        if not scalar @{$self->{'parameter'}};
    $self->{'remove'} = $self->{'parameter'}->[0];
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $remove = $self->{'remove'}->render($context);
    $value =~ s/\Q$remove\E//gs;
    
    return $value;
}

1;