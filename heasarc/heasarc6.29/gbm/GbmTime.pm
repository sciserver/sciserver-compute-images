package GbmTime;
require Exporter;
use strict;

=head1
**************************************************************************

         GbmTime: Another package of time-related utility functions.
              (This complements DOY.pm)
              A portion of the GBM ground software:
              Written, Nov 25, 2009, by WHC @ USRA.

              V0.1: 11/25/09 WHC Added met_leapsecs, met2mjd, met2tjd,
                             met2tt, and met2utc
              V0.2: 11/30/09 WHC added isLeapsec, met2utcString met2ttString and 
                             modified met2utc to return the leap second as mm:60. 
              V0.3: 12/11/09 WHC added convert_UTC which is compatible with
                             DOY::convert_UTC.
              V1.0: 12/18/09 WHC completed tests and released GbmTime as
                             version 1.0 
              V1.1: 05/03/10 RDP Fixed fraction of day formatting in met2bn($met)  
                             so that a fraction of 999.9 is not rounded to the four
                             digit string '1000', but rather truncated to '999'.

Functions:
 $nleapsecs = met_leapsecs($met);
              Returns the number of leapsecs that occured between launch and the 
              given MET.

 ($mjd, $rem) = met2mjd($met);
              Returns the MJD and remaining secs of the day in UTC.

 ($tjd, $rem) = met2tjd($met);
              Returns the TJD and remaining secs of the day in UTC.
              
 ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = met2tt($met)
              Returns the calendar time based in TT.
              note: The output is based on gmtime.
                    Therefore $mon = 0..11 and $year = number of years since 1900.

 ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = met2utc($met)
              Returns the calendar time based in UTC.
              note: The output is based on gmtime.
                    Therefore $mon = 0..11 and $year = number of years since 1900.

  $string = met2utcString($met)
              Returns a string representing the time in UTC.
              
  $string = met2ttString($met)
              Returns a string representing the time in TT.
              
 (yymmdd, fff) = met2bn($met)
              Returns the burst number as a tuple compatible with use on GCN.
              
 $string = met2bnString($met)
              Returns the burst number as a string using the format "bnyymmddfff"
 
 ($sec,$min,$hour,$mday,$mon,$year,$yday) = convert_UTC($met)
              Returns the calendar time based in UTC.
              Compatible with output of DOY::convert_UTC()
              $sec = 00...59, $min = 00..59, $hour = 00..23,
              $mday = 1...31, $mon = 1...12, $year = 2001...9999, $yday = 001...366 
              
                                              
**************************************************************************
=cut
our @ISA      = qw(Exporter);
our @EXPORT   = qw(met_leapsecs met2mjd met2tjd met2tt met2utc met2utcString met2ttString
					met2bn met2bnString convert_UTC);
our $VERSION  = 1.1;

# Some module constants
use constant SECS_IN_A_DAY => 86400;
use constant MJD_EPOCH => 51910;			# Jan 1, 2001
use constant UNIX_EPOCH => 978307200;	# Jan 1, 2001
use constant GBM_OFFSET => 64.184; 			# The number of seconds between TT and UTC at MET(0)
use constant MJD_TO_TJD_OFFSET => 40000;

# An array of Leap Seconds
my @TT_UTC = (
	# [ MET, TOTAL LEAPSEC SINCE LAUNCH ]
	[ 252460800, 2 ],# Dec 31, 2009 23:59:59 UTC	
	[ 157766399, 1 ] # Dec 31, 2006 23:59:59 UTC
);
	


sub met_leapsecs {
	
	# This conversion routine allows for historical MET conversions to UTC
	# by returning the number of leap seconds between launch and the given MET.
	# The idea is to only have to add leap seconds to an array when they are announced.
	#
	# This functions solves two problems:
	#   1. Ingest deals with historical (non-realtime) data and therefore must be able
	#      to apply the correct number of leap seconds when converting older METs to UTC.
	#
	#   2. Handles boundary issues correctly. A burst that happened just prior to a leap second
	#      will most likely be uploaded to the trigger catalog (HiTL) just after the leap second.
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;
	
	# Verify MET is non-negative
	if($met < 0) {
		die "Mission elapsed time has an invalid value (less than zero)\n";
	}
	
	# find the appropriate number of leapsecs
	foreach (@TT_UTC) {
		my ($m, $l) = @$_;
		if( $met > $m) {
			return $l;
		}
	}
	
	# The MET was less than any Leap Second announcement within array
	return 0;
}

sub _isLeapsec {
	
	# This routine returns true if the MET given is a leap second
	#
	# Written by WHC on Nov 30, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;
	
	# Is the met within the array of leap seconds?
	foreach (@TT_UTC) {
		my ($m, $l) = @$_;
		if( $met == $m+1) {
			return 1;
		}
	}
	
	# The met is not within the array
	return 0;
}


sub met2mjd
{
	# This function returns the MJD and the seconds of the day in UTC.
	#
	# This function is based off code written by RDP in DOY.pm
	#
	# This version fixes the following:
	# 1. The MJD returned is UTC and not TT. This doesn't show up unless the MET is within the 
	#    number of leapsecs from midnight. Also, the remainder of the day was always off by the
	#    number of leapsecs.
	# 
	# 2. The remainder of the day only returned whole seconds (truncated not rounded) and not the
	#    fractional portion.
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}
	 
	my $met = shift;

	# Verify MET is non-negative
	if($met < 0) {
		die "Mission elapsed time has an invalid value (less than zero)\n";
	}
	
	# subtract the leap seconds so that the TJD will be in UTC
	$met -= met_leapsecs($met);

	# Keep the fraction of a second
	my $fsec = $met - int($met);

	# Perform the conversion	
	my $mjd = MJD_EPOCH + int($met / SECS_IN_A_DAY);
	my $rem = ($met % SECS_IN_A_DAY) + $fsec;

	my @result = ($mjd,$rem);
	return(@result);
}

sub met2tjd {
	# This function returns the TJD and the seconds of the day in UTC.
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;
	my ($mjd, $rem) = met2mjd($met);
	return ($mjd - MJD_TO_TJD_OFFSET, $rem); 	
}

sub _met2time {
	use Time::Local; 

	# Function converts MET into time struct
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}
	
	my $met = shift;
	my $unix = UNIX_EPOCH + $met;
	return gmtime($unix);
}

sub met2tt {

	# Function converts MET into TT based time struct
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;
	
	# Verify MET is non-negative
	if($met < 0) {
		die "Mission elapsed time has an invalid value (less than zero)\n";
	}
	
	# Adjust to TT
	my $tt = $met + GBM_OFFSET;
	return _met2time($tt);
}
	
sub met2utc {

	# Function converts MET into UTC based time struct
	#
	# Written by WHC on Nov 25, 2009

	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;
	
	# Verify MET is non-negative
	if($met < 0) {
		die "Mission elapsed time has an invalid value (less than zero)\n";
	}
	
	# Adjust to UTC
	my $utc = $met - met_leapsecs($met);
	my @time = _met2time($utc);
	
	# Special case: met given is a designated leap second
	#if(_isLeapsec($met)) {
	#	$time[0] += 1; # Make it 60 second of the minute
	#}
	
	return @time;
}

sub met2bn {

	# Function converts MET into GBM Burst Number.GbmTime::
	#
	# Returns ("YYMMDD", "FFF") where:
	# YY = year, MM = month, DD = day and 
	# FFF = fraction of day.
	#
	# Written by WHC on Nov 25, 2009
	
	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;

	# Verify MET is non-negative
	if($met < 0) {
		die "Mission elapsed time has an invalid value (less than zero)\n";
	}
	
	# Adjust to match a known bug in the old pipeline software
	if($met > 157766399 && $met < 252460801) {
		$met++;
	}
	elsif($met > 252460800 && $met <= 253497600) {
		$met+=2; 
	};

	# Burst number is based on UTC date and time
	my ($sec,$min,$hour,$mday,$mon,$year) = GbmTime::met2utc($met);
	$year += 1900;
	$mon++;
	
	# We are only interested in the last 2 digits of the year
	$year = $year % 100;
	
	# Create the YYMMDD string
	my $yymmdd = sprintf("%02d%02d%02d", $year, $mon, $mday);
	
	# Create the FFFF string
	my $frac = (($hour * 3600 + $min * 60 + $sec) / SECS_IN_A_DAY) * 1000;
	my $fff = sprintf("%03.0f", $frac);
	# 4/30/2010 RDP: catch the edge effect, where the trigger is at the day boundary...
	$fff = "999" if $fff == "1000";
	
	return ($yymmdd, $fff);
} 

sub met2bnString {

	# Function converts MET into GBM Burst Number.GbmTime::
	#
	# Returns ("YYMMDD", "FFF") where:
	# YY = year, MM = month, DD = day and 
	# FFF = fraction of day.
	#
	# Written by WHC on Nov 25, 2009
	
	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}

	my $met = shift;

	my ($ymd, $fff) = met2bn($met);
	
	return "bn" . $ymd . $fff;	
}

sub met2utcString {
	# Function converts MET into UTC Calendar string.
	#
	# Written by WHC on Nov 30, 2009
	
	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}
	
	my $met = shift;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = GbmTime::met2utc($met);
	$year += 1900;
	$mon++;
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d UTC", $year, $mon, $mday, $hour, $min, $sec);
}	

sub met2ttString {
	# Function converts MET into TT Calendar string.
	#
	# Written by WHC on Nov 30, 2009
	
	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}
	
	my $met = shift;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = GbmTime::met2tt($met);
	$year += 1900;
	$mon++;
	return sprintf("%04d-%02d-%02d %02d:%02d:%02d TT", $year, $mon, $mday, $hour, $min, $sec);
}	

sub convert_UTC {
	# Function converts MET into TT Calendar string.
	#
	# Written by WHC on Nov 30, 2009
	
	# Verify the correct number of parameters
	if(@_ != 1) {
		die "Invalid number of parameters. Only expecting MET\n";
	}
	my $met = shift;
	
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday) = GbmTime::met2utc($met);
	$year += 1900;
	$mon++;
	$yday++;

	# format the data to match the old DOY routine
	$sec = sprintf("%02d", $sec);
	$min = sprintf("%02d", $min);
	$hour = sprintf("%02d", $hour);
	$mday = sprintf("%02d", $mday);
	$mon = sprintf("%02d", $mon);
	$year = sprintf("%04d", $year);
	$yday = sprintf("%03d", $yday);

	return ($sec,$min,$hour,$mday,$mon,$year,$yday);	
}

1;
