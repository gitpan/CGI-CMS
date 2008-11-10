use vars qw($r);
use URI::Escape;
use HTML::Entities;
no warnings "uninitialized";

sub EditFile {
    my $name = defined param('name') ? param('name') : $m_hrAction;
    my @n = $m_oDatabase->fetch_array(
        "select file from `actions` where action=?", $name );
    OpenFile("$m_hrSettings->{cgi}{bin}/Content/$n[0]");
}

sub showDir {
    my $m_sSubfolder = param('subfolder') ? param('subfolder') : shift;

    $m_sSubfolder
        = defined $m_sSubfolder ? $m_sSubfolder : $m_hrSettings->{cgi}{bin};

    $m_sSubfolder =~ s?/$??g;
    my $links = $m_sSubfolder =~ ?^(.*/)[^/]+$? ? $1 : $m_sSubfolder;
    $links =~ s?//?/?g;

    my $elinks     = uri_escape($links);
    my $esubfolder = uri_escape($m_sSubfolder);
    $r = 0;

    my @t = readFiles( $m_sSubfolder, 0 );
    columns(
        a(  {   href =>
                    "$ENV{SCRIPT_NAME}?action=openFile&file=$esubfolder&sort=1",
                class => "treeviewLink$m_nSize"
            },
            'Name'
            )
            . '&#160;',
        a(  {   href =>
                    "$ENV{SCRIPT_NAME}?action=openFile&file=$esubfolder&byColumn=0",
                class => "treeviewLink$m_nSize"
            },
            'Size'
            )
            . '&#160;',
        a(  {   href =>
                    "$ENV{SCRIPT_NAME}?action=openFile&file=$esubfolder&byColumn=1",
                class => "treeviewLink$m_nSize"
            },
            'Permission'
            )
            . '&#160;',
        a(  {   href =>
                    "$ENV{SCRIPT_NAME}?action=openFile&file=$esubfolder&byColumn=2",
                class => "treeviewLink$m_nSize"
            },
            'Last Modified'
            )
            . '&#160;'
    );
    border(1);

    if( defined param('byColumn') ) {
        orderByColumn( param('byColumn') );
    } elsif ( param('sort') ) {
        sortTree(1);
    }

    my $hf        = "$ENV{SCRIPT_NAME}?action=openFile&file=$elinks";
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => "",
        server => $m_hrSettings->{serverName},
        id     => 'showDir',
        class  => 'min',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= div(
        { align => 'center' },
        a(  {   href  => $hf,
                class => "treeviewLink$m_nSize"
            },
            $links
            )
            . br()
            . a(
            {   href =>
                    "javascript:var a = prompt('Enter File Name');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=newFile&file='+encodeURIComponent(a)+'&dir=$esubfolder';",
                class => "treeviewLink$m_nSize"
            },
            "New File"
            )
            . '&#160;|&#160;'
            . a(
            {   href =>
                    "javascript:var a = prompt('Neues Verzeichnis');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=makeDir&file=$esubfolder&d='+encodeURIComponent(a);",
                class => "treeviewLink$m_nSize"
            },
            "New Directory"
            )
            . '&#160;|&#160;'
            . a(
            {   href =>
                    "javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$esubfolder&chmod='+encodeURIComponent(a);",
                class => "treeviewLink$m_nSize"
            },
            "Chmod"
            )
            . br()
            . Tree( \@t )
            . br()
            . $window->windowFooter()
    );
    border(0);

    sub readFiles {
        my @TREEVIEW;
        my $dir  = shift;
        my $edir = uri_escape($dir);
        my $rk   = shift;
        $r++ if($rk);
        if( -d "$dir" && -r "$dir" ) {
            opendir DIR, $dir or warn "files.pl sub readFiles: $dir $!";
            foreach my $d ( readdir(DIR) ) {
                my $fl = "$dir/$d";
                use File::stat;
                my $sb = stat($fl);
            TYPE: {
                    last TYPE if( $d =~ /^\.+$/ );
                    my $efl = uri_escape($fl);
                    my $href
                        = "$ENV{SCRIPT_NAME}?action=openFile&amp;file=$efl";
                    if( -d $fl ) {
                        push @TREEVIEW,
                            {
                            text    => $d,
                            href    => "$href/",
                            empty   => 1,
                            columns => [
                                sprintf( "%s",   $sb->size ),
                                sprintf( "%04o", $sb->mode & 07777 ),
                                sprintf( "%s",   scalar localtime $sb->mtime )
                            ],
                            addition =>
                                qq|<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr><td><a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$efl&chmod='+encodeURIComponent(a);">&#160;chmod</a></td><td><a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter File Name');location.href = '$ENV{SCRIPT_NAME}?action=newFile&file='+encodeURIComponent(a)+'&dir=$edir';"><img src="/style/$m_sStyle/$m_nSize/mimetypes/filenew.png" border="0" alt="new"/></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteFile&amp;file=$efl" onclick="return confirm('Realy delete ?')"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"/></a></td></td></tr></table>|
                            };
                        last TYPE;
                    }
                    if( -f $fl ) {
                        my $suffix = $d =~ /\.([^\.]+)$/ ? $1 : '';
                        push @TREEVIEW,
                            {
                            text    => "$d",
                            href    => "$href",
                            columns => [
                                sprintf( "%s",   $sb->size ),
                                sprintf( "%04o", $sb->mode & 07777 ),
                                sprintf( "%s",   scalar localtime $sb->mtime )
                            ],
                            addition =>
                                qq|<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr><td><a class="treeviewLink$m_nSize" href="javascript:var a = prompt('Enter Chmod: 0755');if(a != null )location.href = '$ENV{SCRIPT_NAME}?action=chmodFile&file=$efl&chmod='+encodeURIComponent(a);">&#160;chmod</a></td><td><a class="treeviewLink$m_nSize" href="$href"><img src="/style/$m_sStyle/$m_nSize/mimetypes/edit.png" border="0" alt="edit"/></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteFile&amp;file=$efl" onclick="return confirm('Realy delete ?')"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"/></a></td></tr></table>|,
                            image => (
                                -e "$m_hrSettings->{cgi}{DocumentRoot}/style/$m_sStyle/$m_nSize/mimetypes/$suffix.png"
                                ) ? "$suffix.png" : 'link.gif',
                            };
                    }
                }
            }
            $r = 0;
            return @TREEVIEW;
        }
    }
}

sub OpenFile {
    my $f = defined param('file') ? param('file') : shift;
    return unless defined $f;
SWITCH: {
        if( -d $f ) {
            &showDir($f);
            last SWITCH;
        }
        if( -T $f ) {
            $m_sContent .= qq(<div align="center">)
                . a( { -href => "javascript:history.back()" },
                translate('back') )
                . "</div>";
            &showEditor( "Edit File: $f<br/>", getFile($f), 'saveFile', $f );
            last SWITCH;
        }
        if( $f =~ /png|jpg|jpeg|gif$/ && $f =~ m~/srv/www/htdocs/(.*)$~ ) {
            $m_sContent
                .= br()
                . qq(<div align="center"><img alt="" src="/$1" align="center"/>)
                . br()
                . a( { -href => "javascript:history.back()" },
                translate('back') )
                . "</div>";
            last SWITCH;
        }
        $m_sContent
            .= br()
            . translate("UnsopportedFileType")
            . br()
            . a( { -href => "javascript:history.back()" },
            translate('back') );
    }
}

sub saveFile {
    my $txt     = param('txt');
    my $m_sFile = param('file');
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym();
    unless ( -d $m_sFile ) {
        open $fh, ">$m_sFile.bak"
            or warn "files.pl::saveFile $/ $! $/ $m_sFile $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $txt;
        close $fh;
        rename "$m_sFile.bak", $m_sFile
            or warn "files.pl::saveFile $/ $! $/"
            if( -e "$m_sFile.bak" );
        chmod( 0755, $m_sFile ) if( $m_sFile =~ ?\.pl? );
        showDir();
    } elsif ( defined param('title') && defined param('file') ) {
        my $sf = param('file') . '/' . param('title');
        open $fh, ">$sf.bak" or warn "files.pl::saveFile $/ $! $/ $sf $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $txt;
        close $fh;
        rename "$sf.bak", $sf
            or warn "files.pl::saveFile $/ $! $/"
            if( -e "$sf.bak" );
        showDir();
    }
}

sub showEditor {
    my $h = shift;
    my $t = shift;

    my $a         = shift;
    my $fi        = shift;
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => "",
        server => $m_hrSettings->{serverName},
        id     => 'showEditor',
        class  => 'min',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= qq(
<form action ="$ENV{SCRIPT_NAME}" method="post">
 <table cellspacing="5" cellpadding="0" border="0" align="center" summary="execSql" width="95%">
  <tbody>
   <tr>
      <td>$h</td>
    </tr>
    <tr><td><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;printButtons();</script></td></tr>
    <tr>
      <td>
       <textarea name="txt" id="txt" style="width:100%;height:640px;">$t</textarea>
      </td>
    </tr>
    <tr>
      <td align="right"><input type="submit" value="Save"/>
       <input type="hidden" value="$a" name="action"/>
       <input type="hidden" value="$fi" name="file"/>
      </td>
    </tr>
  </tbody>
</table>
</form>
);
    $m_sContent .= $window->windowFooter();
}

sub getFile {
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym;
    my $f  = shift;
    my $err;
    if( -f $f ) {
        open $fh, $f or $err = "$!: $f";
        seek $fh, 0, 0;
        my @lines = <$fh>;
        close $fh;
        return "@lines";
    } else {
        return $err;
    }
}

sub newFile {
    my $d = defined param('dir') ? param('dir') : '';
    my $m_sFile = param('file');
    unless ( -e $m_sFile ) {
        open( IN, ">$d/$m_sFile" ) or die $!;
        close IN;
        $m_sContent .= translate('newfileadded') if -e $m_sFile;
    } else {
        $m_sContent .= translate('fileExists ') if -e $m_sFile;
    }
    &showDir($d);
}

sub makeDir {
    my $d       = param('d');
    my $m_sFile = param('file');
    unless ( -d "$m_sFile/$d" ) {
        mkdir "$m_sFile/$d";
        $m_sContent .= translate('newfileadded') if -d $m_sFile;
    } else {
        $m_sContent .= translate('fileExists');
    }

    &showDir($m_sFile);
}

sub deleteFile {
    my $m_sFile = param('file');
    unlink $m_sFile if -e $m_sFile;
    rmdir $m_sFile  if -d $m_sFile;
    my $d = $m_sFile =~ ?^(.*)/[^/]+$? ? $1 : $m_hrSettings->{cgi}{bin};
    &showDir($d);
}

sub chmodFile {
    my $chmod   = param('chmod');
    my $m_sFile = param('file');
    chmod oct($chmod), $m_sFile if $chmod =~ /\d\d\d\d/ && -e $m_sFile;
    my $d = $m_sFile =~ ?^(.*)/[^/]+$? ? $1 : $m_hrSettings->{cgi}{bin};
    &showDir($d);
}
