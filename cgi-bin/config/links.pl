$VAR1 = [
    {   'text'    => 'Sourceforge Sites',
        'subtree' => [
            {   'text' => 'Sourceforge Project Site',
                'href' => 'http://sourceforge.net/projects/lindnerei/',
                'rid'  => 3
            },
            {   'text' => 'Website',
                'href' => 'http://lindnerei.sourceforge.net/',
                'rid'  => 4
            }
        ],
        'rid' => 2
    },
    {   'text' => 'Cpan',
        'href' => 'http://search.cpan.org/~lze/',
        'rid'  => 5
    },
    {   'text' => 'Contact',
        'href' => 'mailto:lze@cpan.org',
        'rid'  => 1
    },
    {   'text' => 'Dokumentation',
        'href' => 'http://lindnerei.sourceforge.net/perldoc.shtml',
        'rid'  => 10
    },
    {   'text'    => 'Related Sites',
        'rid'     => 5,
        'subtree' => [
            {   'text' => 'Lindnerei.de',
                'href' => 'http://lindnerei.de/'
            },
            {   'text' => 'treeview.lindnerei',
                'href' => 'http://treeview.lindnerei.de'
            },
        ],
    },
    {   'text'    => 'Examples',
        'rid'     => 5,
        'subtree' => [
            {   'text' => 'HTML::Window',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/window.pl'
            },
            {   'text' => 'HTML::Editor',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/editor.pl'
            },
            {   'text' => 'HTML::TabWidget',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/tabwidget.pl'
            },
            {   'text' => 'HTML::Menu::Pages',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/pages.pl'
            },
            {   'text' => 'CGI::CMS::Main',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/main.pl'
            },
            {   'text' => 'DBI::Libary FO Syntax',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/DBI-FO.pl'
            },
            {   'text' => 'DBI::Libary OO Syntax',
                'href' =>
                    'http://lindnerei.sourceforge.net/cgi-bin/examples/DBI-OO.pl'
            },
        ],
    },
];
@TreeView = $VAR1;
