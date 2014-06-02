use strict;
use warnings;

use Data::User;
use DateTime;

sub login {
    my($req,$res) = @_;
    if($req->{method} eq "GET") {
	my $referer = $req->headers->{referer};
	$referer = "/" if(!$referer);
	$res->render('login.html',0,$referer,'');
	return;
    } elsif ($req->{method} eq "POST") {
	my $params = $req->params;
	my $name = $params->{name};
	my $pwd = $params->{pwd};
	my $referer = $params->{referer};
	my $user = Data::User->auth($name,$pwd);
	if (!$user) {
	    $res->render('login.html',1,$referer,$name);
	    return;
	} else {
	    my $ucookie = $user->encode_cookie;
	    my $expires = DateTime->new(
		year => 3000,
		month => 1,
		day => 1,
		hour => 0,
		minute => 0,
		second => 0
		);
	    $res->set_cookie("userinfo",$ucookie,expires => $expires);
	    $res->redirect($referer);
	    return;
	}
    }
}

1;
