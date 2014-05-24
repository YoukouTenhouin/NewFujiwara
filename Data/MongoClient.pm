package MongoClient;

use strict;
use warnings;

use MongoDB;

my $client;

sub get {
    shift;
    $client = MongoDB::MongoClient->new if (!$client);
    return $client;
}

1;
