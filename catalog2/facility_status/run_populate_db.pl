#!/usr/bin/perl
#

use Time::Local;
# script to populate database for 40 days

#my $begin = timelocal(0,0,0,1,4,113);
#my $end = timelocal(59,59,23,30,5,113);
my $begin = timegm(0,0,0,1,5,113);
my $end = timegm(59,59,23,30,6,113);
# epoch begin time (2013/05/01)
my $begin = 1367366400;
# epoch begin time (2013/06/30)
my $end = 1372636799;

my $i = 1;
my $time = $begin;
while(1) {
  my $diff = 60*60*24*$i;
  $time = $begin + $diff;
  my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
  my $report_date = sprintf ('%4d-%02d-%02d %02d:%02d:%02d', $year+1900,$month+1, $day,$hour,$min,$sec);
  print "$report_date\n";
  my $script_fname = "/usr/local/snorman/misc_scripts/catalog2/facility_status/populate_db.pl";
  $script_fname = "$script_fname -n zith9_mpex_facility_status -u snorman -p emdac -h localhost -d '$report_date'";
  print "$script_fname\n";
  system($script_fname);
  $i++;
  last if ($time > $end );
}
exit();



foreach my $i (1..40)
{
  #my $date = localtime(time() - 60*60*24*$i);
  #my ($sec,$min,$hour,$day,$month,$year) = (localtime(time))[0,1,2,3,4,5];
  my $diff = 60*60*24*$i;
  my $time = time;
  $time += $diff;
  my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
  my $report_date = sprintf ('%4d-%02d-%02d %02d:%02d:%02d', $year+1900,$month+1, $day,$hour,$min,$sec) ;

  my $script_fname = "/usr/local/snorman/misc_scripts/catalog2/facility_status/populate_db.pl";
  $script_fname = "$script_fname -n zith9_mpex_facility_status -u snorman -p emdac -h localhost -d '$report_date'";
  print "$script_fname\n";
  #system($script_fname);
}
