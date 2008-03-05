use strict;
use vars qw($settings $skip $cwd $prefix);
use Module::Build;
my $class = Module::Build->subclass(class => "Module::Build::Custom", code => <<'END');
my $release = 'blib/rhtml/';
my $dir     = 'htdocs/';
my $path    = '.';
use vars qw($settings);
use lib qw(lib);
use CGI::CMS::Settings qw(loadSettings saveSettings);
loadSettings("cgi-bin/config/settings.pl");
*settings = \$CGI::CMS::Settings::settings;

sub ACTION_build {
        my $self = shift;
        &change($dir);
        $release = 'blib/perl/';
        $dir     = 'cgi-bin/';
        &change($dir);
        $self->SUPER::ACTION_build;
        &replace('%PATH%', $settings->{cgi}{bin}, 'blib/perl/lze.pl');
        system(" cp extra/startup.pl blib/perl/config/startup.pl");
        &replace('%PATH%', $settings->{cgi}{bin}, 'blib/perl/config/startup.pl');
        &replace('%host%', $settings->{cgi}{serverName}, 'blib/perl/config/startup.pl');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/config.pl',    'blib/lib/CGI/CMS/Config.pm');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/translate.pl', 'blib/lib/CGI/CMS/Translate.pm');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/settings.pl',  'blib/lib/CGI/CMS/Settings.pm');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/session.pl',   'blib/lib/CGI/CMS/Session.pm');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/actions.pl',   'blib/lib/CGI/CMS/Actions.pm');
        &replace('%CONFIG%', $settings->{cgi}{bin} . '/config/settings.pl',  'blib/lib/CGI/CMS.pm');
        if($settings->{cgi}{mod_rewrite}) {
                system(" cp extra/.htaccess  blib/rhtml/");
                &replace('%ALIAS%', $settings->{cgi}{alias}, 'blib/rhtml/.htaccess');
        }
}
sub ACTION_realclean {
        my $self = shift;
        $settings->{database}{password} = '';
        saveSettings("cgi-bin/config/settings.pl");
        $self->SUPER::ACTION_realclean;
}
sub ACTION_install {
        my $self = shift;
        my %conf = ( name => $self->{'properties'}{dbname}, host => $self->{'properties'}{sqlhost}, user => $self->{'properties'}{dbuser},);
        $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~/^$/;
        eval 'use DBI::Library ';
        unless($@){
        my $database = new DBI::Library();
        $database->initDB(\%conf);
        open(IN, "extra/install.sql") or die $!;
        local $/;
        my $file = <IN>;
        foreach my $sql (split /;\n/, $file) {
                $database->void($sql);
                print  $/,$sql,$/,$@ if $@;
        }
        }else{
                print $/,$@,$/;
        }
        $self->SUPER::ACTION_install;
             if($settings->{cgi}{mod_rewrite}) {
                &replace('%ALIAS%', $settings->{cgi}{alias}, "$settings->{cgi}{DocumentRoot}/.htaccess");
        }
        my $prefix = defined $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} :'';
        system("chmod $settings->{files}{chmod} -R  $prefix/$settings->{cgi}{DocumentRoot}");
        system("chmod $settings->{files}{chmod} -R  $prefix/$settings->{cgi}{bin}");
        system("chown $settings->{files}{owner}:$settings->{files}{group} -R  $prefix/$settings->{cgi}{DocumentRoot}");
        system("chown $settings->{files}{owner}:$settings->{files}{group} -R  $prefix/$settings->{cgi}{bin}");

}

sub ACTION_uninstall {
        my %conf = ( name => $self->{'properties'}{dbname}, host => $self->{'properties'}{sqlhost}, user => $self->{'properties'}{dbuser},);
        if(defined $self->{'properties'}{dbpass} ){
        $conf{password} = $self->{'properties'}{dbpass} unless $self->{'properties'}{dbpass} =~/^$/;
        }
        eval 'use DBI::Library qw(all)';
        unless($@){
        my $database = new DBI::Library();
        $database->initDB(\%conf);
        open(IN, "extra/uninstall.sql") or die $!;
        local $/;
                my $file = <IN>;
        foreach my $sql (split /;\n/, $file) {
                $database->void($sql . ";");
        }
        }
}

sub change {
        my $d = shift;
        chomp($d);
        opendir(IN, $d) or die "cant open $d $!:$/";
        my @files = readdir(IN);
        closedir(IN);
        for(my $i = 0 ; $i <= $#files ; $i++) {
                unless ($files[$i] =~ /^\./) {
                        my $c = $d . $files[$i];
                        my $e = $c;
                        $e =~ s/^$dir(.*)/$1/;
                        unless (-d $d . $files[$i]) {
                                system(" cp " . $c . " $release/$e") unless (-e $release . "/" . $e && $files[$i] =~ /~$/);
                        } else {
                                system("mkdir -p $release/$e") unless (-e $release . "/" . $e);
                                &change($d . $files[$i] . "/");
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
        my $file = '';
        while(<EDIT>) {
                $_ =~s/$replace/$with/g;
                $file .= $_;
        }
        seek(EDIT, 0, 0);
        print EDIT $file;
        truncate(EDIT, tell(EDIT));
        close(EDIT);
        chmod 0755, $f if($f =~ /.pl$/);
}
sub ACTION_testdb {
        my $self = shift;
        $self->SUPER::ACTION_test;
}
END

my $inctance = $class->new(
        get_options => {
                skip => {store => \$skip},
        },
        module_name => 'CGI::CMS',
        requires    => {
                     'Test::More'                     => ">=0.7",
                     'Module::Build'                  => ">=0.2808",
                     'HTML::Menu::TreeView'           => ">=0.85",
                     'CGI::QuickForm'                 => ">=1.93",
                     'DBI'                            => ">=1.50",
                     'CGI'                            => ">=3.29",
                     'HTML::Parser'                   => ">=3.56",
                     'Syntax::Highlight::Perl'        => ">=1.00",
                     'MD5'                            => ">=2.03",
        },
        ($] >= 5.005 ? (AUTHOR => 'Dirk Lindner <lze@cpan.org>') : ()),
        dist_abstract      => "Weblog and CMS that runs under mod_perland and as cgi script",
        license            => "lgpl",
        create_makefile_pl => 'passthrough',
);

use Cwd;
$cwd    = cwd;
$prefix = $inctance->{phash}{runtime_params}{disk}{prefix} ? $inctance->{phash}{runtime_params}{disk}{prefix} :'';
use lib qw(lib);
use CGI::CMS::Settings qw(loadSettings saveSettings);
unless ($@) {
        loadSettings();
        loadSettings("cgi-bin/config/config.pl") unless -e $settings->{cgi}{bin};
        *settings = \$CGI::CMS::Settings::settings;
        $inctance->{properties}{htd}         = $settings->{cgi}{DocumentRoot}  ? $settings->{cgi}{DocumentRoot}  : '/srv/www//htdocs';
        $inctance->{properties}{cgi}         = $settings->{cgi}{bin}           ? $settings->{cgi}{bin}           : '/srv/www/cgi-bin';
        $inctance->{properties}{server}      = $settings->{cgi}{serverName}    ? $settings->{cgi}{serverName}    : 'localhost';
        $inctance->{properties}{alias}       = $settings->{cgi}{alias}         ? $settings->{cgi}{alias}         : 'cgi-bin';
        $inctance->{properties}{mod_rewrite} = $settings->{cgi}{mod_rewrite}   ? $settings->{cgi}{mod_rewrite}   : 0;
        $inctance->{properties}{dbname}      = $settings->{database}{name}     ? $settings->{database}{name}     : 'LZE';
        $inctance->{properties}{dbuser}      = $settings->{database}{user}     ? $settings->{database}{user}     : 'root';
         $inctance->{properties}{sqlhost}                              = $settings->{database}{host}     ? $settings->{database}{host}     : 'localhost';
        $inctance->{properties}{dbpass}      = $settings->{database}{password} ? $settings->{database}{password} : '';
        $inctance->{properties}{group}       = $settings->{files}{group}       ? $settings->{files}{group}       : 'wwwrun';
        $inctance->{properties}{owner}       = $settings->{files}{owner}       ? $settings->{files}{owner}       : $ENV{USER};
        $inctance->{properties}{chmod}       = $settings->{files}{chmod}       ? $settings->{files}{chmod}       : '0755';

} else {
        eval 'use lib("./lib");';
        eval 'use CGI::CMS::Settings qw(saveSettings)';
}
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
$inctance->{properties}{install_path}{perl} = $prefix . $inctance->{properties}{cgi};
$inctance->{properties}{install_path}{rhtml} = $prefix .$inctance->{properties}{htd};

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
        $inctance->{properties}{server}      = Module::Build->prompt("Enter your Server Name", $inctance->{properties}{server});
        $inctance->{properties}{mod_rewrite} = $inctance->{properties}{mod_rewrite}  ? $inctance->{properties}{mod_rewrite} : 0;
        $inctance->{properties}{mod_rewrite} = Module::Build->prompt("Should i use mod_rewrite (0 or 1)? default is 0 type 1 to enable make sure  that mod_rewrite is installed and enabled if you set this to 1!", $inctance->{properties}{mod_rewrite});
        $inctance->{properties}{alias}       =       $inctance->{properties}{alias} ?       $inctance->{properties}{alias} :"cgi-bin";
        $inctance->{properties}{alias}       = Module::Build->prompt("Enter your Script Alias", $inctance->{properties}{alias});
         $inctance->{properties}{sqlhost} =  $inctance->{properties}{sqlhost} ?  $inctance->{properties}{sqlhost} : "localhost";
         $inctance->{properties}{sqlhost} = Module::Build->prompt("Enter your Mysql Server host",  $inctance->{properties}{sqlhost});
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

$settings = {
             config => "$inctance->{properties}{cgi}/config/settings.pl",
             admin  => {email => 'your@email.org', firstname => 'Firstname', name => 'Name', street => 'example 33', town => 'Berlin',},
             cgi    => {
                     expires      => '+1y',
                     cookiePath   => '/',
                     serverName   => $inctance->{properties}{server},
                     DocumentRoot => $inctance->{properties}{htd},
                     bin          => $inctance->{properties}{cgi},
                     title        => 'Lindnerei',
                     style        => 'Crystal',
                     mod_rewrite  => $inctance->{properties}{mod_rewrite},
                     alias        => $inctance->{properties}{alias},
             },
             language      => 'en',
             defaultAction => 'news',
             scriptAlias   => $inctance->{properties}{alias},
             uploads       => {maxlength => 2003153, path => "$inctance->{properties}{htd}/downloads/", chmod => 0644, enabled => 1},
             tree      => {navigation => "$inctance->{properties}{cgi}config/tree.pl", links => "$inctance->{properties}{cgi}config/links.pl"},
             version   => '0.28',
             session   => "$inctance->{properties}{cgi}/config/session.pl",
             actions   => "$inctance->{properties}{cgi}/config/actions.pl",
             translate => "$inctance->{properties}{cgi}/config/translate.pl",
             database  => {name      => $inctance->{properties}{dbname}, host     =>  $inctance->{properties}{sqlhost}, user => $inctance->{properties}{dbuser}, password => $inctance->{properties}{dbpass},},
             sidebar   => {left      => 1,                               right    => 1},
             news      => {maxlength => 5000,                            messages => 10},
             size      => 22,
             htmlright => 2,
             files => {group => $inctance->{properties}{group}, owner => $inctance->{properties}{owner}, chmod => $inctance->{properties}{chmod}},
};

saveSettings("$cwd/cgi-bin/config/settings.pl");
$inctance->create_build_script;

