package DTL::Fast;
use strict; use warnings FATAL => 'all'; 
use parent 'Exporter';
use Carp qw(confess);

use 5.018002;
our $VERSION = '0.01';

=head1 NAME

DTL::Fast - Perl implementation of Django templating language.

=head1 VERSION

Version 0.01

=cut

use Cwd;
use DTL::Fast::Template;

our @EXPORT_OK;

# @todo Texts should be tossed by references
# @todo Protection from cycled ierarchy
# @todo These should be done via Cache class which can work with last modified date
our %TEMPLATES_CACHE = ();
our $TEMPLATES_CACHE_HITS = 0;
our %OBJECTS_CACHE = ();
our $OBJECTS_CACHE_HITS = 0;

push @EXPORT_OK, 'get_template';
sub get_template
{
    my $template_name = shift;
    my $dirs = shift // [getcwd()];
    my %kwargs = @_;
    
    confess "Template name was not specified" 
        if not $template_name;
    
    confess "Second parameter must be a dirs array reference" 
        if(
            not ref $dirs
            or ref $dirs ne 'ARRAY'
            or not scalar @$dirs
        );

    my $cache_key = sprintf '%s:%s:%s:%s'
        , __PACKAGE__
        , $template_name
        , join( ',', @$dirs )
        , join( ',', @{$kwargs{'ssi_dirs'}//[]})
        ;

    my $template;
    
    if( exists $OBJECTS_CACHE{$cache_key} ) # already has object with this source parameters
    {
        $template = $OBJECTS_CACHE{$cache_key};
        $OBJECTS_CACHE_HITS++;
    }    
    else
    {
        $template = _read_template($template_name, $dirs);
        $template =~ s/\{\% (?:block|endblock|extends) .*?\%\}//gs;
        
        my @arguments = ($template, $dirs);
        push @arguments, 'ssi_dirs', $kwargs{'ssi_dirs'}
            if $kwargs{'ssi_dirs'};
        
        $template = DTL::Fast::Template->new(@arguments)
            if defined $template;
        $OBJECTS_CACHE{$cache_key} = $template;
    }
    
    return $template;
}

sub _apply_inheritance
{
    my $template = shift;
    my $dirs = shift;
    
    if( $template =~ s/\s*\{\% extends\s*"(.+?)" \%\}//s ) # template has inheritance
    {
        my $parent_template = _read_template($1, $dirs);
        
        my %named_blocks = (
            $template =~ /\{\% block ([^\s]+) \%\}(.+?)\{\% endblock \%\}/gs
        );
        
        my $block_names = join '|', keys(%named_blocks);
        $parent_template =~ s/\{\% block ($block_names) \%\}.+?\{\% endblock \%\}/\{\% block $1 \%\}$named_blocks{$1}\{\% endblock \%\}/gsi;
        $template = $parent_template;
    }
    
    return $template;
}

sub _read_template
{
    my $template_name = shift;
    my $dirs = shift;

    my $template = undef;

    my $cache_key = sprintf '%s:%s:%s'
        , __PACKAGE__
        , $template_name
        , join ',', @$dirs;

    if( exists $TEMPLATES_CACHE{$cache_key} )   # already read template with this parameters
    {
        $template = $TEMPLATES_CACHE{$cache_key};
        $TEMPLATES_CACHE_HITS++;
    }
    else
    {
        $template = _read_file($template_name, $dirs);
        $template = _apply_inheritance($template, $dirs)
            if defined $template;
            
        $TEMPLATES_CACHE{$cache_key} = $template;
    }

    confess sprintf( <<'_EOT_', $template_name, join("\n", @$dirs)) if not defined $template;
Unable to find template %s in directories: 
%s
_EOT_
    
    return $template;
}

sub _read_file
{
    my $template_name = shift;
    my $dirs = shift;
    my $template;

    foreach my $dir (@$dirs)
    {
        $dir =~ s/[\/\\]+$//gsi;
        my $template_path = sprintf '%s/%s', $dir, $template_name;
        if( 
            -e $template_path
            and -f $template_path
            and -r $template_path
        )
        {
            if( open IF, '<', $template_path )
            {
                $template = join '', <IF>;
                close IF;
                last;
            }
            else
            {
                confess sprintf(
                    'Error opening file %s, %s'
                    , $template_path
                    , $!
                );
            }
        }        
    }
    
    return $template;
}

# result should be cached with full list of params
push @EXPORT_OK, 'select_template';
sub select_template
{
    my $template_names = shift;
    my $dirs = shift // [getcwd()];
    
    confess "First parameter must be a template names array reference" 
        if(
            not ref $template_names
            or ref $template_names ne 'ARRAY'
            or not scalar @$template_names
        );

    my $result = undef;
    
    foreach my $template_name (@$template_names)
    {
        if( ref ( $result = get_template( $template_name, $dirs )) eq 'DTL::Fast::Template' )
        {
            last;
        }
    }
    
    return $result;
}


1;