package Router;

use strict;
use warnings;

sub new {
    shift;
    my $self = bless { rules => {@_} };
    return $self;
}

sub route {
    my $self = shift;
    my $uri = shift;
    for my $reg (keys $self->{rules}) {
	if ( $uri =~ $reg ) {
	    my @args = ( $uri =~ $reg );
	    my $h = $self->{rules}->{$reg};
	    $h->(@_,@args);
	    return 1;
	}
    }
    return undef;
}

1;
