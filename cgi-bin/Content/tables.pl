
sub newSql {
        my $exec = translate('execSQL');
        print qq(
<form action ="$ENV{SCRIPT_NAME}" method="post">
 <table cellspacing="5" cellpadding="0" border="0" align="center" summary="execSql" width="100%">
  <tbody>
   <tr>
      <td>$exec</td>
    </tr>
    <tr>
      <td><textarea cols="150" rows="50" name="sql" style="width:100%;height:250px;" >select * from test</textarea></td>
    </tr>
    <tr>
      <td align="right"><input type="submit" value="Exec"/>
     <input type="hidden" value="execSql" name="action"/></td>
    </tr>
  </tbody>
</table>
)
}

sub execSql {
        my $sql = param('sql');
        my @statements = split /;/, $sql;
        foreach my $s (@statements) {
                eval {$dbh->do($s);};
                print "$s ", br(), '<div style="width:80%;overflow:auto;color:red;">', $dbh->errstr, '</div>' if($@);
        }
        &showTables();
}

sub showEntry {
        my $tb = param('table') ? param('table') : shift;
        $tb = 'news' unless (defined $tb);
        use HTML::Menu::Pages;
        my @count   = $database->fetch_array("SELECT count(*) FROM `$tb`");
        my @caption = $database->fetch_AoH("show columns from `$tb`");
        $von = ($von >= $count[0])? ( ( ($count[0]- 10) > 0) ? ( $count[0]- 10) : 0) : $von;
        my @a       = $database->fetch_AoH("select * from `$tb` order by '$caption[0]->{'Field'}' desc  LIMIT $von , 10"); 
        if($count[0] > 0) {
                my %needed = (start => $von, length => $count[0], style => $style, mod_rewrite => $settings->{mod_rewrite}, action => "showEntry", append => "&table=$tb", path => $settings->{cgi}{bin});
                print makePages(\%needed);
        }
        print '<table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout" >
     <tr>';
        for(my $i = 0 ; $i <= $#caption ; $i++) {
                print '<td class="caption">' . $caption[$i]->{'Field'} . '</td>';
        }
        print '<td class="caption"></td></tr>';
        for(my $i = 0 ; $i <= $#a ; $i++) {
                for(my $j = 0 ; $j <= $#caption ; $j++) {
                        my $headline = $a[$i]->{$caption[$j]->{'Field'}};
                        print '<td >' . substr($headline, 0, 10) . '</td>';
                }
                my $id       = $a[$i]->{'id'};
                my $trdelete = translate('delete');
                print
                qq|<td><a href="$ENV{SCRIPT_NAME}?action=editEntry&amp;table=$tb&amp;edit=$id&amp;von=$von&amp;bis=$bis;"><img src="/style/$style/buttons/edit.png" border="0" alt="Edit" title="Edit Entry"/></a><a href ="$ENV{SCRIPT_NAME}?action=deleteEntry&amp;table=$tb&amp;delete=$id&amp;von=$von;&amp;bis=$bis;" onclick="return confirm('$trdelete ?')"><img src="/style/$style/buttons/delete.png" border="0" alt="delete"/></a></td></td></tr>|;
        }
        print '</table>';
        &showNewEntry($tb);
}

sub editEntry {
        my $rid = param('edit')  ? param('edit')  : shift;
        my $tbl = param('table') ? param('table') : shift;
        my @caption = $database->fetch_AoH("show columns from `$tbl`");
        my $clm;
        for(my $j = 0 ; $j <= $#caption ; $j++) {
                if($caption[$j]->{'Extra'} eq "auto_increment") {
                        $clm = $caption[$j]->{'Field'};
                        last;
                }
        }
        my $a = $database->fetch_hashref("select * from `$tbl` where $clm = $rid order by '$caption[0]->{'Field'}'");
        print
          qq(<div align="center"><p>Edit Entry:</p><form action="$ENV{SCRIPT_NAME}?" method="post" name="action" enctype="multipart/form-data"><input type="hidden" name="action" value="saveEntry"/><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout"><tbody><tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);

        for(my $j = 0 ; $j <= $#caption ; $j++) {
              SWITCH: {
                        if($caption[$j]->{'Type'} eq "text") {
                                print
                                  qq(<tr><td>$caption[$j]->{'Field'} </td><td><textarea name="tbl$caption[$j]->{'Field'}" align="left">$a->{$caption[$j]->{'Field'}}</textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                                last SWITCH;
                        }
                        print
                          qq(<tr><td >$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="$a->{$caption[$j]->{'Field'}}" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                }
        }
        my $trsave = translate('save');
        print
          qq(</table><br/><input type="submit" value="$trsave"/><input type="hidden" name="id" value="$rid"/><input type="hidden" name="table" value="$tbl"/><input  name="von" value="$von" style="display:none;"/><input  name="bis" value="$bis" style="display:none;"/><br/><br/></form></div>);
        &showEntry();
}

sub showNewEntry {
        my $tbl      = param('table') ? param('table') : shift;
        my @caption  = $database->fetch_AoH("show columns from `$tbl`");
        my $newentry = translate('newEntry');
        print
          qq(<div align="center"><p>$newentry:</p><form action="$ENV{SCRIPT_NAME}?" method="get" name="action" enctype="multipart/form-data"><input type="hidden" name="action" value="newEntry"/><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout"><tbody><tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);
        for(my $j = 0 ; $j <= $#caption ; $j++) {
              SWITCH: {
                        if($caption[$j]->{'Type'} eq "text") {
                                print
                                  qq(<tr><td class="caption" >$caption[$j]->{'Field'}</td><td><textarea name="tbl$caption[$j]->{'Field'}" value="" align="left"></textarea></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                                last SWITCH;
                        }
                        print
                          qq(<tr><td>$caption[$j]->{'Field'}</td><td><input type="text" name="tbl$caption[$j]->{'Field'}" value="" align="left"/></td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
                }
        }
        my $save = translate('save');
        print qq(</table><br/><input type="submit" value="$save"/><input type="hidden" name="table" value="$tbl"/><input  name="von" value="$von" style="display:none;"/><input  name="bis" value="$bis" style="display:none;"/><br/><br/></form></div>);
}

sub saveEntry {
        my @params = param();
        my $tbl    = param('table');
        my $i      = 0;
        my @rows;
        my $eid;
        while($i < $#params) {
                $i++;
                my $pa = param($params[$i]);
                $eid = $pa if($params[$i] eq 'id');
                if($params[$i] =~ /tbl.*/) {
                        $params[$i] =~ s/tbl//;
                        unshift @rows, "`" . $params[$i] . "` = " . $database->quote($pa);
                }
        }
        my $sql = "update `$tbl` set " . join(',', @rows) . " where id =$eid;";
        $database->void($sql);
        print "Error: $@<br/>$sql" if $@;
        &showEntry($tbl);
}

sub newEntry {
        my @params = param();
        my $tbl    = param('table');
        my $sql    = "INSERT INTO `$tbl` VALUES(";
        my $i      = 0;
        while($i < $#params) {
                $i++;
                my $pa = param($params[$i]);
                if($params[$i] =~ /tbl.*/) {
                        $params[$i] =~ s/tbl//;
                        $sql .= "'" . $pa . "'";
                        $sql .= "," if($i+ 3 < $#params);
                }
        }
        $sql .= ")";    #,''
        $database->void($sql);
        print "Error: $@<br/>$sql" if $@;
        &showEntry($tbl);
}

sub deleteEntry {
        my $tbl = param('table');
        my $ids = param('delete');
        $database->void("DELETE FROM `$tbl` where id  = '$ids'");
        &showEntry($tbl);
}

sub showTables {
        my @a      = $database->fetch_AoH("SHOW TABLE STATUS");
        my $dbname = $settings->{database}{name};

        print
          qq(<div align="center"><a href="$ENV{SCRIPT_NAME}?action=showTables&amp;table=$dbname" class="menuLink">$dbname</a>|<a href="$ENV{SCRIPT_NAME}?action=sqldump" class="menuLink">Dump</a><br /><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="showTables"><tr><td class="caption">Name</a></td><td class="caption">Rows</td><td class="caption">Type</td><td class="caption">Size (kb)</td><td class="caption"></td><td class="caption"></td></tr>);
        for(my $i = 0 ; $i <= $#a ; $i++) {
                my $kb         = sprintf("%.2f", ($a[$i]->{Index_length}+ $a[$i]->{Data_length})/ 1024);
                my $trdatabase = translate('database');
                my $trdelete   = translate('delete');
                print
                  qq(<tr><td><a href="$ENV{SCRIPT_NAME}?action=showEntry&amp;table=$a[$i]->{Name}">$a[$i]->{Name}</a></td><td>$a[$i]->{Rows}</td><td>$a[$i]->{Engine}</td><td>$kb</td><td><a href="$ENV{SCRIPT_NAME}?action=dropTables&amp;table=$a[$i]->{Name}" onclick="return confirm(' $trdelete?')"><img src="/style/$style/buttons/delete.png" align="middle" alt="" border="0"/></a></td><td><a href="$ENV{SCRIPT_NAME}?action=showTableDetails&amp;table=$a[$i]->{Name}">Details</a></td></tr>);
        }
        print '<table align="center" border="0" cellpadding="1"  cellspacing="1" summary="showTables"><tr><td>';
        &newSql();
        print '</td></tr></table></div>';
}

sub dropTables {
        my $tbl = param('table');
        $database->void("drop table `$tbl`");
        &showTables();
}

sub showTableDetails {
        my $name = param('table');
        my @a    = $database->fetch_AoH("SHOW TABLE STATUS");
        print qq(<div align="center"><p>$name:</p><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="showTables"><tr><td><td class="caption">Name</td><td class="caption">Value</td></tr>);
        for(my $i = 0 ; $i <= $#a ; $i++) {
                if($a[$i]->{Name} eq $name) {
                        foreach my $key (keys %{$a[0]}) {
                                print qq(<tr><td><td>$key</td><td>$a[$i]->{$key}</td></tr>);
                        }
                }
        }
        print qq(</table><a href="$ENV{SCRIPT_NAME}?action=showTables">Tables</a></div>);
}

sub sqldump {
        my $dmp = "/usr/bin/mysqldump -u $settings->{database}{user} --password=$settings->{database}{password}  $settings->{database}{name} > $settings->{cgi}{bin}/config/dump.sql";
        system $dmp;
        print '<br /><textarea style="width:90%;height:600px;">', $dmp, openFile("$settings->{cgi}{bin}/config/dump.sql"), qq(</textarea><br /><a href="$ENV{SCRIPT_NAME}?action=showTables" class="menuLink">weiter</a></div>);

}

#         sub change_col_typ{
#         #ALTER TABLE table1 MODIFY ? VARCHAR(10) NOT NULL;
#         my $tbl      = param('table') ? param('table') : shift;
#         my @caption  = $database->fetch_AoH("show columns from `$tbl`");
#         my $newentry = translate('editTable');
#         print
#         qq(<div align="center"><p>$tbl:</p><form action="$ENV{SCRIPT_NAME}?" method="get" name="action" enctype="multipart/form-data"><input type="hidden" name="action" value="newEntry"/><table align="center" border="0" cellpadding="1"  cellspacing="1" summary="layout"><tbody><tr><td class="caption">Field</td><td class="caption">Value</td><td class="caption">Type</td><td class="caption">Null</td><td class="caption">Key</td><td class="caption">Default</td><td class="caption">Extra</td></tr>);
#         for(my $j = 0 ; $j <= $#caption ; $j++) {
#         SWITCH: {
#         if($caption[$j]->{'Type'} eq "text") {
#         print
#         qq(<tr><td class="caption" >$caption[$j]->{'Field'}</td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
#         last SWITCH;
#         }
#         print
#         qq(<tr><td>$caption[$j]->{'Field'}</td><td>$caption[$j]->{'Type'}</td><td>$caption[$j]->{'Null'}</td><td>$caption[$j]->{'Key'}</td><td>$caption[$j]->{'Default'}</td><td>$caption[$j]->{'Extra'}</td></tr>);
#         }
#         }
#         my $save = translate('save');
#         print qq(</table><br/><input type="submit" value="$save"/><input type="hidden" name="table" value="$tbl"/><br/><br/></form></div>);
#         }
#
#         sub alter_col{
#                 #ALTER TABLE table1 MODIFY ? VARCHAR(10) NOT NULL;
#         }
1;
