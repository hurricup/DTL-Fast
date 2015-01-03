package DTL::Fast::Template::Tags;
use strict; use utf8; use warnings FATAL => 'all'; 

# built in tags
use DTL::Fast::Template::Tag::Autoescape;
use DTL::Fast::Template::Tag::Comment;
use DTL::Fast::Template::Tag::Cycle;
use DTL::Fast::Template::Tag::Debug;
use DTL::Fast::Template::Tag::Include;
use DTL::Fast::Template::Tag::If;
use DTL::Fast::Template::Tag::For;

# not from Django
use DTL::Fast::Template::Tag::Uncomment;

1;
