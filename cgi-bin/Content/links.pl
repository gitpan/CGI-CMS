use vars qw(@t $ff $ss $folderfirst $sortstate);
$folderfirst = param('folderfirst') ? 1 : 0;
$ss          = param('sort')        ? 1 : 0;

folderFirst($folderfirst);

sub ShowBookmarks {
    loadTree( $m_hrSettings->{tree}{links} );
    *t = \@{ $HTML::Menu::TreeView::TreeView[0] };
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => " ",
        server => $m_hrSettings->{serverName},
        id     => 'ShowBookmarks',
        class  => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    _showBookmarksNavi();
    $m_sContent
        .= qq(<table align="center"  border="0" cellpadding="0" cellspacing="0"  width="100%" summary="linkLayout"><tr><td valign="top">);
    $m_sContent .= Tree( \@t );
    $m_sContent .= qq(</td></tr></table>);
    $m_sContent .= $window->windowFooter();
}

sub _showBookmarksNavi {
    $ff = $folderfirst;
    $ff = $ff ? 0 : 1;
    sortTree($ss);
    $sortstate = $ss;
    $ss = $ss ? 0 : 1;
    $m_sContent 
        .= '<div align="right">' 
        . br()
        . a(
        {   class => $sortstate
            ? 'currentLink'
            : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=links&sort=$ss&folderfirst=$folderfirst",
            title => translate('sort')
        },
        translate('sort')
        ) . '&#160;|&#160;';

    $m_sContent .= a(
        {   class => $folderfirst
            ? 'currentLink'
            : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=links&sort=$sortstate&folderfirst=$ff",
            title => translate('folderFirst')
        },
        translate('folderFirst')
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => 'link',
            href  => "$ENV{SCRIPT_NAME}?action=ExportOperaBookmarks",
            title => translate('ExportOperaBookmarks')
        },
        translate('ExportOperaBookmarks')
    );
    $m_sContent .= '&#160;|&#160;'
        . a(
        {   class => 'link',
            href  => "$ENV{SCRIPT_NAME}?action=editTreeview&dump=links",
            title => translate('edit')
        },
        translate('edit')
        )
        . '&#160;|&#160;'
        if( $m_nRight >= $m_oDatabase->getActionRight('editTreeview') );
    $m_sContent .= a(
        {   class => $m_hrAction eq "ImportOperaBookmarks"
            ? 'currentLink'
            : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=ImportOperaBookmarks",
            title => translate("ImportOperaBookmarks")
        },
        translate("ImportOperaBookmarks")
        )
        if(
        $m_nRight >= $m_oDatabase->getActionRight('ImportOperaBookmarks') );
    $m_sContent .= '</div>' . br();
}

sub ExportOperaBookmarks {
    loadTree( $m_hrSettings->{tree}{links} );
    *t = \@{ $HTML::Menu::TreeView::TreeView[0] };
    my %parameter = (
        path   => $m_hrSettings->{cgi}{bin} . '/templates',
        style  => $m_sStyle,
        title  => " ",
        server => $m_hrSettings->{serverName},
        id     => 'ShowBookmarks',
        class  => 'min',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    _showBookmarksNavi();
    $m_sContent
        .= qq(<table align="center"  border="0" cellpadding="0" cellspacing="0"  width="100%" summary="linkLayout"><tr><td align="center" valign="top">);
    $m_sContent
        .= qq(<textarea style="width:98%;height:800px;">\nOpera Hotlist version 2.0\nOptions: encoding = iso-8859-1, version=3\n);
    &_rec( \@t );
    $m_sContent .= qq(</textarea><br/>);
    $m_sContent .= qq(</td></tr></table>);
    $m_sContent .= $window->windowFooter();
}

sub _rec {
    my $tree = shift;
    for( my $i = 0; $i < @$tree; $i++ ) {
        if( defined @$tree[$i] ) {
            my $text = defined @$tree[$i]->{text} ? @$tree[$i]->{text} : '';
            if( defined @{ @$tree[$i]->{subtree} } ) {

                $m_sContent
                    .= "#FOLDER\n\tID=@$tree[$i]->{rid}\n\tNAME=$text\n\tUNIQUEID=@$tree[$i]->{rid}\n";
                _rec( \@{ @$tree[$i]->{subtree} } );
                $m_sContent .= "-\n\n";
            } else {
                my $hrf
                    = defined @$tree[$i]->{href} ? @$tree[$i]->{href} : '';
                $m_sContent
                    .= "#URL\n\tID=@$tree[$i]->{rid}\n\tNAME=$text\n\tUNIQUEID=@$tree[$i]->{rid}\n\tURL=$hrf\n";
            }
        }
    }
}

sub ImportOperaBookmarks {
    my $save       = translate('save');
    my $choosefile = translate('choosefile');
    $m_sContent .= qq|
<br/><div align="center">
<font size="+1">Upload Opera Bookmarks</font><br/><br/>
<form name="upload" action="$ENV{SCRIPT_NAME}" method="post" accept-charset="utf-8" accept="text/*" enctype="multipart/form-data" onSubmit="return confirm('$save ?');">
<input name="file" type="file" size ="30" title="$choosefile"/><input type="submit" value="$save"/>
<input  name="action" value="ImportOperaBookmarks" style="display:none;"/>
</form></div><br/>|;

    my $sra = 0;
    my $ufi = param('file');
    if($ufi) {
        use vars
            qw(@adrFile $folderId $currentOpen @openFolders @operaTree $treeTempRef $up);
        $up = upload('file');
        while(<$up>) {
            push @adrFile, $_;
        }
        ( $folderId, $currentOpen ) = (0) x 2;
        $treeTempRef = \@operaTree;
        $openFolders[0][0] = $treeTempRef;

        for( my $line = 0; $line < $#adrFile; $line++ ) {
            chomp $adrFile[$line];
            if( $adrFile[$line] =~ /^#FOLDER/ ) {    #neuer Folder
                $folderId++;
                my $text = $1 if( $adrFile[ $line+ 2 ] =~ /NAME=(.*)$/ );
                Encode::from_to( $text, "utf-8", "iso-8859-1" );
                push @{$treeTempRef},
                    {
                    text => $text =~ /(.{50}).+/ ? "$1..." : $text,
                    subtree => []
                    };
                my $l = @$treeTempRef;
                $treeTempRef = \@{ @{$treeTempRef}[ $l- 1 ]
                        ->{subtree} };    #aktuelle referenz setzen.
                $openFolders[$folderId][0]
                    = $treeTempRef;    #referenz auf den parent Tree speichern
                $openFolders[$folderId][1]
                    = $currentOpen;    #rücksprung speichern
                $currentOpen = $folderId;
            }
            if( $adrFile[$line] =~ /^-/ ) {    #wenn folder geschlossen wird
                $treeTempRef
                    = $openFolders[ $openFolders[$currentOpen][1] ][0]
                    ;    #aktuelle referenz auf parent referenz setzen
                $currentOpen
                    = $openFolders[$currentOpen][1];    #rücksprung zu parent
            }
            if( $adrFile[$line] =~ /^#URL/ ) {          #Node anhängen
                my $text = $1 if( $adrFile[ $line+ 2 ] =~ /NAME=(.*)$/ );
                my $href = $1 if( $adrFile[ $line+ 3 ] =~ /URL=(.*)$/ );
                Encode::from_to( $text, "utf-8", "iso-8859-1" );
                if( defined $text && defined $href ) {
                    push @{$treeTempRef},
                        {
                        text => $text =~ /(.{75}).+/ ? "$1..." : $text,
                        href => $href,
                        target => "_blank",
                        };
                }
            }
        }
        saveTree( $m_hrSettings->{tree}{links}, \@operaTree );
    }
    ShowBookmarks();
}
