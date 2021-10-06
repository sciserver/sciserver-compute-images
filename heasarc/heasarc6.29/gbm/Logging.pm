package Logging;

use Cwd;

sub TIEHANDLE {
	use POSIX qw( strftime );
	my $class = shift;
	my $prog = shift;
	my $cwd = getcwd;  ### HERA
	# Creating the logfile for moc_ingest
	my $logfile = "$cwd/" . strftime("%Y_%m_%d_%H:%M:%S_$prog.log", localtime);  ### HERA
	
 	my @logs = ("-", $logfile);  ### HERA
	my @handles;
	
	for my $path (@logs) {
		open (my $fh, ">$path") || print "$prog: Failed to open log file: $path";
		push @handles, $fh;
	}
	bless [$prog, \@handles, $logfile], $class;
}

sub PRINT {
	my $self = shift;
	my $ok = 0;
	my $prog = $$self[0] . ": ";
	my $handles = $$self[1]; 
	for my $fh (@$handles) {
		$ok += print $fh $prog, @_;
	}
	return $ok == @$handles;
}

sub CLOSE {
	my $self = shift;
	# Only need to close the logfile:
	my $handles = $$self[1]; 
	close $$handles[1];
}

sub get_name {
	my $self = shift;
	# Return the name of the logfile:
	my $logfile = $$self[2];
	return $logfile; 
}

1;
