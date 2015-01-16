package DTL::Fast::Cache;
use strict; use warnings FATAL => 'all'; 
use Carp;
# This is a prototype class for caching templates

sub new
{
    my $proto = shift;
    my %kwargs = @_;
    
    @kwargs{'hits','misses'} = (0,0);
    
    return bless{ %kwargs }, $proto;
}

sub get
{
    my $self = shift;
    
    my $template = $self->validate_template(
        $self->read_data(
            shift
        )
    );
    
    defined $template ?
        $self->{'hits'}++
        : $self->{'misses'}++;
    
    return $template;
}

sub put
{
    my $self = shift;
    my $key = shift;
    my $template = shift;
    
    if( defined $template )
    {
        delete $template->{'cache'};
        $self->write_data($key, $template, @_);
    }
}

sub read_data
{
    my $self = shift;
    my $key = shift;
    croak "read_data method was not defined in ".(ref $self);
}

sub clear
{
    my $self = shift;
    croak "clear method was not defined in ".(ref $self);
}

sub write_data
{
    my $self = shift;
    my $key = shift;
    my $value = shift;
    
    croak "write_data method was not defined in ".(ref $self);
}

sub validate_template
{
    my $self = shift;
    my $template = shift // return;
    
    # here we check if template is still valid
    
    # check perl version
    # check files modification
    # check modules version
    
    return $template;
}

1;