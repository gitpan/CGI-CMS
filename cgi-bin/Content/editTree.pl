use vars qw($dump $dmp $jspart %tempNode $tN $rid %wparameter );
no warnings "uninitialized";
$dmp    = param('dump') ? param('dump') : 'navigation';
$dump   = $m_hrSettings->{tree}{$dmp};
$jspart = qq|
<script language="JavaScript" >
var m_bOver = true;
function prepareMove(id){
       dragobjekt = document.getElementById(id);
       dragX = posX - dragobjekt.offsetLeft;
       dragY = posY - dragobjekt.offsetTop;
       dropenabled = true;
       m_bOver = false;
       var o = getElementPosition(id);
       move(id,o.x+25,o.y+25);
       startdrag(id);
}
function enableDropZone(id){
       if(!dragobjekt) return;
       dropzone = id;
       if(dragobjekt.id != dropzone) document.getElementById(id).className = "dropzone"+size;
}
function disableDropZone(id){
         document.getElementById(id).className = "treeviewlink"+size;
}
function confirmMove(){
  dragobjekt.style.position ="";
  dropenabled = false;
  if(dropzone && dragobjekt.id != dropzone){
        var url = "$ENV{SCRIPT_NAME}?action=MoveTreeViewEntry&dump=$dmp&from="+document.getElementById(dropid).id+"&to="+document.getElementById(dropzone).id;
        var move = confirm("hierher verschieben ?");
        if(move)
        location.href =url;
   }
  dragobjekt.className = "treeviewlink";
  dragobjekt = null;
  m_bOver = true;
}
if (typeof document.body.onselectstart!="undefined") //ie
        document.body.onselectstart=function(){return false};
else if (typeof document.body.style.MozUserSelect!="undefined") //gecko
        document.body.style.MozUserSelect="none";
else //Opera
        document.body.onmousedown=function(){return false}

document.body.style.cursor = "default";

</script>
|;
$tN         = \%tempNode;
%wparameter = (
    path   => $m_hrSettings->{cgi}{bin} . '/templates',
    style  => $m_sStyle,
    title  => " ",
    server => $m_hrSettings->{serverName},
    id     => 'editTree',
    class  => 'min',
);
my $window = new HTML::Window( \%wparameter );

sub linkseditTreeview {
    $dump = $m_hrSettings->{tree}{'links'};
    editTreeview();
}

sub newTreeviewEntry {
    $dmp = param('dump') ? param('dump') : 'navigation';
    $dump = $m_hrSettings->{tree}{$dmp};
    &newEntry();
}

sub saveTreeviewEntry {
    &load();
    &saveEntry(\@m_aTree, param('rid') );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub addTreeviewEntry {
    &load();
    &addEntry(\@m_aTree, param('rid') );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub editTreeview {
    &load();
    &rid();
    saveTree( $dump, \@m_aTree );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub editTreeviewEntry {
    &load();
    &editEntry(\@m_aTree, param('rid') );
}

sub deleteTreeviewEntry {
    &load();
    &deleteEntry(\@m_aTree, param('rid') );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub upEntry {
    &load();
    &sortUp(\@m_aTree, param('rid') );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub MoveTreeViewEntry {
    &load();
    &getEntry(\@m_aTree, param('from'), param('to') );
    &rid();
    saveTree( $dump, \@m_aTree );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub moveEntry {
    my $t    = shift;
    my $find = shift;
    for( my $i = 0; $i <= @$t; $i++ ) {
        next if ref @$t[$i] ne "HASH";
        if( @$t[$i] ) {
            if( @$t[$i]->{rid}== $find && defined $tN->{id} ) {
                splice @$t, $i, 0, $tN;
                return 1;
            }
            if( defined @{ @$t[$i]->{subtree} } ) {
                moveEntry( \@{ @$t[$i]->{subtree} }, $find );
            }
        }
    }
}

sub getEntry {
    my $t    = shift;
    my $find = shift;
    my $goto = shift;
    for( my $i = 0; $i < @$t; $i++ ) {
        next if ref @$t[$i] ne "HASH";
        if( @$t[$i]->{rid}== $find ) {
            $tN->{$_} = @$t[$i]->{$_} foreach keys %{ @$t[$i] };
            splice @$t, $i, 1;
            moveEntry(\@m_aTree, $goto );
        } elsif ( defined @{ @$t[$i]->{subtree} } ) {
            getEntry( \@{ @$t[$i]->{subtree} }, $find, $goto );
        }
    }
}

sub downEntry {
    &load();
    $down = 1;
    &sortUp(\@m_aTree, param('rid') );
    &updateTree(\@m_aTree);
    TrOver(1);
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent .= table(
        {   align => 'center',
            width => '*'
        },
        Tr( td($jspart) ),
        Tr( td( Tree(\@m_aTree) ) )
    );
    $m_sContent .= $window->windowFooter();
    TrOver(0);
}

sub newEntry {
    $m_sContent .= br() . $window->windowHeader();
    $m_sContent
        .= qq(<b>New Entry</b><form action="$ENV{SCRIPT_NAME}"><br/><table align="center" class="mainborder" cellpadding="2"  cellspacing="2" summary="mainLayolut"><tr><td>Text:</td><td><input type="text" value="" name="text"></td></tr><tr><td>Folder</td><td><input type="checkbox" name="folder" /></td></tr>);
    my $node = help();
    foreach my $key ( sort( keys %{$node} ) ) {
        $m_sContent
            .= qq(<tr><td></td><td>$node->{$key}</td></tr><tr><td>$key :</td><td><input type="text" value="" name="$key"/><br/></td></tr>)
            if( $key ne 'class' );
    }
    $m_sContent
        .= '<tr><td><input type="hidden" name="action" value="addTreeviewEntry"/><input type="hidden" name="rid" value="'
        . param('rid')
        . '"><input type="hidden" name="dump" value="'
        . $dmp
        . '"/></td><td><input type="submit"/></td></tr></table></form>';
    $m_sContent .= $window->windowFooter();
}

sub addEntry {
    my $t    = shift;
    my $find = shift;
    for( my $i = 0; $i < @$t; $i++ ) {
        if( @$t[$i]->{rid}== $find ) {
            my %params = Vars();
            my $node   = {};
            foreach my $key ( sort( keys %params ) ) {
                $node->{$key} = $m_hrParams{$key}
                    if($m_hrParams{$key}
                    && $key ne 'action'
                    && $key ne 'folder'
                    && $key ne 'subtree'
                    && $key ne 'class'
                    && $key ne 'dump' );
                $node->{$key} = (
                    $m_hrSettings->{cgi}{mod_rewrite}
                    ? "/$1.html"
                    : "$ENV{SCRIPT_NAME}?action=$1"
                    )
                    if($key eq 'href'
                    && $m_hrParams{$key} =~ /^action:\/\/(.*)$/ );
            }
            if( param('folder') ) {
                $node->{'subtree'} = [ { text => 'Empty Folder', } ];
            }
            splice @$t, $i, 0, $node;
            &rid();
            saveTree( $dump, \@m_aTree );
            return;
        } elsif ( defined @{ @$t[$i]->{subtree} } ) {
            &addEntry( \@{ @$t[$i]->{subtree} }, $find );
        }
    }
}

sub saveEntry {
    my $t    = shift;
    my $find = shift;
    for( my $i = 0; $i < @$t; $i++ ) {
        if( @$t[$i]->{rid}== $find ) {
            my %params = Vars();
            foreach my $key ( sort keys %params ) {
                @$t[$i]->{$key} = $m_hrParams{$key}
                    if($m_hrParams{$key}
                    && $key ne 'action'
                    && $key ne 'folder'
                    && $key ne 'subtree'
                    && $key ne 'class'
                    && $key ne 'dump' );
                @$t[$i]->{$key} = (
                    $m_hrSettings->{cgi}{mod_rewrite}
                    ? "/$1.html"
                    : "$ENV{SCRIPT_NAME}?action=$1"
                    )
                    if($key eq 'href'
                    && $m_hrParams{$key} =~ /^action:\/\/(.*)$/ );
            }
            saveTree( $dump, \@m_aTree );
            return;
        } elsif ( defined @{ @$t[$i]->{subtree} } ) {
            &saveEntry( \@{ @$t[$i]->{subtree} }, $find );
        }
    }
}

sub editEntry {
    my $t    = shift;
    my $find = shift;
    my $href = "$ENV{SCRIPT_NAME}?action=editTreeviewEntry&amp;dump=$dmp";
    for( my $i = 0; $i < @$t; $i++ ) {
        if( @$t[$i]->{rid}== $find ) {
            $m_sContent .= br() . $window->windowHeader();
            $m_sContent
                .= "<b>"
                . @$t[$i]->{text}
                . '</b><form action="'
                . $href
                . '"><table align=" center " class=" mainborder " cellpadding="0"  cellspacing="0" summary="mainLayolut">';
            my $node = help();
            foreach my $key ( sort( keys %{ @$t[$i] } ) ) {
                $m_sContent .= "<tr><td></td><td>$node->{$key}</td></tr>"
                    if( defined $node->{$key} );
                $m_sContent
                    .= qq(<tr><td>$key </td><td><input type="text" value="@$t[$i]->{$key}" name="$key"></td></tr>)
                    if($key ne 'subtree'
                    && $key ne 'rid'
                    && $key ne 'action'
                    && $key ne 'dump'
                    && $key ne 'class'
                    && $key ne 'addition' );
            }
            foreach my $key2 ( sort( keys %{$node} ) ) {
                unless ( defined @$t[$i]->{$key2} ) {
                    $m_sContent
                        .= qq(<tr><td></td><td>$node->{$key2}</td></tr><tr><td>$key2 :</td><td><input type="text" value="" name="$key2"/><br/></td></tr>);
                }
            }
            $m_sContent
                .= qq(<tr><td><input type="hidden" name="action" value="saveTreeviewEntry"/><input type="hidden" name="rid" value="@$t[$i]->{rid}"/><input type="hidden" name="dump" value="$dmp"/></td><td><input type="submit" value="save"/></td></tr></table></form>);
            $m_sContent .= $window->windowFooter();
            saveTree( $dump, \@m_aTree );
            return;
        } elsif ( defined @{ @$t[$i]->{subtree} } ) {
            &editEntry( \@{ @$t[$i]->{subtree} }, $find );
        }
    }
}

sub sortUp {
    my $t    = shift;
    my $find = shift;
    for( my $i = 0; $i <= @$t; $i++ ) {
        if( defined @$t[$i] ) {
            if( @$t[$i]->{rid}== $find ) {
                $i++ if($down);
                return if( ( $down && $i== @$t ) or ( !$down && $i== 0 ) );
                splice @$t, $i- 1, 2, ( @$t[$i], @$t[ $i- 1 ] );
                saveTree( $dump, \@m_aTree );
            }
            if( defined @{ @$t[$i]->{subtree} } ) {
                sortUp( \@{ @$t[$i]->{subtree} }, $find );
                saveTree( $dump, \@m_aTree );
            }
        }
    }
}

sub deleteEntry {
    my $t    = shift;
    my $find = shift;
    for( my $i = 0; $i < @$t; $i++ ) {
        if( @$t[$i]->{rid}== $find ) {
            splice @$t, $i, 1;
            saveTree( $dump, \@m_aTree );
        } elsif ( defined @{ @$t[$i]->{subtree} } ) {
            deleteEntry( \@{ @$t[$i]->{subtree} }, $find );
        }
    }
}

sub updateTree {
    my $t = shift;
    for( my $i = 0; $i < @$t; $i++ ) {
        if( defined @$t[$i] ) {
            @$t[$i]->{onmouseup}   = "confirmMove()";
            @$t[$i]->{id}          = @$t[$i]->{rid};
            @$t[$i]->{onmousedown} = "prepareMove('" . @$t[$i]->{rid} . "')";
            @$t[$i]->{onmousemove}
                = "enableDropZone('" . @$t[$i]->{rid} . "')";
            @$t[$i]->{onmouseout}
                = "disableDropZone('" . @$t[$i]->{rid} . "')";

            @$t[$i]->{addition}
                = qq(<table border="0" cellpadding="0" cellspacing="0" align="right" summary="layout"><tr>
<td><a class="treeviewLink$m_nSize" target="_blank" title="@$t[$i]->{text}" href="@$t[$i]->{href}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/www.png" border="0" alt=""></a></td>
<td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=editTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/edit.png" border="0" alt="edit"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=deleteTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/editdelete.png" border="0" alt="delete"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=upEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="up"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=downEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="down"></a></td><td><a class="treeviewLink$m_nSize" href="$ENV{SCRIPT_NAME}?action=newTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$m_sStyle/$m_nSize/mimetypes/filenew.png" border="0" alt="new"></a></td></tr></table>);
            @$t[$i]->{href} = '';
            updateTree( \@{ @$t[$i]->{subtree} } )
                if( defined @{ @$t[$i]->{subtree} } );
        }
    }
}

sub rid {
    no warnings;
    $rid = 0;
    &getRid(\@m_aTree);

    sub getRid {
        my $t = shift;
        for( my $i = 0; $i < @$t; $i++ ) {
            $rid++;
            next unless ref @$t[$i] eq "HASH";
            @$t[$i]->{rid} = $rid;
            @$t[$i]->{id}  = $rid;
            getRid( \@{ @$t[$i]->{subtree} } )
                if( defined @{ @$t[$i]->{subtree} } );
        }
    }
}

sub load {
    $dmp = param('dump') ? param('dump') : 'navigation';
    $dump = $m_hrSettings->{tree}{$dmp};
    if( -e $dump ) {
        loadTree($dump);
        *m_aTree = \@{ $HTML::Menu::TreeView::TreeView[0] };
    }
}
1;
