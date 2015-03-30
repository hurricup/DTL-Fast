#!/usr/bin/perl -Ilib -Iblib/arch
# use locale;
# use POSIX qw(locale_h);
# my $locale = "ru_RU.CP-1251";
# setlocale(LC_COLLATE, $locale);
# setlocale(LC_CTYPE, $locale);
use DTL::Fast;
use Data::Dumper;

my $ab = "\x{100}";
print "Unicode string\n";
print Dumper($ab);
print DTL::Fast::dump_string($ab);
print "\n";

print "Unicode string after encoding: if utf8 flag was set, just unsets it, otherwise threats bytes as codepoints and converts to utf8 sequence. Clears utf8 flag.\n";
utf8::encode($ab);
print Dumper($ab);
print DTL::Fast::dump_string($ab);
print "\n";

$ab = 'à';
print "CP1251 string without utf8 flag\n";
print Dumper($ab);
print DTL::Fast::dump_string($ab);
print "\n";

print "CP1251 string after encoding, treated as codepoints and been converted to utf-8 sequence.\n";
utf8::encode($ab);
print Dumper($ab);
print DTL::Fast::dump_string($ab);
print "\n";

print "UTF-8 string upgraded, all bytes treated as codepoints and converted to utf-8 sequences, sets utf8 flag\n";
utf8::upgrade($ab);
print DTL::Fast::dump_string($ab);
print "\n";

utf8::downgrade($ab);
print DTL::Fast::dump_string($ab);
print "\n";
