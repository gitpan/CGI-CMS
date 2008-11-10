package CGI::CMS::Session;
use strict;
use warnings;
require Exporter;
use vars qw( $session $DefaultClass @EXPORT  @ISA $defaultconfig);
@CGI::CMS::Session::EXPORT = qw(loadSession saveSession $session);
use CGI::CMS::Config;
@CGI::CMS::Session::ISA     = qw(Exporter CGI::CMS::Config);
$CGI::CMS::Session::VERSION = '0.37';
$DefaultClass               = 'CGI::CMS::Session'
    unless defined $CGI::CMS::Session::DefaultClass;
$defaultconfig = '%CONFIG%';

=head1 NAME

CGI::CMS::Session - store the sessions for CGI::CMS

=head1 SYNOPSIS

see l<CGI::CMS>

=head1 DESCRIPTION

session for CGI::CMS.

=head2 EXPORT

loadConfig() saveSession() $session

=head1 Public

=head2 new

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    return $self;
}

=head2 loadConfig

=cut

sub loadSession {
    my ( $self, @p ) = getSelf(@_);
    my $do = ( defined $p[0] ) ? $p[0] : $defaultconfig;
    if( -e $do ) {
        do $do;
    }
}

=head2 saveSession

=cut

sub saveSession {
    my ( $self, @p ) = getSelf(@_);
    my $l = defined $p[0] ? $p[0] : $defaultconfig;
    $self->SUPER::saveConfig( $l, $session, 'session' );
}

=head1 Private

=head2 getSelf

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'CGI::CMS::Session' );
    return (
        defined( $_[0] )
            && ( ref( $_[0] ) eq 'CGI::CMS::Session'
            || UNIVERSAL::isa( $_[0], 'CGI::CMS::Session' ) )
    ) ? @_ : ( $CGI::CMS::Session::DefaultClass->new, @_ );
}

1;
