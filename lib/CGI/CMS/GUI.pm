package CGI::CMS::GUI;
use strict;
use warnings;
use DBI::Library::Database qw(:all);
use CGI::CMS::Main qw(:all);
use HTML::TabWidget qw(:all);
use HTML::Window qw(:all);
use HTML::Menu::Pages;
use CGI::CMS qw(:all :lze :cgi-lib);
use HTML::Menu::TreeView qw(:all);
use HTML::Entities;
use HTML::Editor;
use HTML::Editor::BBCODE;
use URI::Escape;

require Exporter;
use vars qw(
  $params
  $query
  $act
  $action
  $bis
  $ACCEPT_LANGUAGE
  $uplod_bytes
  $cgi
  $DefaultClass
  $database
  @EXPORT
  $file
  @ISA
  $language
  $mod_perl
  $settings
  $right
  $sid
  $style
  $size
  $sub
  $title
  $upload_error
  $user
  $von
  $lang
  @tree
  @t1
  $dbh
  @cookies
);
@CGI::CMS::GUI::EXPORT = qw(action Body maxlength openFile );
@ISA                   = qw(Exporter CGI::CMS);

$CGI::CMS::GUI::VERSION = '0.33';
$mod_perl = ($ENV{MOD_PERL}) ? 1 : 0;

local $^W = 0;

=head1 NAME

CGI::CMS::GUI - CGI::CMS user front end

=head1 SYNOPSIS

        use CGI::CMS::GUI;

        Body("config/settings.pl");


=head2 EXPORT

        action Body maxlength openFile

=cut

=head2 Body()

     Body("/path/to/your/settings.pl");

=cut

sub Body {
        my $settingfile = shift;
        init($settingfile);
        *settings = \$CGI::CMS::settings;
        $database = new DBI::Library::Database();
        $database->rewrite($settings->{cgi}{mod_rewrite});
        $database->serverName($settings->{cgi}{serverName});
        $database->floodtime($settings->{floodtime});
        $dbh = $database->initDB({name => $settings->{database}{name}, host => $settings->{database}{host}, user => $settings->{database}{user}, password => $settings->{database}{password},});
        my $cookiepath = $settings->{cgi}{cookiePath};
        $action = param('action') ? param('action') : lc($settings->{defaultAction});
        $action = ($action =~ /^(\w{3,50})$/) ? lc($1) : lc($settings->{defaultAction});
        $size = cookie(-name => 'size') ? cookie(-name => 'size') : $settings->{size};

        if(param('size')) {
                $size = param('size') =~ /(16|22)/ ? $1 : $size;
        }
        size($size);
        my $cook = cookie(-name => 'size', -value => "$size", -expires => '+1y', -path => "$cookiepath");
        push @cookies, $cook;

        if($action eq 'rss') {
                print $database->rss("news", 0);
        } else {
                if($action eq 'logout') {
                        my $cookie = cookie(-name => 'sid', -value => "", -expires => '-1d', -path => "$cookiepath");
                        push @cookies, $cookie;
                        print header(-cookie => [@cookies]);
                        $user = 'guest';
                        $sid  = undef;
                } elsif ($action eq 'login') {
                        my $ip = remote_addr();
                        my $u  = param('user');
                        my $p  = param('pass');
                        if(defined $u && defined $p && defined $ip) {
                                use MD5;
                                my $md5 = new MD5;
                                $md5->add($u);
                                $md5->add($p);
                                my $cyrptpass = $md5->hexdigest();
                                if($database->checkPass($u, $cyrptpass)) {
                                        $sid = $database->setSid($u, $p, $ip);
                                        my $cookie = cookie(-name => 'sid', -value => "$sid", -path => "$cookiepath", -expires => $settings->{cgi}{expires});
                                        push @cookies, $cookie;
                                        print header(-cookie => [@cookies]);
                                } else {
                                        print header(-cookie => [@cookies]);
                                        print translate("wrongpass"), '&#160;', a({href => "$ENV{SCRIPT_NAME}?action=lostpass", class => "treeviewLink2"}, translate("lostpass"));
                                }
                        } else {
                                print header(-cookie => [@cookies]);
                        }
                } else {
                        print header(-cookie => [@cookies]);
                        $sid = cookie(-name => 'sid') ? cookie(-name => 'sid') : '123';
                }
                $style = $settings->{cgi}{style};
                $sid   = '123' unless defined $sid;
                $user  = defined $database->getName($sid) ? $database->getName($sid) : "guest";
                $von   = param('von') ? param('von') : 0;
                $von   = ($von =~ /^(\d+)$/) ? $1 : 0;

                # andere tabellen angeben database.pl usw
                my $newslength = $database->tableLength("news", $right);
                $bis = param('bis') ? param('bis') : ($newslength > 9) ? 10 : $newslength;
                $bis = ($bis =~ /^(\d+)$/) ? $1 : 0;

                if($von < 0) {
                        $action = 'exploit';
                        $von    = 0;
                        $bis    = $newslength;
                }
                if(param('include')) {
                        session(param('include'));
                        $act = $params;
                } else {
                        $act = $database->getAction($action);

                }
                $act   = defined $act ? $act : $database->getAction($settings->{'defaultAction'});
                $title = $act->{'title'};
                $file  = $act->{'file'};
                $sub   = $act->{'sub'};
                $right = $database->userright($user);

                my $logIn;
                if($user eq 'guest') {
                        my $link = $settings->{cgi}{mod_rewrite} ? "/reg.html" : "$ENV{SCRIPT_NAME}?action=reg";
                        my %vars     = (user => 'guest', action => 'login',);
                        my $qstring  = createSession(\%vars);
                        my $register = translate('register');
                        $logIn =
                          qq(<table align="left" border="0" cellpadding="0" cellspacing="0" summary="contentHeader" width="*"><tr><td height="22"  style="vertical-align:top;"><form  action=""  target="_parent" method="post"  name="Login" onsubmit="return checkLogin()">&#160;Name:&#160;<input style="height:22px;" type="text" id="user" name="user" value="" size="10" maxlength="15" alt="" align="left"/>&#160;Password:&#160;<input type="hidden" name="action" value="login"/><input style="height:22px;" type="password" id="password" name="pass" value ="" size="10" maxlength="15" alt="" align="left"/>&#160;<input type="submit"  name="submit" value="Einloggen" size="10" maxlength="15" alt="Login" style="height:22px;"/></form></td><td  style="height:22px;vertical-align:top;">&#160;<a style="height:22px;vertical-align:top;" href="$link">$register</a></td></tr></table>);
                } else {
                        my $lg  = $settings->{cgi}{mod_rewrite} ? '/logout.html' : "$ENV{SCRIPT_NAME}?action=logout";
                        my $wlc = translate('welcome');
                        my $lgo = translate('logout');
                        $logIn = qq($wlc, $user <a  class="link" href="$lg">logout</a>);
                }
                my $z       = $size== 16                    ? 'plus.png'                      : 'minus.png';
                my $newsize = $size== 16                    ? 22                              : 16;
                my $lk2     = $settings->{cgi}{mod_rewrite} ? "/news.html&amp;size=$newsize;" : "$ENV{SCRIPT_NAME}?action=news&amp;size=$newsize;";
                my $zoom = qq(<img src="/images/$z" style="height:22px;width:22px;vertical-align:top;cursor:pointer;" height="22" width="22" alt="zoom"  border="0" onclick="location.href='$lk2'"/>);
                my %set = (
                           zoom      => $zoom,
                           path      => "$settings->{cgi}{bin}/templates",
                           style     => $style,
                           title     => translate($title),
                           server    => $settings->{cgi}{'serverName'},
                           login     => $logIn,
                           size      => $size,
                           right     => $right,
                           htmlright => $settings->{htmlright},
                           template  => 'blog.htm'
                );
                initMain(\%set);
                print Header();
                print '<table  align="center" border="0" cellpadding="5" cellspacing="5" summary="contentLayout"  width="100%"><tr>';

                if($settings->{sidebar}{left}) {
                        print '<td  valign="top" class="leftSidebar">';
                        my @lboxes = $database->fetch_AoH("select * from box where `position` = 'left' && `right` <= '$right'");
                        print '<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%"><tr><td></td></tr>';
                        foreach (my $i = 0 ; $i <= $#lboxes ; $i++) {
                                print '<br/>';
                                do("$settings->{cgi}{bin}/Sidebar/$lboxes[$i]->{file}");
                                warn "Error : $@ " if($@);
                                print '<br/>';
                        }
                        if(defined $act->{box}) {
                                my @boxes = split /;/, $act->{box};
                                foreach my $box (@boxes) {
                                        my $bx = $database->fetch_hashref("select * from box where `dynamic` = 'left' && `file` = '$box.pl' && `right` <= '$right'");
                                        do("$settings->{cgi}{bin}/Sidebar/$bx->{file}") if(defined $bx->{file} && -e "$settings->{cgi}{bin}/Sidebar/$bx->{file}");
                                        warn "Error : $@ " if($@);
                                }
                        }
                        print '</table>';

                        print '</td>';
                }
                print '<td align="center" valign="top" class="content">';
                my %parameter = (path => "$settings->{cgi}{bin}/templates/", style => $style, action => $action, file => $file, right => $right, mod_rewrite => $settings->{cgi}{mod_rewrite}, template => 'lzetabwidget.htm');
                my $sth = $dbh->prepare("select title,action,src from `topnavigation` where `right` <= $right");
                $sth->execute() or warn $dbh->errstr;
                my $hasCurrentlink = 0;

                while(my @a = $sth->fetchrow_array()) {
                        my $fm = ($settings->{cgi}{mod_rewrite}) ? "/$a[1].html" : "$ENV{SCRIPT_NAME}?action=$a[1]";
                        my $nm = 'link';
                        if("$a[1].pl" eq "$file") {
                                $nm             = 'currentLink';
                                $hasCurrentlink = 1;
                        }
                        push @{$parameter{anchors}}, {class => $nm, style => $style, text => translate($a[0]), href => $fm, src => $a[2], title => translate($a[0])};
                }
                unless ($hasCurrentlink) {
                        if(param('include')) {
                                push @{$parameter{anchors}}, {text => translate($act->{title}), class => 'currentLink', style => $style, href => "javascript:void", title => translate($act->{title})};
                        } else {
                                $sth = $dbh->prepare("select title from actions where `action` =  ?");
                                $sth->execute($action) or warn $dbh->errstr;
                                my @a1 = $sth->fetchrow_array();
                                push @{$parameter{anchors}}, {text => translate($a1[0]), class => 'currentLink', style => $style, href => 'javascript:void', title => translate($a1[0])};
                        }
                }
                push @{$parameter{anchors}}, {text => translate('showwindow'), href => "javascript:displayWindows();", class => 'javaScriptLink', title => translate('showwindow')};
                print Menu(\%parameter);
                print tabwidgetHeader();
                if($right >= $act->{right}) {
                        if(defined $file and defined $sub) {
                                if(param('include')) {
                                        my $qstring = param('include') ? param('include') : @_ ? @_ : 0;
                                        CGI::upload_hook(\&hook);
                                        if(defined $qstring) {
                                                session($qstring);
                                                if(defined $params->{file} && defined $params->{sub}) {
                                                        if(-e $params->{file}) {
                                                                do("$params->{file}");
                                                                eval($params->{sub}) if $params->{sub} ne 'main';
                                                                warn $@ if($@);
                                                        } else {
                                                                do("$settings->{cgi}{bin}/Content/exploit.pl");
                                                                warn $@ if($@);
                                                        }
                                                }
                                        }
                                } else {
                                        do("$settings->{cgi}{bin}/Content/$file");
                                        eval($sub) if $sub ne 'main';
                                        warn "Error : $@ " if($@);
                                }
                        } else {
                                do("$settings->{cgi}{bin}/Content/news.pl");
                                warn "Error : $@ " if($@);
                        }
                } else {
                        do("$settings->{cgi}{bin}/Content/exploit.pl");
                        warn $@ if($@);
                }
                print br();
                print tabwidgetFooter();
                print '<br/></td>';
                if($settings->{sidebar}{right}) {
                        print '<td valign="top" class="rightSidebar">';
                        print '<table border="0" cellpadding="0" cellspacing="10" summary="contentLayout"  width="100%"><tr><td></td></tr>';
                        my @rboxes = $database->fetch_AoH("select * from box where `position` = 'right' && `right` <= '$right'");
                        foreach (my $i = 0 ; $i <= $#rboxes ; $i++) {
                                do("$settings->{cgi}{bin}/Sidebar/$rboxes[$i]->{file}");
                                warn "Error : $@ " if($@);
                                print "<br/>";
                        }
                        if(defined $act->{box}) {
                                my @boxes = split /;/, $act->{box};
                                foreach my $box (@boxes) {
                                        my $bx = $database->fetch_hashref("select * from box where `dynamic` = 'right' && `file` = '$box.pl' && `right` <= '$right'");
                                        do("$settings->{cgi}{bin}/Sidebar/$bx->{file}") if(defined $bx->{file} && -e "$settings->{cgi}{bin}/Sidebar/$bx->{file}");
                                        warn "Error : $@ " if($@);
                                }
                        }
                        print '</table>';
                        print '</td>';
                }
                print '</tr></table>';
                clearSession();
                print Footer();
        }

}

=head2  maxlength()

     maxlength($length ,\$text);

=cut

sub maxlength {
        my $maxWidth = shift;
        ++$maxWidth;
        my $txt = shift;
        if(length($$txt) > $maxWidth) {
                my $maxLength = $maxWidth;
                my $i++;
                while($i < length($$txt)) {
                        if(substr($$txt, $i, 1) eq "<") {
                                $maxLength = $maxWidth;
                                do {$i++} while(substr($$txt, $i, 1) ne ">" and $i < length($$txt));
                        }
                        $maxLength = (substr($$txt, $i, 1) =~ /\S/) ? --$maxLength : $maxWidth;
                        if($maxLength eq 0) {
                                substr($$txt, $i, 1) = " ";
                                $maxLength = $maxWidth;
                        }
                        $i++;
                }
        }
}

=head2 openFile

        my $file = openFile("filename");

=cut

sub openFile {
        my $file = shift;
        if(-e $file) {
                use Fcntl qw(:flock);
                use Symbol;
                my $fh = gensym;
                open $fh, $file or warn "$!: $file $/";
                seek $fh, 0, 0;
                my @lines = <$fh>;
                close $fh;
                return "@lines";
        } else {
                warn "file exestiert nicht $/";
        }
}

=head2 action

        my %action = {

                title => '',

                src   => 'location',

                location => '',

                style => 'optional',

        };

        print action{\%action);

=cut

sub action {
        my $hash     = shift;
        my $title    = $hash->{title} if(defined $hash->{title});
        my $src      = $hash->{src} if(defined $hash->{src});
        my $location = $hash->{location} if(defined $hash->{location});
        my $style    = (defined $hash->{style}) ? $hash->{style} : $style;
        return
          qq(<table align ="left" border ="0" cellpadding ="0" cellspacing="0" summary="layoutMenuItem"><tr><td valign ="middle"><img onclick="location.href='$location'" src="/style/$style/buttons/$src" width="20" height="20" border="0" alt="" title="$title" style="cursor:pointer;font-size:14px;vertical-align:bottom;"/></td><td><a class="link" href="$location"  style='font-size:14px;vertical-align:bottom;'>$title</a></td></tr></table>);
}

=head1 SEE ALSO

L<CGI> L<CGI::CMS>
L<DBI> L<DBI::Library> L<DBI::Library::Database>
L<CGI::CMS::GUI::Main> L<HTML::TabWidget>
L<HTML::Window> L<HTML::Menu::Pages>
L<HTML::Menu::TreeView> L<HTML::Editor::BBCODE> L<HTML::LZE::Editor>

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

