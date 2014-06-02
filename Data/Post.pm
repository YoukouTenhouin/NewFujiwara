package Data::Post;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;
use boolean;

use Data::User;
use DateTime;

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

sub new {
    shift;
    my($th,$content,$replyto,$author) = @_;
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('posts');
    my @replyto_list = split /,/,$replyto;
    my @replyto = (keys %{{ map { MongoDB::OID->new($_) => 1 }  @replyto_list }});
    my $now = DateTime->now;
    my $insert = {
	author => $author->{id},
	content => $content,
	hidden => false,
	replyto => \@replyto,
	datetime => $now,
	markup => "markdown",
	th => MongoDB::OID->new($th)
    };
    my $pid = $coll->insert($insert);
    my $tcoll = $db->get_collection('threads');
    $tcoll->update({ _id => $th},{ '$set' => { lastreply => $now }});
    return $pid;
}

1;
