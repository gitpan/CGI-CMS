use strict;
use vars qw($m_hrSettings $skip $cwd $prefix);
use Module::Build;

my $class = Module::Build->subclass(
    class => "Module::Build::Custom",
    code  => <<'END');
              my $release = 'blib/rhtml/';
              my $dir     = 'htdocs/';
              my $path    = '.';
              use vars qw($m_hrSettings $cwd);
              use File::Copy;
              use File::Path;
              loadSettings("cgi-bin/config/settings.pl");

              sub ACTION_build {
              my $self = shift;
              &change($dir);
              $release = 'blib/perl/';
              $dir     = 'cgi-bin/';
              &change($dir);
              $self->SUPER::ACTION_build;
              &replace('%PATH%', $m_hrSettings->{cgi}{bin}, 'blib/perl/lze.pl');
#             copy("extra/startup.pl", "blib/perl/config/startup.pl") or die "Copy failed: $!";

              if(-e "$m_hrSettings->{cgi}{bin}/config/links.pl") {
                     chmod 0755, "blib/perl/config/links.pl";
                     copy("$m_hrSettings->{cgi}{bin}/config/links.pl", "blib/perl/config/links.pl") or die "Copy failed: $m_hrSettings->{cgi}{bin}/config/links.pl $!";
              }
              if(-e "$m_hrSettings->{cgi}{bin}/config/tree.pl") {
                     chmod 0755, "blib/perl/config/tree.pl";
                     copy("$m_hrSettings->{cgi}{bin}/config/tree.pl", "blib/perl/config/tree.pl") or die "Copy failed: $m_hrSettings->{cgi}{bin}/config/tree.pl $!";
              }
              if(-e "$m_hrSettings->{cgi}{DocumentRoot}/.htaccess") {
                     copy("$m_hrSettings->{cgi}{DocumentRoot}/.htaccess", "blib/rhtml/.htaccess") or die $!;
              } elsif ($m_hrSettings->{cgi}{mod_rewrite}) {
                     copy("extra/.htaccess", "blib/rhtml/.htaccess") or die "Copy failed: $!";
                     &replace('%ALIAS%', $m_hrSettings->{cgi}{alias}, 'blib/rhtml/.htaccess');
              }
#             &replace('%PATH%',   'blib/perl',                 'blib/perl/config/startup.pl'  );
#             &replace('%host%',   $m_hrSettings->{cgi}{serverName},'blib/perl/config/startup.pl'  );
              &replace('%CONFIG%', 't/config.pl',               'blib/lib/CGI/CMS/Config.pm'   );
              &replace('%CONFIG%', 't/translate.pl',            'blib/lib/CGI/CMS/Translate.pm');
              &replace('%CONFIG%', 't/settings.pl',             'blib/lib/CGI/CMS/Settings.pm' );
              &replace('%CONFIG%', 't/session.pl',              'blib/lib/CGI/CMS/Session.pm'  );
              &replace('%CONFIG%', 't/actions.pl',              'blib/lib/CGI/CMS/Actions.pm'  );
              &replace('%CONFIG%', 't/settings.pl',             'blib/lib/CGI/CMS.pm'          );
              &replace('%CONFIG%', 't/config.pl',               'blib/lib/CGI/CMS/Config.pm'   );
              &replace('%CONFIG%', 't/settings.pl',             'blib/lib/HTML/Editor.pm'      );
              &replace('%CONFIG%', 't/settings.pl',             'blib/lib/Template/Quick.pm'   );
              }

              sub ACTION_realclean {
              my $self = shift;
              $m_hrSettings->{database}{password} = '';
              saveSettings("cgi-bin/config/settings.pl");
              $self->SUPER::ACTION_realclean;
              }

              sub ACTION_install {
              my $self = shift;
#             &replace('blib/perl',     $m_hrSettings->{cgi}{bin},                          'blib/perl/config/startup.pl'  );
#             &replace('%host%',        $m_hrSettings->{cgi}{serverName},                   'blib/perl/config/startup.pl'  );
              &replace('t/config.pl',   $m_hrSettings->{cgi}{bin} . '/config/config.pl',    'blib/lib/CGI/CMS/Config.pm'   );
              &replace('t/translate.pl',$m_hrSettings->{cgi}{bin} . '/config/translate.pl', 'blib/lib/CGI/CMS/Translate.pm');
              &replace('t/settings.pl', $m_hrSettings->{cgi}{bin} . '/config/settings.pl',  'blib/lib/CGI/CMS/Settings.pm' );
              &replace('t/session.pl',  $m_hrSettings->{cgi}{bin} . '/config/session.pl',   'blib/lib/CGI/CMS/Session.pm'  );
              &replace('t/actions.pl',  $m_hrSettings->{cgi}{bin}. '/config/actions.pl',    'blib/lib/CGI/CMS/Actions.pm'  );
              &replace('t/settings.pl', $m_hrSettings->{cgi}{bin}. '/config/settings.pl',   'blib/lib/CGI/CMS.pm'          );
              &replace('t/settings.pl', $m_hrSettings->{cgi}{bin}. '/config/settings.pl',   'blib/lib/HTML/Editor.pm'      );
              &replace('t/settings.pl', $m_hrSettings->{cgi}{bin}. '/config/settings.pl',   'blib/lib//Template/Quick.pm'  );
              $self->SUPER::ACTION_install;
              my %conf = (
                     name => $self->{'properties'}{dbname},
                     host => $self->{'properties'}{sqlhost},
                     user => $self->{'properties'}{dbuser},
              );
              $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~ /^$/;
              eval 'use lib qw(lib);use DBI::Library ';
              unless ($@) {
                     my $m_oDatabase = new DBI::Library();
                     $m_oDatabase->initDB(\%conf);
                     open(IN, "extra/install.sql") or die $!;
                     local $/;
                     my $m_sFile = <IN>;
                     foreach my $sql (split /;\n/, $m_sFile) {
                     $m_oDatabase->void($sql);
                     print $/, $sql, $/, $@ if $@;
                     }
              } else {
                     warn $@;
              }
              my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} : '';
              system("chmod $m_hrSettings->{files}{chmod} -R  $prefix/$m_hrSettings->{cgi}{DocumentRoot}");
              system("chmod $m_hrSettings->{files}{chmod} -R  $prefix/$m_hrSettings->{cgi}{bin}");
              system("chown $m_hrSettings->{files}{owner}:$m_hrSettings->{files}{group} -R  $prefix/$m_hrSettings->{cgi}{DocumentRoot}");
              system("chown $m_hrSettings->{files}{owner}:$m_hrSettings->{files}{group} -R  $prefix/$m_hrSettings->{cgi}{bin}");

              }

              sub ACTION_uninstall {
              my %conf = (
                     name => $self->{'properties'}{dbname},
                     host => $self->{'properties'}{sqlhost},
                     user => $self->{'properties'}{dbuser},
              );
              if(defined $self->{'properties'}{dbpass}) {
                     $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~ /^$/;
              }
              eval 'use lib qw(lib);use DBI::Library ';
              unless ($@) {
                     my $m_oDatabase = new DBI::Library();
                     $m_oDatabase->initDB(\%conf);
                     open(IN, "extra/uninstall.sql") or die $!;
                     local $/;
                     my $m_sFile = <IN>;
                     foreach my $sql (split /;\n/, $m_sFile) {
                     $m_oDatabase->void($sql . ";");
                     print $@ if $@;
                     }
              }
              }

              sub change {
              my $d = shift;
              chomp($d);
              opendir(IN, $d) or die "Install failed: $d $!:$/";
              my @files = readdir(IN);
              closedir(IN);
              for(my $i = 0 ; $i <= $#files ; $i++) {
                     unless ($files[$i] =~ /^\./) {
                     my $c = "$d/$files[$i]";
                     my $e = $c;
                     $e =~ s/^$dir(.*)/$1/;
                     unless (-d $c) {
                            copy($c, "$release/$e") or die "Install failed: $!$c  $release/$e/$files[$i]";
                     } else {
                            mkpath("$release/$e") unless (-d "$release/$e");
                            &change("$d/$files[$i]") unless $files[$i] =~ /^\./;
                     }
                     }
              }
              }

              sub replace {
              my $replace = shift;
              my $with    = shift;
              my $f       = shift;
              chmod 0644, $f;
              open(EDIT, "+<$f") or die "$! $f $/";
              my $files = '';
              while(<EDIT>) {
                     $_ =~ s/$replace/$with/g;
                     $files .= $_;
              }
              seek(EDIT, 0, 0);
              print EDIT $files;
              truncate(EDIT, tell(EDIT));
              close(EDIT);
              chmod 0755, $f if($f =~ /.pl$/);
              }

              sub ACTION_testdb {
              my $self = shift;
              eval("use File::Copy;");
              unless ($@) {
                     copy("extra/00-DBI-Database.t", "t/00-DBI-Database.t") or die "Copy failed: $!";
                     copy("extra/00-DBI-OO.t",       "t/00-DBI-OO.t")       or die "Copy failed: $!";
                     copy("extra/00-DBI-FO.t",       "t/00-DBI-FO.t")       or die "Copy failed: $!";
                     $self->SUPER::ACTION_test;
                     unlink("t/00-DBI-Database.t");
                     unlink("t/00-DBI-OO.t");
                     unlink("t/00-DBI-FO.t");
              }
              }

              sub ACTION_install_examples {
              my $self = shift;
              my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} : '';
              $release = "$prefix/$self->{properties}{cgi}/examples";
              $dir     = 'examples/';
              &change($dir);
              system("chmod 0755 -R  $release");
              }

              sub loadSettings {
              my $do = shift;
              if(-e $do) {
                     do $do;
              }
              }

              sub saveSettings {
              my $saveAs = shift;
              use Data::Dumper;
              my $content = Dumper($m_hrSettings);
              $content .= "\$m_hrSettings =\$VAR1;";
              use Fcntl qw(:flock);
              use Symbol;
              my $fh = gensym();
              my $rsas = $saveAs =~ /^(\S+)$/ ? $1 : 0;

              if($rsas) {
                     open $fh, ">$rsas.bak" or die "$/saveSettings$/ $! $/ File: $rsas";
                     flock $fh, 2;
                     seek $fh, 0, 0;
                     truncate $fh, 0;
                     print $fh $content;
                     close $fh;
              }
              if(-e "$rsas.bak") {
                     rename "$rsas.bak", $rsas or die "$/saveSettings$/ $! $/ File: $rsas $/";
                     do $rsas;
              }
              }
END

my $inctance = $class->new(
    get_options => {skip => {store => \$skip},},
    module_name => 'CGI::CMS',
    requires    => {
        'Test::More'                      => ">=0.7",
        'Module::Build'                   => ">=0.2808",
        'HTML::Menu::TreeView'            => ">=1.04",
        'DBI'                             => ">=1.50",
        'CGI'                             => ">=3.29",
        'HTML::Parser'                    => ">=3.56",
        'Syntax::Highlight::Engine::Kate' => ">=0.04",
        'MD5'                             => ">=2.03",
#        'CGI::Ajax'                       => ">=0.706",
        'XML::RSS'                        => ">=1.33",
        'LWP::UserAgent'                  => ">= 5.813",
    },
    ($] >= 5.005 ? (AUTHOR => 'Dirk Lindner <lze@cpan.org>') : ()),
    dist_abstract      => "CMS",
    license            => "lgpl",
    create_makefile_pl => 'passthrough',
);
use Cwd;
$cwd = cwd;
$prefix = $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} : '';
eval 'use CGI::CMS::Settings qw(loadSettings)';
unless ($@) {
    *m_hrSettings = \$CGI::CMS::Settings::m_hrSettings;
    loadSettings();
    loadSettings("cgi-bin/config/settings.pl") unless -e $m_hrSettings->{cgi}{bin};
} else {
    do "cgi-bin/config/settings.pl";
}
$inctance->{properties}{htd}         = $m_hrSettings->{cgi}{DocumentRoot}  ? $m_hrSettings->{cgi}{DocumentRoot}  : '/srv/www//htdocs';
$inctance->{properties}{cgi}         = $m_hrSettings->{cgi}{bin}           ? $m_hrSettings->{cgi}{bin}           : '/srv/www/cgi-bin';
$inctance->{properties}{server}      = $m_hrSettings->{cgi}{serverName}    ? $m_hrSettings->{cgi}{serverName}    : 'localhost';
$inctance->{properties}{alias}       = $m_hrSettings->{cgi}{alias}         ? $m_hrSettings->{cgi}{alias}         : 'cgi-bin';
$inctance->{properties}{mod_rewrite} = $m_hrSettings->{cgi}{mod_rewrite}   ? $m_hrSettings->{cgi}{mod_rewrite}   : 0;
$inctance->{properties}{dbname}      = $m_hrSettings->{database}{name}     ? $m_hrSettings->{database}{name}     : 'LZE';
$inctance->{properties}{dbuser}      = $m_hrSettings->{database}{user}     ? $m_hrSettings->{database}{user}     : 'root';
$inctance->{properties}{sqlhost}     = $m_hrSettings->{database}{host}     ? $m_hrSettings->{database}{host}     : 'localhost';
$inctance->{properties}{dbpass}      = $m_hrSettings->{database}{password} ? $m_hrSettings->{database}{password} : '';
$inctance->{properties}{group}       = $m_hrSettings->{files}{group}       ? $m_hrSettings->{files}{group}       : 'wwwrun';
$inctance->{properties}{owner}       = $m_hrSettings->{files}{owner}       ? $m_hrSettings->{files}{owner}       : $ENV{USER};
$inctance->{properties}{chmod}       = $m_hrSettings->{files}{chmod}       ? $m_hrSettings->{files}{chmod}       : '0755';

$inctance->{properties}{dbname}      = $inctance->args('dbname')      if $inctance->args('dbname');
$inctance->{properties}{dbuser}      = $inctance->args('dbuser')      if $inctance->args('dbuser');
$inctance->{properties}{sqlhost}     = $inctance->args('sqlhost')     if $inctance->args('sqlhost');
$inctance->{properties}{dbpass}      = $inctance->args('dbpass')      if $inctance->args('dbpass');
$inctance->{properties}{cgi}         = $inctance->args('cgi')         if $inctance->args('cgi');
$inctance->{properties}{htd}         = $inctance->args('htd')         if $inctance->args('htd');
$inctance->{properties}{alias}       = $inctance->args('alias')       if $inctance->args('alias');
$inctance->{properties}{group}       = $inctance->args('group')       if $inctance->args('group');
$inctance->{properties}{chmod}       = $inctance->args('chmod')       if $inctance->args('chmod');
$inctance->{properties}{owner}       = $inctance->args('owner')       if $inctance->args('owner');
$inctance->{properties}{server}      = $inctance->args('server')      if $inctance->args('server');
$inctance->{properties}{mod_rewrite} = $inctance->args('mod_rewrite') if $inctance->args('mod_rewrite');
$inctance->{properties}{install_path}{perl}  = $prefix . $inctance->{properties}{cgi};
$inctance->{properties}{install_path}{rhtml} = $prefix . $inctance->{properties}{htd};

#uncomment this to install the lib files inside the cgi-bin directory
# $inctance->{properties}{install_path}{lib} = $prefix . $inctance->{properties}{cgi}."/lib/";

unless ($skip) {
    my $an = Module::Build->prompt(
        "Should i use settings from previous previous version $/ Document root: $inctance->{properties}{htd} $/ cgi-bin directory:  $inctance->{properties}{cgi} $/ Server Name: $inctance->{properties}{server} $/ Script Alias  $inctance->{properties}{alias} $/ mod_rewrite:  $inctance->{properties}{mod_rewrite} $/ Mysql Server host:  $inctance->{properties}{sqlhost} $/ Mysql user name: $inctance->{properties}{dbuser} $/ Mysql password:  $inctance->{properties}{dbpass} $/ Mysql Database Name:  $inctance->{properties}{dbname}$/Files group:  $inctance->{properties}{group}$/ Files owner:  $inctance->{properties}{owner} $/ Files chmod:  $inctance->{properties}{chmod}",
        'yes'
    );
    $skip = $an eq 'yes' ? 1 : 0;
}
unless ($skip) {
    $inctance->{properties}{cgi} = $inctance->{properties}{cgi} ? $inctance->{properties}{cgi} : "/srv/www/cgi-bin";
    $inctance->{properties}{htd} = $inctance->{properties}{htd} ? $inctance->{properties}{htd} : "/srv/www/htdocs";
    $inctance->{properties}{htd} = Module::Build->prompt("Where is your Document root ?",     $inctance->{properties}{htd});
    $inctance->{properties}{cgi} = Module::Build->prompt("Where is your cgi-bin directory ?", $inctance->{properties}{cgi});
    $inctance->{properties}{server} = $inctance->{properties}{server} ? $inctance->{properties}{server} : "http://localhost";
    $inctance->{properties}{server} = Module::Build->prompt("Enter your Server Name", $inctance->{properties}{server});
    $inctance->{properties}{mod_rewrite} = $inctance->{properties}{mod_rewrite} ? $inctance->{properties}{mod_rewrite} : 0;
    $inctance->{properties}{mod_rewrite} = Module::Build->prompt("Should i use mod_rewrite (0 or 1)? default is 0 type 1 to enable make sure  that mod_rewrite is installed and enabled if you set this to 1!", $inctance->{properties}{mod_rewrite});
    $inctance->{properties}{alias} = $inctance->{properties}{alias} ? $inctance->{properties}{alias} : "cgi-bin";
    $inctance->{properties}{alias} = Module::Build->prompt("Enter your Script Alias", $inctance->{properties}{alias});
    $inctance->{properties}{sqlhost} = $inctance->{properties}{sqlhost} ? $inctance->{properties}{sqlhost} : "localhost";
    $inctance->{properties}{sqlhost} = Module::Build->prompt("Enter your Mysql Server host", $inctance->{properties}{sqlhost});
    $inctance->{properties}{dbuser} = $inctance->{properties}{dbuser} ? $inctance->{properties}{dbuser} : "root";
    $inctance->{properties}{dbuser} = Module::Build->prompt("Enter your Mysql user name", $inctance->{properties}{dbuser});
    $inctance->{properties}{dbpass} = $inctance->{properties}{dbpass} ? $inctance->{properties}{dbpass} : "";
    $inctance->{properties}{dbpass} = Module::Build->prompt("Enter your Mysql password", $inctance->{properties}{dbpass});
    $inctance->{properties}{dbname} = $inctance->{properties}{dbname} ? $inctance->{properties}{dbname} : "LZE";
    $inctance->{properties}{dbname} = Module::Build->prompt("Enter your Mysql Database Name", $inctance->{properties}{dbname});
    $inctance->{properties}{owner} = $inctance->{properties}{owner} ? $inctance->{properties}{owner} : $ENV{USER};
    $inctance->{properties}{owner} = Module::Build->prompt("Enter your File Owner", $inctance->{properties}{owner});
    $inctance->{properties}{group} = $inctance->{properties}{group} ? $inctance->{properties}{group} : 'wwwrun';
    $inctance->{properties}{group} = Module::Build->prompt("Enter your File Owner Group", $inctance->{properties}{group});
    $inctance->{properties}{chmod} = $inctance->{properties}{chmod} ? $inctance->{properties}{chmod} : '0755';
    $inctance->{properties}{chmod} = Module::Build->prompt("Enter your Chmod!", $inctance->{properties}{chmod});
}

$m_hrSettings = {
    config => "$inctance->{properties}{cgi}/config/settings.pl",
    admin  => {
        email     => 'your@email.org',
        firstname => 'Firstname',
        name      => 'Name',
        street    => 'example 33',
        town      => 'Berlin',
                       'firstname' => 'Max',
                       'number' => '',
                       'postocde' => '',
                       'street' => '',
                       'town' => 'Berlin',
                       'jahoo' => '',
                       'msn' => '',
                       'icq' => '',
                       'tel' => '',
                       'postcode' => '10965',
                       'country' => 'Deutschland',
                       'tonwn' => 'Berlin',
                       'name' => 'Musterman',
                       'aim' => '',
                       'signature' => '',
                       'skype' => '',
                       'jabber' => ''
    },
    cgi => {
        expires      => '+1y',
        cookiePath   => '/',
        serverName   => $inctance->{properties}{server},
        DocumentRoot => $inctance->{properties}{htd},
        bin          => $inctance->{properties}{cgi},
        title        => 'Lindnerei',
        style        => 'lze',
        mod_rewrite  => $inctance->{properties}{mod_rewrite},
        alias        => $inctance->{properties}{alias},
    },
    language      => 'en',
    defaultAction => 'news',
    scriptAlias   => $inctance->{properties}{alias},
    uploads       => {
        maxlength => 2003153,
        path      => "$inctance->{properties}{htd}/downloads/",
        chmod     => 0644,
        enabled   => 1,
        right     => 5
    },
    tree => {
        navigation => "$inctance->{properties}{cgi}/config/tree.pl",
        links      => "$inctance->{properties}{cgi}/config/links.pl"
    },
    version   => '0.37',
    session   => "$inctance->{properties}{cgi}/config/session.pl",
    actions   => "$inctance->{properties}{cgi}/config/actions.pl",
    translate => "$inctance->{properties}{cgi}/config/translate.pl",
    database  => {
        name     => $inctance->{properties}{dbname},
        host     => $inctance->{properties}{sqlhost},
        user     => $inctance->{properties}{dbuser},
        password => $inctance->{properties}{dbpass},
        CurrentDb=> $inctance->{properties}{dbname},
        CurrentHost => $inctance->{properties}{sqlhost},
        CurrentUser => $inctance->{properties}{dbuser},
        CurrentPass =>$inctance->{properties}{dbpass},
    },
    sidebar => {
        left  => 0,
        right => 1
    },
    news => {
        maxlength => 5000,
        messages  => 10,
        right     => 5
    },
    size      => 22,
    htmlright => 2,
    files     => {
        group => $inctance->{properties}{group},
        owner => $inctance->{properties}{owner},
        chmod => $inctance->{properties}{chmod}
    },
    sign => 1,
    floodtime => 10,
};
saveSettings("$cwd/cgi-bin/config/settings.pl");
$inctance->create_build_script;

sub saveSettings {
    my $saveAs = shift;
    use Data::Dumper;
    my $content = Dumper($m_hrSettings);
    $content .= "\$m_hrSettings =\$VAR1;";
    use Fcntl qw(:flock);
    use Symbol;
    my $fh = gensym();
    my $rsas = $saveAs =~ /^(\S+)$/ ? $1 : 0;

    if($rsas) {
        open $fh, ">$rsas.bak" or die "$/saveSettings$/ $! $/ File: $rsas $/";
        flock $fh, 2;
        seek $fh, 0, 0;
        truncate $fh, 0;
        print $fh $content;
        close $fh;
    }
    if(-e "$rsas.bak") {
        rename "$rsas.bak", $rsas or die "$/saveSettings$/ $! $/ File: $rsas $/";
        do $rsas;
    }
}
