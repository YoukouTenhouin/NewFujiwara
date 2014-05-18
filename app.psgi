use MongoDB;
use Mojo::Template;
use Encode;

my $app = sub {
    my $client = MongoDB::MongoClient->new;
    my $db = $client->get_database('fujiwara');
    my $coll = $db->get_collection('threads');
    my $threads = $coll->find()->sort({ 'lastreply' => -1 });
    my $thread = $threads->next;
    my $template  = Mojo::Template->new;
    my $body = $template->render_file('demo.html',$thread,$client);
    return [200,['Content-Type' => 'text/html'],[encode_utf8($body)]]
}
