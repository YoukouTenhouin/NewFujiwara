use strict;
use warnings;

use Data::Post;
use Data::User;

sub reply {
    my($req,$res) = @_;
    my $ucookie = $req->get_cookie('userinfo');
    if (!$ucookie) {
	$res->abort(403);
	return;
    }
    my $uid = Data::User->decode_cookie($ucookie);
    my $user = Data::User->by_id($uid);
    my $referer = $req->headers->{referer};
    my $content = $req->params->{content};
    my $th = $req->params->{th};
    my $replyto = $req->params->{replyto};
    Data::Post->new($th,$content,$replyto,$user);
    $res->redirect($referer);
}

1;
