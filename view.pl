use strict;
use warnings;

use Data::Threads;
use MongoDB::OID;
use boolean;

use Response;

require 'mongo_client.pl';

sub view {
    my($req,$res,$tid,$pn) = @_;
    my $th = Data::Threads->by_id($tid);
    my $posts = $th->posts->page($pn);
    if (!$posts->avaliable) {
	$res->abort(404);
	return;
    }
    $res->render("view.html",$req,$res,$th,$posts,$pn);
}

1;
