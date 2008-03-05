# Add your own lib
# use lib qw(../lib);
###################################################################################
#      path is set during make                                                    #
#lze###############################################################################
use CGI::CMS qw(:all);
use CGI::CMS::Settings;
use DBI::Library qw(:all);
use HTML::Menu::TreeView qw(:all);
loadSettings("%PATH%/config/config.pl");
use Template::Quick;
use HTML::Window qw(:all);
my %parameter = (path => "%PATH%/templates/", style => "Crystal", server => "%host%",);
use CGI::CMS::Main qw(:all);
initMain({template => 'blog.htm', path => "%PATH%/templates/", style => "Crystal", template => 'blog.htm'});
initWindow(\%parameter);
use HTML::TabWidget qw(:all);
initTabWidget({template => 'lzetabwidget.htm', path => "%PATH%/templates/", style => "Crystal",});
use HTML::Menu::Pages;
use HTML::Editor;
use HTML::Editor::BBCODE;
use DBI::Library::Database qw(:all);
use CGI::CMS::GUI;
### 3party
use HTML::Entities;
use CGI::QuickForm;
use Syntax::Highlight::Perl;

# Apache2 mod perl stuff
# enable if the mod_perl 1.0 compatibility is needed
# use Apache2::compat ();
# preload all mp2 modules
# use ModPerl::MethodLookup;
# ModPerl::MethodLookup::preload_all_modules();

#standart section
# use ModPerl::Util        ();    #for CORE::GLOBAL::exit
# use Apache2::RequestRec  ();
# use Apache2::RequestIO   ();
# use Apache2::RequestUtil ();
# use Apache2::ServerRec   ();
# use Apache2::ServerUtil  ();
# use Apache2::Connection  ();
# use Apache2::Log         ();
# use APR::Table           ();
# use ModPerl::Registry    ();
# use Apache2::Const -compile => ':common';
# use APR::Const -compile     => ':common';
#
# # use lib qw(/srv/www/perl-lib);
# # enable if the mod_perl 1.0 compatibility is needed
# # use Apache2::compat ();
# # preload all mp2 modules
# # use ModPerl::MethodLookup;
# # ModPerl::MethodLookup::preload_all_modules();
# use ModPerl::Util        ();    #for CORE::GLOBAL::exit
# use Apache2::RequestRec  ();
# use Apache2::RequestIO   ();
# use Apache2::RequestUtil ();
# use Apache2::ServerRec   ();
# use Apache2::ServerUtil  ();
# use Apache2::Connection  ();
# use Apache2::Log         ();
# use APR::Table           ();
# use ModPerl::Registry    ();
# use Apache2::Const -compile => ':common';
# use APR::Const -compile     => ':common';

1;
