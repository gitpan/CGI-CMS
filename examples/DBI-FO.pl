#!/usr/bin/perl
use strict;
use lib qw(../lib);
use DBI::Library qw(:independent );
use vars qw($db $m_sUser $host $password $m_hrSettings);
use CGI::CMS qw(header init);
use strict;
init();
*m_hrSettings = \$CGI::CMS::settings;
print header;
my $m_dbh = initDB(
    {   name     => $m_hrSettings->{db}{name},
        host     => $m_hrSettings->{db}{host},
        user     => $m_hrSettings->{db}{user},
        password => $m_hrSettings->{db}{password},
    }
);
addexecute(
    {   title       => 'select',
        description => 'show query',
        sql         => "select *from <TABLE> where `title` = ?",
        return      => "fetch_hashref",
    }
);
my $showQuery = useexecute( 'select', 'select' );
local $/ = "<br/>\n";

foreach my $key ( keys %{$showQuery} ) {
    print "$key: ", $showQuery->{$key}, $/;
}
use showsource;
&showSource($0);

