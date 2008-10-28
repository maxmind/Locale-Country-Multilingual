package Locale::Country::Multilingual;

use warnings;
use strict;
use vars qw/$VERSION/;
use File::Spec;
use Carp;

$VERSION = '0.06';

sub new {
	my $class = shift;
	my $dir = __FILE__; $dir =~ s/\.pm//o;
	-d $dir or croak "Directory $dir nonexistent!";
	my $self;
	$self->{'DIR'} = $dir;
	return bless $self => $class;
}

sub set_lang {
    my ($self, $lang) = @_;
    
    $self->{'lang'} = $lang;
    $self->_load_data($lang);
}

sub code2country {
    my ($self, $code, $lang) = @_;
    
    return unless defined $code;
    return if ($code =~ /\W/);
    
    $lang ||= $self->{lang} || 'en';
    $self->_load_data($lang);
    
    if ($code =~ /^\d+$/) {
        return $self->{$lang}->{CODES}->{LOCALE_CODE_NUMERIC}->{$code};
    } elsif (length($code) == 2) {
        return $self->{$lang}->{CODES}->{LOCALE_CODE_ALPHA_2}->{$code};
    } elsif (length($code) == 3) {
        return $self->{$lang}->{CODES}->{LOCALE_CODE_ALPHA_3}->{$code};
    }
    return;
}

sub country2code {
    my ($self, $country, $codeset, $lang) = @_;
    
    return unless defined $country;
    $country = lc($country);
    
    $lang ||= $self->{lang} || 'en';
    $self->_load_data($lang);
    
    $codeset ||= 'LOCALE_CODE_ALPHA_2'; # default
    if (exists $self->{$lang}->{COUNTRIES}->{$codeset}->{$country}) {
        return $self->{$lang}->{COUNTRIES}->{$codeset}->{$country};
    }
    
    return;
}

sub all_country_codes {
    my ($self, $codeset) = @_;

    my $lang ||= $self->{lang} || 'en';
    $self->_load_data($lang);

    $codeset ||= 'LOCALE_CODE_ALPHA_2'; # default
    return keys %{ $self->{$lang}->{CODES}->{$codeset} };
}

sub all_country_names {
    my ($self, $lang) = @_;

    $lang ||= $self->{lang} || 'en';
    $self->_load_data($lang);

    return keys %{ $self->{$lang}->{COUNTRIES}->{LOCALE_CODE_ALPHA_2} };
}

sub _load_data {
    my ($self, $lang) = @_;
    
    return if ($self->{$lang}); # already set
    
    my $file = File::Spec->catfile($self->{'DIR'}, "$lang.dat");
	open(FH, $file)	or croak "$file: $!";
	while (<FH>) {
	    chomp;
		my ($alpha2, $alpha3, $numeric, @countries) = split(/:/, $_);
		next unless ($alpha2);
		$self->{$lang}->{CODES}->{LOCALE_CODE_ALPHA_2}->{$alpha2} = $countries[0];
		$self->{$lang}->{CODES}->{LOCALE_CODE_ALPHA_3}->{$alpha3} = $countries[0] if ($alpha3);
		$self->{$lang}->{CODES}->{LOCALE_CODE_NUMERIC}->{$numeric} = $countries[0] if ($numeric);
		foreach my $country (@countries) {
		    $self->{$lang}->{COUNTRIES}->{LOCALE_CODE_ALPHA_2}->{"\L$country"} = $alpha2;
		    $self->{$lang}->{COUNTRIES}->{LOCALE_CODE_ALPHA_3}->{"\L$country"} = $alpha3 if ($alpha3);
		    $self->{$lang}->{COUNTRIES}->{LOCALE_CODE_NUMERIC}->{"\L$country"} = $numeric if ($numeric);
		}
	}
	close(FH);
}

1;
__END__

=head1 NAME

Locale::Country::Multilingual - ISO codes for country identification with multi-language (ISO 3166)

=head1 SYNOPSIS

    use Locale::Country::Multilingual;

    my $lcm = Locale::Country::Multilingual->new();
    $country = $lcm->code2country('jp');        # $country gets 'Japan'
    $country = $lcm->code2country('chn');       # $country gets 'China'
    $country = $lcm->code2country('250');       # $country gets 'France'
    $code    = $lcm->country2code('Norway');    # $code gets 'no'
    
    $lcm->set_lang('cn'); # set default language to Chinese
    $country = $lcm->code2country('cn');        # $country gets '中国'
    $code    = $lcm->country2code('日本');      # $code gets 'jp'
    
    @codes   = $lcm->all_country_codes();
    @names   = $lcm->all_country_names();
    
    # more heavy call
    my $lang = 'en';
    $country = $lcm->code2country('cn', $lang);        # $country gets 'China'
    $lang = 'cn';
    $country = $lcm->code2country('cn', $lang);        # $country gets '中国'
    
    my $CODE = 'LOCALE_CODE_ALPHA_2'; # by default
    $code    = $lcm->country2code('Norway', $CODE);    # $code gets 'no'
    $CODE = 'LOCALE_CODE_ALPHA_3';
    $code    = $lcm->country2code('Norway', $CODE);    # $code gets 'nor'
    $CODE = 'LOCALE_CODE_NUMERIC';
    $code    = $lcm->country2code('Norway', $CODE);    # $code gets '578'
    $code    = $lcm->country2code('挪威', $CODE, 'cn');    # with lang=cn
    
    $CODE = 'LOCALE_CODE_ALPHA_3';
    $lang = 'cn';
    @codes   = $lcm->all_country_codes($CODE);         # return codes with 3alpha
    @names   = $lcm->all_country_names($lang);         # get all Chinese Countries Names

=head1 AVAILABLE LANGAUGES

=over 4

=item en - English

=item cn - Chinese Simp.

=item tw - Chinese Trad.

=item it - Italian

=item es - Spanish

=item pt - Portuguese

=item de - German

=item fr - French

=item ja - Japanese

=item no - Norwegian

=back

other languages are welcome to send by email.

=head1 SEE ALSO

L<Locale::Country>

=head1 ACKNOWLEDGEMENTS

Thanks to michele ongaro for Italian/Spanish/Portuguese/German/French/Japanese dat files.

Thanks to Andreas Marienborg for Norwegian dat file.

=head1 AUTHOR

Fayland Lam, C<< <fayland at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Fayland Lam, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.