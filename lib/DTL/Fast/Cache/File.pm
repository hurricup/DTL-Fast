package DTL::Fast::Cache::File;
use strict; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Cache::Compressed';
use Carp;

#@Override
sub new
{
    my $proto = shift;
    my $dir = shift;
    my %kwargs = @_;

    croak "You should pass a cache directory to the constructor of ".__PACKAGE__
        if not $dir;
        
    $dir =~ s{[\/]+$}{}gs;
    
    if( 
        -d $dir
        and -w $dir
    )
    {
        $kwargs{'dir'} = $dir;
    }
    else
    {
        croak "$dir is not a directory or it's not writable for me";
    }
    
    return $proto->SUPER::new(%kwargs);
}

#@Override
sub read_compressed_data
{
    my $self = shift;
    my $key = shift;
    my $result; 
    
    my $filename = sprintf '%s/%s', $self->{'dir'}, $key;
    
    if( -e $filename )
    {
        if( open IF, '<', $filename )
        {
            binmode IF;
            $result = join '', <IF>;
            close IF;
        }
        else
        {
            croak "Error opening cache file $filename for reading: $!";
        }
    }
    
    return $result;    
}

#@Override
sub write_compressed_data
{
    my $self = shift;
    my $key = shift;
    my $data = shift;
    my $filename = sprintf '%s/%s', $self->{'dir'}, $key;
    
    if( open OF, '>', $filename )
    {
        binmode OF;
        print OF $data;
        close OF;
    }
    else
    {
        croak "Error opening cache file $filename for writing: $!";
    }
}


1;