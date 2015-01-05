package DTL::Fast::Template::Tag::Load;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;
$DTL::Fast::Template::TAG_HANDLERS{'load'} = __PACKAGE__;

sub new
{
    my $proto = shift;
    my $parameter = shift;
    
    $parameter =~ s/(^\s+|\s+$)//gs;
    my @modules = split /\s+/, $parameter;
    
    foreach my $module (@modules)
    {
        eval "use $module;";
        warn $@ if $@;
    }
    
    return undef;
}

1;
