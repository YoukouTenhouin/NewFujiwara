package Threads;

use strict;
use warnings;

use boolean;
use Data::MongoClient;
use MongoDB::OID;

use Data::Thread;

use constant THREAD_PER_PAGE => 50;

sub list {
    shift;
    my $ret = {
	hidden => false,
	pn => 1,
	@_
    };
    my $cl = Database::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('threads');
    my $q_options = {};
    $q_options->{hidden} = $ret->{hidden};
    $q_options->{category} = $ret->{category} if ($ret->{category});
    $q_options->{tags} = $ret->{tags} if ($ret->{tags});
    my $cursor = $coll->find($q_options);
    $ret->{cursor} = $cursor;
    bless($ret);
    return $ret;
}

sub page {
    my $self = shift;
    my $pn = shift;
    $self->{pn} = $pn;
    $self->{all} = undef;
}

sub by_id {
    shift;
    my $id = MongoDB::OID->new(shift);
    my $cl = MongoClient->get;
    my $coll = $cl->get_database('fujiwara')->get_collection('threads');
    my $cursor = $coll->find({_id => $id});
    if(!$cursor->has_next) {
	return undef;
    } else {
	return Database::Thread->init($cursor->next);
    }
}

sub all {
    my $self = shift;
    return $self->{all} if($self->{all});
    my $cursor = $self->{cursor};
    my $page = $self->{pn};
    return undef if (($page * THREAD_PER_PAGE) - $cursor->count > THREAD_PER_PAGE);    
    $cursor->skip(($page - 1) * THREAD_PER_PAGE)->limit(THREAD_PER_PAGE);
    my $prev_page = 0;
    my $next_page = 0;
    $next_page = 1 if($cursor->count - $page * THREAD_PER_PAGE > THREAD_PER_PAGE);
    $prev_page = 1 if(($cursor->count > THREAD_PER_PAGE)and($page > 1));
    my @all = ();
    push(@all,Database::Thread->init($_)) foreach($cursor->all);
    $self->{all} = \@all;
    return \@all;
}

sub has_prev {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{cursor};
    return (($cursor->count > THREAD_PER_PAGE) and ($pn > 1));
}

sub has_next {
    my $self = shift;
    my $cursor = $self->{cursor};
    my $pn = $self->{pn};
    return ($cursor->count - $pn * THREAD_PER_PAGE > THREAD_PER_PAGE);
}

1;
