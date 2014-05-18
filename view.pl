use MongoDB;
use MongoDB::OID;
use boolean;

use Response;

sub view {
    my($req,$tid,$pn) = @_;
    
    my $db = MongoDB::MongoClient->new->get_database('fujiwara');
    my $tcoll = $db->get_collection("threads");
    my $tcur = $tcoll->find({_id => MongoDB::OID->new($tid)});
    return Response::abort(404) if (!$tcur->has_next);
    my $th = $tcur->next;

    my $pcoll = $db->get_collection("posts");
    my $cur = $pcoll->find({th => $th->{_id},hidden => false})->sort({datetime => 1});
    my $post_count = $cur->count();
    return Response::abort(403) if (($pn-1) * 30 > $post_count);    
    my @posts = $cur->skip(($pn-1)*30)->limit(30)->all;
    return Response::render("view.html",$db,$th,\@posts,$pn,$post_count);
}

1;
