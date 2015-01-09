package DTL::Fast::Template::Filter::Truncatewords;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'truncatewords'} = __PACKAGE__;

use DTL::Fast::Template::Variable;

#@Override
sub parse_parameters
{
    my $self = shift;
    die "No max words number specified"
        if not scalar @{$self->{'parameter'}};
    $self->{'maxlen'} = DTL::Fast::Template::Variable->new($self->{'parameter'}->[0]);
    return $self;
}

#@Override
sub filter
{
    my $self = shift;  # self
    shift;  # filter_manager
    my $value = shift;
    my $context = shift;
    
    my $maxlen = $self->{'maxlen'}->render($context);
    my @value = split /(\s+)/s, $value;
    my $words = 0;
    my @newvalue = ();
    
    foreach my $value (@value)
    {
        if( $words == $maxlen )
        {
            last;
        }
        else
        {
            push @newvalue, $value;
            if( $value !~ /^\s+$/s )
            {
                $words++;
            }
        }
    }

    if( scalar @newvalue < scalar @value )
    {
        push @newvalue, '...';
    }
    
    return join '', @newvalue;
}


1;