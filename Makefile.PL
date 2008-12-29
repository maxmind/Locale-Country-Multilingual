use inc::Module::Install;

name		'Locale-Country-Multilingual';
license		'perl';
all_from	'lib/Locale/Country/Multilingual.pm';
author		'Bernhard Graf <graf@cpan.org>';

requires	'Carp';
requires	'Class::Data::Inheritable';
requires	'File::Spec';
requires	'Symbol';

test_requires	'Test::More';

auto_install;

WriteAll;
