package Posts;

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
    my $cl = MongoClient->get;
    my $coll = $cl->get_database('fujiwara')->get_collection('posts');
    my $cursor = $coll->find({_id => $id});
    if(!$cursor->has_next) {
	return undef;
    } else {
	return Database::Post->init($cursor->next);
    }
}

sub by_thread {
    shift;
    my $tid = shift;
    my $args = {
	hidden => false,
	pn => 1,
	@_
    };
    my $page = $args->{page};
    my $cl = MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $cl->get_collection('posts');
    my $cursor = $coll->find({ th => $tid,
			       hidden => $args->{hidden} });
    my $ret = {
	cursor => $cursor
    };
    bless($ret);
    return $cursor;
}

sub last {
    my $self = shift;
    $self->{cursor}->sort({datetime => -1});
    return Database::Post->init($self->{cursor}->next);
}

sub page {
    my $self = shift;
    my $pn = shift;
    $self->{pn} = $pn;
}

sub all {
    my $self = shift;
    return $self->{all} if($self->{all});
    my $cursor = $self->{cursor};
    my $pn = $self->{pn};
    $cursor->skip(($pn - 1) * POST_PER_PAGE)->limit(POST_PER_PAGE);
    return undef if (!$cursor->has_next);
    my @all = ();
    push(@all,Database::Post->init($_)) foreach($cursor->all);
    $self->{all} = \@all;
    return \@all;
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
