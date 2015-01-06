package DTL::Fast::Utils;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'Exporter';

require Date::Format;
require URI::Escape::XS;
use Carp qw(confess cluck);

our @EXPORT_OK;

push @EXPORT_OK, 'is_object';
sub is_object
{
    my $ref = shift;
    return (
        ref $ref
        and UNIVERSAL::can($ref, 'can')
    );
}

push @EXPORT_OK, 'has_method';
sub has_method
{
    my $ref = shift;
    my $method = shift;
    
    return (
        is_object($ref)
        and $ref->can($method)
    );
}

# @todo This must be implemented with XS part (already written)
push @EXPORT_OK, 'html_protect';
our %HTML_PROTECT = (
    '<' => '&lt;',
    '>' => '&gt;',
    '\'' => '&#39;',
    '"' => '&quot;',
    '&' => '&amp;',
);

our $HTML_PROTECT_RE = join '|', keys %HTML_PROTECT;

sub html_protect
{
    my $text = shift;
    return $text if not defined $text;
    $text =~ s/($HTML_PROTECT_RE)/$HTML_PROTECT{$1}/g;
    return $text;
}

# @todo what with timezones?
push @EXPORT_OK, 'time2str';
sub time2str{ 
    my $format = shift;
    my $time = shift;
    return Date::Format::time2str($format, $time );
}

push @EXPORT_OK, 'uri_escape';
sub uri_escape{return URI::Escape::XS::uri_escape(shift);}

push @EXPORT_OK, 'uri_unescape';
sub uri_unescape{return URI::Escape::XS::uri_unescape(shift);}

push @EXPORT_OK, 'escape';
sub escape{return URI::Escape::XS::encodeURIComponent(shift);}

push @EXPORT_OK, 'unescape';
sub unescape{return URI::Escape::XS::decodeURIComponent(shift);}

1;