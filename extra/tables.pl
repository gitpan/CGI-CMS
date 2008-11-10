use vars qw/%uniq $EXECSQL $PAGES $SQL/;
no warnings "uninitialized";

ChangeDb(
    {   name     => $m_sCurrentDb,
        host     => $m_hrSettings->{database}{host},
        user     => $m_hrSettings->{database}{user},
        password => $m_hrSettings->{database}{password},

    }
);    #todo
$PAGES = "<br/><br/>";

#todo:
# Index bearbeiten.
# multiple action,  multipleEdit
#ChangeEngine NewDatabase ChangeAutoInCrementValue

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
       <table border="0" cellpadding="0" cellspacing="0" class="dataBaseTable">
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
        my $atrrs         = GetAttrs( $tbl, "none", $m_hUniqueAttrs );
        $m_sContent .= qq|
              <tr>
              <td calss="values"><input type="text" value="" name="$m_hUniqueField"/></td>
              <td calss="values">| . GetTypes( 'INT', $m_hUniqueType ) . qq{</td>
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
    my $collation = GetCollation($m_hUniqueCollation);
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
            my $type = param( $m_hrParams->{rows}{$row}{Type} );
            $type
                = $type =~ /Blob|TEXT|TIMESTAMP/
                ? $type
                : $type . '(' . param( $m_hrParams->{rows}{$row}{Length} ) . ')';
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

        my $character_set = GetCharacterSet( param( $m_hrParams->{Collation} ) );
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

        Export Tabelle

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
            $sql .= $m_oDatabase->quote( $a[$n]->{ $columns[$i]->{'Field'} } );
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

       DropIndex(table,name)

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
    my $tbl   = param('table')  ? param('table')  : shift;
    my $uname = param('column') ? param('column') : shift;
    if( $m_oDatabase->tableExists($tbl) && defined $uname ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $uname = $m_dbh->quote_identifier($uname);
        ExecSql("Alter TABLE $tbl2 DROP INDEX ($uname)");
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

    $EXECSQL
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
                        $EXECSQL .= br() . join( br(), @a );
                        $id++;
                    }
                }
            }
            $EXECSQL
                .= br()
                . $window3->windowHeader()
                . HighlightSQl($s)
                . br()
                . $m_dbh->errstr
                . $window3->windowFooter()
                if $@;

        };
        $id2++;
        $EXECSQL .= br() . translate('rows in effect') . $rows_affected
            if( $rows_affected > 0 && $showSql );
    }
    $EXECSQL .= '</div><br/>' if $showSql;
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

        my @a = $m_oDatabase->fetch_AoH(
            "select * from $tb2 order by $qfield $desc LIMIT $m_nStart , $lpp");
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
        my $p_key = GetPrimaryKey($tbl);
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
                .= qq|<td><a href="$ENV{SCRIPT_NAME}?action=EditEntry&amp;table=$tbl&amp;edit=$a[$i]->{$p_key}&amp;von=$m_nStart&amp;bis=$m_nEnd;"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="Edit" title="$tredit"/></a><a href ="$ENV{SCRIPT_NAME}?action=DeleteEntry&amp;table=$tbl&amp;delete=$a[$i]->{$p_key}&amp;von=$m_nStart;&amp;bis=$m_nEnd;" onclick="return confirm('$trdelete ?')"><img src="/style/$m_sStyle/buttons/delete.png" border="0" alt="delete" title="$trdelete"/></a></td></tr>|;
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
              <option value="edit">$edit</option>
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
    my $p_key  = GetPrimaryKey($tbl);
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
    } else {
        ShowDbHeader( $m_sCurrentDb, 1, 'Show' );
    }
    for( my $i = 0; $i <= $#params; $i++ ) {
        if( $m_hrParams[$i] =~ /markBox\d?/ ) {
            my $col = param( $m_hrParams[$i] );
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
                if( $a eq "edit" ) {    #todo
                    ExecSql("truncate $tbl2");
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
        $m_sContent .= qq(<textarea style="width:100%;height:800px;">);
    } else {
        ShowDbHeader( $m_sCurrentDb, 0, 'Show' );
    }
    for( my $i = 0; $i <= $#params; $i++ ) {
        if( $m_hrParams[$i] =~ /markBox\d?/ ) {
            my $tbl  = param( $m_hrParams[$i] );
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
        my $p_key   = GetPrimaryKey($tbl);
        my $ed      = translate('Edit Entry');
        my $a       = $m_oDatabase->fetch_hashref(
            "select * from $tbl2 where $p_key = ?", $rid );
        my %parameter = (
            path     => $m_hrSettings->{cgi}{bin} . '/templates',
            style    => $m_sStyle,
            template => 'wnd.html',
            title    => translate("EditEntry"),
            server   => $m_hrSettings->{serverName},
            id       => 'EditEntry',
            class    => 'max',
        );
        my $window = new HTML::Window( \%parameter );
        $m_sContent
            .= br()
            . $window->windowHeader()
            . qq(<div align="center"><p>$ed</p><form action="$ENV{SCRIPT_NAME}" method="post"  enctype="multipart/form-data"><input type="hidden" name="action" value="SaveEntry"/><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout"><tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);

        for( my $j = 0; $j <= $#caption; $j++ ) {
        SWITCH: {
                if( $caption[$j]->{'Type'} eq "text" ) {
                    $m_sContent
                        .= qq(<tr><td>$caption[$j]->{'Field'} </td><td><textarea name="tbl$caption[$j]->{'Field'}" align="left" style="width:100%>$a->{$caption[$j]->{'Field'}}</textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $m_sContent
                    .= qq(<tr><td >$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="$a->{$caption[$j]->{'Field'}}" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
            }
        }
        my $trsave = translate('save');
        $m_sContent
            .= qq(</table><br/><input type="submit" value="$trsave"/><input type="hidden" name="id" value="$rid"/><input type="hidden" name="table" value="$tbl"/><input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/><br/><br/></form></div>);
        $m_sContent .= $window->windowFooter();
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
            {   name     => $m_sCurrentDb,
                host     => $m_hrSettings->{database}{host},
                user     => $m_hrSettings->{database}{user},
                password => $m_hrSettings->{database}{password},

            }
        );
    }
    my @id
        = $m_oDatabase->fetch_array( "select id from `actions` where action=?",
        $name );
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
            {   name     => $m_sCurrentDb,
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
            {   name     => $m_sCurrentDb,
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
                        .= qq(<tr><td class="caption" >$caption[$j]->{'Field'}</td><td><textarea name="tbl$caption[$j]->{'Field'}" value="" align="left" style="width:100%"></textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                    last SWITCH;
                }
                $m_sContent
                    .= qq(<tr><td>$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
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
        my $p_key = GetPrimaryKey($tbl);
        while( $i < $#params ) {
            $i++;
            my $pa = param( $m_hrParams[$i] );
            if( $m_hrParams[$i] =~ /tbl.*/ ) {
                $m_hrParams[$i] =~ s/tbl//;
                $eid = $pa if( $m_hrParams[$i] eq $p_key );
                unshift @rows,
                      ""
                    . $m_dbh->quote_identifier( $m_hrParams[$i] ) . " = "
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
            my $pa = param( $m_hrParams[$i] );
            if( $m_hrParams[$i] =~ /tbl.*/ ) {
                $m_hrParams[$i] =~ s/tbl//;
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
        my $p_key = GetPrimaryKey($tbl);
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
        my $change     = translate('Edit Table');
        $m_sContent .= qq(
              <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
              <td width="20" class="values"><input type="checkbox" name="markBox$i" class="markBox" value="$a[$i]->{Name}" /></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowTable&amp;table=$a[$i]->{Name}&amp;desc=0">$a[$i]->{Name}</a></td>
              <td class="values">$a[$i]->{Rows}</td><td class="values">$a[$i]->{Engine}</td><td class="values">$kb</td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=DropTable&amp;table=$a[$i]->{Name}" onclick="return confirm(' $trdelete?')"><img src="/style/$m_sStyle/buttons/delete.png" align="middle" alt="" border="0"/></a></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=EditTable&amp;table=$a[$i]->{Name}"><img src="/style/$m_sStyle/buttons/edit.png" border="0" alt="$change" title="$change"/></a></td>
              <td class="values"><a href="$ENV{SCRIPT_NAME}?action=ShowTableDetails&amp;table=$a[$i]->{Name}">Details</a></td>
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
              <td colspan="6" align="left">
              <a id="markAll" href="javascript:markInput(true);" class="links">$markAll</a><a class="links" id="umarkAll" style="display:none;" href="javascript:markInput(false);">$umarkAll</a></td>
              <td align="right">
              <select  name="MultipleDbAction" onchange="this.form.submit();">
              <option  value="$mmark" selected="selected">$mmark</option>
              <option value="delete">$delete</option>
              <option value="export">$export</option>
              <option value="truncate">$truncate</option>
              <option value="optimize">$optimize</option>
              <option value="repair">$repair</option>
              </select>
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
    $m_sContent .= '<div align="left" class="dumpBox" style="width:100%">';

    my $name = param('table');
    my @a    = $m_oDatabase->fetch_AoH("SHOW TABLE STATUS");
    $m_sContent .= qq(<div align="center">
              <table align="center" border="0" cellpadding="2"  cellspacing="0" summary="ShowTables">
              <tr><td colspan="2" align="left">$name</td></tr>
              <tr><td class="caption">Name</td><td class="caption">Value</td></tr>);

    for( my $i = 0; $i <= $#a; $i++ ) {
        if( $a[$i]->{Name} eq $name ) {
            foreach my $key ( keys %{ $a[0] } ) {
                $m_sContent
                    .= qq(<tr class="value" align="left"><td class="value" align="left">$key</td><td class="value" align="left">$a[$i]->{$key}</td></tr>);
            }
        }
    }
    $m_sContent .= qq(</table></div>);
    $m_sContent .= '</div><br/>' . $window->windowFooter();
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
        my $tbl2     = $m_dbh->quote_identifier($tbl);
        my @caption  = $m_oDatabase->fetch_AoH("show full columns from $tbl2");
        my $clm      = GetPrimaryKey($tbl);
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
              <div align="center">
              <table border="0" cellpadding="0" cellspacing="2" class="dataBaseTable">
              <tr >
              <td >
              <form action="" enctype="multipart/form-data" accept-charset="ISO-8859-1"><input type="hidden" name="action" value="RenameTable"/>
              <table border="0"  align="left"  cellpadding="2" cellspacing="0" class="dataBaseTable">
              <tr ><td align="left">
              <input type="hidden" name="table" value="$tbl"/><input type="text" align="bottom" name="newTable" value="$tbl"/></td><td><input type="submit" name="submit" value="$rename"/></td>
              </tr></table>
              </form>
              </td>
              <tr><td>
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
                . GetTypes( $caption[$j]->{'Type'}, $m_hUniqueType ) . qq|</td>
              <td><input type="text" value="$length" style="width:80px;" name="$m_hUniqueLength"/></td>
              <td>|
                . GetNull( $caption[$j]->{'Null'}, $m_hUniqueNull ) . qq|</td>
              <td><input type="text" value="$caption[$j]->{'Default'}" style="width:80px;" name="$m_hUniqueDefault"/></td>
              <td>|
                . GetExtra( $caption[$j]->{'Extra'}, $m_hUniqueExtra ) . '</td>
              <td>'
                . GetColumnCollation( $tbl, $field, $m_hUniqueCollation )
                . qq{</td> <td>}
                . GetAttrs( $tbl, $field, $m_hUniqueAttrs )
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
              <tr><td colspan="10" align="left">$newCol</td></tr>
              <tr class="caption">
              <td>Field</td>
              <td>Type</td>
              <td>LENGTH</td>
              <td>Null</td>
              <td>Default</td>
              <td>Extra</td>
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
              <td><input type="text" value="" name="$m_hUniqueColField" style="width:100px;"/></td>
              <td>| . GetTypes( 'INT', $m_hUniqueColType ) . qq{</td>
              <td><input type="text" value="" style="width:80px;" name="$m_hUniqueColLength"/></td>
              <td>
              <select name="$m_hUniqueColNull" style="width:80px;">
              <option  value="not NULL">not NULL</option>
              <option value="NULL">NULL</option>
              </select>
              </td>
              <td><input type="text" value="" id="default" onkeyup="intputMaskType('default','$m_hUniqueColType')" name="$m_hUniqueColDefault" style="width:80px;"/></td>
              <td>
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
        my $collation = GetCollation($m_hUniqueColCollation);
        my $atrrs     = GetAttrs( $tbl, "none", $m_hUniqueColAttrs );
        my $clmns     = GetColumns( $tbl, 'after_name' );
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
              <input type="submit" value="$save" />
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
            .= '<table align="center" border="0" cellpadding="0" cellspacing="0" class="indexTable">';
        $m_sContent .= '<tr class="caption">
           <td class="caption">
           Non_unique</td>
           <td class="caption">
           Key_name</td>
           <td class="caption">
           Seq_in_index</td>
           <td class="caption">
           Column_name</td>
           <td class="caption">
           Cardinality</td>
           <td class="caption">
           Sub_part</td>
           <td class="caption">
           Packed</td>
           <td class="caption">
           Null</td>
           <td class="caption">
           Index_type</td>
           <td class="caption">
           Comment</td>
           <td class="caption"></td><td class="caption"></td></tr>';
        $m_sContent .= qq|
       <tr onmouseover="this.className = 'overDb';" onmouseout="this.className = '';">
       <td>$_->{'Non_unique'}</td>
       <td>$_->{'Key_name'}</td>
       <td>$_->{'Seq_in_index'}</td>
       <td>$_->{'Column_name'}</td>
       <td>$_->{'Cardinality'}</td>
       <td>$_->{'Sub_part'}</td>
       <td>$_->{'Packed'}</td>
       <td>$_->{'Null'}</td>
       <td>$_->{'Index_type'}</td>
       <td>$_->{'Comment'}</td>
       <td><a href="?action=EditIndex;&amp;table=$tbl&amp;index=$_->{'Key_name'}" title="Edit Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/edit.png" alt="Edit Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       <td><a href="?action=DropIndex;&amp;table=$tbl&amp;index=$_->{'Key_name'}" title="Drop Index $_->{'Key_name'}"><img src="/style/$m_sStyle/buttons/delete.png" alt="Drop Index $_->{'Key_name'}" width="16" height="16" align="left" border="0"/></a></td>
       </tr>| foreach @index;
        $m_sContent .= '</table>';
        my $sIndexOver = translate('IndexOver');
        my $sSubmit    = translate('save');
        $m_sContent .= qq|
          <div align="center"><form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
          $sIndexOver&#160;<input type="text" class="text" value="1"  name="over_cols" style="width:40px"/>&#160;
          &#160;<input type="button" class="button" value="$save"  name="submit"/>
          <input type="hidden" value="ShowEditIndex" name="action"/>
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
        template => 'wnd.html',
        title    => translate("EditEntry"),
        server   => $m_hrSettings->{serverName},
        id       => 'EditEntry',
        class    => 'max',
    );
    my $window = new HTML::Window( \%parameter );
    $m_sContent .= $window->windowHeader();

    my $tbl = param('tbl');
    my $cls = param('over_cols');

    my $m_hUniqueTyp       = Unique();
    my $m_hUniqueIndexName = Unique();
    my $sField          = translate('field');
    my $sSize           = translate('size');
    my $sName           = translate('name');
    my $sTyp            = translate('type');
    $m_sContent .= qq|
              <div align="center">
              <form action="$ENV{SCRIPT_NAME}" method="post" enctype="multipart/form-data">
              <table>
                     <tr><td>
                            $sName&#160; <input type="text" value="SaveNewIndex" name="$m_hUniqueIndexName"/>
                     </td><td>
                            $sTyp&#160;
                            <select name="$m_hUniqueTyp">
                            <option  value="PRIMARY">PRIMARY</option>
                            <option value="INDEX">INDEX</option>
                            <option value="UNIQUE">UNIQUE</option>
                            <option value="FULLTEXT">FULLTEXT</option>
                            </select>
                     </td></tr>
                     <tr><td class="caption">$sField</td><td class="caption">$sSize</td></tr>
       |;

    for( my $i = 0; $i < $cls; $i++ ) {
        my $uName   = Unique();
        my $uSize   = Unique();
        my $columns = GetColumns( $tbl, $uName );

        $m_sContent
            .= qq|<tr><td>$columns</td><td><input type="text" value="SaveNewIndex" name="$uSize" style="width:40px;"/></td></tr>|;

        push @FILDS,
            {
            name => $uName,
            size => $uSize,
            };
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
    my $save = translate('save');
    $m_sContent .= qq|
                     <tr><td colspan="2" align="right"><input type="button" class="button" value="$save" name="submit"/></td></tr>
                     </table>
                     <input type="hidden" value="SaveNewIndex" name="action"/>
                     <input type="hidden" value="$qstring" name="save_new_indexhjfgzu"/>
                     </form>
                     </div>
       |;
    $m_sContent .= $window->windowFooter();
    EditTable($tbl);
}

=head2 SaveEditTable()


=cut

sub SaveNewIndex {
    my $session = param('save_new_indexhjfgzu');
    session( $session, $m_sUser );
    my $tbl = $m_hrParams->{table};
    if( defined $tbl and defined $session ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        my $name = $m_oDatabase->quote( $m_hrParams->{name} );
        my $sql  = qq|ALTER TABLE $tbl2 ADD FULLTEXT $name(|;
        foreach ( $m_hrParams->{fields} ) {
            my $field = $m_oDatabase->quote( param( $m_hrParams->{fields}{name} ) );
            my $m_nSize  = $m_oDatabase->quote( param( $m_hrParams->{fields}{size} ) );
            $sql .= qq|$field( $m_nSize )|;
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
            $type
                = $type =~ /Blob|TEXT|TIMESTAMP/
                ? $type
                : $type . '(' . param( $m_hrParams->{rows}{$row}{Length} ) . ')';
            my $character_set = GetCharacterSet(
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
            $sql .= " CHARACTER SET $character_set COLLATE $collation"
                unless $character_set eq 'binary'
                    or $collation eq 'NULL';
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
        $type
            = $type =~ /Blob|TEXT|TIMESTAMP/
            ? $type
            : $type . '(' . param( $m_hrParams->{rows}{Length} ) . ')';
        my $character_set = GetCharacterSet( param( $m_hrParams->{Collation} ) );
        my $collation     = param( $m_hrParams->{Collation} );
        my $null          = param( $m_hrParams->{rows}{Null} );
        my $comment       = param( $m_hrParams->{rows}{Comment} );
        my $extra         = param( $m_hrParams->{rows}{Extra} );
        my $default       = param( $m_hrParams->{rows}{Default} );
        my $attrs         = param( $m_hrParams->{rows}{Attrs} );

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

=head2 GetPrimaryKey()

       liefert die primary_key der tabelle zurück

       GetPrimaryKey(table)

=cut

sub GetPrimaryKey {
    my $tbl = shift;
    if( defined $tbl ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tbl");
        for( my $j = 0; $j <= $#caption; $j++ ) {
            return $caption[$j]->{'Field'}
                if( $caption[$j]->{'Key'} eq 'PRI' );
        }
    } else {
        return 0;
    }
}

=head2 GetAutoIncrement()

       liefert die auto_increment zeile zurück

       GetAutoIncrement(table)

=cut

sub GetAutoIncrement {
    my $tbl = shift;
    if( defined $tbl ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my @caption = $m_oDatabase->fetch_AoH("show columns from $tbl");
        for( my $j = 0; $j <= $#caption; $j++ ) {
            return $caption[$j]->{'Field'}
                if( $caption[$j]->{'Extra'} eq 'auto_increment' );
        }
    } else {
        return 0;
    }
}

=head2 ChangeEngine()

       Ändert die Engine des datenbank ChangeEngine

=cut

sub ChangeEngine {
    my $tbl    = param('table')  ? param('table')  : shift;
    my $engine = param('engine') ? param('engine') : shift;
    if( defined $engine && defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $engine = $m_oDatabase->quote($engine);
        ExecSql("ALTER TABLE $tbl2 ENGINE = $engine");
        ShowTableDetails($tbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeAutoInCrementValue()

       AUTO_INCREMENT für tabelle setzen

       ChangeAutoInCrementValue


=cut

sub ChangeAutoInCrementValue {
    my $tbl   = param('table') ? param('table') : shift;
    my $tbl2  = $m_dbh->quote_identifier($tbl);
    my $p_key = param('AUTO_INCREMENT') ? param('table') : shift;
    if( defined $p_key && defined $tbl ) {
        $p_key = $m_oDatabase->quote($p_key);
        ExecSql("ALTER TABLE $tbl2 AUTO_INCREMENT = $p_key");
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

=head2 ChangeCharset()

       Charset für tabelle ändern

       ChangeCharset($tbl ,charset)

=cut

sub ChangeCharset {
    my $tbl     = param('table')   ? param('table')   : shift;
    my $charset = param('charset') ? param('charset') : shift;

    if( defined $charset && defined $tbl ) {
        my $tbl2 = $m_dbh->quote_identifier($tbl);
        $charset = $m_oDatabase->quote($charset);
        ExecSql("ALTER TABLE $tbl2 CONVERT TO CHARACTER SET  $charset");
        ShowTable($tbl);
    } else {
        ShowTables();
    }
}

#Tabllen Funktionen

#Html elemente

=head2 GetCharacterSet()

        gibt das Charset zu coalation zurück.

        GetCharacterSet(coalation);

=cut

sub GetCharacterSet {
    my $c = shift;
    if( defined $c ) {
        my $coalation
            = $m_oDatabase->fetch_hashref( "SHOW COLLATION like ?", $c );
        return $coalation->{Charset};
    } else {
        return 0;
    }
}

=head2 GetEngines()

        gibt die verfügbaren Engines zurück.

        GetEngines(tabelle, zeile);

=cut

#todo  engine für datenabnk selektieren

sub GetEngines {
    my $tbl  = shift;
    my $name = shift;
    if( defined $tbl && defined $name ) {
        my @co = $m_oDatabase->fetch_array("SHOW ENGINES");
        my @EINGINES
            = $m_oDatabase->fetch_AoH( "SHOW TABLE STATUS where `Name` = ?  ",
            $tbl );
        my $return = qq|<select name="$name">|;
        $return .=
            $_->{Engine} eq "@co"
            ? qq|<option  value="$_->{Collation}"  selected="selected" >$_->{Collation}</option>|
            : qq|<option  value="$_->{Collation}">$_->{Collation}</option>|
            foreach @co;
        $return .= '</select>';
        return $return;
    } else {
        return 0;
    }
}

=head2 GetEngineForRow()

        gibt die verfügbaren Engines zurück.

        GetEngines(tabelle, zeile);

=cut

sub GetEngineForRow {
    my $tbl  = shift;
    my $name = shift;
    if( defined $tbl && defined $name ) {
        my @co = $m_oDatabase->fetch_array("SHOW ENGINES");
        my @EINGINES
            = $m_oDatabase->fetch_AoH( "SHOW TABLE STATUS where `Name` = ?  ",
            $tbl );
        my $return = qq|<select name="$name">|;
        $return .=
            $_->{Engine} eq "@co"
            ? qq|<option  value="$_->{Collation}"  selected="selected" >$_->{Collation}</option>|
            : qq|<option  value="$_->{Collation}">$_->{Collation}</option>|
            foreach @EINGINES;
        $return .= '</select>';
        return $return;
    } else {
        return 0;
    }
}

=head2 GetNull()

        gibt die NULL(NULL | nor NULL) auswahlliste zurück

        GetNull(selected extra, slect_name);

=cut

sub GetNull {
    my $null = shift;
    my $name = shift;
    if( defined $null && defined $name ) {
        my $return = qq|<select name="$name">|;
        $return .= qq|<option  value="not NULL">not NULL</option>|;
        $return .=
            $null eq 'YES'
            ? qq|<option  value="NULL" selected="selected">NULL</option>|
            : qq|<option value="NULL">NULL</option>|;
        $return .= q|</select>|;
        return $return;
    } else {
        return 0;
    }
}

=head2 GetExtra()

        gibt die extra(auto_increment) auswahlliste zurück

        GetExtra(selected extra, slect_name);

=cut

sub GetExtra {
    my $selected = shift;
    my $name     = shift;
    if( defined $selected && defined $name ) {
        my $return = qq|<select name="$name">|;
        $return .= '<option value=""></option>';
        $return .=
            $selected eq "auto_increment"
            ? q|<option  value="auto_increment" selected="selected">auto_increment</option>|
            : q|<option value="auto_increment">auto_increment</option>|;
        $return .= q|</select>|;
        return $return;
    } else {
        return 0;
    }
}

=head2 GetTypes()

        gibt die datentypen zurück

        GetTypes(selected type, slect_name);

=cut

sub GetTypes {
    my $type = shift;
    my $name = shift;
    $type =~ s/(\w+).*/uc $1/eg;
    if( defined $type && defined $name ) {    #todo title setzen
        my $return = qq|<select name="$name">|;
        $return .= '<option></option>';
        $return .=
            $type eq 'TINYINT'
            ? '<option  value="TINYINT"  selected="selected" >TINYINT</option>'
            : '<option  value="TINYINT" >TINYINT</option>';
        $return .=
            $type eq 'SMALLINT'
            ? '<option selected="selected"  value="SMALLINT" >SMALLINT</option>'
            : '<option value="SMALLINT" >SMALLINT</option>';
        $return .=
            $type eq 'MEDIUMINT'
            ? '<option selected="selected"  value="MEDIUMINT" >MEDIUMINT</option>'
            : '<option value="MEDIUMINT" >MEDIUMINT</option>';
        $return .=
            $type eq 'INT'
            ? '<option selected="selected"  value="INT" >INT</option>'
            : '<option value="INT" >INT</option>';
        $return .=
            $type eq 'BIGINT'
            ? '<option selected="selected"  value="BIGINT" >BIGINT</option>'
            : '<option value="BIGINT" >BIGINT</option>';
        $return .=
            $type eq 'FLOAT'
            ? '<option selected="selected"  value="FLOAT" >FLOAT</option>'
            : '<option value="FLOAT" >FLOAT</option>';
        $return .=
            $type eq 'DOUBLE'
            ? '<option selected="selected"  value="DOUBLE" >DOUBLE</option>'
            : '<option value="DOUBLE" >DOUBLE</option>';
        $return .=
            $type eq 'DECIMAL'
            ? '<option selected="selected"  value="DECIMAL" >DECIMAL</option>'
            : '<option value="DECIMAL" >DECIMAL</option>';
        $return .=
            $type eq 'DATE'
            ? '<option selected="selected"  value="DATE" >DATE</option>'
            : '<option value="DATE">DATE</option>';
        $return .=
            $type eq 'DATETIME'
            ? '<option selected="selected"  value="DATETIME" >DATETIME</option>'
            : '<option value="DATETIME" >DATETIME</option>';
        $return .=
            $type eq 'TIMESTAMP'
            ? '<option selected="selected"  value="TIMESTAMP" >TIMESTAMP</option>'
            : '<option value="TIMESTAMP" >TIMESTAMP</option>';
        $return .=
            $type eq 'TIME'
            ? '<option selected="selected"  value="TIME" >TIME</option>'
            : '<option value="TIME" >TIME</option>';
        $return .=
            $type eq 'YEAR'
            ? '<option selected="selected"  value="YEAR" >YEAR</option>'
            : '<option value="YEAR"  >YEAR</option>';
        $return .=
            $type eq 'CHAR'
            ? '<option selected="selected"  value="CHAR" >CHAR</option>'
            : '<option value="CHAR" >CHAR</option>';
        $return .=
            $type eq 'VARCHAR'
            ? '<option selected="selected"  value="VARCHAR" >VARCHAR</option>'
            : '<option value="VARCHAR">VARCHAR</option>';
        $return .=
            $type eq 'BLOB'
            ? '<option selected="selected"  value="BLOB" >BLOB</option>'
            : '<option value="BLOB" >BLOB</option>';
        $return .=
            $type eq 'TEXT'
            ? '<option selected="selected"  value="TEXT" >TEXT</option>'
            : '<option value="TEXT"  >TEXT</option>';
        $return .=
            $type eq 'ENUM'
            ? '<option selected="selected"  value="ENUM" >ENUM</option>'
            : '<option value="ENUM"  >ENUM</option>';
        $return .=
            $type eq 'SET'
            ? '<option selected="selected"  value="SET" >SET</option>'
            : '<option value="SET"  >SET</option>';
        $return .= '</select>';
        return $return;
    } else {
        return 0;
    }
}

=head2 GetColumnCollation()

       gibt eine auswahlliste (select) zurück.

       GetColumnCollation( tabelle ,columne, name_select);

=cut

sub GetColumnCollation {
    my $tbl    = shift;
    my $column = shift;
    my $name   = shift;
    if( defined $tbl && defined $column && defined $name ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my $col = $m_oDatabase->fetch_hashref(
            "show full columns from $tbl where field = ?", $column );
        my @collation = $m_oDatabase->fetch_AoH("SHOW COLLATION");
        my $return
            = qq|<select name="$name" style="width:100px;"><option></option>|;
        unless ( $col->{Collation} ) {
            $return
                .= qq|<option  value="NULL"  selected="selected" >NULL</option>|;
        } else {
            $return .=
                $_->{Collation} eq $col->{Collation}
                ? qq|<option  value="$_->{Collation}"  selected="selected" >$_->{Collation}</option>|
                : qq|<option  value="$_->{Collation}">$_->{Collation}</option>|
                foreach @collation;
        }
        $return .= '</select>';
        return $return;
    } else {
        return 0;
    }
}

=head2 GetCollation()

       gibt eine auswahlliste (select) zurück.

=cut

sub GetCollation {
    my $name      = shift;
    my @collation = $m_oDatabase->fetch_AoH("SHOW COLLATION");
    my $return
        = qq|<select name="$name" style="width:100px;"><option></option>|;
    $return .= qq|<option  value="$_->{Collation}">$_->{Collation}</option>|
        foreach @collation;
    $return .= '</select>';
    return $return;
}

=head2 GetAttrs

       gibt eine auswahlliste (select) zurück.

       GetAttrs($tbl, $field, $m_hUniqueAttrs )

=cut

sub GetAttrs {
    my $tbl    = shift;
    my $select = shift;
    my $name   = shift;
    my $hr     = $m_oDatabase->fetch_hashref("SHOW CREATE TABLE $tbl");
    my $return = qq|<select name="$name" style="width:100px;">
    <option ></option>
    <option  value="UNSIGNED" |
        . (
        $hr->{'Create Table'} =~ /$select[^,]+unsigned/
        ? 'selected="selected"'
        : ''
        )
        . q|>UNSIGNED</option>
    <option  value="UNSIGNED ZEROFILL" |
        . (
        $hr->{'Create Table'} =~ /$select[^,]+unsigned zerofill/
        ? 'selected="selected"'
        : ''
        )
        . q|>UNSIGNED ZEROFILL</option>
    <option  value="ON UPDATE CURRENT_TIMESTAMP"  |
        . (
        $hr->{'Create Table'} =~ /$select[^,]+on update CURRENT_TIMESTAMP/
        ? 'selected="selected"'
        : ''
        )
        . q|>ON UPDATE CURRENT_TIMESTAMP</option>
    </select>|;
    return $return;
}

=head2 GetColumns

       gibt eine auswahlliste (select) zurück.

       GetColumns($tbl ,$name)

=cut

sub GetColumns {
    my $tbl    = shift;
    my $name   = shift;
    my @col    = $m_oDatabase->fetch_AoH("show columns from $tbl");
    my $return = qq|<select name="$name" style="width:100px;">|;
    $return .= qq|<option  value="$_->{Field}">$_->{Field}</option>|
        foreach @col;
    $return .= '</select>';
    return $return;
}

=head2 ShowDbHeader()

        gibt die navigationszeile für eine tabelle aus

=cut

sub ShowDbHeader {
    my $tbl      = shift;
    my $selected = shift;
    my $current  = shift;

    my %parameter = (
        style    => $m_sStyle,
        path     => "$m_hrSettings->{cgi}{bin}/templates",
        template => 'ribbon.htm',
        anchors  => [
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

    $m_sContent .= Menu( \%parameter );
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

            class => $current eq "ShowTables"
            ? 'currentLink'
            : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ShowTables&amp;database=$m_sCurrentDb",
            title => translate("ShowTables") . "($m_sCurrentDb)"
        },
        translate("Datenbank") . "($m_sCurrentDb)"
    ) . '|';
    $m_sContent .= a(
        {   class => $current eq "Show" ? 'currentLink' : 'link',
            href =>
                "$ENV{SCRIPT_NAME}?action=ShowTables&amp;database=$m_sCurrentDb",
            title => translate("ShowTables")
        },
        translate("delete")
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
    $m_sContent .= qq|
<br/>
<form action="$ENV{SCRIPT_NAME}">
<input type="hidden" name="action" value="ShowNewTable" />
<input type="text" name="table" value="Name" onfocus="this.value=''" tyle="width:80px;" />
$fields:<input type="text" name="count" value="1" style="width:40px;" id="fields4tbl" onkeyup="intputMask('fields4tbl',/(\\d+)/)" />
<input type="submit" name="submit" value="$newtable" />
</form>
<br/>
</div>
<div id="SqlEditor" style="display:none;">
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
$EXECSQL
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

# SHOW VARIABLES;
