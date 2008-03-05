#!/usr/bin/perl -w
use strict;
use DBI::Library;
use vars qw($db $user $host $password $settings);
use CGI::CMS;
use strict;
my $cgi = CGI::CMS->new();
$cgi->init();
*settings = \$CGI::CMS::settings;
print $cgi->header;
my ($dbi, $dbh) = DBI::Library->new({name => $settings->{db}{name}, host => $settings->{db}{host}, user => $settings->{db}{user}, password => $settings->{db}{password},});
$dbi->addexecute({title => 'select', description => 'show query', sql => "select *from <TABLE> where `title` = ?", return => "fetch_hashref",});
my $showQuery = $dbi->select('select');
local $/ = "<br/>\n";

foreach my $key (keys %{$showQuery}) {
        print "$key: ", $showQuery->{$key}, $/;
}

