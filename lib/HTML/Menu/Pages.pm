package HTML::Menu::Pages;
use Template::Quick;
use strict;
use warnings;
require Exporter;
use vars qw(
  $DefaultClass
  @EXPORT
  @ISA
  $action
  $length
  $start
  $style
  $mod_rewrite
  $append
  $pages
  $path
);

@HTML::Menu::Pages::EXPORT = qw(makePages);
@ISA                       = qw(Exporter);

$HTML::Menu::Pages::VERSION = '0.33';

$DefaultClass = 'HTML::Menu::Pages' unless defined $HTML::Menu::Pages::DefaultClass;

=head1 NAME

HTML::Menu::Pages - Create html anchors

=head1 SYNOPSIS

use HTML::Menu::Pages;

=head2 OO Syntax.

        my $test = new HTML::Menu::Pages;

                my %needed =(

                        length => '345',

                        style => 'Crystal',

                        mod_rewrite => 0,

                        action => 'dbs',

                        start  => param('von') ? param('von') : 0,

                        path => "/srv/www/cgi-bin/",

                        append => '?queryString=testit'

                );

        print $test->makePages(\%needed );

=head2 FO Syntax.

        my %needed =(

                length => '345',

                style => 'Crystal',

                mod_rewrite => 0,

                action => 'dbs',

                start  => param('von') ? param('von') : 0,

                path => "/srv/www/cgi-bin/",

                append => '?queryString=testit'

        );

        print makePages(\%needed );


=head2 EXPORT

makePages

=head1 Public

=head2 Public new()


=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        return $self;
}

=head2 makePages()

see SYNOPSIS

=cut

sub makePages {
        my ($self, @p) = getSelf(@_);
        my $hashref = $p[0];
        $action      = $hashref->{action};
        $start       = $hashref->{start} > 0 ? $hashref->{start} : 0;
        $style       = $hashref->{style};
        $mod_rewrite = $hashref->{mod_rewrite};
        $append      = $hashref->{append} ? $hashref->{append} : '';
        $length      = $hashref->{length} ? $hashref->{length} : 0;
        $pages       = $hashref->{title} ? $hashref->{title} : "Seiten";
        $path        = $hashref->{path} ? $hashref->{path} : 'cgi-bin/';
        $self->ebis() if($length > 10);
}

=head2 ebis()

private

=cut

sub ebis {
        my ($self, @p) = getSelf(@_);
        my $previousPage = (($start- 10) > 0) ? $start- 10 : 0;
        my $nextPage = $start;
        $nextPage = 10 if($previousPage <= 0);
        my %template = (path => "$path/templates", style => $style, template => "pages.htm", name => 'pages');
        my @data = ({name => 'header', pages => $pages,},);
        my $link = ($mod_rewrite) ? "/$previousPage/$nextPage/$action.html?$append" : "$ENV{SCRIPT_NAME}?von=$previousPage&amp;bis=$nextPage&amp;action=$action$append";
        push @data, {name => "previous", href => "$link",} if($start- 10 >= 0);
        my $sites = 1;

        if($length > 1) {
                if($length % 10== 0) {
                        $sites = (int($length/ 10))* 10;
                } else {
                        $sites = (int($length/ 10)+ 1)* 10;
                }
        }
        my $beginn = $start/ 10;
        $beginn = (int($start/ 10)+ 1)* 10 unless ($start % 10== 0);
        $beginn = 0 if($beginn < 0);
        my $b = ($sites >= 10) ? $beginn : 0;
        $b = ($beginn- 10 >= 0) ? $beginn- 10 : 0;
        my $h1 = (($start- (10* 5))/ 10);
        $b = $h1 if($h1 > 0);
        my $end = ($sites >= 10) ? $b+ 10 : $sites;

        while($b < $end+ 1) {    # append links
                my $c = $b* 10;
                my $d = $c+ 10;
                $d = $length if($d > $length);
                my $svbis = ($mod_rewrite) ? "/$c/$d/$action.html?$append" : "$ENV{SCRIPT_NAME}?von=$c&amp;bis=$d&amp;action=$action$append";
                push @data, ($b* 10 eq $start) ? {name => 'currentLinks', href => $svbis, title => $b} : {name => 'links', href => $svbis, title => $b};
                last if($d eq $length);
                $b++;
        }
        my $v    = $start+ 10;
        my $next = $v+ 10;
        $next = $length if($next > $length);
        my $esvbis = ($mod_rewrite) ? "/$v/$next/$action.html?$append" : "$ENV{SCRIPT_NAME}?von=$v&amp;bis=$next&amp;action=$action$append";
        push @data, {name => "next", href => $esvbis} if($v < $length);    # apend the Next "button"
        push @data, {name => 'footer'};                                    # apend the footer
        return initTemplate(\%template, \@data);
}

=head2  getSelf()

privat see L<HTML::Menu::TreeView>

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'HTML::Menu::Pages');
        return (defined($_[0]) && (ref($_[0]) eq 'HTML::Menu::Pages' || UNIVERSAL::isa($_[0], 'HTML::Menu::Pages'))) ? @_ : ($HTML::Menu::Pages::DefaultClass->new, @_);
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006 - 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
