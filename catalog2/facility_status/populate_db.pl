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

# GV
my @gv_instrument_arr = (1 .. 15);
@gv_instrument_arr = map("gv_instrument$_", @gv_instrument_arr);
my @gv_instrument_values;
my %gv_instrument_category_id;
my $facility_status_category_id;
my $facility_status_status;
for ($i=0; $i<=$#gv_instrument_arr;$i++) {
  my $name = $gv_instrument_arr[$i];
  my $short_name = $name;
  $short_name =~ s/instrument//g;
  my $facility_status_comment = "$name comment";
  if ( $i >= 0 && $i < 5 ) {
    $facility_status_category_id = 58,
    $facility_status_status = 'up';
  } elsif ( $i >= 5 && $i < 12 ) {
    $facility_status_category_id = 59,
    $facility_status_status = 'down';
  } else {
    $facility_status_category_id = 60,
    $facility_status_status = 'provisional';
  }
  # create instrument
  my $instrument_id = insert_instrument($dbh,$name,$short_name);

  my $hash = {
    'project_id'=>$project_id,
    'platform_id'=>$platform_id{'gv'},
    'instrument_id'=>$instrument_id,
    'category_id'=>$facility_status_category_id,
    'status'=>$facility_status_status,
    'comment'=>$facility_status_comment,
    'report_date'=>$date,
  };

  my $facility_status_id = insert_facility_status($dbh,$hash);

}

#************************
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

  my $dbh = shift;
  my $row_hash = shift;

  my $project_id = $row_hash->{'project_id'};
  my $platform_id = $row_hash->{'platform_id'};
  my $instrument_id = $row_hash->{'instrument_id'};
  my $category_id = $row_hash->{'category_id'};
  my $status = $row_hash->{'status'};
  my $comment = $row_hash->{'comment'};
  my $report_date = $row_hash->{'report_date'};

  my $sql = "select id from catalog_facility_status where (project_id = $project_id) and (platform_id = $platform_id) and (status='$status') and (comment='$comment') and (report_date='$report_date')";
  my $id = $dbh->selectrow_array($sql);
  next() if ( $id );
  my $sql = "INSERT INTO catalog_facility_status (project_id,platform_id,instrument_id,category_id,status,comment,report_date) VALUES ($project_id,$platform_id,$instrument_id,$category_id,'$status','$comment','$report_date')";
  print "facility_status: $sql\n";
  $dbh->do($sql) or die "Couldn't execute facility status sql: $dbh->errstr";


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

