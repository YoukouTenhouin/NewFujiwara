package Request;

use HTTP::Body;

my $MAX_COTENT_LENGTH = 4096;

sub from_psgi_env {
    shift;
    my $env = shift;
    my $req = {
	method => $env->{REQUEST_METHOD},
	uri => $env->{REQUEST_URI}
    };

    $req->{content-type} = $env->{CONTENT_TYPE} if ($env->{CONTENT_TYPE});
    $req->{content-length} = $env->{CONTENT_LENGTH} if ($env->{CONTENT_LENGTH});
    $req->{input-stream} = $env->{psgi.input} if ($env->{psgi.input});
    $req->{query-string} = $env->{QUERY_STRING} if ($env->{QUERY_STRING});
    bless $req;
    return $req;
}

sub params {
    if (!$req->{params}) {
	return undef if ($req->{content-length} > $MAX_COTENT_LENGTH);
	
	my $body = HTTP::Body->new($req->{content-type},$req->{content-length});
	my($buf) = "";
	$req->{input-stream}->read($buf,$req->{content-length});
	$body->add($buf);
	my $params = $body->param;
	$req->{params} = $params;
    }
    return $req->{params};
}

1;
