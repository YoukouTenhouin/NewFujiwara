package Router;

use strict;
use warnings;

sub new {
    shift;
    my $self = bless { rules => { @_ } };
    return $self;
}

sub route {
    my $self = shift;
    my $uri = shift;
    my $rules = $self->{rules};
    for my $reg (keys $rules) {
	if ( $uri =~ $reg ) {
	    my @args = ( $uri =~ $reg );
	    my $handler = $rules->{$reg};
	    return $handler->(@args,@_);
	}
    }
    return undef;
}

1;
