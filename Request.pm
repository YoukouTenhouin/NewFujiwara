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

    $req->{env} = $env;
    
    $req->{content-type} = $env->{CONTENT_TYPE} if ($env->{CONTENT_TYPE});
    $req->{content-length} = $env->{CONTENT_LENGTH} if ($env->{CONTENT_LENGTH});
    $req->{query-string} = $env->{QUERY_STRING};
    
    bless $req;
    return $req;
}

sub get_cookie {
    my $self = shift;
    my $key = shift;
    
    if (!$self->{cookies}) {
	$self->{cookies} = {};
	my $cookies_str = $self->{env}->{HTTP_COOKIES};
	return undef if (!$cookies_str);
	$self->{cookies}->{$key} = $value while(my($key,$value) = ($cookies_str =~ m/([^=]*)=([^;])*;/g));
    }
    return $self->{cookies}->{$key};
}

sub params {
    my $req = shift;
    if (!$req->{params}) {
	my $body = HTTP::Body->new($req->{content-type},$req->{content-length});
	my($buf) = "";
	$req->{env}->{'psgi.input'}->read($buf,$req->{content-length});
	$req->{params} = {};
	my @list = split( /\&/, $buf);
	foreach (@list) {
	    ($var, $val) = split(/=/);
	    $val =~ s/\'//g;
	    $val =~ s/\+/ /g;
	    $val =~ s/%(\w\w)/sprintf("%c", hex($1))/ge;
	    $req->{params}->{$var} = $val;
	}
    }
    return $req->{params};
}

1;
