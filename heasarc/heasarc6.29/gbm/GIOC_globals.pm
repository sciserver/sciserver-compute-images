#!/usr/bin/perl
use strict;

package GIOC_globals;
# require Exporter;
# 
# our @ISA     = qw(Exporter);
# our @EXPORT  = qw(GIOC_globals );

=head1 GIOC_globals.pm:
                 A package that defines all the environment variables that are 
                 specific for each installation of the GBM pipeline software.
                 This package should be declared in any software that uses the 
                 canonical processing directories; most importantly, the directory 
                 that holds the GIOC pipeline software.

=head2
                 
                 A portion of the GBM ground software:
                 Written very long ago by RDP @ UAH.

 NOTES:
       1) USAGE: (in GIOC perl code) e.g.:
		use GIOC_globals;
		my $software = $ENV{'GIOC_perldir'};
		use lib $software;
		chdir $software;

       2) The new design realizes a singleton pattern: by executing the BEGIN block only if 
          GIOC_base has not yet been defined, we ensure that the environment variables are only 
          defined once per session, no matter how many madules contain 'use GIOC_globals;'. 
          This buys us the flexibility to redefine any one of the variables, such as 
          'l1_stage_dir' on the fly, and make it stick throughout the current run. Practically 
          speaking, we use this for reprocessing, to move files off of the primary processing 
          directory ('l1_stage_dir') to another ('reprocess_dir'), which allows two separate 
          instances of the pipeline to run simultaneously without collisions.
       
 DEPENDENCIES:
 
    (None)

 VERSION HISTORY:
              V1.0: RDP Baseline.

              V1.1: 03/27/09 RDP Changed to singleton design, to support reprocessing dir change.

              V1.2: 04/30/09 RDP Added $tmp_dir environment variable, for portability: we 
              don't want to stick the temporarily archived tar files in /tmp on sledgehammer 
              while we are reprocessing, since it gets filled up. The new variable allows us 
              to determine the holding area for each delivered installation.

=cut


BEGIN {
	
	# Make this a singleton; only run through it once per session, so that the ENV variables
	# stick. this will allow us to change the processing stage for reprocessing:
	if (! defined $ENV{'GIOC_base'}) {
		# print "GIOC_globals first run!\n";
		my $base  = '/opt/fermi/gbm';  ### HERA
		$ENV{'GIOC_base'}    = $base;
		$ENV{'GIOC_perldir'} = "$base/software/";
		$ENV{'MOC_datadir'}  = "$base/MOC/";
		$ENV{'GSSC_datadir'} = "$base/GSSC/";
		$ENV{'GIOC_datadir'} = "$base/GIOC/";
		$ENV{'LIOC_datadir'} = "$base/LISOC/";
		$ENV{'MGIOC_datadir'}= "$base/MGIOC/";
		$ENV{'archive_base'} = "$base/archive/";
		$ENV{'l1_stage_dir'} = "$base/level1stage/";
		$ENV{'reprocess_dir'}= "$base/reprocessing/";
		$ENV{'upload_dir'}   = "$base/uploads/";
		$ENV{'plotting_dir'} = "$base/Dailyplots/";
		$ENV{'tmp_dir'}      = "/tmp";
		$ENV{'trigger_stage_dir'} = "$base/level1stage/";
		$ENV{'burst_window'} = 4000.;
		# Used by the calibration software:
		$ENV{'cal_version'} = '2.0';
		$ENV{'cal_form'} = 'SPLINE';
		$ENV{'cal_datapath'} = "$base/software/calibration/";
	}
}

1;
