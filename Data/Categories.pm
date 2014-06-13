package Data::Categories;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;

sub all {
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('categories');
    my $cursor = $coll->find()->sort({parent => 1,name => 1});
    return map{ { id => $_->{_id},category => $_->{parent} , subcategory => $_->{name} } } $cursor->all;
}

sub all_dict {
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('categories');
    my $cursor = $coll->find()->sort({parent => 1,name => 1});
    my %ret;
    map { $ret{$_->{'parent'}} = [] if(!$ret{$_->{'parent'}});push($ret{$_->{'parent'}},[$_->{'name'},$_->{_id}]); } $cursor->all;
    return \%ret;
}
sub by_id {
    shift;
    my $cl = Data::MongoClient->get;
    my $db = $cl->get_database('fujiwara');
    my $coll = $db->get_collection('categories');
    my $cursor = $coll->find({'_id' => MongoDB::OID->new(shift)});
    my $raw = $cursor->next;
    return {
	id => $raw->{_id},
	category => $raw->{parent},
	subcategory => $raw->{name}
    };
}

1;
