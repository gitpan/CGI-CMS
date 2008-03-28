package DBI::Library::Database;
use strict;
use warnings;
use HTML::Entities;

use vars qw( $dbh $dsn $DefaultClass @EXPORT_OK @ISA %functions  $mod_rewrite
  $serverName $min_secs);
$DefaultClass = 'DBI::Library::Database' unless defined $DBI::Library::Database::DefaultClass;
require Exporter;
use DBI::Library qw(:all $dbh $dsn);
@DBI::Library::Database::ISA    = qw(DBI::Library Exporter);
@DBI::Library::Database::EXPORT = qw(useexecute);
@DBI::Library::Database::EXPORT_OK =
  qw(execute useexecute quote void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute tableLength tableExists searchDB addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage initDB rewrite  checkFlood);
%DBI::Library::Database::EXPORT_TAGS = (
        'all' => [
                qw( searchDB addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage initDB tableLength tableExists  useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute rewrite checkFlood)
        ],
        'dynamic'     => [qw( useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute)],
        'independent' => [qw(tableLength tableExists initDB useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute)],
        'lze'         => [qw(addUser hasAcount isMember createMenu catright topicright right getAction checkPass checkSession setSid getName rss readMenu deleteMessage reply editMessage addMessage rewrite checkFlood)],
);
$DBI::Library::Database::VERSION = '0.31';
$mod_rewrite                     = 0;

=head1 NAME

DBI::Library::Database - Database interface for CGI::CMS::GUI

=head1 SYNOPSIS

use DBI::Library::Database;

=cut

sub new {
        my ($class, @initializer) = @_;
        my $self = {};
        bless $self, ref $class || $class || $DefaultClass;
        $dbh = $self->SUPER::initDB(@initializer) if(@initializer);

        #         return ($self, $dbh) if $dbh;
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

          user => $user,

          attach => $filename,

          ip => remote_addr(),


     );

     addMessage(\%message);
=cut

sub addMessage {
        my ($self, @p) = getSelf(@_);
        if($self->checkFlood($p[0]->{ip})) {

                my $thread = defined $p[0]->{thread} ? $p[0]->{thread} : 'trash';
                $thread = ($thread =~ /^(\w{3,50})$/) ? $1 : 'trash';
                my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
                $headline = ($headline =~ /^(.{3,100})$/) ? $1 : 'Invalid headline';
                my $user = defined $p[0]->{user} ? $p[0]->{user} : 'guest';
                my $body = defined $p[0]->{body} ? $p[0]->{body} : 'Body';
                my $cat  = defined $p[0]->{cat}  ? $p[0]->{cat}  : '/news';
                $cat = ($cat =~ /^(.{3,50})$/) ? $1 : '/news';
                my $rght   = $self->catright($cat);
                my $attach = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
                my $format = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
                my $action = defined $p[0]->{action} ? $p[0]->{action} : 'news';
                my $sql    = "insert into $thread (`title`,`body`,`attach`,`cat`,`right`,`user`,`action`,`format`) values(?,?,?,?,?,?,?,?)";
                my $sth    = $dbh->prepare($sql);
                $sth->execute($headline, $body, $attach, $cat, $rght, $user, $action, $format) or warn $dbh->errstr;
                $sth->finish();
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

          user => $user,

          attach => $filename,

          ip => remote_addr(),

     );

     editMessage(\%message);

=cut

sub editMessage {
        my ($self, @p) = getSelf(@_);
        if($self->checkFlood($p[0]->{ip})) {
                my $thread = defined $p[0]->{thread} ? $p[0]->{thread} : 'trash';
                $thread = ($thread =~ /^(\w{3,50})$/) ? $1 : 'trash';
                my $refid    = defined $p[0]->{id}    ? $p[0]->{id}    : 1;
                my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
                $headline = ($headline =~ /^(.{3,100})$/) ? $1 : 'Invalid headline';
                my $user   = defined $p[0]->{user}   ? $p[0]->{user}   : 'guest';
                my $body   = defined $p[0]->{body}   ? $p[0]->{body}   : 'Body';
                my $attach = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
                my $format = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
                my $cat    = defined $p[0]->{cat}    ? $p[0]->{cat}    : 'news';

                if($attach ne '0.0') {
                        my $sql_insert = qq/update $thread set title =?, body =? , attach= ?,format =?,user =?,cat =?,`right` =? where id = ?;/;
                        my $sth        = $dbh->prepare($sql_insert);
                        $sth->execute($headline, $body, $attach, $format, $user, $cat, $self->catright($cat), $refid) or warn $dbh->errstr;
                        $sth->finish();
                } else {
                        my $sql_insert = qq/update $thread set title =?, body = ? ,format = ?,user = ?,cat = ?,`right` =?  where id = ?;/;
                        my $sth        = $dbh->prepare($sql_insert);
                        $sth->execute($headline, $body, $format, $user, $cat, $self->catright($cat), $refid) or warn $dbh->errstr;
                        $sth->finish();
                }
        }
}

=head2 reply

     my %reply =(

          title => $headline,

          body => $body,

          id => $reply,

          user => $user,

          attach =>  $sra,

          format => $html,

          ip => remote_addr(),

     );

     reply(\%reply);

=cut

sub reply {
        my ($self, @p) = getSelf(@_);
        if($self->checkFlood($p[0]->{ip})) {
                my $headline = defined $p[0]->{title} ? $p[0]->{title} : 'headline';
                $headline = ($headline =~ /^(.{3,100})$/) ? $1 : 'Invalid headline';
                my $user   = defined $p[0]->{user}   ? $p[0]->{user}   : 'guest';
                my $body   = defined $p[0]->{body}   ? $p[0]->{body}   : 'Body';
                my $attach = defined $p[0]->{attach} ? $p[0]->{attach} : 0;
                my $format = defined $p[0]->{format} ? $p[0]->{format} : 'bbcode';
                my $refid  = defined $p[0]->{id}     ? $p[0]->{id}     : 1;
                my $sql = "insert into replies (`title`,`body`,`attach`,`right`,`user`,`refererId`,`format`) values(?,?,?,?,?,?,?)";
                my $sth = $dbh->prepare($sql);
                $sth->execute($headline, $body, $attach, $self->topicright($refid), $user, $refid, $format) or warn $dbh->errstr;
                $sth->finish();

        }
}

=head2 deleteMessage

      $bool = $database->deleteMessage($table,$id);

=cut

sub deleteMessage {
        my ($self, @p) = getSelf(@_);
        my $table      = $p[0];
        my $id         = $p[1];
        my $sql_backup = "select * from $table  Where id  = '$id'";
        my $sth_backup = $dbh->prepare($sql_backup);
        $sth_backup->execute();
        my $backup    = $sth_backup->fetchrow_hashref();
        my $c         = ($table eq 'replies') ? 'replies' : $self->quote($backup->{cat});
        my $sql_trash = "insert into `trash`  (`table`,`oldId`,`title`,`body`,`date`,`user`,`right`,`attach`,`cat`,`sticky`) values(?,?,?,?,?,?,?,?,?,?)";
        my $sth_trash = $dbh->prepare($sql_trash);
        $sth_trash->execute($table, $id, $backup->{title}, $backup->{body}, $backup->{date}, $backup->{user}, $backup->{right}, $backup->{attach}, $c, $backup->{sticky});
        my $sql_delete = "DELETE FROM $table Where id  = '$id'";
        my $sth        = $dbh->prepare($sql_delete);
        $sth->execute() or warn $dbh->errstr;
        $sth->finish();
}

=head2 readMenu()

      @menu = $database->readMenu($thread,$right,$von,$bis,$rewrite);

=cut

sub readMenu {
        my ($self, @p) = getSelf(@_);
        my $thread  = $p[0];
        my $right   = $p[1];
        my $von     = $p[2];
        my $bis     = $p[3];
        my $rewrite = $p[4];
        $von = 0  unless (defined $von);
        $bis = 10 unless (defined $bis);
        my $limit = $bis- $von;
        $rewrite = 0 unless (defined $rewrite);

        my $sql_read = qq/select title,id from  $thread where `right` <= $right order by date desc  LIMIT $von , $limit/;
        my $sth      = $dbh->prepare($sql_read);
        $sth->execute();
        my @output;
        while(my @data = $sth->fetchrow_array()) {
                my $headline = $data[0];
                my $id       = $data[1];
                $headline =~ s/(.{20}).+/$1/;
                my $nl = ($rewrite) ? "/$von/$bis/$thread.html#$id" : "$ENV{SCRIPT_NAME}?action=$thread&amp;von=$von&amp;bis=$bis#$id";
                push @output, {text => $headline, href => $nl,};
        }
        $sth->finish();
        return @output;
}

=head2 rss()

      $rss = $database->rss($thread,int start);

=cut

sub rss {
        my ($self, @p) = getSelf(@_);
        my $thread = $p[0];
        $thread = 'news' unless (defined $thread);
        my $start = $p[1];
        $start = 0 unless (defined $start);
        my $time     = localtime;
        my $sql_read = qq/select *from  $thread  where `right` = '0' order by id desc  LIMIT $start , 10/;
        my $sth      = $dbh->prepare($sql_read);
        $sth->execute();
        my @output;
        push @output,
          qq(Content-Type: text/rss\n\n<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns="http://my.netscape.com/rdf/simple/0.9/"><channel><title>$thread</title>\n<description>Die Topics als rss.</description>\n<link>$serverName</link>\n<language>de</language>\n<pubDate>$time</pubDate>\n</channel>\n);

        while(my @data = $sth->fetchrow_array()) {
                my $headline = $data[0];
                my $href     = $data[9];
                my $link     = $mod_rewrite ? "$serverName/$thread.html#$href" : "$serverName?action=$thread;#$href";
                push @output, "\n<item>\n<title>$headline</title>\n<link>$link</link>\n</item>\n";
        }
        push @output, "\n</rdf:RDF>";
        $sth->finish();
        return @output;
}

=head2 getName()

      $name = $database->getName($sid);

=cut

sub getName {
        my ($self, @p) = getSelf(@_);
        my $sid = $p[0];
        if(defined $sid) {
                my $sql = "SELECT user FROM `users` where sid = ?;";
                my $sth = $dbh->prepare($sql) or warn $dbh->errstr;
                $sth->execute($sid) or warn $dbh->errstr;
                my $name = $sth->fetchrow_array();
                $sth->finish();
                return $name;
        }
}

=head2 setSid

$sidid = $database->setSid(name,pass);

=cut

sub setSid {
        my ($self, @p) = getSelf(@_);
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
        my $sth         = $dbh->prepare($sql);
        $sth->execute($fingerprint, $ip, $name);
        $sth->finish();
        return $fingerprint;
}

=head2 checkSession

      $bool = $database->checkSession($user,$sid);

=cut

sub checkSession {
        my ($self, @p) = getSelf(@_);
        my $user   = shift;
        my $ssid   = shift;
        my $ip     = shift;
        my $return = 0;

        if(length($user) > 3 && length($ssid) > 3) {
                my $sql = "select sid from  users where ( DAYOFMONTH(now()) =  DAYOFMONTH(date) ) && user = ?";
                my $sth = $dbh->prepare($sql);
                $sth->execute($user) or warn $dbh->errstr;
                my $session = $sth->fetchrow_array();
                $sth->finish();
                $return = 1 if(defined $session && defined $ssid && $ssid eq $session);
        }
        return $return;
}

=head2 checkPass()

=cut

sub checkPass {
        my ($self, @p) = getSelf(@_);
        my $u  = $p[0];
        my $cp = $p[1];
        use MD5;
        if(defined $u) {
                my $sql = qq(SELECT pass  FROM users where user = ?);
                my $sth = $dbh->prepare($sql) or warn $dbh->errstr;
                $sth->execute($u);
                my $cpass = $sth->fetchrow_array();
                $sth->finish();
                $cpass = defined $cpass ? $cpass : 0;
                return ($cp eq $cpass) ? 1 : 0;
        }
        return 0;
}

=head2 getAction

      $hashref = $database->getAction($action);

=cut

sub getAction {
        my ($self, @p) = getSelf(@_);
        my $action = $p[0];
        my $sql    = qq/select * from actions where action = ?/;
        my $sth    = $dbh->prepare($sql) or warn $dbh->errstr;
        $sth->execute($action);
        my $hr = $sth->fetchrow_hashref;
        $sth->finish();
        return $hr;
}

=head2 right()

      $right = right($action,$username);

=cut

sub right {
        my ($self, @p) = getSelf(@_);
        my $user = $p[0];
        return userright($user);
}

=head2 userright()

      userright(user);

=cut

sub userright {
        my ($self, @p) = getSelf(@_);
        my $user = $p[0];
        my $sql  = "SELECT `right`,`user` FROM users where `user` = ? HAVING `user` = ?";
        my $sth  = $dbh->prepare($sql);
        $sth->execute($user, $user);
        my @q = $sth->fetchrow_array;
        $sth->finish();
        return $q[0];
}

=head2 topicright()

      topicright(id);

=cut

sub topicright {
        my ($self, @p) = getSelf(@_);
        my $id  = $p[0];
        my $sql = "SELECT `right` FROM news where id = ?";
        my $sth = $dbh->prepare($sql);
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
        my ($self, @p) = getSelf(@_);
        my $cat = $p[0];
        $cat =~ s?/??g;
        my @cats = $self->fetch_AoH("SELECT * FROM cats");
        for(my $i = 0 ; $i <= $#cats ; $i++) {
                return $cats[$i]->{right} if($cats[$i]->{name} eq $cat);
        }
        return 0;
}

=head2 createMenu()

      createMenu(name);

=cut

sub createMenu {
        my ($self, @p) = getSelf(@_);
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
        $self->void($sql_createTable, $thread);
}

=head2 isMember

      isMember($user);

checkt ob es den user bereits gibt.


=cut

sub isMember {
        my ($self, @p) = getSelf(@_);
        my $user = lc $p[0];
        if(defined $user) {
                my $sth = $dbh->prepare("SELECT user  FROM users where user = ?") or warn $dbh->errstr;
                $sth->execute($user);
                my ($member) = $sth->fetchrow_array();
                $sth->finish();
                return defined $member ? ($user eq $member) ? 1 : 0 : 0;
        } else {
                return 1;
        }
}

=head2 hasAcount

      hasAcount($email)

checkt ob es die  email Adresse bereits gibt. 

=cut

sub hasAcount {
        my ($self, @p) = getSelf(@_);
        my $mail = lc $p[0];
        if(defined $mail) {
                my $sth = $dbh->prepare("SELECT email  FROM users where email = ?") or warn $dbh->errstr;
                $sth->execute($mail);
                my ($email) = $sth->fetchrow_array();
                $sth->finish();
                return ($mail eq $email) ? 1 : 0;
        } else {
                return 1;
        }
}

=head2 addUser

      $database->addUser(user, pass);

=cut

sub addUser {
        my ($self, @p) = getSelf(@_);
        my $newuser = $p[0];
        my $newpass = $p[1];
        use MD5;
        my $md5 = new MD5;
        $md5->add($newuser);
        $md5->add($newpass);
        my $fingerprint = $md5->hexdigest();
        my $mail        = $p[2];
        my $sql_addUser = qq/insert into users (user,pass,email,`right`) values(?,?,?,1)/;
        my $sth         = $dbh->prepare($sql_addUser);
        my $anzahl      = $sth->execute($newuser, $fingerprint, $mail) or warn $dbh->errstr;
        $sth->finish();
        return 1 if($anzahl+ 0== 1);
}

=head2 rewrite()

enable or disable rewrite.

=cut

sub rewrite {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0]) {
                if($p[0] =~ /(0|1)/) {
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
        my ($self, @p) = getSelf(@_);
        if(defined $p[0]) {
                $serverName = $p[0];
        } else {
                return $serverName;
        }

}

=head2 floodtime()

set floodtime.

=cut

sub floodtime {
        my ($self, @p) = getSelf(@_);
        if(defined $p[0]) {
                $min_secs = $p[0];
        } else {
                return $min_secs;
        }

}

=head2 searchDB()

       searchDB($query,$spalte,$table);

regexp suche  in tabelle ...

=cut

sub searchDB {
        my ($self, @p) = getSelf(@_);
        my $query      = $p[0];
        my $spalte     = $p[1];
        my $table      = $p[2];
        my $sql_select = "SELECT * FROM " . $table;
        $sql_select .= " WHERE $spalte REGEXP '($query)'";
        my $b        = '<table align="center" summary="layoutSearch" border="0" cellpadding="0" cellspacing="0" width="100%">';
        my @messages = $self->fetch_AoH($sql_select);
        for(my $i = 0 ; $i <= $#messages ; $i++) {
                my $link = ($mod_rewrite) ? "/showMessage$messages[$i]->{id}.html" : "$ENV{SCRIPT_NAME}?action=showMessage&amp;reply=$messages[$i]->{id}";
                $b .= qq(<tr><td><a href="$link">$messages[$i]->{title}</a></td><td align="right"><font size="-1">$messages[$i]->{datum}</font></td></tr>);
        }
        $b .= '</table>';
        return $b;
}

=head2 fulltext()

      @messages = fulltext(query,table);

fulltextsuche in tabelle ...

=cut

sub fulltext {
        my ($self, @p) = getSelf(@_);
        my $query    = $p[0];
        my $table    = $p[1];
        my $right    = $p[2];
        my $von      = $p[3] ? $p[3] : 0;
        my $bis      = $p[4] ? $p[4] : 100;
        my $limit    = $bis- $von;
        my $b        = '<table align="center" summary="fulltext" border="0" cellpadding="2" cellspacing="2" width="*"><tr><td>Title</td><td>User</td><td>Datum</td></tr>';
        my @messages = $self->fetch_AoH("SELECT * FROM $table  where `right` <= $right and MATCH (title,body) AGAINST('$query') order by date desc  LIMIT $von , $limit");
        for(my $i = 0 ; $i <= $#messages ; $i++) {
                my $body = $messages[$i]->{body};
                $body =~ s/\[code\](.*?)\[\/code\]//gs;
                $body =~ s/\[([^\]])+\]//g;
                my $j = index $body, $query;
                $j = $j > 50 ? $j- 50 : 0;
                $body = substr($body, $j, 150);
                $body =~ s?$query?<b>$query</b>?g;
                $body = encode_entities($body);
                $messages[$i]->{title} = encode_entities($messages[$i]->{title});
                my $link = ($mod_rewrite) ? "/showMessage$messages[$i]->{id}.html" : "$ENV{SCRIPT_NAME}?action=showMessage&amp;reply=$messages[$i]->{id}";
                $b .=
                  qq(<tr><td style="color:blue;"><a href="$link" class="menuLink">$messages[$i]->{title}</a></td><td>$messages[$i]->{user}</td><td align="right"><font size="-1">$messages[$i]->{date}</font></td></tr><tr><td colspan="3"><font size="-2">$body</font></td></tr>);
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
        my ($self, @p) = getSelf(@_);
        my $ip = $p[0];
        $min_secs = defined $p[1] ? $p[1] : $min_secs;
        my $return = 0;
        if(defined $ip) {
                my $sql = qq(SELECT ti  FROM flood where remote_addr = ?);
                my $sth = $dbh->prepare($sql) or warn $dbh->errstr;
                $sth->execute($ip);
                my $ltime = $sth->fetchrow_array();
                unless (defined $ltime) {
                        $self->void("insert into flood (remote_addr, ti) VALUES(?,?) ", $ip, time());
                        $return = 1;
                        $ltime  = time();
                }
                $sth->finish();
                $return = (time()- $ltime > $min_secs) ? 1 : 0;
        }
        $self->void("update flood set ti =?  where remote_addr = ?; ", time(), $ip);

        return $return;
}

=head2 getSelf()

=cut

sub getSelf {
        return @_ if defined($_[0]) && (!ref($_[0])) && ($_[0] eq 'DBI::Library::Database');
        return (defined($_[0]) && (ref($_[0]) eq 'DBI::Library::Database' || UNIVERSAL::isa($_[0], 'DBI::Library::Database'))) ? @_ : ($DBI::Library::Database::DefaultClass->new, @_);
}

package DBI::Library::Database::db;
use vars qw(@ISA);
@ISA = qw(DBI::Library:::db);

sub prepare {
        my ($dbh, @args) = @_;
        my $sth = $dbh->SUPER::prepare(@args) or return;
        return $sth;
}

package DBI::Library::Database::st;
use vars qw(@ISA);
@ISA = qw(DBI::Library::st);

sub execute {
        my ($sth, @args) = @_;
        my $rv = $sth->SUPER::execute(@args) or return;
        return $rv;

}

sub fetch {
        my ($sth, @args) = @_;

        my $row = $sth->SUPER::fetch(@args) or return;
        return $row;
}

=head1 AUTHOR

Dirk Lindner <lze@cpan.org>

=head1 COPYRIGHT AND LICENSE

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
