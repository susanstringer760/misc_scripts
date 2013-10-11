#!/usr/bin/perl
#

foreach my $i (0..7)
{
  #my $date = localtime(time() - 60*60*24*$i);
  #my ($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5];
  my $diff = 60*60*24*$i;
  my $time = time;
  $time += $diff;
  my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
  #my $yy = $xx + $diff;
  #print "xx: $xx\n";
  #print "yy: $yy\n\n";
  #next();
  my $report_date = sprintf ('%4d-%02d-%02d %02d:%02d:%02d', $year+1900,$month+1, $day,$hour,$min,$sec) ;

  my $script_fname = "/usr/local/snorman/misc_scripts/catalog2/facility_status/populate_db.pl";
  $script_fname = "$script_fname -n zith9_mpex_facility_status -u snorman -p emdac -h localhost -d '$report_date'";
  system($script_fname);
  exit();
}
