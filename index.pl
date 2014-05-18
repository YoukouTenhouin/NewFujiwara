use MongoDB;
use boolean;

use Response;

sub index {
    my $cl = MongoDB::MongoClient->new;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection("threads");
    my $cur = $coll->find({hidden => false})->sort({lastreply => -1 });
    my $body = '<html><head><meta charset="utf8"/><titile>Index</title></head>';
    $body .= '<body><ul>';
    $body .= "<li><a href=\"/thread/view/$_->{_id}\">$_->{title}</a></li>" foreach($cur->all);
    $body .= '</ul></body></html>';

    return Response::write($body,Content-Type => "text/html");
}

1;
