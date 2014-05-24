use MongoDB;
use MongoDB::OID;
use boolean;

use Response;

require 'mongo_client.pl';

sub view {
    my($req,$res,$tid,$pn) = @_;
    
    my $cl = get_mongo_client();
    my $db = $cl->get_database('fujiwara');
    my $tcoll = $db->get_collection("threads");
    my $tcur = $tcoll->find({_id => MongoDB::OID->new($tid)});
    if (!$tcur->has_next) {
	$res->abort(404);
	return;
    }
    my $th = $tcur->next;

    my $pcoll = $db->get_collection("posts");
    my $cur = $pcoll->find({th => $th->{_id},hidden => false})->sort({datetime => 1});
    my $post_count = $cur->count();
    if (($pn-1) * 30 > $post_count) {
	$res->abort(403);
	return;
    }
    my @posts = $cur->skip(($pn-1)*30)->limit(30)->all;
    $res->render("view.html",$db,$th,\@posts,$pn,$post_count);
}

1;
