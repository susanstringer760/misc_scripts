#!/usr/bin/perl
#
# create fake instruments and add to
# zith9_mpex_facility_status db

use Getopt::Std;
use DBI;
require "db.config";

if ( $#ARGV <= 0 ) {
  print "$0:\n";
  print "\t-n project abrev\n";
  print "\t-i project id\n";
  print "\t-s status index (1-3)\n";
  print "\t-d date (YYYY-MM-DD)\n";
  exit();
}

getopt('nids');
my $project_name = $opt_n;
my $project_id = $opt_i;
my $date = $opt_d;
my $status_index = $opt_s;

$status_index = 0 if (!$status_index);

my @status_arr1;
my %status_hash;
$status_hash['0'] = ["up","down","provisional"];
$status_hash['1'] = ["down","provisional","up"];
$status_hash['2'] = ["provisional","up","down"];

print "$date: $status_index = $status_hash[$status_index][0]\n";

# connect to db 
my $dbh = connectToDB();

my $platform_table_name = "$project_name"."_platforms";
my $category_table_name = "$project_name"."_categories";

# create temporary platform table
my $platform_sql = "create temporary table if not exists $platform_table_name as (select dp.dataset_id,dp.platform_id,p.name from dataset_platform dp, platform p where dp.dataset_id in (select dataset_id from dataset_project where project_id = $project_id) and p.name like '%,%' and dp.platform_id = p.id)";
$dbh->do($platform_sql);

# create temporary category table
my $category_sql = "create temporary table if not exists $category_table_name as (select dc.dataset_id,dc.category_id,c.name from dataset_category dc, category c where dc.dataset_id in (select dataset_id from dataset_project where project_id = $project_id) and dc.category_id = c.id)";
$dbh->do($category_sql);

#
my $platform_category_sql = "select distinct p.platform_id,p.name,c.category_id,c.name from $platform_table_name p, $category_table_name c where p.dataset_id=c.dataset_id order by p.platform_id";
my @platform_category_arr = @{$dbh->selectall_arrayref("$platform_category_sql")};

my $platform_id_index = 0;
my $platform_name_index = 1;
my $category_id_index = 2;
my $category_name_index = 3;
my $num_instruments = 4;
my ($status,$comment);
my $add_flag = true;
for ($i=0; $i <= $#platform_category_arr; $i++) {
  $status = $status_hash[$status_index][0] if (($i % 1)==0);
  $status = $status_hash[$status_index][1] if (($i % 2)==0);
  $status = $status_hash[$status_index][2] if (($i % 3)==0);
  #$status = 'up' if ($i % 1) == 0;
  #$status = 'down' if ($i % 2) == 0;
  #$status = 'provisional' if ($i % 3) == 0;
  my $platform_id = $platform_category_arr[$i][$platform_id_index];
  my $platform_name =  $platform_category_arr[$i][$platform_name_index];
  #print "processing $platform_name\n";
  next if ($platform_name =~ /report/i);
  my $category_id = $platform_category_arr[$i][$category_id_index];
  my $category_name = $platform_category_arr[$i][$category_name_index];
  #$status = "up"; 
  $comment = "$project_name: $platform_name comment";
  $add_flag = true;
  if ($platform_name =~ /Aircraft/) {
    for ($j = 1;$j <= $num_instruments; $j++) {
      $status = $status_hash[$status_index][0] if (($j % 1)==0);
      $status = $status_hash[$status_index][1] if (($j % 2)==0);
      $status = $status_hash[$status_index][2] if (($j % 3)==0);
#      $status = 'up' if ($j % 1) == 0;
#      $status = 'down' if ($j % 2) == 0;
#      $status = 'provisional' if ($j % 3) == 0;
      #$status = "up";
      $platform_name =~ /(Aircraft),([\w\d\-\_\s]+)/;
      #my $instrument_short_name = $2;
      my $instrument_name = $2;
      $instrument_name =~ s/(^\s+)||(\s+$)//g;
      $instrument_name =~ s/\s+/\_/g;
      my $instrument_short_name = $instrument_name;
      $instrument_name .= "_instrument$j";
      $instrument_short_name .= "_$j";
      $comment = "$project_name: $platform_name instrument$j comment";
      my $instrument_id = insert_instrument($dbh,$instrument_name,$instrument_short_name);
      my $facility_status_id = insert_facility_status($dbh,$project_id,$platform_id,$instrument_id,$category_id,$status,$comment,$date);
    } 
    $add_flag = false;
  }
  $num_instruments += 2;
  # now add facility_status platform
  if ( $add_flag eq 'true') {
    my $facility_status_id = insert_facility_status($dbh,$project_id,$platform_id,$instrument_id,$category_id,$status,$comment,$date);
  }

}

$dbh->disconnect();
#***************************
sub insert_instrument {

  my $dbh = shift;
  my $name = shift;
  my $short_name = shift;

  # first, make sure it's not a duplicate instrument
  my $instrument_id = get_instrument_id($dbh,$name,$short_name);
  my $id_sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  my $id = $dbh->selectrow_array($id_sql);
  # don't try to enter duplicate record
  return $id if ( $id );
  my $sql = "INSERT INTO instrument (name,short_name) VALUES ('$name','$short_name')";
  #print "$sql\n";
  $dbh->do($sql) or die "Couldn't execute sql: $instrument_sql $dbh->errstr";

  return $id;

}
sub get_facility_status_id {

  my $dbh = shift;
  my $project_id = shift;
  my $platform_id = shift;
  my $status = shift;
  my $comment = shift;
  my $report_date = shift;

  my $sql = "select id from catalog_facility_status where (project_id = $project_id) and (platform_id = $platform_id) and (status='$status') and (comment='$comment') and (report_date='$report_date')";
  my $id = $dbh->selectrow_array($sql);

  return $id;

} 
sub get_instrument_id {

  my $dbh = shift;
  my $name = shift;
  my $short_name = shift;
  my $sql = "SELECT id FROM instrument WHERE name='$name' AND short_name='$short_name'";
  #print "$sql\n";
  my $instrument_id = $dbh->selectrow_array($sql);

  return $instrument_id;

}
sub insert_facility_status {

  my $dbh = shift;
  my $project_id = shift;
  my $platform_id = shift;
  my $instrument_id = shift;
  my $category_id = shift;
  my $status = shift;
  my $comment = shift;
  my $report_date = shift;

  $instrument_id = 'NULL' if (!$instrument_id);

  my $id = get_facility_status_id($dbh,$project_id,$platform_id,$status,$comment,$report_date);
  return $id if ( $id );
  my $sql = "INSERT INTO catalog_facility_status (project_id,platform_id,instrument_id,category_id,status,comment,report_date) VALUES ($project_id,$platform_id,$instrument_id,$category_id,'$status','$comment','$report_date')";
  #print "$sql\n";
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
#sub connectToDB()
#{
#
#  my $db_name = shift;
#  my $user = shift;
#  my $password = shift;
#  my $host = shift;
#
#  return DBI->connect( "DBI:mysql:database=$db_name;
#                       host=$host",
#                       "$user",
#                       "$password",
#                       { PrintError => 0,
#                         PrintWarn => 1,
#                         RaiseError => 1,
#                         HandleError => \&dbiErrorHandler,
#                       } ) || die( "Unable to Connect to database" );
#
#}
#
#sub dbiErrorHandler {
#
#  $error = shift;
#  print "ERROR: $error\n";
#  exit();
#
#  return 1;
#
#}

