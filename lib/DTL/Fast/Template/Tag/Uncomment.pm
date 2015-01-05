package DTL::Fast::Template::Tag::Uncomment;
use strict; use utf8; use warnings FATAL => 'all'; 
use parent 'DTL::Fast::Template::Tag';
use Carp qw(confess);

$DTL::Fast::Template::TAG_HANDLERS{'uncomment'} = __PACKAGE__;

sub get_close_tag{ return 'enduncomment';}

1;