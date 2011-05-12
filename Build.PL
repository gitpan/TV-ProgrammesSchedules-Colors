use strict;use warnings;
use Module::Build;

my $builder = Module::Build->new(
    sign              => 1,
    module_name       => 'TV::ProgrammesSchedules::Colors',
    license           => 'perl',
    dist_author       => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    dist_version_from => 'lib/TV/ProgrammesSchedules/Colors.pm',
    add_to_cleanup    => [ 'TV-ProgrammesSchedules-Colors-*' ],    
    build_requires    => {
        'Test::More'       => 0,
        'Readonly'         => 0,
        'Moose'            => '2.0006',
        'Time::localtime'  => '1.02',
        'HTTP::Request'    => '1.40',
        'LWP::UserAgent'   => '2.33',
        'namespace::clean' => '0.20',
        'Moose::Util::TypeConstraints' => '2.0006',
    },
);

$builder->create_build_script();