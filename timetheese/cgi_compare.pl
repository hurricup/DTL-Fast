#!/usr/bin/perl -I../lib/

use Benchmark qw(:all);

sub dtl_fast
{
    system('perl cgi_dtl_fast.pl');
}

sub dtl_dotiac
{
    system('perl cgi_dtl_dotiac.pl');
}

timethese( 300, {
	'DTL::Fast' => \&dtl_fast,
	'Dotiac' => \&dtl_dotiac,
});
