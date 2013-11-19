#!/usr/bin/perl
#
use Getopt::Std;
use Time::Local;
use DBI;
require "db.config";

# script to run the script to populate the script
# that populates the catalog_facility_status records 

if ( $#ARGV < 0 ) {
  print "Usage: $0\n";
  print "\t-i: project id\n";
  exit();
}

getopt('i');
my $project_id = $opt_i;

# connect to db 
$dbh = connectToDB($db_name,$db_user,$db_password,$db_host);

#
my $sql = "select name,begin_date,end_date from project where id = $project_id";
my $array_ref = $dbh->selectrow_arrayref($sql);
my $project_name = $array_ref->[0];
$array_ref->[1] =~ /(\d{4})-(\d{2})-(\d{2})(.*)/;

# begin date
my $begin_sec = 0;
my $begin_min = 0;
my $begin_hour = 0;
my $begin_year = $1-1900;
my $begin_month = $2-1;
my $begin_day = $3;
my $begin_epoch = timegm($begin_sec,$begin_min,$begin_hour,$begin_day,$begin_month,$begin_year); 

# end date
$array_ref->[2] =~ /(\d{4})-(\d{2})-(\d{2})(.*)/;
my $end_sec = 0;
my $end_min = 0;
my $end_hour = 0;
my $end_year = $1-1900;
my $end_month = $2-1;
my $end_day = $3;
my $end_epoch = timegm($end_sec,$end_min,$end_hour,$end_day,$end_month,$end_year); 

my $i = 1;
my $time = $begin_epoch;
while(1) {
  my $diff = 60*60*24*$i;
  $time = $begin_epoch + $diff;
  my ($sec,$min,$hour,$day,$month,$year) = (localtime($time))[0,1,2,3,4,5];
  #my $report_date = sprintf ('%4d-%02d-%02d %02d:%02d:%02d', $year+1900,$month+1, $day,$hour,$min,$sec);
  my $report_date = sprintf ("%4d-%02d-%02d", $year+1900,$month+1,$day);
  #print "$report_date\n";
  my $script_fname = "/usr/local/snorman/misc_scripts/catalog2/facility_status/populate_db.pl -n $project_name -i $project_id -d $report_date";
  print "$script_fname\n";
  system($script_fname);
  $i++;
  last if ($time > $end_epoch );
}
#***************************
sub connectToDB() {

  my $db_name = shift;
  my $user = shift;
  my $password = shift;
  my $host = shift;

  return DBI->connect( "DBI:mysql:database=$db_name;
                       host=$host",
                       "$user",
                       "$password",
                       { PrintError => 0,
                         PrintWarn => 1,
                         RaiseError => 1,
                         HandleError => \&dbiErrorHandler,
                       } ) || die( "Unable to Connect to database" );

}

exit();
