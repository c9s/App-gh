package App::gh::Logger;
use warnings;
use strict;
require qw(Exporter);
our @EXPORT = qw(Info Log Error);

our $LEVEL = 0;

sub level {
	my $class = shift;
	$LEVEL = shift if @_;
	return $LEVEL;
}


sub Info {
	print @_ , "\n";
}

sub Log {
	print @_ , "\n";
}

sub Error {
	print "[ERROR] " , @_ , "\n";
}

1;
