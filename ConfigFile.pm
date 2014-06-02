package ConfigFile;

use strict;
use warnings;

use Exporter;

our @ISA = qw(Exporter);
our @EXPORT=qw(getcfg setcfg loadcfg dumpcfg);

my %config;

sub getcfg {
    my $key = shift;
    return $config{$key};
}

sub setcfg {
    my($key,$value) = shift;
    $config{$key} = $value;
}

sub loadcfg {
    my $filename = shift;
    open(my $fh,"<",$filename) or return 0;
    while(<$fh>) {
	chomp;
	m/[ \t]*(.+?)[ \t]+(.+);.*/;
	$config{$1} = $2;
    }
    return 1;
}

sub dumpcfg {
    my $filename = shift;
    open(my $fh,">",$filename) or return 0;
    print $fh "$_\t$config{$_}" foreach (keys %config);
    return 1;
}

1;
