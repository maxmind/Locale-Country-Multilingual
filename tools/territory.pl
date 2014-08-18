#!/usr/bin/env perl

use strict;
use warnings;
use autodie ':all';

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

getopts( 'hi:v', \my %opts );
pod2usage() if $opts{h};
if ( $opts{v} ) {
    $VERSION =~ /(\d\S+)/;
    die "$0 $1\n";
}

for my $file (@ARGV) {
    process_language($file);
}

sub process_language {
    my $file = shift;

    my ($language) = $file =~ m{/([^/]+).xml};

    my $iso_file = $opts{i};
    my %iso_data;
    my ( $a2, $a3, $n3, $name );

    if ($iso_file) {
        my $csv = Text::CSV_XS->new( { binary => 1, sep_char => ';' } );
        open my $fh, '<:encoding(UTF-8)', $iso_file;
        <$fh>;    # skip first line
        while ( my $row = $csv->getline($fh) ) {
            $iso_data{ uc( $row->[0] ) }
                = [ uc( $row->[1] ), $row->[2], $row->[3] ];
        }
        close $fh;
    }


    my %countries = handle_territories( $parser->parse_file($file) );

    open my $out_fh, '>:encoding(UTF-8)', "lib/Locale/Country/Multilingual/$language.dat";
    for my $a2 ( sort keys %iso_data ) {
        ( $a3, $n3, $name ) = @{ $iso_data{$a2} };
        print {$out_fh} join(
            ':', $a2, $a3, $n3,
            ( ref( $countries{$a2} ) eq 'ARRAY' )
            ? @{ $countries{$a2} }
            : $name
            ),
            "\n";
    }
    close $out_fh;
}

sub handle_territories {
    my ($territories) = shift->findnodes('//territories');
    my ( @attr, $id, $name );

    die "No territories in file\n"
        unless blessed $territories
        and $territories->isa('XML::LibXML::Element');

    my %countries;
    foreach my $territory ( $territories->childNodes ) {
        next
            unless blessed $territory
            and $territory->isa('XML::LibXML::Element');
        @attr = $territory->attributes;
        $id   = $territory->getAttributeNode('type');
        next
            unless blessed $id and $id->value =~ /^[A-Z]{2}$/;

        ( $name = $territory->to_literal ) =~ s/:/ /g;    # : not allowed
        push @{ $countries{ uc( $id->value ) } }, $name;
    }
    return %countries;
}

__END__

=head1 NAME

  territory.pl - create country data files from territory section in CLDR data

=head1 SYNOPSIS

    territory.pl -h
    territory.pl -i iso-index.csv data/cldr/main/en.xml

=head1 DESCRIPTION

Create country data files from territory section in CLDR XML file.

