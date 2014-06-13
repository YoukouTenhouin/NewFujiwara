use strict;
use warnings;

use Data::User;
use Data::Categories;
use Data::Thread;
use Data::Post;

sub new {
    my($req,$res) = @_;
    my $ucookie = $req->get_cookie('userinfo');
    my $user = Data::User->by_cookie($ucookie);
    if (!$user) {
	$res->redirect('/login');
	return;
    }
    if($req->method eq "GET") {
	$res->render("new.html",$req);
    } elsif ($req->method eq "POST") {
	my $params = $req->params;
	my $title = $params->{title};
	my $cid = $params->{cid};
	my @tags = (map {s/\s+(.*?)/$1/;s/(.*?)\s+$/$1/;$_} (split ",",$params->{tags}));
	my $content = $params->{content};
	my $category = Data::Categories->by_id($cid);
	if(!$category) {
	    $res->render("new.html",$req),
	    return;
	}
	my $tid = Data::Thread->new($title,$category,\@tags,$user);
	Data::Post->new($tid,$content,[],$user);
	$res->redirect("/thread/view/$tid");
	return;
    }
}

1;
