package HTML::TabWidget;
use strict;
use warnings;
require Exporter;
use vars qw($DefaultClass @ISA  $m_bMod_perl $action $scriptname);
our $m_sStyle;
use Template::Quick;
@HTML::TabWidget::ISA     = qw( Exporter Template::Quick);
$HTML::TabWidget::VERSION = '0.38';
$DefaultClass             = 'HTML::TabWidget'
    unless defined $HTML::TabWidget::DefaultClass;
@HTML::TabWidget::EXPORT_OK
    = qw(initTabWidget Menu tabwidgetHeader tabwidgetFooter);
%HTML::TabWidget::EXPORT_TAGS
    = ( 'all' => [qw(initTabWidget tabwidgetHeader Menu tabwidgetFooter)] );

$m_bMod_perl = ( $ENV{MOD_PERL} ) ? 1 : 0;
no warnings;

=head1 NAME

HTML::TabWidget - simple Html TabWidget

=head1 SYNOPSIS

      use HTML::TabWidget;

      my $tabwidget = new HTML::TabWidget(\%patmeter);

      my %parameter = (

                        style => 'Crystal',

                        path => "/srv/www/cgi-bin/templates",

                        anchors => [

                                {

                                text  => 'HTML::TabWidget ',

                                href  => "$ENV{SCRIPT_NAME}",

                                class => 'currentLink',

                                src   => 'link.png'

                                },

                                {

                                text => 'Next',

                                class => 'link',

                                },

                                {

                                text => 'Dynamic Tab',

                                title => 'per default it is the text'

                                href  => 'javascript:displayhidden()',

                                class => 'javaScriptLink',

                                }

                        ],

      );

      print $tabwidget->tabwidgetHeader();

      $tabwidget->Menu();

      print "your content";

      print $tabwidget->tabwidgetFooter();

You also need some js and css file.

Example:

print start_html(

        -title => 'TabWidget',

        -script => [

                {

                -type  => 'text/javascript',

                -src   => '/javascript/tabwidget.js'

                },

                ],

                -style => '/style/Crystal/tabwidget.css',

        );


=head3 function sets

Here is a list of the function sets you can import:

:all initTabWidget tabwidgetHeader Menu tabwidgetFooter


=head2 new

        my $tb = new HTML::TabWidget(%parameter);

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    $self->initTabWidget(@initializer) if( @initializer && !$m_bMod_perl );
    return $self;
}

=head2 initTabWidget

        initTabWidget(\%patmeter);

=cut

sub initTabWidget {
    my ( $self, @p ) = getSelf(@_);
    $m_sStyle = $p[0]->{style};
   $p[0]->{template}
        = defined $p[0]->{template} ? $p[0]->{template} : "tabwidget.htm";
    $self->SUPER::initTemplate( $p[0]);
}

=head2 Menu()

        Menu(\%patmeter);

=cut

sub Menu {
    my ( $self, @p ) = getSelf(@_);
    my $hash = $p[0];
    $self->initTabWidget($hash);    # unless $m_bMod_perl;
    my %header = ( name => 'menuHeader' );
    my $m = $self->SUPER::appendHash( \%header );
    for( my $i = 0; $i < @{ $hash->{anchors} }; $i++ ) {
        my $src
            = ( defined $hash->{anchors}[$i]->{src} )
            ? $hash->{anchors}[$i]->{src}
            : 'link.png';
        my $m_sTitle
            = ( defined $hash->{anchors}[$i]->{title} )
            ? $hash->{anchors}[$i]->{title}
            : $hash->{anchors}[$i]->{text};
        my $id
            = ( defined $hash->{anchors}[$i]->{id} )
            ? $hash->{anchors}[$i]->{id}
            : "menuLink$i";
        $action = defined $p[0]->{action}     ? $p[0]->{action}     : '';
        $scriptname = defined $p[0]->{scriptname} ? $p[0]->{scriptname} : '';
        my %action = (
            title => $m_sTitle,
            text  => $hash->{anchors}[$i]->{text},
            href  => $hash->{anchors}[$i]->{href},
            src   => $src,
        );
        $action{onclick} = $hash->{anchors}[$i]->{onclick}
            if defined $hash->{anchors}[$i]->{onclick};
        my %LINK = (
            name  => $hash->{anchors}[$i]->{class},
            style => $m_sStyle,
            id    => $id,
            text  => $self->action( \%action ),
            title => $hash->{anchors}[$i]->{title},
            src   => $src,
        );
        $m .= $self->SUPER::appendHash( \%LINK );
    }
    my %footer = ( name => 'menuFooter' );
    $m .= $self->SUPER::appendHash( \%footer );
    return $m;
}

=head2 tabwidgetHeader()

        tabwidgetHeader

=cut

sub tabwidgetHeader {
    my ( $self, @p ) = getSelf(@_);
    my %header = (
        name  => 'bheader',
        style => $m_sStyle,
    );
    $self->SUPER::appendHash( \%header );
}

=head2 tabwidgetFooter()

        tabwidgetFooter

=cut

sub tabwidgetFooter {
    my ( $self, @p ) = getSelf(@_);
    my %footer = (
        name       => 'bfooter',
        style      => $m_sStyle,
        action     => $action,
        scriptName => $scriptname,
    );
    $self->SUPER::appendHash( \%footer );
}

=head1 private

=head2 action()

      my %reply = (

            title => 'title',

            src => 'reply',

            href => "/reply.html",

            text => 'Your Text'

      );

      action(\%reply);

=cut

sub action {
    my ( $self, @p ) = getSelf(@_);
    my $hash     = $p[0];
    my $m_sTitle = $hash->{text} if( defined $hash->{text} );
    my $src      = $hash->{src} if( defined $hash->{src} );
    my $location = $hash->{href} if( defined $hash->{href} );
    my $onclick  = defined $hash->{onclick} ? $hash->{onclick} : '';
    my %action   = (
        name    => 'action',
        text    => $hash->{text},
        title   => $m_sTitle,
        href    => $location,
        src     => $src,
        onclick => qq|onclick="$onclick"|
    );
    return $self->SUPER::appendHash( \%action );
}

=head2 getSelf

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'HTML::TabWidget' );
    return (
        defined( $_[0] )
            && ( ref( $_[0] ) eq 'HTML::TabWidget'
            || UNIVERSAL::isa( $_[0], 'HTML::TabWidget' ) )
    ) ? @_ : ( $HTML::TabWidget::DefaultClass->new, @_ );
}

=head1 SEE ALSO

L<CGI::CMS> L<Template::Quick>

http://www.lindnerei.de, http://lindnerei.sourceforege.net,

Example:

http://lindnerei.sourceforge.net/cgi-bin/tabwidget.pl

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 LICENSE

Copyright (C) 2006- 2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
