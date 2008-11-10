package DBI::Library;
use strict;
use warnings;
use vars
    qw( $m_dbh $dsn $DefaultClass $m_hrSettings  @EXPORT_OK @ISA %functions $m_sStyle $m_nRight $tbl $driver $m_oDatabase $host $pass $m_sUser);
$DefaultClass = 'DBI::Library' unless defined $DBI::Library::DefaultClass;
@DBI::Library::EXPORT_OK
    = qw(CurrentPass CurrentUser CurrentHost CurrentDb Driver  useexecute quote void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute tableLength tableExists initDB $dsn $m_dbh selectTable);
%DBI::Library::EXPORT_TAGS = (
    'all' => [
        qw(CurrentPass CurrentUser CurrentHost CurrentDb Driver useexecute quote void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute tableLength tableExists initDB selectTable)
    ],
    'dynamic' => [
        qw(CurrentPass CurrentUser CurrentHost CurrentDb Driver useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute selectTable)
    ],
    'independent' => [
        qw(CurrentPass CurrentUser CurrentHost CurrentDb Driver tableLength tableExists initDB useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute selectTable)
    ],
);
$DBI::Library::VERSION = '0.39';
$tbl                   = 'querys';
$driver                = 'mysql';
require Exporter;
use DBI;

use base qw/Exporter DBI/;

# use Exporter qw/import/;

=head1 NAME

DBI::Library - DBI subclass providing a dynamic SQL Libary.

=head1 SYNOPSIS

FO Syntax

use DBI::Library qw(:all);

my $m_dbh = initDB({name => 'LZE',host => 'localhost',user => 'root',password =>'',style=> 'Crystal'});

OO Syntax

use DBI::Library;

        my ($m_oDatabase,$m_dbh) = new DBI::Library(

                {

                name =>'LZE',

                host => 'localhost',

                user => 'root',

                password =>'',

                style=> 'Crystal'

                }

        );

        my %execute  = (

                title => 'showTables',

                description => 'description',

                sql => "show tables",

                return => "fetch_array",

        );

        $m_oDatabase->addexecute(\%execute);

        $m_oDatabase->showTables();

=head2 Export Tags

:all
    execute useexecute quote void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute  addexecute tableLength tableExists initDB

:dynamic execute useexecute void fetch_hashref fetch_AoH fetch_array updateModules deleteexecute editexecute addexecute

independent: tableLength tableExists initDB :dynamic

=head1 DESCRIPTION

DBI::Library is a DBI subclass providing a dynamic SQL Libary.



=head2 new()

        my $m_oDatabase = new DBI::Library();


        my ($m_oDatabase,$m_dbh) = new DBI::Library(

                                        {

                                        name => $db,

                                        host => $host,

                                        user => $m_sUser,

                                        password => $password,

                                        }

        );

=cut

sub new {
    my ( $class, @initializer ) = @_;
    my $self = {};
    my $m_dbh;
    bless $self, ref $class || $class || $DefaultClass;
    $m_dbh = $self->initDB(@initializer) if(@initializer);
    return ( $self, $m_dbh ) if $m_dbh;
    return $self;
}

=head2 initDB()

        my $m_dbh = initDB(

                {

                name => 'LZE',

                host => 'localhost',

                user => 'root',

                password =>'',

                }
        );

=cut

sub initDB {
    my ( $self, @p ) = getSelf(@_);
    my $hash = $p[0];
    $m_oDatabase
        = defined $hash->{name}
        ? $hash->{name}
        : 'LZE';    #todo durch make setzen
    $host    = defined $hash->{host}     ? $hash->{host}     : 'localhost';
    $m_sUser = defined $hash->{user}     ? $hash->{user}     : 'root';
    $pass    = defined $hash->{password} ? $hash->{password} : '';
    my $install = defined $hash->{install} ? $hash->{install} : 0;
    $m_sStyle = defined $hash->{style} ? $hash->{style} : 'Crystal';
    $dsn      = "DBI:$driver:database=$m_oDatabase;host=$host";
    $m_dbh    = DBI::Library->connect(
        $dsn, $m_sUser, $pass,
        {   RaiseError => 1,
            PrintError => 0,
            AutoCommit => 1,
        }
    ) or print "$DBI::Library::errs";

    if( !$install && $m_oDatabase eq 'LZE' ) {
        my @q = $self->fetch_array("select title from querys");
        $functions{$_} = $_ foreach (@q);
    }
    return $m_dbh;
}

=head2 Driver()

set or get the driver

       Driver()

default: Mysql

=cut

sub Driver {
    if( $_[0] ) {
        $driver = $_[0];
    } else {
        return $driver;
    }
}

=head2 CurrentDb()

gibt die aktuelle datenbank zurück

=cut

sub CurrentDb {
    return $m_oDatabase;
}

=head2 CurrentHost()

gibt den aktuellen host zurück

=cut

sub CurrentHost {
    return $host;
}

=head2 CurrentUser()

gibt den aktuellen user zurück

=cut

sub CurrentUser {
    return $host;
}

=head2 CurrentPass()

gibt das aktuelle passwort zurück

=cut

sub CurrentPass {
    return $pass;
}

=head1 independent functions

=head2  tableExists()

$bool =  $m_oDatabase->tableExists($table);

=cut

sub tableExists {
    my ( $self, @p ) = getSelf(@_);
    my $table     = $m_dbh->quote( $p[0] );
    my $db_clause = "";
    ( $db_clause, $table ) = ( " FROM $1", $2 ) if $table =~ /(.*)\.(.*)/;
    return ( $m_dbh->selectrow_array("SHOW TABLES $db_clause LIKE $table") );
}

=head2 tableLength

$length  = $m_oDatabase->tableLength($table);

=cut

sub tableLength {
    my ( $self, @p ) = getSelf(@_);
    my $table = $m_dbh->quote_identifier( $p[0] );
    my $sql   = "select count(*) from $table";
    if( $self->tableExists( $p[0] ) ) {
        my $sth = $m_dbh->prepare($sql) or warn $m_dbh->errstr;
        $sth->execute() or warn $m_dbh->errstr;
        my $length = $sth->fetchrow_array;
        $sth->finish();
        return $length;
    } else {
        return 0;
    }
}

=head1 dynamic statements

=head2  addexecute()

add sql statments to yourdatabase for later use witdh useexecute();

        my %execute  = (

                title => 'showTables',

                description => 'description',

                sql => "show tables",

                return => "fetch_array",

        );

        $m_oDatabase->addexecute(\%execute);

        print join '<br/>' ,$m_oDatabase->showTables();

Fo Syntax:

        print join '<br/>' , useexecute('showTables');

=cut

sub addexecute {
    my ( $self, @p ) = getSelf(@_);
    my $hash        = $p[0];
    my $m_sTitle    = ( ( defined $hash->{title} ) ) ? $hash->{title} : 0;
    my $sql         = $hash->{sql} if( ( defined $hash->{sql} ) );
    my $description = $hash->{description} if( defined $hash->{description} );
    my $return      = $hash->{'return'} if( defined $hash->{'return'} );
    unless ( $functions{$m_sTitle} ) {
        my $sql_addexecute
            = qq/INSERT INTO querys(`title`,`sql`,`description`,`return`) VALUES(?,?,?,?);/;
        my $sth = $m_dbh->prepare($sql_addexecute);
        $sth->execute( $m_sTitle, $sql, $description, $return )
            or warn $m_dbh->errstr;
        $sth->finish();
        $self->updateModules();
    } else {
        return 0;
    }
}

=head2 editexecute

        my %hash = (

                title => 'Titel',

                newTitle => 'New Titel',

                description => 'querys Abfragen',

                sql => "sql statement",

                return => 'fetch_hashref', #subname

        );

        editexecute(\%hash);

=cut

sub editexecute {
    my ( $self, @p ) = getSelf(@_);
    my $hash = $p[0];
    my $m_sTitle = ( ( defined $hash->{title} ) ) ? $hash->{title} : 0;
    my $newTitle
        = ( ( defined $hash->{newTitle} ) ) ? $hash->{newTitle} : $m_sTitle;
    my $sql = $hash->{sql} if( ( defined $hash->{sql} ) );
    my $description = $hash->{description} if( defined $hash->{description} );
    my $return = ( defined $hash->{'return'} ) ? $hash->{'return'} : 'array';

    if( $functions{$m_sTitle} ) {
        my $sql_edit
            = qq(update querys set title = ?, sql=? ,description=?,return=? where title = ? );
        my $sth = $m_dbh->prepare($sql_edit);
        $sth->execute( $newTitle, $sql, $description, $return, $m_sTitle )
            or warn $m_dbh->errstr;
        $sth->finish();

    } else {
        return 0;
    }
}

=head2 useexecute()

        useexecute($m_sTitle,optional hashref {identifier => {1 => 'news', 2 => 'querys'}  , @parameter);

example:

        my %execute = (

                title => 'joins',

                description => 'description',

                sql => 'select * from table_1 JOIN  table_2 ',

                return => "fetch_hashref"

        );

        $m_oDatabase->addexecute(\%execute5);

        my $ref = $m_oDatabase->joins({identifier => {1 => 'news', 2 => 'querys'}});

=cut

sub useexecute {
    my ( $self, @p ) = getSelf(@_);
    my $m_sTitle = shift(@p);
    my $sql      = "select `sql`,`return` from querys where `title` = ?";
    my $sth      = $m_dbh->prepare($sql);
    $sth->execute($m_sTitle) or warn $m_dbh->errstr;
    my ( $sqlexec, $return ) = $sth->fetchrow_array();
    $sqlexec =~ s/<TABLE>/$tbl/g;
    if( ref $p[0] eq 'HASH' ) {
        my $ref = shift(@p);
        foreach my $key ( keys %{ $ref->{identifier} } ) {
            $sqlexec
                =~ s/table_$key/$m_dbh->quote_identifier($ref->{identifier}{$key})/ge;
        }
    }
    $sth->finish();
    return eval(" \$self->$return(\$sqlexec,\@p)");
}

=head2 deleteexecute()

        deleteexecute($m_sTitle);

=cut

sub deleteexecute {
    my ( $self, @p ) = getSelf(@_);
    my $id         = $p[0];
    my $sql_delete = "DELETE FROM querys Where title  = ?";
    my $sth        = $m_dbh->prepare($sql_delete);
    $sth->execute($id) or warn $m_dbh->errstr;
    $sth->finish();
}

=head2 fetch_array()

        @A = $m_oDatabase->fetch_array($sql);

=cut

sub fetch_array {
    my ( $self, @p ) = getSelf(@_);
    my $sql = shift @p;
    my @r;
    eval( '
my $sth = $m_dbh->prepare($sql);
if(defined $p[0]) {
$sth->execute(@p) or warn $m_dbh->errstr;
}else {
$sth->execute() or warn $m_dbh->errstr;
}
while(my @comms = $sth->fetchrow_array()) {
push(@r, @comms);
}
$sth->finish();' );
    @r = $@ if $@;
    return @r;
}

=head2 fetch_AoH()

@aoh = $m_oDatabase->fetch_AoH($sql)

=cut

sub fetch_AoH {
    my ( $self, @p ) = getSelf(@_);
    my $sql = shift @p;
    my @r;
    eval( '
my $sth = $m_dbh->prepare($sql);
if(defined $p[0]) {
$sth->execute(@p) or warn $m_dbh->errstr;
} else {
$sth->execute() or warn $m_dbh->errstr;
}
while(my $h = $sth->fetchrow_hashref) {
push(@r, $h);
}
$sth->finish();' );
    @r = $@ if $@;
    return @r;
}

=head2 fetch_hashref()

$hashref = $m_oDatabase->fetch_hashref($sql)

=cut

sub fetch_hashref {
    my ( $self, @p ) = getSelf(@_);
    my $sql = shift @p;
    my $h;
    eval( '
my $sth = $m_dbh->prepare($sql);
if(defined $p[0]) {
$sth->execute(@p) or warn $m_dbh->errstr;
} else {
$sth->execute() or warn $m_dbh->errstr;
}
my @r;
$h = $sth->fetchrow_hashref();
$sth->finish();
' );
    $h = "$@" if $@;
    return $h;
}

=head2 void()

void(sql)

=cut

sub void {
    my ( $self, @p ) = getSelf(@_);
    my $sql = shift @p;
    my $sth = $m_dbh->prepare($sql);
    eval( '
if(defined $p[0]) {
$sth->execute(@p) or warn $m_dbh->errstr;
} else {
$sth->execute() or warn $m_dbh->errstr;
}' );
    $sth->finish();
    return "$@" if $@;
}

=head2 quote()

        $quotedString = $m_oDatabase->quote($sql);

=cut

sub quote {
    my ( $self, @p ) = getSelf(@_);
    my $sql = $p[0];
    return $m_dbh->quote($sql);
}

=head2 selectTable

set a placeholder wihich is usesd by dynmaic statements.

<TABLE> will be replaced width this value.

default : querys;

=cut

sub selectTable {
    my ( $self, @p ) = getSelf(@_);
    $tbl = $m_dbh->quote_identifier( $p[0] );
}

=head1 Privat

=head2 updateModules()

=cut

sub updateModules {
    my ( $self, @p ) = getSelf(@_);
    my @q = $self->fetch_array("select title from querys");
    $functions{$_} = $_ foreach (@q);
}

=head2 getSelf()

=cut

sub getSelf {
    return @_
        if defined( $_[0] )
            && ( !ref( $_[0] ) )
            && ( $_[0] eq 'DBI::Library' );
    return (
        defined( $_[0] )
            && ( ref( $_[0] ) eq 'DBI::Library'
            || UNIVERSAL::isa( $_[0], 'DBI::Library' ) )
    ) ? @_ : ( $DBI::Library::DefaultClass->new, @_ );
}

=head2 AUTOLOAD()

statements add by addexecute can called like

$m_oDatabase->showTables()

=cut

sub AUTOLOAD {
    my ( $self, @p ) = getSelf(@_);
    our $AUTOLOAD;
    if( $AUTOLOAD =~ /.*::(\w+)$/ and grep $1 eq $_, %functions ) {
        my $attr = $1;
        {
            no strict 'refs';
            *{$AUTOLOAD} = sub {
                $self->useexecute( $attr, @p );
            };
        }
        goto &{$AUTOLOAD};
    }
}

package DBI::Library::db;
use vars qw(@ISA);
@ISA = qw(DBI::db);

=head2 prepare()


=cut

sub prepare {
    my ( $m_dbh, @args ) = @_;
    my $sth = $m_dbh->SUPER::prepare(@args) or return;
    return $sth;
}

package DBI::Library::st;
use vars qw(@ISA);
@ISA = qw(DBI::st);

=head2 execute()


=cut

sub execute {
    my ( $sth, @args ) = @_;
    my $rv;
    eval('$rv = $sth->SUPER::execute(@args)');
    return "$@" if $@;
    return $rv;
}

=head2 fetch()


=cut

sub fetch {
    my ( $sth, @args ) = @_;
    my $rv;
    eval('$rv = $sth->SUPER::fetch(@args)');
    return "$@" if $@;
    return $rv;
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
