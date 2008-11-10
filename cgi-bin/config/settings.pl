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
                         'right' => 5,
                         'path' => '/srv/www//htdocs/downloads/',
                         'chmod' => 420,
                         'enabled' => 1
                       },
          'floodtime' => 10,
          'session' => '/srv/www/cgi-bin/config/session.pl',
          'scriptAlias' => 'cgi-bin',
          'sign' => 1,
          'admin' => {
                       'firstname' => 'Max',
                       'number' => '',
                       'postocde' => '',
                       'street' => '',
                       'town' => 'Berlin',
                       'msn' => '',
                       'jahoo' => '',
                       'email' => 'your@email.org',
                       'icq' => '',
                       'tel' => '',
                       'postcode' => '10965',
                       'country' => 'Deutschland',
                       'name' => 'Musterman',
                       'tonwn' => 'Berlin',
                       'aim' => '',
                       'signature' => '',
                       'skype' => '',
                       'jabber' => ''
                     },
          'language' => 'en',
          'version' => '0.39',
          'cgi' => {
                     'bin' => '/srv/www/cgi-bin',
                     'style' => 'lze',
                     'serverName' => 'localhost',
                     'cookiePath' => '/',
                     'title' => 'Lindnerei',
                     'mod_rewrite' => '1',
                     'alias' => 'cgi-bin',
                     'DocumentRoot' => '/srv/www//htdocs',
                     'expires' => '+1y'
                   },
          'database' => {
                          'CurrentUser' => 'root',
                          'name' => 'LZE',
                          'CurrentPass' => '',
                          'host' => 'localhost',
                          'password' => '',
                          'user' => 'root',
                          'CurrentDb' => 'LZE',
                          'CurrentHost' => 'localhost'
                        },
          'sidebar' => {
                         'left' => 0,
                         'right' => 1
                       },
          'translate' => '/srv/www/cgi-bin/config/translate.pl',
          'config' => '/srv/www/cgi-bin/config/settings.pl',
          'news' => {
                      'maxlength' => 5000,
                      'right' => 5,
                      'messages' => 10
                    }
        };
$m_hrSettings =$VAR1;