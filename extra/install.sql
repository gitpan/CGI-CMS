CREATE TABLE IF NOT EXISTS actions (
  `action` varchar(100) NOT NULL default '',
  `file` varchar(100) NOT NULL default '',
  title varchar(100) NOT NULL default '',
  `right` int(1) NOT NULL default '0',
  box varchar(500) default NULL,
  sub varchar(25) NOT NULL default 'main',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('news', 'news.pl', 'Blog', 0, 'news;navigation', 'show', 1);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('settings', 'quick.pl', 'Settings', 5, 'navigation;', 'main', 2);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('addNews', 'news.pl', 'newMessage', 0, 'news;navigation', 'addNews', 3);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('admin', 'admin.pl', 'adminCenter', 5, 'navigation;', 'main', 4);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('delete', 'news.pl', 'blog', 5, 'news;navigation', 'deleteNews', 5);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('edit', 'news.pl', 'blog', 5, 'news;navigation', 'editNews', 6);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('saveedit', 'news.pl', 'blog', 5, 'news;navigation', 'saveedit', 7);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('reply', 'news.pl', 'blog', 0, 'news;navigation', 'reply', 8);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('profile', 'profile.pl', 'Profile', 1, 'navigation;', 'main', 9);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('showEntry', 'tables.pl', 'database', 5, 'tables;navigation;', 'showEntry', 10);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('reg', 'reg.pl', 'register', 0, 'navigation;', 'reg', 11);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('addReply', 'news.pl', 'blog', 0, 'news;navigation', 'addReply', 12);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('showthread', 'news.pl', 'blog', 0, 'news;navigation', 'showMessage', 13);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('makeUser', 'reg.pl', 'register', 0, NULL, 'make', 14);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('verify', 'reg.pl', 'verify', 0, NULL, 'navigation;', 15);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('newEntry', 'tables.pl', 'newEntry', 5, 'tables;navigation;', 'newEntry', 16);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('editEntry', 'tables.pl', 'editEntry', 5, 'tables;navigation;', 'editEntry', 17);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('showMessage', 'news.pl', 'blog', 0, 'news;navigation', 'main', 18);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('dropTables', 'tables.pl', 'database', 5, 'tables;navigation;', 'dropTables', 20);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('createMenu', 'tables.pl', 'database', 5, 'tables;navigation;', 'createMenu', 21);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('saveEntry', 'tables.pl', 'database', 5, 'tables;navigation;', 'saveEntry', 23);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('deleteEntry', 'tables.pl', 'database', 5, 'tables;navigation;', 'deleteEntry', 24);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('showTables', 'tables.pl', 'database', 5, 'tables;navigation;', 'showTables', 25);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('fulltext', 'search.pl', 'search', 0, 'navigation;', 'fulltext', 26);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('newTreeviewEntry', 'editTree.pl', 'newTreeViewEntry', 5, 'navigation;', 'newTreeviewEntry', 27);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('saveTreeviewEntry', 'editTree.pl', 'saveTreeviewEntry', 5, 'navigation;', 'saveTreeviewEntry', 28);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('editTreeview', 'editTree.pl', 'editTreeview', 5, 'navigation;', 'editTreeview', 29);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('addTreeviewEntry', 'editTree.pl', 'addTreeviewEntry', 5, 'navigation;', 'addTreeviewEntry', 30);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('editTreeviewEntry', 'editTree.pl', 'editTreeviewEntry', 5, 'navigation;', 'editTreeviewEntry', 31);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('deleteTreeviewEntry', 'editTree.pl', 'deleteTreeviewEntry', 5, 'navigation;', 'deleteTreeviewEntry', 32);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('upEntry', 'editTree.pl', 'upEntry', 5, 'navigation;', 'upEntry', 33);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('downEntry', 'editTree.pl', 'downEntry', 5, 'navigation;', 'downEntry', 34);
INSERT INTO actions (action, `file`, title, `right`, box, sub, id) VALUES('links', 'links.pl', 'Bookmarks', 0, 'navigation;', 'main', 35);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub, id) VALUES ('env', 'env.pl', 'env', 5, 'navigation;', 'main',36);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('lostpass', 'login.pl', 'lostpass', 0, NULL, 'lostpass',38);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('getpass', 'login.pl', 'getpass', 0, NULL, 'getpass',39);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('execSql', 'tables.pl', 'execSql', 4, 'tables;navigation', 'execSql',40);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('showTableDetails', 'tables.pl', 'showTableDetails', 4, 'tables;navigation', 'showTableDetails',41);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('showDir', 'files.pl', 'Files', 5, '', 'showDir', 42);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('openFile', 'files.pl', 'openFile', 5, '', 'openFile', 43);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('newFile', 'files.pl', 'newFile', 5, '', 'newFile', 44);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('saveFile', 'files.pl', 'saveFile', 5, '', 'saveFile', 45);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('sqldump', 'tables.pl', 'mysqldump', 5, 'tables;navigation;', 'sqldump', 46);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('translate', 'translate.pl', 'translate', 5, 'navigation', 'main', 47);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('addTranslation', 'addtranslate.pl', 'translate', 5, '', 'addTranslation', 48);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('chmodFile', 'files.pl', 'chmodFile', 4, NULL, 'chmodFile',49);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('deleteFile', 'files.pl', 'deleteFile', 4, NULL, 'deleteFile',50);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('impressum', 'impressum.pl', 'Impressum', 0, 'impressum;navigation', 'main',51);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('makeDir', 'files.pl', 'Files', 0, NULL, 'makeDir',52);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('newGbookEntry', 'gbook.pl', 'gbook', 5, 'navigation', 'newGbookEntry',55);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('addnewGbookEntry', 'gbook.pl', 'gbook', 0, 'navigation', 'addnewGbookEntry',56);
INSERT INTO actions (`action`,`file`,title,`right`,box,sub,id) VALUES ('gbook', 'gbook.pl', 'gbook', 0, 'navigation', 'showGbook',57);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('showaddTranslation', 'addtranslate.pl', 'translate', 5, 'navigation', 'main', 58);
INSERT INTO `actions` (`action`, `file`, `title`, `right`, `box`, `sub`, `id`) VALUES ('deleteExploit', 'admin.pl', 'Admin', 5, 'navigation', 'deleteExploit', 59);
CREATE TABLE IF NOT EXISTS box (
  `file` varchar(100) NOT NULL default '',
  position varchar(8) NOT NULL default 'left',
  `right` int(1) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  `id` int(11) NOT NULL auto_increment,
  `dynamic` varchar(10) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO box (`file`, position, `right`, name, id, dynamic) VALUES('navigation.pl', 'disabled', 0, 'navigation', 1, 'right');
INSERT INTO box (`file`, position, `right`, name, id, dynamic) VALUES('verify.pl', 'disabled', 0, 'verify', 3, 'right');
INSERT INTO box (`file`, position, `right`, name, id, dynamic) VALUES('login.pl', 'disabled', 0, 'login', 4, '0');
INSERT INTO box (`file`, position, `right`, name, id, dynamic) VALUES('tables.pl', 'disabled', 5, 'database', 10, 'right');
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES ('impressum.pl', 'disabled', 0, 'impressum', 'right',6);
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES ('news.pl', 'disabled', 0, 'blog', 'right',7);
CREATE TABLE IF NOT EXISTS cats (
  `name` varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO cats (name, `right`,  id) VALUES('news', 0,  1);
INSERT INTO cats (name, `right`,  id) VALUES('member', 1, 2);
CREATE TABLE IF NOT EXISTS navigation (
  title varchar(100) NOT NULL default '',
  `action` varchar(100) NOT NULL default '',
  src varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  position varchar(5) NOT NULL default 'left',
  submenu varchar(100) default NULL,
  `id` int(11) NOT NULL auto_increment,
  target int(11) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO navigation (title, action, src, `right`, position, submenu, id, target) VALUES('blog', 'news', 'news.png', 0, 'top', '', 1, 0);
INSERT INTO navigation (title, action, src, `right`, position, submenu, id, target) VALUES('Admin', 'admin', 'admin.png', 5, '8', 'submenuadmin', 2, 0);
INSERT INTO navigation (title, action, src, `right`, position, submenu, id, target) VALUES('properties', 'profile', 'profile.png', 1, '6', '', 3, 0);
INSERT INTO navigation (title, action, src, `right`, position, submenu, id, target) VALUES('links', 'links', 'link.png', 0, 'top', '', 5, 0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES ('impressum', 'impressum', 'about.png', 0, '7', '',6,0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES ('gbook', 'gbook', 'link.png', 0, '8', '',7,0);
CREATE TABLE IF NOT EXISTS news (
  title varchar(100) NOT NULL default '',
  body text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(11) NOT NULL default '0',
  attach varchar(100) NOT NULL default '0',
  cat varchar(25) NOT NULL default 'news',
  `action` varchar(50) NOT NULL default 'main',
  sticky int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  format varchar(10) NOT NULL default 'bbcode',
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO news (title, body, date, `user`, `right`, attach, cat, action, sticky, id) VALUES('Login as', 'Name: admin\r\npassword: testpass', '2007-04-23 19:06:42', 'admin', 0, '0', '/news', 'news', 0, 1);
CREATE TABLE IF NOT EXISTS querys (
  title varchar(100) NOT NULL default '',
  description text NOT NULL,
  `sql` text NOT NULL,
  `return` varchar(100) NOT NULL default 'fetch_array',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE TABLE IF NOT EXISTS replies (
  title varchar(100) NOT NULL default '',
  body text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(10) NOT NULL default '0',
  attach varchar(100) NOT NULL default '0',
  refererId varchar(50) NOT NULL default '',
  sticky int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  format varchar(10) NOT NULL default 'bbcode',
  cat varchar(25) NOT NULL default 'replies',
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE TABLE IF NOT EXISTS submenuadmin (
  title varchar(100) NOT NULL default '',
  `action` varchar(100) NOT NULL default '',
  src varchar(100) NOT NULL default 'link.gif',
  `right` int(11) NOT NULL default '0',
  submenu varchar(100) default NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('settings', 'settings', 'link.gif', 5, NULL, 1);
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('database', 'showTables', 'gear.png', 5, '', 8);
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('navigation', 'editTreeview', '', 5, '', 9);
INSERT INTO submenuadmin (title,`action`,src,`right`,submenu,id) VALUES ('env', 'env', 'link.gif', 5, NULL,10);
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('links', 'linkseditTreeview', 'link.gif', 5, '', 12);
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('files', 'showDir', 'link.gif', 5, '', 15);
INSERT INTO submenuadmin (title, action, src, `right`, submenu, id) VALUES('translate', 'translate', 'link.gif', 5, '', 16);
CREATE TABLE IF NOT EXISTS trash (
  `table` varchar(50) NOT NULL default '',
  oldId bigint(50) NOT NULL default '0',
  title varchar(100) NOT NULL default '',
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `right` int(11) NOT NULL default '0',
  attach varchar(100) NOT NULL default '0',
  cat varchar(25) NOT NULL default 'main',
  `action` varchar(50) NOT NULL default 'news',
  sticky int(1) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  format varchar(10) NOT NULL default 'bbcode',
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE TABLE IF NOT EXISTS users (
  pass text NOT NULL,
  `user` varchar(25) NOT NULL default '',
  `date` date NOT NULL default '0000-00-00',
  email varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  firstname varchar(100) NOT NULL default '',
  street varchar(100) default NULL,
  city varchar(100) default NULL,
  postcode varchar(20) default NULL,
  phone varchar(50) default NULL,
  sid varchar(200) default NULL,
  ip varchar(50) default NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO users (pass, `user`, date, email, `right`, name, firstname, street, city, postcode, phone, sid, ip, id) VALUES('fe7374a18d3f8ca9547e49aa39a2dd67', 'admin', '0000-00-00', 'lindnerei@o2online.de', 5, 'Nachname', 'Vorname', 'Strasse', 'Stadt', 'Postleitzahl', 'Telefonnummer', '0008e525bc0894a780297b7f3aed6f58', '::1', 1);
INSERT INTO users (pass, `user`, date, email, `right`, name, firstname, street, city, postcode, phone, sid, ip, id) VALUES('guest', 'guest', '0000-00-00', 'guest@guestde', 0, 'guest', 'guest', 'guest', 'guest', '57072', '445566', 'hghsdf7', 'dd', 2);
CREATE TABLE IF NOT EXISTS exploit (
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP,
  referer text NOT NULL,
  remote_addr text NOT NULL,
  query_string text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
CREATE TABLE IF NOT EXISTS flood (
  remote_addr text NOT NULL,
  ti text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS topnavigation (
  title varchar(100) NOT NULL default '',
  `action` varchar(100) NOT NULL default '',
  src varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  target int(11) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO topnavigation (title, action, src, `right`,   id, target) VALUES('news', 'news', 'news.png', 0,  1, 0);
INSERT INTO topnavigation (title, action, src, `right`,  id, target) VALUES('Bookmarks', 'links', 'link.png', 0,  2, 0);
CREATE TABLE IF NOT EXISTS gbook (
  title varchar(50) NOT NULL default '',
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;