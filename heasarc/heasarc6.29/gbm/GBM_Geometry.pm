package GBM_Geometry;
require Exporter;


=head1 GBM_Geometry:
                 A package to manage the relations between the Spacecraft attitude
                 quaternions, the Earth position vector, the detector angles and 
                 RA and Dec. We primarily need these conversions to manage the input
                 to the DRM generator.

=head2
                 
                 A portion of the GBM ground software:
                 Written, Feb. 4, 2008, by RDP @ UAH.

 NOTES:
       1) Workhorse routine is write_nml, which takes several inputs and writes out 
          a namelist file as input to the DRM generator. 
       2) Also important is get_sc_geometry, which is called by write_nml, that does 
          the angle conversions.
       3) We don't require it, but get_det_geometry is available to determine the 
          angles from the individual detectors to any given source.
       
 DEPENDENCIES (GBM Software):
    DOY, GIOC_globals

 DEPENDENCIES (External Software - must be installed on the system):
    none

 DEPENDENCIES (Standard perl distribution):
    none

 VERSION HISTORY:
              V1.0: 02/04/08 RDP: Baseline for TVAC Oppty. test and ETE#4, prior to FOR.
              V1.1: 02/06/08 RDP: Fixed elevation calculation as per VC.
              V1.2: 03/28/08 RDP: Greatly expanded the number of energy bins in 'write_nml'.
              V1.2: 04/18/08 RDP: Fixed bad characters in 'write_nml'; added atmospheric 
              scattering parameters to the namelist.
              V1.3: 08/13/08 RDP: Added a function get_sc_axes() to obtain the spacecraft  
              x, y & z pointings in RA and Dec. Exporting a fixed dot_product().
              V1.4: 08/27/08 RDP: Made a change in the get_sc_geometry routine to the geo_el 
              value to correct for the 90 - el convention; caught by C. A. Wilson-Hodge.
              V1.5: 09/10/08 RDP: Changed the atmospheric scattering file reference in  
              write_nml to accomodate gbmrsp version 1.6.
              V1.6: 11/10/08 RDP: Made the change to use the direct matrix database, release 02.
              V1.7: 12/05/08 RDP: Made the changes to write_nml to accomodate gbmrsp version 1.7.
              V1.8: 01/09/09 RDP: Changed 1 occurances of convert_time() to convert_UTC(), to 
                    implement the leap second handling of the official trigger name, as per 
                    CCR# 131. Minor changes in write_nml() to accommodate the channel-to-energy
                    audit trail proagation.
              V1.9: 12/22/09 RDP: In write_nml(), checked the number of requested matrices per
                    detector; if more than one, the file is RSP type-II, so the file extension 
                    should be '.rsp2', as per the FFD. Implements CCR#223.
              V1.10: 05/03/10 RDP In light of the file name formattimg issue of May 1, where  
                    the fraction of the day of 999.9 was rounded to $ff = '1000', several changes 
                    have been made. First of all, GbmTime.pm was fixed to accommodate the desired 
                    behavior for the case (999.9 -> '999'). Secondly, GbmTime is now called for 
                    the day fraction, rather than determining it by hand everywhere. Finally, we 
                    export only sec2mjd and convert_time from DOY, so that we use the convert_UTC 
                    from GbmTime.

=cut
use strict;

our $version = "1.10";

our @ISA     = qw(Exporter);
our @EXPORT  = qw(acos asin dot_product get_sc_axes get_scradec get_det_geometry get_sc_geometry write_nml);

my $pi = atan2(1, 1) * 4;
my $dtorad = $pi / 180;
my $radtod = 180 / $pi;
my @nai_el = (20.58, 45.31, 90.21, 45.24, 90.27, 89.79, 20.43, 46.18, 89.97, 45.55, 90.42, 90.32);
my @nai_az = (45.89, 45.11, 58.44, 314.87, 303.15, 3.35, 224.93, 224.62, 236.61, 135.19, 123.73, 183.74);

sub acos {atan2(sqrt(1 - $_[0] * $_[0]), $_[0])}
sub asin {atan2($_[0], sqrt(1 - $_[0] * $_[0]))}

sub dot_product {
	my $sum = 0.; 
	my ($first, $second) = @_;
	my $num_vec = @$first + 0;
	for (my $i = 0; $i < $num_vec; $i++) {
		my $v1 = $$first[$i];
		my $v2 = $$second[$i]; 
		$sum += $v1 * $v2;
	}
	return $sum;
}

sub get_det_geometry {

=head1
**************************************************************************
  FUNCTION:     my $det_angs = get_det_geometry($input_az, $input_el, $det_no); 
  PURPOSE:      Based on  geometry provided by T. Morse, calculate 
                angles to detectors from calling az and el. 
  INPUTS:       $input_az, $input_el  in RADIANS.
                $det_no: Index of the desired detector (0 .. 13).
  OUTPUTS:      det_angs in RADIANS.
  DEPENDENCY:   none.
  SIDE-EFFECTS: none.
**************************************************************************

=cut
	my ($input_az, $input_el, $det_no) = @_; 
	
	# Calculate angles from detectors using
	# detector az el's from T.Morse.
	my $det_angs = acos(cos($nai_el[$det_no] * $dtorad) * cos($input_el) +
						sin($nai_el[$det_no] * $dtorad) * sin($input_el) *
						cos($nai_az[$det_no] * $dtorad - $input_az));
	
	return $det_angs;
}

sub get_scradec {

=head1
**************************************************************************
  FUNCTION:     my ($RA_sc, $Dec_sc) = get_scradec($scpos); 
  PURPOSE:      Get spacecraft axes RA and Dec, given spacecraft cosines.
  INPUTS:       $scpos(0:2): A reference to the three element spacecraft axis direction cosines.
  OUTPUTS:      $RA_sc, $Dec_sc: Spacecraft axes location in DEGREES.
  DEPENDENCY:   none.
  SIDE-EFFECTS: none.
**************************************************************************

=cut	

	my $scpos = shift;
	my ($RA_sc, $Dec_sc);
	# special case for v. small x,y components => polar axis
	if ((abs($$scpos[1]) < 1.e-6 and abs($$scpos[0]) < 1.e-6)) { #then
		$RA_sc = 0.;
	} else {
		$RA_sc = atan2($$scpos[1], $$scpos[0]);
	} #endif
	$RA_sc += 6.2831853 if ($RA_sc < 0.0);
	$Dec_sc = asin(1.) - atan2(sqrt($$scpos[0]**2 + $$scpos[1]**2), $$scpos[2]);

	return ($RA_sc * $radtod, $Dec_sc * $radtod);

}

sub get_sc_axes {

=head1
**************************************************************************
  FUNCTION:     my ($RA_sc, $Dec_sc) = get_sc_axes($sc_quat); 
  PURPOSE:      Get spacecraft axes geometry, given quaternion.
  INPUTS:       $sc_quat(0:3): A reference to the four element spacecraft attitude quaternion.
  OUTPUTS:      $RA_sc, $Dec_sc: Spacecraft axes location in DEGREES.
  DEPENDENCY:   none.
  SIDE-EFFECTS: none.
**************************************************************************

=cut	
	my $sc_quat = shift;	
	my @sc_quat = @$sc_quat;
	my (@scx, @scy, @scz);
	my (@RA_sc, @Dec_sc);

	# first get direction cosines scx(3), scy(3), scz(3) using quaternion identites:
	$scx[0] = ($sc_quat[0]**2 - $sc_quat[1]**2 - $sc_quat[2]**2 + $sc_quat[3]**2);
	$scx[1] = 2.0 * ($sc_quat[0] * $sc_quat[1] + $sc_quat[3] * $sc_quat[2]);
	$scx[2] = 2.0 * ($sc_quat[0] * $sc_quat[2] - $sc_quat[3] * $sc_quat[1]);
	$scy[0] = 2.0 * ($sc_quat[0] * $sc_quat[1] - $sc_quat[3] * $sc_quat[2]);
	$scy[1] = (-$sc_quat[0]**2 + $sc_quat[1]**2 - $sc_quat[2]**2 + $sc_quat[3]**2);
	$scy[2] = 2.0 * ($sc_quat[1] * $sc_quat[2] + $sc_quat[3] * $sc_quat[0]);
	$scz[0] = 2.0 * ($sc_quat[0] * $sc_quat[2] + $sc_quat[3] * $sc_quat[1]);
	$scz[1] = 2.0 * ($sc_quat[1] * $sc_quat[2] - $sc_quat[3] * $sc_quat[0]);
	$scz[2] = (-$sc_quat[0]**2 - $sc_quat[1]**2 + $sc_quat[2]**2 + $sc_quat[3]**2);
	
	($RA_sc[0], $Dec_sc[0]) = get_scradec(\@scx);
	($RA_sc[1], $Dec_sc[1]) = get_scradec(\@scy);
	($RA_sc[2], $Dec_sc[2]) = get_scradec(\@scz);
# print "Dec_sc: ", join("-",@Dec_sc),"\n";
# print "RA_sc: ", join("-",@RA_sc),"\n";
				
	return (\@RA_sc, \@Dec_sc);

}

sub get_sc_geometry {

=head1
**************************************************************************
  FUNCTION:     my ($az, $el, $geo_az, $geo_el) = get_sc_geometry($sc_quat, $sc_pos, $ra, $dec); 
  PURPOSE:      Get geometry, given quaternion and x,y,z. Calculates:
                geo_az, geo_el, geodir (geocenter in angular and Cartesian coordinates)
                scx, scy, scz (3-element direction cosines of spacecraft)
                az, el -- source position in az, el spacecraft coordinates  
  INPUTS:       $sc_quat(0:3): A reference to the four element spacecraft attitude quaternion.
                $sc_pos(0:2): Spacecraft x,y,z position in whatever units (m or km).
                $ra, $dec: Source location in DEGREES.
  OUTPUTS:      $az, $el: Spacecraft-referenced source location in DEGREES.
                $geo_az, $geo_el: Geocenter location in DEGREES.
  DEPENDENCY:   none.
  SIDE-EFFECTS: none.
**************************************************************************

=cut	
	my ($sc_quat, $sc_pos, $ra, $dec) = @_;	
	my @sc_quat = @$sc_quat;
	my @sc_pos = @$sc_pos;
	my (@scx, @scy, @scz);

	# first get direction cosines scx(3), scy(3), scz(3) using quaternion identites:
	$scx[0] = ($sc_quat[0]**2 - $sc_quat[1]**2 - $sc_quat[2]**2 + $sc_quat[3]**2);
	$scx[1] = 2.0 * ($sc_quat[0] * $sc_quat[1] + $sc_quat[3] * $sc_quat[2]);
	$scx[2] = 2.0 * ($sc_quat[0] * $sc_quat[2] - $sc_quat[3] * $sc_quat[1]);
	$scy[0] = 2.0 * ($sc_quat[0] * $sc_quat[1] - $sc_quat[3] * $sc_quat[2]);
	$scy[1] = (-$sc_quat[0]**2 + $sc_quat[1]**2 - $sc_quat[2]**2 + $sc_quat[3]**2);
	$scy[2] = 2.0 * ($sc_quat[1] * $sc_quat[2] + $sc_quat[3] * $sc_quat[0]);
	$scz[0] = 2.0 * ($sc_quat[0] * $sc_quat[2] + $sc_quat[3] * $sc_quat[1]);
	$scz[1] = 2.0 * ($sc_quat[1] * $sc_quat[2] - $sc_quat[3] * $sc_quat[0]);
	$scz[2] = (-$sc_quat[0]**2 - $sc_quat[1]**2 + $sc_quat[2]**2 + $sc_quat[3]**2);
# print "scx: ", join("-",@scx),"\n";
# print "scy: ", join("-",@scy),"\n";
# print "scz: ", join("-",@scz),"\n";

	# Geocenter direction relative to spacecraft pointing:
	my @geodir;
	$geodir[0] = - dot_product([@scx], [@sc_pos]);
	$geodir[1] = - dot_product([@scy], [@sc_pos]);
	$geodir[2] = - dot_product([@scz], [@sc_pos]);
	my $denom = sqrt(dot_product([@geodir] , [@geodir]));
	for my $geodir (@geodir) {$geodir = $geodir / $denom;}
#print "geodir: ", join("-",@geodir),"\n";

	# transform from Cartesian to angular
	my $geo_az = atan2($geodir[1], $geodir[0]);
	if ($geo_az < 0.0) {$geo_az += 2 * $pi;}
	while ($geo_az > 2 * $pi) {$geo_az -= 2 * $pi;}
	my $geo_el = atan2(sqrt($geodir[0]**2 + $geodir[1]**2), $geodir[2]);

	# Third thing (trivial) -- get source_pos from ra, dec
	$dec *= $dtorad;
	$ra *= $dtorad;
	my @source_pos;
	$source_pos[0] = cos($dec) * cos($ra);
	$source_pos[1] = cos($dec) * sin($ra);
	$source_pos[2] = sin($dec);
#print "source_pos: ", join("-",@source_pos),"\n";
	
	# Second thing that might be useful: transform Ra, Dec in j2000 to spacecraft frame Az, El
	# Inputs: scx, scy, scz  defined above, source_pos (which is ra, dec in Cartesian coords	
	# Convert source pos to sc frame
	my @source_pos_sc;
	$source_pos_sc[0] = dot_product([@scx], [@source_pos]);
	$source_pos_sc[1] = dot_product([@scy], [@source_pos]);
	$source_pos_sc[2] = dot_product([@scz], [@source_pos]);
#print "source_pos_sc: ", join("-",@source_pos_sc),"\n";

	# Transform source Cartesian source_pos to az and Elevation (actually zenith)  in sc frame
	my $el = acos($source_pos_sc[2]);
	my $az = atan2($source_pos_sc[1], $source_pos_sc[0]);
	if ($az < 0.0) {$az += 2 * $pi;}
	$el *= $radtod;
	$el = 90 - $el;
	$geo_el *= $radtod;
	$geo_el = 90 - $geo_el;
	$az = ($az + 0.0) * $radtod;
	return ($az, $el, $geo_az * $radtod, $geo_el);

}

sub write_nml {

=head1
**************************************************************************
  FUNCTION:     write_nml($sc_quat, $sc_pos, $ra, $dec); 
						$det_no, $trigger_sec, $object_class, 
						$ebin_edge_out, $tstart, $tstop, $ver_no, $calling_code);
  PURPOSE:      Writes out a namelist file, usable as input to the DRM generator:
  INPUTS:       \@sc_quat(0:3): A reference to the four element spacecraft attitude quaternion.
                \@sc_pos(0:2): Spacecraft x,y,z position in whatever units (m or km).
                $ra, $dec: Source location in DEGREES.
                $det_no: Index of the desired detector (0:13).
                $trigger_sec: UTC time of trigger, in GLAST epoch.
                $object_class: Official source ID from the GBM FSW (i.e.: GRB, UNK, etc.).
                \@ebin_edge_out: List of the channel edges (used to determine size of 
                output side of DRM).
                \@tstart, \@tstop: Lists of UTC time of desired DRMs.
                $ver_no: Version number of desired DRM (goes into the name of the file only).
                $calling_code: Version string of the perl calling code, including name
                $mat_type: [Optional] Output Matrix type; the possible values are: 
					  0: Direct matrix only (includes spacecraft scattering),
					  1: Earth atmospheric xsattering matrix only,
					  2: Summed matrix: direct + earth scattering.
				$calib_scheme: Name of the channel-to-energy calibration scheme
				$gain_cor: Gain correction factor applied to shift fitted 511 keV to the 
					correct value.
				$lut_filename, $lut_checksum: Name and checksum of the look-up table used.
  OUTPUTS:      $az, $el: Spacecraft-referenced source location in DEGREES.
                $geo_az, $geo_el: Geocenter location in DEGREES.
  DEPENDENCY:   get_sc_geometry (see above).
  SIDE-EFFECTS: Creates the file "gbmrsp.nml".
**************************************************************************

=cut	
	my ($sc_quat, $sc_pos, $ra, $dec, 
	    $det_no, $trigger_sec, $object_class, 
	    $ebin_edge_out, $tstart, $tstop, $ver_no, $calling_code, $mat_type,
	    $calib_scheme, $gain_cor, $lut_filename, $lut_checksum,
	    $atscat_filename, $use_coslat_corr) = @_;

	# Set up environmental variables:
	use GIOC_globals;
	# Add our own software directory into the list of includes:
	use lib "$ENV{'GIOC_perldir'}";
	my $softwaredir = $ENV{'GIOC_perldir'};
	my $gioc_base = $ENV{'GIOC_base'};
	use DOY qw(sec2mjd convert_time);
	use GbmTime;
	    
	# Pick the default matrix type to be directly only:
	if (! defined $mat_type) {$mat_type = 0;}
	if (! defined $calib_scheme) {$calib_scheme = "PNBhat1.7";}
	if (! defined $gain_cor) {$gain_cor = 1.;}
	if (! defined $lut_filename) {$lut_filename = "none";}
	if (! defined $lut_checksum) {$lut_checksum = 0xFEED;}
	if (! defined $use_coslat_corr) {$use_coslat_corr = 1;}
	if (! defined $atscat_filename) {$atscat_filename = "test_atscatfile_preeinterp_db002.fits";}
#print "GAIN: $gain_cor\n";	
	my $nobins_out = $#{$ebin_edge_out};
	my $npos = @$tstart + 0;
	
	my @ebin_edge_in_NAI = (5.00000,     5.34000,     5.70312,     6.09094,     
	  6.50513,     6.94748,
     7.41991,     7.92447,     8.46333,     9.03884,     9.65349,     10.3099,
     11.0110,     11.7598,     12.5594,     13.4135,     14.3256,     15.2997,
     16.3401,     17.4513,     18.6380,     19.9054,     21.2589,     22.7045,
     24.2485,     25.8974,     27.6584,     29.5392,     31.5479,     33.6931,
     35.9843,     38.4312,     41.0446,     43.8356,     46.8164,     50.0000,
     53.4000,     57.0312,     60.9094,     65.0513,     69.4748,     74.1991,
     79.2446,     84.6333,     90.3884,     96.5349,     103.099,     110.110,
     117.598,     125.594,     134.135,     143.256,     152.997,     163.401,
     174.513,     186.380,     199.054,     212.589,     227.045,     242.485,
     258.974,     276.584,     295.392,     315.479,     336.931,     359.843,
     384.312,     410.446,     438.356,     468.164,     500.000,     534.000,
     570.312,     609.094,     650.512,     694.748,     741.991,     792.446,
     846.333,     903.884,     965.349,     1030.99,     1101.10,     1175.98,
     1255.94,     1341.35,     1432.56,     1529.97,     1634.01,     1745.13,
     1863.80,     1990.54,     2125.89,     2270.45,     2424.85,     2589.74,
     2765.84,     2953.92,     3154.79,     3369.31,     3598.43,     3843.12,
     4104.46,     4383.56,     4681.65,     5000.00,     5340.00,     5703.12,
     6090.94,     6505.12,     6947.48,     7419.91,     7924.46,     8463.33,
     9038.84,     9653.49,     10309.9,     11011.0,     11759.8,     12559.4,
     13413.5,     14325.6,     15299.7,     16340.1,     17451.3,     18637.9,
     19905.3,     21258.9,     22704.5,     24248.5,     25897.3,     27658.4,
     29539.2,     31547.8,     33693.1,     35984.3,     38431.2,     41044.6,
     43835.6,     46816.4,     50000.0);
	my @ebin_edge_in_BGO = (100.000,     105.579,     111.470,     117.689,     
	  124.255,     131.188,
     138.507,     146.235,     154.394,     163.008,     172.103,     181.705,
     191.843,     202.546,     213.847,     225.778,     238.375,     251.675,
     265.716,     280.541,     296.194,     312.719,     330.167,     348.588,
     368.036,     388.570,     410.250,     433.139,     457.305,     482.820,
     509.757,     538.198,     568.226,     599.929,     633.401,     668.740,
     706.052,     745.444,     787.035,     830.946,     877.307,     926.255,
     977.933,     1032.49,     1090.10,     1150.92,     1215.13,     1282.93,
     1354.51,     1430.08,     1509.87,     1594.11,     1683.05,     1776.95,
     1876.09,     1980.77,     2091.28,     2207.96,     2331.15,     2461.21,
     2598.53,     2743.51,     2896.58,     3058.18,     3228.81,     3408.95,
     3599.15,     3799.96,     4011.97,     4235.81,     4472.14,     4721.65,
     4985.09,     5263.22,     5556.87,     5866.90,     6194.24,     6539.83,
     6904.71,     7289.95,     7696.67,     8126.09,     8579.47,     9058.15,
     9563.53,     10097.1,     10660.5,     11255.2,     11883.2,     12546.2,
     13246.2,     13985.2,     14765.5,     15589.3,     16459.1,     17377.4,
     18346.9,     19370.6,     20451.3,     21592.4,     22797.1,     24069.0,
     25411.8,     26829.7,     28326.6,     29907.0,     31575.6,     33337.3,
     35197.3,     37161.0,     39234.4,     41423.4,     43734.5,     46174.6,
     48750.8,     51470.7,     54342.5,     57374.4,     60575.5,     63955.2,
     67523.4,     71290.7,     75268.2,     79467.7,     83901.5,     88582.6,
     93524.9,     98742.9,     104252.,     110069.,     116210.,     122693.,
     129539.,     136766.,     144397.,     152453.,     160959.,     169939.,
     179421.,     189431.,     200000.);
	my @ebin_edge_in = ($det_no < 12) ? @ebin_edge_in_NAI : @ebin_edge_in_BGO;
	my $nobins_in = $#ebin_edge_in;
	my $type = ($nobins_out == 8) ? "ctime" : "cspec";
	my $prefix = ($det_no < 12) ? 'n' : 'b';
	my $det_name = sprintf "${prefix}%lx", $det_no % 12;
	$ver_no = 0 if ! defined $ver_no;
	my $ver_str = sprintf "%02u", $ver_no;
	my ($sec,$min,$hour,$day,$month,$year,$yday) = &convert_UTC($trigger_sec);
	#Truncate the year to 2 digits, as per the ICD:
	my $short_year = substr($year, 2, 2);
	my (undef, $fraction) = met2bn($trigger_sec); # sprintf("%03.0f", ($sec + 60 * $min + 60 * 60 * $hour) / 86_400 * 1000);
	my $history_name = "glg_${type}_${det_name}_bn$short_year$month$day${fraction}_v${ver_str}.rsp";
	$history_name .= "2" if $npos > 1;
	# Check to see that the file doesn't already exist (since gbmrsp.exe will refuse to write the file):
	if (-e $history_name) {
		# If so, try *permanently* bumping up the version number:
		my (undef, undef, undef, undef, $ver_test) = split /_/, $history_name;
		($ver_test, undef) = split /./, $ver_test;
		$ver_test = substr($ver_test,1);
		# Make the change permanent, so we don't have to change each time:
		$ver_no = ++$ver_test;
		$ver_str = sprintf "%02u", $ver_no;
		$history_name = "glg_${type}_${det_name}_bn$short_year$month$day${fraction}_v${ver_str}.rsp";
	}
	
	my (@az_arr, @el_arr, @geo_az_arr, @geo_el_arr);
	for (my $i = 0; $i < $npos; $i++) {
		my ($az, $el, $geo_az, $geo_el) = get_sc_geometry($$sc_quat[$i], $$sc_pos[$i], $ra, $dec);
		push @az_arr, $az;
		push @el_arr, $el;
		push @geo_az_arr, $geo_az;
		push @geo_el_arr, $geo_el;
	}
	my $nml_file = "gbmrsp_${det_name}.nml";
	open NML, "> $nml_file";
	print NML '&gbmrsp_inputs';
	print NML " debug=0, detector=$det_no, triflag=0,\n";
	print NML " read_one_drm=0, one_drm_path='none', one_drm_file='none',\n";
	print NML "infile='",$softwaredir,"/inputs/gridpos_InitialGBMDRMdb001.dat',\n";
	print NML "tripath='",$softwaredir,"/inputs/',\n";
	print NML "trifile='InitialGBMDRM_triangleinfo_db001.fits',\n";
	print NML "calling_code='",$calling_code,"',\n";
	print NML "src_ra=$ra, src_dec=$dec,\n";
	print NML "drmdbpath='",$gioc_base,"/GBMDRMdb002/',\n";
	print NML "nobins_in=$nobins_in, nobins_out=$nobins_out,\n";
	print NML "ebin_edge_in = ";
	my $jj = 1;
	for my $edge (@ebin_edge_in) {print NML "$edge  "; print NML "\n  " if $jj % 6 == 0; $jj++}
	print NML ",\n";
	$jj = 1;
	print NML "ebin_edge_out = ";
	for my $edge (@$ebin_edge_out) {print NML sprintf("%3.3f", $edge), "  "; print NML "\n  " if $jj % 4 == 0; $jj++}
	print NML ",\n";
	$jj = 1;
	print NML "npos=$npos,\n";
	print NML "src_az= ";
	for my $az (@az_arr) {print NML $az + 0.0, "  "; print NML "\n  " if $jj % 3 == 0; $jj++}
	print NML ",\n";
	$jj = 1;
	print NML "src_el= ";
	for my $el (@el_arr) {print NML $el + 0.0, "  "; print NML "\n  " if $jj % 3 == 0; $jj++}
	print NML ",\n";
	$jj = 1;
	print NML "geo_az= ";
	for my $geo_az (@geo_az_arr) {print NML $geo_az + 0.0, "  "; print NML "\n  " if $jj % 3 == 0; $jj++}
	print NML ",\n";
	$jj = 1;
	print NML "geo_el= ";
	for my $geo_el (@geo_el_arr) {print NML $geo_el + 0.0, "  "; print NML "\n  " if $jj % 3 == 0; $jj++}
	print NML ",\n";
# 	print NML "geo_az= ", $geo_az + 0.0, ", \n";
# 	print NML "geo_el= ", $geo_el + 0.0, ",\n";
	$jj = 1;
	print NML "tstart= ";
	for my $start (@$tstart) {print NML $start, "  "; print NML "\n  " if $jj % 3 == 0; $jj++} 
	print NML ", \n";
	$jj = 1;
	print NML "tstop= ";
	for my $stop (@$tstop) {print NML $stop, "  "; print NML "\n  " if $jj % 3 == 0; $jj++} 
	print NML ", \n";
# 	print NML "tstop= ",${$tstop}[0],",\n";
	print NML "trigger_sec = $trigger_sec, \n";
	print NML "history_name='$history_name',\n";
	print NML "object_class='$object_class',\n";
	print NML "energy_calib_scheme='$calib_scheme', gain_cor=$gain_cor, \n";
	print NML "lut_filename='$lut_filename', lut_checksum='$lut_checksum', \n";
	print NML "use_coslat_corr=$use_coslat_corr, leaf_ver='v10', \n";
    print NML "matrix_type=$mat_type, atscat_path='",$softwaredir,"/inputs/',  \n";
    print NML "atscat_file='$atscat_filename' / \n";

	close NML;

	return $nml_file;
}

1;

=head1

perl -e 'use GBM_Geometry; my $sc_quat=[0.712331473827362,0.27334913611412,0.511306762695312,0.395511716604233]; $sc_pos=[-6632, 1956, -492]; $ra=0;$dec=-55.0;$det_no=3; $trigger_sec=216846170.60823; $object_class="GRB20071115";@ebin_edge_out=map {$_ * 10.} (1..129); $tstart=[216966900.13834]; $tstop=[216966900.13834];write_nml($sc_quat, $sc_pos, $ra, $dec,$det_no, $trigger_sec, $object_class, [@ebin_edge_out], $tstart, $tstop, 0);'
