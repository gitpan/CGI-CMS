use vars qw/$RIBBONCONTENT $PAGES $SQL/;
no warnings "uninitialized";

ChangeDb(
    {   name     => $m_sCurrentDb,
        host     => $m_sCurrentHost,
        user     => $m_sCurrentUser,
        password => $m_sCurrentPass,
    }
);
$PAGES = br() . br();

=head2 ShowNewTable()

    Form um eine Neue tabelle zu erstelle anzeigen

=cut

sub ShowNewTable {
    my $tbl   = $_[0] ? shift : param('table');
    my $count = $_[0] ? shift : param('count');
    my $newentry  = translate('CreateNewTable');
    my $save      = translate('save');
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ShowNewTable',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();

    ShowDbHeader( $m_sCurrentDb, 0, "none" );

    $m_sContent .= qq(
       <div align="center" style="overflow:auto;">
       <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
       <input type="hidden" name="action" value="SaveNewTable"/>
       <table border="0" cellpadding="0" cellspacing="0" class="dataBaseTable" summary="ShowNewTable">
       <tr><td colspan="8" align="left"><b>$tbl</b></td></tr>
       <tr>
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">LENGTH</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Attribute</td>
              <td class="caption">Primary Key</td>
       </tr>
    );

    my %vars = (
        user   => $m_sUser,
        action => 'SaveNewTable',
        table  => $tbl,
        rows   => {}
    );

    sessionValidity( 60* 60 );
    my $m_hUniqueRadio = Unique();

    for( my $j = 0; $j < $count; $j++ ) {

        my $m_hUniqueField   = Unique();
        my $m_hUniqueType    = Unique();
        my $m_hUniqueLength  = Unique();
        my $m_hUniqueNull    = Unique();
        my $m_hUniqueKey     = Unique();
        my $m_hUniqueDefault = Unique();
        my $m_hUniqueExtra   = Unique();
        my $m_hUniqueComment = Unique();
        my $m_hUniqueAttrs   = Unique();
        my $atrrs         = $m_oDatabase->GetAttrs( 0, "none", $m_hUniqueAttrs );
        $m_sContent .= qq|
              <tr>
              <td calss="values"><input type="text" value="" name="$m_hUniqueField"/></td>
              <td calss="values">|
            . $m_oDatabase->GetTypes( 'INT', $m_hUniqueType ) . qq{</td>
<td calss="values">}
            . $m_oDatabase->GetTypes( 'INT', $m_hUniqueType ) . qq{</td>
<td calss="values">
              <td><input type="text" value="" style="width:40px;" name="$m_hUniqueLength"/></td>
              <td calss="values">
              <select name="$m_hUniqueNull">
                     <option  value="not NULL">not NULL</option>
                     <option value="NULL">NULL</option>
              </select>
              </td>
              <td calss="values"><input type="text" value="" name="$m_hUniqueDefault"/></td>
              <td calss="values">
              <select name="$m_hUniqueExtra">
                     <option value=""></option>
                     <option value="auto_increment">auto_increment</option>
              </select>
              </td>
              <td calss="values">$atrrs</td>
              <td calss="values">
              <input type="radio" class="radioButton" value="$m_hUniqueField"  name="$m_hUniqueRadio"/> Primary Key
              </td>
              </tr>
              };

        $vars{rows}{$m_hUniqueField} = {
            Field   => $m_hUniqueField,
            Type    => $m_hUniqueType,
            Length  => $m_hUniqueLength,
            Null    => $m_hUniqueNull,
            Key     => $m_hUniqueKey,
            Default => $m_hUniqueDefault,
            Extra   => $m_hUniqueExtra,
            Comment => $m_hUniqueComment,
            Attrs   => $m_hUniqueAttrs,
        };
    }
    my $m_hUniqueCollation = Unique();
    my $m_hUniqueEngine    = Unique();
    my $m_hUniqueComment   = Unique();
    $vars{Collation} = $m_hUniqueCollation;
    $vars{Engine}    = $m_hUniqueEngine;
    $vars{Primary}   = $m_hUniqueRadio;
    clearSession();
    my $qstring   = createSession( \%vars );
    my $collation = $m_oDatabase->GetCollation($m_hUniqueCollation);
    $m_sContent .= qq(
       </table>
       <br/>
       $collation <input type="text" value="" name="$m_hUniqueComment" align="left"/><br/>
       <input type="submit" value="$save" align="right"/>
       <input type="hidden" name="create_table_sessionPop" value="$qstring"/>
       </form>
       </div>
       );
    $m_sContent .= $window->windowFooter();
}

=head2 SaveNewTable()

       Neue Tabelle erstellen.
#todo bei fehler form wieder anzeigen

=cut

sub SaveNewTable {
    my $session = param('create_table_sessionPop');
    session( $session, $m_sUser );
    my $tbl = $m_hrParams->{table};
    my $pk;
    if( defined $tbl and defined $session ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql  = qq|CREATE TABLE IF NOT EXISTS $tbl2 (|;

        foreach my $row ( keys %{ $m_hrParams->{rows} } ) {
            my $type   = param( $m_hrParams->{rows}{$row}{Type} );
            my $length = param( $m_hrParams->{rows}{$row}{Length} );
            $type
                = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type
                : $length ? $type . "($length)"
                :           $type;

            my $fie1d   = param( $m_hrParams->{rows}{$row}{Field} );
            my $null    = param( $m_hrParams->{rows}{$row}{Null} );
            my $extra   = param( $m_hrParams->{rows}{$row}{Extra} );
            my $default = param( $m_hrParams->{rows}{$row}{Default} );
            my $attrs   = param( param( $m_hrParams->{rows}{$row}{Attrs} ) );
            $default
                = $extra ? 'auto_increment'
                : (
                $default ? 'default ' . $m_oDatabase->quote($default)
                : ''
                );
            $sql .= $m_dbh->quote_identifier($fie1d)
                . " $type $null $default $attrs,";
        }
        my $comment  = param( $m_hrParams->{Comment} );
        my $vcomment = $m_dbh->quote($comment);
        my $engine
            = param( $m_hrParams->{Engine} )
            ? param( $m_hrParams->{Engine} )
            : 'MyISAM';
        my $key = param( param( $m_hrParams->{Primary} ) );
        $key = $key ? $key : '0';
        $key = $m_dbh->quote_identifier($key);

        my $character_set = $m_oDatabase->GetCharacterSet(
            param( $m_hrParams->{Collation} ) );
        $sql
            .= qq| PRIMARY KEY  ($key) ) ENGINE=$engine DEFAULT CHARSET=$character_set|;
        $sql .= $comment ? " COMMENT $vcomment;" : ';';
        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 NewDatabase()

       NewDatabase(table)

=cut

sub NewDatabase {
    my $db = param('db') ? param('db') : shift;
    my $tbl2 = $m_dbh->quote_identifier($tbl);
    ExecSql("Create DATABASE $tbl2");
    ShowTables($tbl);
}

#todo kommt irgendwann nicht so eilig.

# =head2 ShowProcesslist()
#
#        ShowProcesslist(table)
#
# =cut
#
# sub ShowProcesslist {
#
#     # SHOW PROCESSLIST
# }

=head2 ShowDumpTable()

    Export Tabelle

=cut

sub ShowDumpTable {
    my $tbl       = param('table');
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ShowDumpTable',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader( $tbl, 1, "Export" );
    $m_sContent
        .= '<div align="left" class="dumpBox" style="width:100%;padding-top:5px;">';
    $m_sContent .= qq(<textarea style="width:100%;height:800px;overflow:auto;">);
    DumpTable($tbl);
    $m_sContent .= qq(</textarea>);
    $m_sContent .= '</div>' . $window->windowFooter();
}

=head2 DumpTable()



=cut

sub DumpTable {
    my $tbl = $_[0] ? shift : param('table');
    $tbl = $m_dbh->quote_identifier($tbl);
    my $hr      = $m_oDatabase->fetch_hashref("SHOW CREATE TABLE $tbl");
    my $sql     = $hr->{'Create Table'} . ";$/";
    my @a       = $m_oDatabase->fetch_AoH("select *from $tbl");
    my @columns = $m_oDatabase->fetch_AoH("show columns from $tbl");

    for( my $n = 0; $n <= $#a; $n++ ) {
        $sql .= "INSERT INTO $tbl (";
        for( my $i = 0; $i <= $#columns; $i++ ) {
            $sql .= $m_dbh->quote_identifier( $columns[$i]->{'Field'} );
            $sql .= "," if( $i < $#columns );
        }
        $sql .= ') values(';
        for( my $i = 0; $i <= $#columns; $i++ ) {
            $sql
                .= $m_oDatabase->quote( $a[$n]->{ $columns[$i]->{'Field'} } );
            $sql .= "," if( $i < $#columns );
        }
        $sql .= ");$/";
    }
    $m_sContent .= $sql . $/;
}

=head2 ShowDumpDatabase()

      Export Datenbank

=cut

sub ShowDumpDatabase {
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ShowDumpDatabase',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader( $m_sCurrentDb, 0, 'Export' );
    $m_sContent
        .= qq(<div align="left" class="dumpBox" style="width:100%;padding-top:5px;"><textarea style="width:100%;height:800px;overflow:auto;">);
    DumpDatabase();
    $m_sContent .= qq(</textarea></div>) . $window->windowFooter();
}

=head2 DumpDatabase()

Export Datenbank

=cut

sub DumpDatabase {
    my @tables = $m_oDatabase->fetch_array("show tables");
    for( my $n = 0; $n <= $#tables; $n++ ) {
        DumpTable( $tables[$n] );
    }
}

=head2 HighlightSQl()

    HighlightSQl()

=cut

sub HighlightSQl {
    use Syntax::Highlight::Engine::Kate;
    my $hl = new Syntax::Highlight::Engine::Kate(
        language      => "SQL",
        substitutions => {
            "<" => "&lt;",
            ">" => "&gt;",
            "&" => "&amp;",

        },
        format_table => {
            Alert        => [ '<span class="Alert">',        '</span>' ],
            BaseN        => [ '<span class="BaseN">',        '</span>' ],
            BString      => [ '<span class="BString">',      '</span>' ],
            Char         => [ '<span class="Char">',         '</span>' ],
            Comment      => [ '<span class="Comment">',      '</span>' ],
            DataType     => [ '<span class="DataType">',     '</span>' ],
            DecVal       => [ '<span class="DecVal">',       '</span>' ],
            Error        => [ '<span class="Error">',        '</span>' ],
            Float        => [ '<span class="Float">',        '</span>' ],
            Function     => [ '<span class="Function">',     '</span>' ],
            IString      => [ '<span class="IString">',      '</span>' ],
            Keyword      => [ '<span class="Keyword">',      '</span>' ],
            Normal       => [ '<span class="Normal">',       '</span>' ],
            Operator     => [ '<span class="Operator">',     '</span>' ],
            Others       => [ '<span class="Others">',       '</span>' ],
            RegionMarker => [ '<span class="RegionMarker">', '</span>' ],
            Reserved     => [ '<span class="Reserved">',     '</span>' ],
            String       => [ '<span class="String">',       '</span>' ],
            Variable     => [ '<span class="Variable">',     '</span>' ],
            Warning      => [ '<span class="Warning">',      '</span>' ],
        },
    );
    return $hl->highlightText(shift);
}

=head2 AddFulltext()

       AddFulltext(table,name)

=cut

sub AddFulltext {
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD FULLTEXT ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropFulltext()

       DropFulltext(table,name)

=cut

sub DropFulltext {
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP FULLTEXT ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 AddIndex()

       AddIndex(table,name)

=cut

sub AddIndex {
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD INDEX ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropIndex()

       DropIndex(table,name)

=cut

sub DropIndex {
    my $tbl   = param('table') ? param('table') : shift;
    my $uname = param('index') ? param('index') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP INDEX $uname");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 AddUnique()

       AddUnique(table,name)

=cut

sub AddUnique {
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 ADD UNIQUE ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropUnique()

       DropUnique(table,name)

=cut

sub DropUnique {
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;

    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP UNIQUE ($uname)");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ExecSql()

       ExecSql(sql, bool showSql)

=cut

sub ExecSql {
    my $sql        = shift;
    my $showSql    = $_[0] ? $_[0] : param('showsql');
    my @statements = split /;\n/, $sql unless param('sql');
    @statements = split /%3B%0D%0A/, uri_escape($sql) if param('sql');
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ExecSql',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $window->set_closeable(0);
    $window->set_moveable(0);
    $window->set_resizeable(0);
    $window->set_collapse(0);

    $RIBBONCONTENT
        .= '<div align="left" class="sqlBox" style="width:100%;overflow:auto;">'
        if $showSql;
    my $id2 = 0;
    foreach my $s (@statements) {
        $s = uri_unescape($s);
        $SQL .= "$s$/";
        my $rows_affected = 0;
        $parameter{id} = "ExecSql$id2";
        my $window3 = new HTML::Window( \%parameter );
        eval {
            my $sth = $m_dbh->prepare($s);
            $sth->execute();
            $rows_affected = $sth->rows;
            if($showSql) {
                if( $rows_affected > 0 ) {
                    my $id = 0;
                    while( my @a = $sth->fetchrow_array() ) {
                        $parameter{id} = "ExecSql$id";
                        $RIBBONCONTENT .= br() . join( br(), @a );
                        $id++;
                    }
                }
            }
            $RIBBONCONTENT
                .= br()
                . $window3->windowHeader()
                . HighlightSQl($s)
                . br()
                . $m_dbh->errstr
                . $window3->windowFooter()
                if $@;

        };
        $id2++;
        $RIBBONCONTENT .= br() . translate('rows in effect') . $rows_affected
            if( $rows_affected > 0 && $showSql );
    }
    $RIBBONCONTENT .= '</div><br/>' if $showSql;
}

=head2 SQL()

action
       SQL

=cut

sub SQL {
    ExecSql( param('sql'), 1 );
    ShowTables();
}

=head2 ShowTable()

action
       ShowTable(table)

=cut

sub ShowTable {
    my $tbl = param('table') ? param('table') : shift;

    if( $m_oDatabase->tableExists($tbl) ) {
        my %parameter = (
            path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => "wnd.htm",
            server   => $m_hrSettings->{serverName},
            id       => 'ShowTable',
            class    => 'max',
        );
        my $window = new HTML::Window( \%parameter );
        $m_sContent .= br() . $window->windowHeader();

        my $tb2 = $m_dbh->quote_identifier($tbl);
        use HTML::Menu::Pages;
        my $count   = $m_oDatabase->tableLength($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tb2");
        my $rws     = $#caption+ 2;
        my $rows    = $#caption;
        $m_nStart
            = ( $m_nStart >= $count )
            ? ( ( ( $count- 10 ) > 0 ) ? ( $count- 10 ) : 0 )
            : $m_nStart;

        my $field = $caption[0]->{'Field'};
        my $orderby = defined param('orderBy') ? param('orderBy') : 0;
        $field = $orderby if $orderby;
        my $qfield = $m_dbh->quote_identifier($field);
        my $state  = param('desc') ? param('desc') : 0;
        my $desc   = $state ? 'desc' : '';

        my $lpp
            = defined param('links_pro_page') ? param('links_pro_page') : 30;
        $lpp = $lpp =~ /(\d\d\d?)/ ? $1 : $lpp;

        my @a
            = $m_oDatabase->fetch_AoH(
            "select * from $tb2 order by $qfield $desc LIMIT $m_nStart , $lpp"
            );
        if( $count > 0 ) {
            my %needed = (
                start       => $m_nStart,
                length      => $count,
                style       => $m_sStyle,
                mod_rewrite => 0,
                action      => "ShowTable",
                append =>
                    "&table=$tbl&links_pro_page=$lpp&orderBy=$field&desc=$state",
                path           => $m_hrSettings->{cgi}{bin},
                links_pro_page => $lpp,
            );
            $PAGES = makePages( \%needed );
        }
        ShowDbHeader( $tbl, 1, "Show" );
        $m_sContent .= qq|
                     <div style="overflow:auto;"><form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
                     <input type="hidden" name="action" value="MultipleAction"/>
                     <input type="hidden" name="table" value="$tbl"/>
                     <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="layout" width="100%"><tr><td></td><td colspan="$rws">|
            . div(
            { align => 'right' },
            translate('links_pro_page')
                . '&#160;|&#160;'
                . a(
                {   href =>
                        "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=10&von=$m_nStart&orderBy=$field&desc=$state",
                    class => $lpp== 10 ? 'menuLink2' : 'menuLink3'
                },
                '10'
                )
                . '&#160;'
                . a(
                {   href =>
                        "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=20&von=$m_nStart&orderBy=$field&desc=$state",
                    class => $lpp== 20 ? 'menuLink2' : 'menuLink3'
                },
                '20'
                )
                . '&#160;'
                . a(
                {   href =>
                        "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=30&von=$m_nStart&orderBy=$field&desc=$state",
                    class => $lpp== 30 ? 'menuLink2' : 'menuLink3'
                },
                '30'
                )
                . '&#160;'
                . a(
                {   href =>
                        "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=100&von=$m_nStart&orderBy=$field&desc=$state",
                    class => $lpp== 100 ? 'menuLink2' : 'menuLink3'
                },
                '100'
                )
            ) . '</td></tr><tr><td class="caption"></td>';

        for( my $i = 0; $i <= $rows; $i++ ) {
            $m_sContent .= qq|<td class="caption">|;
            $m_sContent .= a(
                {   class => $caption[$i]->{'Field'} eq $field
                    ? 'currentLink'
                    : 'link',
                    href =>
                        "$ENV{SCRIPT_NAME}?action=ShowTable&table=$tbl&links_pro_page=$lpp&von=$m_nStart&orderBy=$caption[$i]->{'Field'}&desc="
                        . (
                        $field eq $caption[$i]->{'Field'}
                        ? ( $desc eq 'desc' ? '0' : '1' )
                        : '0'
                        ),
                    title => $caption[$i]->{'Field'}
                },
                $caption[$i]->{'Field'}
                    . (
                    $caption[$i]->{'Field'} eq $field
                    ? ( $state
                        ? qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/up.png" border="0" alt="" title="up" width="16" height="16" align="left"/>|
                        : qq|&#160;<img src="/style/$m_sStyle/$m_nSize/mimetypes/down.png" border="0" alt="" title="down" align="left"/>|
                        )
                    : ''
                    )
            );
            $m_sContent .= '</td>';
        }
        $m_sContent .= '<td class="caption"></td></tr>';
        my $p_key = $m_oDatabase->GetPrimaryKey($tbl);
        for( my $i = 0; $i <= $#a; $i++ ) {
            $m_sContent
                .= q|<tr onmouseover="this.className='overDb';" onmouseout="this.className='';">|;

            $m_sContent
                .= qq|<td width="20"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{$p_key}" /></td>|;
            for( my $j = 0; $j <= $rows; $j++ ) {
                my $headline = $a[$i]->{ $caption[$j]->{'Field'} };
                $m_sContent .= '<td class="values">'
                    . substr( $headline, 0, int( 120/ $rows ) ) . '</td>';
            }
            my $trdelete = translate('delete');
            my $tredit   = translate('EditEntry');
            $m_sContent
                .= qq|<td class="values"><a href="$ENV{SCRIPT_NAME}?action=EditEntry&amp;table=$tbl&amp;edit=$a[$i]->{$p_key}&amp;von=$m_nStart&amp;bis=$m_nEnd;"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="Edit" title="$tredit"/></a><a href ="$ENV{SCRIPT_NAME}?action=DeleteEntry&amp;table=$tbl&amp;delete=$a[$i]->{$p_key}&amp;von=$m_nStart;&amp;bis=$m_nEnd;" onclick="return confirm('$trdelete ?')"><img src="/style/$m_sStyle/buttons/delete.png" border="0" alt="delete" title="$trdelete"/></a></td></tr>|;
        }

        $m_sContent
            .= qq|<tr><td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>|;
        my $delete   = translate('delete');
        my $mmark    = translate('makierte');
        my $markAll  = translate('Alle markieren');
        my $umarkAll = translate('Auswahl aufheben');
        my $export   = translate('export');
        my $edit     = translate('edit');
        $m_sContent .= qq{
              <td colspan="$rws">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="layout" width="100%" ><tr>
              <td><a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a>
              </td><td align="right">
              <select   name="MultipleAction"  onchange="this.form.submit();">
              <option  value="$mmark" selected="selected">$mmark</option>
              <option value="delete">$delete</option>
              <option value="export">$export</option>
              </select>
              </td></tr></table>
       };

        $m_sContent .= qq|</td></tr></table></form></div>|;
        $m_sContent .= $window->windowFooter() . br();

    } else {
        ShowTables();
    }
}

=head2 MultipleAction()

       MultipleAction für tabelle

=cut

sub MultipleAction {
    my $a      = param("MultipleAction");
    my @params = param();
    my $tbl    = param('table');
    my $tbl2   = $m_dbh->quote_identifier($tbl);
    my $p_key  = $m_oDatabase->GetPrimaryKey($tbl);
    $p_key = $m_dbh->quote_identifier($p_key);
    my $window = new HTML::Window(
        {   path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => "wnd.htm",
            server   => $m_hrSettings->{serverName},
            id       => 'MultipleAction',
            class    => 'max',
        }
    );
    if( $a eq "export" ) {
        $m_sContent .= br() . $window->windowHeader();
        ShowDbHeader( $m_sCurrentDb, 1, 'Export' );
        $m_sContent
            .= qq(<div  class="dumpBox" style="padding-top:5px;width:100%;padding-right:2px;"><textarea style="width:100%;height:800px;overflow:auto;">);
    }
    for( my $i = 0; $i <= $#params; $i++ ) {
        if( $params[$i] =~ /markBox\d?/ ) {
            my $col = param( $params[$i] );
            $col = $m_oDatabase->quote($col);
        SWITCH: {
                if( $a eq "delete" ) {
                    ExecSql("DELETE FROM $tbl2 where $p_key  = $col");
                    last SWITCH;
                }
                if( $a eq "truncate" ) {
                    ExecSql("truncate $tbl2");
                    last SWITCH;
                }
                if( $a eq "export" ) {
                    my $a = $m_oDatabase->fetch_hashref(
                        "select from $tbl2 where $p_key = $col");
                    my @columns
                        = $m_oDatabase->fetch_AoH("show columns from $tbl2");

                    $m_sContent .= "INSERT INTO $tbl (";
                    for( my $j = 0; $j <= $#columns; $j++ ) {
                        $m_sContent .= $m_dbh->quote_identifier(
                            $columns[$j]->{'Field'} );
                        $m_sContent .= "," if( $j < $#columns );
                    }
                    $m_sContent .= ') values(';
                    for( my $j = 0; $j <= $#columns; $j++ ) {
                        $m_sContent .= $m_oDatabase->quote(
                            $a->{ $columns[$j]->{'Field'} } );
                        $m_sContent .= "," if( $j < $#columns );
                    }
                    $m_sContent .= ");$/";

                    last SWITCH;
                }
            }

        }

    }
    if( $a eq "export" ) {
        $m_sContent .= qq(</textarea>);
        $m_sContent .= '</div>' . $window->windowFooter();
    } else {
        ShowTable($tbl);
    }

}

=head2 MultipleDbAction()

       MultipleDbAction für tabellen

=cut

sub MultipleDbAction {
    my $a         = param("MultipleDbAction");
    my @params    = param();
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'MultipleDbAction',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    if( $a eq "export" ) {
        $m_sContent .= br() . $window->windowHeader();
        ShowDbHeader( $m_sCurrentDb, 0, 'Export' );
        $m_sContent
            .= qq(<div  class="dumpBox" style="padding-top:5px;width:100%;padding-right:2px;"><textarea style="width:100%;height:800px;">);
    } else {
        ShowDbHeader( $m_sCurrentDb, 0, 'Show' );
    }
    for( my $i = 0; $i <= $#params; $i++ ) {
        if( $params[$i] =~ /markBox\d?/ ) {
            my $tbl  = param( $params[$i] );
            my $tbl2 = $m_dbh->quote_identifier($tbl);
        SWITCH: {
                if( $a eq "delete" ) {
                    ExecSql("Drop table $tbl2");
                    last SWITCH;
                }
                if( $a eq "export" ) {
                    DumpTable($tbl);
                    last SWITCH;
                }
                if( $a eq "truncate" ) {
                    ExecSql("Truncate $tbl2");
                    last SWITCH;
                }
                if( $a eq "optimize" ) {
                    ExecSql("OPTIMIZE TABLE $tbl2");
                    ShowTables();
                    last SWITCH;
                }
                if( $a eq "analyze" ) {
                    ExecSql("ANALYZE TABLE $tbl2");
                    last SWITCH;
                }
                if( $a eq "repair" ) {
                    ExecSql("REPAIR TABLE $tbl2");
                    last SWITCH;
                }
            }

        }
    }

    if( $a eq "export" ) {
        $m_sContent .= qq(</textarea>);
        $m_sContent .= '</div>' . $window->windowFooter();
    } else {
        ShowTables();
    }
}

=head2 EditEntry()

    EditEntry( table, edit )

=cut

sub EditEntry {
    my $tbl = defined param('table') ? param('table') : shift;
    my $rid = defined param('edit')  ? param('edit')  : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $rid ) {
        my $tbl2    = $m_dbh->quote_identifier($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tbl2");
        my $p_key   = $m_oDatabase->GetPrimaryKey($tbl);
        my $ed      = translate('Edit Entry');
        my $a       = $m_oDatabase->fetch_hashref(
            "select * from $tbl2 where $p_key = ?", $rid );
        my %parameter = (
            path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => 'wnd.htm',
            title    => translate("EditEntry"),
            server   => $m_hrSettings->{serverName},
            id       => 'EditEntry',
            class    => 'max',
        );
        my $window = new HTML::Window( \%parameter );
        $RIBBONCONTENT
            .= br()
            . $window->windowHeader()
            . qq(<div align="center"><p>$ed</p><form action="$ENV{SCRIPT_NAME}" method="post"  enctype="multipart/form-data"><input type="hidden" name="action" value="SaveEntry"/><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout"><tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);

        for( my $j = 0; $j <= $#caption; $j++ ) {
        SWITCH: {
                if( $caption[$j]->{'Type'} eq "text" ) {
                    $RIBBONCONTENT
                        .= qq(<tr><td>$caption[$j]->{'Field'} </td><td><textarea name="tbl$caption[$j]->{'Field'}" align="left" style="width:100%>$a->{$caption[$j]->{'Field'}}</textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $RIBBONCONTENT
                    .= qq(<tr><td >$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="$a->{$caption[$j]->{'Field'}}" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
            }
        }
        my $trsave = translate('save');
        $RIBBONCONTENT
            .= qq(</table><br/><input type="submit" value="$trsave"/><input type="hidden" name="id" value="$rid"/><input type="hidden" name="table" value="$tbl"/><input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/><br/><br/></form></div>);
        $RIBBONCONTENT .= $window->windowFooter();
        ShowTable($tbl);
    } else {
        ShowTables();
    }

}

=head2 EditAction()

       EditAction()

=cut

sub EditAction {
    my $name = defined param('name') ? param('name') : $m_hrAction;
    unless ( $m_sCurrentDb eq $m_hrSettings->{database}{name} ) {
        ChangeDb(
            {   name     => $m_hrSettings->{database}{name},
                host     => $m_hrSettings->{database}{host},
                user     => $m_hrSettings->{database}{user},
                password => $m_hrSettings->{database}{password},

            }
        );
    }
    my @id = $m_oDatabase->fetch_array(
        "select id from `actions` where action=?", $name );
    if( defined $id[0] ) {
        EditEntry( 'actions', $id[0] );
    } else {
        ShowTable('actions');
    }

}

=head2 EditVertMenu()

       EditAction()

=cut

sub EditVertMenu {
    unless ( $m_sCurrentDb eq $m_hrSettings->{database}{name} ) {
        ChangeDb(
            {   name     => $m_hrSettings->{database}{name},
                host     => $m_hrSettings->{database}{host},
                user     => $m_hrSettings->{database}{user},
                password => $m_hrSettings->{database}{password},

            }
        );
    }
    my $name = defined param('name') ? param('name') : $m_hrAction;
    my @id = $m_oDatabase->fetch_array(
        "select id from `navigation` where action=?", $name );
    if( defined $id[0] ) {
        EditEntry( 'navigation', $id[0] );
    } else {
        ShowTable('navigation');
    }
}

=head2 EditTopMenu()

       EditAction()

=cut

sub EditTopMenu {
    unless ( $m_sCurrentDb eq $m_hrSettings->{database}{name} ) {
        ChangeDb(
            {   name     => $m_hrSettings->{database}{name},
                host     => $m_hrSettings->{database}{host},
                user     => $m_hrSettings->{database}{user},
                password => $m_hrSettings->{database}{password},
            }
        );
    }
    my $name = defined param('name') ? param('name') : $m_hrAction;
    my @id = $m_oDatabase->fetch_array(
        "select id from `topnavigation` where action=?", $name );
    if( defined $id[0] ) {
        EditEntry( 'topnavigation', $id[0] );
    } else {
        ShowTable('topnavigation');
    }
}

=head2 ShowNewEntry()

       ShowNewEntry(table)

=cut

sub ShowNewEntry {
    my $tbl = param('table') ? param('table') : shift;
    if( $m_oDatabase->tableExists($tbl) ) {

        my @caption  = $m_oDatabase->fetch_AoH("show columns from `$tbl`");
        my $newentry = translate('NewEntry');

        my %parameter = (
            path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => "wnd.htm",
            server   => $m_hrSettings->{serverName},
            id       => 'ShowNewEntry',
            class    => 'none',
        );
        my $window = new HTML::Window( \%parameter );
        $m_sContent .= $window->windowHeader();

        $m_sContent
            .= qq(<div align="center"><form action="$ENV{SCRIPT_NAME}?" method="get" name="action" enctype="multipart/form-data"><input type="hidden" name="action" value="NewEntry"/>
<table align="center" border="0" cellpadding="2"  cellspacing="0" summary="layout">
<tr><td colspan="7" align="left">$newentry</td></tr>
<tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);
        for( my $j = 0; $j <= $#caption; $j++ ) {
        SWITCH: {
                if( $caption[$j]->{'Type'} eq "text" ) {
                    $m_sContent
                        .= qq(<tr><td class="values" >$caption[$j]->{'Field'}</td><td><textarea name="tbl$caption[$j]->{'Field'}" value="" align="left" style="width:100%"></textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $m_sContent
                    .= qq(<tr><td class="values" >$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
            }
        }
        my $save = translate('save');
        $m_sContent
            .= qq(</table><br/><input type="submit" value="$save" align="right"/><input type="hidden" name="table" value="$tbl"/><input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/><br/><br/></form></div>);

        $m_sContent .= $window->windowFooter();
    } else {
        ShowTables();
    }
}

=head2 SaveEntry()

       Action

=cut

sub SaveEntry {
    my @params = param();
    my $tbl    = param('table');
    if( $m_oDatabase->tableExists($tbl) ) {
        my $i = 0;
        my @rows;
        my $eid;
        my $p_key = $m_oDatabase->GetPrimaryKey($tbl);
        while( $i < $#params ) {
            $i++;
            my $pa = param( $params[$i] );
            if( $params[$i] =~ /tbl.*/ ) {
                $params[$i] =~ s/tbl//;
                $eid = $pa if( $params[$i] eq $p_key );
                unshift @rows,
                      ""
                    . $m_dbh->quote_identifier( $params[$i] ) . " = "
                    . $m_oDatabase->quote($pa);
            }
        }
        $tbl = $m_dbh->quote_identifier($tbl);

        $p_key = $m_dbh->quote_identifier($p_key);
        my $sql
            = "update $tbl set "
            . join( ',', @rows )
            . " where $p_key = $eid;";
        ExecSql($sql);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 NewEntry()

       Action

=cut

sub NewEntry {
    my @params = param();
    my $tbl    = param('table');
    if( $m_oDatabase->tableExists($tbl) ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my $sql = "INSERT INTO $tbl VALUES(";
        my $i   = 0;
        while( $i < $#params ) {
            $i++;
            my $pa = param( $params[$i] );
            if( $params[$i] =~ /tbl.*/ ) {
                $params[$i] =~ s/tbl//;
                $sql .= "'" . $pa . "'";
                $sql .= "," if( $i+ 3 < $#params );
            }
        }
        $sql .= ")";
        ExecSql($sql);
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DeleteEntry()

       Action

=cut

sub DeleteEntry {
    my $tbl = param('table')  ? param('table')  : shift;
    my $ids = param('delete') ? param('delete') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $ids ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $ids = $m_oDatabase->quote($ids);
        my $p_key = $m_oDatabase->GetPrimaryKey($tbl);
        $p_key = $m_dbh->quote_identifier($p_key);
        ExecSql("DELETE FROM $tbl2 where $p_key  = $ids");
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ShowTables()

       ShowTables()

=cut

sub ShowTables {
    my @a         = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS");
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ShowTables',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();

    ShowDbHeader( $m_sCurrentDb, 0, 'Show' );

    $m_sContent .= qq(
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="MultipleDbAction"/>
              <div align="center" style="padding-top:5px;overflow:auto;width:100%">
              <table align="left" border="0" cellpadding="2"  cellspacing="0" summary="ShowTables" width="100%">
              <tr>
              <td class="caption"></td>
              <td class="caption">Name</td>
              <td class="caption">Rows</td>
              <td class="caption">Type</td>
              <td class="caption">Size (kb)</td>
              <td class="caption"></td>
              <td class="caption"></td>
              <td class="caption"></td>
              </tr>
    );
    for( my $i = 0; $i <= $#a; $i++ ) {
        my $kb = sprintf( "%.2f",
            ( $a[$i]->{Index_length}+ $a[$i]->{Data_length} )/ 1024 );
        my $trdatabase = translate('database');
        my $trdelete   = translate('delete');
        my $change     = translate('EditTable');
        $m_sContent .= qq(
              <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
              <td width="20" class="values"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{Name}" /></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowTable&amp;table=$a[$i]->{Name}&amp;desc=0">$a[$i]->{Name}</a></td>
              <td class="values">$a[$i]->{Rows}</td><td class="values">$a[$i]->{Engine}</td><td class="values">$kb</td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=DropTable&amp;table=$a[$i]->{Name}" onclick="return confirm(' $trdelete?')"><img src="/style/$m_sStyle/buttons/delete.png" align="middle" alt="" border="0"/></a></td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=EditTable&amp;table=$a[$i]->{Name}"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="$change" title="$change"/></a></td>
              <td class="values" width="16"><a href="$ENV{SCRIPT_NAME}?action=ShowTableDetails&amp;table=$a[$i]->{Name}"><img src="/style/$m_sStyle/buttons/details.png" border="0" alt="Details" title="Details" width="16" /></a></td>
              </tr>
       );
    }

    my $delete   = translate('delete');
    my $mmark    = translate('makierte');
    my $markAll  = translate('Alle markieren');
    my $umarkAll = translate('Auswahl aufheben');
    my $export   = translate('export');
    my $truncate = translate('truncate');
    my $optimize = translate('optimize');
    my $repair   = translate('repair');

    $m_sContent .= qq|
              <tr>
              <td><img src="/style/$m_sStyle/buttons/feil.gif" border="0" alt=""/></td>
              <td colspan="7" align="left">
              <table align="center" border="0" cellpadding="0"  cellspacing="0" summary="ShowTables" width="100%">
              <tr><td colspan="2" align="left">
              <a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td>
              <td  align="right">
              <select name="MultipleDbAction" onchange="this.form.submit();">
              <option value="$mmark" selected="selected">$mmark</option>
              <option value="delete">$delete</option>
              <option value="export">$export</option>
              <option value="truncate">$truncate</option>
              <option value="optimize">$optimize</option>
              <option value="repair">$repair</option>
              </select>
</td>
              </tr></table>
              </td>
              </tr>
              </table>
              </form>
              </div>
    |;

    $m_sContent .= $window->windowFooter()

}

=head2 DropTable()

action
       DropTable(table)

=cut

sub DropTable {
    my $tbl = param('table');
    if( $m_oDatabase->tableExists($tbl) ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        ExecSql("drop table $tbl");
    }
    ShowTables();
}

=head2 ShowTableDetails()

action

       ShowTableDetails(table)

=cut

sub ShowTableDetails {
    my $tbl = $_[0] ? shift : param('table');
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => "wnd.htm",
        server   => $m_hrSettings->{serverName},
        id       => 'ShowTableDetails',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= br() . $window->windowHeader();
    ShowDbHeader( $tbl, 1, "Details" );
    $m_sContent
        .= '<div align="center" style="padding-top:5px;width:100%;padding-right:2px;">';
    my $name = param('table');
    my @a    = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS");
    $m_sContent .= qq(
              <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="ShowTables">
              <tr><td colspan="2" align="left">$name</td></tr>
              <tr><td class="caption">Name</td><td class="caption">Value</td></tr>);

    for( my $i = 0; $i <= $#a; $i++ ) {
        if( $a[$i]->{Name} eq $name ) {
            foreach my $key ( keys %{ $a[0] } ) {
                $m_sContent
                    .= qq(<tr class="values" align="left"><td class="value" align="left">$key</td><td class="value" align="left">$a[$i]->{$key}</td></tr>);
            }
        }
    }
    $m_sContent .= '</table></div><br/>' . $window->windowFooter();
}

=head2 AddPrimaryKey()

action

       AddPrimaryKey(table,$col)

=cut

sub AddPrimaryKey {
    my $tbl = $_[0] ? shift : param('table');
    my $col = $_[0] ? shift : param('column');
    if( defined $tbl && defined $col ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $col = $m_dbh->quote_identifier($col);
        ExecSql(
            "ALTER TABLE  $tbl2 DROP PRIMARY KEY, ADD PRIMARY KEY($col) ");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 DropCol()

action

       DropCol(table,$col)

=cut

sub DropCol {
    my $tbl = $_[0] ? shift : param('table');
    my $col = $_[0] ? shift : param('column');
    if( defined $tbl && defined $col ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $col = $m_dbh->quote_identifier($col);
        ExecSql("ALTER TABLE $tbl2 DROP COLUMN $col");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 TruncateTable()

action

       TruncateTable(table)

=cut

sub TruncateTable {
    my $tbl = $_[0] ? shift : param('table');
    if( $m_oDatabase->tableExists($tbl) ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        ExecSql(" TRUNCATE TABLE $tbl");
    }
    ShowTables();
}

=head2 EditTable()

action

       EditTable(table)

=cut

sub EditTable {
    my $tbl = $_[0] ? shift : param('table');
    if( $m_oDatabase->tableExists($tbl) ) {
        my $tbl2    = $m_dbh->quote_identifier($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show full columns from $tbl2");
        my $clm     = $m_oDatabase->GetPrimaryKey($tbl);
        my $newentry = translate('editTableProps');
        my $rename   = translate('rename');
        my $save     = translate('save');

        my %parameter = (
            path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => "wnd.htm",
            server   => $m_hrSettings->{serverName},
            id       => 'EditTable',
            class    => 'max',
        );
        my $window = new HTML::Window( \%parameter );
        $m_sContent .= $window->windowHeader();
        ShowDbHeader( $tbl, 1, "Edit" );
        $m_sContent .= qq(
              <div  align="center" style="padding-top:5px;width:100%;padding-right:2px;">
              <table border="0" cellpadding="0" cellspacing="2" class="dataBaseTable">
              <tr >
              <td >);

        $m_sContent .= qq|
              <table cellspacing="0" border="0" cellpadding="2" width="100%">
              <tr>
              <td class="caption">Name</td>
              <td class="caption">Engine</td>
              <td class="caption">Auto_increment</td>
              </tr>
              <tr>
              <td class="values"><form action="" enctype="multipart/form-data" accept-charset="ISO-8859-1"><input type="hidden" name="action" value="RenameTable"/>
              <table border="0"  align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
              <tr ><td class="values">
              <input type="hidden" name="table" value="$tbl"/><input type="text" align="bottom" name="newTable" value="$tbl"/></td><td><input type="submit" name="submit" value="$rename"/></td>
              </tr></table>
              </form></td>
              <td>
               <form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
              <table border="0"  align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
              <tr ><td class="values">|
            . $m_oDatabase->GetEngines( $tbl, 'engine' ) . qq|
              </td><td class="values">
              <input type="submit" value="|
            . translate('ChangeEngine') . qq|"/>
              </td>
              </tr></table>
              <input type="hidden" value="ChangeEngine" name="action"/>
              <input type="hidden" value="$tbl" name="table"/>
              </form></td>|;

        $m_sContent .= qq|
              <td class="values"><form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
                     <table border="0" align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
                     <tr><td class="values">
                     <input type="text" value="|
            . $m_oDatabase->GetAutoIncrementValue($tbl)
            . qq|" name="AUTO_INCREMENT" style="width:40px"/>
                     </td><td class="values"><input type="hidden" value="$tbl" name="table"/>
                     <input type="hidden" value="ChangeAutoInCrementValue" name="action"/>
                     <input type="submit" value="|
            . translate('ChangeAutoInCrementValue') . qq|"/>
                     </form></td>
                     </tr></table>
              </td></tr></table>|;

#         $m_sContent
#             .= qq|<td class="values"><form action="$ENV{SCRIPT_NAME}" method="POST" enctype="multipart/form-data">
#                <table border="0" align="left" cellpadding="2" cellspacing="0" class="dataBaseTable">
#               <tr><td class="values">|
#             . $m_oDatabase->GetCollation($tbl,'charset') . qq|
#               </td>
#               <td class="values"><input type="submit" value="|
#             . translate('ChangeCharset') . qq|"/>
#               </td>
#               </tr></table>
#               <input type="hidden" value="$tbl" name="table"/>
#               <input type="hidden" value="ChangeCharset" name="action"/>
#               </form></td></table></td>|;

        $m_sContent .= qq(
              <tr><td >
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="SaveEditTable"/>
              <table border="0" cellpadding="0" cellspacing="0" class="dataBaseTable">
              <tr class="caption">
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">Length</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Collation</td>
              <td class="caption">Attribute</td>
              <td class="caption">Comment</td>
              <td class="caption"><img src="/style/$m_sStyle/buttons/primary.png" alt="Add Primary Key"  title="Add Primary Key" width="16" height="16" align="left" border="0"/></td>
              <td class="caption"></td>
              </tr>
       );

        my %vars = (
            user   => $m_sUser,
            action => 'SaveEditTable',
            table  => $tbl,
            rows   => {}
        );

        sessionValidity( 60* 60 );

        for( my $j = 0; $j <= $#caption; $j++ ) {

            my $field = $caption[$j]->{'Field'};

            my $lght            = $caption[$j]->{'Type'};
            my $length          = ( $lght =~ /\((\d+)\)/ ) ? $1 : '';
            my $m_hUniqueField     = Unique();
            my $m_hUniqueType      = Unique();
            my $m_hUniqueLength    = Unique();
            my $m_hUniqueNull      = Unique();
            my $m_hUniqueDefault   = Unique();
            my $m_hUniqueExtra     = Unique();
            my $m_hUniqueComment   = Unique();
            my $m_hUniqueCollation = Unique();
            my $m_hUniqueAttrs     = Unique();
            $m_sContent .= qq|
              <tr class="values">
              <td><input type="text" value="$field" style="width:80px;" name="$m_hUniqueField"/></td>
              <td>|
                . $m_oDatabase->GetTypes( $caption[$j]->{'Type'},
                $m_hUniqueType )
                . qq|</td>
              <td><input type="text" value="$length" style="width:80px;" name="$m_hUniqueLength"/></td>
              <td>|
                . $m_oDatabase->GetNull( $caption[$j]->{'Null'}, $m_hUniqueNull )
                . qq|</td>
              <td><input type="text" value="$caption[$j]->{'Default'}" style="width:80px;" name="$m_hUniqueDefault"/></td>
              <td>|
                . $m_oDatabase->GetExtra( $caption[$j]->{'Extra'},
                $m_hUniqueExtra )
                . '</td>
              <td>'
                . $m_oDatabase->GetColumnCollation( $tbl, $field,
                $m_hUniqueCollation )
                . qq{</td> <td>}
                . $m_oDatabase->GetAttrs( $tbl, $field, $m_hUniqueAttrs )
                . qq{</td>
              <td><input type="text" value="$caption[$j]->{Comment}" style="width:80px;" name="$m_hUniqueComment"/></td><td>}
                . (
                $clm eq $field
                ? qq|<input align="left" type="radio" value="$field"  name="AddPrimaryKey" title="Primary Key"  checked="true"/>|
                : qq|<input align="left" type="radio" value="$field"  name="AddPrimaryKey" title="Primary Key"/> |
                )
                . qq{</td><td><a href="?action=AddFulltext;&amp;table=$tbl&amp;column=$field" title="Add fulltext $field" title="Add fulltext"><img src="/style/$m_sStyle/buttons/fulltext.png" alt="Add fulltext" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=AddIndex;&amp;table=$tbl&amp;column=$field" title="Add Index $field"><img src="/style/$m_sStyle/buttons/index.png" alt="Add Index" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=AddUnique;&amp;table=$tbl&amp;column=$field" title="Add Unique $field" ><img src="/style/$m_sStyle/buttons/unique.png" alt="Add Unique" width="16" height="16" align="left" border="0"/></a>
              <a href="?action=DropCol;&amp;table=$tbl&amp;column=$field" onclick="return confirm('Delete $field')" title="Drop Column $field" ><img src="/style/$m_sStyle/buttons/delete.png" alt="Delete $field" width="16" height="16" align="left" border="0"/></a>
              </td>
              </tr>
              };

            $vars{rows}{$field} = {
                Field     => $m_hUniqueField,
                Type      => $m_hUniqueType,
                Length    => $m_hUniqueLength,
                Null      => $m_hUniqueNull,
                Default   => $m_hUniqueDefault,
                Extra     => $m_hUniqueExtra,
                Comment   => $m_hUniqueComment,
                Collation => $m_hUniqueCollation,
                Attrs     => $m_hUniqueAttrs,
            };
        }
        clearSession();
        my $qstring = createSession( \%vars );
        $m_sContent .= qq(
              <tr><td colspan="11" align="right" style="padding-top:2px;">
              <input type="submit" value="$save" align="right"/>
              <input type="hidden" name="change_col_sessionRTZHBG" value="$qstring"/>
              </form>
              </td></tr>
              <tr><td colspan="10" align="right" style="padding-top:2px;">
       );

        my $newCol = translate('newcol');

        $m_sContent .= qq(
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <input type="hidden" name="action" value="SaveNewColumn"/>
              <table border="0" cellpadding="2" cellspacing="0" class="dataBaseTable" width="100%">
              <tr ><td colspan="10" align="left">$newCol</td></tr>
              <tr class="caption">
              <td class="caption">Field</td>
              <td class="caption">Type</td>
              <td class="caption">LENGTH</td>
              <td class="caption">Null</td>
              <td class="caption">Default</td>
              <td class="caption">Extra</td>
              <td class="caption">Collation</td>
              <td class="caption">Attribute</td>
              <td class="caption">Comment</td>
              <td><img src="/style/$m_sStyle/buttons/primary.png" alt="Add Primary Key" title="Add Primary Key"  width="16" height="16" align="left" border="0"/></td>
              </tr>
       );

        sessionValidity( 60* 60 );
        my $m_hUniqueRadio = Unique();

        my $m_hUniqueColField   = Unique();
        my $m_hUniqueColType    = Unique();
        my $m_hUniqueColLength  = Unique();
        my $m_hUniqueColNull    = Unique();
        my $m_hUniqueColKey     = Unique();
        my $m_hUniqueColDefault = Unique();
        my $m_hUniqueColExtra   = Unique();
        my $m_hUniqueColComment = Unique();
        my $m_hUniqueColAttrs   = Unique();

        $m_sContent .= qq|
              <tr>
              <td class="values"><input type="text" value="" name="$m_hUniqueColField" style="width:100px;"/></td>
              <td class="values">|
            . $m_oDatabase->GetTypes( 'INT', $m_hUniqueColType ) . qq{</td>
<td class="values">}
            . $m_oDatabase->GetTypes( 'INT', $m_hUniqueColType ) . qq{</td>
              <td class="values"><input type="text" value="" style="width:80px;" name="$m_hUniqueColLength"/></td>
              <td class="values">
              <select name="$m_hUniqueColNull" style="width:80px;">
              <option  value="not NULL">not NULL</option>
              <option value="NULL">NULL</option>
              </select>
              </td>
              <td class="values"><input type="text" value="" id="default" onkeyup="intputMaskType('default','$m_hUniqueColType')" name="$m_hUniqueColDefault" style="width:80px;"/></td>
              <td class="values">
              <select name="$m_hUniqueColExtra" style="width:80px;">
              <option value=""></option>
              <option value="auto_increment">auto_increment</option>
              </select>
              </td>
        };

        my $m_hUniqueColCollation = Unique();
        my $m_hUniqueColEngine    = Unique();

        my $qstringCol = createSession(
            {   user      => $m_sUser,
                action    => 'SaveNewColumn',
                table     => $tbl,
                Collation => $m_hUniqueColCollation,
                Engine    => $m_hUniqueColEngine,
                Primary   => $m_hUniqueColRadio,
                rows      => {
                    Field   => $m_hUniqueColField,
                    Type    => $m_hUniqueColType,
                    Length  => $m_hUniqueColLength,
                    Null    => $m_hUniqueColNull,
                    Key     => $m_hUniqueColKey,
                    Default => $m_hUniqueColDefault,
                    Extra   => $m_hUniqueColExtra,
                    Comment => $m_hUniqueColComment,
                    Attrs   => $m_hUniqueColAttrs,
                }
            }
        );
        my $sStart    = translate('startTable');
        my $sEnde     = translate('endTable');
        my $sInsert   = translate('insertAfter');
        my $sAfter    = translate('after');
        my $si        = translate('insert');
        my $collation = $m_oDatabase->GetCollation($m_hUniqueColCollation);
        my $atrrs = $m_oDatabase->GetAttrs( $tbl, "none", $m_hUniqueColAttrs );
        my $clmns = $m_oDatabase->GetColumns( $tbl, 'after_name' );
        $m_sContent .= qq(
              <td class="values">$collation</td>
              <td class="values">$atrrs</td>
              <td class="values"><input type="text" value="" name="$m_hUniqueColComment" align="left" style="width:80px;"/><br/></td>
              <td class="values">
              <input type="radio" class="radioButton" value="$m_hUniqueColField"  name="$m_hUniqueColRadio"/>
              </td>
              </tr>
              <tr>
              <td colspan="10"  >
              $sInsert&#160;$sStart<input type="radio" class="radioButton" value="first"  name="after_col" />&#160;
              $sEnde&#160;<input type="radio" class="radioButton" value="last"  name="after_col" checked="checked"/>&#160;
              $sAfter&#160;<input type="radio" class="radioButton" value="after"  name="after_col"/>
              $clmns&#160;
              <input type="submit" value="$si"/>
              </td>
              </td>
              </tr>
              </table>
              <input type="hidden" name="create_new_col_seesion" value="$qstringCol"/>
              </form>
              </div>
              </td></tr>
              </table>
              </form>
              </td></tr></table>
              </div>
       ) . br();

        my @index = $m_oDatabase->fetch_AoH("SHOW INDEX FROM $tbl2");

        $m_sContent
            .= '<table align="center" border="0" cellpadding="2" cellspacing="0" class="indexTable">';
        $m_sContent .= '
        <tr class="caption">
           <td class="caption">Non_unique</td>
           <td class="caption">Key_name</td>
           <td class="caption">Seq_in_index</td>
           <td class="caption">Column_name</td>
           <td class="caption">Cardinality</td>
           <td class="caption">Sub_part</td>
           <td class="caption">Packed</td>
           <td class="caption">Null</td>
           <td class="caption">Index_type</td>
           <td class="caption">Comment</td>
           <td class="caption"></td>
           <td class="caption"></td>
       </tr>';
        $m_sContent .= qq|
       <tr onmouseover="this.className='overDb';" onmouseout="this.className='';">
       <td class="values">$_->{'Non_unique'}</td>
       <td class="values">$_->{'Key_name'}</td>
       <td class="values">$_->{'Seq_in_index'}</td>
       <td class="values">$_->{'Column_name'}</td>
       <td class="values">$_->{'Cardinality'}</td>
       <td class="values">$_->{'Sub_part'}</td>
       <td class="values">$_->{'Packed'}</td>
       <td class="values">$_->{'Null'}</td>
       <td class="values">$_->{'Index_type'}</td>
       <td class="values">$_->{'Comment'}</td>
       <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowEditIndex;&amp;tbl=$tbl&amp;index=$_->{'Key_name'}&amp;editIndexOlp145656=1" title="Edit Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/edit.png" alt="Edit Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       <td class="values"><a href="$ENV{SCRIPT_NAME}?action=DropIndex;&amp;table=$tbl&amp;index=$_->{'Key_name'}" title="Drop Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/delete.png" alt="Drop Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       </tr>| foreach @index;

        $m_sContent .= '</table>';

        my $sIndexOver = translate('IndexOver');
        my $sSubmit    = translate('create');
        $m_sContent .= qq|
              <div align="center"><form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              $sIndexOver&#160;<input type="text" class="text" value="1"  name="over_cols" style="width:40px"/>&#160;
              &#160;<input type="submit" class="button" value="$sSubmit"  name="submit"/>
              <input type="hidden" value="ShowEditIndex" name="action"/>
              <input type="hidden" value="$tbl" name="tbl"/>
              </form></div>
       |;
        $m_sContent .= $window->windowFooter();
    } else {
        ShowTables();
    }
}

=head2 ShowEditIndex()

action

=cut

sub ShowEditIndex {
    my %parameter = (
        path     => $m_hrSettings->{cgi}{bin} . '/templates',
        style    => $m_sStyle,
        template => 'wnd.htm',
        title    => translate("NewIndex"),
        server   => $m_hrSettings->{serverName},
        id       => 'NewIndex',
        class    => 'none',
    );

    my $window = new HTML::Window( \%parameter );
    $RIBBONCONTENT .= $window->windowHeader();
    my $tbl             = param('tbl');
    my $tbl2            = $m_dbh->quote_identifier($tbl);
    my $cls             = param('over_cols');
    my $m_hUniqueTyp       = Unique();
    my $m_hUniqueIndexName = Unique();
    my $sField          = translate('field');
    my $sSize           = translate('size');
    my $sName           = translate('name');
    my $sTyp            = translate('type');
    my $iname           = param('index') ? param('index') : '';
    my $hashref         = $m_oDatabase->fetch_hashref(
        "SHOW INDEX FROM $tbl2 where `Key_name` = ?", $iname );
    $RIBBONCONTENT .= qq|
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <table cellspacing="0" cellpadding="2" border="0" align="center" summary="ShowEditIndex" width="100%">
                     <tr><td>
                            $sName&#160; <input type="text" value="$iname" name="$m_hUniqueIndexName"/>
                     </td><td>
                            $sTyp&#160;
                            <select name="$m_hUniqueTyp">
                            <option  value="PRIMARY" |
        . ( $hashref->{Key_name} eq 'PRIMARY' ? 'selected="selected"' : '' )
        . qq|>PRIMARY</option>
                            <option value="INDEX" |
        . ( $hashref->{Index_type} eq 'BTREE' ? 'selected="selected"' : '' )
        . qq|>INDEX</option>
                            <option value="UNIQUE" >UNIQUE</option>
                            <option value="FULLTEXT" |
        . (
        $hashref->{Index_type} eq 'FULLTEXT' ? 'selected="selected"' : '' )
        . qq|>FULLTEXT</option>
                            </select>
                     </td></tr>
                     <tr><td class="caption">$sField</td><td class="caption">$sSize</td></tr>
       |;

    if( param('editIndexOlp145656') ) {
        my $keyName = param('index');
        my @index   = $m_oDatabase->fetch_AoH("SHOW INDEX FROM $tbl2");
        for( my $i = 0; $i < $#index; ++$i ) {
            next if $index[$i]->{Key_name} ne $keyName;
            my $uName   = Unique();
            my $uSize   = Unique();
            my $columns = $m_oDatabase->GetColumns( $tbl, $uName,
                $index[$i]->{Column_name} );
            $RIBBONCONTENT
                .= qq|<tr><td class="values">$columns</td><td class="values"><input type="text" value="$index[$i]->{Sub_part}" name="$uSize" style="width:40px;"/></td></tr>|;
            push @FILDS,
                {
                name => $uName,
                size => $uSize,
                };
        }
    } else {
        for( my $i = 0; $i < $cls; $i++ ) {
            my $uName   = Unique();
            my $uSize   = Unique();
            my $columns = $m_oDatabase->GetColumns( $tbl, $uName, );
            $RIBBONCONTENT
                .= qq|<tr><td>$columns</td><td><input type="text" value="" name="$uSize" style="width:40px;"/></td></tr>|;
            push @FILDS,
                {
                name => $uName,
                size => $uSize,
                };
        }
    }
    my $qstring = createSession(
        {   user   => $m_sUser,
            action => 'SaveNewIndex',
            table  => $tbl,
            name   => $m_hUniqueIndexName,
            typ    => $m_hUniqueTyp,
            fields => [@FILDS],
        }
    );

    my $ers = translate('createIndex');
    $RIBBONCONTENT .= qq|
                     <tr><td colspan="2" align="right"><input type="submit" class="button" value="$ers" name="submit"/></td></tr>
                     </table>
                     <input type="hidden" value="SaveNewIndex" name="action"/>
                     <input type="hidden" value="$qstring" name="save_new_indexhjfgzu"/>
                     <input type="hidden" value="$iname" name="oldname"/>
      |;
    $RIBBONCONTENT
        .= '<input type="hidden" value="1" name="editIndexOlp145656"/>'
        if param('editIndexOlp145656');
    $RIBBONCONTENT .= '</form></div>' . $window->windowFooter();
    EditTable($tbl);
}

=head2 SaveEditTable()


=cut

sub SaveNewIndex {
    my $session = param('save_new_indexhjfgzu');
    session( $session, $m_sUser );
    my $tbl = $m_hrParams->{table};
    if( defined $tbl and defined $session ) {
        my $tbl2  = $m_dbh->quote_identifier($tbl);
        my $name  = $m_dbh->quote_identifier( param( $m_hrParams->{name} ) );
        my $oname = $m_dbh->quote_identifier( param('oldname') );
        my $typ   = param( $m_hrParams->{typ} );
        my $sql   = qq|ALTER TABLE $tbl2 |
            . (
            param('editIndexOlp145656')
            ? ( param('oldname') eq 'PRIMARY'
                ? 'DROP PRIMARY KEY'
                : "DROP INDEX $oname,"
                )
            : ''
            ) . qq| ADD $typ $name(|;
        for( my $i = 0; $i <= $#{ $m_hrParams->{fields} }; $i++ ) {
            my $field = $m_dbh->quote_identifier(
                param( $m_hrParams->{fields}[$i]{name} ) );
            my $m_nSize
                = param( $m_hrParams->{fields}[$i]{size} ) =~ /(\d+)/
                ? $1
                : 0;
            $sql .= qq|$field|;
            $sql .= qq|($m_nSize)| if $m_nSize;
            $sql .= ',' unless $i== $#{ $m_hrParams->{fields} };
        }
        $sql .= ')';
        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 SaveEditTable()


=cut

sub SaveEditTable {
    my $session = param('change_col_sessionRTZHBG');
    session( $session, $m_sUser );
    my $tbl = $m_hrParams->{table};

    if( defined $tbl and defined $session ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql;
        foreach my $row ( keys %{ $m_hrParams->{rows} } ) {
            my $newrow = param( $m_hrParams->{rows}{$row}{Field} );
            my $type   = param( $m_hrParams->{rows}{$row}{Type} );
            my $length = param( $m_hrParams->{rows}{$row}{Length} );
            $type
                = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type
                : $length ? $type . "($length)"
                :           $type;

            my $character_set = $m_oDatabase->GetCharacterSet(
                param( $m_hrParams->{rows}{$row}{Collation} ) );
            my $collation = param( $m_hrParams->{rows}{$row}{Collation} );
            my $null      = param( $m_hrParams->{rows}{$row}{Null} );
            my $comment   = param( $m_hrParams->{rows}{$row}{Comment} );
            my $extra     = param( $m_hrParams->{rows}{$row}{Extra} );
            my $default   = param( $m_hrParams->{rows}{$row}{Default} );
            my $attrs     = param( $m_hrParams->{rows}{$row}{Attrs} );
            my $row2      = $m_dbh->quote_identifier($row);
            my $newrow2   = $m_dbh->quote_identifier($newrow);
            $default
                = ( ( $default || $default =~ /0/ )
                    && $default ne "CURRENT_TIMESTAMP" )
                ? ' default '
                . $m_dbh->quote($default)
                : '';
            my $vcomment = $m_dbh->quote($comment);
            $sql
                .= "ALTER TABLE $tbl2 DROP PRIMARY KEY, ADD constraint PRIMARY KEY ($newrow2);$/"
                if $newrow eq param('AddPrimaryKey');
            $sql .= "ALTER TABLE $tbl2 CHANGE $row2 $newrow2 $type";
            $sql .= " auto_increment " if $extra eq 'auto_increment';

            if($collation) {
                $sql .= " CHARACTER SET $character_set COLLATE $collation"
                    unless $character_set eq 'binary'
                        or $collation eq 'NULL';
            }
            $sql .= " $attrs";
            $sql .= " $null ";
            $sql .= " COMMENT $vcomment" if $comment;
            $sql .= $default if $default;
            $sql .= ";$/";

        }

        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 SaveNewColumn()

       SaveNewColumn()

=cut

sub SaveNewColumn {
    my $session   = param('create_new_col_seesion');
    my $after_col = param('after_col');
    session( $session, $m_sUser );
    my $tbl = $m_hrParams->{table};

    if( defined $tbl and defined $session ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $sql;
        my $newrow = param( $m_hrParams->{rows}{Field} );
        my $type   = param( $m_hrParams->{rows}{Type} );
        my $length = param( $m_hrParams->{rows}{Length} );
        $type
            = $type =~ /Blob|TEXT|TIMESTAMP/ ? $type
            : $length ? $type . "($length)"
            :           $type;
        my $character_set = $m_oDatabase->GetCharacterSet(
            param( $m_hrParams->{Collation} ) );
        my $collation = param( $m_hrParams->{Collation} );
        my $null      = param( $m_hrParams->{rows}{Null} );
        my $comment   = param( $m_hrParams->{rows}{Comment} );
        my $extra     = param( $m_hrParams->{rows}{Extra} );
        my $default   = param( $m_hrParams->{rows}{Default} );
        my $attrs     = param( $m_hrParams->{rows}{Attrs} );

        my $newrow2 = $m_dbh->quote_identifier($newrow);
        $default
            = ( ( $default || $default =~ /0/ )
                && $default ne "CURRENT_TIMESTAMP" )
            ? ' default '
            . $m_dbh->quote($default)
            : '';
        my $vcomment = $m_dbh->quote($comment);

        $sql .= "ALTER TABLE $tbl2 ADD  $newrow2 $type";
        $sql .= " auto_increment " if $extra eq 'auto_increment';
        if($collation) {
            $sql .= " CHARACTER SET $character_set COLLATE $collation"
                unless ( $character_set eq 'binary' or $collation eq 'NULL' );
        }
        $sql .= " $attrs";
        $sql .= " $null ";
        $sql .= " COMMENT $vcomment" if $comment;
        $sql .= $default if $default;
        $sql .= ' first' if $after_col eq ' first';
        $sql .= 'after ' . param('after_name') if $after_col eq 'after';
        $sql .= ";$/";

        ExecSql($sql);
        EditTable($tbl);
    } else {
        ShowTables();
    }

}

=head2 RenameTable()

       RenameTable(oldname,newname)

=cut

sub RenameTable {
    my $tbl    = param('table')    ? param('table')    : shift;
    my $newtbl = param('newTable') ? param('newTable') : shift;

    if( defined $tbl && defined $newtbl ) {
        my $tbl2    = $m_dbh->quote_identifier($tbl);
        my $newtbl2 = $m_dbh->quote_identifier($newtbl);
        ExecSql("ALTER TABLE $tbl2 RENAME $newtbl2;");
        EditTable($newtbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeEngine()


=cut

sub ChangeEngine {
    my $tbl    = param('table')  ? param('table')  : shift;
    my $engine = param('engine') ? param('engine') : shift;
    if( defined $engine && defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $engine = $m_oDatabase->quote($engine);
        ExecSql("ALTER TABLE $tbl2 ENGINE = $engine");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeAutoInCrementValue()

       AUTO_INCREMENT für tabelle setzen

       ChangeAutoInCrementValue

=cut

sub ChangeAutoInCrementValue {
    my $tbl   = param('table')          ? param('table')          : shift;
    my $p_key = param('AUTO_INCREMENT') ? param('AUTO_INCREMENT') : shift;
    if( defined $p_key && defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql("ALTER TABLE $tbl2 AUTO_INCREMENT = $p_key");
        EditTable($tbl);
    } else {
        ShowTables();
    }
}

#Html elemente

=head2 ShowDbHeader()

        gibt die navigationszeile für eine tabelle aus

=cut

sub ShowDbHeader {
    my $tbl      = shift;
    my $selected = shift;
    my $current  = shift;

    my %parameter = (
        style      => $m_sStyle,
        path       => "$m_hrSettings->{cgi}{bin}/templates",
        template   => 'ribbon.htm',
        action     => $m_hrAction,
        scriptname => $ENV{SCRIPT_NAME},
        style      => $m_sStyle,
        path       => "$m_hrSettings->{cgi}{bin}/templates",
        template   => 'ribbon.htm',
        action     => $m_hrAction,
        scriptname => $ENV{SCRIPT_NAME},
        anchors    => [
            {   text    => translate('database'),
                src     => 'link.png',
                href    => 'javascript:void(0);',
                onclick => "showDatabaseMenu(this.id)",
                class   => $selected || param('sql') ? 'link' : 'currentLink',
            },

            {   text    => translate('Sql'),
                onclick => "showSqlEditor(this.id)",
                href    => 'javascript:void(0);',
                class   => param('sql') ? 'currentLink' : 'link',
            },
        ],
    );
    push @{ $parameter{anchors} },
        {
        text    => translate('table'),
        onclick => "showTableMenu(this.id)",
        class   => 'currentLink',
        href    => 'javascript:void(0);',
        }
        if $selected;
    my $rb = new HTML::TabWidget();
    $m_sContent .= $rb->Menu( \%parameter );
    $m_sContent .= tabwidgetHeader();

    $m_sContent .= '<div id="TableMenu" '
        . ( $selected ? '' : 'style="display:none;"' ) . '>';

    $m_sContent .= a(
        {   class => $current eq "Show" ? 'currentLink' : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=ShowTable&amp;table=$tbl",
            title => translate("Show") . "($tbl)"
        },
        translate("Daten") . "($tbl)"
    ) . '&#160;|&#160;';

    $m_sContent .= a(
        {   class => $current eq "Edit" ? 'currentLink' : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=EditTable&amp;table=$tbl",
            title => translate("Edit")
        },
        translate("Edit")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "Details" ? 'currentLink' : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ShowTableDetails&amp;table=$tbl",
            title => translate("Details")
        },
        translate("Details")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "Export" ? 'currentLink' : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=ShowDumpTable&amp;table=$tbl",
            title => translate("Export")
        },
        translate("Export")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "AnalyzeTable"
            ? 'currentLink'
            : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=AnalyzeTable&amp;table=$tbl",
            title => translate("AnalyzeTable")
        },
        translate("AnalyzeTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "OptimizeTable"
            ? 'currentLink'
            : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=OptimizeTable&amp;table=$tbl",
            title => translate("OptimizeTable")
        },
        translate("OptimizeTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "RepairTable"
            ? 'currentLink'
            : 'link',
            href  => "$ENV{SCRIPT_NAME}?action=RepairTable&amp;table=$tbl",
            title => translate("RepairTable")
        },
        translate("RepairTable")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   class => $current eq "NewEntry"
            ? 'currentLink'
            : 'link',
            href  => "javascript:showNewEntry()",
            title => translate("showNewEntry")
        },
        translate("NewEntry")
    ) . '&#160;|&#160;';
    $m_sContent .= a(
        {   href    => "$ENV{SCRIPT_NAME}?action=DropTable&amp;table=$tbl",
            title   => translate("Delete"),
            onclick => "return confirm('" . translate("Delete") . "?')"
        },
        translate("Delete")
    );

    $m_sContent .= qq|$PAGES</div><div id="NewEntry" style="display:none;">|;
    &ShowNewEntry($tbl) if $m_oDatabase->tableExists($tbl);

    $m_sContent .= qq|</div><div id="DatabaseMenu" |
        . ( $selected ? 'style="display:none;"' : '' ) . '>';
    $m_sContent .= a(
        {

            class => $current eq "Show"
            ? 'currentLink'
            : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ShowTables&amp;database=$m_sCurrentDb",
            title => translate("ShowTables") . "($m_sCurrentDb)"
        },
        translate("Datenbank") . "($m_sCurrentDb)"
    ) . '|';
    $m_sContent .= a(
        {   class => $current eq "Export" ? 'currentLink' : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ShowDumpDatabase&amp;database=$m_sCurrentDb",
            title => translate("ExportDatabase"),
        },
        translate("Export")
    );
    my $sql      = defined param('sql') ? param('sql') : $SQL;
    my $exec     = translate('ExecSql');
    my $newtable = translate('newtable');
    my $fields   = translate('fields');

    $m_sContent .= qq|<br/>
   <table align="center" border="0" cellspacing="5" cellpadding="0"  summary="layout">
    <tr>
      <td valign="top">
<form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
<table align="left" border="0" cellspacing="0" cellpadding="2"  summary="newTable">
    <tr>
      <td class="caption" colspan="4">| . translate('CreateTable') . qq|</td>
    </tr>
    <tr>
      <td class="values"><input type="text" name="table" value="Name" onfocus="this.value=''" style="width:80px;" /></td>
      <td class="values">$fields:</td>
      <td class="values"><input type="text" name="count" value="1" style="width:40px;" id="fields4tbl" onkeyup="intputMask('fields4tbl',/(\\d+)/)" /></td>
      <td class="values"><input type="submit" name="submit" value="$newtable" /></td>
    </tr>
</table>
<input type="hidden" name="action" value="ShowNewTable" />
</form>
</td><td>
<form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
    <input type="hidden" name="m_ChangeCurrentDb" value="$m_sCurrentDb"/>
    <table align="left" border="0" cellspacing="0" cellpadding="2" summary="M_currentDb">
    <tr>
      <td class="caption">Host</td>
      <td class="caption">User</td>
      <td class="caption">Password</td>
      <td class="caption"></td>
    </tr>
    <tr>
      <td class="values"><input type="text" name="m_shost" value="$m_sCurrentHost"/></td>
      <td class="values"><input type="text" name="m_suser" value="$m_sCurrentUser"/></td>
      <td class="values"><input type="password" name="m_spass" value="$m_sCurrentPass"/></td>
      <td class="values"><input type="submit" name="submit" value="connect" /></td>
    </tr>
</table>
</form><br/><br/>
</td>
    </tr>
</table>
</div>
<div id="SqlEditor" style="display:none;">
<br/>
<form action ="$ENV{SCRIPT_NAME}" method="post">
<table cellspacing="5" cellpadding="0" border="0" align="center" summary="SQL" width="100%">
<tr>
<td align="left">$exec</td>
</tr>
<tr>
<td><textarea cols="150" rows="20" name="sql" class="sqlEdit" id="sqlEdit"  style="width:100%;height:100px;" >$sql </textarea></td>
</tr>
<tr>
<td align="right"><input type="hidden" value="$current" name="goto"/><input type="hidden" value="SQL" name="action"/><input type="submit" value="Exec"/></td>
</tr>
</table>
</form>
</div>
<div>
<div id="EXECSQL">$RIBBONCONTENT</div>
</div>
| . tabwidgetFooter();

}

=head2 AnalyzeTable()

       DropColumn(table)

=cut

#todo
sub AnalyzeTable {
    my $tbl = param('table') ? param('table') : shift;
    if( defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql( "ANALYZE TABLE $tbl2", 1 );
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 RepairTable()

       RepairTable(table)

=cut

sub RepairTable {
    my $tbl = param('table') ? param('table') : shift;
    if( defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql( "REPAIR TABLE $tbl2", 1 );
        ShowTable($tbl);
    } else {
        ShowTables();
    }

}

=head2 OptimizeTable()

       OptimizeTable(table)

=cut

sub OptimizeTable {
    my $tbl = param('table') ? param('table') : shift;
    if( defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        ExecSql( "OPTIMIZE TABLE $tbl2", 1 );
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

# SHOW VARIABLES;
