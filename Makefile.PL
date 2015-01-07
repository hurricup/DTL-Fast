use 5.018002;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'DTL::Fast',
    VERSION_FROM      => 'lib/DTL/Fast.pm', # finds $VERSION
    PREREQ_PM         => {
		'Date::Format' => '2.24',
		'URI::Escape::XS' => '0.12',
	}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/DTL/Fast.pm', # retrieve abstract from module
       AUTHOR         => 'Alexandr Evstigneev <hurricup@evstigneev.com>') : ()),
);
