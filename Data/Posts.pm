package Data::Posts;

use strict;
use warnings;

use Data::Post;

use boolean;
use Data::MongoClient;
use MongoDB::OID;

use constant POST_PER_PAGE => 30;

sub by_id {
    shift;
    my $id = MongoDB::OID->new(shift);
    my $cl = Data::MongoClient->get;
    my $coll = $cl->get_database('fujiwara')->get_collection('posts');
    my $cursor = $coll->find({_id => $id});
    if(!$cursor->has_next) {
	return undef;
    } else {
	return Data::Post->init($cursor->next);
    }
}

sub by_thread {
    shift;
    my $tid = MongoDB::OID->new(shift);
    my $opts = {
	hidden => false,
	th => $tid,
	@_
    };
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('posts');
    my $cursor = $coll->find($opts);
    my $ret = { cursor => $cursor };
    bless($ret);
    return $ret;
}

sub last {
    my $self = shift;
    $self->{cursor}->sort({datetime => -1});
    return Data::Post->init($self->{cursor}->next);
}

sub avaliable {
    my $self = shift;
    return $self->{cursor}->has_next;
}

sub page {
    my $self = shift;
    my $pn = shift;
    $self->{all} = undef;
    $self->{pn} = $pn;
    $self->{cursor}->sort({datetime => 1})->skip(($pn - 1) * POST_PER_PAGE)->limit(POST_PER_PAGE);
    return $self;
}

sub all {
    my $self = shift;
    if (!$self->{all}) {
	my $cursor = $self->{cursor};
	my @all = ();
	push(@all,Data::Post->init($_)) foreach($cursor->all);
	$self->{all} = \@all;
    }
    return $self->{all};
}

sub has_prev {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{cursor};
    return (($cursor->count > POST_PER_PAGE) and ($pn > 1));
}

sub has_next {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{pn};
    return ($cursor->count - $pn * POST_PER_PAGE > POST_PER_PAGE);
}

1;
