package DTL::Fast::Template::Tag::Ssi;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag::Simple';
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'ssi'} = __PACKAGE__;

use DTL::Fast::Template::Expression;

#@Override
sub parse_parameters
{
    my $self = shift;
    if( $self->{'parameter'} =~ /^\s*(.+?)(?:\s*(parsed))?\s*$/ )
    {
        @{$self}{'template', 'parsed'} = (
            DTL::Fast::Template::Expression->new($1)
            , $2 
        );
    }
    else
    {
        confess "Can't parse parameter: $self->{'parameter'}";
    }
    
    return $self;
}

#@Override
# @todo: recursion protection
sub render
{
    my $self = shift;
    my $context = shift;
    my $result;
    
    my $ssi_dirs = $context->get('_dtl_ssi_dirs');
    if( 
        defined $ssi_dirs
        and ref $ssi_dirs eq 'ARRAY'
        and scalar @$ssi_dirs
    )
    {
        if( $self->{'parsed'} )
        {
            $result = DTL::Fast::get_template(
                $self->{'template'}->render($context)
                , $ssi_dirs
            )->render($context);
        }
        else
        {
            my $ssi_filename;
            ($result, $ssi_filename) = DTL::Fast::_read_file(
                $self->{'template'}->render($context)
                , $ssi_dirs
            );
        }
    }
    else
    {
        confess 'In order to use ssi tag, you must provide ssi_dirs argument to constructor';
    }
    
    return $result;
}

1;