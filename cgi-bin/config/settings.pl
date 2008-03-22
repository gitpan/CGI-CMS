$VAR1 = {
          'htmlright' => 2,
          'actions' => '/srv/www/cgi-bin/config/actions.pl',
          'tree' => {
                      'navigation' => '/srv/www/cgi-bin/config/tree.pl',
                      'links' => '/srv/www/cgi-bin/config/links.pl'
                    },
          'defaultAction' => 'news',
          'files' => {
                       'owner' => 'linse',
                       'group' => 'users',
                       'chmod' => '0755'
                     },
          'size' => 22,
          'uploads' => {
                         'maxlength' => 2003153,
                         'path' => '/srv/www//htdocs/downloads/',
                         'chmod' => 420,
                         'enabled' => 1
                       },
          'floodtime' => 10,
          'session' => '/srv/www/cgi-bin/config/session.pl',
          'scriptAlias' => 'cgi-bin',
          'admin' => {
                       'firstname' => 'Firstname',
                       'email' => 'your@email.org',
                       'street' => 'example 33',
                       'name' => 'Name',
                       'town' => 'Berlin'
                     },
          'language' => 'en',
          'version' => '0.3',
          'cgi' => {
                     'bin' => '/srv/www/cgi-bin',
                     'style' => 'Crystal',
                     'serverName' => 'localhost',
                     'cookiePath' => '/',
                     'title' => 'Lindnerei',
                     'mod_rewrite' => '1',
                     'alias' => 'cgi-bin',
                     'DocumentRoot' => '/srv/www//htdocs',
                     'expires' => '+1y'
                   },
          'database' => {
                          'password' => '',
                          'user' => 'root',
                          'name' => 'LZE',
                          'host' => 'localhost'
                        },
          'sidebar' => {
                         'left' => 1,
                         'right' => 1
                       },
          'translate' => '/srv/www/cgi-bin/config/translate.pl',
          'config' => '/srv/www/cgi-bin/config/settings.pl',
          'news' => {
                      'maxlength' => 5000,
                      'messages' => 10
                    }
        };
$settings =$VAR1;