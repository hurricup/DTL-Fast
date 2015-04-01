#!/usr/bin/perl
use strict; use warnings FATAL => 'all'; 
use Test::More;

use DTL::Fast qw(get_template);
use DTL::Fast::Context;
use Data::Dumper;

my @LAST_WARNING;
local $SIG{__WARN__} = sub { # here we get the warning
    @LAST_WARNING = @_;
#    print STDERR $_[0];
}; 

my $dirs = ['./t/tmpl'];
my( $template, $test_string, $context);

$template = get_template('error_tag.txt', 'dirs' => $dirs)->render();
ok( $LAST_WARNING[0] =~ /error_tag.txt/si, 'Unknown tag error message: template filename');
ok( $LAST_WARNING[0] =~ /, syntax began at line 5/si, 'Unknown tag error message: line number');
ok( $LAST_WARNING[0] =~ /duplicate/si, 'Unknown tag error message: possible reason');

$template = get_template('error_undisclosed.txt', 'dirs' => $dirs)->render();

ok( $LAST_WARNING[0] =~ /error_undisclosed.txt/si, 'Undisclosed tag error message: template filename');
ok( $LAST_WARNING[0] =~ /endif/si, 'Undisclosed tag error message: tag name');
ok( $LAST_WARNING[0] =~ /, syntax began at line 36/si, 'Undisclosed tag error message: line number');
ok( $LAST_WARNING[0] =~ /with/si, 'Undisclosed tag error message: possible cause, inner block');
ok( $LAST_WARNING[0] =~ /at line 21/si, 'Undisclosed tag error message: possible cause, inner block line number');

$template = get_template('error_unknown_filter.txt', 'dirs' => $dirs)->render();

ok($LAST_WARNING[0] =~ /error_unknown_filter.txt/si, 'Unknown filter error message: template filename');
ok($LAST_WARNING[0] =~ /unknown_something/si, 'Unknown filter error message: filter name');
ok($LAST_WARNING[0] =~ /, syntax began at line 36/si, 'Unknown filter error message: source line number');

eval{$template = get_template('error_double_empty.txt', 'dirs' => $dirs)->render();};
ok($@ =~ /\Qthere can be only one {% empty %} block\E/si, 'Double empty block message: error message');
ok($@ =~ /error_double_empty.txt/si, 'Double empty block message: template name');
ok($@ =~ /at line 46/si, 'Double empty block message: template line');
ok($@ =~ /\QDTL::Fast::Tag::For\E/si, 'Double empty block message: parent block');
ok($@ =~ /at line 42/si, 'Double empty block message: parent block line');

eval{$template = DTL::Fast::Template->new('{{var1|date:"D"}}');};
ok( $@ eq '', "Undef time value passed");

eval{get_template('error_variable_name.txt', 'dirs' => $dirs);};
ok( $@ =~ /\Qvariable `a=b` contains incorrect symbols\E/, 'Wrong variable name: error message');
ok( $@ =~ /\Qsyntax began at line 36\E/, 'Wrong variable name: error line');

eval{get_template('error_autoescape_bla.txt', 'dirs' => $dirs);};
print $@;

# unpaired brackets
# two operators
# no operator processor
# binary operator missing left argument
# unary operator got left argumet
# unknown operator handler
# no right argument

done_testing();
