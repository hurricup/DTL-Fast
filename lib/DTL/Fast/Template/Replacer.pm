package DTL::Fast::Template::Replacer;
use strict; use utf8; use warnings FATAL => 'all'; 
use Carp qw(confess);

use DTL::Fast::Template::Replacer::Replacement;
use DTL::Fast::Template::Variable;

sub new
{
    my $proto = shift;
    my %kwargs = @_;

    my $self = bless {%kwargs}, $proto;

    return $self;
}

sub backup_strings
{
    my $self = shift;
    my $expression = shift;

    $self->clean_replacement($expression)
        if not $self->{'replacement'}
            or not $self->{'replacement'}->isa('DTL::Fast::Template::Replacer::Replacement');
    
    $expression =~ s/(?<!\\)(".+?(?<!\\)")/$self->backup_variable($1)/ge;
    
    return $expression;
}

sub backup_variable
{
    my $self = shift;
    my $string = shift;
 
    return $self->{'replacement'}->add_replacement(
        DTL::Fast::Template::Variable->new($string)
    );
}

sub backup_expression
{
    my $self = shift;
    my $expression = shift;

    return $self->{'replacement'}->add_replacement(
        DTL::Fast::Template::Expression->new(
            $expression
            , 'replacement' => $self->{'replacement'}
            , 'level' => 0 
        )
    );
}

sub get_backup
{
    return shift->{'replacement'}->get_replacement(shift);
}


sub get_backup_or_variable
{
    my $self = shift;
    my $token = shift;

    my $result = $self->get_backup($token)
        // DTL::Fast::Template::Variable->new($token)
        ;
        
    return $result;
}

sub get_backup_or_expression
{
    my $self = shift;
    my $token = shift;
    my $current_level = shift // -1;

    my $result = $self->get_backup($token)
        // DTL::Fast::Template::Expression->new(
            $token
            , 'replacement' => $self->{'replacement'}
            , 'level' => $current_level+1 
        );
        
    return $result;
}

sub clean_replacement
{
    return shift->set_replacement(
        DTL::Fast::Template::Replacer::Replacement->new(shift)
    );
}

sub set_replacement
{
    my $self = shift;
    $self->{'replacement'} = shift;
    return $self;
}

1;