use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Locale::Country::Multilingual',
    license             => 'perl',
    dist_author         => 'Fayland Lam <fayland@gmail.com>',
    dist_version_from   => 'lib/Locale/Country/Multilingual.pm',
    create_makefile_pl  => 'traditional',
    build_requires => {
        'Test::More' => 0,
        'File::Spec' => 0,
    },
    add_to_cleanup      => [ 'Locale-Country-Multilingual-*' ],
);
$builder->add_build_element('dat');
$builder->create_build_script();
