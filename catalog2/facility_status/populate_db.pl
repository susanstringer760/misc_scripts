#!/usr/bin/perl
#
# create fake instruments and add to
# zith9_mpex_facility_status db

use Getopt::Std;
use DBI;

if ( $#ARGV < 0 ) {
  print "$0:\n";
  print "\t-n: db name\n";
  print "\t-u: db user\n";
  print "\t-p: db password\n";
  print "\t-h: db host\n";
  print "\t-d: date\n";
  exit();
}

# db information
getopt('nuphd');
my $db_name = $opt_n;
my $db_user = $opt_u;
my $db_password = $opt_p;
my $db_host = $opt_h;
my $date = $opt_d;
my $dbh = connectToDB($db_name,$db_user,$db_password,$db_host);

my $project_id=371;
my %platform_id;
$platform_id{'gv'} = 350;
$platform_id{'c130'} = 130;
$platform_id{'goes_13'} = 405;
$platform_id{'goes_10'} = 232;
$platform_id{'csu_chill'} = 450;
$platform_id{'spol'} = 398;
$platform_id{'wsr_88d'} = 79;
$platform_id{'aws'} = 88;
$platform_id{'gps'} = 150;

my %category_id;
$category_id{'gv'} = 2;
$category_id{'c130'} = 2;
$category_id{'goes_13'} = 15;
$category_id{'goes_10'} = 15;
$category_id{'csu_chill'} = 14;
$category_id{'spol'} = 14;
$category_id{'wsr_88d'} = 14;
$category_id{'aws'} = 19;
$category_id{'gps'} = 19;

my $facility_status_ref = {};
my $sql;

#xx# GV
#xxmy @gv_instrument_arr = (1 .. 15);
#xx@gv_instrument_arr = map("gv_instrument$_", @gv_instrument_arr);
#xxmy @gv_instrument_values;
#xxmy %gv_instrument_category_id;
#xxmy $facility_status_category_id;
#xxmy $facility_status_status;
#xxfor ($i=0; $i<=$#gv_instrument_arr;$i++) {
#xx  my $name = $gv_instrument_arr[$i];
#xx  my $short_name = $name;
#xx  $short_name =~ s/instrument//g;
#xx  my $facility_status_comment = "$name comment";
#xx  if ( $i >= 0 && $i < 5 ) {
#xx    $facility_status_category_id = 58,
#xx    $facility_status_status = 'up';
#xx  } elsif ( $i >= 5 && $i < 12 ) {
#xx    $facility_status_category_id = 59,
#xx    $facility_status_status = 'down';
#xx  } else {
#xx    $facility_status_category_id = 60,
#xx    $facility_status_status = 'provisional';
#xx  }
#xx  # create instrument
#xx  my $instrument_id = insert_instrument($dbh,$name,$short_name);
#xx
#xx  my $hash = {
#xx    'project_id'=>$project_id,
#xx    'platform_id'=>$platform_id{'gv'},
#xx    'instrument_id'=>$instrument_id,
#xx    'category_id'=>$facility_status_category_id,
#xx    'status'=>$facility_status_status,
#xx    'comment'=>$facility_status_comment,
#xx  };
#xx
#xx  my $facility_status_id = insert_facility_status($dbh,$hash,$name);
#xx
#xx  print "asdf: $name and $short_name and $instrument_id\n";
#xx  exit();
#xx
#xx}
#xx
#************************
sub insert_facility_status {

  my $dbh = shift;
  my $column_value_hash = shift;
  print "testit: $id\n";exit();

  # assemble the sql

}
    
sub insert_instrument {

  my $dbh = shift;
  my $name = shift;
  my $short_name = shift;

  # first, make sure it's not a duplicate instrument
  my $instrument_id = get_instrument_id($dbh,$name,$short_name);
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $id = $dbh->selectrow_array($id_sql);
  # don't try to enter duplicate record
  next() if ( $id );
  my $sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
  print "$sql\n";
  $dbh->do($sql) or die "Couldn't execute sql: $instrument_sql$dbh->errstr";
  $instrument_id = get_instrument_id($dbh,$name,$short_name);

  return $instrument_id;

}

sub get_facility_status_id {

  my $dbh = shift;
  my $project_id = shift;
  my $platform_id = shift;
  my $status = shift;
  my $comment = shift;
  my $report_date = shift;

sub insert_facility_status {

  my $sql = "select id from catalog_facility_status where (project_id = $project_id) and (platform_id = $platform_id) and (status='$status') and (comment='$comment') and (report_date='$report_date')";
  print "$sql\n";
  exit();
  
 # my $instrument_id = $dbh->selectrow_array($sql);

 # return $instrument_id;

}
sub get_instrument_id {

  my $dbh = shift;
  my $name = shift;
  my $short_name = shift;
  my $sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  print "$sql\n";
  my $instrument_id = $dbh->selectrow_array($sql);

  return $instrument_id;

}
sub insert_facility_status {

  my $project_id = shift;
  my $platform_id = shift;
  my $instrument_id = shift;
  my $status = shift;
  my $comment = shift;
  my $category_id = shift;

  #first, make sure it's not a duplicate instrument
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $id = $dbh->selectrow_array($id_sql);
  #don't try to enter duplicate record
  next() if ( $id );
  my $sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
  $dbh->do($instrument_sql) or die "Couldn't execute sql: $instrument_sql$dbh->errstr";

}
sub connectToDB()
{

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

sub dbiErrorHandler {

  $error = shift;
  print "ERROR: $error\n";
  exit();

  return 1;

}

