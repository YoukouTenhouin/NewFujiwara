use MongoDB;
use MongoDB::OID;

use Router;
use Request;
use Response;
use ConfigFile;

require 'view.pl';
require 'index.pl';
require 'login.pl';
require 'logout.pl';
require 'reply.pl';
require 'modify_title.pl';
require 'new.pl';
require 'categories.pl';
require 'category.pl';
require 'register.pl';

my $router = Router->new( qr'^/index/(\d+)$' => \&index ,
			  qr'^/thread/view/([^/]+)/(\d+)$' => \&view ,
			  qr'^/login$' => \&login ,
			  qr'^/logout$' => \&logout ,
			  qr'^/post/new$' => \&reply ,
			  qr'^/api/modify-title$' => \&modify_title ,
			  qr'^/new$' => \&new ,
			  qr'^/categories' => \&categories ,
			  qr'^/category/(\w+)/(\d+)$' => \&category ,
			  qr'^/reg$' => \&register
    );

my $app = sub {
    loadcfg 'config';
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
