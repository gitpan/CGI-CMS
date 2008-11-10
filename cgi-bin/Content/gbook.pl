sub newGbookEntry {
    my %parameter = (
        action    => "addnewGbookEntry",
        body      => translate("gbook_body"),
        class     => 'max',
        attach    => 0,
        maxlength => 1000,
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        server    => $m_hrSettings->{cgi}{serverName},
        style     => $m_sStyle,
        thread    => translate('gbook'),
        headline  => translate('headline'),
        title     => translate("Gbook"),
        right     => 0,
        catlist   => '&#160;',
        html      => 0,
        atemp =>
            qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    use HTML::Editor;
    my $editor = new HTML::Editor( \%parameter );
    $m_sContent
        .= '<div align="center"><br/><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;</script>';
    $m_sContent .= $editor->show();
    $m_sContent .= '</div>';

}

sub addnewGbookEntry {
    my $message = param('message');
    $message = ( $message =~ /^(.{3,1000})$/s ) ? $1 : 'Invalid body';
    my $headline = param('headline');
    $headline = ( $headline =~ /^(.{3,50})$/s ) ? $1 : 'Invalid headline';
    unless ( param('submit') eq translate('preview') ) {
        if( $m_oDatabase->checkFlood( remote_addr() ) ) {
            my $sql
                = q/INSERT INTO gbook (`title`,`body`,`user`) VALUES (?,?,?)/;
            $m_oDatabase->void( $sql, $headline, $message, $m_sUser );
            &showGbook();
        } else {
            $m_sContent .= translate('floodtext');
            &showGbook();
        }
    } else {
        BBCODE( \$message, $m_nRight );
        my %wparameter = (
            path   => "$m_hrSettings->{cgi}{bin}/templates",
            style  => $m_sStyle,
            title  => $headline,
            server => $m_hrSettings->{cgi}{serverName},
            id     => "prev",
            class  => 'min',
        );
        my $win = new HTML::Window( \%wparameter );
        $win->set_closeable(0);
        $win->set_collapse(0);
        $win->set_moveable(1);
        $win->set_resizeable(1);
        $m_sContent .= br() . $win->windowHeader();
        $m_sContent
            .= qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%">
                <tr><td align="left">$headline</td></tr>
                <tr><td align="left">$message</td></tr>
                </table>) . $win->windowFooter();
        my %parameter = (
            action    => "addnewGbookEntry",
            body      => $message,
            class     => 'max',
            attach    => 0,
            maxlength => 1000,
            path      => "$m_hrSettings->{cgi}{bin}/templates",
            server    => $m_hrSettings->{cgi}{serverName},
            style     => $m_sStyle,
            thread    => 'gbook',
            headline  => $headline,
            title     => translate('gbook'),
            right     => 0,
            catlist   => '&#160;',
            html      => 0,
        );
        use HTML::Editor;
        my $editor = new HTML::Editor( \%parameter );
        $m_sContent
            .= '<div align="center"><br/><script language="JavaScript1.5" type="text/javascript">html = 1;bbcode = false;</script>';
        $m_sContent .= $editor->show();
        $m_sContent .= '</div>';
    }
}

sub showGbook {
    my $length = $m_oDatabase->tableLength( 'gbook', 0 );
    &newGbookEntry();
    $m_sContent .= br();
    if( $length > 0 ) {
        my %needed = (
            start       => $m_nStart,
            length      => $length,
            style       => $m_sStyle,
            mod_rewrite => $m_hrSettings->{cgi}{mod_rewrite},
            action      => "gbook",
            path        => $m_hrSettings->{cgi}{bin},
        );
        $m_sContent .= br() . makePages( \%needed ) . br();
        $m_sContent
            .= '<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout"   width="100%">';
        my $sql_read
            = qq/select title,body,date,id,user from  `gbook` order by date desc LIMIT $m_nStart,10 /;
        my $sth = $m_dbh->prepare($sql_read);
        $sth->execute();

        while( my @data = $sth->fetchrow_array() ) {
            my $headline    = $data[0];
            my $body        = $data[1];
            my $datum       = $data[2];
            my $id          = $data[3];
            my $m_sUsername = $data[4];

            my %parameter = (
                path   => "$m_hrSettings->{cgi}{bin}/templates",
                style  => $m_sStyle,
                title  => $headline,
                server => $m_hrSettings->{cgi}{serverName},
                id     => $id,
                class  => 'min',
            );

            my $win = new HTML::Window( \%parameter );
            $win->set_closeable(1);
            $win->set_collapse(1);
            $win->set_moveable(1);
            $win->set_resizeable(1);
            $m_sContent .= qq(<tr id="trw$id"><td valign="top">)
                . $win->windowHeader();
            BBCODE( \$body, $m_nRight );
            $m_sContent
                .= qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%">
                        <tr><td align="left"><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$m_sUsername</td><td align="right">$datum</td></tr></table></td></tr>
                        <tr><td align="left">$body</td></tr>
                </table>
                ) . $win->windowFooter() . '</td></tr>';
        }
        $m_sContent .= '</table>';
    }
}
