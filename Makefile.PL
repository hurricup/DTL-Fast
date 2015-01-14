use 5.006;use strict;use warnings FATAL => 'all';use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'DTL::Fast',
    AUTHOR              => 'Alexandr Evstigneev <hurricup@evstigneev.com>',
    VERSION_FROM        => 'lib/DTL/Fast.pm', # finds $VERSION
    ABSTRACT_FROM       => 'lib/DTL/Fast.pm', # retrieve abstract from module
    MIN_PERL_VERSION    => 5.010,
    LICENSE             => 'MIT',
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::Harness' => 0,
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Date::Format' => 0,
        'URI::Escape::XS' => 0,
        'POSIX' => 0,
		'Storable' => 0,
    }, 
);
