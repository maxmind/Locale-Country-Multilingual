#!perl -T

use Test::More tests => 4;

use Locale::Country::Multilingual;

cmp_ok(scalar(keys %{Locale::Country::Multilingual->languages}), '==', 0, 'no languages loaded');

load('en');

is_deeply([sort keys %{Locale::Country::Multilingual->languages}], [qw(en)], 'language en loaded successfully');

load('it');

is_deeply([sort keys %{Locale::Country::Multilingual->languages}], [qw(en it)], 'language en and it both loaded');

load('cn');

is_deeply([sort keys %{Locale::Country::Multilingual->languages}], [qw(cn en it)], 'language cn, en and it all loaded');


sub load {
    my $lang = shift;

    # create an object, load language data and go out of scope
    my @volatile = Locale::Country::Multilingual
	->new(lang => $lang)
	->all_country_codes;

    return;
}
