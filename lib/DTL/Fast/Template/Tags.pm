package DTL::Fast::Template::Tags;
use strict; use utf8; use warnings FATAL => 'all'; 

# built in tags
use DTL::Fast::Template::Tag::Autoescape;
use DTL::Fast::Template::Tag::Comment;
use DTL::Fast::Template::Tag::Cycle;
use DTL::Fast::Template::Tag::Debug;
use DTL::Fast::Template::Tag::Filter;
use DTL::Fast::Template::Tag::Firstof;
use DTL::Fast::Template::Tag::For;
use DTL::Fast::Template::Tag::Include;
use DTL::Fast::Template::Tag::If;
use DTL::Fast::Template::Tag::Ifchanged;
use DTL::Fast::Template::Tag::Ifequal;
use DTL::Fast::Template::Tag::Ifnotequal;
use DTL::Fast::Template::Tag::Load;
use DTL::Fast::Template::Tag::Now;
use DTL::Fast::Template::Tag::Regroup;
use DTL::Fast::Template::Tag::Spaceless;

# not from Django
use DTL::Fast::Template::Tag::Firstofdefined;
use DTL::Fast::Template::Tag::Uncomment;

1;
