use MongoDB;
use boolean;

use Response;

sub index {
    my($req,$pn) = @_;
    my $cl = MongoDB::MongoClient->new;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection("threads");
    my $cur = $coll->find({hidden => false})->sort({lastreply => -1 });
    my $count = $cur->count();
    return Response::abort(404) if ((($pn * 30) - $count) > 30);
    my @threads = $cur->skip(($pn - 1) * 30)->limit(30)->all;
    return Response::render("index.html",$db,\@threads,$count,$pn);
}

1;
