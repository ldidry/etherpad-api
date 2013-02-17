

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Etherpad::API',
    VERSION_FROM => 'lib/Etherpad/API.pm', # finds \$VERSION
    AUTHOR       => 'Luc DIDRY (ldidry@cpan.org)',
    ABSTRACT     => 'Access Etherpad Lite API easily',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                     'LWP::UserAgent' => 0,
                     'JSON::XS' => 0,
                     'Carp' => 0
                    },
);
