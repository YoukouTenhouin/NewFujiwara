package Response;

use strict;
use warnings;

use Mojo::Template;
use Encode;

sub write {
    my $content = shift;
    my $headers = \@_;
    return [200,$headers,[encode_utf8($content)]];
}

sub render {
    my $file = shift;
    my $template = Mojo::Template->new;
    my $body = $template->render_file('templates/'.$file,@_);
    my $headers = [ 'Content-Type' => 'text/html' ];
    return [200,$headers,[encode_utf8($body)]];
}

sub abort {
    my $status = shift;
    my $headers = [ 'Content-Type' => 'text/plain' , @_ ];
    return [$status,$headers,[ $status ]];
}

1;
