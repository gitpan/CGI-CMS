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
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('news','news.pl','Blog',0,'news;navigation','show',1);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('settings','quick.pl','Settings',5,'','main',2);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addNews','news.pl','newMessage',0,'news;navigation','addNews',3);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('admin','admin.pl','adminCenter',5,'navigation;','main',4);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('delete','news.pl','blog',5,'news;navigation','deleteNews',5);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('edit','news.pl','blog',5,'news;navigation','editNews',6);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveedit','news.pl','blog',5,'news;navigation','saveedit',7);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('reply','news.pl','blog',0,'news;navigation','replyNews',8);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('profile','profile.pl','Profile',1,'navigation;','main',9);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('reg','reg.pl','register',0,'navigation;','reg',11);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addReply','news.pl','blog',0,'news;navigation','addReply',12);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showthread','news.pl','blog',0,'news;navigation','showMessage',13);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('makeUser','reg.pl','register',0,0,'make',14);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('verify','reg.pl','verify',0,0,'navigation;',15);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('fulltext','search.pl','search',0,'navigation;','fulltext',26);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newTreeviewEntry','editTree.pl','newTreeViewEntry',5,'navigation;','newTreeviewEntry',27);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveTreeviewEntry','editTree.pl','saveTreeviewEntry',5,'navigation;','saveTreeviewEntry',28);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('editTreeview','editTree.pl','editTreeview',5,'navigation;','editTreeview',29);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addTreeviewEntry','editTree.pl','addTreeviewEntry',5,'navigation;','addTreeviewEntry',30);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('editTreeviewEntry','editTree.pl','editTreeviewEntry',5,'navigation;','editTreeviewEntry',31);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteTreeviewEntry','editTree.pl','deleteTreeviewEntry',5,'navigation;','deleteTreeviewEntry',32);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('upEntry','editTree.pl','upEntry',5,'navigation;','upEntry',33);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('downEntry','editTree.pl','downEntry',5,'navigation;','downEntry',34);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('links','links.pl','Bookmarks',0,'navigation;','ShowBookmarks',35);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('env','env.pl','env',5,'navigation;','main',36);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('lostpass','login.pl','lostpass',0,0,'lostpass',38);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('getpass','login.pl','getpass',0,0,'getpass',39);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showDir','files.pl','Files',5,'navigation','showDir',42);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('openFile','files.pl','openFile',5,'navigation','OpenFile',43);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newFile','files.pl','newFile',5,'navigation','newFile',44);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('saveFile','files.pl','saveFile',5,'navigation','saveFile',45);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showMessage','news.pl','blog',0,'news;navigation','main',18);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('translate','translate.pl','translate',5,'navigation','main',47);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addTranslation','addtranslate.pl','translate',5,'navigation','addTranslation',48);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('chmodFile','files.pl','chmodFile',5,'navigation','chmodFile',49);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteFile','files.pl','deleteFile',5,'navigation','deleteFile',50);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('impressum','impressum.pl','Impressum',0,'navigation','main',51);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('makeDir','files.pl','Files',5,'navigation','makeDir',52);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('newGbookEntry','gbook.pl','gbook',5,'navigation','newGbookEntry',55);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('addnewGbookEntry','gbook.pl','gbook',0,'navigation','addnewGbookEntry',56);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('gbook','gbook.pl','gbook',0,'navigation','showGbook',57);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showaddTranslation','addtranslate.pl','translate',5,'navigation','main',58);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('deleteExploit','admin.pl','Admin',5,'navigation','deleteExploit',59);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('help','help.pl','help',0,'help;navigation','main',60);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('showEditor','news.pl','NewPost',0,'navigation','showEditor',61);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddFulltext','tables.pl','AddFulltext',5,'tables;navigation','AddFulltext',62);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AnalyzeTable','tables.pl','AnalyzeTable',5,'tables;navigation','AnalyzeTable',63);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddPrimaryKey','tables.pl','AddPrimaryKey',5,'tables;navigation','AddPrimaryKey',64);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',65);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeAutoInCrementValue',5,'tables;navigation','ChangeAutoInCrementValue',66);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeCol','tables.pl','ChangeCol',5,'tables;navigation','ChangeCol',67);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',68);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeCharset','tables.pl','ChangeCharset',5,'tables;navigation','ChangeCharset',69);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeAutoInCrementValue',5,'tables;navigation','ChangeAutoInCrementValue',70);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChooseDataBase','tables.pl','ChooseDataBase',5,'tables;navigation','ChooseDataBase',71);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropTable','tables.pl','DropTable',5,'tables;navigation;','DropTable',72);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DeleteEntry','tables.pl','DeleteEntry',5,'tables;navigation;','DeleteEntry',73);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropCol','tables.pl','DropCol',5,'tables;navigation','DropCol',74);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowDumpTable','tables.pl','DumpTable',5,'tables;navigation','ShowDumpTable',75);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ExecSql', 'tables.pl','ExecSql',5,'tables;navigation','ExecSql',76);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditTable','tables.pl','SQL',5,'tables;navigation','EditTable',77);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditEntry','tables.pl','EditEntry',5,'tables;navigation;','EditEntry',78);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewEntry', 'tables.pl','NewEntry',5,'tables;navigation;','NewEntry',79);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewTable','tables.pl','NewTable',5,'tables;navigation','NewTable',80);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewDatabase','tables.pl','NewDatabase',5,'tables;navigation','NewDatabase',81);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('OptimizeTable','tables.pl','OptimizeTable',5,'tables;navigation','OptimizeTable',82);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('RenameTable','tables.pl','RenameTable',5,'tables;navigation','RenameTable',83);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('RepairTable','tables.pl','RepairTable',5,'tables;navigation','RepairTable',84);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEditTable','tables.pl','SaveEditTable',5,'tables;navigation','SaveEditTable',85);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SQL','tables.pl','SQL',5,'tables;navigation','SQL',86);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewTable','tables.pl','ShowNewTable',5,'tables;navigation','ShowNewTable',87);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEntry','tables.pl','SaveEntry',5,'tables;navigation;','SaveEntry',88);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropFulltext','tables.pl','DropFulltext',5,'tables;navigation','DropFulltext',89);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTables','tables.pl',,'ShowTables',5,'tables;navigation;','ShowTables',90);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTableDetails','tables.pl','ShowTableDetails',5,'tables;navigation;','ShowTableDetails',91);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTable','tables.pl','ShowTable',5,'tables;navigation;','ShowTable',92);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('TruncateTable','tables.pl','TruncateTable',5,'tables;navigation','TruncateTable',93);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowProcesslist','tables.pl','ShowProcesslist',5,'tables;navigation','ShowProcesslist',94);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropFulltext','tables.pl','DropFulltext',5,'tables;navigation','DropFulltext',95);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddIndex','tables.pl','DropFulltext',5,'tables;navigation','AddIndex',96);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DropIndex','tables.pl','DropFulltext',5,'tables;navigation','DropIndex',97);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('AddUnique','tables.pl','DropFulltext',5,'tables;navigation','AddUnique',98);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewEntry','tables.pl','ShowNewEntry',5,'tables;navigation','ShowNewEntry',99);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveEntry','tables.pl','SaveEntry',5,'tables;navigation','SaveEntry',100);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewEntry','tables.pl','NewEntry',5,'tables;navigation','NewEntry',101);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('DeleteEntry','tables.pl','DeleteEntry',5,'tables;navigation','DeleteEntry',102);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowTables','tables.pl','ShowTables',5,'tables;navigation','ShowTables',103);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MultipleAction','tables.pl','MultipleAction',5,'tables;navigation','MultipleAction',104);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowDumpDatabase','tables.pl','DumpDatabase',5,'tables;navigation','ShowDumpDatabase',105);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowNewTable','tables.pl','ShowNewTable',5,'tables;navigation','ShowNewTable',106);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewTable','tables.pl','SaveNewTable',5,'tables;navigation','SaveNewTable',107);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ImportOperaBookmarks','links.pl','ImportOperaBookmarks',5,'navigation','ImportOperaBookmarks',108);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('linkseditTreeview','editTree.pl','linkseditTreeview',5,'navigation','linkseditTreeview',109);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditFile','files.pl','EditAction',5,'navigation','EditFile',110);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditAction','tables.pl','EditAction',5,'tables;navigation','EditAction',111);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditTopMenu','tables.pl','EditAction',5,'tables;navigation','EditTopMenu',112);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('EditVertMenu','tables.pl','EditAction',5,'tables;navigation','EditVertMenu',113);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ExportOperaBookmarks','links.pl','ExportOperaBookmarks',0,'navigation','ExportOperaBookmarks',114);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MoveTreeViewEntry','editTree.pl','MoveTreeViewEntry',5,'navigation','MoveTreeViewEntry',115);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) values('RenameTable','tables.pl','RenameTable','0','tables;navigation','RenameTable','117');
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('MultipleDbAction','tables.pl','MultipleDbAction',5,'tables;navigation','MultipleDbAction',118);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('RenameTable','tables.pl','RenameTable',5,'tables;navigation','RenameTable',119);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewColumn','tables.pl','SaveNewColumn',5,'tables;navigation','SaveNewColumn',120);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('NewDatabase','tables.pl','NewDatabase',5,'tables;navigation','NewDatabase',121);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ShowEditIndex','tables.pl','ShowEditIndex',5,'tables;navigation','ShowEditIndex',122);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('SaveNewIndex','tables.pl','SaveNewIndex',5,'tables;navigation','SaveNewIndex',123);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeEngine','tables.pl','ChangeEngine',5,'tables;navigation','ChangeEngine',124);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeAutoInCrementValue','tables.pl','ChangeEngine',5,'tables;navigation','ChangeAutoInCrementValue',125);
INSERT INTO `actions` (`action`,`file`,`title`,`right`,`box`,`sub`,`id`) VALUES('ChangeCharset','tables.pl','ChangeCharset',5,'tables;navigation','ChangeCharset',126);
CREATE TABLE IF NOT EXISTS box (
  `file` varchar(100) NOT NULL default '',
  position varchar(8) NOT NULL default 'left',
  `right` int(1) NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  `id` int(11) NOT NULL auto_increment,
  `dynamic` varchar(10) default NULL,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('navigation.pl','disabled',0,'navigation',1,'right');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('verify.pl','disabled',0,'verify',3,'right');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('login.pl','disabled',0,'login',4,'0');
INSERT INTO box (`file`,position,`right`,name,id,dynamic) VALUES('tables.pl','disabled',5,'database',10,'right');
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES('news.pl','disabled',0,'blog','right',7);
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES('help.pl','disabled',0,'help','right',8);
INSERT INTO box (`file`,position,`right`,name,dynamic,id) VALUES('feeds.pl','disabled',0,'help','right',9);
CREATE TABLE IF NOT EXISTS cats (
  `name` varchar(100) NOT NULL default '',
  `right` int(11) NOT NULL default '0',
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
INSERT INTO cats (name,`right`, id) VALUES('news',0, 1);
INSERT INTO cats (name,`right`, id) VALUES('member',1,2);
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
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('blog','news','news.png',0,'top','',1,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('Admin','admin','admin.png',5,'5','submenuadmin',2,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('properties','profile','profile.png',1,'6','',3,0);
INSERT INTO navigation (title,action,src,`right`,position,submenu,id,target) VALUES('links','links','link.png',0,'top','',5,0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES('impressum','impressum','about.png',0,'7','',6,0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES('gbook','gbook','link.png',0,'8','',7,0);
INSERT INTO navigation (title,`action`,src,`right`,position,submenu,id,target) VALUES('help','help','link.png',0,'9','',8,0);
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
INSERT INTO news (title,body,date,`user`,`right`,attach,cat,action,sticky,id) VALUES('Login as','Name: admin\r\npassword: testpass','2007-04-23 19:06:42','admin',0,'0','/news','news',0,1);
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
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('settings','settings','link.gif',5,NULL,1);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('database','showTables','gear.png',5,'',8);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('navigation','editTreeview','',5,'',9);
INSERT INTO submenuadmin (title,`action`,src,`right`,submenu,id) VALUES('env','env','link.gif',5,NULL,10);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('Edit links','linkseditTreeview','link.gif',5,'',12);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('Explorer','showDir','link.gif',5,'',15);
INSERT INTO submenuadmin (title,action,src,`right`,submenu,id) VALUES('translate','translate','link.gif',5,'',16);
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
INSERT INTO users (pass,`user`,date,email,`right`,name,firstname,street,city,postcode,phone,sid,ip,id) VALUES('fe7374a18d3f8ca9547e49aa39a2dd67','admin','0000-00-00','lindnerei@o2online.de',5,'Nachname','Vorname','Strasse','Stadt','Postleitzahl','Telefonnummer','0008e525bc0894a780297b7f3aed6f58','::1',1);
INSERT INTO users (pass,`user`,date,email,`right`,name,firstname,street,city,postcode,phone,sid,ip,id) VALUES('guest','guest','0000-00-00','guest@guestde',0,'guest','guest','guest','guest','57072','445566','hghsdf7','dd',2);
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
INSERT INTO topnavigation (title,action,src,`right`,  id,target) VALUES('news','news','news.png',0, 1,0);
INSERT INTO topnavigation (title,action,src,`right`, id,target) VALUES('Bookmarks','links','link.png',0, 2,0);
CREATE TABLE IF NOT EXISTS gbook (
  title varchar(50) NOT NULL default '',
  `body` text NOT NULL,
  `date` timestamp NOT NULL default CURRENT_TIMESTAMP on update CURRENT_TIMESTAMP,
  `user` text NOT NULL,
  `id` int(11) NOT NULL auto_increment,
  PRIMARY KEY  (id),
  FULLTEXT KEY title (title,body)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
