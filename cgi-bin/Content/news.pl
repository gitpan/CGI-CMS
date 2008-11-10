use vars qw($akt $m_nEnd $length $m_nStart $thread $replyId );

sub show {
    my $threadlength = $m_oDatabase->tableLength('news');
    $m_nStart = $m_nStart > $threadlength ? $threadlength- 1 : $m_nStart;
    my %needed = (
        action => 'news',
        start  => $m_nStart,
        end    => $m_nEnd,
        thread => 'news',
        id     => 'c',
    );

    $m_sContent .= showThread( \%needed );
    my $catlist   = readcats('news');
    my %parameter = (
        action => 'addNews',
        body   => translate('body'),
        class  => 'max',
        attach => $m_nRight >= $m_hrSettings->{uploads}{right}
        ? $m_hrSettings->{uploads}{enabled}
        : 0,
        maxlength => $m_hrSettings->{news}{maxlength},
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        reply     => 'none',
        server    => $m_hrSettings->{cgi}{serverName},
        style     => $m_sStyle,
        thread    => 'news',
        headline  => translate('headline'),
        title     => translate('newMessage'),
        catlist   => $catlist,
        right     => $m_nRight,
        html      => 0,
        atemp =>
            qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    use HTML::Editor;
    my $editor = new HTML::Editor( \%parameter );
    $m_sContent .= '<div align="center">';
    $m_sContent .= $editor->show()
        if( $m_nRight >= $m_hrSettings->{news}{right} );
    $m_sContent .= '</div>';
}

sub showEditor {
    my $catlist   = readcats('news');
    my %parameter = (
        action => 'addNews',
        body   => translate('body'),
        class  => 'max',
        attach => $m_nRight >= $m_hrSettings->{uploads}{right}
        ? $m_hrSettings->{uploads}{enabled}
        : 0,
        maxlength => $m_hrSettings->{news}{maxlength},
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        reply     => 'none',
        server    => $m_hrSettings->{cgi}{serverName},
        style     => $m_sStyle,
        thread    => 'news',
        headline  => translate('headline'),
        title     => translate('newMessage'),
        catlist   => $catlist,
        right     => $m_nRight,
        html      => 0,
        template  => "enlargedEditor.htm",
    );
    use HTML::Editor;
    my $editor = new HTML::Editor( \%parameter );
    $m_sContent .= '<div align="center">';
    $m_sContent .= $editor->show()
        if( $m_nRight >= $m_hrSettings->{news}{right} );
    $m_sContent .= '</div>';
}

sub addNews {
    my $sbm = param('submit') ? param('submit') : 'save';
    if( not defined $sbm or ( $sbm ne translate('preview') ) ) {
        if(    defined param('message')
            && defined param('headline')
            && defined param('thread')
            && defined param('catlist') )
        {
            my $message = param('message');
            my $max     = $m_hrSettings->{news}{maxlength};
            $message = ( $message =~ /^(.{3,$max})$/s ) ? $1 : 'Invalid body';
            my $headline = param('headline');
            $headline
                = ( $headline =~ /^(.{3,100})$/s ) ? $1 : 'Invalid headline';
            my $thread = param('thread');
            $thread = ( $thread =~ /^(\w+)$/ ) ? $1 : 'trash';
            my $cat = param('catlist');
            &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
            my $attach
                = ( defined param('file') )
                ? ( split( /[\\\/]/, param('file') ) )[-1]
                : 0;
            my $cit
                = ( defined $attach )
                ? $attach =~ /^(\S+)\.[^\.]+$/
                    ? $1
                    : 0
                : 0;
            my $type
                = ( defined $attach )
                ? ( $attach =~ /\.([^\.]+)$/ )
                    ? $1
                    : 0
                : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra = ( $cit && $type ) ? "$cit.$type" : undef;
            my $format = param('format') eq 'on' ? 'html' : 'bbcode';

            if(    defined $headline
                && defined $message
                && defined $thread
                && $m_nRight >= $m_hrSettings->{news}{right} )
            {
                my %message = (
                    title  => $headline,
                    body   => $message,
                    thread => $thread,
                    user   => $m_sUser,
                    cat    => $cat,
                    attach => $sra,
                    format => $format,
                    ip     => remote_addr()
                );
                if( $m_oDatabase->addMessage( \%message ) ) {
                    $m_sContent
                        .= '<div align="center">Nachricht wurde erstellt.<br/></div>';
                } else {
                    $m_sContent
                        .= '<div align="center">'
                        . translate('floodtext')
                        . '<br/></div>';
                }

            }
        }
        &show();
    } else {
        &preview();
    }
}

sub saveedit {
    if( not defined param('submit')
        or ( param('submit') ne translate('preview') ) )
    {
        my $thread = param('thread');
        $thread = ( $thread =~ /^(\w+)$/ ) ? $1 : 'trash';
        my $id = param('reply');
        $id = ( $id =~ /^(\d+)$/ ) ? $1 : 0;
        my $headline = param('headline');
        $headline = ( $headline =~ /^(.{3,50})$/ ) ? $1 : 0;
        my $body = param('message');
        my $max  = $m_hrSettings->{news}{maxlength};
        $body = ( $body =~ /^(.{3,$max})$/s ) ? $1 : 'Invalid body';
        &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
        my $attach
            = ( param('file') )
            ? ( split( /[\\\/]/, param('file') ) )[-1]
            : 0;
        my $cit
            = ( defined $attach ) ? $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0 : 0;
        my $type
            = ( defined $attach ) ? ( $attach =~ /\.([^\.]+)$/ ) ? $1 : 0 : 0;
        $cit =~ s/("|'|\s| )//g;
        my $sra = ( $cit && $type ) ? "$cit.$type" : undef;
        my $format  = param('format') eq 'on' ? 'html' : 'bbcode';
        my $cat     = param('catlist');
        my %message = (
            thread => $thread,
            title  => $headline,
            body   => $body,
            thread => $thread,
            cat    => $cat,
            attach => $sra,
            format => $format,
            id     => $id,
            user   => $m_sUser,
            cat    => $cat,
            ip     => remote_addr()
        );
        $m_oDatabase->editMessage( \%message );
        my $rid = $id;

        if( $thread eq 'replies' ) {
            my @tid = $m_oDatabase->fetch_array(
                "select refererId from  `replies` where id = '$id'");
            $rid = $tid[0];
        }
        &showMessage($rid);
    } else {
        &preview();
    }
}

sub editNews {
    my $id = param('edit');
    $id = ( $id =~ /^(\d+)$/ ) ? $1 : 0;
    my $th = param('thread');
    $th = ( $th =~ /^(\w+)$/ ) ? $1 : 'news';
    if( not defined param('submit')
        or ( param('submit') ne translate('preview') ) )
    {

        my @data
            = $m_oDatabase->fetch_array(
            "select title,body,date,id,user,attach,format,cat from  `$th`  where `id` = '$id'  and  (`user` = '$m_sUser'  or `right` < '$m_nRight' );"
            ) if( defined $th );
        my $catlist   = readcats( $data[7] );
        my $html      = $data[6] eq 'html' ? 1 : 0;
        my %parameter = (
            action => 'saveedit',
            body   => $data[1],
            class  => 'max',
            attach => $m_nRight >= $m_hrSettings->{uploads}{right}
            ? $m_hrSettings->{uploads}{enabled}
            : 0,
            maxlength => $m_hrSettings->{news}{maxlength},
            path      => "$m_hrSettings->{cgi}{bin}/templates",
            reply     => $id,
            server    => $m_hrSettings->{cgi}{serverName},
            style     => $m_sStyle,
            thread    => $th,
            headline  => $data[0],
            title     => translate('editMessage'),
            right     => $m_nRight,
            catlist   => ( $th eq 'news' ) ? $catlist : '&#160;',
            html      => $html,
            atemp =>
                qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
        );
        use HTML::Editor;
        my $editor = new HTML::Editor( \%parameter );
        $m_sContent .= '<div align="center"><br/>';
        $m_sContent .= $editor->show();
        $m_sContent .= '</div>';
    } else {
        &preview();
    }
    my $rid = $id;
    if( $thread eq 'replies' ) {
        my @tid = $m_oDatabase->fetch_array(
            "select refererId from  `replies` where id = '$id'");
        $rid = $tid[0];
    }
    &showMessage($rid);
}

sub replyNews {
    my $id = param('reply');
    $id = ( $id =~ /^(\d+)$/ ) ? $1 : 0;
    my $th = param('thread');
    $th = ( $th =~ /^(\w+)$/ ) ? $1 : 'trash';
    my %parameter = (
        action => 'addreply',
        body   => translate('insertText'),
        class  => 'max',
        attach => $m_nRight >= $m_hrSettings->{uploads}{right}
        ? $m_hrSettings->{uploads}{enabled}
        : 0,
        maxlength => $m_hrSettings->{news}{maxlength},
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        reply     => $id,
        server    => $m_hrSettings->{cgi}{serverName},
        style     => $m_sStyle,
        thread    => $th,
        headline  => translate('headline'),
        title     => translate('reply'),
        right     => $m_nRight,
        catlist   => "",
        html      => 0,
        atemp =>
            qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    use HTML::Editor;
    my $editor = new HTML::Editor( \%parameter );
    $m_sContent .= '<div align="center"><br/>';
    $m_sContent .= $editor->show();
    $m_sContent .= '</div>';
    &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
    &showMessage($id);
}

sub addReply {
    my $body     = param('message');
    my $headline = param('headline');
    my $reply    = param('reply');
    my $format   = 'bbcode';
    if( defined $format ) {
        $format = 'html' if param('format') eq 'on';
    }
    if( not defined param('submit')
        or ( param('submit') ne translate("preview") ) )
    {
        if( param('file') ) {
            my $attach = ( split( /[\\\/]/, param('file') ) )[-1];
            my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
            my $type = ( $attach =~ /\.([^\.]+)$/ ) ? $1 : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra   = "$cit.$type";
            my %reply = (
                title  => $headline,
                body   => $body,
                id     => $reply,
                user   => $m_sUser,
                attach => $sra,
                format => $format,
            );
            $m_oDatabase->reply( \%reply );
        } else {
            my %reply = (
                title  => $headline,
                body   => $body,
                id     => $reply,
                user   => $m_sUser,
                format => $format,
                ip     => remote_addr()
            );
            $m_oDatabase->reply( \%reply );
        }
        &saveUpload() if $m_nRight >= $m_hrSettings->{uploads}{right};
    } else {
        &preview();
    }
    &showMessage($reply);
}

sub deleteNews {
    my $th = param('thread');
    $th = ( $th =~ /^(\w+)$/ ) ? $1 : 'trash';
    my $del = param('delete');
    $del = ( $del =~ /^(\d+)$/ ) ? $1 : 0;
    if( $th eq 'replies' ) {
        my @tid = $m_oDatabase->fetch_array(
            "select refererId from  `replies` where id = ?", $del );
        $m_oDatabase->deleteMessage( $th, $del );
        &showMessage( $tid[0] );
    } else {
        $m_oDatabase->deleteMessage( $th, $del );
        $m_oDatabase->void( "DELETE FROM `replies` where `refererId`  = ?",
            $del )
            if( $th eq 'news' );
        &show();
    }
}

sub showMessage {
    my $id = shift;
    if( defined param('reply') && param('reply') =~ /(\d+)/ ) {
        $id = $1 unless ( defined $id );
    }

    my $sql_read
        = qq/select title,body,date,id,user,attach,format from  news where `id` = $id && `right` <= $m_nRight/;
    my $ref = $m_oDatabase->fetch_hashref($sql_read);

    if( $ref->{id}== $id ) {

        my $m_sTitle  = $ref->{title};
        my %parameter = (
            path   => $m_hrSettings->{cgi}{bin} . '/templates',
            style  => $m_sStyle,
            title  => qq(<div style="white-space:nowrap">$m_sTitle</div>),
            server => $m_hrSettings->{cgi}{serverName},
            id     => "n$id",
            class  => 'min',
        );
        my $window = new HTML::Window( \%parameter );
        $window->set_closeable(0);
        $window->set_moveable(1);
        $window->set_resizeable(1);
        $ref->{body} =~ s/\[previewende\]//s;
        BBCODE( \$ref->{body}, $ACCEPT_LANGUAGE )
            if( $ref->{format} eq 'bbcode' );
        my $menu = "";

        my $answerlink
            = $m_hrSettings->{cgi}{mod_rewrite}
            ? "/replynews-$ref->{id}.html"
            : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$ref->{id}&amp;thread=news";
        my %reply = (
            title    => translate('reply'),
            descr    => translate('reply'),
            src      => 'reply.png',
            location => $answerlink,
            style    => $m_sStyle,
        );
        my $thread = defined param('thread') ? param('thread') : 'news';

        $menu .= action( \%reply )
            unless ( $thread =~ /.*\d$/ && $m_nRight < 5 );
        my $editlink
            = $m_hrSettings->{cgi}{mod_rewrite}
            ? "/edit$thread-$ref->{id}.html"
            : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;";
        my %edit = (
            title    => translate('edit'),
            descr    => translate('edit'),
            src      => 'edit.png',
            location => $editlink,
            style    => $m_sStyle,
        );
        $menu .= action( \%edit ) if( $m_nRight >= 5 );
        my $trdelete = translate('delete');

        my $deletelink
            = $m_hrSettings->{cgi}{mod_rewrite}
            ? "javascript:if(confirm('$trdelete ?')) location.href='/delete.html&amp;delete=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;'"
            : "javascript:if(confirm('$trdelete ?')) location.href='$ENV{SCRIPT_NAME}?action=delete&amp;delete=$ref->{id}&amp;thread=news&amp;von=$m_nStart&amp;bis=$m_nEnd;'";
        my %delete = (
            title    => translate('delete'),
            descr    => translate('delete'),
            src      => 'delete.png',
            location => $deletelink,
            style    => $m_sStyle,
        );
        $menu .= action( \%delete ) if( $m_nRight >= 5 );

        $m_sContent .= br() . $window->windowHeader() . qq(
                <table align="left" border ="0" cellpadding="0" cellspacing="0" summary ="0"  width="100%">
                <tr >
                <td align='left'>$menu</td></tr>
                <tr ><td align='left'>
                        <table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%">
                        <tr>
                        <td align="left">$ref->{user}</td>
                        <td align="right">$ref->{date}</td>
                        </tr>
                        </table>
                        </td>
                        </tr>
                        <tr><td align='left'>$ref->{body}</td></tr>);
        $m_sContent
            .= qq(<tr><td><a href="/downloads/$ref->{attach}">$ref->{attach}</a></td></tr>)
            if( -e "$m_hrSettings->{uploads}{path}/$ref->{attach}" );
        $m_sContent .= "</table>" . $window->windowFooter();

        my @rps = $m_oDatabase->fetch_array(
            "select count(*) from replies where refererId = $id;");

        if( $rps[0] > 0 ) {
            $m_nStart = $m_nStart > $rps[0] ? $rps[0]- 1 : $m_nStart;
            my %needed = (
                action  => 'showthread',
                start   => $m_nStart,
                end     => $m_nEnd,
                thread  => 'replies',
                replyId => $id,
                id      => 'c',
            );

            $m_sContent .= showThread( \%needed );

        }
    } else {
        &show();
    }
}

# privat
sub readcats {
    my $selected = lc(shift);
    my @cats
        = $m_oDatabase->fetch_AoH( "select * from cats where `right` <= ?",
        $m_nRight );
    my $list = '<select name="catlist" size="1">';
    for( my $i = 0; $i <= $#cats; $i++ ) {
        my $catname = lc( $cats[$i]->{name} );
        $list .=
            ( $catname eq $selected )
            ? qq(<option value="$catname"  selected="selected">$catname</option>)
            : qq(<option value="$catname">$catname</option>);
    }
    $list .= '</select>';
    return $list;
}

sub preview {
    my $thread = param('thread');
    $thread = ( $thread =~ /^(\w+)$/ ) ? $1 : 'trash';
    my $id = param('reply');
    $id = ( $id =~ /^(\d+)$/ ) ? $1 : 0;
    my $headline = param('headline');
    $headline = ( $headline =~ /^(.{3,50})$/ ) ? $1 : 0;
    my $body       = param('message');
    my $selected   = param('catlist');
    my $catlist    = readcats($selected);
    my %wparameter = (
        path   => "$m_hrSettings->{cgi}{bin}/templates",
        style  => $m_sStyle,
        title  => $headline,
        server => "http://localhost",
        id     => "previewWindow",
        class  => "min",
    );
    my $win = new HTML::Window( \%wparameter );
    $win->set_closeable(1);
    $win->set_collapse(1);
    $win->set_moveable(1);
    $win->set_resizeable(1);
    $m_sContent .= "<br/>";
    $m_sContent .= $win->windowHeader();
    my $html = defined param('format') ? param('format') : 'off';
    $html = $html eq 'on' ? 1 : 0;
    BBCODE( \$body, $ACCEPT_LANGUAGE ) unless ($html);
    $m_sContent
        .= qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary ="0"  width="100%"><tr ><td align="left">$body</td></tr></table>);
    $m_sContent .= $win->windowFooter();
    my %parameter = (
        action => $m_hrAction,
        body   => param('message'),
        class  => 'max',
        attach => $m_nRight >= $m_hrSettings->{uploads}{right}
        ? $m_hrSettings->{uploads}{enabled}
        : 0,
        maxlength => $m_hrSettings->{news}{maxlength},
        path      => "$m_hrSettings->{cgi}{bin}/templates",
        reply     => $id,
        server    => $m_hrSettings->{cgi}{serverName},
        style     => $m_sStyle,
        thread    => $thread,
        headline  => $headline,
        title     => translate("editMessage"),
        right     => $m_nRight,
        catlist   => ( $thread eq 'news' ) ? $catlist : '&#160;',
        html      => $html,
        template  => 'enlargedEditor.htm',
        atemp =>
            qq(<input  name="von" value="$m_nStart" style="display:none;"/><input  name="bis" value="$m_nEnd" style="display:none;"/>),
    );
    use HTML::Editor;
    my $editor = new HTML::Editor( \%parameter );
    $m_sContent .= '<div align="center"><br/>';
    $m_sContent .= $editor->show();
    $m_sContent .= '</div>';
}

sub showThread {
    my $needed = shift;
    $akt       = $needed->{action};
    $m_nEnd       = $needed->{end};
    $m_nStart     = $needed->{start};
    $thread    = $needed->{thread};
    $replyId   = $needed->{replyId};
    $replylink = defined $replyId ? "&reply=$replyId" : ' ';

    my @rp = $m_oDatabase->fetch_array(
        "select count(*) from news where `right` <= $m_nRight");
    $length = $rp[0] =~ /(\d+)/ ? $rp[0] : 0 unless ( $thread eq 'replies' );
    if( defined $needed->{replyId} ) {
        my @rps
            = $m_oDatabase->fetch_array(
            "select count(*) from replies where refererId = $needed->{replyId};"
            );
        if( $rps[0] > 0 ) {
            $length = $rps[0];
        } else {
            $length = 0;
        }
    }
    $length = 0 unless ( defined $length );
    my $lpp
        = defined param('links_pro_page')
        ? param('links_pro_page') =~ /(\d\d?\d?)/
            ? $1
            : 10
        : 10;

    my $itht
        = '<table align="center" border ="0" cellpadding ="0" cellspacing="0" summary="showThread" width="100%" >';

    $itht .= Tr(
        td( div({ align => 'right' },
                (   $m_nRight >= $m_hrSettings->{news}{right}
                    ? a({   href  => "$ENV{SCRIPT_NAME}?action=showEditor",
                            class => 'menuLink3'
                        },
                        translate('newmessage')
                        )
                        . ( $length > 5 ? '&#160;/&#160;' : '&#160;' )
                    : ''
                    )
                    . (
                    $length > 5
                    ? translate('news_pro_page') . '&#160;|&#160;'
                    : ''
                    )
                    . (
                    $length > 5
                    ? a({   href =>
                                "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=5&von=$m_nStart$replylink",
                            class => ( $lpp== 5 ? 'menuLink2' : 'menuLink3' )
                        },
                        '5'
                        )
                        . '&#160;'
                    : ''
                    )
                    . (
                    $length > 10
                    ? a({   href =>
                                "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=10&von=$m_nStart$replylink",
                            class => ( $lpp== 10 ? 'menuLink2' : 'menuLink3' )
                        },
                        '10'
                        )
                        . '&#160;'
                    : ''
                    )
                    . (
                    $length > 30
                    ? a({   href =>
                                "$ENV{SCRIPT_NAME}?action=$akt&links_pro_page=30&von=$m_nStart$replylink",
                            class => ( $lpp== 30 ? 'menuLink2' : 'menuLink3' )
                        },
                        '30'
                        )
                    : ''
                    )
            )
        )
    );

    my %needed = (
        start          => $m_nStart,
        length         => $length,
        style          => $m_sStyle,
        mod_rewrite    => $m_hrSettings->{cgi}{mod_rewrite},
        action         => $akt,
        append         => "links_pro_page=$lpp$replylink",
        path           => $m_hrSettings->{cgi}{bin},
        links_pro_page => $lpp,
    );
    my $pages = makePages( \%needed );
    $itht .= '<tr><td>' . $pages . '</td></tr>';
    $itht .= '<tr><td>' . &threadBody($thread) . '</td></tr>';
    $itht .= '<tr><td>' . $pages . '</td></tr>';
    $itht .= '</table>';
    return $itht;
}

sub threadBody {
    my $th = shift;
    my @output;
    if( ( $m_oDatabase->tableExists($th) ) ) {
        push @output,
            '<table border="0" cellpadding="0" cellspacing="10" summary="contentLayout" width="100%">';
        my $answers = defined $replyId ? " && refererId =$replyId" : '';
        my $lpp
            = defined param('links_pro_page')
            ? param('links_pro_page') =~ /(\d\d?\d?)/
                ? $1
                : 10
            : 10;
        my $sql_read
            = qq/select title,body,date,id,user,attach,format from $th where `right` <= $m_nRight $answers order by date desc LIMIT $m_nStart,$lpp /;
        my $sth = $m_dbh->prepare($sql_read);
        $sth->execute();
        while( my @data = $sth->fetchrow_array() ) {
            my $headline    = $data[0];
            my $body        = $data[1];
            my $datum       = $data[2];
            my $id          = $data[3];
            my $m_sUsername = $data[4];
            my $attach      = $data[5];
            my $format      = $data[6];
            my $replylink
                = $m_hrSettings->{cgi}{mod_rewrite}
                ? "/news$id.html"
                : "$ENV{SCRIPT_NAME}?action=showthread&amp;reply=$id&amp;thread=$th";
            my $answer = translate('answers');
            my @rps    = $m_oDatabase->fetch_array(
                "select count(*) from replies where refererId = $id;");
            my $reply
                = ( ( $rps[0] > 0 ) && $th eq 'news' )
                ? qq(<br/><a href="$replylink" class="link" >$answer:$rps[0]</a>)
                : '<br/>';
            my $menu = "";

            if( $th ne 'replies' ) {
                my $answerlink
                    = $m_hrSettings->{cgi}{mod_rewrite}
                    ? "/reply$th-$id.html"
                    : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$id&amp;thread=$th";
                my %reply = (
                    title    => translate('reply'),
                    descr    => translate('reply'),
                    src      => 'reply.png',
                    location => $answerlink,
                    style    => $m_sStyle,
                );
                $menu .= action( \%reply );
            }
            my $editlink
                = $m_hrSettings->{cgi}{mod_rewrite}
                ? "/edit$th-$id.html"
                : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd;";
            my %edit = (
                title    => translate('edit'),
                descr    => translate('edit'),
                src      => 'edit.png',
                location => $editlink,
                style    => $m_sStyle,
            );
            $menu .= action( \%edit ) if( $m_nRight > 1 );
            my $trdelete = translate('delete');
            my $deletelink
                = $m_hrSettings->{cgi}{mod_rewrite}
                ? "javascript:if(confirm('$trdelete ?')) location.href='/delete.html&amp;delete=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd'"
                : "javascript:if(confirm('$trdelete ?')) location.href='$ENV{SCRIPT_NAME}?action=delete&amp;delete=$id&amp;thread=$th&amp;von=$m_nStart&amp;bis=$m_nEnd'";
            my %delete = (
                title    => translate('delete'),
                descr    => translate('delete'),
                src      => 'delete.png',
                location => $deletelink,
                style    => $m_sStyle,
            );
            $menu .= action( \%delete ) if( $m_nRight >= 5 );
            my %parameter = (
                path  => "$m_hrSettings->{cgi}{bin}/templates",
                style => $m_sStyle,
                title => qq(<div style="white-space:nowrap;">$headline</div>),
                server => $m_hrSettings->{cgi}{serverName},
                id     => $id,
                class  => 'min',
            );

            my $win = new HTML::Window( \%parameter );
            $win->set_closeable(1);
            $win->set_collapse(1);
            $win->set_moveable(1);
            $win->set_resizeable(1);
            my $h1 = qq(<tr id="trw$id"><td valign="top">)
                . $win->windowHeader();
            my $readmore = translate('readmore');
            $reply
                .= qq(&#160;<a href="$replylink" class="link" >$readmore</a>)
                if $body =~ /\[previewende\]/ && $thread eq "news";
            my $permalink
                = $m_hrSettings->{cgi}{mod_rewrite}
                ? "/news$id.html"
                : "$ENV{SCRIPT_NAME}?action=showthread&amp;thread=$th&amp;reply=$id";

            if( $th eq 'news' ) {
                $reply
                    .= qq(&#160;<a href="$permalink" class="link" >Permalink</a>);
                $body =~ s/([^\[previewende\]]+)\[previewende\](.*)$/$1/s;
            }
            BBCODE( \$body, $ACCEPT_LANGUAGE ) if( $format eq 'bbcode' );
            $h1
                .= qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%"><tr ><td align="left">$menu</td></tr><tr><td align="left"><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$m_sUsername</td><td align="right">$datum</td></tr></table></td></tr><tr><td align="left">$body</td></tr>);
            $h1
                .= qq(<tr><td><a href="/downloads/$attach">$attach</a></td></tr>)
                if( -e "$m_hrSettings->{uploads}{path}/$attach" );
            $h1 .= qq(<tr><td align="left">$reply</td></tr></table>);
            $h1 .= $win->windowFooter();
            push @output, "$h1</td></tr>";
        }
        push @output, "</table>";
    }
    return "@output";
}

sub saveUpload {
    my $ufi = param('file');
    if( $m_nRight >= $m_hrSettings->{uploads}{right} ) {
        if($ufi) {
            my $attach = ( split( /[\\\/]/, param('file') ) )[-1];
            my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
            my $type = ( $attach =~ /\.([^\.]+)$/ ) ? $1 : 0;
            $cit =~ s/("|'|\s| )//g;
            my $sra = "$cit.$type";
            my $up  = upload('file');
            use Symbol;
            my $fh = gensym();

            open $fh, ">$m_hrSettings->{uploads}{path}/$sra.bak"
                or warn "news.pl::saveUpload: $!";

            while(<$up>) {
                print $fh $_;
            }
            close $fh;

            rename "$m_hrSettings->{uploads}{path}/$sra.bak",
                "$m_hrSettings->{uploads}{path}/$cit.$type"
                or warn "news.pl::saveUpload: $!";
            chmod( "$m_hrSettings->{'uploads'}{'chmod'}",
                "$m_hrSettings->{uploads}{path}/$sra" )
                if( -e "$m_hrSettings->{uploads}{path}/$sra" );
        }
    }
}
1;
