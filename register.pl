use strict;
use warnings;

use Data::User;
use DateTime;
use Captcha::reCAPTCHA;
use ConfigFile;

sub register {
    my($req,$res) = @_;
    if($req->method eq "GET") {
	my $referer = $req->headers->{referer};
	$referer = "/" if(!$referer);
	$res->render('reg.html',0,$referer,"","");
	return;
    } elsif($req->method eq "POST") {
	my $params = $req->params;
	my $referer = $params->{referer};
	my $name = $params->{name};
	my $pwd = $params->{pwd};
	my $email = $params->{email};
	$name =~ s/^[ \t]*(.+?)[ \t]*$/$1/;
	$email =~  s/^[ \t]*(.+?)[ \t]*$/$1/;
	if(getcfg 'recaptcha') {
	    my $challenge = $params->{recaptcha_challenge_field};
	    my $response = $params->{recaptcha_response_field};
	    my $c = Captcha::reCAPTCHA->new;
	    my $result = $c->check_answer(
		(getcfg 'c_private_key'),
		$req->headers->{x_real_ip},
		$challenge,$response
		);
	    if(!$result->{is_vaild}) {
		$res->render('reg.html',1,$referer,$name,$email);
		return;
	    }
	}
	if(Data::User->by_name($name)) {
	    $res->render('reg.html',2,$referer,$name,$email);
	    return;
	}
	my $user = Data::User->new($name,$pwd,$email);
	my $ucookie = $user->encode_cookie;
	my $expires = DateTime->new(
	    year => 3000,
	    month => 1,
	    day => 1,
	    hour => 0,
	    minute => 0,
	    second => 0
	    );
	$res->set_cookie("userinfo",$ucookie,expires => $expires);
	$res->redirect($referer);
	return;
    } else {
	$res->abort(405);
    }
}

1;
