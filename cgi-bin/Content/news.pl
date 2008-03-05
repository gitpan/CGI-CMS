use vars qw($akt $end $length $start $thread $replyId $replylink);

sub show {
        my %needed = (action => 'news', start => $von, end => $bis, thread => 'news', id => 'c',);
        my $newMessage = translate('newMessage');
        print
          qq(<table align ="center" border ="0" cellpadding ="0" cellspacing="0" summary="layoutMenuItem"><tr><td><img onclick="location.href='#winedit'" src="/style/$style/buttons/new.png" width="20" height="20" border="0" alt="" title="$newMessage" style='cursor:pointer;font-size:14px;vertical-align:bottom;'/></td><td><a class="link" href="#winedit"  style='font-size:14px;vertical-align:bottom;'>$newMessage</a></td></tr></table>)
          if($right >= 1);
        print showThread(\%needed);
        my $catlist = readcats('news');
        my %parameter = (
                         action    => 'addNews',
                         body      => translate('body'),
                         class     => 'max',
                         attach    => $settings->{uploads}{enabled},
                         maxlength => $settings->{news}{maxlength},
                         path      => "$settings->{cgi}{bin}/templates",
                         reply     => 'none',
                         server    => $settings->{cgi}{serverName},
                         style     => $style,
                         thread    => 'news',
                         headline  => translate('headline'),
                         title     => translate('newMessage'),
                         catlist   => $catlist,
                         right     => $right,
                         html      => 0,
        );
        use HTML::Editor;
        my $editor = new HTML::Editor(\%parameter);
        print '<div align="center">';
        print $editor->show() if($right >= 2);
        print '</div>';
}

sub addNews {
        my $sbm = param('submit') ? param('submit') : 'save';
        if(not defined $sbm or ($sbm ne translate('preview'))) {
                if(defined param('message') && defined param('headline') && defined param('thread') && defined param('catlist')) {
                        my $message = param('message');
                        my $max     = $settings->{news}{maxlength};
                        $message = ($message =~ /^(.{3,$max})$/s) ? $1 : 'Invalid body';
                        my $headline = param('headline');
                        $headline = ($headline =~ /^(.{3,100})$/s) ? $1 : 'Invalid headline';
                        my $thread = param('thread');
                        $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
                        my $cat = param('catlist');
                        &saveUpload();
                        my $attach = (defined param('file')) ? (split(/[\\\/]/, param('file')))[-1] : 0;
                        my $cit = (defined $attach) ? $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0 : 0;
                        my $type = (defined $attach) ? ($attach =~ /\.([^\.]+)$/) ? $1 : 0 : 0;
                        $cit =~ s/("|'|\s| )//g;
                        my $sra = ($cit && $type) ? "$cit.$type" : undef;
                        my $format = param('format') eq 'on' ? 'html' : 'bbcode';

                        if(defined $headline && defined $message && defined $thread && $right >= 2) {
                                my %message = (title => $headline, body => $message, thread => $thread, user => $user, cat => $cat, attach => $sra, format => $format, ip => remote_addr());
                                $database->addMessage(\%message);
                                print '<div align="center">Nachricht wurde erstellt.<br/></div>';
                        }
                }
                &show();
        } else {
                &preview();
        }
}

sub saveedit {
        if(not defined param('submit') or (param('submit') ne translate('preview'))) {
                my $thread = param('thread');
                $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
                my $id = param('reply');
                $id = ($id =~ /^(\d+)$/) ? $1 : 0;
                my $headline = param('headline');
                $headline = ($headline =~ /^(.{3,50})$/) ? $1 : 0;
                my $body = param('message');
                $body = ($body =~ /^(.{3,$max})$/s) ? $1 : 'Invalid body';
                &saveUpload();
                my $attach = (defined param('file')) ? (split(/[\\\/]/, param('file')))[-1] : 0;
                my $cit = (defined $attach) ? $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0 : 0;
                my $type = (defined $attach) ? ($attach =~ /\.([^\.]+)$/) ? $1 : 0 : 0;
                $cit =~ s/("|'|\s| )//g;
                my $sra = ($cit && $type) ? "$cit.$type" : undef;
                my $format  = param('format') eq 'on' ? 'html' : 'bbcode';
                my $cat     = param('catlist');
                my %message = (thread => $thread, title => $headline, body => $body, thread => $thread, cat => $cat, attach => $sra, format => $format, id => $id, user => $user, cat => $cat, ip => remote_addr());
                $database->editMessage(\%message);
                my $rid = $id;

                if($thread eq 'replies') {
                        my @tid = $database->fetch_array("select refererId from  `replies` where id = '$id'");
                        $rid = $tid[0];
                }
                &showMessage($rid);
        } else {
                &preview();
        }
}

sub editNews {
        my $id = param('edit');
        $id = ($id =~ /^(\d+)$/) ? $1 : 0;
        my $th = param('thread');
        $th = ($th =~ /^(\w+)$/) ? $1 : 'news';
        my @data    = $database->fetch_array("select title,body,date,id,user,attach,format,cat from  `$th`  where `id` = '$id'  and  (`user` = '$user'  or `right` < '$right' );") if(defined $th);
        my $catlist = readcats($data[7]);
        my $html    = $data[6] eq 'html' ? 1 : 0;
        my %parameter = (
                         action    => 'saveedit',
                         body      => $data[1],
                         class     => 'max',
                         attach    => $settings->{uploads}{enabled},
                         maxlength => $settings->{news}{maxlength},
                         path      => "$settings->{cgi}{bin}/templates",
                         reply     => $id,
                         server    => $settings->{cgi}{serverName},
                         style     => $style,
                         thread    => $th,
                         headline  => $data[0],
                         title     => translate('editMessage'),
                         right     => $right,
                         catlist   => ($th eq 'news') ? $catlist : '&#160;',
                         html      => $html,
        );
        use HTML::Editor;
        my $editor = new HTML::Editor(\%parameter);
        print '<div align="center"><br/>';
        print $editor->show();
        print '</div>';
}

sub reply {
        my $id = param('reply');
        $id = ($id =~ /^(\d+)$/) ? $1 : 0;
        my $th = param('thread');
        $th = ($th =~ /^(\w+)$/) ? $1 : 'trash';
        my %parameter = (
                         action    => 'addreply',
                         body      => translate('insertText'),
                         class     => 'max',
                         attach    => $settings->{uploads}{enabled},
                         maxlength => $settings->{news}{maxlength},
                         path      => "$settings->{cgi}{bin}/templates",
                         reply     => $id,
                         server    => $settings->{cgi}{serverName},
                         style     => $style,
                         thread    => $th,
                         headline  => translate('headline'),
                         title     => translate('reply'),
                         right     => $right,
                         catlist   => "",
                         html      => 0,
        );
        use HTML::Editor;
        my $editor = new HTML::Editor(\%parameter);
        print '<div align="center"><br/>';
        print $editor->show();
        print '</div>';
        &showMessage($id);
}

sub addReply {
        my $body     = param('message');
        my $headline = param('headline');
        my $reply    = param('reply');
        my $format   = param('format') eq 'on' ? 'html' : 'bbcode';
        if(not defined param('submit') or (param('submit') ne translate("preview"))) {
                if(param('file')) {
                        my $attach = (split(/[\\\/]/, param('file')))[-1];
                        my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
                        my $type = ($attach =~ /\.([^\.]+)$/) ? $1 : 0;
                        $cit =~ s/("|'|\s| )//g;
                        my $sra = "$cit.$type";
                        my %reply = (title => $headline, body => $body, id => $reply, user => $user, attach => $sra, format => $html,);
                        $database->reply(\%reply);
                } else {
                        my %reply = (title => $headline, body => $body, id => $reply, user => $user, format => $format, ip => remote_addr());
                        $database->reply(\%reply);
                }
                &saveUpload();
        } else {
                &preview();
        }
        &showMessage($reply);
}

sub deleteNews {
        my $th = param('thread');
        $th = ($th =~ /^(\w+)$/) ? $1 : 'trash';
        my $del = param('delete');
        $del = ($del =~ /^(\d+)$/) ? $1 : 0;
        if($th eq 'replies') {
                my @tid = $database->fetch_array("select refererId from  `replies` where id = ?", $del);
                $rid = $tid[0];
                $database->deleteMessage($th, $del);
                &showMessage($tid[0]);
        } else {
                $database->deleteMessage($th, $del);
                $database->void("DELETE FROM `replies` where `refererId`  = ?", $del) if($th eq 'news');
                &show();
        }
}

sub showMessage {
        my $id = shift;
        if(defined param('reply') && param('reply') =~ /(\d+)/) {
                $id = $1 unless (defined $id);
        }
        my $sql_read = qq/select title,body,date,id,user,attach,format from  news where `id` = $id && `right` <= $right/;
        my $ref      = $database->fetch_hashref($sql_read);
        if($ref->{id}== $id) {
                my $title     = $ref->{title};
                my %parameter = (path => $settings->{cgi}{bin} . '/templates', style => $style, title => qq(<div style="white-space:nowrap">$title</div>), server => $settings->{cgi}{serverName}, id => "n$id", class => 'min',);
                my $window    = new HTML::Window(\%parameter);
                $window->set_closeable(0);
                $window->set_moveable(1);
                $window->set_resizeable(1);
                $ref->{body} =~ s/\[previewende\]//s;
                BBCODE(\$ref->{body}, $right) if($ref->{format} eq 'bbcode');
                my $menu       = "";
                my $answerlink = $settings->{cgi}{mod_rewrite} ? "/replynews-$ref->{id}.html" : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$ref->{id}&amp;thread=news";
                my %reply      = (title => translate('reply'), descr => translate('reply'), src => 'reply.png', location => $answerlink, style => $style,);
                my $thread     = defined param('thread') ? param('thread') : '';
                $menu .= action(\%reply) unless ($thread =~ /.*\d$/ && $right < 5);
                my $editlink = $settings->{cgi}{mod_rewrite} ? "/edit$thread-$ref->{id}.html" : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$ref->{id}&amp;thread=news";
                my %edit = (title => translate('edit'), descr => translate('edit'), src => 'edit.png', location => $editlink, style => $style,);
                $menu .= action(\%edit) if($right >= 5);
                my $deletelink = $settings->{cgi}{mod_rewrite} ? "/delete.html&amp;delete=$ref->{id}&amp;thread=news" : "$ENV{SCRIPT_NAME}?action=delete&amp;delete=$ref->{id}&amp;thread=news";
                my %delete = (title => translate('delete'), descr => translate('delete'), src => 'delete.png', location => $deletelink, style => $style,);
                $menu .= action(\%delete) if($right >= 5);
                print br(), $window->windowHeader(), qq(
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
                        print qq(<tr><td><a href="/downloads/$ref->{attach}">$ref->{attach}</a></td></tr>) if(-e "$settings->{uploads}{path}/$ref->{attach}");
                print "</table>", $window->windowFooter();
                my @rps = $database->fetch_array("select count(*) from replies where refererId = $id;");

                if($rps[0] > 0) {
                        my %needed = (action => 'showthread', start => $von, end => $bis, thread => 'replies', replyId => $id, id => 'c',);
                        print showThread(\%needed);
                }
        } else {
                &show();
        }
}

# privat
sub readcats {
        my $selected = lc(shift);
        my @cats     = $database->fetch_AoH("select * from cats where `right` <= ?", $right);
        my $list     = '<select name="catlist" size="1">';
        for(my $i = 0 ; $i <= $#cats ; $i++) {
                my $catname = lc($cats[$i]->{name});
                $list .= ($catname eq $selected) ? qq(<option value="$catname"  selected="selected">$catname</option>) : qq(<option value="$catname">$catname</option>);
        }
        $list .= '</select>';
        return $list;
}

sub preview {
        my $thread = param('thread');
        $thread = ($thread =~ /^(\w+)$/) ? $1 : 'trash';
        my $id = param('reply');
        $id = ($id =~ /^(\d+)$/) ? $1 : 0;
        my $headline = param('headline');
        $headline = ($headline =~ /^(.{3,50})$/) ? $1 : 0;
        my $body       = param('message');
        my $selected   = param('catlist');
        my $catlist    = readcats($selected);
        my %wparameter = (path => "$settings->{cgi}{bin}/templates", style => $style, title => $headline, server => "http://localhost", id => "previewWindow", class => "min",);
        my $win        = new HTML::Window(\%wparameter);
        $win->set_closeable(1);
        $win->set_collapse(1);
        $win->set_moveable(1);
        $win->set_resizeable(1);
        print "<br/>";
        print $win->windowHeader();
        my $html = param('format') eq 'on' ? 1 : 0;
        BBCODE(\$body, $right) unless ($html);
        print qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary ="0"  width="500"><tr ><td align='left'>$body</td></tr></table>);
        print $win->windowFooter();
        my %parameter = (
                         action    => $action,
                         body      => param('message'),
                         class     => 'max',
                         attach    => $settings->{uploads}{enabled},
                         maxlength => $settings->{news}{maxlength},
                         path      => "$settings->{cgi}{bin}/templates",
                         reply     => $id,
                         server    => $settings->{cgi}{serverName},
                         style     => $style,
                         thread    => $thread,
                         headline  => $headline,
                         title     => translate("editMessage"),
                         right     => $right,
                         catlist   => ($thread eq 'news') ? $catlist : '&#160;',
                         html      => $html,
        );
        use HTML::Editor;
        my $editor = new HTML::Editor(\%parameter);
        print '<div align="center"><br/>';
        print $editor->show();
        print '</div>';
}

sub saveUpload {
        my $ufi = param('file');
        if($ufi) {
                my $attach = (split(/[\\\/]/, param('file')))[-1];
                my $cit = $attach =~ /^(\S+)\.[^\.]+$/ ? $1 : 0;
                my $type = ($attach =~ /\.([^\.]+)$/) ? $1 : 0;
                $cit =~ s/("|'|\s| )//g;
                my $sra = "$cit.$type";
                my $up  = upload('file');
                use Symbol;
                my $fh = gensym();

                #my $ctype = uploadInfo($ufi)->{'Content-Type'};#do something with it
                open $fh, ">$settings->{uploads}{path}/$sra.bak" or warn "news.pl::saveUpload: $!";

                while(<$up>) {
                        print $fh $_;
                }
                close $fh;

                rename "$settings->{uploads}{path}/$sra.bak", "$settings->{uploads}{path}/$cit.$type" or warn "news.pl::saveUpload: $!";
                chmod("$settings->{'uploads'}{'chmod'}", "$settings->{uploads}{path}/$sra") if(-e "$settings->{uploads}{path}/$sra");
        }
}

# sub newAction {
#         print start_form(-method => "POST", -action => "$ENV{SCRIPT_NAME}",),
#           table(
#                 {-align => 'center', -border => 0, width => "80%%"},
#                 Tr({-align => 'left', -valign => 'top'}, td("Action"), td(textfield({-style => "width:100%", -name  => 'new_action',}, 'Action'))),
#                 Tr({-align => 'left', -valign => 'top'}, td("File"),   td(textfield({-name  => 'new_file',   -style => "width:100%"},  'File'))),
#                 Tr({-align => 'left', -valign => 'top'}, td("Title"),  td(textfield({-name  => 'new_title',  -style => "width:100%"},  'Title'))),
#                 Tr({-align => 'left',  -valign => 'top'}, td("right "), td(popup_menu(-name => 'new_right', -values                 => [0,            1,        2,       3,                        4,    5],    -style => "width:100%"))),
#                 Tr({-align => 'left',  -valign => 'top'}, td("Box"),    td(textfield({-name => 'new_box',   -style                  => "width:100%"}, ''))),
#                 Tr({-align => 'left',  -valign => 'top'}, td("sub"),    td(textfield({-name => 'new_sub',   -style                  => "width:100%"}, ''))),
#                 Tr({-align => 'left',  -valign => 'top'}, td({colspan   => 2},              script({type    => 'text/javascript',}, "html = 1;bbcode = false;printButtons();"))),
#                 Tr({-align => 'left',  -valign => 'top'}, td({colspan   => 2},              textarea(-name  => 'txt',               -id               => 'txt', -default => 'print "new action";', -rows => 50, -style => "width:100%;height:300px;"))),
#                 Tr({-align => 'right', -valign => 'top'}, td({colspan   => 2},              submit))
#           ),
#           hidden({-name => 'enquiry'}, '1'), hidden({-name => 'action'}, 'addnewAction'), end_form;
# }
#
# sub addnewAction {
#         my $new_action = param('new_action') ? param('new_action') : $id;
#         my $new_file   = param('new_file')   ? param('new_file')   : $file;
#         my $new_title  = param('new_title')  ? param('new_title')  : $title;
#         my $new_right  = param('new_right')  ? param('new_right')  : $nright;
#         my $new_box    = param('new_box')    ? param('new_box')    : '';
#         my $new_sub    = param('new_sub')    ? param('new_sub')    : 'main';
#         my $sql = q/INSERT INTO actions (`action`,`file`,title,`right`,box,sub,) VALUES (?,?,?,?,?,?)/;
#         $database->void($sql, $new_action, $new_file, $new_title, $new_right, $new_box, $new_sub);
# }

sub showThread {
        my $needed = shift;
        $akt       = $needed->{action};
        $end       = $needed->{end};
        $start     = $needed->{start};
        $thread    = $needed->{thread};
        $replyId   = $needed->{replyId};
        $replylink = defined $replyId ? $replyId : '';

        $length = $database->tableLength($thread, $right) unless ($thread eq 'replies');
        if(defined $needed->{replyId}) {
                my @rps = $database->fetch_array("select count(*) from replies where refererId = $needed->{replyId};");
                if($rps[0] > 0) {
                        $length = $rps[0];
                } else {
                        $length = 0;
                }
        }
        $length = 0 unless (defined $length);
        my $itht = '<table align="center" border ="0" cellpadding ="2" cellspacing="10" summary="newTopic" width="100%" >';

        if(defined $start && defined $end) {
                $start = 0       if($start < 0);
                $end   = $length if($end > $length);
                $itht .= &ebis() if($length > 10);
                $itht .= '<tr><td>' . &threadBody($thread) . '</td></tr>';
                $itht .= &ebis() if($length > 10);
        }
        $itht .= '</table>';
        return $itht;
}

sub ebis {
        my $prev  = $start- 10;
        my $next1 = $start;
        $next1 = 10 if($prev < 0);
        $prev  = 0  if($prev < 0);
        my $seiten  = translate('sites');
        my $ebis    = qq(<tr><td align="center"><a class="menuLink2" name ="pages">$seiten:</a>);
        my $npevbis = ($settings->{cgi}{mod_rewrite}) ? "/$prev/$next1/$akt$replylink.html" : "$ENV{SCRIPT_NAME}?action=$akt&amp;von=$prev&amp;bis=$next1&amp;reply=$replylink";
        $ebis .= qq(<a class="menuLink2" href="$npevbis"><img src="/style/$style/prev.png" alt="previous" border="0" title="previous" style="cursor:pointer;"/></a>&#160;) if($start- 10 >= 0);

        my $sites = (int($length/ 10)+ 1)* 10 unless ($length % 10== 0);
        $sites = (int($length/ 10))* 10 if($length % 10== 0);
        my $beginn = $start/ 10;
        $beginn = (int($start/ 10)+ 1)* 10 unless ($start % 10== 0);
        $beginn = 0 if($beginn < 0);
        my $b = ($sites >= 10) ? $beginn : 0;
        $b = ($beginn- 5 >= 0) ? $beginn- 5 : 0;
        my $end = ($sites >= 10) ? $b+ 10 : $sites;
      ECT: {

                while($b < $end) {
                        my $c = $b* 10;
                        my $d = $c+ 10;
                        $d = $length if($d > $length);
                        my $svbis = ($settings->{cgi}{mod_rewrite}) ? "/$c/$d/$akt$replylink.html" : "$ENV{SCRIPT_NAME}?action=$akt&amp;von=$c&amp;bis=$d&amp;reply=$replylink";
                        if($b* 10 eq $start) {
                                $ebis .= qq(<a class="menuLink3" href="$svbis">$b</a>&#160;);
                        } else {
                                $ebis .= qq(<a class="menuLink2" href="$svbis">$b</a>&#160;);
                        }
                        last ECT if($d eq $length);
                        $b++;
                }
        }
        my $v    = $start+ 10;
        my $next = $v+ 10;
        $next = $length if($next > $length);
        my $esvbis = ($settings->{cgi}{mod_rewrite}) ? "/$v/$next/$akt$replylink.html" : "$ENV{SCRIPT_NAME}?action=$akt&amp;von=$v&amp;bis=$next&amp;reply=$replylink";
        $ebis .= qq(<a class="menuLink2" href="$esvbis"><img src="/style/$style/next.png" border="0" alt="next" title="next" style="cursor:pointer;"/></a>&#160;) if($v < $length);
        $ebis .= '</td></tr>';
        return $ebis;
}

sub threadBody {
        my $th = shift;
        my @output;
        my ($db_clause, $table) = (" FROM $1", $2) if $th =~ /(.*)\.(.*)/;
        $dbh->quote(\$table);
        $db_clause = defined $db_clause ? $db_clause : ' ';

        if(($dbh->selectrow_array("SHOW TABLES $db_clause LIKE '$th'"))) {
                push @output, '<table  border="0" cellpadding="0" cellspacing="10" summary="contentLayout"   width="100%">';
                my $answers  = defined $replyId ? " && refererId ='$replyId'" : '';
                my $sql_read = qq/select title,body,date,id,user,attach,format from  `$th`  where `right` <= $right $answers order by date desc LIMIT $start,10 /;
                my $sth      = $dbh->prepare($sql_read);
                $sth->execute();
                while(my @data = $sth->fetchrow_array()) {
                        my $headline = $data[0];
                        $headline =~ s/ /&#160;/g;
                        my $body      = $data[1];
                        my $datum     = $data[2];
                        my $id        = $data[3];
                        my $username  = $data[4];
                        my $attach    = $data[5];
                        my $format    = $data[6];
                        my $replylink = $settings->{cgi}{mod_rewrite} ? "/news$id.html" : "$ENV{SCRIPT_NAME}?action=showthread&amp;reply=$id&amp;thread=$th";
                        my $answer    = translate('answers');
                        my @rps       = $database->fetch_array("select count(*) from replies where refererId = $id;");
                        my $reply     = (($rps[0] > 0) && $th eq 'news') ? qq(<br/><a href="$replylink" class="link" >$answer:$rps[0]</a>) : '<br/>';
                        my $menu      = "";

                        if($th ne 'replies') {
                                my $answerlink = $settings->{cgi}{mod_rewrite} ? "/reply$th-$id.html" : "$ENV{SCRIPT_NAME}?action=reply&amp;reply=$id&amp;thread=$th";
                                my %reply = (title => translate('reply'), descr => translate('reply'), src => 'reply.png', location => $answerlink, style => $style,);
                                $menu .= action(\%reply);
                        }
                        my $editlink = $settings->{cgi}{mod_rewrite} ? "/edit$th-$id.html" : "$ENV{SCRIPT_NAME}?action=edit&amp;edit=$id&amp;thread=$th";
                        my %edit = (title => translate('edit'), descr => translate('edit'), src => 'edit.png', location => $editlink, style => $style,);
                        $menu .= action(\%edit) if($right > 1);
                        my $deletelink = $settings->{cgi}{mod_rewrite} ? "/delete.html&amp;delete=$id&amp;thread=$th" : "$ENV{SCRIPT_NAME}?action=delete&amp;delete=$id&amp;thread=$th";
                        my %delete = (title => translate('delete'), descr => translate('delete'), src => 'delete.png', location => $deletelink, style => $style,);
                        $menu .= action(\%delete) if($right >= 5);
                        my %parameter = (path => "$settings->{cgi}{bin}/templates", style => $style, title => qq(<div style="white-space:nowrap;">$headline</div>), server => $settings->{cgi}{serverName}, id => $id, class => 'min',);

                        my $win = new HTML::Window(\%parameter);
                        $win->set_closeable(1);
                        $win->set_collapse(1);
                        $win->set_moveable(1);
                        $win->set_resizeable(1);
                        my $h1       = qq(<tr id="trw$id"><td valign="top">) . $win->windowHeader();
                        my $readmore = translate('readmore');
                        $reply .= qq(&#160;<a href="$replylink" class="link" >$readmore</a>) if $body =~ /\[previewende\]/;
                        $body =~ s/([^\[previewende\]]+)\[previewende\](.*)$/$1/s if $th eq 'news';
                        BBCODE(\$body, $right) if($format eq 'bbcode');
                        $h1 .=
                          qq(<table align="left" border ="0" cellpadding="0" cellspacing="0" summary="threadBody"  width="100%"><tr ><td align="left">$menu</td></tr><tr><td align="left"><table align="left" border ="0" cellpadding="0" cellspacing="0" summary="user_datum"  width="100%"><tr><td align="left">$username</td><td align="right">$datum</td></tr></table></td></tr><tr><td align="left">$body</td></tr>);
                          $h1 .= qq(<tr><td><a href="/downloads/$attach">$attach</a></td></tr>) if(-e "$settings->{uploads}{path}/$attach");
                        $h1 .= qq(<tr><td align="left">$reply</td></tr></table>);
                        $h1 .= $win->windowFooter();
                        push @output, "$h1</td></tr>";
                }
                push @output, "</table>";
        }
        return "@output";
}
1;
