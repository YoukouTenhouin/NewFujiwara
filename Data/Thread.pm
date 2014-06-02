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
	category => $thread->{category_name},
	subcategory => $thread->{subcategory}	
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

sub set_title {
    my $self = shift;
    my $title = shift;
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('threads');
    $coll->update({_id => $self->{id}},{'$set' => {title => $title}});
    return $self;
}

1;
