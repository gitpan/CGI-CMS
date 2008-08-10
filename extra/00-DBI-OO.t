# use strict;
# use warnings;
# use lib qw(lib);
use DBI::Library;
use vars qw($db $user $host $password);
do('t/config.pl');
my ($database, $dbh) = new DBI::Library(
    {
        name     => $db,
        host     => $host,
        user     => $user,
        password => $password,
    }
);
use Test::More tests => 2;
my %execute2 = (
    title       => 'truncateQuerys',
    description => 'description',
    sql         => "truncate querys",
    return      => "void",
);
my %execute3 = (
    title       => 'showTables',
    description => 'description',
    sql         => "show tables",
    return      => "fetch_array",
);
$database->addexecute(\%execute2);
$database->addexecute(\%execute3);
my %execute4 = (
    title       => 'select',
    description => 'description',
    sql         => "select *from querys where `title` = ?",
    return      => "fetch_hashref"
);
$database->addexecute(\%execute4);
my $showTables = $database->select('showTables');
ok($showTables->{sql} eq 'show tables');
$database->truncateQuerys();
ok($database->tableLength('querys')== 0);
