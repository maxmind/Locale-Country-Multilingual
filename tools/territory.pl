#!/usr/bin/env perl

use strict;
use warnings;

use Getopt::Std;
use Pod::Usage;

use Scalar::Util 'blessed';
use Text::CSV_XS;
use XML::LibXML;
use Encode::StdIO;

our $VERSION = '0.01';

my $parser = XML::LibXML->new();
$parser->keep_blanks(0);

$Getopt::Std::STANDARD_HELP_VERSION = 1;

getopts('hi:v', \my %opts);
pod2usage() if $opts{h};
if ($opts{v}) {
    $VERSION =~ /(\d\S+)/;
    die "$0 $1\n";
}

my %Countries;
my $iso_file = $opts{i};
my %IsoData;
my ($a2, $a3, $n3, $name);

if ($iso_file) {
    my $csv = Text::CSV_XS->new ({binary => 1, sep_char => ';'});
    open my $fh, '<:utf8', $iso_file
	or die "Unable to open iso index file: $!\n";
    <$fh>;	# skip first line
    while (my $row = $csv->getline($fh)) {
	$IsoData{uc($row->[0])} = [uc($row->[1]), $row->[2], $row->[3]];
    }
    close $fh;
}

if (scalar @ARGV) {
    foreach (@ARGV) {
        handle_territories($parser->parse_file($_));
    }
}
else {
    # read from stdin
    my @doc = <STDIN>;
    my $string = join "", @doc;
    handle_territories($parser->parse_string($string));
}

foreach $a2 (sort keys %IsoData) {
    ($a3, $n3, $name) = @{$IsoData{$a2}};
    print join(':', $a2, $a3, $n3, (ref($Countries{$a2}) eq 'ARRAY') ? @{$Countries{$a2}} : $name), "\n";
}

sub handle_territories {
    my ($territories) = $_[0]->findnodes('//territories');
    my (@attr, $id, $name);

    die "No territories in file\n"
	unless blessed $territories and $territories->isa('XML::LibXML::Element');

    foreach my $territory ($territories->childNodes) {
	next
	    unless blessed $territory and
		$territory->isa('XML::LibXML::Element');
	@attr = $territory->attributes;
	$id = $territory->getAttributeNode('type');
	next
	    unless blessed $id and $id->value =~ /^[A-Z]{2}$/;
	
	($name = $territory->to_literal) =~ s/:/ /g;	# : not allowed
	push @{$Countries{uc($id->value)}}, $name;
    }
}

__END__

=head1 NAME

  territory.pl - create country data files from territory section in CLDR data

=head1 SYNOPSIS

    territory.pl -h
    territory.pl -i iso-index.csv data/cldr/main/en.xml

=head1 DESCRIPTION

Create country data files from territory section in CLDR XML file.

