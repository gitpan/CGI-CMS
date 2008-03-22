package CGI::CMS;
use strict;
use warnings;
use CGI::CMS::Settings;
use CGI::CMS::Translate;
use CGI::CMS::Config;
use CGI::CMS::Session;
use CGI::CMS::Actions;
use CGI qw(-compile :all :html2 :html3 :html4  :cgi :cgi-lib  -private_tempfiles);

require Exporter;
use vars qw(
  $params
  $qy
  $actions
  $ACCEPT_LANGUAGE
  $DefaultClass
  $uplod_bytes
  $DefaultClass
  @EXPORT
  @ISA
  $mod_perl
  $settings
  $upload_error
  $user
  $lng
  @EXPORT_OK
  %EXPORT_TAGS
  $defaultconfig
);

$CGI::DefaultClass      = 'CGI';
$DefaultClass           = 'CGI::CMS' unless defined $CGI::CMS::DefaultClass;
$defaultconfig          = '%CONFIG%';
$CGI::AutoloadClass     = 'CGI';
$CGI::CMS::VERSION = '0.3';
$mod_perl               = ($ENV{MOD_PERL}) ? 1 : 0;
our $hold = 120;    #session ist 120 sekunden gültig.
@ISA = qw(Exporter CGI );
@CGI::CMS::EXPORT_OK =
  qw(start_table end_table include h1 h2 h3 h4 h5 h6 p br hr ol ul li dl dt dd menu code var strong em tt u i b blockquote pre img a address cite samp dfn html head base body Link nextid title meta kbd start_html end_html input Select option comment charset escapeHTML div table caption th td TR Tr sup Sub strike applet Param embed basefont style span layer ilayer font frameset frame script small big Area Map abbr acronym bdo col colgroup del fieldset iframe ins label legend noframes noscript object optgroup Q thead tbody tfoot blink fontsize center textfield textarea filefield password_field hidden checkbox checkbox_group submit reset defaults radio_group popup_menu button autoEscape scrolling_list image_button start_form end_form startform endform start_multipart_form end_multipart_form isindex tmpFileName uploadInfo URL_ENCODED MULTIPART param upload path_info path_translated request_uri url self_url script_name cookie Dump raw_cookie request_method query_string Accept user_agent remote_host content_type remote_addr referer server_name server_software server_port server_protocol virtual_port virtual_host remote_ident auth_type http append save_parameters restore_parameters param_fetch remote_user user_name header redirect import_names put Delete Delete_all url_param cgi_error ReadParse PrintHeader HtmlTop HtmlBot SplitParam Vars https $ACCEPT_LANGUAGE  translate init session createSession $params clearSession $qy sessionValidity includeAction);

%EXPORT_TAGS = (
        'html2' => [
                'h1' .. 'h6', qw/p br hr ol ul li dl dt dd menu code var strong em
                  tt u i b blockquote pre img a address cite samp dfn html head
                  base body Link nextid title meta kbd start_html end_html
                  input Select option comment charset escapeHTML/
        ],
        'html3' => [
                qw/div table caption th td TR Tr sup Sub strike applet Param
                  embed basefont style span layer ilayer font frameset frame script small big Area Map/
        ],
        'html4' => [
                qw/abbr acronym bdo col colgroup del fieldset iframe
                  ins label legend noframes noscript object optgroup Q
                  thead tbody tfoot/
        ],
        'netscape' => [qw/blink fontsize center/],
        'form'     => [
                qw/textfield textarea filefield password_field hidden checkbox checkbox_group
                  submit reset defaults radio_group popup_menu button autoEscape
                  scrolling_list image_button start_form end_form startform endform
                  start_multipart_form end_multipart_form isindex tmpFileName uploadInfo URL_ENCODED MULTIPART/
        ],
        'cgi' => [
                qw/param upload path_info path_translated request_uri url self_url script_name
                  cookie Dump
                  raw_cookie request_method query_string Accept user_agent remote_host content_type
                  remote_addr referer server_name server_software server_port server_protocol virtual_port
                  virtual_host remote_ident auth_type http append
                  save_parameters restore_parameters param_fetch
                  remote_user user_name header redirect import_names put
                  Delete Delete_all url_param cgi_error/
        ],
        'ssl'     => [qw/https/],
        'cgi-lib' => [qw/ReadParse PrintHeader HtmlTop HtmlBot SplitParam Vars/],
        'html'    => [
                qw/h1 h2 h3 h4 h5 h6 p br hr ol ul li dl dt dd menu code var strong em tt u i b blockquote pre img a address cite samp dfn html head base body Link nextid title meta kbd start_html end_html input Select option comment charset escapeHTML div table caption th td TR Tr sup Sub strike applet Param embed basefont style span layer ilayer font frameset frame script small big Area Map abbr acronym bdo col colgroup del fieldset iframe ins label legend noframes noscript object optgroup Q thead tbody tfoot blink fontsize center/
        ],
        'standard' => [
                qw/h1 h2 h3 h4 h5 h6 p br hr ol ul li dl dt dd menu code var strong em tt u i b blockquote pre img a address cite samp dfn html head base body Link nextid title meta kbd start_html end_html input Select option comment charset escapeHTML div table caption th td TR Tr sup Sub strike applet Param embed basefont style span layer ilayer font frameset frame script small big Area Map abbr acronym bdo col colgroup del fieldset iframe ins label legend noframes noscript object optgroup Q thead tbody tfoot textfield textarea filefield password_field hidden checkbox checkbox_group
                  submit reset defaults radio_group popup_menu button autoEscape
                  scrolling_list image_button start_form end_form startform endform
                  start_multipart_form end_multipart_form isindex tmpFileName uploadInfo URL_ENCODED MULTIPART param upload path_info path_translated request_uri url self_url script_name
                  cookie Dump
                  raw_cookie request_method query_string Accept user_agent remote_host content_type
                  remote_addr referer server_name server_software server_port server_protocol virtual_port
                  virtual_host remote_ident auth_type http append
                  save_parameters restore_parameters param_fetch
                  remote_user user_name header redirect import_names put
                  Delete Delete_all url_param cgi_error/
        ],
        'push' => [qw/multipart_init multipart_start multipart_end multipart_final/],
        'all'  => [
        qw/h1 h2 h3 h4 h5 h6 p br hr ol ul li dl dt dd menu code var strong em tt u i b blockquote pre img a address cite samp dfn html head base body Link nextid title meta kbd start_html end_html input Select option comment charset escapeHTML div table caption th td TR Tr sup Sub strike applet Param embed basefont style span layer ilayer font frameset frame script small big Area Map abbr acronym bdo col colgroup del fieldset iframe ins label legend noframes noscript object optgroup Q thead tbody tfoot blink fontsize center textfield textarea filefield password_field hidden checkbox checkbox_group submit reset defaults radio_group popup_menu button autoEscape scrolling_list image_button start_form end_form startform endform start_multipart_form end_multipart_form isindex tmpFileName uploadInfo URL_ENCODED MULTIPART param upload path_info path_translated request_uri url self_url script_name cookie Dump raw_cookie request_method query_string Accept user_agent remote_host content_type remote_addr referer server_name server_software server_port server_protocol virtual_port virtual_host remote_ident auth_type http append save_parameters restore_parameters param_fetch remote_user user_name header redirect import_names put Delete Delete_all url_param cgi_error ReadParse PrintHeader HtmlTop HtmlBot SplitParam Vars  $ACCEPT_LANGUAGE  translate init session createSession $params clearSession $qy sessionValidity includeAction include/
        ],
        'lze' => [qw/$ACCEPT_LANGUAGE translate init session createSession $params clearSession $qy include sessionValidity includeAction/],

);

=head1 NAME

CGI::CMS - Content Managment System that runs under mod_perl and and as cgi script.

=head1 SYNOPSIS

use CGI::CMS;

=head1 DESCRIPTION

CGI::CMS is a CGI subclass, This Module is mainly written for L<CGI::CMS::GUI>.

But you can it also use standalone.

Take a look in example directory.

=head2 EXPORT

export_ok:

$ACCEPT_LANGUAGE translate init session createSession $params clearSession $qy include sessionValidity includeAction 


export tags:
lze: $ACCEPT_LANGUAGE translate init session createSession $params clearSession $qy include sessionValidity includeAction

and all export tags from L<CGI.pm>

=head1 Public

=head2 new()

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        return $self;
}

=head2 init()

        init("/srv/www/cgi-bin/config/settings.pl");

        default: /srv/www/cgi-bin

=cut

sub init {
        my ($self, @p) = getSelf(@_);
        my $settingfile = $p[0] ? $p[0] : $defaultconfig;
        loadSettings($settingfile);
        *settings = \$CGI::CMS::Settings::settings;
        loadTranslate($settings->{translate});
        *lng = \$CGI::CMS::Translate::lang;
        loadSession($settings->{session});
        *qy = \$CGI::CMS::Session::session;
        loadActions($settings->{actions});
        *actions = \$CGI::CMS::Actions::actions;
}

=head2 include

        %vars = (sub => 'main','file' => "fo.pl");

        $qstring = createSession(\%vars);

        include($qstring); # in void context param('include') will be used.

=cut

sub include {
        my ($self, @p) = getSelf(@_);
        my $qstring = $p[0] ? $p[0] : param('include') ? param('include')  : 0;
        CGI::upload_hook(\&hook);
        if(defined $qstring) {
                session($qstring);
                if(defined $params->{file} && defined $params->{sub}) {
                        if(-e $params->{file}) {
                                do("$params->{file}");
                                eval($params->{sub}) if $params->{sub} ne 'main';
                                warn $@ if($@);
                        } else {
                                do("$actions->{$settings->{defaultAction}}{file}");
                                eval($actions->{$settings->{defaultAction}}{sub}) if $actions->{$settings->{defaultAction}}{sub} ne 'main';
                                warn $@ if($@);
                        }
                }
        }
}

=head2 includeAction

        includeAction('welcome');

see L<CGI::CMS::Actions>

=cut

sub includeAction {
        my ($self, @p) = getSelf(@_);
        my $action = param('action') ? param('action') : $p[0] ? $p[0] : 0;
        CGI::upload_hook(\&hook);
        if(defined $actions->{$action}) {
                if(defined $actions->{$action}{file} && defined $actions->{$action}{sub}) {
                        if(-e $params->{file}) {
                                do("$settings->{cgi}{bin}/Content/$actions->{$action}{file}");
                                eval($actions->{$action}{sub}) if $actions->{$action}{sub} ne 'main';
                                warn $@ if($@);
                        } else {
                                do("$settings->{cgi}{bin}/Content/$actions->{$settings->{defaultAction}}{file}");
                                eval($actions->{$settings->{defaultAction}}{sub}) if $actions->{$settings->{defaultAction}}{sub} ne 'main';
                                warn $@ if($@);
                        }
                }
        }
}

=head2 createSession

        Secure your Session (or simple store session informations);

        my %vars = (first => 'query', secondly => "Jo");

        my $qstring = createSession(\%vars);

        *params= \$CGI::CMS::params;

        session($qstring);

        print $params->{first};


=cut

sub createSession {
        my ($self, @p) = getSelf(@_);
        my $par = shift @p;
        $user = $par->{user} ? $par->{user} : 'guest';
        my $ip   = $self->remote_addr();
        my $time = time();
        use MD5;
        my $md5 = new MD5;
        $md5->add($user);
        $md5->add($time);
        $md5->add($ip);
        my $fingerprint = $md5->hexdigest();

        foreach my $key (sort(keys %{$par})) {
                $qy->{$user}{$fingerprint}{$key} = $par->{$key};
                $params->{$key} = $par->{$key};
        }
        $qy->{$user}{$fingerprint}{timestamp} = time();
        saveSession($settings->{session});
        return $fingerprint;
}

=head2 session

        $qstring = session(\%vars);

        session($qstring);

        print $params->{'key'};

=cut

#################################### session###################################################################
# Diese Funktion lädt die Parameter die mit createSession erzeugt wurden.                                     #
# Als parameter erwartet Sie den wert den createSession zurückgegeben hat:                                    #
# Im Void Kontext wird param('include') benutzt.                                                                # ###############################################################################################################

sub session {
        my ($self, @p) = getSelf(@_);
        if(ref($p[0]) eq 'HASH') {
                $self->createSession(@p);
        } else {
                my $param = param('include') ? param('include') : shift @p;
                $user = 'guest';
                foreach my $key (sort(keys %{$qy->{$user}{$param}})) {
                        $params->{$key} = $qy->{$user}{$param}{$key};
                }
                $params->{session_id} = $param;
        }

        #delete $qy->{$user}{$param};
        #saveSession($settings->{session});
}

=head2 clearSession

delete old sessions. Delete all session older then 120 sec.

=cut

sub clearSession {
        foreach my $ua (keys %{$qy}) {
                foreach my $entry (keys %{$qy->{$ua}}) {
                        my $t = $qy->{$ua}{$entry}{timestamp} ? time()- $qy->{$ua}{$entry}{timestamp} : time();
                        delete $qy->{$ua}{$entry} if($t > $hold);
                }
        }
        saveSession($settings->{session});
}

=head2 sessionValidity()

set the session Validity in seconds in scalar context:

        sessionValidity(120); #120is the dafault value

or get it in void context:

        $time = sessionValidity();

=cut

sub sessionValidity {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0] and $p[0] =~ /(\d+)/) {
                $hold = $1;
        } else {
                return $hold;
        }
}

=head2 translate()

        translate(key);

see L<CGI::CMS::Translate>
 
=cut

sub translate {
        my ($self, @p) = getSelf(@_);
        my $key = lc $p[0];
        my @a   = split(/,/, defined $ENV{HTTP_ACCEPT_LANGUAGE} ? $ENV{HTTP_ACCEPT_LANGUAGE} : 'de,en');
        my $i   = 0;
        while($i <= $#a) {
                $a[$i] =~ s/(\w\w).*/$1/;
                if(defined $lng->{$a[$i]}{$key}) {
                        $ACCEPT_LANGUAGE = $a[$i];
                        return $lng->{$a[$i]}{$key};
                }
                $i++;
                }
#                 warn $p[0];
        return $p[0];
}

=head1 Private

=head2 hook

used by include and includeAction.

=cut

$uplod_bytes = 0;

sub hook {
        my ($self, @p) = getSelf(@_);
        my ($filename, $buffer, $bytes_read, $data) = @p;
        use Symbol;
        my $fh = gensym();
        if($uplod_bytes <= $settings->{uploads}{maxlength}) {
                require bytes;
                $uplod_bytes += bytes::length($buffer);
        } else {
                $upload_error = 1;
                warn 'To big upload :', $filename, $/;
        }
}

=head2 getSelf()

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'CGI::CMS');
        return (defined($_[0]) && (ref($_[0]) eq 'CGI::CMS' || UNIVERSAL::isa($_[0], 'CGI::CMS'))) ? @_ : ($CGI::CMS::DefaultClass->new, @_);
}

=head2 see Also

L<CGI> L<CGI::CMS::GUI> L<CGI::CMS::Actions> L<CGI::CMS::Translate> L<CGI::CMS::Settings> L<CGI::CMS::Config>

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

