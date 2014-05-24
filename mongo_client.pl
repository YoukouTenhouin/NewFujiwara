use strict;
use warnings;

use MongoDB;

my $_mongo_client;

sub get_mongo_client {
    $_mongo_client = MongoDB::MongoClient->new if (!$_mongo_client);
    return $_mongo_client;
}

1;
