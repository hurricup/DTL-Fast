package DTL::Fast::Cache::Memcached;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache::Runtime';
use Carp;

our %SUPPORTS = qw(
    Cache::Memcached        1
    Cache::Memcached::Fast  1
);

#@Override
sub new
{
    my $proto = shift;
    my $memcached = shift;
    
    if( not exists $SUPPORTS{ref $memcached} )
    {
        croak sprintf(
            "You may construct %s object using one of the following modules:\n\t%s\n"
            , $proto
            , join( "\n\t", keys %SUPPORTS )
        );
    }
    
    return $proto->SUPER::new( 'mc' => $memcached );
    
}

#@Override
sub read_data{ return shift->{'mc'}->get(shift); }

#@Override
sub write_data{ shift->{'mc'}->set(shift, shift); }

1;