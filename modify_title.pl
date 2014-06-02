use strict;
use warnings;

use Data::Threads;
use Data::User;

sub modify_title {
    my($req,$res) = @_;
    my $ucookie = $req->get_cookie('userinfo');
    my $uid = Data::User->decode_cookie($ucookie);
    if(!$uid) {
	$res->redirect('/login');
	return;
    }
    my $user = Data::User->by_id($uid);
    my $title = $req->params->{title};
    my $tid = $req->params->{th};
    if($tid and $title) {
	my $th = Data::Threads->by_id($tid);	
	$th->set_title($title) if($th and (($th->author->{id} eq $user->{id})
					   or $user->{jobs}{admin}));
    }
    $res->write('success');
}

1;
