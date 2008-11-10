package CGI::CMS::GUI;
use strict;
use warnings;
no warnings "uninitialized";
use DBI::Library::Database qw(:all);
use CGI::CMS::Main qw(:all);
use CGI::QuickFormR;
use HTML::TabWidget qw(:all);
use HTML::Window qw(:all);
use HTML::Menu::Pages;
use CGI::CMS qw(:all :lze :cgi-lib);
use HTML::Menu::TreeView qw(:all);
use HTML::Entities;
use HTML::Editor;
use HTML::Editor::BBCODE;
use URI::Escape;
use CGI::CMS::Settings;
use CGI::CMS::Translate;
use CGI::CMS::Config;
use CGI::CMS::Session;
use CGI::CMS::Actions;
use Encode;
use Fcntl qw(:flock);
use Symbol;

require Exporter;
use vars qw(
    $m_hrParams
    $m_hrAct
    $m_hrAction
    $m_hrParams
    $m_hrAct
    $m_hrAction
    $m_nEnd
    $ACCEPT_LANGUAGE
    $m_nUplod_bytes
    $m_oCgi
    $DefaultClass
    $m_oDatabase
    @EXPORT
    $m_sFile
    @ISA
    $m_hrSettings
    $m_nRight
    $m_sSid
    $m_sStyle
    $m_nSize
    $m_sSub
    $m_sTitle
    $m_bUpload_error
    $m_sUser
    $m_hrLng
    @m_aTree
    @m_aT1
    $m_dbh
    @m_aCookies
    $m_sContent
    $m_bMod_perl
    $m_hrSettings
    $m_nRight
    $m_sSid
    $m_sStyle
    $m_nSize
    $m_sSub
    $m_sTitle
    $m_bUpload_error
    $m_sUser
    $m_nStart
    $m_hrLng
    @m_aTree
    @m_aT1
    $m_dbh
    @m_aCookies
    $m_sContent
    $m_sCurrentDb
    $m_sCurrentHost
    $m_sCurrentUser
    $m_sCurrentPass
    %m_hUniq
);
@CGI::CMS::GUI::EXPORT
    = qw(action ContentHeader Body maxlength openFile ChangeDb action Unique);
@ISA = qw(Exporter CGI::CMS);

$CGI::CMS::GUI::VERSION = '0.37';
$m_bMod_perl = ( $ENV{MOD_PERL} ) ? 1 : 0;

local $^W = 0;

=head1 NAME

CGI::CMS::GUI - CGI::CMS user front end

=head1 SYNOPSIS

        use CGI::CMS::GUI;

        Body("config/settings.pl");


=head2 EXPORT

        action Body maxlength openFile

=cut

=head2 ContentHeader()

     ContentHeader("/path/to/your/settings.pl");

=cut

sub ContentHeader {
    my $m_hrSettingsfile = shift;
    init($m_hrSettingsfile);
    loadActions( $m_hrSettings->{actions} );
    *m_hrAction  = \$CGI::CMS::Actions::actions;
    $m_oDatabase = new DBI::Library::Database();
    $m_oDatabase->rewrite( $m_hrSettings->{cgi}{mod_rewrite} );
    $m_oDatabase->serverName( $m_hrSettings->{cgi}{serverName} );
    $m_oDatabase->floodtime( $m_hrSettings->{floodtime} );
    $m_dbh = $m_oDatabase->initDB(
        {   name     => $m_hrSettings->{database}{name},
            host     => $m_hrSettings->{database}{host},
            user     => $m_hrSettings->{database}{user},
            password => $m_hrSettings->{database}{password},
        }
    );
    $m_sCurrentDb
        = param('m_ChangeCurrentDb')
        ? param('m_ChangeCurrentDb')
        : $m_hrSettings->{database}{CurrentDb};
    $m_hrAction
        = param('action')
        ? param('action')
        : $m_hrSettings->{defaultAction};
    $m_hrAction
        = ( $m_hrAction =~ /^(\w{3,50})$/ )
        ? $1
        : $m_hrSettings->{defaultAction};

    $m_sCurrentHost
        = param('m_shost')
        ? param('m_shost')
        : $m_hrSettings->{database}{CurrentHost};
    $m_sCurrentUser
        = param('m_suser')
        ? param('m_suser')
        : $m_hrSettings->{database}{CurrentUser};
    $m_sCurrentPass
        = param('m_spass')
        ? param('m_spass')
        : $m_hrSettings->{database}{CurrentPass};

    if( param('m_ChangeCurrentDb') ) {
        $m_hrSettings->{database}{CurrentDb}   = $m_sCurrentDb;
        $m_hrSettings->{database}{CurrentHost} = $m_sCurrentHost;
        $m_hrSettings->{database}{CurrentUser} = $m_sCurrentUser;
        $m_hrSettings->{database}{CurrentPass} = $m_sCurrentPass;
        $m_hrAction                            = 'ShowTables';
        saveSettings($m_hrSettingsfile);
    }
    my $cookiepath = $m_hrSettings->{cgi}{cookiePath};

    $m_nSize
        = cookie( -name => 'size' )
        ? cookie( -name => 'size' )
        : $m_hrSettings->{size};

    if( param('size') ) {
        $m_nSize = param('size') =~ /(16|22)/ ? $1 : $m_nSize;
    }
    size($m_nSize);
    my $cook = cookie(
        -name    => 'size',
        -value   => "$m_nSize",
        -expires => '+1y',
        -path    => "$cookiepath"
    );
    push @m_aCookies, $cook;
    undef $m_sSid;

    if( $m_hrAction eq 'rss' ) {
        print $m_oDatabase->rss( "news", 0 );
    } else {
        if( $m_hrAction eq 'logout' ) {
            my $cookie = cookie(
                -name    => 'sid',
                -value   => "",
                -expires => '-1d',
                -path    => "$cookiepath"
            );
            push @m_aCookies, $cookie;
            print header( -cookie => [@m_aCookies] );
            $m_sUser = 'guest';
            $m_sSid  = '123';
        } elsif ( $m_hrAction eq 'login' ) {
            my $ip = remote_addr();
            my $u  = param('user');
            my $p  = param('pass');
            if( defined $u && defined $p && defined $ip ) {
                use MD5;
                my $md5 = new MD5;
                $md5->add($u);
                $md5->add($p);
                my $cyrptpass = $md5->hexdigest();
                if( $m_oDatabase->checkPass( $u, $cyrptpass ) ) {
                    $m_sSid = $m_oDatabase->setSid( $u, $p, $ip );
                    my $cookie = cookie(
                        -name    => 'sid',
                        -value   => "$m_sSid",
                        -path    => "$cookiepath",
                        -expires => '+1y'
                    );
                    push @m_aCookies, $cookie;
                    print header( -cookie => [@m_aCookies] );
                } else {
                    print header( -cookie => [@m_aCookies] );
                    print translate("wrongpass"), '&#160;',
                        a(
                        {   href  => "$ENV{SCRIPT_NAME}?action=lostpass",
                            class => "treeviewLink2"
                        },
                        translate("lostpass")
                        );
                }
            } else {
                print header( -cookie => [@m_aCookies] );
            }
        } else {
            $m_sSid
                = cookie( -name => 'sid' ) ? cookie( -name => 'sid' ) : '123';
            print header( -cookie => [@m_aCookies] );
        }

    }
}

=head2 Body()

     Body();

=cut

sub Body {

    $m_sStyle = $m_hrSettings->{cgi}{style};
    $m_sUser
        = defined $m_oDatabase->getName($m_sSid)
        ? $m_oDatabase->getName($m_sSid)
        : 'guest';
    $m_nStart = param('von') ? param('von') : 0;
    $m_nStart = ( $m_nStart =~ /^(\d+)$/ ) ? $1 : 0;

    my $newslength = $m_oDatabase->tableLength( 'news', $m_nRight );
    $m_nEnd
        = param('bis')        ? param('bis')
        : ( $newslength > 9 ) ? 10
        :                       $newslength;
    $m_nEnd = ( $m_nEnd =~ /^(\d+)$/ ) ? $1 : 0;

    if( $m_nStart < 0 ) {
        $m_hrAction = 'exploit';
        $m_nStart   = 0;
        $m_nEnd     = $newslength;
    }
    if( param('include') ) {
        session();
        $m_hrAct = $m_hrParams;
    } else {
        $m_hrAct = $m_oDatabase->getAction($m_hrAction);
    }
    $m_hrAct
        = defined $m_hrAct
        ? $m_hrAct
        : $m_oDatabase->getAction( $m_hrSettings->{'defaultAction'} );
    $m_sTitle = $m_hrAct->{'title'};
    $m_sFile  = $m_hrAct->{'file'};
    $m_sSub   = $m_hrAct->{'sub'};
    $m_nRight
        = $m_oDatabase->userright($m_sUser)
        ? $m_oDatabase->userright($m_sUser)
        : 0;

    my $logIn;
    if( $m_sUser eq 'guest' ) {
        my $link
            = $m_hrSettings->{cgi}{mod_rewrite}
            ? "/reg.html"
            : "$ENV{SCRIPT_NAME}?action=reg";
        my %vars = (
            user   => 'guest',
            action => 'login',
        );
        my $qstring  = createSession( \%vars );
        my $register = translate('register');

        #todo template
        $logIn = qq(
<form  action=""  target="_parent" method="post"  name="Login" onsubmit="return checkLogin()">
<input type="hidden" name="action" value="login"/>
<table align="left" border="0" cellpadding="2" cellspacing="0" summary="login" class="LoginLayout" width="*"><tr>
<td>Name:</td>
<td><input  type="text" id="user" name="user" value=""  maxlength="15" alt="" align="left"/></td>
<td>Password:</td>
<td><input style="" type="password" id="password" name="pass" value ="" maxlength="15" alt="" align="left"/></td><td><input type="submit"  name="submit" value="Login"  alt=""/></td><td><a  href="$link" class="menuLink">$register</a></td></tr></table>
</form>
);
    } else {
        my $lg
            = $m_hrSettings->{cgi}{mod_rewrite}
            ? '/logout.html'
            : "$ENV{SCRIPT_NAME}?action=logout";
        my $wlc = translate('welcome');
        my $lgo = translate('logout');
        $logIn = qq(
<table align="left" border="0" cellpadding="2" cellspacing="0" summary="contentHeader" class="contentHeader" width="*"><tr>
<td>$wlc,</td><td valign="top">$m_sUser</td></td><td><a class="menuLink" href="$lg">logout</a></td></tr></table>
);
    }
    my $z       = $m_nSize== 16 ? 'plus.png' : 'minus.png';
    my $newsize = $m_nSize== 16 ? 22         : 16;
    my $lk2
        = $m_hrSettings->{cgi}{mod_rewrite}
        ? "/news.html&amp;size=$newsize;"
        : "$ENV{SCRIPT_NAME}?action=news&amp;size=$newsize;";
    my $zoom
        = qq(<img src="/images/$z" style="cursor:pointer;" alt=""  border="0" onclick="location.href='$lk2'"/>);
    my %set = (
        zoom      => $zoom,
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        style     => $m_sStyle,
        title     => translate($m_sTitle),
        server    => $m_hrSettings->{cgi}{'serverName'},
        login     => $logIn,
        size      => $m_nSize,
        right     => $m_nRight,
        htmlright => $m_hrSettings->{htmlright},
        template  => 'blog.htm'
    );
    initMain( \%set );
    $m_sContent .= Header();
    $m_sContent
        .= '<table align="center" border="0" cellpadding="0" cellspacing="0" summary="contentLayout"  class="contentLayout" width="100%"><tr>';

    if( $m_hrSettings->{sidebar}{left} ) {
        $m_sContent .= '<td  valign="top" class="leftSidebar">';
        my @lboxes
            = $m_oDatabase->fetch_AoH(
            "select * from box where `position` = 'left' && `right` <= '$m_nRight'"
            );
        $m_sContent
            .= '<table  border="0" cellpadding="0" cellspacing="0" summary="contentLayout" class="contentLayout" width="100%">';
        foreach ( my $i = 0; $i <= $#lboxes; $i++ ) {
            do("$m_hrSettings->{cgi}{bin}/Sidebar/$lboxes[$i]->{file}");
            warn "Error : $@ " if($@);
        }
        if( defined $m_hrAct->{box} ) {
            my @boxes = split /;/, $m_hrAct->{box};
            foreach my $box (@boxes) {
                my $bx
                    = $m_oDatabase->fetch_hashref(
                    "select * from box where `dynamic` = 'left' && `file` = '$box.pl' && `right` <= '$m_nRight'"
                    );
                do("$m_hrSettings->{cgi}{bin}/Sidebar/$bx->{file}")
                    if( defined $bx->{file}
                    && -e "$m_hrSettings->{cgi}{bin}/Sidebar/$bx->{file}" );
                warn "Error : $@ " if($@);
            }
        }
        $m_sContent .= '</table>';

        $m_sContent .= '</td>';
    }
    $m_sContent .= '<td align="center" valign="top" class="content">';
    my %parameter = (
        path        => "$m_hrSettings->{cgi}{bin}/templates/",
        style       => $m_sStyle,
        action      => $m_hrAction,
        file        => $m_sFile,
        right       => $m_nRight,
        mod_rewrite => $m_hrSettings->{cgi}{mod_rewrite},
        template    => 'lzetabwidget.htm',
        action      => $m_hrAction,
        scriptname  => $ENV{SCRIPT_NAME},
    );
    my $sth
        = $m_dbh->prepare(
        "select title,action,src from `topnavigation` where `right` <= $m_nRight"
        );
    $sth->execute() or warn $m_dbh->errstr;
    my $hasCurrentlink = 0;

    while( my @a = $sth->fetchrow_array() ) {
        my $fm
            = ( $m_hrSettings->{cgi}{mod_rewrite} )
            ? "/$a[1].html"
            : "$ENV{SCRIPT_NAME}?action=$a[1]";
        my $nm = 'link';
        if( "$a[1].pl" eq $m_sFile ) {
            $nm             = 'currentLink';
            $hasCurrentlink = 1;
        }
        push @{ $parameter{anchors} },
            {
            class => $nm,
            style => $m_sStyle,
            text  => translate( $a[0] ),
            href  => $fm,
            src   => $a[2],
            title => translate( $a[0] )
            };
    }
    unless ($hasCurrentlink) {
        if( param('include') ) {
            push @{ $parameter{anchors} },
                {
                text  => translate( $m_hrAct->{title} ),
                class => 'currentLink',
                style => $m_sStyle,
                href  => "javascript:void(0)",
                title => translate( $m_hrAct->{title} )
                };
        } else {
            $sth = $m_dbh->prepare(
                "select title from actions where `action` =  ?");
            $sth->execute($m_hrAction) or warn $m_dbh->errstr;
            my @a1 = $sth->fetchrow_array();
            push @{ $parameter{anchors} },
                {
                text  => translate( $a1[0] ),
                class => 'currentLink',
                style => $m_sStyle,
                href  => 'javascript:void(0)',
                title => translate( $a1[0] )
                };
        }
    }
    push @{ $parameter{anchors} },
        {
        text  => translate('Action'),
        href  => 'javascript:void(0)',
        id    => 'dropdownLink',
        class => 'adminlink',
        title => translate('Action'),
        }
        if( $m_nRight >= 5 );
    push @{ $parameter{anchors} },
        {
        text  => translate('showwindow'),
        href  => 'javascript:displayWindows();',
        class => 'javaScriptLink',
        title => translate('showwindow')
        };
    $m_sContent .= Menu( \%parameter );

    $m_sContent .= tabwidgetHeader();
    if( $m_nRight >= $m_hrAct->{right} ) {
        if( defined $m_sFile and defined $m_sSub ) {
            if( param('include') ) {
                my $qstring = param('include') ? param('include') : 0;
                CGI::upload_hook( \&hook );
                if( defined $qstring ) {
                    session($qstring);
                    if(    defined $m_hrParams->{file}
                        && defined $m_hrParams->{sub} )
                    {
                        if( -e $m_hrParams->{file} ) {
                            do("$m_hrParams->{file}");
                            eval( $m_hrParams->{sub} )
                                if $m_hrParams->{sub} ne 'main';
                            warn $@ if($@);
                        } else {
                            do("$m_hrSettings->{cgi}{bin}/Content/exploit.pl"
                            );
                            warn $@ if($@);
                        }
                    }
                }
            } else {
                do("$m_hrSettings->{cgi}{bin}/Content/$m_sFile");
                eval($m_sSub) if $m_sSub ne 'main';
                warn "Error : $@ " if($@);
                $m_dbh = $m_oDatabase->initDB(
                    {   name     => $m_hrSettings->{database}{name},
                        host     => $m_hrSettings->{database}{host},
                        user     => $m_hrSettings->{database}{user},
                        password => $m_hrSettings->{database}{password},
                    }
                );
            }
        } else {
            do("$m_hrSettings->{cgi}{bin}/Content/news.pl");
            warn "Error : $@ " if($@);
        }
    } else {
        do("$m_hrSettings->{cgi}{bin}/Content/exploit.pl");
        warn $@ if($@);
    }
    $m_sContent .= br();
    $m_sContent .= tabwidgetFooter();
    $m_sContent .= '<br/></td>';
    if( $m_hrSettings->{sidebar}{right} ) {
        $m_sContent .= '<td valign="top" class="rightSidebar">';
        $m_sContent
            .= '<table border="0" cellpadding="0" cellspacing="0" summary="contentLayout" class="contentLayout" width="100%">';
        my @rboxes
            = $m_oDatabase->fetch_AoH(
            "select * from box where `position` = 'right' && `right` <= ? ",
            $m_nRight );
        for( my $i = 0; $i <= $#rboxes; $i++ ) {
            do("$m_hrSettings->{cgi}{bin}/Sidebar/$rboxes[$i]->{file}");
            warn "Error : $@ " if($@);
        }
        if( defined $m_hrAct->{box} ) {
            my @boxes = split /;/, $m_hrAct->{box};
            foreach my $box (@boxes) {
                my $bx = $m_oDatabase->fetch_hashref(
                    "select * from box where `dynamic` = 'right' && `file` = ? && `right` <= ? ",
                    "$box.pl", $m_nRight
                );
                do("$m_hrSettings->{cgi}{bin}/Sidebar/$bx->{file}")
                    if( defined $bx->{file}
                    && -e "$m_hrSettings->{cgi}{bin}/Sidebar/$bx->{file}" );
                warn "Error : $@ " if($@);
            }
        }
        $m_sContent .= '</table>';
        $m_sContent .= '</td>';
    }
    $m_sContent .= '</tr></table>';
    clearSession();
    $m_sContent .= Footer();
    return $m_sContent;
}

=head2  maxlength()

     maxlength($length ,\$text);

=cut

sub maxlength {
    my $maxWidth = shift;
    ++$maxWidth;
    my $txt = shift;
    if( length($$txt) > $maxWidth ) {
        my $maxLength = $maxWidth;
        my $i++;
        while( $i < length($$txt) ) {
            if( substr( $$txt, $i, 1 ) eq "<" ) {
                $maxLength = $maxWidth;
                do { $i++ }
                    while( substr( $$txt, $i, 1 ) ne ">"
                    and $i < length($$txt) );
            }
            $maxLength
                = ( substr( $$txt, $i, 1 ) =~ /\S/ )
                ? --$maxLength
                : $maxWidth;
            if( $maxLength eq 0 ) {
                substr( $$txt, $i, 1 ) = " ";
                $maxLength = $maxWidth;
            }
            $i++;
        }
    }
}

=head2 openFile

        my $m_sFile = openFile("filename");

=cut

sub openFile {
    my $m_sFile = shift;
    if( -e $m_sFile ) {
        use Fcntl qw(:flock);
        use Symbol;
        my $fh = gensym;
        open $fh, $m_sFile or warn "$!: $m_sFile $/";
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

        $m_sContent .= action{\%action);

=cut

sub action {
    my $hash     = shift;
    my $m_sTitle = $hash->{title} if( defined $hash->{title} );
    my $src      = $hash->{src} if( defined $hash->{src} );
    my $location = $hash->{location} if( defined $hash->{location} );
    my $m_sStyle = ( defined $hash->{style} ) ? $hash->{style} : $m_sStyle;
    return
        qq(<table align ="left" border ="0" cellpadding ="0" cellspacing="0" summary="layoutMenuItem"><tr><td valign ="middle"><img src="/style/$m_sStyle/buttons/$src" width="20" height="20" border="0" alt="" title="$m_sTitle" style="cursor:pointer;font-size:14px;vertical-align:bottom;"/></td><td><a class="link" href="$location"  style='font-size:14px;vertical-align:bottom;'>$m_sTitle</a></td></tr></table>);
}

=head2 ChangeDb



        my %db = {

                name => '',

                host   => '',

                user => '',

                password => '',

       };

       ChangeDb(\%action);

=cut

sub ChangeDb {
    my $hash = shift;
    my $m_sTitle = $hash->{title} if( defined $hash->{title} );
    $m_dbh = $m_oDatabase->initDB(
        {   name     => $hash->{name},
            host     => $hash->{host},
            user     => $hash->{user},
            password => $hash->{password},
        }
    );
}

=head2 Unique()

        Gibt einen eindeutigen schlüssel zurück.

=cut

sub Unique {
    my $unic;
    do {
        $unic = int( rand(1000000) );
    } while( defined $m_hUniq{$unic} );
    $m_hUniq{$unic} = 1;
    return $unic;
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

