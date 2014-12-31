#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast::Template::Expression;

my $exp;

#$exp = new DTL::Fast::Template::Expression('blabla and (blabla not bla))');
#$exp = new DTL::Fast::Template::Expression('blabla and (blabla not bla)(');

$exp = new DTL::Fast::Template::Expression('myvar.val != "regular string"  or myvar.val2 == "string with \" quote" and (mytest or myvar.val2) and not mytime or number >= -othernumber and (a + ( b + d ) + e) * c <= 7');
use Data::Dumper;
print Dumper($exp);

done_testing();
