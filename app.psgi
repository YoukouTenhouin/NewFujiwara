use MongoDB;
use MongoDB::OID;
use Encode;

use Router;
use Request;
use Response;

require 'view.pl';
require 'index.pl';

my $router = Router->new( qr/^\/$/ => \&index ,
			  qr"/thread/view/([^/]+)/(\d+)" => \&view );

my $app = sub {
    my $env = shift;
    my $req = Request->from_psgi_env($env);
    my $uri = $req->{uri};
    my $ret =  $router->route($uri,$req);
    if ($ret) {
	return $ret;
    } else {
	return Response::abort(404);
    }
}
