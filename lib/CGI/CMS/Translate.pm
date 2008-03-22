package CGI::CMS::Translate;
use strict;
use warnings;
require Exporter;
use vars qw($ACCEPT_LANGUAGE $lang $DefaultClass @EXPORT  @ISA $defaultconfig);
@CGI::CMS::Translate::EXPORT = qw(loadTranslate saveTranslate $lang);
use CGI::CMS::Config;
@ISA                          = qw(Exporter CGI::CMS::Config);
$CGI::CMS::Translate::VERSION = '0.3';
$DefaultClass                 = 'CGI::CMS::Translate' unless defined $CGI::CMS::Translate::DefaultClass;
$defaultconfig                = '%CONFIG%';

=head1 NAME

CGI::CMS::Translate - manage translations for CGI::LZE

=head1 SYNOPSIS

        use CGI::CMS::Translate;

        use vars qw($lang);

        loadTranslate("/srv/www/cgi-bin/config/translate.pl");

        *lang = \$CGI::CMS::Translate::lang;

        print $lang->{de}{firstname};  #'Vorname'

=head1 DESCRIPTION

Translations for CGI::CMS.

=head2 EXPORT

loadTranslate() saveTranslate() $lang

=head1 Public

=head2 new()

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        return $self;
}

=head2 loadTranslate()

=cut

sub loadTranslate {
        my ($self, @p) = getSelf(@_);
        my $do = (defined $p[0]) ? $p[0] : $defaultconfig;
        if(-e $do) {
                do $do;
        }
}

=head2  saveTranslate()

=cut

sub saveTranslate {
        my ($self, @p) = getSelf(@_);
        my $l = defined $p[0] ? $p[0] : $defaultconfig;
        $self->SUPER::saveConfig($l, $lang, 'lang');
}

=head1 Private

=head2 getSelf()

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'CGI::CMS::Translate');
        return (defined($_[0]) && (ref($_[0]) eq 'CGI::CMS::Translate' || UNIVERSAL::isa($_[0], 'CGI::CMS::Translate'))) ? @_ : ($CGI::CMS::Translate::DefaultClass->new, @_);
}

=head2 see Also

L<CGI> L<CGI::CMS> L<CGI::CMS::Actions> L<CGI::CMS::Translate> L<CGI::CMS::Settings> L<CGI::CMS::Config>

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
