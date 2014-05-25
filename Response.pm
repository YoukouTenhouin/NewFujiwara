package Response;

use strict;
use warnings;

use Encode;
use Mojo::Template;

sub new {
    shift;
    my $res = { buf => [],
		headers => [ 'Content-Type' => 'text/html' ],
		cookies => {},
		status => 200 };
    bless($res);
    return $res;
}

sub write {
    my $self = shift;
    my $content = shift;
    $self->{buf} = [ @{$self->{buf}} ,encode_utf8($content) ];
}

sub render {
    my $self = shift;
    my $file = shift;
    my $tmp = Mojo::Template->new;
    my $rendered = $tmp->render_file('templates/' . $file,@_);
    push(@{$self->{buf}},encode_utf8($rendered));
}

sub set_headers {
    my $self = shift;
    $self->{headers} = [
	@{$self->{headers}},
	@_
    ];
}

sub set_cookie {
    my $self = shift;
    my $key = shift;
    my $value = shift;

    my $cookie = {
	value => $value,
	path => '/',
	@_
    };

    $self->{cookies}->{$key} =$cookie;
}

sub redirect {
    my $self = shift;
    my $location = shift;
    $self->{status} = 302;
    push(@{$self->{headers}},Location => $location);
}

sub abort {
    my $self = shift;
    my $status = shift;
    %$self = (
	buf => [ $status ],
	headers => [ 'Content-Type' => 'text/plain' ],
	status => $status,
	cookies => {}
    );
}

sub psgi {
    my $self = shift;

    foreach(keys %{$self->{cookies}}) {
	my $cookie = $self->{cookies}->{$_};
	my $buf = "$_=$cookie->{value}";
	$buf .= ";Domain=" . $cookie->{domain} if ($cookie->{domain});
	$buf .= ";Path=" . $cookie->{path} if ($cookie->{path});
	$buf .= ";Expires=" . $cookie->{expires}->strftime("%a, %d %b %Y %T GMT") if (my $t = $cookie->{expires});
	$buf .= ";Secure" if ($cookie->{secure});
	$buf .= ";HttpOnly" if ($cookie->{secure});
	push(@{$self->{headers}},"Set-Cookie" => $buf);
    }
    
    my $ret = [ $self->{status}, $self->{headers}, $self->{buf} ];
    return $ret;
}

1;
