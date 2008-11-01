#!perl -T

use Test::More;
eval "use 5.8.0";
plan skip_all => "Perl 5.8 required for testing POD" if $@;
eval "use Test::Pod 1.14";
plan skip_all => "Test::Pod 1.14 required for testing POD" if $@;
all_pod_files_ok();
