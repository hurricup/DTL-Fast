package DTL::Fast::Template::Filter::Urlize;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Filter';
use Carp qw(confess);

$DTL::Fast::Template::FILTER_HANDLERS{'urlize'} = __PACKAGE__;

use DTL::Fast::Utils qw(html_protect unescape);

#@Override
sub filter
{
    my $self = shift;  # self
    my $filter_manager = shift;  # filter_manager
    my $value = shift;  # value
    shift;    #context
    
    $value =~ s{
        (
            (?:(?:http|ftp|https)\://)?  # protocol
            (?:\w+\:\w+\@)?              # username and password
            (?:(?:www|ftp)\.)?           # domain prefixes
            (?:[-\w]+\.)+                # domain name
            (?:com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|travel|ru|рф|[a-z]{2,3}) # top level domain
            (?:\:\d{1,5})?               # port number
            (?:/[-\w~._]*)*?             # directories and files
            (?:\?[^\s#]+?)?              # query string no spaces or sharp
            (?:\#[^\s]+?)?               # anchor
        )
        ($|\s|\.|,|!)                    # after link
        }{$self->wrap_url($1,$2)}xesi;
    
    $filter_manager->{'safe'} = 1;
    
    return $value;
}

sub wrap_url
{
    my $self = shift;
    my $text = shift;
    my $appendix = shift // '';
    
    my $uri = $text;
    $uri = 'http://'.$uri if
        $uri !~ m{^(http|ftp|https)://}i;
    return sprintf '<a href="%s" rel="nofollow">%s</a>%s'
        , $uri
        , html_protect(unescape($text))
        , $appendix
        ;
}

1;