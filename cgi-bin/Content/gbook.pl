sub newGbookEntry {
        my %parameter = (
                         action    => "addnewGbookEntry",
                         body      => translate("gbook_body"),
                         class     => 'max',
                         attach    => 0,
                         maxlength => 1000,
                         path      => "$settings->{cgi}{bin}/templates",
                         server    => $settings->{cgi}{serverName},
                         style     => $style,
                         thread    => translate('gbook'),
                         headline  => translate('headline'),
                         title     => translate("Gbook"),
                         right     => 0,
                         catlist   => '&#160;',
                         html      => 0,
                         atemp     => qq(<input  name="von" value="$von" style="display:none;"/><input  name="bis" value="$bis" style="display:none;"/>),
        );
        use HTML::Editor;
        my $editor = new HTML::Editor(\%parameter);
        print '<div align="center"><br/><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;</script>';
        print $editor->show();
        print '</div>';

}

sub addnewGbookEntry {
        my $message = param('message');
        $message = ($message =~ /^(.{3,1000})$/s) ? $1 : 'Invalid body';
        my $headline = param('headline');
        $headline = ($headline =~ /^(.{3,50})$/s) ? $1 : 'Invalid headline';
        unless (param('submit') eq translate('preview')) {
                if($database->checkFlood(remote_addr())) {
                        my $sql = q/INSERT INTO gbook (`title`,`body`,`user`) VALUES (?,?,?)/;
                        $database->void($sql, $headline, $message, $user);
                        &showGbook();
                } else {
                        print translate('floodtext');
                }
        } else {
                BBCODE(\$message, $right);

                my %parameter = (path => "$settings->{cgi}{bin}/templates", style => $style, title => $headline, server => $settings->{cgi}{serverName}, id => "prev", class => 'min',);
                my $win = new HTML::Window(\%parameter);
                $win->set_closeable(0);
                $win->set_collapse(0);
                $win->set_moveable(1);
                $win->set_resizeable(1);
                print br(), $win->windowHeader();
                print qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%">
                <tr><td align="left">$headline</td></tr>
                <tr><td align="left">$message</td></tr>
                </table>), $win->windowFooter();
                my %parameter = (
                                 action    => "addnewGbookEntry",
                                 body      => $message,
                                 class     => 'max',
                                 attach    => 0,
                                 maxlength => 1000,
                                 path      => "$settings->{cgi}{bin}/templates",
                                 server    => $settings->{cgi}{serverName},
                                 style     => $style,
                                 thread    => 'gbook',
                                 headline  => $headline,
                                 title     => translate('gbook'),
                                 right     => 0,
                                 catlist   => '&#160;',
                                 html      => 0,
                );
                use HTML::Editor;
                my $editor = new HTML::Editor(\%parameter);
                print '<div align="center"><br/><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;</script>';
                print $editor->show();
                print '</div>';
        }
}

sub showGbook {
        my $length = $database->tableLength('gbook', 0);
        &newGbookEntry();
        print br();
        if($length > 0) {
                my %needed = (start => $von, length => $length, style => $style, mod_rewrite => $settings->{cgi}{mod_rewrite}, action => "gbook", path => $settings->{cgi}{bin},);
                print br(), makePages(\%needed), br();
                print '<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout"   width="100%">';
                my $sql_read = qq/select title,body,date,id,user from  `gbook` order by date desc LIMIT $von,10 /;
                my $sth      = $dbh->prepare($sql_read);
                $sth->execute();

                while(my @data = $sth->fetchrow_array()) {
                        my $headline = $data[0];
                        my $body     = $data[1];
                        my $datum    = $data[2];
                        my $id       = $data[3];
                        my $username = $data[4];

                        my %parameter = (path => "$settings->{cgi}{bin}/templates", style => $style, title => $headline, server => $settings->{cgi}{serverName}, id => $id, class => 'min',);

                        my $win = new HTML::Window(\%parameter);
                        $win->set_closeable(1);
                        $win->set_collapse(1);
                        $win->set_moveable(1);
                        $win->set_resizeable(1);
                        print qq(<tr id="trw$id"><td valign="top">) . $win->windowHeader();
                        BBCODE(\$body, $right);
                        print qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%">
                        <tr><td align="left"><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$username</td><td align="right">$datum</td></tr></table></td></tr>
                        <tr><td align="left">$body</td></tr>
                </table>
                ), $win->windowFooter(), '</td></tr>';
                }
                print '</table>';
        }
}
