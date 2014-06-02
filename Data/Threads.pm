package Data::Threads;

use strict;
use warnings;

use boolean;
use Data::MongoClient;
use MongoDB::OID;

use Data::Thread;

use constant THREAD_PER_PAGE => 50;

sub list {
    shift;
    my $opts = {
	hidden => false,
	@_
    };
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('threads');
    my $cursor = $coll->find($opts);
    my $ret = {
	cursor => $cursor,
	avaliable => 0
    };
    bless($ret);
    return $ret;
}

sub page {
    my $self = shift;
    my $pn = shift;
    $self->{pn} = $pn;
    $self->{cursor}->sort({datetime => -1})->skip(($pn - 1) * THREAD_PER_PAGE)->limit(THREAD_PER_PAGE);
    $self->{avaliable} = 1 if($self->{cursor}->has_next);
    $self->{all} = undef;
    return $self;
}

sub by_id {
    shift;
    my $id = MongoDB::OID->new(shift);
    my $cl = Data::MongoClient->get;
    my $coll = $cl->get_database('fujiwara')->get_collection('threads');
    my $cursor = $coll->find({_id => $id});
    if(!$cursor->has_next) {
	return undef;
    } else {
	return Data::Thread->init($cursor->next);
    }
}

sub avaliable {
    my $self = shift;
    return $self->{avaliable};
}

sub all {
    my $self = shift;
    if (!$self->{all}) {
	my $cursor = $self->{cursor};
	my @all = ();
	push(@all,Data::Thread->init($_)) foreach($cursor->all);
	$self->{all} = \@all;
    }
    return $self->{all};
}

sub has_prev {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{pn};
    return (($cursor->count > THREAD_PER_PAGE) and ($pn > 1));
}

sub has_next {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{pn};
    return ($cursor->count > $pn * THREAD_PER_PAGE);
}

1;
