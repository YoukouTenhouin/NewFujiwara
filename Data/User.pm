package Data::User;

use strict;
use warnings;

use Data::MongoClient;
use MongoDB::OID;
use ConfigFile;

use Digest::SHA qw(sha256_hex);
use MIME::Base64;
use Encode;

my $hashed_key;

sub by_id {
    shift;
    my $id = MongoDB::OID->new(shift);
    my $db = Data::MongoClient->get->get_database('fujiwara');
    my $coll = $db->get_collection('users');
    my $cursor = $coll->find({ _id => $id });
    if (!$cursor->has_next) {
	return undef;
    } else {
	return init($cursor->next);
    }
}

sub init {
    my $user = shift;
    my $ret = {
	id => $user->{_id},
	name => $user->{name},
	jobs => {map { $_ => 1 } @{$user->{jobs}}},
	email => $user->{email}
    };
    bless($ret);
}

sub sign_data {
    my $data = shift;
    $hashed_key = sha256_hex(getcfg 'secret_key') if(!$hashed_key);
    return sha256_hex(sha256_hex($data)^$hashed_key);
}

sub decode_cookie {
    shift;
    my $cookie = shift;
    return undef if(!$cookie);
    if ($cookie =~ m/([^|]*)\|(.*)/) {
	if ($2 eq sign_data($1)) {
	    return MongoDB::OID->new(decode_base64($1));
	} else {
	    return undef;
	}
    }
    return undef;
}

sub auth {
    shift;
    my($name,$pwd) = @_;
    my $name_lower = lc($name);
    my $hashed_pwd = sha256_hex($pwd);
    my $db = Data::MongoClient->get->get_database('fujiwara');
    my $coll = $db->get_collection('users');
    my $cursor = $coll->find({name_lower => decode_utf8($name_lower),
			      hashed_pwd => $hashed_pwd});
    if (!$cursor->has_next) {
	return undef;
    } else {
	return init($cursor->next);
    }
}

sub encode_cookie {
    my $self = shift;
    my $id = $self->{id};
    my $data = encode_base64($id);
    chomp($data);
    my $sign = sign_data($data);
    return "$data|$sign";
}

1;
