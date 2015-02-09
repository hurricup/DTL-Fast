package DTL::Fast::Tags;
use strict; use utf8; use warnings FATAL => 'all'; 

# built in tags
use DTL::Fast::Tag::Autoescape;
use DTL::Fast::Tag::Block;
use DTL::Fast::Tag::Comment;
use DTL::Fast::Tag::Cycle;
use DTL::Fast::Tag::Extends;
use DTL::Fast::Tag::Filter;
use DTL::Fast::Tag::Firstof;
use DTL::Fast::Tag::For;
use DTL::Fast::Tag::Include;
use DTL::Fast::Tag::If;
use DTL::Fast::Tag::Ifchanged;
use DTL::Fast::Tag::Ifequal;
use DTL::Fast::Tag::Ifnotequal;
use DTL::Fast::Tag::Load;
use DTL::Fast::Tag::Now;
use DTL::Fast::Tag::Regroup;
use DTL::Fast::Tag::Spaceless;
use DTL::Fast::Tag::Ssi;
use DTL::Fast::Tag::Templatetag;
use DTL::Fast::Tag::Url;
use DTL::Fast::Tag::Verbatim;
use DTL::Fast::Tag::Widthratio;
use DTL::Fast::Tag::With;

# not from Django
use DTL::Fast::Tag::Firstofdefined;

1;
