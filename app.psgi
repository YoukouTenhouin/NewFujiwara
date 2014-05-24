use MongoDB;
use MongoDB::OID;

use Router;
use Request;
use Response;

require 'view.pl';
require 'index.pl';

my $router = Router->new( qr'^/index/(\d+)$' => \&index ,
			  qr'^/thread/view/([^/]+)/(\d+)$' => \&view ,
			  qr'^/posttest' => \&posttest );

my $app = sub {
    my $env = shift;
    my $req = Request->from_psgi_env($env);
    my $uri = $req->{uri};
    my $res = Response->new;
    if($router->route($uri,$req,$res)) {
	return $res->psgi;
    } else {
	return [404,['Content-Type' => 'text/plain'],['404']];
    }
}
