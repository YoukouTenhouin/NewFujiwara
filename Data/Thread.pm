package Data::Thread;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;
use boolean;

use Data::Posts;
use Data::User;

sub init {
    shift;
    my $thread = shift;
    my $ret = {
	id => $thread->{_id},
	title => $thread->{title},
	datetime => $thread->{datetime},
	lastreply => $thread->{lastreply},
	tags => $thread->{tags},
	hidden => $thread->{hidden},
	author => $thread->{author},
    };
    bless($ret);
    return $ret;
}

sub posts {
    my $self = shift;
    return Data::Posts->by_thread($self->{id},@_);
}

sub author {
    my $self = shift;
    return Data::User->by_id($self->{author});
}

1;
