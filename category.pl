use strict;
use warnings;

use MongoDB;
use boolean;

use Response;

use Data::Threads;
use Data::Categories;

sub category {
    my($req,$res,$cid,$pn) = @_;
    my $threads = Data::Threads->by_category($cid)->page($pn);
    my $category = Data::Categories->by_id($cid);
    if(!$threads->avaliable || !$category) {
	$res->abort(404);
	return;
    }
    $res->render("category.html",$req,$res,$category,$threads,$pn);
}

1;
