package DTL::Fast::Tag::Load;
use strict; use utf8; use warnings FATAL => 'all'; 

use DTL::Fast::Template;
$DTL::Fast::TAG_HANDLERS{'load'} = __PACKAGE__;

sub new
{
    my $proto = shift;
    my $parameter = shift;
    
    $parameter =~ s/(^\s+|\s+$)//gs;
    my @modules = split /\s+/, $parameter;
    
    foreach my $module (@modules)
    {
        (my $file = "$module.pm") =~ s{::}{/}g;
        eval { require $file; };
        warn $@ if $@;
    }
    
    return;
}

1;
