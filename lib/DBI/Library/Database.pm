package DBI::Library::Database;
use strict;
use warnings;
no warnings "uninitialized";
use HTML::Entities;

use vars
    qw( $m_dbh $dsn $DefaultClass @EXPORT_OK @ISA %functions  $mod_rewrite
    $serverName $min_secs);
$DefaultClass = 'DBI::Library::Database'
    unless defined $DBI::Library::Database::DefaultClass;
require Exporter;
use DBI::Library qw(:all $m_dbh $dsn);
@DBI::Library::Database::ISA    = qw(DBI::Library Exporter);
@DBI::Library::Database::EXPORT = qw(useexecute);
@DBI::Library::Database::EXPORT_OK
    = qw(getActionRight CurrentPass CurrentUser CurrentHost CurrentDb Driver execute useexecute quote void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute tableLength tableExists searchDB addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage initDB rewrite  checkFlood GetColumns GetAttrs GetCollation GetColumnCollation GetTypes GetExtra GetNull GetEngineForRow GetEngines GetCharacterSet GetDataBases GetAutoIncrement GetPrimaryKey GetAutoIncrementValue fetch_string);
%DBI::Library::Database::EXPORT_TAGS = (
    'all' => [
        qw(getActionRight CurrentPass CurrentUser CurrentHost CurrentDb Driver  searchDB addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage initDB tableLength tableExists  useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute rewrite checkFlood GetColumns GetAttrs GetCollation GetColumnCollation GetTypes GetExtra GetNull GetEngineForRow GetEngines GetCharacterSet GetDataBases GetAutoIncrement GetPrimaryKey GetAutoIncrementValue fetch_string)
    ],
    'dynamic' => [
        qw(getActionRight CurrentPass CurrentUser CurrentHost CurrentDb Driver useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute)
    ],
    'independent' => [
        qw(getActionRight CurrentPass CurrentUser CurrentHost CurrentDb Driver tableLength tableExists initDB useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute fetch_string)
    ],
    'lze' => [
        qw(getActionRight CurrentPass CurrentUser CurrentHost CurrentDb Driver addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage rewrite checkFlood GetColumns GetAttrs GetCollation GetColumnCollation GetTypes GetExtra GetNull GetEngineForRow GetEngines GetCharacterSet GetDataBases GetAutoIncrement GetPrimaryKey GetAutoIncrementValue)
    ],
);
$DBI::Library::Database::VERSION = '0.38';
$mod_rewrite                     = 0;
$min_secs                        = 10;

=head1 NAME

DBI::Library::Database - Database interface for CGI::CMS::GUI

=head1 SYNOPSIS

use DBI::Library::Database;

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    bless $self, ref $class || $class || $DefaultClass;
    $m_dbh = $self->SUPER::initDB(@initializer) if(@initializer);
    return $self;
}

=head2 addMessage

     my %message = (

          thread => $thread,

          title => $headline,

          body  => $body,

          thread => $thread,

          cat    => $cat,

          attach => $sra,

          format => $format,

          id => $id,

          user => $m_sUser,

          attach => $m_sFilename,

          ip => remote_addr(),


     );

     addMessage(\%message);
=cut

sub addMessage {
    my ( $self, @p ) = getSelf(@_);
    if( $self->checkFlood( $p[0]->{ip} ) ) {
        my $thread = defined $p[0]->{thread} ? $p[0]->{thread} : 'trash';
        $thread = ( $thread =~ /^(\w{3,50})$/ ) ? $1 : 'trash';
        $thread = $m_dbh->quote_identifier($thread);
        my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
        $headline = ( $headline =~ /^(.{3,100})$/ ) ? $1 : 'Invalid headline';
        my $m_sUser = defined $p[0]->{user} ? $p[0]->{user} : 'guest';
        my $body    = defined $p[0]->{body} ? $p[0]->{body} : 'Body';
        my $cat     = defined $p[0]->{cat}  ? $p[0]->{cat}  : '/news';
        $cat = ( $cat =~ /^(.{3,50})$/ ) ? $1 : '/news';
        my $rght       = $self->catright($cat);
        my $attach     = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
        my $format     = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
        my $m_hrAction = defined $p[0]->{action} ? $p[0]->{action} : 'news';
        my $sql
            = "insert into $thread (`title`,`body`,`attach`,`cat`,`right`,`user`,`action`,`format`) values(?,?,?,?,?,?,?,?)";
        my $sth = $m_dbh->prepare($sql);
        $sth->execute( $headline, $body, $attach, $cat, $rght, $m_sUser,
            $m_hrAction, $format )
            or warn $m_dbh->errstr;
        $sth->finish();
        return 1;
    } else {
        return 0;
    }
}

=head2 editMessage()

     my %message = (

             thread => $thread,

          title => $headline,

          body  => $body,

          thread => $thread,

          cat    => $cat,

          attach => $sra,

          format => $format,

          id => $id,

          user => $m_sUser,

          attach => $m_sFilename,

          ip => remote_addr(),

     );

     editMessage(\%message);

=cut

sub editMessage {
    my ( $self, @p ) = getSelf(@_);
    if( $self->checkFlood( $p[0]->{ip} ) ) {
        my $thread = defined $p[0]->{thread} ? $p[0]->{thread} : 'trash';
        $thread = ( $thread =~ /^(\w{3,50})$/ ) ? $1 : 'trash';
        $thread = $m_dbh->quote_identifier($thread);
        my $refid    = defined $p[0]->{id}    ? $p[0]->{id}    : 1;
        my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
        $headline = ( $headline =~ /^(.{3,100})$/ ) ? $1 : 'Invalid headline';
        my $m_sUser = defined $p[0]->{user}   ? $p[0]->{user}   : 'guest';
        my $body    = defined $p[0]->{body}   ? $p[0]->{body}   : 'Body';
        my $attach  = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
        my $format  = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
        my $cat     = defined $p[0]->{cat}    ? $p[0]->{cat}    : 'news';

        if( $attach ne '0.0' ) {
            my $sql_insert
                = qq/update $thread set title =?, body =? , attach= ?,format =?,user =?,cat =?,`right` =? where id = ?;/;
            my $sth = $m_dbh->prepare($sql_insert);
            $sth->execute( $headline, $body, $attach, $format, $m_sUser, $cat,
                $self->catright($cat), $refid )
                or warn $m_dbh->errstr;
            $sth->finish();
        } else {
            my $sql_insert
                = qq/update $thread set title =?, body = ? ,format = ?,user = ?,cat = ?,`right` =?  where id = ?;/;
            my $sth = $m_dbh->prepare($sql_insert);
            $sth->execute( $headline, $body, $format, $m_sUser, $cat,
                $self->catright($cat), $refid )
                or warn $m_dbh->errstr;
            $sth->finish();
        }
    }
}

=head2 reply

     my %reply =(

          title => $headline,

          body => $body,

          id => $reply,

          user => $m_sUser,

          attach =>  $sra,

          format => $html,

          ip => remote_addr(),

     );

     reply(\%reply);

=cut

sub reply {
    my ( $self, @p ) = getSelf(@_);
    if( $self->checkFlood( $p[0]->{ip} ) ) {
        my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
        $headline = ( $headline =~ /^(.{3,100})$/ ) ? $1 : 'Invalid headline';
        my $m_sUser = defined $p[0]->{user}   ? $p[0]->{user}   : 'guest';
        my $body    = defined $p[0]->{body}   ? $p[0]->{body}   : 'Body';
        my $attach  = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
        my $format  = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
        my $refid   = defined $p[0]->{id}     ? $p[0]->{id}     : 1;
        my $sql
            = "insert into replies (`title`,`body`,`attach`,`right`,`user`,`refererId`,`format`) values(?,?,?,?,?,?,?)";
        my $sth = $m_dbh->prepare($sql);
        $sth->execute( $headline, $body, $attach, $self->topicright($refid),
            $m_sUser, $refid, $format )
            or warn $m_dbh->errstr;
        $sth->finish();
    }
}

=head2 deleteMessage

      $bool = $self->deleteMessage($table,$id);

=cut

sub deleteMessage {
    my ( $self, @p ) = getSelf(@_);
    my $table      = $p[0];
    my $id         = $p[1];
    my $sql_backup = "select * from $table  Where id  = '$id'";
    my $sth_backup = $m_dbh->prepare($sql_backup);
    $sth_backup->execute();
    my $backup = $sth_backup->fetchrow_hashref();
    my $c
        = ( $table eq 'replies' )
        ? 'replies'
        : $self->quote( $backup->{cat} );
    my $sql_trash
        = "insert into `trash`  (`table`,`oldId`,`title`,`body`,`date`,`user`,`right`,`attach`,`cat`,`sticky`) values(?,?,?,?,?,?,?,?,?,?)";
    my $sth_trash = $m_dbh->prepare($sql_trash);
    $sth_trash->execute(
        $table,           $id,               $backup->{title},
        $backup->{body},  $backup->{date},   $backup->{user},
        $backup->{right}, $backup->{attach}, $c,
        $backup->{sticky}
    );
    my $sql_delete = "DELETE FROM $table Where id  = '$id'";
    my $sth        = $m_dbh->prepare($sql_delete);
    $sth->execute() or warn $m_dbh->errstr;
    $sth->finish();
}

=head2 readMenu()

      @menu = $m_oDatabase->readMenu($thread,$m_nRight,$m_nStart,$m_nEnd,$rewrite);

=cut

sub readMenu {
    my ( $self, @p ) = getSelf(@_);
    my $thread   = $p[0];
    my $m_nRight = $p[1];
    my $m_nStart = $p[2];
    my $m_nEnd   = $p[3];
    my $rewrite  = $p[4];
    $m_nStart = 0  unless ( defined $m_nStart );
    $m_nEnd   = 10 unless ( defined $m_nEnd );
    my $limit = $m_nEnd- $m_nStart;
    $rewrite = 0 unless ( defined $rewrite );

    my $sql_read
        = qq/select title,id from  $thread where `right` <= $m_nRight order by date desc  LIMIT $m_nStart , $limit/;
    my $sth = $m_dbh->prepare($sql_read);
    $sth->execute();
    my @output;
    while( my @data = $sth->fetchrow_array() ) {
        my $headline = $data[0];
        my $id       = $data[1];
        $headline =~ s/(.{15}).+/$1.../;
        my $nl
            = ($rewrite)
            ? "/$m_nStart/$m_nEnd/$thread.html#$id"
            : "$ENV{SCRIPT_NAME}?action=$thread&amp;von=$m_nStart&amp;bis=$m_nEnd#$id";
        push @output,
            {
            text => $headline,
            href => $nl,
            };
    }
    $sth->finish();
    return @output;
}

=head2 rss()

      $rss = $m_oDatabase->rss($thread,int start);

=cut

sub rss {
    my ( $self, @p ) = getSelf(@_);
    my $thread = $p[0];
    $thread = 'news' unless ( defined $thread );
    my $m_nStart = $p[1];
    $m_nStart = 0 unless ( defined $m_nStart );
    my $time = localtime;
    my $sql_read
        = qq/select *from  $thread  where `right` = '0' order by id desc  LIMIT $m_nStart , 10/;
    my $sth = $m_dbh->prepare($sql_read);
    $sth->execute();
    my @output;
    push @output,
        qq(Content-Type: text/rss\n\n<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://my.netscape.com/rdf/simple/0.9/"><channel><title>$thread</title>\n<description>Die Topics als rss.</description>\n<link>$serverName</link>\n<language>de</language>\n<pubDate>$time</pubDate>\n</channel>\n);

    while( my @data = $sth->fetchrow_array() ) {
        my $headline = $data[0];
        my $href     = $data[9];
        my $link
            = $mod_rewrite
            ? "$serverName/$thread.html#$href"
            : "$serverName?action=$thread;#$href";
        push @output,
            "\n<item>\n<title>$headline</title>\n<link>$link</link>\n</item>\n";
    }
    push @output, "\n</rdf:RDF>";
    $sth->finish();
    return @output;
}

=head2 getName()

      $name = $m_oDatabase->getName($m_sSid);

=cut

sub getName {
    my ( $self, @p ) = getSelf(@_);
    my $m_sSid = $p[0];
    if( defined $m_sSid ) {
        my $sql = "SELECT user FROM `users` where sid = ?;";
        my $sth = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
        $sth->execute($m_sSid) or warn $m_dbh->errstr;
        my $name = $sth->fetchrow_array();
        $sth->finish();
        return $name;
    } else {
        return "guest";
    }
}

=head2 setSid

$m_sSidid = $m_oDatabase->setSid(name,pass);

=cut

sub setSid {
    my ( $self, @p ) = getSelf(@_);
    my $name = $p[0];
    my $pass = $p[1];
    my $ip   = $p[2];
    use POSIX qw(strftime);
    my $time = strftime "%d.%m.%Y %H:%M:%S", localtime;
    use MD5;
    my $md5 = new MD5;
    $md5->add($name);
    $md5->add($pass);
    $md5->add($time);
    $md5->add($ip);
    my $fingerprint = $md5->hexdigest();
    my $sql         = "UPDATE users  SET sid = ? ,ip = ? WHERE user = ?";
    my $sth         = $m_dbh->prepare($sql);
    $sth->execute( $fingerprint, $ip, $name );
    $sth->finish();
    return $fingerprint;
}

=head2 checkSession

      $bool = $m_oDatabase->checkSession($m_sUser,$m_sSid);

=cut

sub checkSession {
    my ( $self, @p ) = getSelf(@_);
    my $m_sUser = shift @p;
    my $ssid    = shift @p;
    my $ip      = shift @p;
    my $return  = 0;

    if( length($m_sUser) > 3 && length($ssid) > 3 ) {
        my $sql = "select sid from  users where  user = ?";
        my $sth = $m_dbh->prepare($sql);
        $sth->execute($m_sUser) or warn $m_dbh->errstr;
        my $session = $sth->fetchrow_array();
        $sth->finish();
        $return = 1
            if( defined $session && defined $ssid && $ssid eq $session );
    }
    return $return;
}

=head2 checkPass()

=cut

sub checkPass {
    my ( $self, @p ) = getSelf(@_);
    my $u  = $p[0];
    my $cp = $p[1];
    use MD5;
    if( defined $u ) {
        my $sql = qq(SELECT pass  FROM users where user = ?);
        my $sth = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
        $sth->execute($u);
        my $cpass = $sth->fetchrow_array();
        $sth->finish();
        $cpass = defined $cpass ? $cpass : 0;
        return ( $cp eq $cpass ) ? 1 : 0;
    }
    return 0;
}

=head2 getAction

      $hashref = $m_oDatabase->getAction($m_hrAction);

=cut

sub getAction {
    my ( $self, @p ) = getSelf(@_);
    my $m_hrAction = $p[0];
    my $sql        = qq/select * from actions where action = ?/;
    my $sth        = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
    $sth->execute($m_hrAction);
    my $hr = $sth->fetchrow_hashref;
    $sth->finish();
    return $hr;
}

=head2 getActionRight

      $m_nRight = $m_oDatabase->getActionRight($m_hrAction);

=cut

sub getActionRight {
    my ( $self, @p ) = getSelf(@_);
    my $m_hrAction = $p[0];
    my $sql        = qq/select `right` from actions where action = ?/;
    my $sth        = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
    $sth->execute($m_hrAction);
    my $hr = $sth->fetchrow_array;
    $sth->finish();
    return $hr;
}

=head2 right()

      $m_nRight = right($m_hrAction,$m_sUsername);

=cut

sub right {
    my ( $self, @p ) = getSelf(@_);
    my $m_sUser = $p[0];
    return userright($m_sUser);
}

=head2 userright()

      userright(user);

=cut

sub userright {
    my ( $self, @p ) = getSelf(@_);
    my $m_sUser = $p[0];
    my $sql
        = "SELECT `right`,`user` FROM users where `user` = ? HAVING `user` = ?";
    my $sth = $m_dbh->prepare($sql);
    $sth->execute( $m_sUser, $m_sUser );
    my @q = $sth->fetchrow_array;
    $sth->finish();
    return $q[0];
}

=head2 topicright()

      topicright(id);

=cut

sub topicright {
    my ( $self, @p ) = getSelf(@_);
    my $id  = $p[0];
    my $sql = "SELECT `right` FROM news where id = ?";
    my $sth = $m_dbh->prepare($sql);
    $sth->execute($id);
    my @q = $sth->fetchrow_array;
    $sth->finish();
    return $q[0];
}

=head2 catright()

      catright(name);
      todo rekursiv fetch subcat

=cut

#todo rekursiv über id.
sub catright {
    my ( $self, @p ) = getSelf(@_);
    my $cat = $p[0];
    $cat =~ s?/??g;
    my @cats = $self->fetch_AoH("SELECT * FROM cats");
    for( my $i = 0; $i <= $#cats; $i++ ) {
        return $cats[$i]->{right} if( $cats[$i]->{name} eq $cat );
    }
    return 0;
}

=head2 createMenu()

      createMenu(name);

=cut

sub createMenu {
    my ( $self, @p ) = getSelf(@_);
    my $thread          = $p[0];
    my $sql_createTable = qq/
              CREATE TABLE ? (
                     `title` varchar(100) NOT NULL default '',
                     `action` varchar(100) NOT NULL default '',
                     `src` varchar(100) NOT NULL default '',
                     `right` int(11) NOT NULL default '0',
                     `position` varchar(5) NOT NULL default 'left',
                     `submenu` varchar(100) default NULL,
                     `id` int(11) NOT NULL auto_increment,
                     `target` int(11) default NULL,
                     PRIMARY KEY  (`id`)
              ) ENGINE=MyISAM DEFAULT CHARSET=latin1 ;/;
    $self->void( $sql_createTable, $thread );
}

=head2 isMember

      isMember($m_sUser);

checkt ob es den user bereits gibt.


=cut

sub isMember {
    my ( $self, @p ) = getSelf(@_);
    my $m_sUser = lc $p[0];
    if( defined $m_sUser ) {
        my $sth = $m_dbh->prepare("SELECT user  FROM users where user = ?")
            or warn $m_dbh->errstr;
        $sth->execute($m_sUser);
        my ($member) = $sth->fetchrow_array();
        $sth->finish();
        return defined $member ? ( $m_sUser eq $member ) ? 1 : 0 : 0;
    } else {
        return 1;
    }
}

=head2 hasAcount

      hasAcount($email)

checkt ob es die  email Adresse bereits gibt.

=cut

sub hasAcount {
    my ( $self, @p ) = getSelf(@_);
    my $mail = lc $p[0];
    if( defined $mail ) {
        my $sth = $m_dbh->prepare("SELECT email  FROM users where email = ?")
            or warn $m_dbh->errstr;
        $sth->execute($mail);
        my ($email) = $sth->fetchrow_array();
        $sth->finish();
        return ( $mail eq $email ) ? 1 : 0;
    } else {
        return 1;
    }
}

=head2 addUser

      $m_oDatabase->addUser(user, pass);

=cut

sub addUser {
    my ( $self, @p ) = getSelf(@_);
    my $newuser = $p[0];
    my $newpass = $p[1];
    use MD5;
    my $md5 = new MD5;
    $md5->add($newuser);
    $md5->add($newpass);
    my $fingerprint = $md5->hexdigest();
    my $mail        = $p[2];
    my $sql_addUser
        = qq/insert into users (user,pass,email,`right`) values(?,?,?,1)/;
    my $sth = $m_dbh->prepare($sql_addUser);
    my $anzahl = $sth->execute( $newuser, $fingerprint, $mail )
        or warn $m_dbh->errstr;
    $sth->finish();
    return 1 if( $anzahl+ 0== 1 );
}

=head2 rewrite()

enable or disable rewrite.

=cut

sub rewrite {
    my ( $self, @p ) = getSelf(@_);
    if( defined $p[0] ) {
        if( $p[0] =~ /(0|1)/ ) {
            $mod_rewrite = $1;
        }
    } else {
        return $mod_rewrite;
    }

}

=head2 serverName()

set serverName.

=cut

sub serverName {
    my ( $self, @p ) = getSelf(@_);
    if( defined $p[0] ) {
        $serverName = $p[0];
    } else {
        return $serverName;
    }

}

=head2 floodtime()

set floodtime.

=cut

sub floodtime {
    my ( $self, @p ) = getSelf(@_);
    if( defined $p[0] ) {
        $min_secs = $p[0];
    } else {
        return $min_secs;
    }

}

=head2 searchDB()

       searchDB($m_hrQuery,$spalte,$table);

regexp suche  in tabelle ...

=cut

sub searchDB {
    my ( $self, @p ) = getSelf(@_);
    my $m_hrQuery  = $p[0];
    my $spalte     = $p[1];
    my $table      = $p[2];
    my $sql_select = "SELECT * FROM " . $table;
    $sql_select .= " WHERE $spalte REGEXP '($m_hrQuery)'";
    my $b
        = '<table align="center" summary="layoutSearch" border="0" cellpadding="0" cellspacing="0" width="100%">';
    my @messages = $self->fetch_AoH($sql_select);

    for( my $i = 0; $i <= $#messages; $i++ ) {
        my $link
            = ($mod_rewrite)
            ? "/showMessage$messages[$i]->{id}.html"
            : "$ENV{SCRIPT_NAME}?action=showMessage&amp;reply=$messages[$i]->{id}";
        $b
            .= qq(<tr><td><a href="$link">$messages[$i]->{title}</a></td><td align="right"><font size="-1">$messages[$i]->{datum}</font></td></tr>);
    }
    $b .= '</table>';
    return $b;
}

=head2 fulltext()

      @messages = fulltext(query,table);

fulltextsuche in tabelle ...

=cut

sub fulltext {
    my ( $self, @p ) = getSelf(@_);
    my $m_hrQuery = $p[0];
    my $table     = $p[1];
    my $m_nRight  = $p[2];
    my $m_nStart  = $p[3] ? $p[3] : 0;
    my $m_nEnd    = $p[4] ? $p[4] : 100;
    my $limit     = $m_nEnd- $m_nStart;
    my $b
        = '<table align="center" summary="fulltext" border="0" cellpadding="2" cellspacing="0" width="*"><tr><td class="caption">Title</td><td class="caption">User</td><td class="caption">Datum</td></tr>';
    my @messages
        = $self->fetch_AoH(
        "SELECT * FROM $table  where `right` <= $m_nRight and MATCH (title,body) AGAINST('$m_hrQuery') order by date desc  LIMIT $m_nStart , $limit"
        );

    for( my $i = 0; $i <= $#messages; $i++ ) {
        my $body = $messages[$i]->{body};
        $body =~ s/\[([^\]])+\]//gs;
        $body =~ s?<[^>]+>??gs;
        my $j = index $body, $m_hrQuery;
        $j = $j > 50 ? $j- 50 : 0;
        $body = substr( $body, $j, 150 );
        $body =~ s?$m_hrQuery?<b>$m_hrQuery</b>?g;
        $messages[$i]->{title} = encode_entities( $messages[$i]->{title} );
        my $link
            = ($mod_rewrite)
            ? "/showMessage$messages[$i]->{id}.html"
            : "$ENV{SCRIPT_NAME}?action=showMessage&amp;reply=$messages[$i]->{id}";
        $b
            .= qq(<tr><td class="values"><a href="$link" class="menuLink">$messages[$i]->{title}</a></td><td class="values">$messages[$i]->{user}</td><td align="right" class="values"><font size="-1">$messages[$i]->{date}</font></td></tr><tr><td colspan="3"><font size="-2">$body</font></td></tr>);
    }
    $b .= '</table>';
    return $b;
}

=head2 checkFlood

checked wann die letzte aktion der ip adresse war und
erlaubt sie nur wenn midestens time zeit zur letzen aktion vergangen ist.

checkFlood(ip,optionaler abstand in sekunden )

        checkFlood(remote_addr());

=cut

sub checkFlood {
    my ( $self, @p ) = getSelf(@_);
    my $ip = $p[0];
    $min_secs = defined $p[1] ? $p[1] : $min_secs;
    my $return = 0;
    if( defined $ip ) {
        my $sql = qq(SELECT ti  FROM flood where remote_addr = ? );
        my $sth = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
        $sth->execute($ip);
        my $ltime = $sth->fetchrow_array();
        unless ( defined $ltime ) {
            $self->void( "insert into flood (remote_addr, ti) VALUES(?,?) ",
                $ip, time() );
            $return = 1;
        } else {
            $return = ( time()- $ltime > $min_secs ) ? 1 : 0;
            $self->void( "update flood set ti =?  where remote_addr = ?; ",
                time(), $ip );
        }
        $sth->finish();
    }
    return $return;
}

=head2 GetAutoIncrementValue()


       GetAutoIncrementValue(table)

=cut

sub GetAutoIncrementValue {
    my ( $self, @p ) = getSelf(@_);
    my $name = my @a = $self->fetch_AoH("SHOW TABLE STATUS");
    for( my $i = 0; $i <= $#a; $i++ ) {
        return $a[$i]->{Auto_increment} if( $a[$i]->{Name} eq $name );
    }
}

=head2 GetPrimaryKey()

       liefert die primary_key der tabelle zurück

       GetPrimaryKey(table)

=cut

sub GetPrimaryKey {
    my ( $self, @p ) = getSelf(@_);
    my $tbl = $p[0];
    if( defined $tbl ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my @caption = $self->fetch_AoH("show columns from $tbl");
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
    my ( $self, @p ) = getSelf(@_);
    my $tbl = $p[0];
    if( defined $tbl ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my @caption = $self->fetch_AoH("show columns from $tbl");
        for( my $j = 0; $j <= $#caption; $j++ ) {
            return $caption[$j]->{'Field'}
                if( $caption[$j]->{'Extra'} eq 'auto_increment' );
        }
    } else {
        return 0;
    }
}

#html erzeugende funktionen

=head2 GetDataBases()

Gibt eine auswahl liste der Datenabanken zurück

=cut

sub GetDataBases {
    my ( $self, @p ) = getSelf(@_);
    my $m_sCurrentDb = $self->CurrentDb();
    my @dbs          = $self->fetch_array("show Databases");
    my $return
        = qq|<select align="left" onchange="this.form.submit()" name="m_ChangeCurrentDb" style="width:75%" >|;
    $return .=
        $_ eq $m_sCurrentDb
        ? qq|<option  value="$_"  selected="selected" >$_(|
        . $self->TableCount4Db($_)
        . q|)</option>|
        : qq|<option  value="$_">$_(|
        . $self->TableCount4Db($_)
        . q|)</option>|
        foreach @dbs;
    $return .= '</select>';
    return $return;
}

=head2 TableCount4Db()


=cut

sub TableCount4Db {
    my ( $self, @p ) = getSelf(@_);
    my @count = $self->fetch_array("show tables from $p[0]");
    warn $@ if $@;
    return $#count;
}

=head2 GetCharacterSet()

        gibt das Charset zu coalation zurück.

        GetCharacterSet(coalation);

=cut

sub GetCharacterSet {
    my ( $self, @p ) = getSelf(@_);
    my $c = shift @p;
    if( defined $c ) {
        my $coalation = $self->fetch_hashref( "SHOW COLLATION like ?", $c );
        return $coalation->{Charset};
    } else {
        return 0;
    }
}

=head2 GetEngines()

        gibt die verfügbaren Engines zurück.

        GetEngines(tabelle);

=cut

sub GetEngines {
    my ( $self, @p ) = getSelf(@_);
    my $tbl  = shift @p;
    my $name = shift @p;
    if( defined $tbl ) {
        my @co = $self->fetch_AoH("SHOW ENGINES");
        my $status
            = $self->fetch_hashref( "SHOW TABLE STATUS where `Name` = ?  ",
            $tbl );
        my $return = qq|<select name="$name">|;
        $return .=
            $_->{Engine} eq $status->{Engine}
            ? qq|<option  value="$_->{Engine}"  selected="selected" >$_->{Engine}</option>|
            : qq|<option  value="$_->{Engine}">$_->{Engine}</option>|
            foreach @co;
        $return .= '</select>';
        return $return;
    } else {
        return 0;
    }
}

=head2 GetEngineForRow()


        GetEngineForRow(tabelle, zeile);

=cut

sub GetEngineForRow {
    my ( $self, @p ) = getSelf(@_);
    my $tbl  = shift @p;
    my $name = shift @p;
    if( defined $tbl && defined $name ) {
        my @co = $self->fetch_array("SHOW ENGINES");
        my @EINGINES
            = $self->fetch_AoH( "SHOW TABLE STATUS where `Name` = ?  ",
            $tbl );
        my $return = qq|<select name="$name">|;
        $return .=
            $_->{Engine} eq "@co"
            ? qq|<option  value="$_->{Engine}"  selected="selected" >$_->{Engine}</option>|
            : qq|<option  value="$_->{Engine}">$_->{Engine}</option>|
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
    my ( $self, @p ) = getSelf(@_);
    my $null = shift @p;
    my $name = shift @p;
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
    my ( $self, @p ) = getSelf(@_);
    my $selected = shift @p;
    my $name     = shift @p;
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
    my ( $self, @p ) = getSelf(@_);
    my $type = shift @p;
    my $name = shift @p;
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
    my ( $self, @p ) = getSelf(@_);
    my $tbl    = shift @p;
    my $column = shift @p;
    my $name   = shift @p;
    if( defined $tbl && defined $column && defined $name ) {
        $tbl = $m_dbh->quote_identifier($tbl);
        my $col = $self->fetch_hashref(
            "show full columns from $tbl where field = ?", $column );
        my @collation = $self->fetch_AoH("SHOW COLLATION");
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
    my ( $self, @p ) = getSelf(@_);
    my $name      = shift @p;
    my @collation = $self->fetch_AoH("SHOW COLLATION");
    my $collation = 0;
    if($name) {
        my @a = $self->fetch_AoH("SHOW TABLE STATUS");
        for( my $i = 0; $i <= $#a; $i++ ) {
            $collation = $a[$i]->{Collation} if( $a[$i]->{Name} eq $name );
        }
    }
    my $return
        = qq|<select name="$name" style="width:100px;"><option></option>|;
    $return
        .= qq|<option  value="$_->{Collation}"|
        . ( $collation eq $_->{Collation} ? 'selected="selected"' : '' )
        . qq|>$_->{Collation}</option>|
        foreach @collation;
    $return .= '</select>';
    return $return;
}

=head2 GetAttrs

       gibt eine auswahlliste (select) zurück.

       GetAttrs($tbl, $field, $m_hUniqueAttrs )

=cut

sub GetAttrs {
    my ( $self, @p ) = getSelf(@_);
    my $tbl    = shift @p;
    my $select = shift @p;
    my $name   = shift @p;
    if($tbl) {
        my $hr     = $self->fetch_hashref("SHOW CREATE TABLE $tbl");
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
    } else {
        return qq|
    <select name="$name" style="width:100px;">
    <option ></option>
    <option  value="UNSIGNED">UNSIGNED</option>
    <option  value="UNSIGNED ZEROFILL">UNSIGNED ZEROFILL</option>
    <option  value="ON UPDATE CURRENT_TIMESTAMP">ON UPDATE CURRENT_TIMESTAMP</option>
    </select>|;
    }
}

=head2 GetColumns

       gibt eine auswahlliste (select) zurück.

       GetColumns($tbl ,$name,selected)

=cut

sub GetColumns {
    my ( $self, @p ) = getSelf(@_);
    my $tbl      = shift @p;
    my $name     = shift @p;
    my $selected = $_[0] ? $_[0] : 0;
    my @col      = $self->fetch_AoH("show columns from $tbl");
    my $return   = qq|<select name="$name" style="width:100px;">|;
    $return
        .= qq|<option  value="$_->{Field}" |
        . ( $selected eq $_->{Field} ? 'selected="selected"' : '' )
        . qq|>$_->{Field}</option>|
        foreach @col;
    $return .= '</select>';
    return $return;
}

=head2 getSelf()

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'DBI::Library::Database' );
    return (
        defined( $_[0] )
            && ( ref( $_[0] ) eq 'DBI::Library::Database'
            || UNIVERSAL::isa( $_[0], 'DBI::Library::Database' ) )
    ) ? @_ : ( $DBI::Library::Database::DefaultClass->new, @_ );
}

package DBI::Library::Database::db;
use vars qw(@ISA);
@ISA = qw(DBI::Library:::db);

=head2 prepare()

=cut

sub prepare {
    my ( $m_dbh, @args ) = @_;
    my $sth = $m_dbh->SUPER::prepare(@args) or return;
    return $sth;
}

package DBI::Library::Database::st;
use vars qw(@ISA);
@ISA = qw(DBI::Library::st);

=head2 execute()

=cut

sub execute {
    my ( $sth, @args ) = @_;
    my $rv = $sth->SUPER::execute(@args) or return;
    return $rv;

}

=head2 fetch()

=cut

sub fetch {
    my ( $sth, @args ) = @_;

    my $row = $sth->SUPER::fetch(@args) or return;
    return $row;
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 LICENSE

Copyright (C) 2006-2008 by Hr. Dirk Lindner

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License
as published by the Free Software Foundation;
This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

=cut

1;
