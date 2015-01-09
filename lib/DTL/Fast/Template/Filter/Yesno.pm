package DTL::Fast::Template::Filter::Yesno;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'yesno'} = __PACKAGE__;

#@Override
sub parse_parameters
{
    my $self = shift;
    push @{$self->{'parameter'}}, '"yes,no,maybe"'
        if not scalar @{$self->{'parameter'}};
    $self->{'mappings'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
    return $self;
}


#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;  # context

    my @mappings = split /\s*,\s*/s, $self->{'mappings'}->render($context);
    
    return $value ?
        $mappings[0]
        : defined $value ?
            $mappings[1]
            : $mappings[2];
}

1;