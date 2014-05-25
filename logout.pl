use strict;
use warnings;

use DateTime;

sub logout {
    my($req,$res) = @_;
    my $referer = $req->{env}->{HTTP_REFERER};
    $referer = "/" if(!$referer);
    my $expires = DateTime->new(
	year => 1970,
	month => 1,
	day => 1,
	hour => 0,
	minute => 0,
	second => 0
	);
    $res->set_cookie("userinfo","",expires => $expires);
    $res->redirect($referer);
}

1;
