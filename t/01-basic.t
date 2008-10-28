#!perl -T

use Test::More tests => 12;

use Locale::Country::Multilingual;
my $lcm = Locale::Country::Multilingual->new();

my $country = $lcm->code2country('jp');
is($country, 'Japan', "alpha2: code2country('jp') works");

$country = $lcm->code2country('chn');
is($country, 'China', "alpha3: code2country('chn') works");

$country = $lcm->code2country('250');
is($country, 'France', "NUMERIC: code2country('250') works");

$lcm->set_lang('cn');

$country = $lcm->code2country('cn'); 
is($country, '中国', "code2country('cn') works after set_lang");

my $lang = 'en';
$country = $lcm->code2country('cn', $lang);
is($country, 'China', "code2country('cn', 'en') works");
$lang = 'cn';
$country = $lcm->code2country('cn', $lang);
is($country, '中国', "code2country('cn', 'cn') works");

$lcm->set_lang('en');
my $code    = $lcm->country2code('Norway');
is($code, 'no', "alpha2: country2code('Norway') works");

my $CODE = 'LOCALE_CODE_ALPHA_2';
$code    = $lcm->country2code('Norway', $CODE);    # $code gets 'no'
is($code, 'no', "alpha2: country2code('Norway', 'LOCALE_CODE_ALPHA_2') works");
$CODE = 'LOCALE_CODE_ALPHA_3';
$code    = $lcm->country2code('Norway', $CODE);    # $code gets 'nor'
is($code, 'nor', "alpha3: country2code('Norway', 'LOCALE_CODE_ALPHA_3') works");
$CODE = 'LOCALE_CODE_NUMERIC';
$code    = $lcm->country2code('Norway', $CODE);    # $code gets '578'
is($code, '578', "NUMERIC: country2code('Norway', 'LOCALE_CODE_NUMERIC') works");

$code    = $lcm->country2code('挪威', $CODE, 'cn');
is($code, '578', "NUMERIC: country2code('挪威', 'LOCALE_CODE_NUMERIC', 'cn') works");

$lcm->set_lang('tw');
$country = $lcm->code2country('tw'); 
is($country, '台灣', "code2country('tw') works after set_lang=tw");
