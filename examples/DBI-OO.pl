#!/usr/bin/perl -w
use strict;
use lib qw(../lib);
use DBI::Library;
use vars qw($db $m_sUser $host $password $m_hrSettings);
use CGI::CMS;
use strict;
my $m_oCgi = CGI::CMS->new();
$m_oCgi->init();
*m_hrSettings = \$CGI::CMS::settings;
print $m_oCgi->header;
my ( $dbi, $m_dbh ) = DBI::Library->new(
    {   name     => $m_hrSettings->{db}{name},
        host     => $m_hrSettings->{db}{host},
        user     => $m_hrSettings->{db}{user},
        password => $m_hrSettings->{db}{password},
    }
);
$dbi->addexecute(
    {   title       => 'select',
        description => 'show query',
        sql         => "select *from <TABLE> where `title` = ?",
        return      => "fetch_hashref",
    }
);
my $showQuery = $dbi->select('select');
local $/ = "<br/>\n";

foreach my $key ( keys %{$showQuery} ) {
    print "$key: ", $showQuery->{$key}, $/;
}
use showsource;
&showSource($0);

