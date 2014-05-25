package Data::Post;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;
use boolean;

use Data::User;

sub init {
    shift;
    my $post = shift;
    my $ret = {
	id => $post->{_id},
	author => $post->{author},
	content => $post->{content},
	datetime => $post->{datetime},
	hidden => $post->{hidden},
	replyto => $post->{replyto},
    };
    bless($ret);
    return $ret;
}

sub author {
    my $self = shift;
    return Data::User->by_id($self->{author});
}

1;
