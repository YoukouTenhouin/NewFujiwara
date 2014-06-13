use strict;
use warnings;

sub categories {
    my($req,$res) = @_;
    $res->render('categories.html',$req);
}

1;
