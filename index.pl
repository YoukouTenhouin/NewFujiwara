use strict;
use warnings;

use MongoDB;
use boolean;

use Response;

use Data::Threads;

sub index {
    my($req,$res,$pn) = @_;
    my $threads = Data::Threads->list->page($pn);
    if(!$threads->avaliable) {
	$res->abort(404);
	return;
    }
    $res->render("index.html",$req,$res,$threads,$pn);
}

1;
