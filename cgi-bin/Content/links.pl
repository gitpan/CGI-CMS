use vars qw(@t);
loadTree($settings->{tree}{links});
*t = \@{$HTML::Menu::TreeView::TreeView[0]};
print qq(
<table align="left"  border="0" cellpadding="0" cellspacing="0"  width="100%" summary="linkLayout"><tr><td valign="top">);
print Tree(\@t);
print qq(</td></tr></table>);

