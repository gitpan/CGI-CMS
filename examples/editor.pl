#!/usr/bin/perl -w
use lib("lib");
use HTML::Editor;
use HTML::Editor::BBCODE;
use CGI::CMS qw(:all);
init("/home/groups/l/li/lindnerei/cgi-bin/config/settings.pl");
print header;
print start_html(-title => 'HTML::Editor', -script => [{-type => 'text/javascript', -src => '/javascript/editor.js'}], -style => '/style/Crystal/editor.css',);
if(param('action') && param('action') eq 'add') {
        my $txt = param('message');
        if(param('submit') eq translate('preview')) {
                print a({href => "$ENV{SCRIPT_NAME}?txt=$txt"}, 'Edit it Again');
                print h2(param('headline'));
                BBCODE(\$txt);
                print br(), $txt;
        } else {
                print "You should save it ", br();
                print $txt;
                print br(), a({href => "$ENV{SCRIPT_NAME}?txt=$txt"}, 'Edit it Again');
        }
} else {
        my %parameter = (

                action => 'add',

                body => param('txt') ? param('txt') : 'body of the message',

                class => "min",

                attach => 0,

                maxlength => '100',

                path => "/home/groups/l/li/lindnerei/cgi-bin/templates/",

                reply => '',

                server => "http://localhost",

                style => 'Crystal',

                thread => 'news',

                headline => "New Message",
                title    => "title",
                catlist  => ' ',
                html     => 0,               # html enabled ? 0 for bbcode
        );
        my $editor = new HTML::Editor(\%parameter);

        print $editor->show();
}
use showsource;
&showSource("./editor.pl");
