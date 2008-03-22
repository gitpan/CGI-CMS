package ISettings;
use strict;
use warnings;
require Exporter;
use vars qw($settings $DefaultClass @EXPORT  @ISA $defaultconfig);
@ISettings::EXPORT  = qw(loadSettings saveSettings $settings);
@ISA                = qw(Exporter);
$ISettings::VERSION = '0.3';
$DefaultClass       = 'ISettings' unless defined $ISettings::DefaultClass;
$defaultconfig      = 'cgi-bin/config/settings.pl';

=head1 NAME

ISettings

=head1 DESCRIPTION

Config for CGI::CMS.

use this for whatever you want to store.


=head2 EXPORT

loadSettings() saveSettings() $settings

=head1 Public

=head2 new()

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        return $self;
}

=head2 loadSettings()

=cut

sub loadSettings {
        my ($self, @p) = getSelf(@_);
        my $do = (defined $p[0]) ? $p[0] : $defaultconfig;
        if(-e $do) {
                do $do;
        }
}

=head2 saveSettings()

=cut

sub saveSettings {
        my ($self, @p) = getSelf(@_);
        my $saveAs = defined $p[0] ? $p[0] : $defaultconfig;
        use Data::Dumper;
        my $content = Dumper($settings);
        $content .= "\$settings =\$VAR1;";
        use Fcntl qw(:flock);
        use Symbol;
        my $fh = gensym();
        my $rsas = $saveAs =~ /^(\S+)$/ ? $1 : 0;

        if($rsas) {
                open $fh, ">$rsas.bak" or warn "$/ISettings::saveSettings$/ $! $/ File: $rsas $/Caller: " . caller() . $/;
                flock $fh, 2;
                seek $fh, 0, 0;
                truncate $fh, 0;
                print $fh $content;
                close $fh;
        }
        if(-e "$rsas.bak") {
                rename "$rsas.bak", $rsas or warn "$/ISettings::saveSettings$/ $! $/ File: $rsas $/Caller: " . caller() . $/;
                do $rsas;
        }
}

=head1 Private

=head2 getSelf()

see L<HTML::Menu::TreeView>

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'ISettings');
        return (defined($_[0]) && (ref($_[0]) eq 'ISettings' || UNIVERSAL::isa($_[0], 'ISettings'))) ? @_ : ($ISettings::DefaultClass->new, @_);
}

=head2 see Also

L<CGI> L<CGI::CMS> L<CGI::CMS::Actions> L<CGI::CMS::Translate> L<CGI::CMS::Settings> L<ISettings>

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005-2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
