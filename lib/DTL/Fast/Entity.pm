package DTL::Fast::Entity;
use strict; use utf8; use warnings FATAL => 'all'; 
# prototype for template entity. Handling current line and current template references

use Scalar::Util qw(weaken);

sub new
{
    my( $proto, %kwargs ) = @_;

    $proto = ref $proto || $proto;
    
    $DTL::Fast::Template::CURRENT_TEMPLATE->{'modules'}->{$proto} = $proto->VERSION // DTL::Fast->VERSION;
    
    my $self = bless {%kwargs}, $proto;

    $self->remember_template;

    weaken $self->{'_template'};
    
    return $self;
}

sub remember_template
{
    my ($self) = @_;
    
    $self->{'_template'} = $DTL::Fast::Template::CURRENT_TEMPLATE;
    $self->{'_template_line'} = $DTL::Fast::Template::CURRENT_TEMPLATE_LINE;
    
    return $self;
}

sub get_parse_error
{
    my ($self, $message, @messages) = @_;
    
    return $self->get_error(
        $DTL::Fast::Template::CURRENT_TEMPLATE->{'file_path'}
        , $DTL::Fast::Template::CURRENT_TEMPLATE_LINE
        , '         Parsing error: '.($message // 'undef')
        , @messages
    );
}

sub get_render_error
{
    my ($self, $message, $context) = @_;
    
    my @params = (
        $self->{'_template'}->{'file_path'}
        , $self->{'_template_line'}
        , '       Rendering error: '.($message // 'undef')
    );
    
    if ( scalar @{$context->{'ns'}->[-1]->{'_dtl_include_path'}} > 1 ) # has inclusions, appending stack trace
    {
        push @params, sprintf( <<'_EOM_'
           Stack trace: %s
_EOM_
            , join( "\n                 ", @{$context->{'ns'}->[-1]->{'_dtl_include_path'}})
        );
    }
    
    return $self->get_error( @params );
}

sub get_error
{
    my ($self, $template, $line, $message, @messages ) = @_;
    
    my $result = sprintf <<'_EOM_'
%s
              Template: %s, syntax began at line %s
_EOM_
        , $message // 'undef'
        , $template // 'undef'
        , $line // 'undef'
    ;
    
    if ( scalar @messages )
    {
        $result .= join "\n", @messages;
    }
    
    $result .= "\n" if $result !~ /\n$/s;
    
    return $result;
}

1;
