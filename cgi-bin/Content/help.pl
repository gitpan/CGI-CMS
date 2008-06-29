print print q(
<div align="center">
<div align="left" style="width:75%">
<h1>Help</h1>
<h2><a name="inst">Installation</a></h2>
<pre>
perl -MCPAN -e 'install CGI::CMS'
perl Makefile.PL
make
make test
make install
make testdb
make install_examples # /cgi-bin/examples/
</pre>
Mysql 5 <br/>
Perl 5.008006 is recommend<br/>
Required Cpan Module:<br/>
Apache2 with mod_perl2 is recommend but any other webbrowser  with cgi support should work.<br/>
<ul>
<li>CGI</li>
<li>DBI</li>
<li>MD5</li>
<li>HTML::Parser</li>
<li>CGI::QuickForm</li>
<li>HTML::Menu::TreeView</li>
<li>Syntax::Highlight::Engine::Kate</li>
<li>Module::Build</li>
<li>CGI::CMS</li>
</ul>
<br/>
Or simple install Bundle::Personal::lze ,
so you can simple install all aditional scripts.
<br/>
<a name="apache">Apache2 Example Config</a><br/>
<pre>

#
LoadModule perl_module                  /usr/lib/apache2-prefork/mod_perl.so

# If you want mod_rewrite
LoadModule rewrite_module               /usr/lib/apache2-prefork/mod_rewrite.so

# php einschalten
#AddType application/x-httpd-php .php #That is a stupid idea.


NameVirtualHost *:80

#user
User linse
Group users

<span style="color: #000000;">&lt;VirtualHost *:80&gt;</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">DirectoryIndex</span><span style="color: #dd0000;"> index.html index.pl index.php</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">ServerName</span><span style="color: #dd0000;"> localhost</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">ServerAlias</span><span style="color: #dd0000;"> localhost</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">ServerAdmin</span><span style="color: #dd0000;"> lindnerei@o2online.de</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">ServerSignature</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">on</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">UseCanonicalName</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">HostnameLookups</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">DocumentRoot</span><span style="color: #dd0000;"> "/srv/www/htdocs/"</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">RewriteEngine</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">RedirectMatch</span><span style="color: #dd0000;"> /perl/lze.pl https://localhost</span>
<span style="color: #000000;">        &lt;Directory "/srv/www/htdocs"&gt;</span>
<span style="color: #000000;">                </span><span style="font-weight: bold;color: #0000ff;">AllowOverride</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">All</span>
<span style="color: #000000;">                </span><span style="font-weight: bold;color: #0000ff;">Order</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">allow,deny</span>
<span style="color: #000000;">                </span><span style="font-weight: bold;color: #0000ff;">Allow</span><span style="color: #dd0000;"> from all</span>
<span style="color: #000000;">        &lt;/Directory&gt;</span>
<span style="color: #000000;">        </span><span style="font-weight: bold;color: #0000ff;">ScriptAlias</span><span style="color: #dd0000;"> /cgi-bin/ "/srv/www/cgi-bin/"</span>

<span style="color: #000000;">        &lt;Directory "/srv/www/cgi-bin/"&gt;</span>
<span style="color: #000000;">                 </span><span style="font-weight: bold;color: #0000ff;">AllowOverride</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">None</span>
<span style="color: #000000;">                 </span><span style="font-weight: bold;color: #0000ff;">Options</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">+ExecCGI</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">-Includes</span>
<span style="color: #000000;">                 </span><span style="font-weight: bold;color: #0000ff;">Order</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">allow,deny</span>
<span style="color: #000000;">                 </span><span style="font-weight: bold;color: #0000ff;">Allow</span><span style="color: #dd0000;"> from all</span>
<span style="color: #000000;">        &lt;/Directory&gt;</span>
<span style="color: #000000;">      </span><span style="font-weight: bold;color: #0000ff;">LoadModule</span><span style="color: #dd0000;"> perl_module                    /usr/lib/apache2/mod_perl.so</span>
<span style="color: #000000;">      &lt;IfModule mod_perl.c&gt;</span>
<span style="color: #000000;">            PerlModule Apache2</span>
<span style="color: #000000;">            PerlRequire "/srv/www/cgi-bin/config/startup.pl"</span>
<span style="color: #000000;">            </span><span style="font-weight: bold;color: #0000ff;">ScriptAlias</span><span style="color: #dd0000;"> /perl/ "/srv/www/cgi-bin/"</span>
<span style="color: #000000;">            PerlModule Apache2::Reload</span>
<span style="color: #000000;">            PerlInitHandler Apache2::Reload</span>
<span style="color: #000000;">            &lt;Location /perl/&gt;</span>
<span style="color: #000000;">                  </span><span style="font-weight: bold;color: #0000ff;">SetHandler</span><span style="color: #dd0000;"> perl-script</span>
<span style="color: #000000;">                  PerlResponseHandler ModPerl::Registry</span>
<span style="color: #000000;">                  PerlOptions +ParseHeaders</span>
<span style="color: #000000;">                  PerlSetVar PerlTaintCheck On</span>
<span style="color: #000000;">            &lt;/Location&gt;</span>
<span style="color: #000000;">      &lt;/IfModule&gt;</span>
<span style="color: #000000;">&lt;/VirtualHost&gt;</span>

<span style="font-style: italic;color: #808080;">################################################################################################</span>
<span style="font-style: italic;color: #808080;">#ssl</span>
<span style="font-style: italic;color: #808080;">#  Schluessel erzeugen</span>
<span style="font-style: italic;color: #808080;"># 1. openssl genrsa -out server.key -des3 1024</span>
<span style="font-style: italic;color: #808080;"># cert erstellen</span>
<span style="font-style: italic;color: #808080;"># 2.openssl req -new -key server.key -out server.csr</span>
<span style="font-style: italic;color: #808080;"># 3. selbst unterzeichnen</span>
<span style="font-style: italic;color: #808080;"># openssl req -new -x509 -days 1500 -key server.key -out server.crt</span>
<span style="font-style: italic;color: #808080;">################################################################################################</span>

<span style="font-weight: bold;color: #0000ff;">LoadModule</span><span style="color: #dd0000;"> ssl_module                 /usr/lib/apache2-prefork/mod_ssl.so</span>

<span style="font-weight: bold;color: #0000ff;">Listen</span><span style="color: #dd0000;"> 443</span>
<span style="font-weight: bold;color: #0000ff;">SSLMutex</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">sem</span>
<span style="font-weight: bold;color: #0000ff;">SSLRandomSeed</span><span style="color: #dd0000;"> startup builtin</span>
<span style="font-weight: bold;color: #0000ff;">NameVirtualHost</span><span style="color: #dd0000;"> *:443</span>

<span style="color: #000000;"> &lt;VirtualHost *:443&gt;</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">DirectoryIndex</span><span style="color: #dd0000;"> index.html index.pl index.php</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">ServerName</span><span style="color: #dd0000;"> localhost</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">ServerAlias</span><span style="color: #dd0000;"> localhost</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">ServerAdmin</span><span style="color: #dd0000;"> lindnerei@o2online.de</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">ServerSignature</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">on</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">UseCanonicalName</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">HostnameLookups</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">DocumentRoot</span><span style="color: #dd0000;"> "/srv/www/htdocs"</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">RewriteEngine</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">On</span>

<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">SSLEngine</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">on</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">SSLCertificateFile</span><span style="color: #dd0000;">    /home/linse/server.crt</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">SSLCertificateKeyFile</span><span style="color: #dd0000;"> /home/linse/server.key</span>

<span style="color: #000000;">       &lt;Directory "/srv/www/htdocs"&gt;</span>
<span style="color: #000000;">               </span><span style="font-weight: bold;color: #0000ff;">AllowOverride</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">All</span>
<span style="color: #000000;">               </span><span style="font-weight: bold;color: #0000ff;">Order</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">allow,deny</span>
<span style="color: #000000;">               </span><span style="font-weight: bold;color: #0000ff;">Allow</span><span style="color: #dd0000;"> from all</span>
<span style="color: #000000;">       &lt;/Directory&gt;</span>
<span style="color: #000000;">         </span><span style="font-weight: bold;color: #0000ff;">ScriptAlias</span><span style="color: #dd0000;"> /cgi-bin/ "D:\srv\www\cgi-bin\"</span>

<span style="color: #000000;">         &lt;Directory "D:\srv\www\cgi-bin\"&gt;</span>
<span style="color: #000000;">                  </span><span style="font-weight: bold;color: #0000ff;">AllowOverride</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">None</span>
<span style="color: #000000;">                  </span><span style="font-weight: bold;color: #0000ff;">Options</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">+ExecCGI</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">-Includes</span>
<span style="color: #000000;">                  </span><span style="font-weight: bold;color: #0000ff;">Order</span><span style="color: #ff00ff;"> </span><span style="font-weight: bold;color: #000000;">allow,deny</span>
<span style="color: #000000;">                  </span><span style="font-weight: bold;color: #0000ff;">Allow</span><span style="color: #dd0000;"> from all</span>
<span style="color: #000000;">       &lt;/Directory&gt;</span>
<span style="color: #000000;">       </span><span style="font-weight: bold;color: #0000ff;">LoadModule</span><span style="color: #dd0000;"> perl_module                    /usr/lib/apache2/mod_perl.so</span>
<span style="color: #000000;">       &lt;IfModule mod_perl.c&gt;</span>
<span style="color: #000000;">             PerlModule Apache2</span>
<span style="color: #000000;">             PerlRequire "/srv/www/cgi-bin/config/startup.pl"</span>
<span style="color: #000000;">             </span><span style="font-weight: bold;color: #0000ff;">ScriptAlias</span><span style="color: #dd0000;"> /perl/ "D:\srv\www\cgi-bin\"</span>
<span style="color: #000000;">             PerlModule Apache2::Reload</span>
<span style="color: #000000;">             PerlInitHandler Apache2::Reload</span>
<span style="color: #000000;">             &lt;Location /perl/&gt;</span>
<span style="color: #000000;">                   </span><span style="font-weight: bold;color: #0000ff;">SetHandler</span><span style="color: #dd0000;"> perl-script</span>
<span style="color: #000000;">                   PerlResponseHandler ModPerl::Registry</span>
<span style="color: #000000;">                   PerlOptions +ParseHeaders</span>
<span style="color: #000000;">                   PerlSetVar PerlTaintCheck On</span>
<span style="color: #000000;">             &lt;/Location&gt;</span>
<span style="color: #000000;">       &lt;/IfModule&gt;</span>
<span style="color: #000000;"> &lt;/VirtualHost&gt;</span>
</pre>
<h2><a name="video">Video Tutorials</a></h2><br/>
<a href="ftp://lindnerei.de/install_CGI_CMS.mpeg">Install Demo Video</a><br/>
<a href="ftp://lindnerei.de/bbcode_demo.mpeg">BBcode Demo</a><br/>
<a href="ftp://lindnerei.de/blog_demo.mpeg">Future Demo</a><br/>
<h2><a name="dev">Developer</a></h2>
<h2><a name="modules">Module</a></h2>
<a href="http://search.cpan.org/dist/CGI-CMS/">CGI::CMS</a><br/>
<a href="http://search.cpan.org/dist/HTML-Menu-TreeView/">HTML-Menu-TreeView</a><br/>
<h2><a name="examples">Examples</a></h2>
<a href="'http://lindnerei.sourceforge.net/cgi-bin/examples/window.pl">HTML::Window</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/editor.pl">HTML::Editor</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/tabwidget.pl">HTML::TabWidget</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/tabwidget.pl">HTML::TabWidget</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/pages.pl">HTML::Menu::Pages</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/main.pl">CGI::CMS::Main</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/main.pl">CGI::CMS::Main</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/DBI-FO.pl">DBI::Libary FO Syntax</a><br/>
<a href="http://lindnerei.sourceforge.net/cgi-bin/examples/DBI-OO.pl">DBI::Libary OO Syntax</a><br/>
<h2><a name="bbcode">BBcode</a></h2>
Avaible BBcode tags:<br/>
<b>
<br/>
[left]left[/left]<br/>
[center]center[/center]<br/>
[right]right[/right]<br/>
</b><br/>
<div  align="left">left</div>
<div align="center">center</div>
<div align="right">right</div>
<br/>
<b>
[b]bold[/b]<br/>
[i]italic[/i]<br/>
[s]strike[/s]<br/>
[u]underline[/u]<br/>
[sub]sub[/sub]<br/>
[sup]sup[/sup]
</b>
<br/>
<b>bold</b>
<br/><i>italic</i><br/>
<s>strike</s><br/>
<u>underline</u><br/>
<sub>sub</sub><br/>
<sup>sup</sup><br/>
<b>[img]http://www.lindnerei.de/images/plus.png[/img]<br/>
[url=http://url.de]link[/url]<br/>
[email=email@url.de]mailme[/email]<br/>
[color=red]color[/color]<br/>
[google]lindnerei.de[/google]<br/>
Example Config for JustBlogIt.<br/>
http://lindnerei.de/cgi-bin/lze.pl?action=showEditor;headline=%TITLE%;&amp;quote=%TEXT%;&amp;referer=%URL%;<br/>
[blog=http://referer]text[/blog]<br/>
</b>
<br/>
<img src="http://www.lindnerei.de/images/plus.png" alt="" border="0"/><br/>
<a style="color:rgb(0,0,0);background-color:rgb(230,218,222);" href="http://url.de">link</a><br/><a style="color:rgb(0,0,0);" target="_blank" href="mailto:email@url.de">mailme</a><br/><span style="color:red;background-color:rgb(230,218,222);">color</span><br/>
<a style="color:rgb(0,0,0);" target="_blank" href="http://www.google.de/search?q=lindnerei.de">Google:lindnerei.de</a><br/><table border="0" cellpadding="0" cellspacing="0"><tbody><tr><td><table class="blog" border="0" cellpadding="5" cellspacing="0"><tbody><tr><td>text</td></tr></tbody>
</table></td></tr><tr><td><b><a href="http://referer" class="link">Quelle</a></b></td></tr></tbody></table><br/><br/><b>[h1]h1[/h1]<br/>
[h2]h2[/h2]<br/>
[h3]h3[/h3]<br/>
[h4]h4[/h4]<br/>
[h5]h5[/h5]<br/>
</b>
<h1>h1</h1>
<h2>h2</h2>
<h3>h3</h3>
<h4>h4</h4>
<h5>h5</h5>
<br/><b>
[ul]<br/>
[li]1[/li]<br/>
[li]2[/li]<br/>
[li]3[/li]<br/>
[/ul]<br/></b><br/>
<ul>
<li>1</li>
<li>2</li>
<li>3</li>
</ul>
<b>
[ol]<br/>
[li]1[/li]<br/>
[li]2[/li]<br/>
[li]3[/li]<br/>
[/ol]<br/>
</b>
<ol>
<li>1</li>
<li>2</li>
<li>3</li>
</ol>
<br/><b>[hr]<br/></b>
<hr/>
<b>SyntaxHighlight tags</b><br/>
<b>[code=Perl]<br/>print"OK";<br/>[/code]<br/>
</b>
<div style="width:100%;"><pre><span style="color:#007f00;">print</span><span style="color:#ffa500;">"</span><span style="color:#ff0000;">OK</span><span style="color:#ffa500;">"</span>;</pre></div><br/>
langtags:Bash,C++,CSS,HTML,Java,JavaScript,PHP,Perl,Python,Ruby,XML<br/>
Not for replies:<br/>
Text Display in News<br/>
[previewende]<br/>
The Whole Message.<br/>
[de]
Deutscher Text wird angezigt wenn lang=de
[/de]<br/>
[en]
English text  is displayed if lang=en
[/en]
</div>
</div>
);
1;
