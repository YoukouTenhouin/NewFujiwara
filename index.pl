use strict;
use warnings;

use MongoDB;
use boolean;

use Response;

use Data::Threads;

require 'mongo_client.pl';

sub index {
    my($req,$res,$pn) = @_;
    my $threads = Data::Threads->list(page => $pn);
    my $all = $threads->all;
    if(!$all) {
	$res->abort(404);
	return;
    }
    $res->render("index.html",$req,$res,$all,$pn);
}

1;
