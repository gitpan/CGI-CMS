# use strict;
# use warnings;
use lib qw(lib);
use vars qw($db $user $host $password);
do('t/config.pl');
use DBI::Library;
my $database = new DBI::Library();

my %hash = (
    name     => $db,
    host     => $host,
    user     => $user,
    password => $password,
);
my $dbh     = $database->initDB(\%hash);
my %execute = (
    title       => 'showTables',
    description => 'description',
    sql         => "show tables",
    return      => "fetch_array",
);
my %execute2 = (
    title       => 'truncateQuerys',
    description => 'description',
    sql         => "truncate querys",
    return      => "void",
);
my %execute3 = (
    title       => 'querys',
    description => 'description',
    sql         => "select * from querys ",
    return      => "fetch_array",
);
$database->addexecute(\%execute);
$database->addexecute(\%execute2);
$database->addexecute(\%execute3);
my @a1    = $database->useexecute("showTables");
my @a2    = $database->showTables();
my @a3    = $database->fetch_array('show tables');
my $hash  = $database->fetch_hashref('select *from querys where `title` = ? && `description` = ?', 'showTables', 'description');
my $hash2 = $database->fetch_hashref("select *from querys where `title` = 'showTables'");
my @aoh   = $database->fetch_AoH('select *from querys where `return` = ? && `description` = ?', 'fetch_array', 'description');
my @aoa   = $database->fetch_array('select *from querys;');

my $sth = $dbh->prepare("select *from querys where `title` = 'showTables'");
$sth->execute() or warn $dbh->errstr;
my $ref = $sth->fetchrow_hashref;
$sth->finish();
use Test::More tests => 9;
ok($#a1 > 0);
ok($#a1         eq $#a2);
ok($#a2         eq $#a3);
ok($hash->{sql} eq $hash2->{sql});
ok($#aoh > 0);
$sth->finish();
$sth = $dbh->prepare("select *from querys");
$sth->execute();
ok(!$@);
$sth->finish();
my %execute4 = (
    title       => 'select',
    description => 'description',
    sql         => 'select * from <TABLE> where `title` = ?',
    return      => "fetch_hashref"
);
$database->addexecute(\%execute4);
$database->selectTable('querys');
my $showTables = $database->select('showTables');
ok($showTables->{sql} eq 'show tables');
my %execute5 = (
    title       => 'joins',
    description => 'description',
    sql         => 'select * from table_1 JOIN  table_2 ',
    return      => "fetch_hashref"
);
$database->addexecute(\%execute5);
my $ref2 = $database->joins(
    {
        identifier => {
            1 => 'news',
            2 => 'querys'
        }
    }
);
ok(ref $ref2 eq 'HASH');
$database->truncateQuerys();
ok($database->tableLength('querys')== 0);
