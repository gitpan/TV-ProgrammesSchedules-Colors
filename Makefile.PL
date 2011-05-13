use strict;use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'TV::ProgrammesSchedules::Colors',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/TV/ProgrammesSchedules/Colors.pm',
    ABSTRACT_FROM => 'lib/TV/ProgrammesSchedules/Colors.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'TV-ProgrammesSchedules-Colors-*' },
    PREREQ_PM     => {
        'Test::More'       => 0,
        'Readonly'         => 0,
        'XML::Simple'      => '2.14',
        'Moose'            => '2.0006',
        'Time::localtime'  => '1.02',
        'HTTP::Request'    => '1.40',
        'LWP::UserAgent'   => '2.33',
        'namespace::clean' => '0.20',
        'Moose::Util::TypeConstraints' => '2.0006',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);