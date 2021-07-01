package DOY;
require Exporter;

use strict;

=head1
**************************************************************************

         DOY: A package of time-related utility functions.
              A portion of the GBM ground software:
              Written, July 25, 2005, by RDP @ UAH.

              V1.1: 02/15/06 RDP Added sec2mjd.
              V1.2: 01/09/09 RDP Added convert_UTC() to take leap seconds 
                    into account, as per Alexander's CCR #131.
              V1.3: 11/25/09 RDP Corrected the epoch in sec2mjd() to 
                    51910, since it was off by a day, per Bill Cleveland's
                    error report on 11/13/09.
              V1.4: 06/23/10 RDP Removed export of convert_UTC(), since WC added 
                    it to GbmTime.pm and we don't want namespace collisions. This 
                    is all part of the support for CCR#260, the fraction of day 
                    '1000' bug.

Functions:
 ($year, $month, $day) = day_of_year($year, $ndays);
              Converts the day of the year into the date for a given year.

 $ndays = mmdd_to_doy($year, $mymonth, $ndays);
              Converts a date into the day of the year for a given year.

 ($sec,$min,$hour,$mday,$mon,$year,$yday) = convert_time($met_sec);
              Converts GLAST mission elapsed time into a date.

 ($mjd, $remainder) = sec2mjd($met_sec);
              Converts GLAST mission elapsed time into MJD and seconds of day.

**************************************************************************

=cut
our @ISA      = qw(Exporter);
our @EXPORT   = qw(day_of_year mmdd_to_doy convert_time sec2mjd);
our $VERSION  = 1.4;

sub day_of_year {
    my ($year, $ndays) = @_;

    my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31);
    
    die "Number of days is too large: $ndays,"  if ($ndays > 366);
    
    # Fix syntax of days:
    $ndays += 0;
    
    #Correct for leap year:
    $months[1]++  if ($year % 4 == 0);	
    $months[1]--  if ($year % 100 == 0);	
    $months[1]++  if ($year % 400 == 0);
	
	#print @months[1] . "\n";
	my $mymonth = 0;
	while ($ndays > $months[$mymonth]) {
	    $ndays -= $months[$mymonth];
	    $mymonth++;
	}
	
	# Correctly format the single-integer days:
    $ndays = "0" . $ndays  if ($ndays < 10);
	
	# We use 1-indexed months!
	$mymonth++;
    if ($mymonth > 12) {
        $mymonth = 1;
        $year++;
    }
    $mymonth = "0" . $mymonth  if ($mymonth < 10);

	my @result = ($year, $mymonth, $ndays);
	return @result;
}

sub sec2mjd {
	# We want the division to be integer part only:
	use integer;
	my ($seconds) = @_;
	# Use Jan. 1, 2001 epoch:
	my $mjd_epoch = 51910;
	my $mjd = $mjd_epoch + $seconds / 86400;
	my $remainder = $seconds % 86400;
	no integer;
	my @result = ($mjd, $remainder);
	return @result;
}

sub mmdd_to_doy {
    my ($year, $month, $days) = @_;

    my @months = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 31);
    
    die "Month is too large: $month,"  if ($month > 11);
    
    # Fix syntax of days:
    my $ndays += 0;
    
    #Correct for leap year:
    $months[1]++  if ($year % 4 == 0);	
    $months[1]--  if ($year % 100 == 0);	
    $months[1]++  if ($year % 400 == 0);
	
	#print @months[1] . "\n";
	my $mymonth = 0;
	while ($mymonth < $month) {
	    $ndays += $months[$mymonth];
	    $mymonth++;
	}
	
	$ndays += $days;
	
	# Correctly format the single-integer days:
    $ndays = "0" . $ndays  if ($ndays < 100);
    $ndays = "0" . $ndays  if ($ndays < 10);
	
	my $result = $ndays;
	return $result;
}

sub convert_time {
	use Time::Local; 

	my ($met_sec) = @_;
	my $epoch_sec = timegm(0,0,0,1,0,101);
	my $utc_sec = $epoch_sec + $met_sec;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = gmtime($utc_sec);
	$year += 1900;
	$mon++;
	$yday++;
	
	# Correctly format the single-integer values:
    $mday = "0" . $mday  if ($mday < 10);
    $mon = "0" . $mon  if ($mon < 10);
    $hour = "0" . $hour  if ($hour < 10);
    $min = "0" . $min  if ($min < 10);
    $sec = "0" . $sec  if ($sec < 10);
    $yday = "0" . $yday  if ($yday < 100);
    $yday = "0" . $yday  if ($yday < 10);

	my @result = ($sec,$min,$hour,$mday,$mon,$year,$yday);
	return @result;
}

sub convert_UTC {
	use Time::Local; 

	my ($met_sec) = @_;
	# 01/09/09 RDP: For leap second handling, we need to subract the appropriate number 
	# of seconds after the appropriate time:
	if ($met_sec > 253497600) {$met_sec -= 2}

	return convert_time($met_sec);
}

1;
