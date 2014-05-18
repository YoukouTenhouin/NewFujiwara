use MongoDB;
use MongoDB::OID;
use Encode;

use Router;
use Response;

sub get_collection{
    my $coll = shift;
    my $cl = MongoDB::MongoClient->new;
    my $db = $cl->get_database('fujiwara');
    return $db->get_collection($coll);
}

sub index {
    my $coll = get_collection("threads");
    my $cur = $coll->find()->sort({lastreply => -1 });    
    my $body = '<html><head><titile>Index</title></head>';
    $body .= '<body><ul>';
    $body .= "<li><a href=\"/thread/view/$_->{_id}\">$_->{title}</a></li>" foreach($cur->all);
    $body .= '</ul></body></html>';

    return Response::write($body,Content-Type => "text/html");
}

sub view {
    my $tid = MongoDB::OID->new(shift);
    my $coll = get_collection("threads");
    my $cur = $coll->find({_id => $tid});
    return Response::abort(404) if (!$cur->has_next);
    my $th = $cur->next;
    return Response::render("demo.html",$th);
}

my $router = Router->new( qr/^\/$/ => \&index ,
			  qr"/thread/view/([^/]+)" => \&view );

my $app = sub {
    my $env = shift;
    my $uri = $env->{REQUEST_URI};
    my $ret =  $router->route($uri);
    if ($ret) {
	return $ret;
    } else {
	return Response::abort(404);
    }
}
