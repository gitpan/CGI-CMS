use vars qw($dump $dmp);
$dmp = param('dump') ? param('dump') : 'navigation';
$dump = $settings->{tree}{$dmp};

sub newTreeviewEntry {
        $dmp = param('dump') ? param('dump') : 'navigation';
        $dump = $settings->{tree}{$dmp};
        &newEntry();
}

sub saveTreeviewEntry {
        &load();
        &saveEntry(\@tree, param('rid'));
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub addTreeviewEntry {
        &load();
        &addEntry(\@tree, param('rid'));
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub editTreeview {
        &load();
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub editTreeviewEntry {
        &load();
        &editEntry(\@tree, param('rid'));
}

sub deleteTreeviewEntry {
        &load();
        &deleteEntry(\@tree, param('rid'));
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub upEntry {
        &load();
        &sortUp(\@tree, param('rid'));
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub downEntry {
        &load();
        $down = 1;
        &sortUp(\@tree, param('rid'));
        &updateTree(\@tree);
        print Tree(\@tree);
}

sub newEntry {
        print
          qq(<b>New Entry</b><form action="$ENV{SCRIPT_NAME}"><br/><table align="center" class="mainborder" cellpadding="2"  cellspacing="2" summary="mainLayolut"><tr><td>Text:</td><td><input type="text" value="" name="text"></td></tr><tr><td>Folder</td><td><input type="checkbox" name="folder" /></td></tr>);
        my $node = help();
        foreach my $key (sort(keys %{$node})) {
                print qq(<tr><td></td><td>$node->{$key}</td></tr><tr><td>$key :</td><td><input type="text" value="" name="$key"/><br/></td></tr>) if($key ne 'class');
        }
        print '<tr><td><input type="hidden" name="action" value="addTreeviewEntry"/><input type="hidden" name="rid" value="'
          . param('rid')
          . '"><input type="hidden" name="dump" value="'
          . $dmp
          . '"/></td><td><input type="submit"/></td></tr></table></form>';
}

sub addEntry {
        my $t    = shift;
        my $find = shift;
        for(my $i = 0 ; $i < @$t ; $i++) {
                if(@$t[$i]->{rid}== $find) {
                        my %params = Vars();
                        my $node   = {};
                        foreach my $key (sort(keys %params)) {
                                $node->{$key} = $params{$key} if(!($params{$key} =~ /^$/) && $key ne 'action' && $key ne 'folder' && $key ne 'subtree' && $key ne 'class' && $key ne 'href' && $key ne 'dump');
                                $node->{$key} =
                                    ($key eq 'href' && $params{$key} =~ /^action:\/\/(.*)$/)
                                  ? ($settings->{cgi}{mod_rewrite}) ? "/$1.html" : "$ENV{SCRIPT_NAME}?action=$1"
                                  :   $params{$key};
                        }
                        if(param('folder')) {
                                $node->{'subtree'} = [{text => 'Empty Folder',}];
                        }
                        push @$t, $node;
                        &rid();
                        saveTree($dump, \@tree);
                        return;
                } elsif (defined @{@$t[$i]->{subtree}}) {
                        &addEntry(\@{@$t[$i]->{subtree}}, $find);
                }
        }
}

sub saveEntry {
        my $t    = shift;
        my $find = shift;
        for(my $i = 0 ; $i < @$t ; $i++) {
                if(@$t[$i]->{rid}== $find) {
                        my %params = Vars();
                        foreach my $key (sort keys %params) {
                                @$t[$i]->{$key} = param($key) if(!($params{$key} =~ /^$/) && ($key ne 'action') && ($key ne 'subtree') && ($key ne 'dump') && ($key ne 'class'));
                        }
                        saveTree($dump, \@tree);
                        return;
                } elsif (defined @{@$t[$i]->{subtree}}) {
                        &saveEntry(\@{@$t[$i]->{subtree}}, $find);
                }
        }
}

sub editEntry {
        my $t    = shift;
        my $find = shift;
        my $href = "$ENV{SCRIPT_NAME}?action=editTreeviewEntry&amp;dump=$dmp";
        for(my $i = 0 ; $i < @$t ; $i++) {
                if(@$t[$i]->{rid}== $find) {
                        print "<b>" . @$t[$i]->{text} . '</b><form action="' . $href . '"><table align=" center " class=" mainborder " cellpadding="0"  cellspacing="0" summary="mainLayolut">';
                        my $node = help();
                        foreach my $key (sort(keys %{@$t[$i]})) {
                                print "<tr><td></td><td>$node->{$key}</td></tr>" if(defined $node->{$key});
                                print qq(<tr><td>$key </td><td><input type="text" value="@$t[$i]->{$key}" name="$key"></td></tr>) if($key ne 'subtree' && $key ne 'rid' && $key ne 'action' && $key ne 'dump' && $key ne 'class');
                        }
                        foreach my $key (sort(keys %{$node})) {
                                unless (defined @$t[$i]->{$key}) {
                                        print qq(<tr><td></td><td>$node->{$key}</td></tr><tr><td>$key :</td><td><input type="text" value="" name="$key"/><br/></td></tr>);
                                }
                        }
                        print
                          qq(<tr><td><input type="hidden" name="action" value="saveTreeviewEntry"/><input type="hidden" name="rid" value="@$t[$i]->{rid}"/><input type="hidden" name="dump" value="$dmp"/></td><td><input type="submit" value="save"/></td></tr></table></form>);
                        saveTree($dump, \@tree);
                        return;
                } elsif (defined @{@$t[$i]->{subtree}}) {
                        &editEntry(\@{@$t[$i]->{subtree}}, $find);
                }
        }
}

sub sortUp {
        my $t    = shift;
        my $find = shift;
        for(my $i = 0 ; $i <= @$t ; $i++) {
                if(defined @$t[$i]) {
                        if(@$t[$i]->{rid}== $find) {
                                $i++ if($down);
                                return if(($down && $i== @$t) or (!$down && $i== 0));
                                splice @$t, $i- 1, 2, (@$t[$i], @$t[$i- 1]);
                                saveTree($dump, \@tree);
                        }
                        if(defined @{@$t[$i]->{subtree}}) {
                                sortUp(\@{@$t[$i]->{subtree}}, $find);
                                saveTree($dump, \@tree);
                        }
                }
        }
}

sub deleteEntry {
        my $t    = shift;
        my $find = shift;
        for(my $i = 0 ; $i < @$t ; $i++) {
                if(@$t[$i]->{rid}== $find) {
                        splice @$t, $i, 1;
                        saveTree($dump, \@tree);
                } elsif (defined @{@$t[$i]->{subtree}}) {
                        deleteEntry(\@{@$t[$i]->{subtree}}, $find);
                }
        }
}

sub updateTree {
        my $t = shift;
        for(my $i = 0 ; $i < @$t ; $i++) {
                if(defined @$t[$i]) {
                        @$t[$i]->{addition} =
                          qq(<table border="0" cellpading="0" cellspacing="0" align="right" summary="layout"><tr><td><a class="treeviewLink$size" href="$ENV{SCRIPT_NAME}?action=editTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$style/$size/mimetypes/edit.png" border="0" alt="edit"></a></td><td><a class="treeviewLink$size" href="$ENV{SCRIPT_NAME}?action=deleteTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$style/$size/mimetypes/editdelete.png" border="0" alt="delete"></a></td><td><a class="treeviewLink$size" href="$ENV{SCRIPT_NAME}?action=upEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$style/$size/mimetypes/up.png" border="0" alt="up"></a></td><td><a class="treeviewLink$size" href="$ENV{SCRIPT_NAME}?action=downEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$style/$size/mimetypes/down.png" border="0" alt="down"></a></td><td><a class="treeviewLink$size" href="$ENV{SCRIPT_NAME}?action=newTreeviewEntry&amp;dump=$dmp&amp;rid=@$t[$i]->{rid}"><img src="/style/$style/$size/mimetypes/filenew.png" border="0" alt="new"></a></td></tr></table>);
                        updateTree(\@{@$t[$i]->{subtree}}) if(defined @{@$t[$i]->{subtree}});
                }
        }
}

sub rid {
        no warnings;
        my $rid = 0;
        &getRid(\@tree);

        sub getRid {
                my $t = shift;
                for(my $i = 0 ; $i < @$t ; $i++) {
                        $rid++;
                        @$t[$i]->{rid} = $rid;
                        getRid(\@{@$t[$i]->{subtree}}) if(defined @{@$t[$i]->{subtree}});
                }
        }
}

sub load {
        $dmp = param('dump') ? param('dump') : 'navigation';
        $dump = $settings->{tree}{$dmp};
        if(-e $dump) {
                loadTree($dump);
                *tree = \@{$HTML::Menu::TreeView::TreeView[0]};
        }
}
1;
