package HTML::Window;
use strict;
use warnings;
require Exporter;
use vars qw($DefaultClass @EXPORT  @ISA $class $server $hidden $template);
our $style = 'Crystal';
our $title = '';
our $id    = 'a';
our ($collapse, $resizeable, $closeable, $moveable) = (0) x 4;

@ISA = qw(Exporter);
use Template::Quick;
@HTML::Window::ISA         = qw(Template::Quick);
@HTML::Window::EXPORT_OK   = qw( set_title set_class set_style set_closeable set_resizeable set_collapse set_moveable initWindow windowHeader windowFooter);
%HTML::Window::EXPORT_TAGS = ('all' => [qw(set_title set_class set_style set_closeable set_resizeable set_collapse set_moveable initWindow windowHeader windowFooter)]);
$HTML::Window::VERSION     = '0.28';

$DefaultClass = 'HTML::Window' unless defined $HTML::Window::DefaultClass;

%HTML::Window::EXPORT_TAGS = ('all' => [qw(set_title set_class set_style set_closeable set_resizeable set_collapse set_moveable initWindow windowHeader windowFooter)],);

=head1 NAME

HTML::Window.pm - html window

=head1 SYNOPSIS

use HTML::Window qw(:all);

       my %parameter =(

              cgiBin   => "path to cgi-bin",

              style    => "style to use",

              title    => "title",

              server   => "http://servername",

              id       => $id,

              class    => min or max,

       );
      $mod_perl = ($ENV{MOD_PERL}) ? 1 : 0;

      initWindow(\%parameter) unless($mod_perl);

      windowHeader();

       print 'this is the content';

       windowFooter();


=head1 DESCRIPTION

Produce a move-,resize-,collapse- and closeable Html Window.

This Module is mainly written for CGI::CMS::GUI.

But there is no reason to use it not standalone. Also it is much more easier

to update, test and distribute it  standalone.

=cut

=head2 new()

       my %parameter =(

              path    => "path to template",

              style    => "style to use",

              title    => "title

              server   => "http://servername",

              id       => $id,

              class    => min or max,

       );

       my $window = new  window(\%parameter);

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {closeable => 0, resizeable => 0, collapse => 1, moveable => 0,};
        bless $self, ref $class || $class || $DefaultClass;
        $self->initWindow(@initializer) if(@initializer);
        return $self;
}

=head2 set_style()

default: Crystal;

=cut

sub set_style {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(\w+)/) {
                $style = $1;
        } else {
                return $style;
        }
}

=head2 set_closeable()

default: 0;

=cut

sub set_closeable {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(0|1)/) {
                $closeable = $1;
        } else {
                return $closeable;
        }
}

=head2 set_resizeable()

default = 0;

=cut

sub set_resizeable {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(0|1)/) {
                $resizeable = $1;
        } else {
                return $resizeable;
        }
}

=head2 set_collapse()

default = 0;

=cut

sub set_collapse {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(0|1)/) {
                $collapse = $1;
        } else {
                return $collapse;
        }
}

=head2 set_moveable()

default = 0;

=cut

sub set_moveable {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(0|1)/) {
                $moveable = $1;
        } else {
                return $moveable;
        }
}

=head2 set_title()

default = 0;

=cut

sub set_title {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(\w+)/) {
                $title = $1;
        } else {
                return $title;
        }
}

=head2 set_class()

default = 0;

=cut

sub set_class {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] && $p[0] =~ /(\w+)/) {
                $class = $1;
        } else {
                return $class;
        }
}

=head2 initWindow()

       my %parameter =(

       path   => "path to templates",

       style    => "style to use",

       title    => "title

       server   => "http://servername",

       id       => $id,

       class    => min or max,

       hidden   => '', #set the window hidden

       );

       initWindow(\%parameter);

=cut

sub initWindow {
        my ($self, @p) = getSelf(@_);
        my $hash = $p[0];
        $server   = $hash->{server};
        $style    = defined $hash->{style} ? $hash->{style} : 'Crystal';
        $title    = defined $hash->{title} ? $hash->{title} : $title;
        $id       = defined $hash->{id} ? $hash->{id} : $id;
        $class    = defined $hash->{class} ? $hash->{class} : 'min';
        $hidden   = defined $hash->{hidden} ? 'style="visibility:hidden;position:absolute;' : '';
        $template = defined $hash->{template} ? $hash->{template} : "window.htm";
        my %template = (path => $hash->{path}, style => $style, template => $template,);
        $self->SUPER::initTemplate(\%template);
}

=head2 windowHeader()

=cut

sub windowHeader {
        my ($self, @p) = getSelf(@_);
        eval 'use CGI qw(cookie)';
        unless ($@) {
                my $co = cookie(-name => 'windowStatus') ? cookie(-name => 'windowStatus') : '';
                my @wins = split /:/, $co;
                for(my $i = 0 ; $i <= $#wins ; $i++) {
                        $hidden = 'style="visibility:hidden;position:absolute;"' if($id eq $wins[$i]);
                }
        }
        my $menu = " ";
        unless ($moveable eq 0 && $collapse eq 0 && $resizeable eq 0 && $closeable eq 0) {

                $menu .= qq(<script language="javascript" type="text/javascript">menu('$id','$moveable','$collapse','$resizeable','$closeable');</script>);
        }
        my %header = (
                name   => 'windowheader',
                server => $server,
                style  => $style,
                title  => $title,
                menu   => $menu,
                id     => $id,
                class  => $class,
                hidden => $hidden,

        );
        $self->SUPER::appendHash(\%header);
}

=head2 windowFooter()

=cut

sub windowFooter {
        my ($self, @p) = getSelf(@_);
        my %footer = (name => 'windowfooter', style => $style, id => $id,);
        $self->SUPER::appendHash(\%footer);
}

=head2 getSelf()

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'HTML::Window');
        return (defined($_[0]) && (ref($_[0]) eq 'HTML::Window' || UNIVERSAL::isa($_[0], 'HTML::Window'))) ? @_ : ($HTML::Window::DefaultClass->new, @_);
}

=head2 see Also

L<CGI::CMS::GUI> L<CGI> L<CGI::CMS> L<Template::Quick> 


=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006-2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation; 
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
