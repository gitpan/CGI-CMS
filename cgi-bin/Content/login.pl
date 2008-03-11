sub lostpass {
        my $name = param('user') ? param('user') : 'Name';
        my $mail = param('mail') ? param('mail') : 'mail';
        
        print
        qq(<br/><br/><table align="center" border="0" cellpadding="0" cellspacing="0" summary="lostpassHeader"><tr><td valign="middle"><form  action=""  target="_parent" method="post"  name="lostpass">&#160;Name:&#160;<input style="width:60px;" type="text" id="username" name="user" value="$name" maxlength="100" align="left"/>&#160;Email:&#160;<input type="hidden" name="action" value="getpass"/><input style="width:150px;" type="text" id="email" name="mail" value ="$mail" size="10"  alt="password" align="left"/>&#160;<input type="submit"  name="submit" value="submit" alt="submit" align="left" /></form></td></tr></table>);
}

sub getpass {
        my $name = param('user');
        my $mail = param('mail');
        my $uref = $database->fetch_hashref("SELECT *  FROM users where email = ?", $mail);
        if($uref->{email} eq $mail and $uref->{user} eq $name) {
                my $pass = int(rand(1000)+ 2) x 3;
                use MD5;
                my $md5 = new MD5;
                $md5->add($name);
                $md5->add($pass);
                my $cpass = $md5->hexdigest();
                $database->void("update users set pass =?  where id = $uref->{id}", $cpass);
                use Mail::Sendmail;
                my %mail = (To => $mail, From => $settings->{'admin'}{'email'}, subject => translate('lostpass'), Message => translate('username') . ": $name " . translate('password') . ":$pass");
                sendmail(%mail) or warn $Mail::Sendmail::error;
                print "<br/>", translate('mailsendet');
        } else {
                &lostpass();
        }
}
