package User;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;

use Digest::SHA qw(sha256);
use MIME::Base64;

require 'Data/secret_key.pl';
my $hashed_key = sha256(secret_key());

sub by_id {
    shift;
    my $id = MongoDB::OID->new(shift);
    my $db = Database::MongoClient->get->get_database('fujiwara');
    my $coll = $db->get_collection('users');
    my $cursor = $coll->find({ _id => $id });
    if (!$cursor->has_next) {
	return undef;
    } else {
	return user_init($cursor->next);
    }
}

sub user_init {
    my $user = shift;
    my $ret = {
	id => $user->{_id},
	name => $user->{name},
	jobs => $user->{jobs},
	email => $user->{email}
    }
}

sub sign_data {
    my $data = shift;
    return sha256($data ^ $hashed_key);
}

sub decode_cookie {
    shift;
    my $cookie = shift;
    my($data,$sign) = ($cookie =~ m/([^|]*)|(.*)/);
    if ($sign eq sign_data($data)) {
	reutrn MongoDB::OID->new(decode_base64($data));
    } else {
	return undef;
    }
}

sub encode_cookie {
    my $self = shift;
    my $id = $self->{id};
    my $data = encode_base64($id);
    my $sign = sign_data($data);
    return "$data|$sign";
}

1;
